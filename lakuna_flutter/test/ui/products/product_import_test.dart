import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/customers/customer_import_view_model.dart';
import 'package:lakuna_flutter/ui/products/product_import_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_catalog_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_spreadsheet_exporter.dart';
import 'product_list_view_model_test.dart' show sampleProducts;

class _Picker extends TableFilePicker {
  _Picker(this.file);

  PickedTableFile? file;

  @override
  Future<PickedTableFile?> pickTable({required int maxBytes}) async => file;
}

PickedTableFile _csv(String text, {String name = 'produk.csv'}) {
  final bytes = Uint8List.fromList(utf8.encode(text));
  return PickedTableFile(name: name, size: bytes.length, bytes: bytes);
}

const _sample =
    'Nama;Kategori;Satuan;Harga Jual;Stok Awal\n'
    'Gula Aren;Sembako;kg;18.000;12\n'
    'Teh Celup;Minuman;kotak;9.500;1,5\n'
    'Kopi Bubuk;Minuman;;mahal;\n';

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

void main() {
  group('ProductImportViewModel', () {
    test('pratinjau, masalah berkas, lalu jalankan', () async {
      final repo = FakeCatalogRepository();
      final picker = _Picker(_csv('kategori\nSembako\n'));
      final vm = ProductImportViewModel(repository: repo, picker: picker);
      await vm.pick.execute();
      expect(vm.problem, ImportFileProblem.missingName);
      expect(vm.canRun, isFalse);

      picker.file = PickedTableFile(name: 'besar.csv', size: 3 << 20);
      await vm.pick.execute();
      expect(vm.problem, ImportFileProblem.tooLarge);

      picker.file = _csv('nama,harga\n');
      await vm.pick.execute();
      expect(vm.problem, ImportFileProblem.empty);

      picker.file = _csv(_sample);
      await vm.pick.execute();
      expect(vm.problem, isNull);
      expect(vm.fileName, 'produk.csv');
      expect(vm.rows.map((r) => r.draft.name), ['Gula Aren', 'Teh Celup']);
      expect(vm.rejected.single.line, 4);
      expect(vm.rejected.single.reason, ProductImportRejectReason.price);
      expect(vm.canRun, isTrue);

      await vm.run.execute();
      final summary = (vm.run.result! as Ok<ProductImportSummary>).value;
      expect(summary.created, 2);
      expect(repo.imported, hasLength(2));
      expect(vm.canRun, isFalse);
      expect(repo.lastUpdateExisting, isFalse);
      vm.dispose();
    });

    test('perbarui harga produk yang ada (F1-07k)', () async {
      final repo = FakeCatalogRepository(
        seed: [
          const ProductDraft(
            name: 'Gula Aren',
            baseUnit: 'kg',
            variants: [VariantDraft(sellPrice: Money(17000))],
          ),
        ],
      );
      final vm = ProductImportViewModel(
        repository: repo,
        picker: _Picker(_csv(_sample)),
      );
      await vm.pick.execute();
      expect(vm.updateExisting, isFalse);
      vm.setUpdateExisting(true);
      await vm.preview.execute();
      await vm.run.execute();
      expect(repo.lastUpdateExisting, isTrue);
      final summary = (vm.run.result! as Ok<ProductImportSummary>).value;
      expect(summary.created, 1);
      expect(summary.updated, 1);
      // Setelah selesai sakelar tidak bisa diubah lagi.
      vm.setUpdateExisting(false);
      expect(vm.updateExisting, isTrue);
      vm.dispose();
    });

    test('pratinjau perubahan harga sebelum simpan (F1-07m)', () async {
      final repo = FakeCatalogRepository(
        seed: [
          const ProductDraft(
            name: 'Gula Aren',
            baseUnit: 'kg',
            variants: [VariantDraft(sellPrice: Money(17000))],
          ),
        ],
      );
      final picker = _Picker(_csv(_sample));
      final vm = ProductImportViewModel(repository: repo, picker: picker);
      await vm.pick.execute();
      // Sakelar mati: langsung import seperti F1-07b.
      expect(vm.needsPreview, isFalse);
      expect(vm.canRun, isTrue);

      vm.setUpdateExisting(true);
      expect(vm.needsPreview, isTrue);
      expect(vm.canPreview, isTrue);
      expect(vm.canRun, isFalse);

      await vm.preview.execute();
      expect(repo.importDryRuns, [true]);
      expect(repo.lastUpdateExisting, isTrue);
      expect(repo.imported, isEmpty);
      final p = vm.previewed!;
      expect(p.created, 1);
      expect(p.updated, 1);
      expect(p.changes.single.oldSell, const Money(17000));
      expect(p.changes.single.newSell, const Money(18000));
      expect(vm.needsPreview, isFalse);
      expect(vm.canPreview, isFalse);
      expect(vm.canRun, isTrue);

      // Sakelar diubah: pratinjau hilang dan harus diulang.
      vm.setUpdateExisting(false);
      expect(vm.previewed, isNull);
      vm.setUpdateExisting(true);
      expect(vm.previewed, isNull);
      expect(vm.canRun, isFalse);
      await vm.preview.execute();
      expect(vm.previewed, isNotNull);

      // Berkas baru juga menghapus pratinjau.
      await vm.pick.execute();
      expect(vm.previewed, isNull);
      expect(vm.canRun, isFalse);

      await vm.preview.execute();
      await vm.run.execute();
      expect(repo.importDryRuns, [true, true, true, false]);
      expect(repo.imported, hasLength(1));
      vm.dispose();
    });

    test('pratinjau berjalan atau gagal (F1-07m)', () async {
      final repo = FakeCatalogRepository();
      final vm = ProductImportViewModel(
        repository: repo,
        picker: _Picker(_csv(_sample)),
      );
      await vm.pick.execute();
      vm.setUpdateExisting(true);
      repo.nextError = const NotPermitted(Permission.productsManage);
      final pending = vm.preview.execute();
      // Selama pratinjau: sakelar terkunci, tombol nonaktif.
      expect(vm.preview.running, isTrue);
      expect(vm.canPreview, isFalse);
      vm.setUpdateExisting(false);
      expect(vm.updateExisting, isTrue);
      await pending;
      expect(vm.preview.error, isTrue);
      expect(vm.previewed, isNull);
      // Gagal: tetap harus pratinjau, bisa diulang.
      expect(vm.needsPreview, isTrue);
      expect(vm.canPreview, isTrue);
      expect(vm.canRun, isFalse);
      await vm.preview.execute();
      expect(vm.previewed, isNotNull);
      vm.dispose();
    });

    test('ringkasan pratinjau bahasa Inggris memakai bentuk tunggal', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(
        en.productImportPreviewSummary(1, 2, 0, 3),
        '1 new product · 2 updated · 0 unchanged · 3 skipped',
      );
      expect(
        en.productImportPreviewSummary(2, 1, 1, 0),
        '2 new products · 1 updated · 1 unchanged · 0 skipped',
      );
    });

    test('pratinjau tanpa perubahan: simpan nonaktif (F1-07m)', () async {
      final repo = FakeCatalogRepository(
        seed: [
          const ProductDraft(
            name: 'Gula Aren',
            baseUnit: 'kg',
            variants: [VariantDraft(sellPrice: Money(18000))],
          ),
        ],
      );
      final vm = ProductImportViewModel(
        repository: repo,
        picker: _Picker(_csv('Nama;Harga Jual\nGula Aren;18.000\n')),
      );
      await vm.pick.execute();
      vm.setUpdateExisting(true);
      await vm.preview.execute();
      expect(vm.previewed!.unchanged, 1);
      expect(vm.canRun, isFalse);
      vm.dispose();
    });
  });

  Future<FakeCatalogRepository> pump(
    WidgetTester tester,
    Size size, {
    List<ProductDraft>? seed,
    FakeSpreadsheetExporter? exporter,
  }) async {
    final repo = FakeCatalogRepository(seed: seed);
    await pumpLakuna(
      exporter: exporter,
      tester,
      size: size,
      initialLocation: Routes.products,
      catalog: repo,
      session: FakeSessionRepository()..current = sampleStaff(),
      tablePicker: _Picker(_csv(_sample)),
    );
    return repo;
  }

  testWidgets('ponsel: pratinjau panjang dipotong 30 baris (F1-07m)', (
    tester,
  ) async {
    final repo = FakeCatalogRepository(
      seed: [
        for (var i = 1; i <= 32; i++)
          ProductDraft(
            name: 'Produk $i',
            baseUnit: 'pcs',
            variants: [
              VariantDraft(costPrice: Money(500), sellPrice: Money(1000 * i)),
            ],
          ),
      ],
    );
    final csv = StringBuffer('Nama;Harga Beli;Harga Jual;Stok Minimum\n');
    for (var i = 1; i <= 32; i++) {
      // Produk 2: hanya stok minimum yang berubah.
      final sell = i == 2 ? 2000 : 1000 * i + 100;
      csv.write('Produk $i;${i == 1 ? 600 : 500};$sell;${i == 2 ? 4 : ''}\n');
    }
    await pumpLakuna(
      tester,
      size: const Size(360, 740),
      initialLocation: Routes.products,
      catalog: repo,
      session: FakeSessionRepository()..current = sampleStaff(),
      tablePicker: _Picker(_csv(csv.toString())),
    );
    await _tap(tester, 'products-import');
    await _tap(tester, 'product-import-pick');
    await _tap(tester, 'product-import-update');
    // Pratinjau gagal: pesan tampil, tombol tetap Lihat perubahan.
    repo.nextError = const NotPermitted(Permission.productsManage);
    await _tap(tester, 'product-import-preview');
    expect(_key('product-import-preview-error'), findsOneWidget);
    expect(_key('product-import-run'), findsNothing);
    await _tap(tester, 'product-import-preview');
    expect(_key('product-import-preview-error'), findsNothing);
    expect(find.text('Produk 1 · Rp 1.000 → Rp 1.100'), findsOneWidget);
    expect(find.text('Harga beli Rp 500 → Rp 600'), findsOneWidget);
    expect(find.text('Produk 2'), findsOneWidget);
    expect(find.text('Stok minimum 0 → 4 pcs'), findsOneWidget);
    expect(find.text('Produk 30 · Rp 30.000 → Rp 30.100'), findsOneWidget);
    expect(find.textContaining('Produk 31 ·'), findsNothing);
    expect(find.text('dan 2 perubahan lainnya'), findsOneWidget);
    // Belum ada yang tersimpan.
    expect(
      repo.products
          .firstWhere((p) => p.name == 'Produk 1')
          .variants
          .single
          .sellPrice,
      const Money(1000),
    );
    await _tap(tester, 'product-import-run');
    expect(_key('product-import-done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final (label, size) in [
    ('desktop', const Size(1280, 800)),
    ('ponsel', const Size(360, 740)),
  ]) {
    testWidgets('$label: import dari daftar kosong lalu daftar terisi', (
      tester,
    ) async {
      final exporter = FakeSpreadsheetExporter();
      final repo = await pump(tester, size, exporter: exporter);
      await _tap(tester, 'products-empty-import');
      // Templat (F1-07g) bisa diunduh dari dialog yang sama.
      await _tap(tester, 'import-template-products');
      expect(exporter.saved.single.$1, 'templat-import-produk.xlsx');
      expect(_key('product-import'), findsOneWidget);
      await _tap(tester, 'product-import-pick');
      expect(_key('product-import-ready'), findsOneWidget);
      expect(
        find.text('Baris 4: harga jual kosong atau bukan rupiah bulat'),
        findsOneWidget,
      );
      await _tap(tester, 'product-import-run');
      expect(repo.imported, hasLength(2));
      expect(
        find.text('Selesai: 2 produk baru, 0 dilewati karena sudah ada.'),
        findsOneWidget,
      );
      await _tap(tester, 'product-import-close');
      expect(_key('product-import'), findsNothing);
      expect(find.text('Gula Aren'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$label: tombol header, produk yang sudah ada dilewati', (
      tester,
    ) async {
      final repo = await pump(tester, size, seed: sampleProducts());
      await _tap(tester, 'products-import');
      await _tap(tester, 'product-import-pick');
      await _tap(tester, 'product-import-run');
      expect(repo.imported, hasLength(2));
      expect(_key('product-import-done'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$label: sakelar perbarui harga (F1-07k)', (tester) async {
      final repo = await pump(
        tester,
        size,
        seed: [
          const ProductDraft(
            name: 'Gula Aren',
            baseUnit: 'kg',
            variants: [VariantDraft(sellPrice: Money(17000))],
          ),
        ],
      );
      await _tap(tester, 'products-import');
      await _tap(tester, 'product-import-pick');
      expect(
        find.textContaining('Hanya menambah produk baru'),
        findsOneWidget,
      );
      await _tap(tester, 'product-import-update');
      expect(
        find.textContaining('Sel kosong tidak mengubah apa pun'),
        findsOneWidget,
      );
      // Pratinjau dulu (F1-07m), baru simpan.
      expect(_key('product-import-run'), findsNothing);
      await _tap(tester, 'product-import-preview');
      expect(_key('product-import-changes'), findsOneWidget);
      expect(
        find.text(
          '1 produk baru · 1 diperbarui · 0 tidak berubah · 0 dilewati',
        ),
        findsOneWidget,
      );
      expect(find.text('Gula Aren · Rp 17.000 → Rp 18.000'), findsOneWidget);
      expect(repo.products, hasLength(1));
      await _tap(tester, 'product-import-run');
      expect(repo.lastUpdateExisting, isTrue);
      expect(_key('product-import-changes'), findsNothing);
      expect(
        find.text(
          'Selesai: 1 produk baru, 1 harga diperbarui, 0 tidak berubah, '
          '0 dilewati.',
        ),
        findsOneWidget,
      );
      expect(
        repo.products
            .firstWhere((p) => p.name == 'Gula Aren')
            .variants
            .single
            .sellPrice,
        const Money(18000),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
