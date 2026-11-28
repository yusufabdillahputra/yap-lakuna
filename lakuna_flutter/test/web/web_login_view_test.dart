import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_flutter/data/services/web_session_store.dart';
import 'package:lakuna_flutter/ui/web/web_login_view.dart';

import '../testing/fake_web_join_repository.dart';

void main() {
  late FakeWebJoinRepository repo;
  late MemoryWebSessionStore sessions;
  late int joined;

  setUp(() {
    repo = FakeWebJoinRepository();
    sessions = MemoryWebSessionStore(delete: (_) async {});
    joined = 0;
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    bool showServerField = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      WebLoginApp(
        join: repo,
        login: repo,
        sessions: sessions,
        onJoined: () async => joined++,
        initialServer: 'https://toko.contoh.id',
        showServerField: showServerField,
        locale: const Locale('id'),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String key) => find.descendant(
    of: find.byKey(ValueKey(key)),
    matching: find.byType(EditableText),
  );

  bool enabled(WidgetTester tester, String key) =>
      tester.widget<FButton>(find.byKey(ValueKey(key))).onPress != null;

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(field('web-login-email'), 'ani@contoh.id');
    await tester.enterText(field('web-login-password'), 'rahasia123');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('web-login-submit')));
    await tester.pumpAndSettle();
  }

  for (final (width, wide) in [(1280.0, true), (600.0, true), (390.0, false)]) {
    testWidgets('lebar $width: ${wide ? 'dua kolom' : 'menumpuk'}', (
      tester,
    ) async {
      await pump(tester, size: Size(width, 800));
      final hero = tester.getRect(find.byKey(const ValueKey('web-login-hero')));
      final form = tester.getRect(
        find.byKey(const ValueKey('web-login-form')),
      );
      if (wide) {
        expect(hero.right, lessThanOrEqualTo(form.left));
        expect(hero.height, 800);
      } else {
        expect(hero.bottom, lessThanOrEqualTo(form.top));
        expect(hero.width, width);
      }
      expect(find.text('Pantau semua cabang dari mana saja.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Masuk nonaktif sampai email dan kata sandi terisi; alamat '
      'server hanya di build lepas', (tester) async {
    await pump(tester);
    expect(find.byKey(const ValueKey('web-login-server')), findsNothing);
    expect(enabled(tester, 'web-login-submit'), isFalse);
    await tester.enterText(field('web-login-email'), 'ani@contoh.id');
    await tester.pump();
    expect(enabled(tester, 'web-login-submit'), isFalse);
    await tester.enterText(field('web-login-password'), 'rahasia123');
    await tester.pump();
    expect(enabled(tester, 'web-login-submit'), isTrue);

    await pump(tester, showServerField: true);
    expect(find.byKey(const ValueKey('web-login-server')), findsOneWidget);
  });

  testWidgets('pilihan bahasa mengganti teks', (tester) async {
    await pump(tester);
    expect(find.text('Lupa kata sandi?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('web-login-lang-en')));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Watch every branch from anywhere.'), findsOneWidget);
  });

  testWidgets('alur penuh: kata sandi → kode (dua toko) → menyiapkan data → '
      'sesi aktif', (tester) async {
    final second = UuidValue.fromString('01900000-0000-7000-8000-000000000002');
    repo.tenants = [
      ...repo.tenants,
      WebTenant(tenantId: second, name: 'Toko Cabang Dua'),
    ];
    await pump(tester);
    await signIn(tester);
    expect(find.byKey(const ValueKey('web-login-code-step')), findsOneWidget);
    expect(find.byKey(const ValueKey('web-login-tenant')), findsOneWidget);
    expect(enabled(tester, 'web-login-code-submit'), isFalse);
    await tester.enterText(field('web-login-code'), '123456');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('web-login-code-submit')));
    await tester.pumpAndSettle();
    expect(repo.openCalls.single.remember, isTrue);
    expect(repo.pullCalls, ['lakuna-web.sqlite']);
    expect(sessions.activeDatabase, 'lakuna-web.sqlite');
    expect(joined, 1);
  });

  testWidgets('terkunci: pesan dengan jam buka', (tester) async {
    repo.openError = WebAccessException(
      failure: WebAccessFailure.locked,
      lockedUntil: DateTime(2026, 11, 28, 9, 15),
    );
    await pump(tester);
    await signIn(tester);
    await tester.enterText(field('web-login-code'), '000000');
    await tester.pump();
    repo.openGate = Completer<void>();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump();
    repo.openGate!.complete();
    await tester.pumpAndSettle();
    expect(
      find.text('Terlalu banyak kode salah. Coba lagi pukul 09.15.'),
      findsOneWidget,
    );
    expect(sessions.pendingDatabase, isNull);
    // Kode berikutnya bisa langsung diketik tanpa klik isian lagi.
    expect(
      tester.widget<EditableText>(field('web-login-code')).focusNode.hasFocus,
      isTrue,
    );
  });

  testWidgets('verifikasi 2 langkah belum aktif: petunjuk di langkah 1', (
    tester,
  ) async {
    repo.signInError = WebAccessException(
      failure: WebAccessFailure.totpNotEnabled,
    );
    await pump(tester);
    await signIn(tester);
    expect(find.byKey(const ValueKey('web-login-error')), findsOneWidget);
    expect(
      find.textContaining('Aktifkan dari kartu Versi hosting'),
      findsOneWidget,
    );
  });

  testWidgets('Pakai kode pasang lalu kembali ke login', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('web-login-pairing')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-join')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('web-join-use-login')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-login')), findsOneWidget);
  });

  testWidgets('Lupa kata sandi: kode email + kata sandi baru dua kali', (
    tester,
  ) async {
    await pump(tester, size: const Size(390, 800));
    await tester.enterText(field('web-login-email'), 'ani@contoh.id');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('web-login-forgot')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('web-reset-send')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-reset-code')), findsOneWidget);
    await tester.enterText(field('web-reset-code'), '12345678');
    await tester.enterText(field('web-reset-password'), 'barurahasia');
    await tester.enterText(field('web-reset-password-again'), 'barurahasib');
    await tester.pump();
    expect(find.text('Kata sandi tidak sama.'), findsOneWidget);
    expect(enabled(tester, 'web-reset-save'), isFalse);
    await tester.enterText(field('web-reset-password-again'), 'barurahasia');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('web-reset-save')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-reset-done')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('web-reset-close')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-login')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pull pertama tertunda dari tab sebelumnya dilanjutkan', (
    tester,
  ) async {
    await sessions.setPendingDatabase('lakuna-web.sqlite');
    await pump(tester);
    expect(repo.pullCalls, ['lakuna-web.sqlite']);
    expect(joined, 1);
  });
}
