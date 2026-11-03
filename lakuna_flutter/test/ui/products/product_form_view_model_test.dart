import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/catalog_repository.dart';
import 'package:lakuna_flutter/ui/products/product_form_view_model.dart';

import '../../testing/fake_catalog_repository.dart';
import 'product_list_view_model_test.dart' show sampleProducts;

void main() {
  late FakeCatalogRepository repo;

  setUp(() {
    repo = FakeCatalogRepository(seed: sampleProducts());
  });

  Future<ProductFormViewModel> open([String? id]) async {
    final vm = ProductFormViewModel(repository: repo, productId: id);
    await vm.load.execute();
    return vm;
  }

  test('produk baru mulai dengan satu varian kosong dan saran', () async {
    final vm = await open();
    expect(vm.isNew, isTrue);
    expect(vm.loaded, isTrue);
    expect(vm.variants, hasLength(1));
    expect(vm.variants.single.isNew, isTrue);
    expect(vm.categorySuggestions, containsAll(['Sembako', 'Minuman']));
    expect(vm.unitSuggestions, containsAll(['botol', 'dus']));
  });

  test('simpan produk baru dengan satuan konversi dan grosir', () async {
    final vm = await open();
    vm
      ..setName('Teh Botol')
      ..setCategory('minuman')
      ..setBaseUnit('botol');
    vm.editVariant(0, ProductField.sellPrice, (v) {
      v.sellPrice = const Money(6000);
      v.openingStock = Qty.units(48);
    });
    vm.addUnit(0);
    vm.editUnit(0, 0, ProductField.unitName, (u) => u.name = 'krat');
    vm.editUnit(0, 0, ProductField.unitFactor, (u) => u.factor = Qty.units(24));
    vm.addTier(0);
    vm.editTier(0, 0, ProductField.tierMinQty, (t) => t.minQty = Qty.units(24));
    vm.editTier(
      0,
      0,
      ProductField.tierPrice,
      (t) => t.price = const Money(5500),
    );

    await vm.save.execute();
    expect(vm.save.completed, isTrue);
    final saved = repo.saved.single;
    expect(saved.name, 'Teh Botol');
    expect(saved.variants.single.units.single.factor, Qty.units(24));
    expect(saved.variants.single.tiers.single.price, const Money(5500));
    final product = repo.products.firstWhere((p) => p.name == 'Teh Botol');
    expect(product.categoryName, 'Minuman');
    expect(product.variants.single.stock, Qty.units(48));
  });

  test('galat validasi menunjuk field dan pindah ke tab bermasalah', () async {
    final vm = await open();
    vm.addUnit(0);
    vm.addTier(0);
    await vm.save.execute();
    expect(vm.save.error, isTrue);
    expect(vm.problem(ProductField.name)?.error, ProductError.required);
    expect(vm.problem(ProductField.baseUnit)?.error, ProductError.required);
    final v = vm.variants.single;
    final u = v.units.single;
    final t = v.tiers.single;
    expect(
      vm.problem(ProductField.unitName, variant: v.key, unit: u.key)?.error,
      ProductError.required,
    );
    expect(
      vm.problem(ProductField.tierPrice, variant: v.key, tier: t.key)?.error,
      ProductError.required,
    );
    expect(vm.tabHasProblem(ProductTab.units), isTrue);
    expect(vm.tabHasProblem(ProductTab.tiers), isTrue);
    expect(vm.tabHasProblem(ProductTab.variants), isFalse);
    expect(vm.tab, ProductTab.units);
    expect(repo.saved, isEmpty);

    // Mengubah field menghapus galatnya.
    vm.setName('Gula');
    expect(vm.problem(ProductField.name), isNull);
    vm.editUnit(0, 0, ProductField.unitName, (u) => u.name = 'karung');
    expect(
      vm.problem(ProductField.unitName, variant: v.key, unit: u.key),
      isNull,
    );
  });

  test('kode dipakai produk lain ditampilkan dengan nama pemiliknya', () async {
    final vm = await open();
    vm
      ..setName('Kopi Lain')
      ..setBaseUnit('pcs');
    vm.editVariant(0, ProductField.variantSku, (v) => v.sku = 'kop-sch');
    await vm.save.execute();
    final key = vm.variants.single.key;
    final p = vm.problem(ProductField.variantSku, variant: key)!;
    expect(p.error, ProductError.taken);
    expect(p.takenBy, 'Kopi Sachet');
    expect(vm.tab, ProductTab.variants);
  });

  test('ubah produk: isi dari katalog, varian lama tanpa stok awal', () async {
    final existing = repo.products.firstWhere((p) => p.name == 'Minyak Goreng');
    final vm = await open(existing.id.uuid);
    expect(vm.isNew, isFalse);
    expect(vm.originalName, 'Minyak Goreng');
    expect(vm.category, 'Sembako');
    expect(vm.baseUnit, 'botol');
    expect(vm.variants.single.isNew, isFalse);
    expect(vm.variants.single.units.single.name, 'dus');

    vm.addVariant();
    vm.editVariant(0, ProductField.variantName, (v) => v.name = '2 L');
    vm.editVariant(1, ProductField.variantName, (v) => v.name = '1 L');
    vm.editVariant(1, ProductField.openingStock, (v) {
      v.openingStock = Qty.units(5);
    });
    await vm.save.execute();
    expect(vm.save.completed, isTrue);
    final updated = repo.products.firstWhere((p) => p.id == existing.id);
    expect(updated.variants.map((v) => v.name), ['2 L', '1 L']);
    expect(updated.variants.first.stock, Qty.units(24));
    expect(updated.variants.last.stock, Qty.units(5));
  });

  test('hapus varian: minimal satu, galat dibersihkan', () async {
    final vm = await open();
    vm.removeVariant(0);
    expect(vm.variants, hasLength(1));
    vm.addVariant();
    vm.selectVariant(1);
    vm.removeVariant(1);
    expect(vm.variants, hasLength(1));
    expect(vm.selectedVariant, 0);
  });

  test('produk tidak dikenal → notFound', () async {
    final vm = await open('0192f3a1-7c00-7000-8000-00000000dead');
    expect(vm.notFound, isTrue);
  });

  test('galat umum disimpan di error', () async {
    final vm = await open();
    vm
      ..setName('X')
      ..setBaseUnit('pcs');
    repo.nextError = const NotPermitted(Permission.productsManage);
    await vm.save.execute();
    expect(vm.error, isA<NotPermitted>());
    vm.setName('Y');
    expect(vm.error, isNull);
  });

  test('draft membawa semua isian', () async {
    final vm = await open();
    vm
      ..setName(' Sabun ')
      ..setBaseUnit('pcs')
      ..setSku('SBN')
      ..setBrand('Contoh')
      ..setKind(ProductKind.service)
      ..setActive(false)
      ..setTaxable(true);
    final d = vm.draft;
    expect(d.name, ' Sabun ');
    expect(d.sku, 'SBN');
    expect(d.brand, 'Contoh');
    expect(d.kind, ProductKind.service);
    expect(d.isActive, isFalse);
    expect(d.isTaxable, isTrue);
  });

  test(
    'galat di beberapa tab membuka tab pertama menurut urutan form',
    () async {
      final vm = await open();
      vm
        ..setName('Kopi')
        ..setBaseUnit('sachet');
      vm.editVariant(0, ProductField.sellPrice, (v) {
        v.sellPrice = const Money(2000);
        v.sku = 'X' * 41; // terlalu panjang (tab Varian)
      });
      vm.addTier(0);
      vm.editTier(
        0,
        0,
        ProductField.tierMinQty,
        (t) => t.minQty = Qty.units(10),
      );
      vm.setTab(ProductTab.units); // harga grosir kosong = "wajib" (tab Grosir)

      await vm.save.execute();
      expect(vm.tab, ProductTab.variants);
      expect(vm.tabHasProblem(ProductTab.tiers), isTrue);
      expect(vm.hasProblems, isTrue);
    },
  );

  test('varian terpilih tidak bergeser saat varian lain dihapus', () async {
    final vm = await open();
    vm
      ..addVariant()
      ..addVariant();
    final c = vm.variants[2].key;
    vm.selectVariant(2);
    vm.removeVariant(0);
    expect(vm.variants[vm.selectedVariant].key, c);
  });

  test('galat field info dasar mana pun memunculkan spanduk', () async {
    final vm = await open();
    vm
      ..setName('Teh')
      ..setBaseUnit('botol')
      ..setBrand('M' * 61);
    vm.editVariant(0, ProductField.sellPrice, (v) {
      v.sellPrice = const Money(5000);
    });
    await vm.save.execute();
    expect(vm.problem(ProductField.brand), isNotNull);
    expect(vm.hasProblems, isTrue);
  });
}
