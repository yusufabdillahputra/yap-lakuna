import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/ui/settings/payment_settings_view_model.dart';

import '../../testing/fake_payment_settings_repository.dart';

/// Header PNG (tanpa data gambar) berukuran [w] × [h].
Uint8List _png(int w, int h) {
  int b(int v, int s) => (v >> s) & 0xFF;
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, //
    b(w, 24), b(w, 16), b(w, 8), b(w, 0), //
    b(h, 24), b(h, 16), b(h, 8), b(h, 0), //
    8, 6, 0, 0, 0, 0, 0, 0, 0, 0,
  ]);
}

String _tlv(String tag, String value) =>
    '$tag${value.length.toString().padLeft(2, '0')}$value';

/// QRIS statis dengan NMID dan nama merchant tertentu (CRC benar).
QrisQrRead _qris(String nmid, String name) {
  final body = [
    _tlv('00', '01'),
    _tlv('01', '11'),
    _tlv('51', _tlv('00', qrisGuid) + _tlv('02', nmid)),
    _tlv('59', name),
    _tlv('62', _tlv('07', 'A01')),
    '6304',
  ].join();
  return QrisQrRead.fromText(body + qrisCrc16(body));
}

/// Balapan baca QR di Pengaturan › QRIS statis (review F1-18g).
void main() {
  late FakePaymentSettingsRepository repo;
  late FakeImagePicker picker;
  late PaymentSettingsViewModel vm;

  Future<void> open({QrisConfig? initial}) async {
    repo = FakePaymentSettingsRepository(initial: initial)..holdQr = true;
    picker = FakeImagePicker();
    vm = PaymentSettingsViewModel(repository: repo, picker: picker);
    await vm.load.execute();
  }

  Future<void> pick(int width) async {
    final bytes = _png(width, 1528);
    picker.next = PickedImage(name: 'q.png', size: bytes.length, bytes: bytes);
    await vm.pickImage.execute();
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test(
    'pilih gambar lagi saat QR lama masih dibaca: hasil lama dibuang',
    () async {
      await open();
      await pick(1080);
      await pick(1081);
      expect(repo.pendingQr, hasLength(2));
      repo.pendingQr[1].complete(_qris('ID2222', 'BARU'));
      await settle();
      repo.pendingQr[0].complete(_qris('ID1111', 'LAMA'));
      await settle();
      expect(vm.qr!.payload!.nmid, 'ID2222');
      expect(vm.draft.nmid, 'ID2222');
      expect(vm.draft.merchantName, 'BARU');
    },
  );

  test('Batal saat QR dibaca: isian tidak terisi belakangan', () async {
    await open();
    await pick(1080);
    vm.cancel();
    repo.pendingQr.single.complete(_qris('ID1111', 'LAMA'));
    await settle();
    expect(vm.draft.nmid, '');
    expect(vm.qr, isNull);
    expect(vm.qrReading, isFalse);
  });

  test('Simpan menunggu baca QR gambar baru', () async {
    await open();
    await pick(1080);
    expect(vm.qrReading, isTrue);
    expect(vm.canSave, isFalse);
    repo.pendingQr.single.complete(_qris('ID1111', 'LAMA'));
    await settle();
    expect(vm.canSave, isTrue);
  });

  test(
    'simpan isian saat gambar tersimpan dibaca: hasil QR tetap tampil',
    () async {
      await open(
        initial: QrisConfig(
          settings: const QrisStaticSettings(),
          imageBytes: _png(1080, 1528),
        ),
      );
      expect(vm.qrReading, isTrue);
      vm.setSettlementNote('BCA');
      await vm.save.execute();
      repo.pendingQr.single.complete(_qris('ID1111', 'LAMA'));
      await settle();
      expect(vm.qr!.payload!.nmid, 'ID1111');
      expect(vm.qrReading, isFalse);
      // Gambar tersimpan tidak mengisi isian otomatis.
      expect(vm.draft.nmid, '');
    },
  );

  test('gambar baru tersimpan: baca lama gambar tersimpan dibuang', () async {
    await open(
      initial: QrisConfig(
        settings: const QrisStaticSettings(),
        imageBytes: _png(1080, 1528),
      ),
    );
    await pick(1081);
    repo.pendingQr[1].complete(_qris('ID2222', 'BARU'));
    await settle();
    await vm.save.execute();
    repo.pendingQr[0].complete(_qris('ID1111', 'LAMA'));
    await settle();
    expect(vm.qr!.payload!.nmid, 'ID2222');
  });

  test('isi otomatis hanya menyegarkan field yang diisi', () async {
    await open();
    vm.setTerminalCode('K01');
    final revision = vm.revision;
    await pick(1080);
    repo.pendingQr.single.complete(_qris('ID1111', 'LAMA'));
    await settle();
    expect(vm.revision, revision);
    expect(vm.fillRevision(QrisAutoField.nmid), 1);
    expect(vm.fillRevision(QrisAutoField.merchantName), 1);
    expect(vm.fillRevision(QrisAutoField.terminalCode), 0);
    expect(vm.draft.terminalCode, 'K01');
  });

  test('ditutup saat QR dibaca: tidak melempar', () async {
    await open();
    await pick(1080);
    vm.dispose();
    repo.pendingQr.single.complete(_qris('ID1111', 'LAMA'));
    await settle();
  });
}
