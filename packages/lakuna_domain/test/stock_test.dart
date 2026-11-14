import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('selisih = fisik − sistem, termasuk pecahan dan stok minus', () {
    expect(
      stockDifference(system: Qty(12500), physical: Qty(12200)),
      Qty(-300),
    );
    expect(
      stockDifference(system: Qty.units(-4), physical: Qty.zero),
      Qty.units(4),
    );
    expect(
      stockDifference(system: Qty.units(2), physical: Qty.units(2)),
      Qty.zero,
    );
  });

  test('nilai selisih memakai HPP rata-rata, atau harga modal bila 0', () {
    // 0,3 kg × Rp 25.500/kg = Rp 7.650 (rugi).
    expect(
      adjustmentUnitCost(avgCost: Money(25500), costPrice: Money(24000)),
      Money(25500),
    );
    expect(
      adjustmentUnitCost(avgCost: Money.zero, costPrice: Money(18000)),
      Money(18000),
    );
    expect(adjustmentValue(Qty(-300), Money(25500)), Money(-7650));
    expect(adjustmentValue(Qty.units(2), Money(18000)), Money(36000));
  });

  test('nama lokasi: wajib, maks 40 karakter, unik per cabang', () {
    expect(
      validateLocationName('  ', existing: const []),
      StockLocationNameError.empty,
    );
    expect(
      validateLocationName('x' * 41, existing: const []),
      StockLocationNameError.tooLong,
    );
    expect(
      validateLocationName('gudang', existing: const ['Etalase', 'Gudang']),
      StockLocationNameError.duplicate,
    );
    expect(
      validateLocationName(
        'Gudang Belakang',
        existing: const ['Etalase', 'Gudang'],
      ),
      isNull,
    );
  });

  test('alasan baris maks 60 karakter', () {
    expect(StockLimits.lineNote, 60);
    expect(StockLimits.locationName, 40);
  });

  test(
    'jumlah saran beli ulang: 2 × minimum − stok, bulat ke atas (F1-08c)',
    () {
      expect(restockQuantity(Qty.units(2), Qty.units(20)), Qty.units(38));
      expect(restockQuantity(const Qty(12500), Qty.units(15)), Qty.units(18));
      // Stok minus dihitung 0.
      expect(restockQuantity(Qty.units(-3), Qty.units(5)), Qty.units(10));
      // Minimal satu satuan.
      expect(restockQuantity(const Qty(9900), const Qty(5000)), Qty.units(1));
      expect(restockQuantity(Qty.units(4), Qty.zero), Qty.units(1));
    },
  );

  group('supplier untuk draf stok minimum (F1-08d)', () {
    final d1 = DateTime.utc(2026, 10, 1);
    final d2 = DateTime.utc(2026, 11, 1);

    test('supplier terakhir untuk barang terbanyak', () {
      expect(
        chooseRestockSupplier([
          (supplier: 'A', at: d1),
          (supplier: 'B', at: d2),
          (supplier: 'A', at: d1),
        ]),
        (supplier: 'A', count: 2),
      );
    });

    test('seri: pembelian terbaru menang', () {
      expect(
        chooseRestockSupplier([
          (supplier: 'A', at: d1),
          (supplier: 'B', at: d2),
        ]),
        (supplier: 'B', count: 1),
      );
      expect(
        chooseRestockSupplier([
          (supplier: 'B', at: d1),
          (supplier: 'A', at: d2),
          (supplier: 'B', at: d1),
          (supplier: 'A', at: d1),
        ]),
        (supplier: 'A', count: 2),
      );
    });

    test('tanpa riwayat: null', () {
      expect(
        chooseRestockSupplier(<({String supplier, DateTime at})>[]),
        isNull,
      );
    });
  });

  test('harga beli per satuan dasar (F1-08e)', () {
    // Rp 185.000 per dus isi 6 = 30.833,3 → 30.833.
    expect(
      perBaseUnitPrice(const Money(185000), Qty.units(6)),
      const Money(30833),
    );
    // 100.000 / 3 = 33.333,3; 50.000 / 3 = 16.666,7 → 16.667.
    expect(
      perBaseUnitPrice(const Money(50000), Qty.units(3)),
      const Money(16667),
    );
    // Setengah ke atas: 15 / 2 = 7,5 → 8.
    expect(perBaseUnitPrice(const Money(15), Qty.units(2)), const Money(8));
    expect(perBaseUnitPrice(const Money(14500), Qty.one), const Money(14500));
    // Isi pecahan: 1 pak = 0,5 kg seharga 10.000 → 20.000 per kg.
    expect(
      perBaseUnitPrice(const Money(10000), const Qty(500)),
      const Money(20000),
    );
    // Isi tidak sah: harga apa adanya.
    expect(perBaseUnitPrice(const Money(9000), Qty.zero), const Money(9000));
  });
}
