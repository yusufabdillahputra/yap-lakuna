import 'dart:convert';

import 'package:lakuna_domain/lakuna_domain.dart' show secretHash;
import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:lakuna_server/src/sync/activation.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

final tenantId = UuidValue.fromString('01900000-0000-7000-8000-000000000001');
final deviceA = UuidValue.fromString('01900000-0000-7000-8000-0000000000a1');
final outletId = UuidValue.fromString('01900000-0000-7000-8000-000000000010');
const ownerId = '01900000-0000-7000-8000-00000000ff01';

Matcher failsWith(ActivationFailure reason) => throwsA(
  isA<ActivationException>().having((e) => e.reason, 'reason', reason),
);

void main() {
  withServerpod('Aktivasi hosting (F2-01)', (sessionBuilder, endpoints) {
    final owner = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(ownerId, {}),
    );

    Future<String> code({int days = 30, DateTime? now}) => createActivationCode(
      sessionBuilder.build(),
      note: 'Toko Maju',
      days: days,
      now: now,
    );

    Future<ActivationResult> activate(String c, {UuidValue? device}) =>
        endpoints.activation.activateFirstDevice(
          owner,
          c,
          tenantId,
          device ?? deviceA,
          'Toko Maju',
          'K01',
        );

    test('aktivasi pertama: tenant hosted, pemilik, token perangkat', () async {
      final c = await code();
      expect(c, hasLength(8));
      final r = await activate(c);
      expect(r.tenantId, tenantId);
      expect(r.deviceId, deviceA);
      expect(r.deviceCode, 'K01');
      expect(r.deviceToken, hasLength(43));
      final session = sessionBuilder.build();
      final tenant = (await Tenant.db.findById(session, tenantId))!;
      expect(tenant.plan, TenantPlan.hosted);
      final owners = await TenantOwner.db.find(session);
      expect(owners.single.authUserId.uuid, ownerId);
      final cred = (await DeviceCredential.db.find(session)).single;
      expect(cred.tokenHash, secretHash(r.deviceToken));
      expect(cred.deviceId, deviceA);
      final status = await endpoints.sync.status(sessionBuilder, r.deviceToken);
      expect(status.tenantKnown, isTrue);
    });

    test('kode diketik dengan huruf kecil dan strip tetap diterima', () async {
      final c = await code();
      final typed = '${c.substring(0, 4)}-${c.substring(4)}'.toLowerCase();
      expect((await activate(typed)).tenantId, tenantId);
    });

    test('tanpa login akun pemilik ditolak', () async {
      final c = await code();
      await expectLater(
        endpoints.activation.activateFirstDevice(
          sessionBuilder,
          c,
          tenantId,
          deviceA,
          'Toko Maju',
          'K01',
        ),
        failsWith(ActivationFailure.notOwner),
      );
    });

    test('kode aktivasi tidak dikenal ditolak', () async {
      await expectLater(
        activate('ZZZZZZZZ'),
        failsWith(ActivationFailure.codeInvalid),
      );
    });

    test('kode aktivasi dipakai dua kali: galat kedua', () async {
      final c = await code();
      await activate(c);
      await expectLater(
        endpoints.activation.activateFirstDevice(
          owner,
          c,
          UuidValue.fromString('01900000-0000-7000-8000-000000000002'),
          UuidValue.fromString('01900000-0000-7000-8000-0000000000a2'),
          'Toko Lain',
          'K01',
        ),
        failsWith(ActivationFailure.codeUsed),
      );
    });

    test('kode aktivasi kedaluwarsa ditolak', () async {
      final c = await code(
        days: 1,
        now: DateTime.now().toUtc().subtract(const Duration(days: 2)),
      );
      await expectLater(activate(c), failsWith(ActivationFailure.codeExpired));
    });

    test('tenant yang sudah aktif tidak bisa diaktifkan lagi', () async {
      await activate(await code());
      await expectLater(
        activate(
          await code(),
          device: UuidValue.fromString('01900000-0000-7000-8000-0000000000a2'),
        ),
        failsWith(ActivationFailure.tenantActive),
      );
    });

    test('ID perangkat yang sudah punya token: perangkat salinan', () async {
      await activate(await code());
      await expectLater(
        endpoints.activation.activateFirstDevice(
          owner,
          await code(),
          UuidValue.fromString('01900000-0000-7000-8000-000000000002'),
          deviceA,
          'Toko Salinan',
          'K01',
        ),
        failsWith(ActivationFailure.copiedDevice),
      );
    });

    test(
      'salinan backup (tenant dan perangkat sama): perangkat salinan',
      () async {
        await activate(await code());
        await expectLater(
          activate(await code()),
          failsWith(ActivationFailure.copiedDevice),
        );
      },
    );

    group('kode pasang', () {
      late ActivationResult first;
      setUp(() async {
        first = await activate(await code());
        final session = sessionBuilder.build();
        await Outlet.db.insertRow(
          session,
          Outlet(
            id: outletId,
            tenantId: tenantId,
            code: 'PST',
            name: 'Pusat',
            hlc: '0000000000000-0000-seed',
          ),
        );
      });

      Future<ActivationResult> join(String pairing, {String code = 'K02'}) =>
          endpoints.activation.joinWithPairingCode(
            sessionBuilder,
            pairing,
            outletId,
            code,
            'Kasir 2',
            DevicePlatform.android,
          );

      test('pasang membalas ID perangkat baru dan baris devices', () async {
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        expect(pairing, hasLength(8));
        final r = await join(pairing);
        expect(r.tenantId, tenantId);
        expect(r.deviceId, isNot(deviceA));
        expect(r.deviceCode, 'K02');
        final session = sessionBuilder.build();
        final device = (await Device.db.findById(session, r.deviceId))!;
        expect(device.outletId, outletId);
        expect(device.platform, DevicePlatform.android);
        final change = (await SyncChange.db.find(session)).single;
        expect(change.entity, 'devices');
        expect(change.originDeviceId, isNull);
        expect(
          (jsonDecode(change.payloadJson) as Map)['code'],
          'K02',
        );
        final page = await endpoints.sync.pull(
          sessionBuilder,
          first.deviceToken,
          0,
        );
        expect(page.changes.single.rowId, r.deviceId);
      });

      test('pasang memegang kunci tenant seperti push (urutan seq)', () async {
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        final session = sessionBuilder.build();
        Future<int> tenantLocks() async {
          final rows = await session.db.unsafeQuery(
            "SELECT count(*) FROM pg_locks WHERE locktype = 'advisory' "
            'AND pid = pg_backend_pid() '
            'AND objid = (hashtext(@t)::bigint & 4294967295)::oid',
            parameters: QueryParameters.named({'t': tenantId.uuid}),
          );
          return rows.first.first! as int;
        }

        expect(await tenantLocks(), 0);
        await join(pairing);
        expect(await tenantLocks(), 1);
      });

      test('cabang untuk kode pasang: hanya cabang aktif tenant', () async {
        final session = sessionBuilder.build();
        await Outlet.db.insertRow(
          session,
          Outlet(
            id: UuidValue.fromString('01900000-0000-7000-8000-000000000011'),
            tenantId: tenantId,
            code: 'CB2',
            name: 'Cabang Dua',
            hlc: '0000000000000-0000-seed',
          ),
        );
        await Outlet.db.insertRow(
          session,
          Outlet(
            id: UuidValue.fromString('01900000-0000-7000-8000-000000000012'),
            tenantId: tenantId,
            code: 'LMA',
            name: 'Cabang Lama',
            hlc: '0000000000000-0000-seed',
            deletedAt: DateTime.utc(2026),
          ),
        );
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        final outlets = await endpoints.activation.pairingOutlets(
          sessionBuilder,
          pairing.toLowerCase(),
        );
        expect([for (final o in outlets) o.code], ['CB2', 'PST']);
        expect(outlets.last.id, outletId);
        expect(outlets.last.name, 'Pusat');
      });

      test('cabang untuk kode pasang yang sudah dipakai ditolak', () async {
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        await join(pairing);
        await expectLater(
          endpoints.activation.pairingOutlets(sessionBuilder, pairing),
          failsWith(ActivationFailure.codeUsed),
        );
        await expectLater(
          endpoints.activation.pairingOutlets(sessionBuilder, 'ZZZZZZZZ'),
          failsWith(ActivationFailure.codeInvalid),
        );
      });

      test('kode pasang hanya sekali pakai', () async {
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        await join(pairing);
        await expectLater(
          join(pairing, code: 'K03'),
          failsWith(ActivationFailure.codeUsed),
        );
      });

      test('kode pasang habis setelah 15 menit', () async {
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        final session = sessionBuilder.build();
        final row = (await PairingCode.db.find(session)).single;
        expect(
          row.expiresAt.difference(row.createdAt),
          const Duration(minutes: 15),
        );
        await PairingCode.db.updateRow(
          session,
          row.copyWith(
            expiresAt: DateTime.now().toUtc().subtract(
              const Duration(seconds: 1),
            ),
          ),
        );
        await expectLater(
          join(pairing),
          failsWith(ActivationFailure.codeExpired),
        );
      });

      test('kode perangkat sudah dipakai di cabang itu ditolak', () async {
        final session = sessionBuilder.build();
        await Device.db.insertRow(
          session,
          Device(
            tenantId: tenantId,
            outletId: outletId,
            code: 'K02',
            name: 'Kasir 2 lama',
            platform: DevicePlatform.linux,
            hlc: '0000000000000-0000-seed',
          ),
        );
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        await expectLater(
          join(pairing),
          failsWith(ActivationFailure.deviceCodeTaken),
        );
      });

      test('cabang bukan milik tenant ditolak', () async {
        final pairing = await endpoints.activation.createPairingCode(
          sessionBuilder,
          first.deviceToken,
        );
        await expectLater(
          endpoints.activation.joinWithPairingCode(
            sessionBuilder,
            pairing,
            UuidValue.fromString('01900000-0000-7000-8000-000000000099'),
            'K02',
            'Kasir 2',
            DevicePlatform.android,
          ),
          failsWith(ActivationFailure.outletUnknown),
        );
      });

      test('kode pasang tanpa token perangkat sah ditolak', () async {
        await expectLater(
          endpoints.activation.createPairingCode(sessionBuilder, 'salah'),
          throwsA(isA<SyncAuthException>()),
        );
      });
    });
  });
}
