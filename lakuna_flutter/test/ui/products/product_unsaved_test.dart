import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/ui/products/product_form_view_model.dart';

import '../../testing/fake_catalog_repository.dart';
import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/floor_seed.dart';
import 'product_list_view_model_test.dart' show sampleProducts;

/// F1-07q: perubahan form produk yang belum tersimpan.
void main() {
  late FakeCatalogRepository repo;
  late FakeImagePicker picker;

  setUp(() {
    repo = FakeCatalogRepository(seed: sampleProducts());
    picker = FakeImagePicker();
  });

  Future<ProductFormViewModel> open([String? id]) async {
    final vm = ProductFormViewModel(
      repository: repo,
      productId: id,
      picker: picker,
    );
    await vm.load.execute();
    return vm;
  }

  String idOf(String name) =>
      repo.products.firstWhere((p) => p.name == name).id.uuid;

  test('produk baru dan lama belum berubah; ketik lalu kembalikan', () async {
    final baru = await open();
    expect(baru.hasUnsavedChanges, isFalse);
    baru.setName('Teh');
    expect(baru.hasUnsavedChanges, isTrue);
    baru.setName('');
    expect(baru.hasUnsavedChanges, isFalse);
    // Pindah tab bukan perubahan.
    baru.setTab(ProductTab.units);
    expect(baru.hasUnsavedChanges, isFalse);

    final lama = await open(idOf('Minyak Goreng'));
    expect(lama.hasUnsavedChanges, isFalse);
    lama.editVariant(
      0,
      ProductField.sellPrice,
      (v) => v.sellPrice = const Money(37000),
    );
    expect(lama.hasUnsavedChanges, isTrue);
  });

  test('satuan, grosir, varian, dan sakelar terhitung berubah', () async {
    final vm = await open(idOf('Minyak Goreng'));
    vm.addTier(0);
    expect(vm.hasUnsavedChanges, isTrue);
    vm.removeTier(0, vm.variants[0].tiers.length - 1);
    expect(vm.hasUnsavedChanges, isFalse);
    vm.addUnit(0);
    expect(vm.hasUnsavedChanges, isTrue);
    vm.removeUnit(0, vm.variants[0].units.length - 1);
    expect(vm.hasUnsavedChanges, isFalse);
    vm.setTaxable(!vm.isTaxable);
    expect(vm.hasUnsavedChanges, isTrue);
    vm.setTaxable(!vm.isTaxable);
    vm.addVariant();
    expect(vm.hasUnsavedChanges, isTrue);
  });

  test('foto baru terhitung berubah', () async {
    final vm = await open(idOf('Minyak Goreng'));
    picker.next = PickedImage(
      name: 'minyak.png',
      size: samplePng.length,
      bytes: samplePng,
    );
    await vm.pickPhoto.execute();
    expect(vm.hasUnsavedChanges, isTrue);
  });

  test('simpan berhasil: boleh ditinggalkan; galat: tetap berubah', () async {
    final vm = await open(idOf('Minyak Goreng'));
    vm.setBrand('Bimoli');
    repo.nextError = Exception('disk penuh');
    await vm.save.execute();
    expect(vm.save.error, isTrue);
    expect(vm.hasUnsavedChanges, isTrue);
    await vm.save.execute();
    expect(vm.save.completed, isTrue);
    expect(vm.hasUnsavedChanges, isFalse);
  });

  test('foto gagal disimpan: tetap berubah', () async {
    final vm = await open();
    vm
      ..setName('Teh Botol')
      ..setBaseUnit('botol')
      ..editVariant(
        0,
        ProductField.sellPrice,
        (v) => v.sellPrice = const Money(5000),
      );
    picker.next = PickedImage(
      name: 'teh.png',
      size: samplePng.length,
      bytes: samplePng,
    );
    await vm.pickPhoto.execute();
    repo.nextPhotoError = Exception('media penuh');
    await vm.save.execute();
    expect(vm.save.error, isTrue);
    expect(vm.hasUnsavedChanges, isTrue);
  });

  PickedImage png() =>
      PickedImage(name: 'p.png', size: samplePng.length, bytes: samplePng);

  test('foto gagal lalu dilepas: tidak berubah lagi', () async {
    final vm = await open();
    vm
      ..setName('Teh Botol')
      ..setBaseUnit('botol')
      ..editVariant(
        0,
        ProductField.sellPrice,
        (v) => v.sellPrice = const Money(5000),
      );
    picker.next = png();
    await vm.pickPhoto.execute();
    repo.nextPhotoError = Exception('media penuh');
    await vm.save.execute();
    expect(vm.hasUnsavedChanges, isTrue);
    // Produk sudah tersimpan; hanya foto yang tertunda.
    vm.removePhoto();
    expect(vm.hasUnsavedChanges, isFalse);
  });

  test('foto gagal: mengembalikan harga yang sudah tersimpan tetap '
      'berubah', () async {
    final vm = await open(idOf('Minyak Goreng'));
    final before = vm.variants[0].sellPrice;
    vm.editVariant(
      0,
      ProductField.sellPrice,
      (v) => v.sellPrice = const Money(37000),
    );
    picker.next = png();
    await vm.pickPhoto.execute();
    repo.nextPhotoError = Exception('media penuh');
    await vm.save.execute();
    vm
      ..editVariant(0, ProductField.sellPrice, (v) => v.sellPrice = before)
      ..removePhoto();
    expect(vm.hasUnsavedChanges, isTrue);
  });

  test('melepas foto tersimpan berubah; memilih varian tidak', () async {
    final id = idOf('Kopi Sachet');
    final first = await open(id);
    picker.next = png();
    await first.pickPhoto.execute();
    await first.save.execute();
    expect(first.hasUnsavedChanges, isFalse);

    final vm = await open(id);
    vm
      ..addVariant()
      ..selectVariant(1);
    vm.removeVariant(1);
    vm.selectVariant(0);
    expect(vm.hasUnsavedChanges, isFalse);
    vm.removePhoto();
    expect(vm.hasUnsavedChanges, isTrue);
  });

  test('barcode dari Cetak label bukan perubahan', () async {
    final id = idOf('Kopi Sachet');
    final vm = await open(id);
    expect(vm.variants.single.barcode, isEmpty);
    // Barcode dibuat di Cetak label (F1-07j).
    final other = await open(id);
    other.editVariant(
      0,
      ProductField.variantBarcode,
      (v) => v.barcode = '2000000000015',
    );
    await other.save.execute();
    await vm.refreshBarcodes();
    expect(vm.variants.single.barcode, '2000000000015');
    expect(vm.hasUnsavedChanges, isFalse);
  });

  test('diarsipkan: boleh ditinggalkan', () async {
    final vm = await open(idOf('Minyak Goreng'));
    vm.setBrand('Bimoli');
    await vm.archive.execute();
    expect(vm.archive.completed, isTrue);
    expect(vm.hasUnsavedChanges, isFalse);
  });
}
