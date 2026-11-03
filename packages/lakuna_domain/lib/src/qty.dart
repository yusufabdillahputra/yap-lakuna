import 'rounding.dart';

/// Jumlah barang dalam mili-satuan (per seribu), supaya barang timbang
/// (0,25 kg) tetap akurat tanpa `double`.
extension type const Qty(int milli) {
  static const zero = Qty(0);
  static const one = Qty(1000);

  /// Jumlah bulat, mis. `Qty.units(3)` = 3 pcs.
  static Qty units(int n) => Qty(n * 1000);

  bool get isPositive => milli > 0;

  Qty operator +(Qty other) => Qty(milli + other.milli);
  Qty operator -(Qty other) => Qty(milli - other.milli);
  Qty operator -() => Qty(-milli);

  /// Konversi dari satuan jual ke satuan dasar. [factorMilli] adalah isi satu
  /// satuan dalam satuan dasar (1 dus = 24 pcs -> 24000).
  Qty toBaseUnit(int factorMilli) => Qty(
        divRoundHalfAway(
            BigInt.from(milli) * BigInt.from(factorMilli), BigInt.from(1000)),
      );
}
