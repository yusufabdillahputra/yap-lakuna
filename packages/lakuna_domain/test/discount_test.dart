import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('ManualDiscount', () {
    test('persen dibulatkan setengah ke atas', () {
      const d = ManualDiscount.percent(BasisPoints(500));
      expect(d.cut(const Money(253000)), const Money(12650));
      // 10% dari 9.245 = 924,5 → 925.
      expect(
        const ManualDiscount.percent(BasisPoints(1000)).cut(const Money(9245)),
        const Money(925),
      );
      expect(
        const ManualDiscount.percent(BasisPoints.full).cut(const Money(7000)),
        const Money(7000),
      );
    });

    test('rupiah tidak melebihi dasar', () {
      const d = ManualDiscount.amount(Money(2000));
      expect(d.cut(const Money(5000)), const Money(2000));
      expect(d.issue(const Money(5000)), isNull);
      expect(d.issue(const Money(1500)), DiscountIssue.tooLarge);
    });

    test('nilai tidak sah', () {
      expect(
        const ManualDiscount.percent(BasisPoints.zero).issue(const Money(100)),
        DiscountIssue.invalid,
      );
      expect(
        const ManualDiscount.percent(BasisPoints(10001))
            .issue(const Money(100)),
        DiscountIssue.invalid,
      );
      expect(
        const ManualDiscount.amount(Money.zero).issue(const Money(100)),
        DiscountIssue.invalid,
      );
    });

    test('kesamaan dan bp untuk label', () {
      expect(
        const ManualDiscount.percent(BasisPoints(500)),
        const ManualDiscount.percent(BasisPoints(500)),
      );
      expect(const ManualDiscount.percent(BasisPoints(500)).bp, 500);
      expect(const ManualDiscount.amount(Money(500)).bp, 0);
    });
  });

  group('parseDiscountValue', () {
    test('persen dua desimal, rupiah bulat dengan titik ribuan', () {
      expect(
        parseDiscountValue('5', DiscountKind.percent),
        const ManualDiscount.percent(BasisPoints(500)),
      );
      expect(
        parseDiscountValue('12,5', DiscountKind.percent),
        const ManualDiscount.percent(BasisPoints(1250)),
      );
      expect(
        parseDiscountValue('12.500', DiscountKind.amount),
        const ManualDiscount.amount(Money(12500)),
      );
      expect(parseDiscountValue('', DiscountKind.amount), isNull);
      expect(parseDiscountValue('abc', DiscountKind.percent), isNull);
      expect(parseDiscountValue('5,555', DiscountKind.percent), isNull);
    });
  });

  test('SalesRules: PIN diskon bawaan hidup, JSON bolak-balik', () {
    expect(const SalesRules().discountNeedsPin, isTrue);
    const off = SalesRules(discountNeedsPin: false);
    expect(off.toJson()['discountNeedsPin'], false);
    expect(SalesRules.fromJson(off.toJson()), off);
    expect(SalesRules.fromJson({'discountNeedsPin': 1}), const SalesRules());
  });

  test('laporan: diskon manual mengurangi penjualan bersih', () {
    const sale = ReportSale(
      staffKey: 'sari',
      subtotal: Money(100000),
      tierDiscount: Money(2000),
      manualDiscount: Money(4900),
      service: Money.zero,
      tax: Money.zero,
      total: Money(93100),
      credit: false,
      paidAtSale: Money(93100),
      payments: [],
      lines: [],
    );
    expect(sale.netContribution, const Money(93100));
    final pl = ProfitAndLoss.compute(
      sales: const [sale],
      returns: const [],
      expenses: const [],
      stockAdjustment: Money.zero,
    );
    expect(pl.discount, const Money(6900));
    expect(pl.netSales, const Money(93100));
  });
}
