import 'rounding.dart';

/// Persentase dalam basis poin: 100 bp = 1%, 10.000 bp = 100%.
extension type const BasisPoints(int value) {
  static const zero = BasisPoints(0);
  static const full = BasisPoints(10000);

  static BasisPoints percent(int p) => BasisPoints(p * 100);
}

/// Uang dalam rupiah penuh (IDR tidak memakai sen). Tidak pernah memakai
/// `double`.
extension type const Money(int value) implements Comparable<num> {
  static const zero = Money(0);

  static Money sum(Iterable<Money> items) =>
      items.fold(zero, (a, b) => a + b);

  bool get isNegative => value < 0;

  Money operator +(Money other) => Money(value + other.value);
  Money operator -(Money other) => Money(value - other.value);
  Money operator -() => Money(-value);
  bool operator <(Money other) => value < other.value;
  bool operator <=(Money other) => value <= other.value;
  bool operator >(Money other) => value > other.value;
  bool operator >=(Money other) => value >= other.value;

  /// Bagian [bp] dari jumlah ini, dibulatkan setengah menjauhi nol.
  Money applyBp(BasisPoints bp) => Money(
        divRoundHalfAway(BigInt.from(value) * BigInt.from(bp.value),
            BigInt.from(10000)),
      );

  /// Harga per satuan dikali jumlah dalam mili-satuan.
  Money timesMilli(int milli) => Money(
        divRoundHalfAway(
            BigInt.from(value) * BigInt.from(milli), BigInt.from(1000)),
      );

  /// `Rp 12.500`, `-Rp 3.000`.
  String formatIdr() => '${_sign}Rp ${groupThousands(value.abs(), '.')}';

  /// `36.000` tanpa "Rp", untuk struk.
  String formatPlain() => '$_sign${groupThousands(value.abs(), '.')}';

  /// `IDR 12,500`.
  String formatEn() => '${_sign}IDR ${groupThousands(value.abs(), ',')}';

  String get _sign => value < 0 ? '-' : '';
}

/// Mengelompokkan ribuan: `1234567` -> `1.234.567`.
String groupThousands(int n, String separator) {
  final digits = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(separator);
    buf.write(digits[i]);
  }
  return buf.toString();
}
