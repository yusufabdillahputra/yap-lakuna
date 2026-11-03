import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('CashDrawer.expectedCash', () {
    test('saldo awal + penjualan tunai − retur tunai + masuk − keluar', () {
      const drawer = CashDrawer(
        openingCash: Money(200000),
        cashSales: Money(1500000),
        cashRefunds: Money(25000),
        inflow: Money(50000),
        outflow: Money(75000),
      );
      expect(drawer.expectedCash, const Money(1650000));
    });

    test('hanya saldo awal', () {
      const drawer = CashDrawer(openingCash: Money(100000));
      expect(drawer.expectedCash, const Money(100000));
    });

    test('selisih = dihitung − seharusnya', () {
      const drawer = CashDrawer(openingCash: Money(100000));
      expect(drawer.differenceFor(const Money(95000)), const Money(-5000));
      expect(drawer.differenceFor(const Money(100000)), Money.zero);
      expect(drawer.differenceFor(const Money(102000)), const Money(2000));
    });
  });

  test('CashDrawer.fromMovements menjumlahkan masuk dan keluar', () {
    final drawer = CashDrawer.fromMovements(
      openingCash: const Money(100000),
      movements: const [
        (inflow: true, amount: Money(50000)),
        (inflow: false, amount: Money(15000)),
        (inflow: false, amount: Money(5000)),
      ],
    );
    expect(drawer.inflow, const Money(50000));
    expect(drawer.outflow, const Money(20000));
    expect(drawer.expectedCash, const Money(130000));
  });

  group('CashCount', () {
    test('pecahan mengikuti Storeku, dari terbesar', () {
      expect(cashDenominations, [
        100000,
        50000,
        20000,
        10000,
        5000,
        2000,
        1000,
      ]);
    });

    test('total = Σ pecahan × lembar + receh', () {
      const count = CashCount(
        sheets: {100000: 3, 50000: 2, 5000: 1},
        coins: Money(1500),
      );
      expect(count.total, const Money(406500));
    });

    test('kosong bernilai nol', () {
      expect(const CashCount().total, Money.zero);
    });

    test('lembar negatif, receh negatif, atau pecahan asing tidak sah', () {
      expect(const CashCount(sheets: {100000: 1}).isValid, isTrue);
      expect(const CashCount(sheets: {100000: -1}).isValid, isFalse);
      expect(const CashCount(coins: Money(-500)).isValid, isFalse);
      expect(const CashCount(sheets: {75000: 1}).isValid, isFalse);
    });

    test('JSON bolak-balik dan lembar nol tidak disimpan', () {
      const count = CashCount(
        sheets: {100000: 2, 20000: 0, 1000: 4},
        coins: Money(700),
      );
      final json = count.toJson();
      expect(json, {
        'sheets': {'100000': 2, '1000': 4},
        'coins': 700,
      });
      final back = CashCount.fromJson(json);
      expect(back.total, count.total);
      expect(back.sheetsOf(100000), 2);
      expect(back.sheetsOf(20000), 0);
      expect(back.coins, const Money(700));
    });

    test('fromJson menerima objek kosong', () {
      expect(CashCount.fromJson(const {}).total, Money.zero);
    });
  });

  group('validasi', () {
    test('saldo awal boleh nol, tidak boleh negatif', () {
      expect(validateOpeningCash(Money.zero), isNull);
      expect(validateOpeningCash(const Money(150000)), isNull);
      expect(validateOpeningCash(const Money(-1)), CashError.negative);
    });

    test('uang masuk/keluar: jumlah > 0 dan keterangan wajib', () {
      expect(validateMovementAmount(const Money(1000)), isNull);
      expect(validateMovementAmount(Money.zero), CashError.notPositive);
      expect(validateMovementAmount(const Money(-5)), CashError.notPositive);
      expect(validateMovementNote('Beli es batu'), isNull);
      expect(validateMovementNote('   '), CashError.required);
      expect(
        validateMovementNote('x' * (cashNoteMaxLength + 1)),
        CashError.tooLong,
      );
    });

    test('catatan selisih wajib bila selisih tidak nol', () {
      expect(validateClosingNote(Money.zero, ''), isNull);
      expect(validateClosingNote(const Money(-5000), ''), CashError.required);
      expect(validateClosingNote(const Money(2000), '  '), CashError.required);
      expect(validateClosingNote(const Money(2000), 'Kembalian salah'), isNull);
      expect(
        validateClosingNote(Money.zero, 'x' * (cashNoteMaxLength + 1)),
        CashError.tooLong,
      );
    });

    test('panjang catatan dihitung per karakter, bukan unit UTF-16', () {
      final emoji = '😀' * cashNoteMaxLength;
      expect(emoji.length, cashNoteMaxLength * 2);
      expect(validateMovementNote(emoji), isNull);
      expect(validateMovementNote('$emoji!'), CashError.tooLong);
    });

    test('catatan buka sesi opsional tapi dibatasi panjangnya', () {
      expect(validateOpeningNote(''), isNull);
      expect(validateOpeningNote('Shift pagi'), isNull);
      expect(
        validateOpeningNote('x' * (cashNoteMaxLength + 1)),
        CashError.tooLong,
      );
    });
  });
}
