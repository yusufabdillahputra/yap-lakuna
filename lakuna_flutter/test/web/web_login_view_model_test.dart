import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_flutter/data/services/web_session_store.dart';
import 'package:lakuna_flutter/ui/web/web_login_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show EmailAccountLoginException, EmailAccountLoginExceptionReason;

import '../testing/fake_web_join_repository.dart';

void main() {
  late FakeWebJoinRepository repo;
  late MemoryWebSessionStore sessions;

  setUp(() {
    repo = FakeWebJoinRepository();
    sessions = MemoryWebSessionStore(delete: (_) async {});
  });

  WebLoginViewModel model() => WebLoginViewModel(
    repository: repo,
    sessions: sessions,
    initialServer: 'https://toko.contoh.id',
  );

  WebLoginViewModel filled() => model()
    ..setEmail('ani@contoh.id')
    ..setPassword('rahasia123');

  Exception? errorOf(Result<void>? r) => switch (r) {
    Error(:final error) => error,
    _ => null,
  };

  test('Masuk nonaktif sampai alamat, email, dan kata sandi terisi', () {
    final vm = model();
    expect(vm.step, WebLoginStep.credentials);
    expect(vm.remember, isTrue);
    expect(vm.canSubmitCredentials, isFalse);
    vm.setEmail('ani@contoh.id');
    expect(vm.canSubmitCredentials, isFalse);
    vm.setPassword('rahasia123');
    expect(vm.canSubmitCredentials, isTrue);
    vm.setServer('  ');
    expect(vm.canSubmitCredentials, isFalse);
  });

  test('kata sandi salah: galat di langkah 1', () async {
    repo.signInError = EmailAccountLoginException(
      reason: EmailAccountLoginExceptionReason.invalidCredentials,
    );
    final vm = filled();
    await vm.submitCredentials.execute();
    expect(vm.step, WebLoginStep.credentials);
    expect(
      errorOf(vm.submitCredentials.result),
      isA<EmailAccountLoginException>(),
    );
    expect(repo.signInCalls.single, (
      'https://toko.contoh.id',
      'ani@contoh.id',
      'rahasia123',
    ));
  });

  test('verifikasi 2 langkah belum aktif: tetap di langkah 1', () async {
    repo.signInError = WebAccessException(
      failure: WebAccessFailure.totpNotEnabled,
    );
    final vm = filled();
    await vm.submitCredentials.execute();
    expect(vm.step, WebLoginStep.credentials);
    expect(
      errorOf(vm.submitCredentials.result),
      isA<WebAccessException>().having(
        (e) => e.failure,
        'failure',
        WebAccessFailure.totpNotEnabled,
      ),
    );
  });

  test('dua toko: langkah 2 memuat pilihan, toko terpilih dikirim', () async {
    final second = UuidValue.fromString('01900000-0000-7000-8000-000000000002');
    repo.tenants = [
      ...repo.tenants,
      WebTenant(tenantId: second, name: 'Toko Cabang Dua'),
    ];
    final vm = filled();
    await vm.submitCredentials.execute();
    expect(vm.step, WebLoginStep.secondFactor);
    expect(vm.tenants.map((t) => t.name), ['Toko Bu Ani', 'Toko Cabang Dua']);
    expect(vm.tenantId, repo.tenants.first.tenantId);
    vm.selectTenant(second);
    vm.setCode('123 456');
    expect(vm.canSubmitCode, isTrue);
    await vm.submitCode.execute();
    expect(repo.openCalls.single.tenantId, second);
    expect(repo.openCalls.single.code, '123456');
  });

  test('kode: 6 angka atau kode cadangan', () async {
    final vm = filled();
    await vm.submitCredentials.execute();
    for (final (code, ok) in [
      ('12345', false),
      ('123456', true),
      ('abcd-efgh', true),
      ('ABCDEFGH', true),
      ('abc', false),
    ]) {
      vm.setCode(code);
      expect(vm.canSubmitCode, ok, reason: code);
    }
  });

  test('terkunci: galat dengan jam buka, tetap di langkah 2', () async {
    final until = DateTime.utc(2026, 11, 28, 9, 15);
    repo.openError = WebAccessException(
      failure: WebAccessFailure.locked,
      lockedUntil: until,
    );
    final vm = filled();
    await vm.submitCredentials.execute();
    vm.setCode('000000');
    await vm.submitCode.execute();
    expect(vm.step, WebLoginStep.secondFactor);
    expect(
      errorOf(vm.submitCode.result),
      isA<WebAccessException>().having((e) => e.lockedUntil, 'until', until),
    );
    expect(sessions.pendingDatabase, isNull);
  });

  test('sukses: menyiapkan data dengan Ingat perangkat yang dikirim', () async {
    final vm = filled()..setRemember(false);
    await vm.submitCredentials.execute();
    vm.setCode('123456');
    await vm.submitCode.execute();
    expect(vm.step, WebLoginStep.preparing);
    expect(repo.openCalls.single.remember, isFalse);
    expect(sessions.pendingDatabase, 'lakuna-web.sqlite');
    expect(sessions.activeDatabase, isNull);
  });

  test('Kembali dari langkah 2 mengosongkan kode', () async {
    final vm = filled();
    await vm.submitCredentials.execute();
    vm.setCode('123456');
    vm.back();
    expect(vm.step, WebLoginStep.credentials);
    expect(vm.code, isEmpty);
    expect(vm.password, 'rahasia123');
  });

  test('pull pertama tertunda dari tab sebelumnya: langsung menyiapkan', () {
    sessions.setPendingDatabase('lakuna-lama.sqlite');
    expect(model().step, WebLoginStep.preparing);
  });
}
