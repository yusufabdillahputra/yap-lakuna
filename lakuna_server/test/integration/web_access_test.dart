import 'package:lakuna_domain/lakuna_domain.dart' show secretHash;
import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';
import 'web_access_fixtures.dart';

Matcher failsWith(WebAccessFailure f) => throwsA(
  isA<WebAccessException>().having((e) => e.failure, 'failure', f),
);

void main() {
  withServerpod('Login web pemilik (F2-02 aturan 11–14)', (
    sessionBuilder,
    endpoints,
  ) {
    final owner = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(ownerId, {}),
    );
    final stranger = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(strangerId, {}),
    );
    late String secret;
    late List<String> backupCodes;

    setUp(() async {
      final session = sessionBuilder.build();
      setTotpKey(session, 'kunci-tes-totp');
      await seedOwner(session);
    });

    Future<void> enable() async {
      final e = await endpoints.totp.begin(owner, ownerDeviceToken);
      secret = e.secretBase32;
      // Konfirmasi memakai langkah sebelumnya agar langkah sekarang dan
      // berikutnya masih bisa dipakai login.
      backupCodes = await endpoints.totp.confirm(
        owner,
        ownerDeviceToken,
        codeFor(secret, offset: -1),
      );
    }

    test('akun tanpa tenant → noTenant', () async {
      await expectLater(
        endpoints.webAccess.tenants(stranger),
        failsWith(WebAccessFailure.noTenant),
      );
    });

    test('tanpa TOTP aktif → totpNotEnabled', () async {
      await expectLater(
        endpoints.webAccess.tenants(owner),
        failsWith(WebAccessFailure.totpNotEnabled),
      );
      await expectLater(
        endpoints.webAccess.open(owner, '123456', tenantId, true),
        failsWith(WebAccessFailure.totpNotEnabled),
      );
    });

    test('tenants: toko milik akun', () async {
      await enable();
      final list = await endpoints.webAccess.tenants(owner);
      expect(list.map((t) => (t.tenantId, t.name)), [(tenantId, 'Toko Maju')]);
    });

    test('kode benar: perangkat web W01 di cabang tertua, token bisa pull, '
        'berlaku 30 hari', () async {
      await enable();
      final before = DateTime.now().toUtc();
      final r = await endpoints.webAccess.open(
        owner,
        codeFor(secret),
        tenantId,
        true,
      );
      expect(r.tenantId, tenantId);
      expect(r.deviceCode, 'W01');
      expect(r.outletId, outletId);
      expect(
        r.expiresAt.difference(before).inDays,
        inInclusiveRange(29, 30),
      );
      final device = (await Device.db.findById(
        sessionBuilder.build(),
        r.deviceId,
      ))!;
      expect(device.platform, DevicePlatform.web);
      expect(device.outletId, outletId);
      final page = await endpoints.sync.pull(sessionBuilder, r.deviceToken, 0);
      expect(page.changes.map((c) => c.rowId), contains(r.deviceId));
    });

    test('tanpa "ingat saya": token berlaku 12 jam', () async {
      await enable();
      final before = DateTime.now().toUtc();
      final r = await endpoints.webAccess.open(
        owner,
        codeFor(secret),
        tenantId,
        false,
      );
      expect(
        r.expiresAt.difference(before).inMinutes,
        inInclusiveRange(
          12 * 60 - 1,
          12 * 60,
        ),
      );
    });

    test('kode yang sama dipakai lagi → totpInvalid', () async {
      await enable();
      final code = codeFor(secret, offset: 1);
      await endpoints.webAccess.open(owner, code, tenantId, true);
      await expectLater(
        endpoints.webAccess.open(owner, code, tenantId, true),
        failsWith(WebAccessFailure.totpInvalid),
      );
    });

    test('5 kode salah → locked 15 menit, kode benar pun ditolak; setelah '
        'kunci lewat bisa lagi', () async {
      await enable();
      final wrong = wrongCode(secret);
      for (var i = 0; i < 4; i++) {
        await expectLater(
          endpoints.webAccess.open(owner, wrong, tenantId, true),
          failsWith(WebAccessFailure.totpInvalid),
        );
      }
      final before = DateTime.now().toUtc();
      await expectLater(
        endpoints.webAccess.open(owner, wrong, tenantId, true),
        throwsA(
          isA<WebAccessException>()
              .having((e) => e.failure, 'failure', WebAccessFailure.locked)
              .having(
                (e) => e.lockedUntil!.difference(before).inMinutes,
                'menit',
                inInclusiveRange(14, 15),
              ),
        ),
      );
      await expectLater(
        endpoints.webAccess.open(owner, codeFor(secret), tenantId, true),
        failsWith(WebAccessFailure.locked),
      );
      // Waktu berlalu: kunci habis.
      final session = sessionBuilder.build();
      final row = (await OwnerTotp.db.find(session)).single;
      await OwnerTotp.db.updateRow(
        session,
        row.copyWith(
          lockedUntil: DateTime.now().toUtc().subtract(
            const Duration(seconds: 1),
          ),
        ),
      );
      final r = await endpoints.webAccess.open(
        owner,
        codeFor(secret),
        tenantId,
        true,
      );
      expect(r.deviceCode, 'W01');
    });

    test('kode cadangan sekali pakai', () async {
      await enable();
      final r = await endpoints.webAccess.open(
        owner,
        backupCodes.first,
        tenantId,
        true,
      );
      expect(r.deviceCode, 'W01');
      await expectLater(
        endpoints.webAccess.open(owner, backupCodes.first, tenantId, true),
        failsWith(WebAccessFailure.totpInvalid),
      );
      final r2 = await endpoints.webAccess.open(
        owner,
        backupCodes[1],
        tenantId,
        true,
      );
      expect(r2.deviceCode, 'W02');
    });

    test('tenant bukan milik akun → noTenant', () async {
      await enable();
      await expectLater(
        endpoints.webAccess.open(owner, codeFor(secret), otherTenantId, true),
        failsWith(WebAccessFailure.noTenant),
      );
    });

    test('twoFactorEnabled dengan token perangkat: status TOTP pemilik '
        'tenant', () async {
      final session = sessionBuilder.build();
      await DeviceCredential.db.insertRow(
        session,
        DeviceCredential(
          tenantId: tenantId,
          deviceId: UuidValue.fromString(
            '01900000-0000-7000-8000-0000000000a1',
          ),
          tokenHash: secretHash('token-kasir-012345'),
        ),
      );
      expect(
        await endpoints.webAccess.twoFactorEnabled(
          sessionBuilder,
          'token-kasir-012345',
        ),
        isFalse,
      );
      await enable();
      expect(
        await endpoints.webAccess.twoFactorEnabled(
          sessionBuilder,
          'token-kasir-012345',
        ),
        isTrue,
      );
      await expectLater(
        endpoints.webAccess.twoFactorEnabled(sessionBuilder, 'salah'),
        throwsA(isA<SyncAuthException>()),
      );
    });

    test('logout mencabut token web itu saja', () async {
      await enable();
      final a = await endpoints.webAccess.open(
        owner,
        codeFor(secret),
        tenantId,
        true,
      );
      final b = await endpoints.webAccess.open(
        owner,
        backupCodes.first,
        tenantId,
        true,
      );
      await endpoints.webAccess.logout(sessionBuilder, a.deviceToken);
      await expectLater(
        endpoints.sync.pull(sessionBuilder, a.deviceToken, 0),
        throwsA(isA<SyncAuthException>()),
      );
      await endpoints.sync.pull(sessionBuilder, b.deviceToken, 0);
    });
  });

  withServerpod(
    'Login web paralel (Fokus review 3)',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      final owner = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(ownerId, {}),
      );

      test('dua open paralel dengan kode sama: tepat satu berhasil', () async {
        final session = sessionBuilder.build();
        setTotpKey(session, 'kunci-tes-totp');
        await seedOwner(session);
        final e = await endpoints.totp.begin(owner, ownerDeviceToken);
        await endpoints.totp.confirm(
          owner,
          ownerDeviceToken,
          codeFor(e.secretBase32, offset: -1),
        );
        final code = codeFor(e.secretBase32, offset: 1);
        final results = await Future.wait([
          for (var i = 0; i < 2; i++)
            endpoints.webAccess
                .open(owner, code, tenantId, true)
                .then<Object>((r) => r, onError: (Object e) => e),
        ]);
        expect(results.whereType<WebAccessResult>(), hasLength(1));
        expect(
          results.whereType<WebAccessException>().map((e) => e.failure),
          [WebAccessFailure.totpInvalid],
        );
      });
    },
  );
}
