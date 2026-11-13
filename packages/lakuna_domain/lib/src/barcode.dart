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
