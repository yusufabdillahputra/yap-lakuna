import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

/// Pembacaan QR offline dari gambar stiker QRIS (F1-18g). Fixture dibuat
/// sekali dengan paket Python `qrcode` (QRIS statis NMID ID10234567890).
void main() {
  Uint8List fixture(String name) =>
      File('test/fixtures/$name').readAsBytesSync();

  for (final name in ['qris-statis.png', 'qris-statis.jpg']) {
    test('QR QRIS statis terbaca dari $name', () {
      final read = readQrisFromImage(fixture(name));
      expect(read.status, QrisQrStatus.qris);
      final payload = read.payload!;
      expect(payload.isStatic, isTrue);
      expect(payload.nmid, 'ID10234567890');
      expect(payload.merchantName, 'WARUNG CONTOH');
      expect(payload.terminalLabel, 'A01');
    });
  }

  // Ekspor QR umum: 1-bit, 16-bit, dan latar transparan (RGB 0, alfa 0).
  for (final name in [
    'qris-1bit.png',
    'qris-16bit.png',
    'qris-transparan.png',
  ]) {
    test('QR QRIS terbaca dari $name', () {
      final read = readQrisFromImage(fixture(name));
      expect(read.status, QrisQrStatus.qris);
      expect(read.payload!.nmid, 'ID10234567890');
    });
  }

  test('gambar tanpa QR dan bukan gambar: tidak ditemukan', () {
    expect(
      readQrisFromImage(fixture('tanpa-qr.png')).status,
      QrisQrStatus.notFound,
    );
    expect(
      readQrisFromImage(Uint8List.fromList('bukan gambar'.codeUnits)).status,
      QrisQrStatus.notFound,
    );
  });

  test('teks QR bukan QRIS', () {
    expect(
      QrisQrRead.fromText('https://warung.example').status,
      QrisQrStatus.notQris,
    );
  });
}
