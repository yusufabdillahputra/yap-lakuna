import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/products/archived_products_view_model.dart';
import 'package:lakuna_flutter/ui/products/product_form_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_catalog_repository.dart';
import 'product_list_view_model_test.dart' show sampleProducts;

/// F1-07d: arsip produk (view model).
void main() {
  late FakeCatalogRepository repo;

  setUp(() => repo = FakeCatalogRepository(seed: sampleProducts()));

  CatalogProduct named(String name) =>
      repo.products.firstWhere((p) => p.name == name);

  test('form: arsip produk lama, peringatan stok', () async {
    final minyak = named('Minyak Goreng');
    final vm = ProductFormViewModel(
      repository: repo,
      productId: minyak.id.uuid,
    );
    await vm.load.execute();
    expect(vm.canArchive, isTrue);
    expect(vm.archiveStock, (Qty.units(24), 'botol'));
    await vm.archive.execute();
    expect(vm.archive.result, isA<Ok<void>>());
    expect(repo.archivedProducts.single.id, minyak.id);
  });

  test(
    'form: produk baru tidak bisa diarsipkan; jasa tanpa peringatan',
    () async {
      final baru = ProductFormViewModel(repository: repo);
      await baru.load.execute();
      expect(baru.canArchive, isFalse);
      final jasa = ProductFormViewModel(
        repository: repo,
        productId: named('Jasa Antar').id.uuid,
      );
      await jasa.load.execute();
      expect(jasa.canArchive, isTrue);
      expect(jasa.archiveStock, isNull);
    },
  );

  test('daftar arsip: muat, pulihkan, kode kembar ditolak', () async {
    final minyak = named('Minyak Goreng');
    final kopi = named('Kopi Sachet');
    await repo.archive(minyak.id);
    await repo.archive(kopi.id);
    await repo.save(
      ProductDraft(
        name: 'Minyak Baru',
        baseUnit: 'botol',
        variants: const [
          VariantDraft(barcode: '8991234500024', sellPrice: Money(35000)),
        ],
      ),
    );
    final vm = ArchivedProductsViewModel(repository: repo);
    await vm.load.execute();
    expect(vm.products!.map((p) => p.name), ['Kopi Sachet', 'Minyak Goreng']);
    expect(vm.changed, isFalse);

    await vm.restore.execute(minyak.id);
    final error = vm.errorFor(minyak.id);
    expect(error, isA<ProductCodesTaken>());
    expect(
      (error! as ProductCodesTaken).conflicts.single.takenBy,
      'Minyak Baru',
    );
    expect(vm.errorFor(kopi.id), isNull);
    expect(vm.products, hasLength(2));

    await vm.restore.execute(kopi.id);
    expect(vm.errorFor(minyak.id), isNull);
    expect(vm.restoredName, 'Kopi Sachet');
    expect(vm.changed, isTrue);
    expect(vm.products!.single.name, 'Minyak Goreng');
    expect(repo.products.map((p) => p.name), contains('Kopi Sachet'));
  });
}
