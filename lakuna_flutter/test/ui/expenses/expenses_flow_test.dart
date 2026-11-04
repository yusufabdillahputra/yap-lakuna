import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_expenses_repository.dart';
import '../../testing/fake_payment_settings_repository.dart'
    show FakeImagePicker;
import '../../testing/fake_spreadsheet_exporter.dart';
import '../../testing/qris_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _keyPrefix(String prefix) => find.byWidgetPredicate(
  (w) =>
      w.key is ValueKey<String> &&
      (w.key! as ValueKey<String>).value.startsWith(prefix),
);

Finder _rows() => _keyPrefix('expenses-row-');

Finder _input(Finder field) =>
    find.descendant(of: field, matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.enterText(_input(field), text);
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, Finder field, String label) async {
  await _tap(tester, field);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  late FakeExpensesRepository repo;
  late FakeImagePicker picker;
  late FakeSpreadsheetExporter exporter;

  Future<void> pump(
    WidgetTester tester,
    Size size, {
    FakeExpensesRepository? expenses,
  }) async {
    repo = expenses ?? FakeExpensesRepository();
    picker = FakeImagePicker();
    exporter = FakeSpreadsheetExporter();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.expenses,
      expenses: repo,
      imagePicker: picker,
      exporter: exporter,
    );
  }

  /// Mengisi form pengeluaran yang sedang tampil (generasi [gen]).
  Future<void> fill(
    WidgetTester tester, {
    int gen = 0,
    String description = 'Galon air',
    String category = 'Bahan habis pakai',
    String amount = '25000',
  }) async {
    await _type(tester, _key('expense-description-$gen'), description);
    await _choose(tester, _keyPrefix('expense-category-$gen-'), category);
    await _type(tester, _key('expense-amount-$gen'), amount);
  }

  testWidgets('1440 px: daftar, per jenis, catat dengan foto, batal', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    expect(_rows(), findsNWidgets(5));
    expect(_key('expenses-form-card'), findsOneWidget);
    expect(_key('expenses-new'), findsNothing);
    expect(find.text('Total Rp 3.250.000'), findsOneWidget);
    expect(_key('expenses-category-Sewa tempat'), findsOneWidget);
    expect(find.text('Kas laci · sesi Sari'), findsOneWidget);

    // Galat isian tampil setelah mencoba menyimpan.
    await _tap(tester, _key('expense-save'));
    expect(find.text('Pilih jenis pengeluaran.'), findsOneWidget);
    expect(repo.requests, isEmpty);

    await fill(tester);
    picker.next = PickedImage(
      name: 'nota.png',
      size: tinyPortraitPng.length,
      bytes: tinyPortraitPng,
    );
    await _tap(tester, _key('expense-receipt-pick'));
    expect(_key('expense-receipt-preview'), findsOneWidget);
    await _tap(tester, _key('expense-save'));
    final saved = repo.expenses.last;
    expect(saved.description, 'Galon air');
    expect(saved.amount, 25000);
    expect(saved.fundingSource, FundingSource.drawer);
    expect(repo.receipts[saved.id], isNotNull);
    expect(_rows(), findsNWidgets(6));
    expect(find.text('Total Rp 3.275.000'), findsOneWidget);
    // Isian dikosongkan (generasi baru).
    expect(_key('expense-description-1'), findsOneWidget);

    // Rincian → batal dengan alasan.
    final listrik = repo.byDescription('Token listrik');
    await _tap(tester, _key('expenses-row-${listrik.id.uuid}'));
    expect(_key('expense-detail'), findsOneWidget);
    await _tap(tester, _key('expense-void'));
    await _tap(tester, _key('expense-void-confirm'));
    expect(find.text('Alasan wajib diisi, maksimal 200 karakter.'), findsOne);
    await _type(tester, _key('expense-void-reason'), 'Dobel input');
    await _tap(tester, _key('expense-void-confirm'));
    expect(_key('expense-detail-voided'), findsOneWidget);
    expect(_key('expense-detail-void-info'), findsOneWidget);
    await _tap(tester, _key('expense-detail-close'));
    expect(_key('expense-detail'), findsNothing);
    expect(find.text('Dibatalkan'), findsOneWidget);
    expect(find.text('Total Rp 2.775.000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('1440 px: cari, periode, dan ekspor', (tester) async {
    await pump(tester, const Size(1440, 900));
    await _type(tester, _key('expenses-search'), 'listrik');
    expect(_rows(), findsOneWidget);
    await _type(tester, _key('expenses-search'), 'zzz');
    expect(_key('expenses-empty'), findsOneWidget);
    await _type(tester, _key('expenses-search'), '');
    await _choose(tester, _key('expenses-period'), 'Bulan lalu');
    expect(_rows(), findsNWidgets(2));
    expect(find.text('Per jenis · Bulan lalu'), findsOneWidget);
    await _tap(tester, _key('expenses-export'));
    expect(_key('expenses-export-saved'), findsOneWidget);
    expect(exporter.saved.single.$1, 'pengeluaran-bulan-lalu-261104.xlsx');
    expect(tester.takeException(), isNull);
  });

  testWidgets('kas laci tanpa sesi terbuka ditolak di form', (tester) async {
    await pump(
      tester,
      const Size(1440, 900),
      expenses: FakeExpensesRepository(hasOpenSession: false),
    );
    expect(_key('expense-drawer-hint'), findsNothing);
    await _choose(
      tester,
      _key('expense-funding-0'),
      'Kas laci (sesi aktif)',
    );
    expect(_key('expense-drawer-hint'), findsOneWidget);
    await fill(tester);
    await _tap(tester, _key('expense-save'));
    expect(repo.requests, isEmpty);
    await _choose(tester, _key('expense-funding-0'), 'Rekening bank');
    expect(_key('expense-drawer-hint'), findsNothing);
    await _tap(tester, _key('expense-save'));
    expect(repo.expenses.last.fundingSource, FundingSource.bank);
  });

  for (final size in const [Size(800, 900), Size(360, 740)]) {
    testWidgets('${size.width.toInt()} px: catat lewat dialog', (
      tester,
    ) async {
      await pump(tester, size);
      expect(_key('expenses-form-card'), findsNothing);
      expect(_rows(), findsNWidgets(5));
      await _tap(tester, _key('expenses-new'));
      expect(_key('expense-form-dialog'), findsOneWidget);
      await fill(tester, description: 'Parkir', category: 'Transport');
      await _tap(tester, _key('expense-save'));
      expect(_key('expense-form-dialog'), findsNothing);
      expect(repo.expenses.last.description, 'Parkir');
      expect(_rows(), findsNWidgets(6));

      // Batal menutup dialog tanpa menyimpan.
      await _tap(tester, _key('expenses-new'));
      await _tap(tester, _key('expense-cancel'));
      expect(_key('expense-form-dialog'), findsNothing);

      final sewa = repo.byDescription('Sewa tempat November');
      await _tap(tester, _key('expenses-row-${sewa.id.uuid}'));
      expect(_key('expense-detail'), findsOneWidget);
      await _tap(tester, _key('expense-detail-close'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tanpa izin tampil galat muat', (tester) async {
    await pump(
      tester,
      const Size(1440, 900),
      expenses: FakeExpensesRepository(canManage: false),
    );
    expect(_key('expenses-error'), findsOneWidget);
  });
}
