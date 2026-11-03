import 'money.dart';
import 'qty.dart';

/// Split bill F&B (F1-10c, layar 1.9): satu nota, pembayaran per tamu.

/// Cara membagi tagihan.
enum SplitKind {
  /// Setiap porsi item diberikan ke tamu; tagihan proporsional subtotal.
  item,

  /// Total dibagi sama rata.
  equal,

  /// Kasir mengetik nominal tiap tamu.
  amount,
}

abstract final class SplitLimits {
  static const minGuests = 2;
  static const maxGuests = 8;

  static bool validGuests(int n) => n >= minGuests && n <= maxGuests;

  static int clampGuests(int n) => n.clamp(minGuests, maxGuests);
}

const _labels = 'ABCDEFGH';

/// Label tamu ke-[index] (0 = `A`).
String guestLabel(int index) => _labels[index];

/// Kebalikan [guestLabel]; `null` bila bukan `A`–`H`.
int? guestIndex(String label) {
  if (label.length != 1) return null;
  final i = _labels.indexOf(label);
  return i < 0 ? null : i;
}

/// Membagi [total] sesuai [weights] dengan metode sisa terbesar: jumlah
/// hasil selalu sama dengan [total]. Sisa dibagi ke pecahan terbesar,
/// seri → urutan lebih awal. Bobot nol mendapat nol; semua nol → semua nol.
List<Money> allocateByWeight(Money total, List<int> weights) {
  if (weights.any((w) => w < 0)) {
    throw ArgumentError.value(weights, 'weights', 'tidak boleh negatif');
  }
  final sum = weights.fold(0, (a, b) => a + b);
  if (sum == 0 || total.value == 0) {
    return [for (final _ in weights) Money.zero];
  }
  final t = BigInt.from(total.value);
  final s = BigInt.from(sum);
  final shares = <int>[];
  final remainders = <BigInt>[];
  for (final w in weights) {
    final p = t * BigInt.from(w);
    shares.add((p ~/ s).toInt());
    remainders.add(p.remainder(s));
  }
  var left = total.value - shares.fold(0, (a, b) => a + b);
  final order = [for (var i = 0; i < weights.length; i++) i]
    ..sort((a, b) {
      final c = remainders[b].compareTo(remainders[a]);
      return c != 0 ? c : a.compareTo(b);
    });
  for (final i in order) {
    if (left <= 0) break;
    if (weights[i] == 0) continue;
    shares[i]++;
    left--;
  }
  return [for (final v in shares) Money(v)];
}

/// Jumlah satu porsi dari baris berjumlah [quantity]: satu satuan bila
/// jumlahnya bulat dan ≥ 2, selain itu seluruh baris.
Qty splitPortion(Qty quantity) =>
    quantity.milli >= 2000 && quantity.milli % 1000 == 0 ? Qty.one : quantity;

/// Tagihan per tamu (urut A, B, …) untuk [total] bill. *Per item*:
/// proporsional [guestSubtotals] (Σ total porsi tiap tamu). *Rata*: sama
/// rata. *Nominal bebas*: kosong (nominal diketik kasir).
List<Money> splitDues({
  required SplitKind mode,
  required Money total,
  required int guests,
  List<Money> guestSubtotals = const [],
}) => switch (mode) {
  SplitKind.item => allocateByWeight(total, [
    for (var i = 0; i < guests; i++)
      i < guestSubtotals.length ? guestSubtotals[i].value : 0,
  ]),
  SplitKind.equal => allocateByWeight(total, List.filled(guests, 1)),
  SplitKind.amount => const [],
};
