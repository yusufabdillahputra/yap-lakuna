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
