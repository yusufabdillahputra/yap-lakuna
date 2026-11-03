import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  const total = Money(214000);

  group('settleTender', () {
    test('tanpa bagian → empty, sisa = total', () {
      final s = settleTender(total, const []);
      expect(s.error, TenderError.empty);
      expect(s.remaining, total);
      expect(s.paid, Money.zero);
    });

    test('nominal nol atau negatif → nonPositive', () {
      final s = settleTender(total, const [
        TenderPart(Money(214000), isCash: true),
        TenderPart(Money.zero),
      ]);
      expect(s.error, TenderError.nonPositive);
    });

    test('dua bagian tunai → multipleCash', () {
      final s = settleTender(total, const [
        TenderPart(Money(100000), isCash: true),
        TenderPart(Money(114000), isCash: true),
      ]);
      expect(s.error, TenderError.multipleCash);
    });

    test('non-tunai melebihi total → nonCashOver (kembalian hanya tunai)', () {
      final s = settleTender(total, const [
        TenderPart(Money(200000)),
        TenderPart(Money(20000)),
      ]);
      expect(s.error, TenderError.nonCashOver);
    });

    test('kurang → short dengan sisa', () {
      final s = settleTender(total, const [
        TenderPart(Money(150000), isCash: true),
      ]);
      expect(s.error, TenderError.short);
      expect(s.remaining, const Money(64000));
      expect(s.change, Money.zero);
      expect(s.isSettled, isFalse);
    });

    test('pas: tunai + QRIS', () {
      final s = settleTender(total, const [
        TenderPart(Money(150000), isCash: true),
        TenderPart(Money(64000)),
      ]);
      expect(s.error, isNull);
      expect(s.isSettled, isTrue);
      expect(s.paid, total);
      expect(s.remaining, Money.zero);
      expect(s.change, Money.zero);
    });

    test('tunai lebih → kembalian', () {
      final s = settleTender(total, const [
        TenderPart(Money(64000)),
        TenderPart(Money(200000), isCash: true),
      ]);
      expect(s.isSettled, isTrue);
      expect(s.paid, const Money(264000));
      expect(s.change, const Money(50000));
    });

    test('satu bagian non-tunai sama dengan total', () {
      final s = settleTender(total, const [TenderPart(total)]);
      expect(s.isSettled, isTrue);
      expect(s.change, Money.zero);
    });
  });
}
