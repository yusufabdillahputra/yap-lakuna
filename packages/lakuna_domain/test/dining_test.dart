import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('fnbCharges', () {
    test('contoh kanvas 1.7e: service 5% dine in, PB1 10% dari subtotal + '
        'service', () {
      final c = fnbCharges(
        const Money(158000),
        dineIn: true,
        serviceBp: const BasisPoints(500),
        taxBp: const BasisPoints(1000),
      );
      expect(c.subtotal, const Money(158000));
      expect(c.service, const Money(7900));
      expect(c.tax, const Money(16590));
      expect(c.total, const Money(182490));
    });

    test('take away tanpa service, PB1 tetap', () {
      final c = fnbCharges(
        const Money(158000),
        dineIn: false,
        serviceBp: const BasisPoints(500),
        taxBp: const BasisPoints(1000),
      );
      expect(c.service, Money.zero);
      expect(c.tax, const Money(15800));
      expect(c.total, const Money(173800));
    });

    test('pembulatan setengah ke atas ke rupiah', () {
      final c = fnbCharges(
        const Money(1005),
        dineIn: true,
        serviceBp: const BasisPoints(250), // 25,125 → 25
        taxBp: const BasisPoints(1000), // (1005 + 25) × 10% = 103
      );
      expect(c.service, const Money(25));
      expect(c.tax, const Money(103));
      final half = fnbCharges(
        const Money(10),
        dineIn: true,
        serviceBp: const BasisPoints(500), // 0,5 → 1
        taxBp: BasisPoints.zero,
      );
      expect(half.service, const Money(1));
    });

    test('tarif 0 = total sama dengan subtotal', () {
      final c = fnbCharges(
        const Money(50000),
        dineIn: true,
        serviceBp: BasisPoints.zero,
        taxBp: BasisPoints.zero,
      );
      expect(c.total, const Money(50000));
    });
  });

  test('validateFnbRate: 0..maks, kelipatan 0,5%', () {
    expect(validateFnbRate(BasisPoints.zero, FnbLimits.serviceBp), isTrue);
    expect(
      validateFnbRate(const BasisPoints(550), FnbLimits.serviceBp),
      isTrue,
    );
    expect(
      validateFnbRate(const BasisPoints(3000), FnbLimits.serviceBp),
      isTrue,
    );
    expect(
      validateFnbRate(const BasisPoints(3050), FnbLimits.serviceBp),
      isFalse,
    );
    expect(validateFnbRate(const BasisPoints(525), FnbLimits.taxBp), isFalse);
    expect(validateFnbRate(const BasisPoints(-50), FnbLimits.taxBp), isFalse);
    expect(validateFnbRate(const BasisPoints(2000), FnbLimits.taxBp), isTrue);
    expect(validateFnbRate(const BasisPoints(2050), FnbLimits.taxBp), isFalse);
  });

  group('validateDiningName', () {
    test('wajib, maks, unik tanpa beda huruf, abaikan diri sendiri', () {
      expect(
        validateDiningName('  ', max: 20, existing: const []),
        DiningNameError.empty,
      );
      expect(
        validateDiningName('a' * 21, max: 20, existing: const []),
        DiningNameError.tooLong,
      );
      expect(
        validateDiningName('🍜' * 20, max: 20, existing: const []),
        isNull,
      );
      expect(
        validateDiningName(' m4 ', max: 20, existing: const ['M4', 'M5']),
        DiningNameError.duplicate,
      );
      expect(validateDiningName('M6', max: 20, existing: const ['M4']), isNull);
    });
  });

  group('tableRange', () {
    test('M1–M12', () {
      expect(tableRange('M', 1, 3), ['M1', 'M2', 'M3']);
      expect(tableRange(' Meja ', 9, 10), ['Meja 9', 'Meja 10']);
    });

    test('rentang tidak sah atau lebih dari 50 meja → null', () {
      expect(tableRange('M', 5, 4), isNull);
      expect(tableRange('M', 0, 3), isNull);
      expect(tableRange('M', 1, 51), isNull);
      expect(tableRange('M', 1, 50), hasLength(50));
    });
  });

  test('label take away dan tiket dapur', () {
    expect(takeAwayLabel(7), 'TA-07');
    expect(takeAwayLabel(123), 'TA-123');
    expect(kitchenTicketLabel(12), 'K-0012');
  });

  test('nextDailyNumber: tertinggi + 1, mulai 1', () {
    expect(nextDailyNumber(const []), 1);
    expect(nextDailyNumber(const [3, 1, 7]), 8);
  });

  test('takeAwayState dari jumlah item per status', () {
    expect(takeAwayState(pending: 0, sent: 0, served: 0), TakeAwayState.empty);
    expect(
      takeAwayState(pending: 1, sent: 2, served: 0),
      TakeAwayState.pending,
    );
    expect(
      takeAwayState(pending: 0, sent: 1, served: 3),
      TakeAwayState.inKitchen,
    );
    expect(takeAwayState(pending: 0, sent: 0, served: 2), TakeAwayState.ready);
  });

  group('fnbCharges dengan diskon nota (F1-04e)', () {
    test('service dan PB1 dari dasar setelah diskon', () {
      // 100.000 − 10% = 90.000; service 5% = 4.500; PB1 10% dari 94.500.
      final c = fnbCharges(
        const Money(100000),
        dineIn: true,
        serviceBp: const BasisPoints(500),
        taxBp: const BasisPoints(1000),
        discount: const ManualDiscount.percent(BasisPoints(1000)),
      );
      expect(c.subtotal, const Money(100000));
      expect(c.discount, const Money(10000));
      expect(c.service, const Money(4500));
      expect(c.tax, const Money(9450));
      expect(c.total, const Money(103950));
    });

    test('PB1 termasuk dan pembulatan', () {
      final c = fnbCharges(
        const Money(55000),
        dineIn: true,
        serviceBp: const BasisPoints(500),
        taxBp: const BasisPoints(1000),
        taxInclusive: true,
        rounding: TotalRounding.nearest500,
        discount: const ManualDiscount.amount(Money(5000)),
      );
      // 50.000 + service 2.500 = 52.500 (PB1 termasuk), dibulatkan 52.500.
      expect(c.discount, const Money(5000));
      expect(c.service, const Money(2500));
      expect(c.total, const Money(52500));
    });

    test('rupiah dipangkas ke dasar; tanpa diskon tetap sama', () {
      final c = fnbCharges(
        const Money(3000),
        dineIn: false,
        serviceBp: const BasisPoints(500),
        taxBp: BasisPoints.zero,
        discount: const ManualDiscount.amount(Money(5000)),
      );
      expect(c.discount, const Money(3000));
      expect(c.total, Money.zero);
      final plain = fnbCharges(
        const Money(3000),
        dineIn: false,
        serviceBp: const BasisPoints(500),
        taxBp: BasisPoints.zero,
      );
      expect(plain.discount, Money.zero);
      expect(plain.total, const Money(3000));
    });
  });
}
