import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('stockMovementRows', () {
    final start = DateTime.utc(2026, 10, 31, 17); // 1 Nov 00.00 WIB
    final end = DateTime.utc(2026, 11, 30, 17); // 1 Des 00.00 WIB
    StockMove move(String key, int milli, DateTime at) =>
        StockMove(key: key, quantityMilli: milli, at: at);

    test('awal, masuk, keluar, akhir per varian dan nilai akhir', () {
      final rows = stockMovementRows(
        moves: [
          move('kopi', 10000, DateTime.utc(2026, 10, 1)), // stok awal
          move('kopi', -2000, DateTime.utc(2026, 10, 20)),
          move('kopi', 5000, DateTime.utc(2026, 11, 2)), // beli
          move('kopi', -3000, DateTime.utc(2026, 11, 3)), // jual
          move('kopi', 1000, DateTime.utc(2026, 11, 3)), // retur
          move('kopi', -4000, DateTime.utc(2026, 12, 2)), // sesudah periode
          move('teh', 3000, DateTime.utc(2026, 9, 1)), // tanpa gerak periode
          move('gula', 0, DateTime.utc(2026, 9, 1)),
        ],
        start: start,
        end: end,
        names: const {'kopi': 'Kopi', 'teh': 'Teh', 'gula': 'Gula'},
        unitCost: const {'kopi': Money(6000), 'teh': Money(2500)},
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

    test('tanpa harga pokok: nilai null, urut nama', () {
      final rows = stockMovementRows(
        moves: [
          move('b', 1000, DateTime.utc(2026, 11, 2)),
          move('a', 2000, DateTime.utc(2026, 11, 2)),
        ],
        start: start,
        end: end,
        names: const {'a': 'Apel', 'b': 'Beras'},
      );
      expect(rows.map((r) => r.name), ['Apel', 'Beras']);
      expect(rows.first.value, isNull);
    });

    test('barang tanpa pergerakan sama sekali tetap tampil bila diminta', () {
      final rows = stockMovementRows(
        moves: const [],
        start: start,
        end: end,
        names: const {'a': 'Apel'},
        includeAll: true,
      );
      expect(rows.single.closing, Qty.zero);
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
