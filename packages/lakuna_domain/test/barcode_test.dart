import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

/// F1-07e: simbologi label barcode.
void main() {
  group('eanCheckDigit', () {
    test('menghitung digit periksa EAN/UPC', () {
      expect(eanCheckDigit('899000100001'), 2);
      expect(eanCheckDigit('9638507'), 4);
      expect(eanCheckDigit('03600029145'), 2);
    });
  });

  group('labelSymbology', () {
    test('EAN-13, EAN-8, UPC-A dengan digit periksa benar', () {
      expect(labelSymbology('8990001000012'), BarcodeSymbology.ean13);
      expect(labelSymbology('96385074'), BarcodeSymbology.ean8);
      expect(labelSymbology('036000291452'), BarcodeSymbology.upcA);
    });

    test('digit periksa salah atau panjang lain → Code 128', () {
      expect(labelSymbology('8990001000013'), BarcodeSymbology.code128);
      expect(labelSymbology('96385075'), BarcodeSymbology.code128);
      expect(labelSymbology('8990001'), BarcodeSymbology.code128);
      expect(labelSymbology('KOP-SCH'), BarcodeSymbology.code128);
      expect(labelSymbology('a b/c'), BarcodeSymbology.code128);
    });

    test('kosong atau di luar ASCII cetak → tidak bisa dicetak', () {
      expect(labelSymbology(''), isNull);
      expect(labelSymbology('Café'), isNull);
      expect(labelSymbology('a\tb'), isNull);
    });
  });
}
