import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';
import 'web_access_fixtures.dart';

Matcher failsWith(WebAccessFailure f) => throwsA(
  isA<WebAccessException>().having((e) => e.failure, 'failure', f),
);

void main() {
  withServerpod('Verifikasi 2 langkah pemilik (F2-02 aturan 12–14)', (
    sessionBuilder,
    endpoints,
  ) {
    final owner = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(ownerId, {}),
    );
    final stranger = sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(strangerId, {}),
    );

    setUp(() async {
      final session = sessionBuilder.build();
      setTotpKey(session, 'kunci-tes-totp');
      await seedOwner(session);
    });

    Future<List<String>> enable() async {
      final e = await endpoints.totp.begin(owner);
      return endpoints.totp.confirm(owner, codeFor(e.secretBase32));
    }

    test('tanpa login ditolak', () async {
      await expectLater(
        endpoints.totp.status(sessionBuilder),
        throwsA(isA<ServerpodUnauthenticatedException>()),
      );
    });

    test('akun yang bukan pemilik tenant ditolak', () async {
      await expectLater(
        endpoints.totp.begin(stranger),
        failsWith(WebAccessFailure.notOwner),
      );
    });

    test('begin → confirm kode benar → aktif dan 8 kode cadangan', () async {
      expect(await endpoints.totp.status(owner), isFalse);
      final e = await endpoints.totp.begin(owner);
      expect(e.secretBase32, matches(RegExp(r'^[A-Z2-7]{32}$')));
      expect(
        e.otpauthUri,
        startsWith('otpauth://totp/Lakuna:sari%40contoh.id?secret='),
      );
      expect(await endpoints.totp.status(owner), isFalse);
      final codes = await endpoints.totp.confirm(
        owner,
        codeFor(e.secretBase32),
      );
      expect(codes, hasLength(8));
      expect(await endpoints.totp.status(owner), isTrue);
      final stored = await OwnerBackupCode.db.find(sessionBuilder.build());
      expect(stored, hasLength(8));
      expect(stored.map((c) => c.codeHash), isNot(contains(codes.first)));
      final row = (await OwnerTotp.db.find(sessionBuilder.build())).single;
      expect(row.secretEncrypted, isNot(contains(e.secretBase32)));
    });

    test('confirm kode salah → totpInvalid, belum aktif', () async {
      final e = await endpoints.totp.begin(owner);
      await expectLater(
        endpoints.totp.confirm(owner, wrongCode(e.secretBase32)),
        failsWith(WebAccessFailure.totpInvalid),
      );
      expect(await endpoints.totp.status(owner), isFalse);
    });

    test('begin ulang sebelum dikonfirmasi menimpa rahasia lama', () async {
      final a = await endpoints.totp.begin(owner);
      final b = await endpoints.totp.begin(owner);
      expect(b.secretBase32, isNot(a.secretBase32));
      expect(await OwnerTotp.db.count(sessionBuilder.build()), 1);
      await expectLater(
        endpoints.totp.confirm(owner, codeFor(a.secretBase32)),
        failsWith(WebAccessFailure.totpInvalid),
      );
    });

    test('begin saat sudah aktif ditolak', () async {
      await enable();
      await expectLater(
        endpoints.totp.begin(owner),
        failsWith(WebAccessFailure.totpAlreadyEnabled),
      );
    });

    test('kunci enkripsi kosong → totpKeyMissing', () async {
      setTotpKey(sessionBuilder.build(), '');
      await expectLater(
        endpoints.totp.begin(owner),
        failsWith(WebAccessFailure.totpKeyMissing),
      );
    });

    test('disable dengan kode cadangan menghapus TOTP dan kode', () async {
      final codes = await enable();
      await endpoints.totp.disable(owner, codes[3].toLowerCase());
      expect(await endpoints.totp.status(owner), isFalse);
      expect(await OwnerTotp.db.count(sessionBuilder.build()), 0);
      expect(await OwnerBackupCode.db.count(sessionBuilder.build()), 0);
    });

    test('disable dengan kode salah ditolak', () async {
      await enable();
      await expectLater(
        endpoints.totp.disable(owner, 'ABCD-EFGH'),
        failsWith(WebAccessFailure.totpInvalid),
      );
      expect(await endpoints.totp.status(owner), isTrue);
    });
  });
}
