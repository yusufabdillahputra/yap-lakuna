import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/ui/login/login_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_session_repository.dart';

void main() {
  late DateTime now;
  late FakeSessionRepository session;
  late LoginViewModel vm;
  final owner = sampleStaff(name: 'Yusuf');
  final sari = sampleStaff(name: 'Sari', role: 'cashier');
  final noPin = sampleStaff(name: 'Budi', role: 'waiter', hasPin: false);

  setUp(() {
    now = DateTime.utc(2026, 11, 3, 8);
    session = FakeSessionRepository(
      staff: [owner, sari, noPin],
      guard: PinGuard(clock: () => now),
    );
    vm = LoginViewModel(session: session, clock: () => now);
  });

  tearDown(() => vm.dispose());

  Future<void> typePin(String pin) async {
    for (final c in pin.split('')) {
      vm.addDigit(int.parse(c));
    }
    // Digit ke-6 menjalankan submitPin; tunggu hasilnya.
    while (vm.submitPin.running) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  test('memuat staf; satu staf langsung terpilih', () async {
    await vm.load.execute();
    expect(vm.staff.map((s) => s.name), ['Yusuf', 'Sari', 'Budi']);
    expect(vm.selected, isNull);

    final single = LoginViewModel(
      session: FakeSessionRepository(staff: [owner]),
    );
    await single.load.execute();
    expect(single.selected, owner);
    single.dispose();
  });

  test('staf tanpa PIN tidak bisa dipilih', () async {
    await vm.load.execute();
    vm.select(noPin);
    expect(vm.selected, isNull);
  });

  test('enam digit langsung diverifikasi', () async {
    await vm.load.execute();
    vm.select(sari);
    vm.addDigit(1);
    vm.addDigit(2);
    expect(vm.pin, '12');
    vm.backspace();
    expect(vm.pin, '1');
    vm.clearPin();
    expect(vm.pin, isEmpty);

    await typePin('123456');
    expect(vm.submitPin.result, isA<Ok<StaffProfile>>());
    expect(session.current, sari);
    expect(session.pinAttempts, ['123456']);
  });

  test('PIN salah mengosongkan titik dan menyimpan galat', () async {
    await vm.load.execute();
    vm.select(sari);
    await typePin('000000');
    expect(vm.pin, isEmpty);
    final error = (vm.submitPin.result as Error).error;
    expect((error as WrongPin).remainingAttempts, 4);

    // Mengetik lagi menghapus galat lama.
    vm.addDigit(1);
    expect(vm.submitPin.result, isNull);
  });

  test('dikunci: keypad nonaktif dengan hitung mundur', () async {
    await vm.load.execute();
    vm.select(sari);
    for (var i = 0; i < 5; i++) {
      await typePin('000000');
    }
    expect(vm.lockSecondsLeft, 60);
    vm.addDigit(1);
    expect(vm.pin, isEmpty);

    now = now.add(const Duration(seconds: 42));
    expect(vm.lockSecondsLeft, 18);
    now = now.add(const Duration(seconds: 18));
    expect(vm.lockSecondsLeft, isNull);
    vm.addDigit(1);
    expect(vm.pin, '1');
  });

  test('memilih staf lain mengatur ulang PIN dan galat', () async {
    await vm.load.execute();
    vm.select(sari);
    await typePin('000000');
    vm.select(owner);
    expect(vm.pin, isEmpty);
    expect(vm.submitPin.result, isNull);
    expect(vm.lockSecondsLeft, isNull);
  });

  test('login pemilik dengan email dan kata sandi', () async {
    await vm.load.execute();
    vm.showPasswordForm();
    expect(vm.passwordMode, isTrue);
    expect(vm.canSubmitPassword, isFalse);
    vm.setEmail('yusuf@contoh.id');
    vm.setPassword('salah');
    expect(vm.canSubmitPassword, isTrue);
    await vm.submitPassword.execute();
    expect((vm.submitPassword.result as Error).error, isA<WrongCredentials>());

    vm.setPassword('rahasia123');
    expect(vm.submitPassword.result, isNull);
    await vm.submitPassword.execute();
    expect(session.current, owner);

    vm.showPinForm();
    expect(vm.passwordMode, isFalse);
  });

  test('staf tidak tersedia: daftar dimuat ulang', () async {
    await vm.load.execute();
    vm.select(sari);
    session.staff = [owner];
    await typePin('123456');
    expect(
      (vm.submitPin.result as Error).error,
      isA<StaffUnavailable>(),
    );
    expect(vm.staff, [owner]);
    expect(vm.selected, owner);
  });
}
