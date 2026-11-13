import 'package:characters/characters.dart';

import 'document_number.dart';
import 'money.dart';

// Piutang pelanggan (F1-13). Saldo selalu dihitung dari dokumen: nota,
// alokasi pembayaran, dan retur yang memotong piutang.

/// Sisa piutang satu nota: `total − dibayar saat jual − alokasi − pengurang
/// retur`, minimum 0.
Money saleOutstanding({
  required Money total,
  required Money paidAtSale,
  Money allocated = Money.zero,
  Money debtReduction = Money.zero,
}) {
  final rest = total - paidAtSale - allocated - debtReduction;
  return rest.isNegative ? Money.zero : rest;
}

/// Alasan kredit di Kasir ditolak, urut prioritas.
enum CreditIssue {
  /// Limit pelanggan 0: tidak boleh kredit.
  noLimit,

  /// DP negatif atau tidak kurang dari total (itu bukan kredit).
  downPayment,

  /// Jatuh tempo sebelum hari ini.
  dueOn,

  /// Piutang berjalan + piutang baru melebihi limit.
  overLimit,
}

/// Memeriksa nota kredit [total] dengan DP [downPayment]. [dueOn] dan
/// [today] tanggal kalender (UTC tengah malam).
CreditIssue? creditIssue({
  required Money limit,
  required Money outstanding,
  required Money total,
  required Money downPayment,
  required DateTime dueOn,
  required DateTime today,
}) {
  if (limit <= Money.zero) return CreditIssue.noLimit;
  if (downPayment.isNegative || downPayment >= total) {
    return CreditIssue.downPayment;
  }
  if (dueOn.isBefore(today)) return CreditIssue.dueOn;
  if (outstanding + (total - downPayment) > limit) return CreditIssue.overLimit;
  return null;
}

/// Nota belum lunas, urut terlama dulu.
class OpenReceivable<K> {
  const OpenReceivable({required this.id, required this.outstanding});

  final K id;
  final Money outstanding;
}

/// Alokasi otomatis [amount] ke nota terlama dulu. Kelebihan di atas total
/// piutang tidak dialokasikan.
Map<K, Money> allocateOldestFirst<K>(
  Money amount,
  List<OpenReceivable<K>> open,
) {
  final result = <K, Money>{};
  var rest = amount;
  for (final r in open) {
    if (rest <= Money.zero) break;
    if (r.outstanding <= Money.zero) continue;
    final take = rest < r.outstanding ? rest : r.outstanding;
    result[r.id] = take;
    rest -= take;
  }
  return result;
}

enum DebtPaymentIssue {
  /// Jumlah ≤ 0.
  amount,

  /// Jumlah melebihi total piutang.
  overOutstanding,

  /// Ada alokasi negatif.
  allocationNegative,

  /// Alokasi ke nota yang bukan piutang pelanggan ini.
  allocationUnknown,

  /// Alokasi melebihi sisa nota.
  allocationOverRemaining,

  /// Jumlah alokasi ≠ jumlah diterima.
  allocationTotal,
}

/// Memeriksa pembayaran [amount] untuk [open]; [manual] = alokasi manual
/// (`null` = otomatis).
DebtPaymentIssue? validateDebtPayment<K>(
  Money amount,
  List<OpenReceivable<K>> open, {
  Map<K, Money>? manual,
}) {
  if (amount <= Money.zero) return DebtPaymentIssue.amount;
  if (amount > Money.sum(open.map((r) => r.outstanding))) {
    return DebtPaymentIssue.overOutstanding;
  }
  if (manual == null) return null;
  final byId = {for (final r in open) r.id: r.outstanding};
  if (manual.values.any((m) => m.isNegative)) {
    return DebtPaymentIssue.allocationNegative;
  }
  for (final MapEntry(:key, :value) in manual.entries) {
    final remaining = byId[key];
    if (remaining == null) return DebtPaymentIssue.allocationUnknown;
    if (value > remaining) return DebtPaymentIssue.allocationOverRemaining;
  }
  if (Money.sum(manual.values) != amount) {
    return DebtPaymentIssue.allocationTotal;
  }
  return null;
}

/// Terlambat bila jatuh tempo sebelum [today] (tanggal kalender).
bool isOverdue(DateTime? dueOn, DateTime today) =>
    dueOn != null && dueOn.isBefore(today);

/// `BP-PST-D01-261103-0007`.
String debtPaymentNumber(
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) => documentNumber('BP', outletCode, deviceCode, localDate, counter);

const _ones = [
  '',
  'satu',
  'dua',
  'tiga',
  'empat',
  'lima',
  'enam',
  'tujuh',
  'delapan',
  'sembilan',
  'sepuluh',
  'sebelas',
];

String _below1000(int n) {
  final parts = <String>[];
  final hundreds = n ~/ 100;
  final rest = n % 100;
  if (hundreds == 1) {
    parts.add('seratus');
  } else if (hundreds > 1) {
    parts.add('${_ones[hundreds]} ratus');
  }
  if (rest == 0) {
    // tidak ada
  } else if (rest < 12) {
    parts.add(_ones[rest]);
  } else if (rest < 20) {
    parts.add('${_ones[rest - 10]} belas');
  } else {
    final tens = rest ~/ 10;
    final ones = rest % 10;
    parts.add('${_ones[tens]} puluh');
    if (ones > 0) parts.add(_ones[ones]);
  }
  return parts.join(' ');
}

const _scales = ['', 'ribu', 'juta', 'miliar', 'triliun', 'kuadriliun'];

/// Terbilang rupiah untuk kuitansi, mis. "Delapan ratus ribu rupiah".
String rupiahInWords(Money amount) {
  var n = amount.value.abs();
  String words;
  if (n == 0) {
    words = 'nol';
  } else {
    final groups = <String>[];
    var scale = 0;
    while (n > 0) {
      final chunk = n % 1000;
      if (chunk > 0) {
        final text = scale == 1 && chunk == 1
            ? 'seribu'
            : [
                _below1000(chunk),
                _scales[scale],
              ].where((s) => s.isNotEmpty).join(' ');
        groups.insert(0, text);
      }
      n ~/= 1000;
      scale++;
    }
    words = groups.join(' ');
  }
  if (amount.isNegative) words = 'minus $words';
  final sentence = '$words rupiah';
  return sentence[0].toUpperCase() + sentence.substring(1);
}

/// Panjang maksimum alasan batal pembayaran piutang/hutang (F1-13c), sama
/// dengan batal pengeluaran.
const debtPaymentVoidReasonMax = 200;

/// Alasan batal pembayaran sah: tidak kosong, ≤ [debtPaymentVoidReasonMax].
bool validateDebtPaymentVoidReason(String reason) {
  final n = reason.trim().characters.length;
  return n > 0 && n <= debtPaymentVoidReasonMax;
}
