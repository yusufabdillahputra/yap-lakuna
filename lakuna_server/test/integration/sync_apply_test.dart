import 'dart:convert';

import 'package:lakuna_domain/lakuna_domain.dart' show Hlc;
import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:lakuna_server/src/sync/apply_change.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

final serverNow = DateTime.utc(2026, 11, 28, 5);
final t0 = serverNow.millisecondsSinceEpoch - 60000;

final tenantId = UuidValue.fromString('01900000-0000-7000-8000-000000000001');
final otherTenantId = UuidValue.fromString(
  '01900000-0000-7000-8000-000000000002',
);
final outletId = UuidValue.fromString('01900000-0000-7000-8000-000000000010');
final deviceA = UuidValue.fromString('01900000-0000-7000-8000-0000000000a1');
final deviceB = UuidValue.fromString('01900000-0000-7000-8000-0000000000b1');
final staffId = UuidValue.fromString('01900000-0000-7000-8000-000000000020');

/// HLC perangkat [node] pada [t0] + [dt] ms.
String h(int dt, {int counter = 0, UuidValue? node}) =>
    Hlc(t0 + dt, counter, (node ?? deviceA).uuid).toString();

const seedHlc = '0000000000000-0000-seed';

DeviceAuth authA() => DeviceAuth(tenantId: tenantId, deviceId: deviceA);
DeviceAuth authB() => DeviceAuth(tenantId: tenantId, deviceId: deviceB);

SyncPushEntry entry(String table, TableRow<UuidValue?> row, String hlc) =>
    SyncPushEntry(
      tableName: table,
      rowId: row.id!,
      op: SyncOp.upsert,
      payloadJson: jsonEncode(row.toJson()),
      hlc: hlc,
    );

Future<void> seed(Session session) async {
  await Tenant.db.insertRow(
    session,
    Tenant(id: tenantId, name: 'Toko Maju', hlc: seedHlc),
  );
  await Tenant.db.insertRow(
    session,
    Tenant(id: otherTenantId, name: 'Toko Lain', hlc: seedHlc),
  );
  await Outlet.db.insertRow(
    session,
    Outlet(
      id: outletId,
      tenantId: tenantId,
      code: 'PST',
      name: 'Pusat',
      hlc: seedHlc,
    ),
  );
  for (final (id, code) in [(deviceA, 'K01'), (deviceB, 'K02')]) {
    await Device.db.insertRow(
      session,
      Device(
        id: id,
        tenantId: tenantId,
        outletId: outletId,
        code: code,
        name: code,
        platform: DevicePlatform.linux,
        hlc: seedHlc,
      ),
    );
  }
  await StaffMember.db.insertRow(
    session,
    StaffMember(id: staffId, tenantId: tenantId, name: 'Ani', hlc: seedHlc),
  );
}

Outlet outlet({
  UuidValue? id,
  String code = 'CB1',
  required String hlc,
  UuidValue? tenant,
  UuidValue? origin,
}) => Outlet(
  id: id ?? UuidValue.fromString('01900000-0000-7000-8000-000000000011'),
  tenantId: tenant ?? tenantId,
  code: code,
  name: 'Cabang $code',
  hlc: hlc,
  originDeviceId: origin ?? deviceA,
);

final saleId = UuidValue.fromString('01900000-0000-7000-8000-000000000030');

Sale sale({
  required String hlc,
  SaleStatus status = SaleStatus.completed,
  int total = 50000,
  UuidValue? origin,
  DateTime? voidedAt,
  String? voidReason,
}) => Sale(
  id: saleId,
  tenantId: tenantId,
  outletId: outletId,
  deviceId: deviceA,
  staffId: staffId,
  number: 'PST-K01-261128-0001',
  status: status,
  subtotal: total,
  tierDiscount: 0,
  total: total,
  paidAmount: total,
  changeAmount: 0,
  itemCount: 1,
  soldAt: DateTime.utc(2026, 11, 28, 4),
  voidedAt: voidedAt,
  voidReason: voidReason,
  createdAt: DateTime.utc(2026, 11, 28, 4),
  updatedAt: DateTime.utc(2026, 11, 28, 4),
  hlc: hlc,
  originDeviceId: origin ?? deviceA,
);

Future<SyncPushResult> apply(
  Session session,
  DeviceAuth auth,
  SyncPushEntry e,
) => session.db.transaction(
  (tx) => applyPushEntry(session, tx, auth, e, serverNow: serverNow),
);

void main() {
  withServerpod('Penerap push sync (F2-01)', (sessionBuilder, endpoints) {
    late Session session;
    setUp(() async {
      session = sessionBuilder.build();
      await seed(session);
    });

    test('baris baru diterapkan dan masuk log perubahan', () async {
      final row = outlet(hlc: h(1));
      final r = await apply(session, authA(), entry('outlets', row, h(1)));
      expect(r.kind, SyncResultKind.applied);
      expect(r.rowId, row.id);
      final stored = await Outlet.db.findById(session, row.id);
      expect(stored!.code, 'CB1');
      expect(stored.hlc, h(1));
      final changes = await SyncChange.db.find(session);
      expect(changes, hasLength(1));
      expect(changes.single.entity, 'outlets');
      expect(changes.single.originDeviceId, deviceA);
      expect(changes.single.tenantId, tenantId);
    });

    test('kirim ulang (row_id, hlc) yang sama tanpa efek', () async {
      final e = entry('outlets', outlet(hlc: h(1)), h(1));
      await apply(session, authA(), e);
      final again = await apply(session, authA(), e);
      expect(again.kind, SyncResultKind.applied);
      expect(await SyncChange.db.count(session), 1);
    });

    test(
      'HLC lebih lama dari baris server: stale dengan baris server',
      () async {
        await apply(
          session,
          authB(),
          entry(
            'outlets',
            outlet(
              hlc: h(5, node: deviceB),
              origin: deviceB,
            ),
            h(5, node: deviceB),
          ),
        );
        final old = outlet(hlc: h(1)).copyWith(name: 'Nama lama');
        final r = await apply(session, authA(), entry('outlets', old, h(1)));
        expect(r.kind, SyncResultKind.stale);
        final server = jsonDecode(r.serverPayloadJson!) as Map<String, dynamic>;
        expect(server['hlc'], h(5, node: deviceB));
        expect(server['name'], 'Cabang CB1');
        expect((await Outlet.db.findById(session, old.id))!.name, 'Cabang CB1');
        expect(await SyncConflict.db.count(session), 1);
      },
    );

    test('baris tenant lain ditolak (tenant)', () async {
      final r = await apply(
        session,
        authA(),
        entry('outlets', outlet(hlc: h(1), tenant: otherTenantId), h(1)),
      );
      expect(r.kind, SyncResultKind.rejected);
      expect(r.reason, SyncRejectReason.tenant);
    });

    test('perangkat asal bukan perangkat token ditolak (device)', () async {
      final r = await apply(
        session,
        authA(),
        entry('outlets', outlet(hlc: h(1), origin: deviceB), h(1)),
      );
      expect(r.reason, SyncRejectReason.device);
    });

    test('tabel tak dikenal atau tabel perangkat ditolak (table)', () async {
      for (final table in ['nope', 'sync_outbox', 'stock_levels']) {
        final r = await apply(
          session,
          authA(),
          entry('outlets', outlet(hlc: h(1)), h(1)).copyWith(tableName: table),
        );
        expect(r.reason, SyncRejectReason.table, reason: table);
      }
    });

    test(
      'HLC lebih dari 5 menit di depan jam server ditolak (clock)',
      () async {
        final future = Hlc(
          serverNow.millisecondsSinceEpoch + 6 * 60000,
          0,
          deviceA.uuid,
        ).toString();
        final r = await apply(
          session,
          authA(),
          entry('outlets', outlet(hlc: future), future),
        );
        expect(r.reason, SyncRejectReason.clock);
      },
    );

    test(
      'isi nota final diubah: ditolak (finalDocument) dan dicatat',
      () async {
        await apply(session, authA(), entry('sales', sale(hlc: h(1)), h(1)));
        final r = await apply(
          session,
          authA(),
          entry('sales', sale(hlc: h(2), total: 1000), h(2)),
        );
        expect(r.kind, SyncResultKind.rejected);
        expect(r.reason, SyncRejectReason.finalDocument);
        expect((await Sale.db.findById(session, saleId))!.total, 50000);
        final conflicts = await SyncConflict.db.find(session);
        expect(conflicts, hasLength(1));
        expect(conflicts.single.reason, 'final');
      },
    );

    test(
      'void lalu retur sebagian (HLC lebih baru): merged, tetap voided',
      () async {
        await apply(session, authA(), entry('sales', sale(hlc: h(1)), h(1)));
        final voidedAt = DateTime.utc(2026, 11, 28, 4, 30);
        await apply(
          session,
          authB(),
          entry(
            'sales',
            sale(
              hlc: h(2, node: deviceB),
              status: SaleStatus.voided,
              voidedAt: voidedAt,
              voidReason: 'salah input',
              origin: deviceB,
            ),
            h(2, node: deviceB),
          ),
        );
        final r = await apply(
          session,
          authA(),
          entry(
            'sales',
            sale(hlc: h(3), status: SaleStatus.partiallyReturned),
            h(3),
          ),
        );
        expect(r.kind, SyncResultKind.merged);
        final stored = (await Sale.db.findById(session, saleId))!;
        expect(stored.status, SaleStatus.voided);
        expect(stored.voidReason, 'salah input');
        final payload =
            jsonDecode(r.serverPayloadJson!) as Map<String, dynamic>;
        expect(payload['status'], 'voided');
        expect(Hlc.parse(stored.hlc) > Hlc.parse(h(3)), isTrue);
        expect(payload['hlc'], stored.hlc);
      },
    );

    test(
      'urutan dibalik (void HLC lebih lama tiba belakangan): voided',
      () async {
        await apply(session, authA(), entry('sales', sale(hlc: h(1)), h(1)));
        await apply(
          session,
          authA(),
          entry(
            'sales',
            sale(hlc: h(3), status: SaleStatus.partiallyReturned),
            h(3),
          ),
        );
        final r = await apply(
          session,
          authB(),
          entry(
            'sales',
            sale(
              hlc: h(2, node: deviceB),
              status: SaleStatus.voided,
              voidedAt: DateTime.utc(2026, 11, 28, 4, 30),
              voidReason: 'salah input',
              origin: deviceB,
            ),
            h(2, node: deviceB),
          ),
        );
        expect(r.kind, SyncResultKind.merged);
        final stored = (await Sale.db.findById(session, saleId))!;
        expect(stored.status, SaleStatus.voided);
        expect(stored.voidReason, 'salah input');
        expect(Hlc.parse(stored.hlc) > Hlc.parse(h(3)), isTrue);
        final last = (await SyncChange.db.find(
          session,
          orderBy: (c) => c.id,
        )).last;
        expect(last.hlc, stored.hlc);
        expect(last.originDeviceId, isNull);
      },
    );

    test('settings kunci sama, ID beda: merged, satu baris tersisa', () async {
      Setting setting(UuidValue id, String value, String hlc, UuidValue dev) =>
          Setting(
            id: id,
            tenantId: tenantId,
            scopeKey: 'tenant',
            key: 'receipt.footer',
            valueJson: value,
            hlc: hlc,
            originDeviceId: dev,
          );
      final idA = UuidValue.fromString('01900000-0000-7000-8000-000000000041');
      final idB = UuidValue.fromString('01900000-0000-7000-8000-000000000042');
      await apply(
        session,
        authA(),
        entry('settings', setting(idA, '"A"', h(1), deviceA), h(1)),
      );
      final r = await apply(
        session,
        authB(),
        entry(
          'settings',
          setting(idB, '"B"', h(2, node: deviceB), deviceB),
          h(2, node: deviceB),
        ),
      );
      expect(r.kind, SyncResultKind.merged);
      final rows = await Setting.db.find(session);
      expect(rows, hasLength(1));
      expect(rows.single.id, idA);
      expect(rows.single.valueJson, '"B"');
      final payload = jsonDecode(r.serverPayloadJson!) as Map<String, dynamic>;
      expect(payload['id'], idA.uuid);
    });

    test('induk ditolak: anak dependency, entri lain tetap applied', () async {
      final clash = outlet(code: 'PST', hlc: h(1));
      final location = StockLocation(
        id: UuidValue.fromString('01900000-0000-7000-8000-000000000051'),
        tenantId: tenantId,
        outletId: clash.id,
        name: 'Gudang',
        hlc: h(2),
        originDeviceId: deviceA,
      );
      final fine = outlet(
        id: UuidValue.fromString('01900000-0000-7000-8000-000000000012'),
        code: 'CB2',
        hlc: h(3),
      );
      final results = await session.db.transaction((tx) async {
        final out = <SyncPushResult>[];
        for (final e in [
          entry('outlets', clash, h(1)),
          entry('stock_locations', location, h(2)),
          entry('outlets', fine, h(3)),
        ]) {
          out.add(
            await applyPushEntry(session, tx, authA(), e, serverNow: serverNow),
          );
        }
        return out;
      });
      expect(results[0].reason, SyncRejectReason.unique);
      expect(results[1].reason, SyncRejectReason.dependency);
      expect(results[2].kind, SyncResultKind.applied);
      expect(await Outlet.db.findById(session, fine.id), isNotNull);
    });

    test('payload tanpa kolom baru yang boleh kosong: kolom null', () async {
      final payload = sale(hlc: h(1)).toJson()..remove('discountBase');
      final r = await apply(
        session,
        authA(),
        SyncPushEntry(
          tableName: 'sales',
          rowId: saleId,
          op: SyncOp.upsert,
          payloadJson: jsonEncode(payload),
          hlc: h(1),
        ),
      );
      expect(r.kind, SyncResultKind.applied);
      expect((await Sale.db.findById(session, saleId))!.discountBase, isNull);
    });

    test(
      'payload tanpa kolom wajib berdefault: nilai default dipakai',
      () async {
        final payload = sale(hlc: h(1)).toJson()..remove('roundingStep');
        final r = await apply(
          session,
          authA(),
          SyncPushEntry(
            tableName: 'sales',
            rowId: saleId,
            op: SyncOp.upsert,
            payloadJson: jsonEncode(payload),
            hlc: h(1),
          ),
        );
        expect(r.kind, SyncResultKind.applied);
        expect((await Sale.db.findById(session, saleId))!.roundingStep, 0);
      },
    );
  });
}
