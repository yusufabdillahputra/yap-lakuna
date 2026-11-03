import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/catalog_repository.dart';
import 'package:lakuna_flutter/ui/products/product_list_view_model.dart';

import '../../testing/fake_catalog_repository.dart';

List<ProductDraft> sampleProducts() => [
  ProductDraft(
    name: 'Minyak Goreng',
    category: 'Sembako',
    baseUnit: 'botol',
    variants: [
      VariantDraft(
        sku: 'MYK-2L',
        barcode: '8991234500024',
        sellPrice: const Money(36000),
        openingStock: Qty.units(24),
        minStock: Qty.units(12),
        units: [
          UnitDraft(name: 'dus', factor: Qty.units(6), barcode: '899100'),
        ],
      ),
    ],
  ),
  ProductDraft(
    name: 'Kopi Sachet',
    category: 'Minuman',
    baseUnit: 'sachet',
    variants: [
      VariantDraft(
        sku: 'KOP-SCH',
        sellPrice: const Money(2000),
        openingStock: Qty.units(2),
        minStock: Qty.units(20),
      ),
    ],
  ),
  ProductDraft(
    name: 'Jasa Antar',
    baseUnit: 'kali',
    kind: ProductKind.service,
    isActive: false,
    variants: const [VariantDraft(sellPrice: Money(5000))],
  ),
];

void main() {
  late FakeCatalogRepository repo;
  late ProductListViewModel vm;

  setUp(() async {
    repo = FakeCatalogRepository(seed: sampleProducts());
    vm = ProductListViewModel(repository: repo);
    await vm.load.execute();
  });

  test('ringkasan aktif dan di bawah minimum', () {
    expect(vm.loaded, isTrue);
    expect(vm.activeCount, 2);
    expect(vm.lowStockCount, 1);
    expect(vm.products.map((p) => p.name), [
      'Jasa Antar',
      'Kopi Sachet',
      'Minyak Goreng',
    ]);
    expect(vm.categories.map((c) => c.name), ['Sembako', 'Minuman']);
  });

  test('cari nama, SKU, dan barcode satuan', () {
    vm.setQuery('kopi');
    expect(vm.products.single.name, 'Kopi Sachet');
    vm.setQuery('myk-2');
    expect(vm.products.single.name, 'Minyak Goreng');
    vm.setQuery('899100');
    expect(vm.products.single.name, 'Minyak Goreng');
    vm.setQuery('tidak ada');
    expect(vm.products, isEmpty);
    expect(vm.isEmpty, isFalse);
  });

  test('filter kategori dan chip di bawah minimum saling mengganti', () {
    final minuman = vm.categories.firstWhere((c) => c.name == 'Minuman');
    vm.setCategory(minuman.id);
    expect(vm.products.single.name, 'Kopi Sachet');
    vm.setLowStockOnly(true);
    expect(vm.categoryId, isNull);
    expect(vm.products.single.name, 'Kopi Sachet');
    vm.setCategory(null);
    expect(vm.lowStockOnly, isFalse);
    expect(vm.products, hasLength(3));
  });

  test('gagal muat tetap belum termuat', () async {
    final failing = FakeCatalogRepository()
      ..nextError = const NotPermitted(Permission.productsManage);
    final vm = ProductListViewModel(repository: failing);
    await vm.load.execute();
    expect(vm.loaded, isFalse);
    expect(vm.load.error, isTrue);
  });

  test('katalog kosong', () async {
    final vm = ProductListViewModel(repository: FakeCatalogRepository());
    await vm.load.execute();
    expect(vm.isEmpty, isTrue);
  });
}
