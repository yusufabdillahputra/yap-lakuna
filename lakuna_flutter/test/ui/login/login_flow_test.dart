import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_session_repository.dart';

const _tablet = Size(1194, 834);
const _mobile = Size(400, 800);

Future<void> _typePin(WidgetTester tester, String pin) async {
  for (final c in pin.split('')) {
    await tester.tap(find.byKey(ValueKey('pin-key-$c')));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}

void main() {
  final owner = sampleStaff(name: 'Yusuf');
  final sari = sampleStaff(name: 'Sari Dewi', role: 'cashier');
  final budi = sampleStaff(name: 'Budi', role: 'waiter', hasPin: false);

  FakeSessionRepository loggedOut() =>
      FakeSessionRepository(staff: [owner, sari, budi]);

  testWidgets('tanpa sesi, aplikasi membuka layar login', (tester) async {
    await pumpLakuna(tester, size: _tablet, session: loggedOut());
    expect(find.text('Siapa yang bertugas?'), findsOneWidget);
    expect(
      find.text('Warung Contoh · Cabang Pusat · Perangkat K01'),
      findsOneWidget,
    );
    expect(find.text('Sari Dewi'), findsOneWidget);
    expect(find.text('Kasir'), findsOneWidget);
    expect(find.text('Belum punya PIN'), findsOneWidget);
    expect(find.text('Pilih nama Anda untuk memasukkan PIN.'), findsOneWidget);
    expect(find.byKey(const ValueKey('sidebar')), findsNothing);
  });

  testWidgets('satu staf langsung terpilih; PIN benar membuka Beranda', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      size: _tablet,
      session: FakeSessionRepository(staff: [owner]),
    );
    expect(find.text('Masukkan PIN Yusuf'), findsOneWidget);
    await _typePin(tester, '123456');
    expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
    expect(find.byKey(const ValueKey('switch-cashier')), findsOneWidget);
    expect(find.text('Ganti kasir'), findsOneWidget);
  });

  testWidgets('PIN salah menampilkan sisa percobaan, ke-5 mengunci', (
    tester,
  ) async {
    await pumpLakuna(tester, size: _tablet, session: loggedOut());
    await tester.tap(find.text('Sari Dewi'));
    await tester.pump();
    expect(find.text('Masukkan PIN Sari Dewi'), findsOneWidget);

    await _typePin(tester, '000000');
    expect(find.text('PIN salah. Sisa 4 percobaan.'), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await _typePin(tester, '000000');
    }
    expect(
      find.text('Terlalu banyak percobaan. Coba lagi dalam 60 detik.'),
      findsOneWidget,
    );
    // Keypad nonaktif selama dikunci.
    await tester.tap(find.byKey(const ValueKey('pin-key-1')));
    await tester.pumpAndSettle();
    expect(find.text('Siapa yang bertugas?'), findsOneWidget);
    expect(
      find.text('Terlalu banyak percobaan. Coba lagi dalam 60 detik.'),
      findsOneWidget,
    );
  });

  testWidgets('keyboard fisik: angka, hapus, lalu masuk', (tester) async {
    final session = FakeSessionRepository(staff: [owner]);
    await pumpLakuna(tester, size: _tablet, session: session);
    for (final key in [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit9,
      LogicalKeyboardKey.backspace,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
    ]) {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(session.pinAttempts, ['123456']);
    expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
  });

  testWidgets('kasir hanya melihat menu sesuai izinnya; ganti kasir', (
    tester,
  ) async {
    final session = loggedOut();
    await pumpLakuna(tester, size: const Size(1280, 800), session: session);
    await tester.tap(find.text('Sari Dewi'));
    await tester.pump();
    await _typePin(tester, '123456');

    expect(find.byKey(const ValueKey('nav-cashier')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-history')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-settings')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-guide')), findsOneWidget);
    for (final hidden in ['products', 'stock', 'purchases', 'users']) {
      expect(find.byKey(ValueKey('nav-$hidden')), findsNothing, reason: hidden);
    }
    expect(find.text('Sari Dewi'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('switch-cashier')));
    await tester.pumpAndSettle();
    expect(session.current, isNull);
    expect(find.text('Siapa yang bertugas?'), findsOneWidget);
  });

  testWidgets('rute modul tanpa izin dialihkan ke Beranda', (tester) async {
    final session = FakeSessionRepository(staff: [sari])..current = sari;
    await pumpLakuna(
      tester,
      size: _tablet,
      session: session,
      initialLocation: Routes.module('users'),
    );
    expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
  });

  testWidgets('pemilik masuk dengan email dan kata sandi', (tester) async {
    final session = loggedOut();
    await pumpLakuna(tester, size: _tablet, session: session);
    await tester.tap(find.byKey(const ValueKey('login-owner-link')));
    await tester.pumpAndSettle();
    expect(find.text('Masuk sebagai pemilik'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('login-email')),
        matching: find.byType(EditableText),
      ),
      'yusuf@contoh.id',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('login-password')),
        matching: find.byType(EditableText),
      ),
      'salah',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('login-password')),
        matching: find.byType(EditableText),
      ),
      'rahasia123',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('login-submit')));
    await tester.pumpAndSettle();
    expect(session.current, owner);
    expect(find.byKey(const ValueKey('home-greeting')), findsOneWidget);
  });

  testWidgets('mobile: pilih staf, PIN, lalu navigasi bawah sesuai izin', (
    tester,
  ) async {
    await pumpLakuna(tester, size: _mobile, session: loggedOut());
    expect(find.byKey(const ValueKey('pin-card')), findsNothing);
    await tester.tap(find.text('Sari Dewi'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('pin-card')), findsOneWidget);
    expect(find.text('Siapa yang bertugas?'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('login-back-to-staff')));
    await tester.pumpAndSettle();
    expect(find.text('Siapa yang bertugas?'), findsOneWidget);

    await tester.tap(find.text('Sari Dewi'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('pin-key-0')));
    await _typePin(tester, '123456');
    expect(find.byKey(const ValueKey('nav-cashier')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav-products')), findsNothing);
    expect(find.byKey(const ValueKey('switch-cashier')), findsOneWidget);
  });

  testWidgets('tablet sempit tetap muat dengan staf bertugas', (tester) async {
    await pumpLakuna(tester, size: const Size(600, 800));
    expect(find.byKey(const ValueKey('switch-cashier')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
