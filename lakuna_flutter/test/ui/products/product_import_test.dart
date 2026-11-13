import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
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
  }
}
