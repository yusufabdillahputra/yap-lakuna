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
        'transferAccount': '',
      });
      expect(SalesRules.fromJson(json), rules);
    });

    test('rekening transfer (F1-05c): bawaan kosong, dipangkas', () {
      expect(const SalesRules().transferAccount, '');
      const rules = SalesRules(transferAccount: 'BCA 123-456-7890');
      expect(rules.toJson()['transferAccount'], 'BCA 123-456-7890');
      expect(SalesRules.fromJson(rules.toJson()), rules);
      expect(
        SalesRules.fromJson({'transferAccount': '  BCA 1  '}).transferAccount,
        'BCA 1',
      );
      expect(SalesRules.fromJson({'transferAccount': 12}).transferAccount, '');
      // JSON lama tanpa kunci rekening.
      expect(
        SalesRules.fromJson({
          'allowNegativeStock': true,
          'rounding': 'none',
          'discountNeedsPin': true,
        }).transferAccount,
        '',
      );
      // Nilai tersimpan terlalu panjang dibatasi 100 karakter.
      expect(
        SalesRules.fromJson({'transferAccount': 'z' * 150})
            .transferAccount
            .length,
        100,
      );
      expect(rules == const SalesRules(), isFalse);
      expect(
        rules.copyWith(transferAccount: 'Mandiri 9').transferAccount,
        'Mandiri 9',
      );
      expect(ProfileLimits.transferAccount, 100);
    });

    test('beberapa rekening (F1-05f): satu per baris, maks 3', () {
      expect(ProfileLimits.transferAccountLines, 3);
      expect(
        normalizeTransferAccounts('  BCA 1 \n\n  Mandiri 2\r\n \n'),
        'BCA 1\nMandiri 2',
      );
      expect(normalizeTransferAccounts('   '), '');
      expect(normalizeTransferAccounts('A\rB\u2028C'), 'A\nB\nC');
      const two = SalesRules(transferAccount: 'BCA 1\nMandiri 2');
      expect(two.transferAccounts, ['BCA 1', 'Mandiri 2']);
      expect(const SalesRules().transferAccounts, isEmpty);
      expect(const SalesRules(transferAccount: 'BCA 1').transferAccounts, [
        'BCA 1',
      ]);
      // Data tersimpan dirapikan: baris kosong dibuang, tiap baris
      // dibatasi 100 karakter, maks 3 rekening.
      final stored = SalesRules.fromJson({
        'transferAccount': ' A \n\n${'z' * 150}\nC\nD',
      });
      expect(stored.transferAccounts, ['A', 'z' * 100, 'C']);
      expect(stored.transferAccount, 'A\n${'z' * 100}\nC');

      expect(transferAccountIssue(''), isNull);
      expect(transferAccountIssue('A\nB\n\nC\n'), isNull);
      expect(transferAccountIssue('A\nB\nC\nD'), TransferAccountIssue.tooMany);
      expect(transferAccountIssue('z' * 100), isNull);
      expect(
        transferAccountIssue('A\n${'z' * 101}'),
        TransferAccountIssue.tooLong,
      );
      // Spasi di ujung baris tidak dihitung.
      expect(transferAccountIssue('  ${'z' * 100}  '), isNull);
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

  group('target margin (F1-16d)', () {
    test('bawaan tanpa target; JSON bolak-balik; kunci hanya bila diatur', () {
      expect(const SalesRules().targetMarginBp, isNull);
      expect(
        const SalesRules().toJson().containsKey('targetMarginBp'),
        isFalse,
      );
      const rules = SalesRules(targetMarginBp: 2500);
      expect(rules.toJson()['targetMarginBp'], 2500);
      expect(SalesRules.fromJson(rules.toJson()), rules);
      expect(rules, isNot(const SalesRules()));
      expect(rules.hashCode, isNot(const SalesRules().hashCode));
    });

    test('data rusak dibaca tanpa target', () {
      for (final bad in [0, 99, 2550, 9901, 10000, -2500, '2500', 25.5, true]) {
        expect(
          SalesRules.fromJson({'targetMarginBp': bad}).targetMarginBp,
          isNull,
          reason: '$bad',
        );
      }
      expect(SalesRules.fromJson({'targetMarginBp': 100}).targetMarginBp, 100);
      expect(
        SalesRules.fromJson({'targetMarginBp': 9900}).targetMarginBp,
        9900,
      );
    });

    test('copyWith bisa mengosongkan target', () {
      const rules = SalesRules(targetMarginBp: 2500);
      expect(
        rules.copyWith(rounding: TotalRounding.nearest100).targetMarginBp,
        2500,
      );
      expect(rules.copyWith(targetMarginBp: () => null).targetMarginBp, isNull);
      expect(
        const SalesRules().copyWith(targetMarginBp: () => 3000).targetMarginBp,
        3000,
      );
    });

    test('isian target: kosong atau 1–99', () {
      expect(targetMarginIssue(''), isNull);
      expect(targetMarginIssue('  '), isNull);
      expect(targetMarginIssue('1'), isNull);
      expect(targetMarginIssue('25'), isNull);
      expect(targetMarginIssue(' 99 '), isNull);
      for (final bad in ['0', '00', '100', '250', '-5', '2,5', 'x']) {
        expect(
          targetMarginIssue(bad),
          TargetMarginIssue.outOfRange,
          reason: bad,
        );
      }
      expect(targetMarginBpOf(''), isNull);
      expect(targetMarginBpOf(' 25 '), 2500);
      expect(targetMarginBpOf('07'), 700);
      expect(targetMarginBpOf('100'), isNull);
      expect(targetMarginText(null), '');
      expect(targetMarginText(2500), '25');
    });

    test('selisih poin di bawah target', () {
      expect(marginGapBp(2180, 2500), 320);
      expect(marginGapBp(2500, 2500), 0);
      expect(marginGapBp(3100, 2500), 0);
      expect(marginGapBp(-500, 2500), 3000);
      // Dibandingkan pada 0,1 poin seperti tampilan: 24,96% = 25,0%.
      expect(marginGapBp(2496, 2500), 0);
      expect(marginGapBp(2494, 2500), 10);
      expect(marginGapBp(2185, 2500), 310);
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
