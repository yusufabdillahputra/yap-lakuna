import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/ui/products/product_form_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_catalog_repository.dart';
import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/floor_seed.dart';
import 'product_list_view_model_test.dart' show sampleProducts;

/// F1-07f: foto produk di form 1.16.
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

  PickedImage png([String name = 'kopi.png']) =>
      PickedImage(name: name, size: samplePng.length, bytes: samplePng);

  String kopiId() =>
      repo.products.firstWhere((p) => p.name == 'Kopi Sachet').id.uuid;

  test('pilih foto lalu simpan memasang foto ke produk', () async {
    final vm = await open(kopiId());
    expect(vm.hasPhoto, isFalse);
    picker.next = png();
    await vm.pickPhoto.execute();
    expect(vm.photoBytes, samplePng);
    expect(vm.hasPhoto, isTrue);
    expect(repo.photoCalls, isEmpty, reason: 'baru tersimpan saat Simpan');
    await vm.save.execute();
    expect(vm.save.result, isA<Ok<UuidValue>>());
    final (id, photo) = repo.photoCalls.single;
    expect(id.uuid, kopiId());
    expect(photo!.fileName, 'kopi.png');
  });

  test('produk baru: foto dipasang setelah produk tersimpan', () async {
    final vm = await open();
    vm
      ..name = 'Teh Botol'
      ..baseUnit = 'botol';
    vm.variants.single.sellPrice = const Money(5000);
    picker.next = png('teh.jpg');
    await vm.pickPhoto.execute();
    await vm.save.execute();
    final saved = (vm.save.result! as Ok<UuidValue>).value;
    expect(repo.photoCalls.single.$1, saved);
  });

  test('hapus foto lama lalu simpan', () async {
    final vm0 = await open(kopiId());
    picker.next = png();
    await vm0.pickPhoto.execute();
    await vm0.save.execute();
    repo.photoCalls.clear();

    final vm = await open(kopiId());
    expect(vm.photoPath, '/media/kopi.png');
    expect(vm.hasPhoto, isTrue);
    vm.removePhoto();
    expect(vm.hasPhoto, isFalse);
    await vm.save.execute();
    expect(repo.photoCalls.single.$2, isNull);
    expect(
      repo.products.firstWhere((p) => p.id.uuid == kopiId()).photoPath,
      isNull,
    );
  });

  test('tanpa perubahan foto, simpan tidak menyentuh foto', () async {
    final vm = await open(kopiId());
    await vm.save.execute();
    expect(repo.photoCalls, isEmpty);
  });

  test('berkas bukan gambar atau terlalu besar ditolak di form', () async {
    final vm = await open(kopiId());
    picker.next = PickedImage(
      name: 'catatan.png',
      size: 10,
      bytes: Uint8List.fromList(List.filled(10, 1)),
    );
    await vm.pickPhoto.execute();
    expect(vm.photoError, ProductPhotoError.unsupported);
    expect(vm.hasPhoto, isFalse);

    picker.next = const PickedImage(name: 'besar.jpg', size: 9999999);
    await vm.pickPhoto.execute();
    expect(vm.photoError, ProductPhotoError.tooLarge);

    picker.next = png();
    await vm.pickPhoto.execute();
    expect(vm.photoError, isNull);

    // Batal memilih: foto terpilih tetap.
    await vm.pickPhoto.execute();
    expect(vm.photoBytes, samplePng);
  });

  test('ambil foto dari kamera bila tersedia', () async {
    picker.camera = true;
    final vm = await open(kopiId());
    expect(vm.canTakePhoto, isTrue);
    picker.next = png('kamera.jpg');
    await vm.takePhoto.execute();
    expect(picker.photoCalls, 1);
    expect(vm.photoBytes, samplePng);
  });

  test(
    'produk tersimpan tetapi foto gagal: simpan ulang tidak menggandakan',
    () async {
      final vm = await open();
      vm
        ..name = 'Teh Botol'
        ..baseUnit = 'botol';
      vm.variants.single.sellPrice = const Money(5000);
      picker.next = png('teh.jpg');
      await vm.pickPhoto.execute();
      repo.nextPhotoError = Exception('disk penuh');
      await vm.save.execute();
      expect(vm.save.result, isA<Error<UuidValue>>());
      expect(vm.error, isA<ProductPhotoNotSaved>());
      expect(repo.products.where((p) => p.name == 'Teh Botol'), hasLength(1));
      // Form diisi ulang dari produk tersimpan: bukan produk baru lagi,
      // varian punya ID, stok awal tidak dikirim ulang.
      expect(vm.isNew, isFalse);
      expect(vm.productId, isNotNull);
      expect(vm.variants.single.id, isNotNull);
      expect(vm.photoBytes, samplePng);

      await vm.save.execute();
      expect(vm.save.result, isA<Ok<UuidValue>>());
      expect(repo.products.where((p) => p.name == 'Teh Botol'), hasLength(1));
      expect(repo.photoCalls, hasLength(1));
      expect(repo.saved.last.variants.single.id, isNotNull);
      expect(repo.saved.last.variants.single.openingStock, Qty.zero);
    },
  );

  test('kamera: lebar 1.600 px; galat kamera jadi pesan', () async {
    picker.camera = true;
    final vm = await open(kopiId());
    picker.next = png('kamera.jpg');
    await vm.takePhoto.execute();
    expect(picker.lastPhotoWidth, ProductLimits.cameraMaxWidth);

    picker.throwNext = Exception('izin kamera ditolak');
    await vm.takePhoto.execute();
    expect(vm.photoError, ProductPhotoError.unreadable);
    expect(vm.photoBytes, samplePng);
  });
}
