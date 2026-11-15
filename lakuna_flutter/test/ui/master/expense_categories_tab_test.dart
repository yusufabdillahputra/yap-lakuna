import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Permission;
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_expenses_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String key, String text) async {
  await tester.enterText(_input(key), text);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('${size.width.toInt()} px: tambah, ubah, hapus jenis', (
      tester,
    ) async {
      final repo = FakeExpensesRepository();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.master,
        expenses: repo,
      );
      await _tap(
        tester,
        size.width < 600
            ? 'master-pill-expenseCategories'
            : 'master-tab-expenseCategories',
      );
      final sewa = repo.categoryByName('Sewa tempat');
      expect(_key('expense-category-${sewa.id.uuid}'), findsOneWidget);

      // Nama ganda (beda huruf) ditolak.
      await _tap(tester, 'expense-categories-new');
      await _type(tester, 'expense-category-name', 'TRANSPORT');
      await _tap(tester, 'expense-category-save');
      expect(_key('expense-category-error'), findsOneWidget);
      await _type(tester, 'expense-category-name', 'Iuran keamanan');
      await _tap(tester, 'expense-category-save');
      expect(_key('expense-category-form'), findsNothing);
      final iuran = repo.categoryByName('Iuran keamanan');

      await _tap(tester, 'expense-category-edit-${iuran.id.uuid}');
      await _type(tester, 'expense-category-name', 'Iuran RT');
      await _tap(tester, 'expense-category-save');
      expect(repo.categoryList.any((c) => c.name == 'Iuran RT'), isTrue);

      // Jenis terpakai tidak bisa dihapus; jenis kosong bisa.
      await _tap(tester, 'expense-category-delete-${sewa.id.uuid}');
      expect(_key('expense-category-delete-error'), findsOneWidget);
      await _tap(tester, 'expense-category-delete-${iuran.id.uuid}');
      expect(repo.categoryList.any((c) => c.id == iuran.id), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tanpa expenses:manage tab jenis tidak tampil', (tester) async {
    await pumpLakuna(
      tester,
      initialLocation: Routes.master,
      expenses: FakeExpensesRepository(canManage: false),
      session: FakeSessionRepository()
        ..current = staffWithPermissions({Permission.productsManage}),
    );
    expect(_key('master-tab-units'), findsOneWidget);
    expect(_key('master-tab-expenseCategories'), findsNothing);
  });

  testWidgets('dialog jenis yang berubah bertanya sebelum ditutup (F1-09b)', (
    tester,
  ) async {
    final repo = FakeExpensesRepository();
    await pumpLakuna(
      tester,
      size: const Size(1280, 800),
      initialLocation: Routes.master,
      expenses: repo,
    );
    await _tap(tester, 'master-tab-expenseCategories');
    await _tap(tester, 'expense-categories-new');
    // Spasi saja bukan perubahan.
    await _type(tester, 'expense-category-name', '  ');
    await _tap(tester, 'expense-category-cancel');
    expect(_key('expense-category-form'), findsNothing);

    await _tap(tester, 'expense-categories-new');
    await _type(tester, 'expense-category-name', 'Parkir');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('expense-category-discard'), findsOneWidget);
    expect(
      find.text(
        'Jenis pengeluaran yang sedang diisi belum disimpan dan akan hilang.',
      ),
      findsOneWidget,
    );
    await _tap(tester, 'expense-category-discard-confirm');
    expect(_key('expense-category-form'), findsNothing);
    expect(repo.categoryList.any((c) => c.name == 'Parkir'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Esc tetap bertanya setelah ketuk di luar lalu Batal (F1-09b)', (
    tester,
  ) async {
    final repo = FakeExpensesRepository();
    await pumpLakuna(
      tester,
      size: const Size(1280, 800),
      initialLocation: Routes.master,
      expenses: repo,
    );
    await _tap(tester, 'master-tab-expenseCategories');
    await _tap(tester, 'expense-categories-new');
    await _type(tester, 'expense-category-name', 'Parkir');
    // Ketukan di luar melepas fokus isian, jadi tidak ada isian berfokus
    // saat Esc ditekan.
    await tester.tapAt(const Offset(20, 780));
    await tester.pumpAndSettle();
    expect(_key('expense-category-discard'), findsOneWidget);
    await _tap(tester, 'expense-category-discard-cancel');
    expect(_key('expense-category-form'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('expense-category-discard'), findsOneWidget);
    await _tap(tester, 'expense-category-discard-confirm');
    expect(_key('expense-category-form'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Esc tanpa isian berfokus tetap menutup / bertanya (F1-09b)', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      size: const Size(1280, 800),
      initialLocation: Routes.master,
      expenses: FakeExpensesRepository(),
    );
    await _tap(tester, 'master-tab-expenseCategories');
    // Dialog baru belum berubah: Esc langsung menutup.
    await _tap(tester, 'expense-categories-new');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('expense-category-form'), findsNothing);

    // Isian dilepas fokusnya (mis. klik area kosong): Esc tetap bertanya.
    await _tap(tester, 'expense-categories-new');
    await _type(tester, 'expense-category-name', 'Parkir');
    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('expense-category-discard'), findsOneWidget);
    await _tap(tester, 'expense-category-discard-cancel');
    // Setelah Batal, Esc masih bekerja.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_key('expense-category-discard'), findsOneWidget);
    await _tap(tester, 'expense-category-discard-confirm');
    expect(_key('expense-category-form'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
