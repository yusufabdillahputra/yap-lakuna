import 'money.dart' show groupThousands;
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
      BigInt.from(milli) * BigInt.from(factorMilli),
      BigInt.from(1000),
    ),
  );

  /// `12,5`, `0,25`, `1.250` (id) atau dengan [decimal] `.` dan [group] `,`
  /// (en). Nol di belakang koma dibuang.
  String format({String decimal = ',', String group = '.'}) {
    final abs = milli.abs();
    final whole = groupThousands(abs ~/ 1000, group);
    final frac = (abs % 1000)
        .toString()
        .padLeft(3, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    final sign = milli < 0 ? '-' : '';
    return frac.isEmpty ? '$sign$whole' : '$sign$whole$decimal$frac';
  }

  /// Kebalikan [format]: angka tidak negatif dengan pemisah ribuan [group]
  /// (kelompok tiga digit) dan paling banyak tiga desimal setelah
  /// [decimal]. `null` bila tidak sah atau melampaui batas.
  static Qty? tryParse(
    String text, {
    String decimal = ',',
    String group = '.',
  }) {
    final t = text.trim();
    final g = RegExp.escape(group);
    final d = RegExp.escape(decimal);
    final match = RegExp('^(\\d{1,3}(?:$g\\d{3})+|\\d+)(?:$d(\\d{1,3}))?\$')
        .firstMatch(t);
    if (match == null) return null;
    final whole = match.group(1)!.replaceAll(group, '');
    final frac = (match.group(2) ?? '').padRight(3, '0');
    if (whole.length > 15) return null;
    return Qty(int.parse(whole) * 1000 + int.parse(frac));
  }
}
