import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Money', () {
    test('format rupiah gaya Indonesia dan Inggris', () {
      expect(const Money(0).formatIdr(), 'Rp 0');
      expect(const Money(12500).formatIdr(), 'Rp 12.500');
      expect(const Money(1234567).formatIdr(), 'Rp 1.234.567');
      expect(const Money(-3000).formatIdr(), '-Rp 3.000');
      expect(const Money(36000).formatPlain(), '36.000');
      expect(const Money(12500).formatEn(), 'IDR 12,500');
    });

    test('basis poin dibulatkan setengah menjauhi nol', () {
      // 11% dari 12.345 = 1.357,95 -> 1.358
      expect(
        const Money(12345).applyBp(const BasisPoints(1100)),
        const Money(1358),
      );
      expect(const Money(10).applyBp(BasisPoints.percent(5)), const Money(1));
      expect(const Money(-10).applyBp(BasisPoints.percent(5)), const Money(-1));
      expect(const Money(9).applyBp(BasisPoints.percent(5)), const Money(0));
    });

    test('kali mili-satuan untuk barang timbang', () {
      expect(const Money(30000).timesMilli(250), const Money(7500));
      expect(const Money(4500).timesMilli(3000), const Money(13500));
      expect(const Money(1000).timesMilli(333), const Money(333));
    });

    test('aritmetika dan perbandingan', () {
      expect(const Money(5) + const Money(7), const Money(12));
      expect(const Money(5) - const Money(7), const Money(-2));
      expect(-const Money(5), const Money(-5));
      expect(const Money(3) < const Money(4), isTrue);
      expect(
        Money.sum([const Money(1), const Money(2), const Money(3)]),
        const Money(6),
      );
      expect(const Money(-1).isNegative, isTrue);
    });
  });

  group('Qty', () {
    test('satuan bulat dan konversi ke satuan dasar', () {
      expect(Qty.units(3).milli, 3000);
      expect(Qty.units(2).toBaseUnit(24000), Qty.units(48));
      expect(Qty.one.toBaseUnit(1000), Qty.one);
      expect(Qty.units(1) + const Qty(250), const Qty(1250));
      expect(Qty.units(1) - Qty.units(3), Qty.units(-2));
      expect(Qty.units(1).isPositive, isTrue);
    });
  });
}
