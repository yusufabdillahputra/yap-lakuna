import 'package:characters/characters.dart';

import 'money.dart';

/// Pecahan uang kertas yang dihitung saat tutup sesi, dari terbesar.
/// Rp 2.000 dan 1.000 ikut dihitung (sama dengan Storeku).
const cashDenominations = [100000, 50000, 20000, 10000, 5000, 2000, 1000];

/// Panjang maksimal (dalam karakter yang tampak, sama dengan penghitung
/// field teks) catatan buka sesi, keterangan uang laci, dan catatan selisih.
const cashNoteMaxLength = 200;

/// Kelebihan [amount] yang akan keluar dari laci di atas perkiraan uang di
/// laci [drawerCash] (*Kas seharusnya* sesi terbuka), atau `null` bila
/// cukup, jumlahnya nol atau negatif, atau tidak ada sesi (`drawerCash` null). Dipakai
/// untuk peringatan, bukan pemblokir (F1-03c).
Money? drawerShortfallOf(Money amount, Money? drawerCash) {
  if (drawerCash == null || amount <= Money.zero) return null;
  final over = amount - drawerCash;
  return over > Money.zero ? over : null;
}

/// Komponen kas laci dalam satu sesi kasir.
class CashDrawer {
  const CashDrawer({
    required this.openingCash,
    this.cashSales = Money.zero,
    this.cashRefunds = Money.zero,
    this.inflow = Money.zero,
    this.outflow = Money.zero,
  });

  /// Rekap dari gerakan kas sesi: [movements] berisi arah (`inflow`
  /// true = uang masuk) dan jumlahnya.
  factory CashDrawer.fromMovements({
    required Money openingCash,
    required Iterable<({bool inflow, Money amount})> movements,
    Money cashSales = Money.zero,
    Money cashRefunds = Money.zero,
  }) {
    var inflow = Money.zero;
    var outflow = Money.zero;
    for (final m in movements) {
      if (m.inflow) {
        inflow += m.amount;
      } else {
        outflow += m.amount;
      }
    }
    return CashDrawer(
      openingCash: openingCash,
      cashSales: cashSales,
      cashRefunds: cashRefunds,
      inflow: inflow,
      outflow: outflow,
    );
  }

  final Money openingCash;

  /// Penjualan tunai bersih dari kembalian.
  final Money cashSales;

  /// Retur yang dibayar tunai dari laci.
  final Money cashRefunds;

  /// Uang masuk lain (manual atau dari modul lain).
  final Money inflow;

  /// Uang keluar (manual atau dari modul lain).
  final Money outflow;

  /// Seharusnya di laci.
  Money get expectedCash =>
      openingCash + cashSales - cashRefunds + inflow - outflow;

  /// Selisih = dihitung − seharusnya; positif berarti lebih.
  Money differenceFor(Money counted) => counted - expectedCash;
}

/// Hasil hitung uang fisik: lembar per pecahan dan receh.
class CashCount {
  const CashCount({this.sheets = const {}, this.coins = Money.zero});

  factory CashCount.fromJson(Map<String, Object?> json) {
    final raw = json['sheets'];
    final sheets = <int, int>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        final key = int.tryParse('${entry.key}');
        final value = entry.value;
        if (key != null && value is int) sheets[key] = value;
      }
    }
    final coins = json['coins'];
    return CashCount(sheets: sheets, coins: Money(coins is int ? coins : 0));
  }

  /// Lembar per pecahan (nilai rupiah → jumlah lembar).
  final Map<int, int> sheets;

  /// Receh dan sisa yang diisi sebagai nominal langsung.
  final Money coins;

  int sheetsOf(int denomination) => sheets[denomination] ?? 0;

  Money get total {
    var sum = coins.value;
    for (final entry in sheets.entries) {
      sum += entry.key * entry.value;
    }
    return Money(sum);
  }

  /// Lembar dan receh tidak negatif, dan pecahan termasuk [cashDenominations].
  bool get isValid =>
      !coins.isNegative &&
      sheets.entries.every(
        (e) => e.value >= 0 && cashDenominations.contains(e.key),
      );

  /// Disimpan di `counted_breakdown`; pecahan berlembar nol dilewati.
  Map<String, Object?> toJson() => {
    'sheets': {
      for (final d in cashDenominations)
        if (sheetsOf(d) != 0) '$d': sheetsOf(d),
    },
    'coins': coins.value,
  };
}

enum CashError { required, negative, notPositive, tooLong }

CashError? validateOpeningCash(Money amount) =>
    amount.isNegative ? CashError.negative : null;

CashError? validateOpeningNote(String note) =>
    _noteLength(note) > cashNoteMaxLength ? CashError.tooLong : null;

CashError? validateMovementAmount(Money amount) =>
    amount.value <= 0 ? CashError.notPositive : null;

CashError? validateMovementNote(String note) => _requiredNote(note);

/// Catatan selisih wajib bila [difference] tidak nol.
CashError? validateClosingNote(Money difference, String note) {
  if (difference != Money.zero) return _requiredNote(note);
  return validateOpeningNote(note);
}

CashError? _requiredNote(String note) {
  if (note.trim().isEmpty) return CashError.required;
  if (_noteLength(note) > cashNoteMaxLength) return CashError.tooLong;
  return null;
}

int _noteLength(String note) => note.trim().characters.length;
