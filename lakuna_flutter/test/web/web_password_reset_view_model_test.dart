import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/ui/web/web_password_reset_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show EmailAccountPasswordResetException;

import '../testing/fake_web_join_repository.dart';

void main() {
  late FakeWebJoinRepository repo;

  setUp(() => repo = FakeWebJoinRepository());

  WebPasswordResetViewModel model() => WebPasswordResetViewModel(
    repository: repo,
    serverUrl: 'https://toko.contoh.id',
    email: 'ani@contoh.id',
  );

  test('kirim kode lalu kata sandi baru diketik dua kali', () async {
    final vm = model();
    expect(vm.step, WebResetStep.email);
    expect(vm.canSend, isTrue);
    await vm.send.execute();
    expect(vm.step, WebResetStep.code);
    vm
      ..setCode('12345678')
      ..setPassword('barurahasia')
      ..setPasswordAgain('barurahasia');
    expect(vm.passwordError, isNull);
    expect(vm.canSave, isTrue);
    await vm.save.execute();
    expect(vm.step, WebResetStep.done);
    expect(repo.resetCalls, [
      'start:ani@contoh.id',
      'verify:12345678',
      'finish:token-reset:barurahasia',
    ]);
  });

  test('kata sandi pendek atau tidak sama: Simpan nonaktif', () async {
    final vm = model();
    await vm.send.execute();
    vm
      ..setCode('12345678')
      ..setPassword('pendek');
    expect(vm.passwordError, WebResetPasswordError.tooShort);
    expect(vm.canSave, isFalse);
    vm
      ..setPassword('barurahasia')
      ..setPasswordAgain('barurahasib');
    expect(vm.passwordError, WebResetPasswordError.mismatch);
    expect(vm.canSave, isFalse);
  });

  test('kode salah: tetap di langkah kode dengan galat', () async {
    final vm = model();
    await vm.send.execute();
    vm
      ..setCode('99999999')
      ..setPassword('barurahasia')
      ..setPasswordAgain('barurahasia');
    await vm.save.execute();
    expect(vm.step, WebResetStep.code);
    expect(
      (vm.save.result as Error<void>).error,
      isA<EmailAccountPasswordResetException>(),
    );
    expect(repo.resetCalls.last, 'verify:99999999');
  });

  test(
    'kata sandi baru ditolak server: ulang tanpa verifikasi kode lagi',
    () async {
      repo.finishError = Exception('policy');
      final vm = model();
      await vm.send.execute();
      vm
        ..setCode('12345678')
        ..setPassword('barurahasia')
        ..setPasswordAgain('barurahasia');
      await vm.save.execute();
      expect(vm.step, WebResetStep.code);
      await vm.save.execute();
      expect(vm.step, WebResetStep.done);
      expect(
        repo.resetCalls.where((c) => c.startsWith('verify')),
        hasLength(1),
      );
    },
  );

  test('email kosong: Kirim kode nonaktif', () {
    final vm = model()..setEmail(' ');
    expect(vm.canSend, isFalse);
  });
}
