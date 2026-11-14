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

  test('jumlah saran beli ulang: 2 × minimum − stok, bulat ke atas (F1-08c)', () {
    expect(restockQuantity(Qty.units(2), Qty.units(20)), Qty.units(38));
    expect(restockQuantity(const Qty(12500), Qty.units(15)), Qty.units(18));
    // Stok minus dihitung 0.
    expect(restockQuantity(Qty.units(-3), Qty.units(5)), Qty.units(10));
    // Minimal satu satuan.
    expect(restockQuantity(const Qty(9900), const Qty(5000)), Qty.units(1));
    expect(restockQuantity(Qty.units(4), Qty.zero), Qty.units(1));
  });
}
