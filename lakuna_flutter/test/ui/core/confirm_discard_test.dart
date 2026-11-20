import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/core/confirm_discard.dart';
import 'package:lakuna_flutter/ui/core/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

void main() {
  group('DiscardChangesScope.canDiscardAll (F1-02d)', () {
    final navigator = GlobalKey<NavigatorState>();

    Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        locale: const Locale('id'),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...FLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) =>
            FTheme(data: lakunaLightTheme(touch: false), child: child!),
        home: const SizedBox(),
      ),
    );

    /// Membuka "dialog form" [name] di atas yang sudah ada.
    Future<void> open(
      WidgetTester tester,
      String name, {
      bool dirty = true,
      bool busy = false,
    }) async {
      navigator.currentState!.push(
        PageRouteBuilder<void>(
          opaque: false,
          pageBuilder: (context, _, _) => DiscardChangesScope(
            dirty: dirty,
            busy: busy,
            body: 'Isian $name hilang.',
            dialogKey: '$name-discard',
            child: SizedBox(key: ValueKey('$name-form')),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<bool> ask(WidgetTester tester, Future<bool> answer) async {
      await tester.pumpAndSettle();
      return answer;
    }

    Future<void> tap(WidgetTester tester, String key) async {
      await tester.tap(_key(key));
      await tester.pumpAndSettle();
    }

    testWidgets('tanpa dialog atau dialog tanpa perubahan → boleh', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(await DiscardChangesScope.canDiscardAll(), isTrue);
      await open(tester, 'a', dirty: false);
      final answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      expect(_key('a-discard'), findsNothing);
      expect(await answer, isTrue);
    });

    testWidgets('dialog berubah bertanya: Batal → tidak, Buang → boleh', (
      tester,
    ) async {
      await pumpApp(tester);
      await open(tester, 'a');
      var answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      expect(_key('a-discard'), findsOneWidget);
      expect(find.text('Isian a hilang.'), findsOneWidget);
      await tap(tester, 'a-discard-cancel');
      expect(await answer, isFalse);
      expect(_key('a-form'), findsOneWidget);

      answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      await tap(tester, 'a-discard-confirm');
      expect(await answer, isTrue);
      // Dialog form tidak ditutup: aplikasi yang akan ditutup, dan bila
      // halaman di bawahnya batal, isiannya tetap ada.
      expect(_key('a-form'), findsOneWidget);
    });

    testWidgets('dialog bertumpuk ditanya dari atas, berhenti di Batal', (
      tester,
    ) async {
      await pumpApp(tester);
      await open(tester, 'a');
      await open(tester, 'b');
      final answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      expect(_key('b-discard'), findsOneWidget);
      expect(_key('a-discard'), findsNothing);
      await tap(tester, 'b-discard-confirm');
      expect(_key('a-discard'), findsOneWidget);
      await tap(tester, 'a-discard-cancel');
      expect(await ask(tester, answer), isFalse);
    });

    testWidgets('dialog teratas tanpa perubahan dilewati', (tester) async {
      await pumpApp(tester);
      await open(tester, 'a');
      await open(tester, 'b', dirty: false);
      final answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      expect(_key('b-discard'), findsNothing);
      await tap(tester, 'a-discard-confirm');
      expect(await answer, isTrue);
    });

    testWidgets('dialog yang sedang menyimpan menolak tanpa bertanya', (
      tester,
    ) async {
      // Form menutup dirinya dengan `pop` setelah simpan; pertanyaan di
      // atasnya akan ikut tertutup.
      await pumpApp(tester);
      await open(tester, 'a');
      await open(tester, 'b', busy: true);
      final answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      expect(_key('b-discard'), findsNothing);
      expect(_key('a-discard'), findsNothing);
      expect(await answer, isFalse);
    });

    testWidgets('dialog yang sedang ditutup tidak ditanya lagi', (
      tester,
    ) async {
      await pumpApp(tester);
      await open(tester, 'a');
      navigator.currentState!.maybePop();
      await tester.pumpAndSettle();
      await tester.tap(_key('a-discard-confirm'));
      // Pertanyaan tertutup, form masih beranimasi keluar.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(_key('a-form'), findsOneWidget);
      bool? answer;
      unawaited(DiscardChangesScope.canDiscardAll().then((v) => answer = v));
      await tester.pump();
      // Langsung terjawab tanpa pertanyaan baru.
      expect(answer, isTrue);
      expect(_key('a-form'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(_key('a-form'), findsNothing);
      expect(_key('a-discard'), findsNothing);
    });

    testWidgets('pertanyaan Esc yang terbuka dipakai; Buang menutup dialog '
        'form', (tester) async {
      await pumpApp(tester);
      await open(tester, 'a');
      navigator.currentState!.maybePop();
      await tester.pumpAndSettle();
      expect(_key('a-discard'), findsOneWidget);
      final answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      expect(_key('a-discard'), findsOneWidget);
      await tap(tester, 'a-discard-confirm');
      expect(await answer, isTrue);
      expect(_key('a-form'), findsNothing);
      expect(_key('a-discard'), findsNothing);
    });

    testWidgets('dialog yang sudah ditutup tidak ditanya', (tester) async {
      await pumpApp(tester);
      await open(tester, 'a');
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(_key('a-form'), findsNothing);
      final answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      expect(_key('a-discard'), findsNothing);
      expect(await answer, isTrue);
    });
  });
}
