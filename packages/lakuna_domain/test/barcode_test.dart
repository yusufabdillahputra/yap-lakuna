import 'dart:math';

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

  group('barcodeKey (F1-07h)', () {
    test('EAN-13 awalan 0 dengan digit periksa benar = UPC-A', () {
      expect(barcodeKey('0036000291452'), '036000291452');
      expect(barcodeKey(' 036000291452 '), '036000291452');
      expect(sameBarcode('036000291452', '0036000291452'), isTrue);
      expect(sameBarcode('0036000291452', '036000291452'), isTrue);
    });

    test('kode lain hanya dinormalkan', () {
      expect(barcodeKey('0036000291453'), '0036000291453');
      expect(barcodeKey('8990001000012'), '8990001000012');
      expect(barcodeKey(' kop-sch '), 'KOP-SCH');
      expect(barcodeKey('0ABCDEFGHIJKL'), '0ABCDEFGHIJKL');
      expect(sameBarcode('kop-sch', 'KOP-SCH'), isTrue);
      expect(sameBarcode('8990001000012', '899000100001'), isFalse);
      expect(sameBarcode(null, '899'), isFalse);
      expect(sameBarcode('', ''), isFalse);
    });
  });

  group('generateStoreEan13 (F1-07h)', () {
    test('EAN-13 awalan 20 dengan digit periksa benar', () {
      final random = Random(7);
      for (var i = 0; i < 50; i++) {
        final code = generateStoreEan13(random);
        expect(code, hasLength(13));
        expect(code, startsWith('20'));
        expect(labelSymbology(code), BarcodeSymbology.ean13);
      }
    });

    test('mengulang sampai kode belum dipakai', () {
      final first = generateStoreEan13(Random(1));
      final code = generateStoreEan13(Random(1), isTaken: (c) => c == first);
      expect(code, isNot(first));
      expect(labelSymbology(code), BarcodeSymbology.ean13);
    });

    test('berhenti dengan StateError bila semua kode ditolak', () {
      expect(
        () => generateStoreEan13(Random(1), isTaken: (_) => true),
        throwsStateError,
      );
    });
  });

  group('barcodeTooDense (F1-07i)', () {
    test('garis lebih kecil dari 0,25 mm ditandai', () {
      // SKU 14 karakter Code 128 = 189 modul.
      expect(barcodeTooDense(189, 32), isTrue, reason: '0,17 mm');
      expect(barcodeTooDense(189, 42), isTrue, reason: '0,22 mm');
      expect(barcodeTooDense(189, 58), isFalse, reason: '0,31 mm');
      // EAN-13 = 95 modul.
      expect(barcodeTooDense(95, 32), isFalse, reason: '0,34 mm');
      expect(barcodeTooDense(128, 32), isFalse, reason: 'tepat 0,25 mm');
      expect(barcodeTooDense(0, 32), isFalse);
    });
  });
}
