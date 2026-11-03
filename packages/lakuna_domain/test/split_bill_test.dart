import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('label tamu', () {
    test('A–H dan kebalikannya', () {
      expect([for (var i = 0; i < 8; i++) guestLabel(i)].join(), 'ABCDEFGH');
      expect(guestIndex('A'), 0);
      expect(guestIndex('H'), 7);
      expect(guestIndex('I'), isNull);
      expect(guestIndex(''), isNull);
      expect(guestIndex('a'), isNull);
    });

    test('jumlah tamu 2–8', () {
      expect(SplitLimits.validGuests(1), isFalse);
      expect(SplitLimits.validGuests(2), isTrue);
      expect(SplitLimits.validGuests(8), isTrue);
      expect(SplitLimits.validGuests(9), isFalse);
      expect(SplitLimits.clampGuests(1), 2);
      expect(SplitLimits.clampGuests(4), 4);
      expect(SplitLimits.clampGuests(20), 8);
    });
  });

  group('allocateByWeight', () {
    test('rata dengan sisa terbesar, urutan stabil', () {
      expect(allocateByWeight(const Money(100000), [1, 1, 1]), [
        const Money(33334),
        const Money(33333),
        const Money(33333),
      ]);
      expect(allocateByWeight(const Money(2), [1, 1, 1]), [
        const Money(1),
        const Money(1),
        Money.zero,
      ]);
    });

    test('proporsional dan jumlah selalu sama dengan total', () {
      final shares = allocateByWeight(const Money(205830), [
        62000,
        69000,
        55000,
      ]);
      expect(Money.sum(shares), const Money(205830));
      expect(shares, [
        const Money(68610),
        const Money(76356),
        const Money(60864),
      ]);
    });

    test('bobot nol mendapat nol; semua nol → semua nol', () {
      expect(allocateByWeight(const Money(1000), [0, 3, 1]), [
        Money.zero,
        const Money(750),
        const Money(250),
      ]);
      expect(allocateByWeight(const Money(1000), [0, 0]), [
        Money.zero,
        Money.zero,
      ]);
      expect(allocateByWeight(Money.zero, [1, 2]), [Money.zero, Money.zero]);
    });

    test('bobot negatif ditolak', () {
      expect(
        () => allocateByWeight(const Money(10), [1, -1]),
        throwsArgumentError,
      );
    });
  });

  group('splitPortion', () {
    test('satu satuan bila jumlah bulat ≥ 2, selain itu utuh', () {
      expect(splitPortion(Qty.units(3)), Qty.one);
      expect(splitPortion(Qty.units(2)), Qty.one);
      expect(splitPortion(Qty.one), Qty.one);
      expect(splitPortion(const Qty(2500)), const Qty(2500));
      expect(splitPortion(const Qty(500)), const Qty(500));
    });
  });

  group('splitDues', () {
    test('rata: dibagi sama per tamu', () {
      expect(
        splitDues(mode: SplitKind.equal, total: const Money(100000), guests: 3),
        [const Money(33334), const Money(33333), const Money(33333)],
      );
    });

    test('per item: proporsional subtotal porsi tamu', () {
      expect(
        splitDues(
          mode: SplitKind.item,
          total: const Money(110000),
          guests: 3,
          guestSubtotals: const [Money(60000), Money(40000), Money.zero],
        ),
        [const Money(66000), const Money(44000), Money.zero],
      );
    });

    test('nominal bebas: tanpa pembagian', () {
      expect(
        splitDues(
          mode: SplitKind.amount,
          total: const Money(100000),
          guests: 3,
        ),
        isEmpty,
      );
    });
  });
}
