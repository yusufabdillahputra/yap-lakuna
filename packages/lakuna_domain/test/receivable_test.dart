import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('umur piutang/hutang (F1-16c)', () {
    final today = DateTime.utc(2026, 11, 14);
    DateTime ago(int days) => today.subtract(Duration(days: days));

    test('kelompok menurut hari lewat jatuh tempo', () {
      expect(agingBucketOf(null, today), AgingBucket.notDue);
      expect(agingBucketOf(today, today), AgingBucket.notDue);
      expect(
        agingBucketOf(today.add(const Duration(days: 3)), today),
        AgingBucket.notDue,
      );
      expect(agingBucketOf(ago(1), today), AgingBucket.days1To30);
      expect(agingBucketOf(ago(30), today), AgingBucket.days1To30);
      expect(agingBucketOf(ago(31), today), AgingBucket.days31To60);
      expect(agingBucketOf(ago(60), today), AgingBucket.days31To60);
      expect(agingBucketOf(ago(61), today), AgingBucket.days61To90);
      expect(agingBucketOf(ago(90), today), AgingBucket.days61To90);
      expect(agingBucketOf(ago(91), today), AgingBucket.over90);
      expect(agingBucketOf(ago(400), today), AgingBucket.over90);
    });

    test('jam di tanggal diabaikan (tanggal kalender)', () {
      expect(
        agingBucketOf(DateTime.utc(2026, 10, 15, 23, 59), today),
        AgingBucket.days1To30,
      );
      expect(
        agingBucketOf(DateTime.utc(2026, 10, 14, 0, 1), today),
        AgingBucket.days31To60,
      );
    });

    test('Aging.of menjumlahkan nilai dan nota per kelompok', () {
      final aging = Aging.of([
        (dueOn: null, outstanding: const Money(1000)),
        (dueOn: ago(5), outstanding: const Money(2000)),
        (dueOn: ago(10), outstanding: const Money(3000)),
        (dueOn: ago(95), outstanding: const Money(4000)),
      ], today);
      expect(aging.amountOf(AgingBucket.notDue), const Money(1000));
      expect(aging.countOf(AgingBucket.notDue), 1);
      expect(aging.amountOf(AgingBucket.days1To30), const Money(5000));
      expect(aging.countOf(AgingBucket.days1To30), 2);
      expect(aging.amountOf(AgingBucket.days31To60), Money.zero);
      expect(aging.countOf(AgingBucket.days61To90), 0);
      expect(aging.amountOf(AgingBucket.over90), const Money(4000));
      expect(aging.total, const Money(10000));
      expect(aging.count, 4);
      expect(aging.overdue, const Money(9000));
      expect(Aging.empty.total, Money.zero);
      expect(Aging.empty.count, 0);
    });
  });

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

  test('alasan batal pembayaran 1–200 karakter (F1-13c)', () {
    expect(validateDebtPaymentVoidReason('Salah nominal'), isTrue);
    expect(validateDebtPaymentVoidReason('   '), isFalse);
    expect(validateDebtPaymentVoidReason('x' * 200), isTrue);
    expect(validateDebtPaymentVoidReason('x' * 201), isFalse);
  });
}
