import 'dart:convert';

import 'package:lakuna_domain/lakuna_domain.dart' show Hlc, secretHash;
import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:lakuna_server/src/sync/server_version.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

final tenantId = UuidValue.fromString('01900000-0000-7000-8000-000000000001');
final otherTenantId = UuidValue.fromString(
  '01900000-0000-7000-8000-000000000002',
);
final outletId = UuidValue.fromString('01900000-0000-7000-8000-000000000010');
final otherOutletId = UuidValue.fromString(
  '01900000-0000-7000-8000-000000000019',
);
final deviceA = UuidValue.fromString('01900000-0000-7000-8000-0000000000a1');
final deviceB = UuidValue.fromString('01900000-0000-7000-8000-0000000000b1');
final deviceC = UuidValue.fromString('01900000-0000-7000-8000-0000000000c1');

const tokenA = 'token-a-0123456789';
const tokenB = 'token-b-0123456789';
const tokenC = 'token-c-0123456789';
const revokedToken = 'token-revoked-0123';
const seedHlc = '0000000000000-0000-seed';

final now = DateTime.now().toUtc();

String hlcOf(UuidValue device, int i) =>
    Hlc(now.millisecondsSinceEpoch, i, device.uuid).toString();

Future<void> seed(Session session) async {
  for (final (id, name) in [(tenantId, 'Toko Maju'), (otherTenantId, 'Lain')]) {
    await Tenant.db.insertRow(
      session,
      Tenant(id: id, name: name, hlc: seedHlc),
    );
  }
  for (final (id, tenant) in [
    (outletId, tenantId),
    (otherOutletId, otherTenantId),
  ]) {
    await Outlet.db.insertRow(
      session,
      Outlet(
        id: id,
        tenantId: tenant,
        code: 'PST',
        name: 'Pusat',
        hlc: seedHlc,
      ),
    );
  }
  for (final (id, tenant, outlet, code, token) in [
    (deviceA, tenantId, outletId, 'K01', tokenA),
    (deviceB, tenantId, outletId, 'K02', tokenB),
    (deviceC, otherTenantId, otherOutletId, 'K01', tokenC),
  ]) {
    await Device.db.insertRow(
      session,
      Device(
        id: id,
        tenantId: tenant,
        outletId: outlet,
        code: code,
        name: code,
        platform: DevicePlatform.linux,
        hlc: seedHlc,
      ),
    );
    await DeviceCredential.db.insertRow(
      session,
      DeviceCredential(
        tenantId: tenant,
        deviceId: id,
        tokenHash: secretHash(token),
      ),
    );
  }
  await DeviceCredential.db.insertRow(
    session,
    DeviceCredential(
      tenantId: tenantId,
      deviceId: deviceA,
      tokenHash: secretHash(revokedToken),
      revokedAt: now,
    ),
  );
}

SyncPushEntry staff(UuidValue tenant, UuidValue device, int i) {
  final hlc = hlcOf(device, i);
  final row = StaffMember(
    id: UuidValue.fromString(
      '01900000-0000-7000-8${device.uuid.substring(34, 36)}0-${i.toString().padLeft(12, '0')}',
    ),
    tenantId: tenant,
    name: 'Staf $i',
    hlc: hlc,
    originDeviceId: device,
  );
  return SyncPushEntry(
    tableName: 'staff_members',
    rowId: row.id,
    op: SyncOp.upsert,
    payloadJson: jsonEncode(row.toJson()),
    hlc: hlc,
  );
}

void main() {
  withServerpod('Endpoint sync (F2-01)', (sessionBuilder, endpoints) {
    setUp(() => seed(sessionBuilder.build()));

    test('token salah atau dicabut: SyncAuthException', () async {
      for (final token in ['salah', revokedToken]) {
        await expectLater(
          endpoints.sync.pull(sessionBuilder, token, 0),
          throwsA(isA<SyncAuthException>()),
          reason: token,
        );
        await expectLater(
          endpoints.sync.push(sessionBuilder, token, []),
          throwsA(isA<SyncAuthException>()),
        );
      }
    });

    test('push lalu pull dari perangkat lain, urut seq', () async {
      final entries = [
        for (var i = 1; i <= 3; i++) staff(tenantId, deviceA, i),
      ];
      final reply = await endpoints.sync.push(sessionBuilder, tokenA, entries);
      expect(
        reply.results.map((r) => r.kind),
        everyElement(SyncResultKind.applied),
      );
      expect(reply.results.map((r) => r.rowId), entries.map((e) => e.rowId));

      final page = await endpoints.sync.pull(sessionBuilder, tokenB, 0);
      expect(page.changes.map((c) => c.rowId), entries.map((e) => e.rowId));
      final seqs = page.changes.map((c) => c.seq).toList();
      expect(seqs, orderedEquals([...seqs]..sort()));
      expect(page.nextSeq, seqs.last);
      expect(page.hasMore, isFalse);

      final again = await endpoints.sync.pull(
        sessionBuilder,
        tokenB,
        page.nextSeq,
      );
      expect(again.changes, isEmpty);
      expect(again.nextSeq, page.nextSeq);
    });

    test('pull melewati perubahan perangkat sendiri dan tenant lain', () async {
      await endpoints.sync.push(sessionBuilder, tokenA, [
        staff(tenantId, deviceA, 1),
      ]);
      await endpoints.sync.push(sessionBuilder, tokenC, [
        staff(otherTenantId, deviceC, 1),
      ]);
      final own = await endpoints.sync.pull(sessionBuilder, tokenA, 0);
      expect(own.changes, isEmpty);
      expect(own.nextSeq, greaterThan(0));
      final b = await endpoints.sync.pull(sessionBuilder, tokenB, 0);
      expect(b.changes, hasLength(1));
      final c = await endpoints.sync.pull(sessionBuilder, tokenC, 0);
      expect(c.changes, isEmpty);
      // Sisa dihitung per tenant, bukan seluruh log server.
      expect(b.remaining, 0);
      final empty = await endpoints.sync.pull(sessionBuilder, tokenB, b.nextSeq);
      expect(empty.changes, isEmpty);
      expect(empty.remaining, 0);
    });

    test('1.001 perubahan: halaman 1.000 lalu 1', () async {
      for (var start = 1; start <= 1001; start += 500) {
        final end = start + 499 > 1001 ? 1001 : start + 499;
        await endpoints.sync.push(sessionBuilder, tokenA, [
          for (var i = start; i <= end; i++) staff(tenantId, deviceA, i),
        ]);
      }
      final first = await endpoints.sync.pull(sessionBuilder, tokenB, 0);
      expect(first.changes, hasLength(1000));
      expect(first.hasMore, isTrue);
      // Sisa perubahan tenant setelah halaman ini (F2-02, progres pull).
      expect(first.remaining, 1);
      final second = await endpoints.sync.pull(
        sessionBuilder,
        tokenB,
        first.nextSeq,
      );
      expect(second.changes, hasLength(1));
      expect(second.hasMore, isFalse);
      expect(second.remaining, 0);
    }, timeout: const Timeout(Duration(minutes: 3)));

    test('batch lebih dari 500 entri ditolak', () async {
      await expectLater(
        endpoints.sync.push(sessionBuilder, tokenA, [
          for (var i = 1; i <= 501; i++) staff(tenantId, deviceA, i),
        ]),
        throwsA(isA<SyncRequestException>()),
      );
    });

    test(
      'status tanpa token: tenant belum dikenal, versi selalu ada',
      () async {
        final status = await endpoints.sync.status(sessionBuilder, null);
        expect(status.tenantKnown, isFalse);
        expect(status.serverVersion, serverVersion);
        expect(status.protocolVersion, syncProtocolVersion);
        expect(syncProtocolVersion, 1);
        final known = await endpoints.sync.status(sessionBuilder, tokenA);
        expect(known.tenantKnown, isTrue);
        final unknown = await endpoints.sync.status(sessionBuilder, 'salah');
        expect(unknown.tenantKnown, isFalse);
      },
    );
  });
}
