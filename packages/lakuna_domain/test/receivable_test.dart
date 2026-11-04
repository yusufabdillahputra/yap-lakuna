import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('saleOutstanding', () {
    test('total − DP − alokasi − pengurang retur', () {
      expect(
        saleOutstanding(
          total: const Money(214000),
          paidAtSale: const Money(50000),
          allocated: const Money(64000),
          debtReduction: const Money(20000),
        ),
        const Money(80000),
      );
    });

    test('nota lunas = 0, tidak pernah negatif', () {
      expect(
        saleOutstanding(
          total: const Money(10000),
          paidAtSale: const Money(10000),
        ),
        Money.zero,
      );
      expect(
        saleOutstanding(
          total: const Money(10000),
          paidAtSale: const Money(5000),
          allocated: const Money(9000),
        ),
        Money.zero,
      );
    });
  });

  group('creditIssue', () {
    final today = DateTime.utc(2026, 11, 3);

    CreditIssue? check({
      int limit = 2000000,
      int outstanding = 1150000,
      int total = 214000,
      int down = 50000,
      DateTime? dueOn,
    }) => creditIssue(
      limit: Money(limit),
      outstanding: Money(outstanding),
      total: Money(total),
      downPayment: Money(down),
      dueOn: dueOn ?? DateTime.utc(2026, 11, 17),
      today: today,
    );

    test('sah bila dalam limit', () {
      expect(check(), isNull);
      // Tepat di limit masih boleh.
      expect(check(outstanding: 1836000), isNull);
    });

    test('melebihi limit, limit nol', () {
      expect(check(outstanding: 1836001), CreditIssue.overLimit);
      expect(check(limit: 0, outstanding: 0), CreditIssue.noLimit);
    });

    test('DP negatif atau tidak kurang dari total', () {
      expect(check(down: -1), CreditIssue.downPayment);
      expect(check(down: 214000), CreditIssue.downPayment);
    });

    test('jatuh tempo sebelum hari ini', () {
      expect(check(dueOn: DateTime.utc(2026, 11, 2)), CreditIssue.dueOn);
      expect(check(dueOn: today), isNull);
    });
  });

  group('alokasi', () {
    final open = [
      OpenReceivable(id: 'a', outstanding: const Money(500000)),
      OpenReceivable(id: 'b', outstanding: const Money(300000)),
      OpenReceivable(id: 'c', outstanding: const Money(350000)),
    ];

    test('nota terlama dulu', () {
      expect(allocateOldestFirst(const Money(800000), open), {
        'a': const Money(500000),
        'b': const Money(300000),
      });
      expect(allocateOldestFirst(const Money(100), open), {
        'a': const Money(100),
      });
      expect(allocateOldestFirst(Money.zero, open), isEmpty);
    });

    test('jumlah melebihi total piutang terpotong', () {
      expect(
        Money.sum(allocateOldestFirst(const Money(9999999), open).values),
        const Money(1150000),
      );
    });

    test('validasi pembayaran dan alokasi manual', () {
      expect(validateDebtPayment(Money.zero, open), DebtPaymentIssue.amount);
      expect(
        validateDebtPayment(const Money(1150001), open),
        DebtPaymentIssue.overOutstanding,
      );
      expect(validateDebtPayment(const Money(1150000), open), isNull);
      expect(
        validateDebtPayment(
          const Money(800000),
          open,
          manual: {
            'c': const Money(350000),
            'b': const Money(300000),
            'a': const Money(150000),
          },
        ),
        isNull,
      );
      expect(
        validateDebtPayment(
          const Money(800000),
          open,
          manual: {'c': const Money(350000), 'b': const Money(300000)},
        ),
        DebtPaymentIssue.allocationTotal,
      );
      expect(
        validateDebtPayment(
          const Money(400000),
          open,
          manual: {'b': const Money(400000)},
        ),
        DebtPaymentIssue.allocationOverRemaining,
      );
      expect(
        validateDebtPayment(
          const Money(100),
          open,
          manual: {'x': const Money(100)},
        ),
        DebtPaymentIssue.allocationUnknown,
      );
      expect(
        validateDebtPayment(
          const Money(100),
          open,
          manual: {'a': const Money(200), 'b': const Money(-100)},
        ),
        DebtPaymentIssue.allocationNegative,
      );
    });
  });

  test('isOverdue memakai tanggal kalender', () {
    final today = DateTime.utc(2026, 11, 3);
    expect(isOverdue(DateTime.utc(2026, 11, 2), today), isTrue);
    expect(isOverdue(DateTime.utc(2026, 11, 3), today), isFalse);
    expect(isOverdue(null, today), isFalse);
  });

  test('nomor BP', () {
    expect(
      debtPaymentNumber('pst', 'd01', DateTime(2026, 11, 3), 7),
      'BP-PST-D01-261103-0007',
    );
  });

  group('rupiahInWords', () {
    test('angka umum', () {
      expect(rupiahInWords(Money.zero), 'Nol rupiah');
      expect(rupiahInWords(const Money(1)), 'Satu rupiah');
      expect(rupiahInWords(const Money(11)), 'Sebelas rupiah');
      expect(rupiahInWords(const Money(19)), 'Sembilan belas rupiah');
      expect(rupiahInWords(const Money(100)), 'Seratus rupiah');
      expect(rupiahInWords(const Money(1000)), 'Seribu rupiah');
      expect(rupiahInWords(const Money(1500)), 'Seribu lima ratus rupiah');
      expect(rupiahInWords(const Money(800000)), 'Delapan ratus ribu rupiah');
      expect(
        rupiahInWords(const Money(1150000)),
        'Satu juta seratus lima puluh ribu rupiah',
      );
      expect(rupiahInWords(const Money(2000000000)), 'Dua miliar rupiah');
      expect(rupiahInWords(const Money(3000000000000)), 'Tiga triliun rupiah');
      expect(
        rupiahInWords(const Money(214111)),
        'Dua ratus empat belas ribu seratus sebelas rupiah',
      );
    });

    test('negatif diberi kata minus', () {
      expect(rupiahInWords(const Money(-5000)), 'Minus lima ribu rupiah');
    });
  });
}
