import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('roundTotal', () {
    test('tanpa pembulatan', () {
      expect(
        roundTotal(const Money(12345), TotalRounding.none),
        const Money(12345),
      );
    });

    test('ke Rp 100 terdekat, Rp 50 ke atas', () {
      const r = TotalRounding.nearest100;
      expect(roundTotal(const Money(12349), r), const Money(12300));
      expect(roundTotal(const Money(12350), r), const Money(12400));
      expect(roundTotal(const Money(12300), r), const Money(12300));
      expect(roundTotal(const Money(49), r), Money.zero);
    });

    test('ke Rp 500 terdekat, Rp 250 ke atas', () {
      const r = TotalRounding.nearest500;
      expect(roundTotal(const Money(12249), r), const Money(12000));
      expect(roundTotal(const Money(12250), r), const Money(12500));
      expect(roundTotal(const Money(12750), r), const Money(13000));
    });

    test('nol dan negatif tidak dibulatkan', () {
      expect(roundTotal(Money.zero, TotalRounding.nearest500), Money.zero);
      expect(
        roundTotal(const Money(-120), TotalRounding.nearest100),
        const Money(-120),
      );
    });
  });

  group('SalesRules', () {
    test('bawaan: stok minus boleh, tanpa pembulatan', () {
      const rules = SalesRules();
      expect(rules.allowNegativeStock, isTrue);
      expect(rules.rounding, TotalRounding.none);
    });

    test('JSON bolak-balik', () {
      const rules = SalesRules(
        allowNegativeStock: false,
        rounding: TotalRounding.nearest500,
      );
      final json = rules.toJson();
      expect(json, {
        'allowNegativeStock': false,
        'rounding': 'nearest500',
        'discountNeedsPin': true,
      });
      expect(SalesRules.fromJson(json), rules);
    });

    test('JSON rusak memakai bawaan per kolom', () {
      expect(SalesRules.fromJson('x'), const SalesRules());
      expect(
        SalesRules.fromJson({'allowNegativeStock': 'ya', 'rounding': 'aneh'}),
        const SalesRules(),
      );
      expect(
        SalesRules.fromJson({'rounding': 'nearest100'}),
        const SalesRules(rounding: TotalRounding.nearest100),
      );
    });
  });

  group('fnbCharges', () {
    test('pajak eksklusif + pembulatan', () {
      // 45.500 + service 5% 2.275 = 47.775; PB1 10% 4.778 → 52.553.
      final c = fnbCharges(
        const Money(45500),
        dineIn: true,
        serviceBp: const BasisPoints(500),
        taxBp: const BasisPoints(1000),
        rounding: TotalRounding.nearest100,
      );
      expect(c.service, const Money(2275));
      expect(c.tax, const Money(4778));
      expect(c.rounding, const Money(47));
      expect(c.total, const Money(52600));
      expect(c.taxInclusive, isFalse);
    });

    test(
      'harga sudah termasuk pajak: PB1 dipisahkan, total tidak bertambah',
      () {
        final c = fnbCharges(
          const Money(110000),
          dineIn: false,
          serviceBp: const BasisPoints(500),
          taxBp: const BasisPoints(1000),
          taxInclusive: true,
        );
        expect(c.service, Money.zero);
        expect(c.tax, const Money(10000));
        expect(c.total, const Money(110000));
        expect(c.taxInclusive, isTrue);
      },
    );

    test('termasuk pajak dengan service: pajak dari subtotal + service', () {
      // 100.000 + service 10% = 110.000; PB1 termasuk 10% = 10.000.
      final c = fnbCharges(
        const Money(100000),
        dineIn: true,
        serviceBp: const BasisPoints(1000),
        taxBp: const BasisPoints(1000),
        taxInclusive: true,
        rounding: TotalRounding.nearest500,
      );
      expect(c.service, const Money(10000));
      expect(c.tax, const Money(10000));
      expect(c.rounding, Money.zero);
      expect(c.total, const Money(110000));
    });

    test('pajak termasuk dibulatkan setengah ke atas', () {
      // 10.050 × 1.000 / 11.000 = 913,6 → 914.
      final c = fnbCharges(
        const Money(10050),
        dineIn: false,
        serviceBp: BasisPoints.zero,
        taxBp: const BasisPoints(1000),
        taxInclusive: true,
      );
      expect(c.tax, const Money(914));
    });
  });

  group('profil toko dan cabang', () {
    test('nama usaha wajib, maks 60', () {
      expect(storeNameIssue(''), ProfileIssue.required);
      expect(storeNameIssue('  '), ProfileIssue.required);
      expect(storeNameIssue('a' * 61), ProfileIssue.tooLong);
      expect(storeNameIssue('Warung Contoh'), isNull);
    });

    test('cabang: nama wajib, alamat maks 160, telepon', () {
      expect(outletProfileIssues(name: '', address: '', phone: ''), {
        OutletProfileField.name: ProfileIssue.required,
      });
      expect(
        outletProfileIssues(
          name: 'Cabang Pusat',
          address: 'a' * 161,
          phone: '0812-3456 7890',
        ),
        {OutletProfileField.address: ProfileIssue.tooLong},
      );
      expect(outletProfileIssues(name: 'Pusat', address: '', phone: 'telp 1'), {
        OutletProfileField.phone: ProfileIssue.invalidPhone,
      });
      expect(outletProfileIssues(name: 'Pusat', address: '', phone: '1' * 21), {
        OutletProfileField.phone: ProfileIssue.tooLong,
      });
      expect(
        outletProfileIssues(
          name: 'Pusat',
          address: 'Jl. Melati 1',
          phone: '+62 812-3456',
        ),
        isEmpty,
      );
    });
  });

  group('laporan: pembulatan dan pajak termasuk', () {
    ReportSale sale({
      int subtotal = 110000,
      int tax = 0,
      bool inclusive = false,
      int rounding = 0,
    }) {
      final total = subtotal + (inclusive ? 0 : tax) + rounding;
      return ReportSale(
        staffKey: 'sari',
        subtotal: Money(subtotal),
        tierDiscount: Money.zero,
        service: Money.zero,
        tax: Money(tax),
        taxInclusive: inclusive,
        rounding: Money(rounding),
        total: Money(total),
        credit: false,
        paidAtSale: Money(total),
        payments: const [],
        lines: const [],
      );
    }

    test('kontribusi bersih tanpa pajak termasuk, dengan pembulatan', () {
      expect(
        sale(tax: 10000, inclusive: true, rounding: 0).netContribution,
        const Money(100000),
      );
      expect(sale(rounding: -50).netContribution, const Money(109950));
      expect(sale(tax: 11000).netContribution, const Money(110000));
    });

    test('laba rugi memisahkan pajak termasuk dan pembulatan', () {
      final pl = ProfitAndLoss.compute(
        sales: [
          sale(tax: 10000, inclusive: true),
          sale(subtotal: 20050, rounding: 50),
          sale(subtotal: 10000, tax: 1000),
        ],
        returns: const [],
        expenses: const [],
        stockAdjustment: Money.zero,
      );
      expect(pl.grossSales, const Money(140050));
      expect(pl.includedTax, const Money(10000));
      expect(pl.rounding, const Money(50));
      expect(pl.taxCollected, const Money(11000));
      expect(pl.netSales, const Money(130100));
    });
  });

  test('TotalRounding.byStep: kelipatan tersimpan, 0/tak dikenal = null', () {
    expect(TotalRounding.byStep(1), TotalRounding.none);
    expect(TotalRounding.byStep(100), TotalRounding.nearest100);
    expect(TotalRounding.byStep(500), TotalRounding.nearest500);
    expect(TotalRounding.byStep(0), isNull);
    expect(TotalRounding.byStep(250), isNull);
  });
}
