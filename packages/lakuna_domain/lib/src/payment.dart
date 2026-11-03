import 'money.dart';

/// Kembalian tunai untuk [total] bila [received] cukup, `null` bila kurang.
Money? cashChange({required Money total, required Money received}) =>
    received < total ? null : received - total;

/// Nominal cepat di layar bayar tunai: uang pas, lalu total dibulatkan ke
/// atas ke Rp 10.000, 50.000, dan 100.000. Unik dan urut naik.
List<Money> quickCashAmounts(Money total) {
  if (total.value <= 0) return const [];
  int up(int step) => ((total.value + step - 1) ~/ step) * step;
  final values = <int>{total.value, up(10000), up(50000), up(100000)};
  return [for (final v in values.toList()..sort()) Money(v)];
}

/// Panjang maksimal no. approval kartu atau referensi transfer.
const maxPaymentReferenceLength = 40;

enum PaymentReferenceError { tooLong }

/// No. approval / referensi boleh kosong, maksimal
/// [maxPaymentReferenceLength] karakter.
PaymentReferenceError? validatePaymentReference(String reference) =>
    reference.trim().length > maxPaymentReferenceLength
    ? PaymentReferenceError.tooLong
    : null;

/// Satu bagian pembayaran: nominal dan apakah tunai. Hanya tunai yang boleh
/// melebihi sisa (kembalian).
class TenderPart {
  const TenderPart(this.amount, {this.isCash = false});

  final Money amount;
  final bool isCash;
}

/// Alasan pembayaran belum bisa diselesaikan, urut prioritas.
enum TenderError {
  /// Belum ada bagian.
  empty,

  /// Ada nominal nol atau negatif. Pengecualian: total nol (barang
  /// gratis) lunas dengan satu bagian nol.
  nonPositive,

  /// Lebih dari satu bagian tunai.
  multipleCash,

  /// Jumlah non-tunai melebihi total: kembalian hanya dari tunai.
  nonCashOver,

  /// Jumlah bagian kurang dari total.
  short,
}

/// Hasil [settleTender].
class Settlement {
  const Settlement({
    required this.paid,
    required this.remaining,
    required this.change,
    this.error,
  });

  /// Jumlah semua bagian.
  final Money paid;

  /// Sisa yang belum dibayar (≥ 0).
  final Money remaining;

  /// Kembalian dari bagian tunai (≥ 0).
  final Money change;

  /// `null` bila lunas.
  final TenderError? error;

  bool get isSettled => error == null;
}

/// Melunasi [total] dengan [parts] (satu metode = satu bagian). Lihat
/// [TenderError] untuk aturannya.
Settlement settleTender(Money total, List<TenderPart> parts) {
  final paid = Money.sum(parts.map((p) => p.amount));
  final nonCash = Money.sum([
    for (final p in parts)
      if (!p.isCash) p.amount,
  ]);
  final diff = paid - total;
  final remaining = diff.isNegative ? -diff : Money.zero;
  final change = diff.isNegative ? Money.zero : diff;
  final freeSale = total == Money.zero && parts.length == 1;
  final error = parts.isEmpty
      ? TenderError.empty
      : parts.any(
          (p) => p.amount.isNegative || (p.amount == Money.zero && !freeSale),
        )
      ? TenderError.nonPositive
      : parts.where((p) => p.isCash).length > 1
      ? TenderError.multipleCash
      : nonCash > total
      ? TenderError.nonCashOver
      : remaining > Money.zero
      ? TenderError.short
      : null;
  return Settlement(
    paid: paid,
    remaining: remaining,
    change: error == null ? change : Money.zero,
    error: error,
  );
}
