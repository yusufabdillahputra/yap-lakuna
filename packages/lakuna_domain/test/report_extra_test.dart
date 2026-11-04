import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('stockMovementRows', () {
    final start = DateTime.utc(2026, 10, 31, 17); // 1 Nov 00.00 WIB
    final end = DateTime.utc(2026, 11, 30, 17); // 1 Des 00.00 WIB
    StockMove move(String key, int milli, DateTime at) =>
        StockMove(key: key, quantityMilli: milli, at: at);
    const costs = {'kopi': Money(6000), 'teh': Money(2500)};

    test('awal dari stok saat ini, masuk, keluar, akhir, nilai', () {
      // Kopi: 10 (Okt) − 2 (Okt) + 5 + 1 − 3 (Nov) − 4 (Des) = saat ini 7.
      final rows = stockMovementRows(
        moves: [
          move('kopi', -2000, DateTime.utc(2026, 10, 20)), // sebelum: abaikan
          move('kopi', 5000, DateTime.utc(2026, 11, 2)), // beli
          move('kopi', -3000, DateTime.utc(2026, 11, 3)), // jual
          move('kopi', 1000, DateTime.utc(2026, 11, 3)), // retur
          move('kopi', -4000, DateTime.utc(2026, 12, 2)), // sesudah periode
        ],
        start: start,
        end: end,
        names: const {'kopi': 'Kopi', 'teh': 'Teh', 'gula': 'Gula'},
        current: const {'kopi': 7000, 'teh': 3000},
        valueOf: (k, q) => (costs[k] ?? Money.zero).timesMilli(q.milli),
      );
      expect(
        rows.map(
          (r) => (r.key, r.opening, r.inflow, r.outflow, r.closing, r.value),
        ),
        [
          (
            'kopi',
            Qty.units(8),
            Qty.units(6),
            Qty.units(3),
            Qty.units(11),
            const Money(66000),
          ),
          (
            'teh',
            Qty.units(3),
            Qty.zero,
            Qty.zero,
            Qty.units(3),
            const Money(7500),
          ),
        ],
      );
      expect(rows.first.name, 'Kopi');
    });

    test('tanpa nilai: urut nama tanpa membedakan huruf besar', () {
      final rows = stockMovementRows(
        moves: [
          move('b', 1000, DateTime.utc(2026, 11, 2)),
          move('a', 2000, DateTime.utc(2026, 11, 2)),
        ],
        start: start,
        end: end,
        names: const {'a': 'beras', 'b': 'Apel'},
        current: const {'a': 2000, 'b': 1000},
      );
      expect(rows.map((r) => r.name), ['Apel', 'beras']);
      expect(rows.first.value, isNull);
    });
  });

  group('stockValueOf', () {
    test('tepat nilai saat ini, proporsional, atau harga cadangan', () {
      const value = Money(100000); // 3 pcs dari dua lokasi berbeda harga
      final current = Qty.units(3);
      expect(
        stockValueOf(
          value: value,
          current: current,
          qty: current,
          fallback: const Money(1),
        ),
        value,
      );
      expect(
        stockValueOf(
          value: value,
          current: current,
          qty: Qty.units(1),
          fallback: const Money(1),
        ),
        const Money(33333),
      );
      expect(
        stockValueOf(
          value: Money.zero,
          current: Qty.zero,
          qty: Qty.units(2),
          fallback: const Money(9000),
        ),
        const Money(18000),
      );
    });
  });

  group('groupTotals', () {
    test('jumlah dan total per kunci, urut total menurun lalu kunci', () {
      final rows = groupTotals([
        ('manual-out', const Money(5000)),
        ('expense', const Money(20000)),
        ('manual-out', const Money(3000)),
        ('debt', const Money(8000)),
      ]);
      expect(rows.map((r) => (r.key, r.count, r.total)), [
        ('expense', 1, const Money(20000)),
        ('debt', 1, const Money(8000)),
        ('manual-out', 2, const Money(8000)),
      ]);
    });
  });
}
