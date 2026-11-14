import 'dart:math';

import 'setup.dart' show normalizeCode;

/// Simbologi barcode untuk label produk (F1-07e).
enum BarcodeSymbology { ean13, ean8, upcA, code128 }

final _digits = RegExp(r'^\d+$');

/// Digit periksa EAN/UPC untuk [body] (kode tanpa digit terakhir): bobot 3
/// dan 1 bergantian dari kanan.
int eanCheckDigit(String body) {
  var sum = 0;
  for (var i = 0; i < body.length; i++) {
    final digit = body.codeUnitAt(body.length - 1 - i) - 0x30;
    sum += i.isEven ? digit * 3 : digit;
  }
  return (10 - sum % 10) % 10;
}

bool _validEan(String code) =>
    eanCheckDigit(code.substring(0, code.length - 1)) ==
    code.codeUnitAt(code.length - 1) - 0x30;

/// Simbologi untuk mencetak [code] di label: EAN-13 / EAN-8 / UPC-A bila
/// panjang dan digit periksanya cocok, selain itu Code 128 untuk ASCII
/// cetak (32–126). `null` bila kode kosong atau memuat karakter lain.
BarcodeSymbology? labelSymbology(String code) {
  if (code.isEmpty) return null;
  if (_digits.hasMatch(code) && _validEan(code)) {
    switch (code.length) {
      case 13:
        return BarcodeSymbology.ean13;
      case 8:
        return BarcodeSymbology.ean8;
      case 12:
        return BarcodeSymbology.upcA;
    }
  }
  final printable = code.codeUnits.every((c) => c >= 32 && c <= 126);
  return printable ? BarcodeSymbology.code128 : null;
}

final _ean13 = RegExp(r'^\d{13}$');

/// Kunci pembanding barcode (F1-07h): [normalizeCode], lalu EAN-13 berawalan
/// `0` dengan digit periksa benar disamakan dengan UPC-A 12 digit (sebagian
/// pemindai membaca UPC-A sebagai 13 digit).
String barcodeKey(String raw) {
  final code = normalizeCode(raw);
  if (code.startsWith('0') && _ean13.hasMatch(code) && _validEan(code)) {
    return code.substring(1);
  }
  return code;
}

/// `true` bila [stored] dan [scanned] terisi dan kunci barcodenya sama.
bool sameBarcode(String? stored, String scanned) =>
    stored != null &&
    stored.trim().isNotEmpty &&
    barcodeKey(stored) == barcodeKey(scanned);

/// EAN-13 toko (F1-07h): awalan `20` (rentang GS1 pemakaian internal) +
/// 10 digit acak + digit periksa. Diulang selama [isTaken] menolak kode.
String generateStoreEan13(
  Random random, {
  bool Function(String code)? isTaken,
}) {
  while (true) {
    final body = StringBuffer('20');
    for (var i = 0; i < 10; i++) {
      body.write(random.nextInt(10));
    }
    final code = '$body${eanCheckDigit(body.toString())}';
    if (isTaken == null || !isTaken(code)) return code;
  }
}
