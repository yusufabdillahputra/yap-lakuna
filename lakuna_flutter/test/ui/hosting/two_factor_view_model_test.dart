import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/ui/hosting/two_factor_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_hosting_repository.dart';
import '../../testing/fake_session_repository.dart';

void main() {
  late FakeHostingRepository hosting;
  late FakeSessionRepository session;

  setUp(() {
    hosting = FakeHostingRepository(state: hostingState(active: true));
    session = FakeSessionRepository()..current = sampleStaff();
  });

  TwoFactorViewModel vm({TwoFactorMode mode = TwoFactorMode.enable}) =>
      TwoFactorViewModel(hosting: hosting, session: session, mode: mode);

  Future<void> throughAccount(TwoFactorViewModel m) async {
    m.setPin('123456');
    await m.submitPin.execute();
    m
      ..setEmail('sari@contoh.id')
      ..setPassword('rahasia123');
    await m.submitAccount.execute();
  }

  test('aktifkan: PIN → akun → QR + kode → 8 kode cadangan', () async {
    final m = vm();
    expect(m.step, TwoFactorStep.pin);
    expect(m.canSubmitPin, isFalse);
    await throughAccount(m);
    expect(m.step, TwoFactorStep.enroll);
    expect(m.enrollment!.otpauthUri, startsWith('otpauth://totp/Lakuna:'));
    expect(m.secretGroups, 'JBSW Y3DP EHPK 3PXP JBSW Y3DP EHPK 3PXP');
    m.setCode('123 456');
    await m.submitCode.execute();
    expect(m.step, TwoFactorStep.backupCodes);
    expect(m.backupCodes, hasLength(8));
    expect(hosting.calls, contains('confirmTwoFactor:123456'));
    m.finish();
    expect(m.step, TwoFactorStep.done);
    expect(hosting.calls.last, 'endTwoFactor');
  });

  test('PIN salah: tetap di langkah PIN dengan galat', () async {
    final m = vm()..setPin('000000');
    await m.submitPin.execute();
    expect(m.step, TwoFactorStep.pin);
    expect(m.submitPin.result, isA<Error<void>>());
    expect((m.submitPin.result! as Error).error, isA<WrongPin>());
  });

  test('kata sandi salah: galat di langkah akun', () async {
    final m = vm()..setPin('123456');
    await m.submitPin.execute();
    m
      ..setEmail('sari@contoh.id')
      ..setPassword('salah');
    await m.submitAccount.execute();
    expect(m.step, TwoFactorStep.account);
    expect(m.submitAccount.result, isA<Error<void>>());
  });

  test('kode salah: tetap di langkah kode dengan pesan', () async {
    final m = vm();
    await throughAccount(m);
    m.setCode('999999');
    await m.submitCode.execute();
    expect(m.step, TwoFactorStep.enroll);
    final error = (m.submitCode.result! as Error).error;
    expect(
      error,
      isA<WebAccessException>().having(
        (e) => e.failure,
        'failure',
        WebAccessFailure.totpInvalid,
      ),
    );
  });

  test('kode harus 6 angka atau kode cadangan sebelum bisa dikirim', () async {
    final m = vm();
    await throughAccount(m);
    m.setCode('12345');
    expect(m.canSubmitCode, isFalse);
    m.setCode('123456');
    expect(m.canSubmitCode, isTrue);
  });

  test('nonaktifkan butuh kode, lalu selesai', () async {
    hosting.twoFactorOn = true;
    final m = vm(mode: TwoFactorMode.disable);
    await throughAccount(m);
    expect(m.step, TwoFactorStep.disable);
    m.setCode('aaaa bbbb');
    await m.submitDisable.execute();
    expect(hosting.calls, contains('disableTwoFactor:AAAA-BBBB'));
    expect(m.step, TwoFactorStep.done);
    expect(hosting.twoFactorOn, isFalse);
  });

  test('atur ulang: nonaktifkan lalu langsung QR baru', () async {
    hosting.twoFactorOn = true;
    final m = vm(mode: TwoFactorMode.reset);
    await throughAccount(m);
    expect(m.step, TwoFactorStep.disable);
    m.setCode('123456');
    await m.submitDisable.execute();
    expect(m.step, TwoFactorStep.enroll);
    expect(m.enrollment, isNotNull);
  });

  test('aktifkan padahal di server sudah aktif: langsung selesai', () async {
    hosting.twoFactorOn = true;
    final m = vm();
    await throughAccount(m);
    expect(m.step, TwoFactorStep.done);
    expect(m.alreadyEnabled, isTrue);
  });

  test('dispose menutup sesi akun', () {
    vm().dispose();
    expect(hosting.calls, contains('endTwoFactor'));
  });

  test('status kartu dimuat dari server', () async {
    hosting.twoFactorOn = true;
    final status = TwoFactorStatusViewModel(hosting: hosting);
    await status.load.execute();
    expect(status.enabled, isTrue);
    hosting.twoFactorStatusError = const SyncOfflineException();
    await status.load.execute();
    expect(status.enabled, isNull);
    expect(status.offline, isTrue);
  });
}
