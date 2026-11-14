import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/ui/purchases/purchase_detail_view_model.dart';
import 'package:lakuna_flutter/ui/purchases/purchase_form_view_model.dart';

import '../../testing/fake_payment_settings_repository.dart';
import '../../testing/fake_purchases_repository.dart';
import '../../testing/floor_seed.dart';

/// F1-12b: foto faktur di form dan detail pembelian.
void main() {
  late FakePurchasesRepository repo;
  late FakeImagePicker picker;

  PickedImage picked(Uint8List? bytes, {String name = 'faktur.png'}) =>
      PickedImage(name: name, size: bytes?.length ?? 1 << 30, bytes: bytes);

  setUp(() {
    repo = FakePurchasesRepository();
    picker = FakeImagePicker();
  });

  Future<PurchaseFormViewModel> openForm({UuidValue? draftId}) async {
    final form = PurchaseFormViewModel(
      repository: repo,
      draftId: draftId,
      picker: picker,
    );
    await form.load.execute();
    return form;
  }

  void fill(PurchaseFormViewModel form) => form
    ..selectSupplier(repo.suppliers.single.id)
    ..addByCode('8991234500031');

  group('form pembelian', () {
    test(
      'pilih foto: pratinjau, ikut request, lalu tidak dikirim ulang',
      () async {
        final form = await openForm();
        fill(form);
        picker.next = picked(samplePng);
        await form.pickInvoicePhoto.execute(false);
        expect(picker.lastWebp, isTrue);
        expect(form.invoicePhoto, samplePng);
        expect(form.invoicePhotoName, 'faktur.png');

        await form.saveDraft.execute();
        final sent = repo.requests.single;
        expect(sent.invoicePhoto!.bytes, samplePng);
        expect(sent.invoicePhoto!.fileName, 'faktur.png');
        expect(sent.removeInvoicePhoto, isFalse);

        // Simpan lagi tanpa menyentuh foto: foto lama tetap.
        await form.saveDraft.execute();
        expect(repo.requests.last.invoicePhoto, isNull);
        expect(repo.requests.last.removeInvoicePhoto, isFalse);
        expect(repo.purchases.single.invoiceMediaId, isNotNull);
      },
    );

    test('ganti foto setelah simpan draf menghapus pesan tersimpan', () async {
      final form = await openForm();
      fill(form);
      await form.saveDraft.execute();
      expect(form.saveDraft.completed, isTrue);
      expect(form.invoicePhotoUnsaved, isFalse);
      picker.next = picked(samplePng);
      await form.pickInvoicePhoto.execute(false);
      expect(form.saveDraft.completed, isFalse);
      expect(form.invoicePhotoUnsaved, isTrue);
    });

    test('kamera memakai batas foto faktur', () async {
      picker.camera = true;
      final form = await openForm();
      expect(form.canTakePhoto, isTrue);
      picker.next = picked(samplePng);
      await form.pickInvoicePhoto.execute(true);
      expect(picker.photoCalls, 1);
      expect(form.invoicePhoto, samplePng);
    });

    test('berkas bukan gambar atau terlalu besar ditolak', () async {
      final form = await openForm();
      picker.next = picked(Uint8List.fromList([1, 2, 3]));
      await form.pickInvoicePhoto.execute(false);
      expect(form.invoicePhoto, isNull);
      expect(form.invoicePhotoRejected, isTrue);
      picker.next = picked(null);
      await form.pickInvoicePhoto.execute(false);
      expect(form.invoicePhotoRejected, isTrue);
      picker.next = picked(samplePng);
      await form.pickInvoicePhoto.execute(false);
      expect(form.invoicePhotoRejected, isFalse);
      // Batal memilih tidak mengubah foto.
      await form.pickInvoicePhoto.execute(false);
      expect(form.invoicePhoto, samplePng);
    });

    test('draf dengan foto: pratinjau dimuat; hapus foto dikirim', () async {
      final first = await openForm();
      fill(first);
      picker.next = picked(samplePng);
      await first.pickInvoicePhoto.execute(false);
      await first.saveDraft.execute();

      final form = await openForm(draftId: first.draftId);
      expect(form.invoicePhoto, samplePng);
      expect(form.invoicePhotoMissing, isFalse);
      form.removeInvoicePhoto();
      expect(form.invoicePhoto, isNull);
      await form.saveDraft.execute();
      expect(repo.requests.last.removeInvoicePhoto, isTrue);
      expect(repo.purchases.single.invoiceMediaId, isNull);
    });

    test('foto draf yang berkasnya belum ada di perangkat', () async {
      final first = await openForm();
      fill(first);
      picker.next = picked(samplePng);
      await first.pickInvoicePhoto.execute(false);
      await first.saveDraft.execute();
      repo.photoFileMissing = true;

      final form = await openForm(draftId: first.draftId);
      expect(form.invoicePhoto, isNull);
      expect(form.invoicePhotoMissing, isTrue);
      // Tidak disentuh: foto tercatat tetap.
      await form.saveDraft.execute();
      expect(repo.requests.last.removeInvoicePhoto, isFalse);
      expect(repo.purchases.single.invoiceMediaId, isNotNull);
    });
  });

  group('detail pembelian', () {
    Future<PurchaseDetailViewModel> received({bool photo = false}) async {
      final form = await openForm();
      fill(form);
      if (photo) {
        picker.next = picked(samplePng);
        await form.pickInvoicePhoto.execute(false);
      }
      form.payInFull();
      await form.receive.execute();
      final vm = PurchaseDetailViewModel(
        repository: repo,
        purchaseId: form.draftId!,
        picker: picker,
      );
      await vm.load.execute();
      return vm;
    }

    test('foto faktur dimuat bersama detail', () async {
      final vm = await received(photo: true);
      expect(vm.detail!.hasInvoicePhoto, isTrue);
      expect(vm.invoicePhoto, samplePng);
    });

    test('lampirkan lalu hapus foto', () async {
      final vm = await received();
      expect(vm.invoicePhoto, isNull);
      picker.next = picked(samplePng);
      await vm.attachInvoicePhoto.execute(false);
      expect(vm.attachInvoicePhoto.completed, isTrue);
      expect(vm.detail!.hasInvoicePhoto, isTrue);
      expect(vm.invoicePhoto, samplePng);

      await vm.removeInvoicePhoto.execute();
      expect(vm.detail!.hasInvoicePhoto, isFalse);
      expect(vm.invoicePhoto, isNull);
    });

    test('berkas ditolak, batal, dan galat repositori', () async {
      final vm = await received();
      picker.next = picked(Uint8List.fromList([1, 2]));
      await vm.attachInvoicePhoto.execute(false);
      expect(vm.invoicePhotoRejected, isTrue);
      expect(vm.detail!.hasInvoicePhoto, isFalse);

      await vm.attachInvoicePhoto.execute(false);
      expect(vm.invoicePhotoRejected, isFalse);
      expect(vm.detail!.hasInvoicePhoto, isFalse);

      picker.next = picked(samplePng);
      repo.nextError = const PurchaseInvoicePhotoInvalid();
      await vm.attachInvoicePhoto.execute(false);
      expect(vm.attachInvoicePhoto.error, isTrue);
      expect(vm.detail!.hasInvoicePhoto, isFalse);
    });

    test('galat lama hilang setelah aksi berikutnya berhasil', () async {
      final vm = await received(photo: true);
      repo.nextError = PurchaseNotFound();
      await vm.removeInvoicePhoto.execute();
      expect(vm.photoError, isA<PurchaseNotFound>());
      picker.next = picked(samplePng);
      await vm.attachInvoicePhoto.execute(false);
      expect(vm.photoError, isNull);
      expect(vm.invoicePhoto, samplePng);

      picker.throwNext = Exception('izin kamera ditolak');
      await vm.attachInvoicePhoto.execute(true);
      expect(vm.photoPickFailed, isTrue);
      await vm.removeInvoicePhoto.execute();
      expect(vm.photoPickFailed, isFalse);
    });

    test('centang Ubah harga tetap setelah foto berubah', () async {
      final vm = await received();
      final variant = vm.suggestions.first.item.variantId;
      vm.toggle(variant, true);
      picker.next = picked(samplePng);
      await vm.attachInvoicePhoto.execute(false);
      expect(vm.checked, contains(variant));
    });
  });
}
