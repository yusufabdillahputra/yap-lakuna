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
      Future<bool> Function(BuildContext context)? onSave,
    }) async {
      navigator.currentState!.push(
        PageRouteBuilder<void>(
          opaque: false,
          pageBuilder: (context, _, _) => DiscardChangesScope(
            dirty: dirty,
            busy: busy,
            onSave: onSave == null ? null : () => onSave(context),
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

    for (final saved in [true, false]) {
      testWidgets('onSave: tombol Simpan, jawaban = hasil simpan ($saved) '
          '(F1-13g)', (tester) async {
        await pumpApp(tester);
        var calls = 0;
        await open(
          tester,
          'a',
          onSave: (context) async {
            calls++;
            // Form menutup dirinya sendiri setelah tersimpan.
            if (saved) Navigator.of(context).pop();
            return saved;
          },
        );
        final answer = DiscardChangesScope.canDiscardAll();
        await tester.pumpAndSettle();
        expect(_key('a-discard-save'), findsOneWidget);
        await tap(tester, 'a-discard-save');
        expect(await answer, saved);
        expect(calls, 1);
        expect(_key('a-form'), saved ? findsNothing : findsOneWidget);
      });

      testWidgets('maybePop lalu Simpan ($saved): hanya rute dialog itu yang '
          'tertutup (F1-13g)', (tester) async {
        await pumpApp(tester);
        await open(tester, 'a');
        await open(
          tester,
          'b',
          onSave: (context) async {
            if (saved) Navigator.of(context).pop();
            return saved;
          },
        );
        unawaited(navigator.currentState!.maybePop());
        await tester.pumpAndSettle();
        await tap(tester, 'b-discard-save');
        expect(_key('b-form'), saved ? findsNothing : findsOneWidget);
        expect(_key('a-form'), findsOneWidget);
        expect(_key('a-discard'), findsNothing);
      });
    }

    testWidgets('Simpan tidak pernah ditutup lingkup: form yang menutup '
        'dirinya dengan hasil (F1-13g)', (tester) async {
      await pumpApp(tester);
      await open(tester, 'a');
      // Simpan berhasil tetapi form belum menutup dirinya: lingkup tidak
      // menutupnya tanpa hasil.
      await open(tester, 'b', onSave: (_) async => true);
      unawaited(navigator.currentState!.maybePop());
      await tester.pumpAndSettle();
      await tap(tester, 'b-discard-save');
      expect(_key('b-form'), findsOneWidget);
      expect(_key('a-form'), findsOneWidget);
      // Pertanyaan berikutnya mulai baru: Buang tetap menutup dialognya.
      unawaited(navigator.currentState!.maybePop());
      await tester.pumpAndSettle();
      await tap(tester, 'b-discard-confirm');
      expect(_key('b-form'), findsNothing);
      expect(_key('a-form'), findsOneWidget);
    });

    testWidgets('Esc lalu tutup jendela lalu Simpan: satu simpan, dua '
        'jawaban sama (F1-13g)', (tester) async {
      await pumpApp(tester);
      var saves = 0;
      await open(
        tester,
        'b',
        onSave: (context) async {
          saves++;
          Navigator.of(context).pop();
          return true;
        },
      );
      unawaited(navigator.currentState!.maybePop());
      await tester.pumpAndSettle();
      final answer = DiscardChangesScope.canDiscardAll();
      await tester.pumpAndSettle();
      // Pertanyaan yang sama dipakai ulang, tidak bertumpuk.
      expect(_key('b-discard'), findsOneWidget);
      await tap(tester, 'b-discard-save');
      expect(await answer, isTrue);
      expect(saves, 1);
      expect(_key('b-form'), findsNothing);
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

  group('confirmDiscardChanges onSave (F1-07r)', () {
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

    testWidgets('tanpa onSave tidak ada tombol Simpan', (tester) async {
      await pumpApp(tester);
      unawaited(
        confirmDiscardChanges(
          navigator.currentContext!,
          body: 'Isian hilang.',
          key: 'x',
        ),
      );
      await tester.pumpAndSettle();
      expect(_key('x'), findsOneWidget);
      expect(_key('x-save'), findsNothing);
    });

    for (final saved in [true, false]) {
      testWidgets('Simpan menutup dialog lalu jawabannya hasil simpan '
          '($saved)', (tester) async {
        await pumpApp(tester);
        var calls = 0;
        bool? answer;
        unawaited(
          confirmDiscardChanges(
            navigator.currentContext!,
            body: 'Isian hilang.',
            key: 'x',
            onSave: () async {
              calls++;
              return saved;
            },
          ).then((v) => answer = v),
        );
        await tester.pumpAndSettle();
        expect(find.text('Simpan'), findsOneWidget);
        await tester.tap(_key('x-save'));
        await tester.pumpAndSettle();
        expect(_key('x'), findsNothing);
        expect(calls, 1);
        expect(answer, saved);
      });
    }

    testWidgets('saveLabel mengganti label Simpan (F1-12i)', (tester) async {
      await pumpApp(tester);
      unawaited(
        confirmDiscardChanges(
          navigator.currentContext!,
          body: 'Isian hilang.',
          key: 'x',
          onSave: () async => true,
          saveLabel: 'Simpan draf',
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: _key('x-save'), matching: find.text('Simpan draf')),
        findsOneWidget,
      );
      expect(find.text('Simpan'), findsNothing);
    });

    testWidgets('Batal dan Buang tidak menyimpan', (tester) async {
      await pumpApp(tester);
      var calls = 0;
      for (final (button, expected) in [('cancel', false), ('confirm', true)]) {
        bool? answer;
        unawaited(
          confirmDiscardChanges(
            navigator.currentContext!,
            body: 'Isian hilang.',
            key: 'x',
            onSave: () async {
              calls++;
              return true;
            },
          ).then((v) => answer = v),
        );
        await tester.pumpAndSettle();
        await tester.tap(_key('x-$button'));
        await tester.pumpAndSettle();
        expect(answer, expected);
      }
      expect(calls, 0);
    });
  });
}
