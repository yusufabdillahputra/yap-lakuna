import 'expense.dart' show DateRange;
import 'money.dart';
import 'qty.dart';
import 'rounding.dart';

// --- Periode ----------------------------------------------------------------

enum ReportPeriodKind { today, last7Days, thisMonth, month }

/// Periode laporan (F1-16): hari ini, 7 hari terakhir, bulan ini, atau satu
/// bulan kalender tertentu. Tanggal = tanggal lokal cabang (UTC tengah malam).
class ReportPeriod {
  const ReportPeriod._(this.kind, [this.year = 0, this.monthOfYear = 0]);

  /// Bulan kalender [year]-[monthOfYear].
  const ReportPeriod.month(int year, int monthOfYear)
    : this._(ReportPeriodKind.month, year, monthOfYear);

  static const today = ReportPeriod._(ReportPeriodKind.today);
  static const last7Days = ReportPeriod._(ReportPeriodKind.last7Days);
  static const thisMonth = ReportPeriod._(ReportPeriodKind.thisMonth);

  final ReportPeriodKind kind;

  /// Hanya untuk [ReportPeriodKind.month].
  final int year;
  final int monthOfYear;

  static DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  static DateRange _monthRange(int y, int m) =>
      DateRange(DateTime.utc(y, m), DateTime.utc(y, m + 1, 0));

  /// Rentang inklusif periode ini relatif ke [today].
  DateRange range(DateTime today) {
    final t = _day(today);
    return switch (kind) {
      ReportPeriodKind.today => DateRange(t, t),
      ReportPeriodKind.last7Days => DateRange(
        DateTime.utc(t.year, t.month, t.day - 6),
        t,
      ),
      ReportPeriodKind.thisMonth => _monthRange(t.year, t.month),
      ReportPeriodKind.month => _monthRange(year, monthOfYear),
    };
  }

  /// Rentang pembanding: hari/7 hari sebelumnya, tanggal yang sama bulan lalu
  /// (bulan ini), atau bulan sebelumnya.
  DateRange previousRange(DateTime today) {
    final r = range(today);
    return switch (kind) {
      ReportPeriodKind.today || ReportPeriodKind.last7Days => DateRange(
        DateTime.utc(
          r.from.year,
          r.from.month,
          r.from.day - (kind == ReportPeriodKind.today ? 1 : 7),
        ),
        DateTime.utc(r.from.year, r.from.month, r.from.day - 1),
      ),
      ReportPeriodKind.thisMonth => () {
        // Tanggal 1 s.d. hari yang sama bulan lalu (dipotong di akhir bulan).
        final t = _day(today);
        final last = DateTime.utc(t.year, t.month, 0);
        return DateRange(
          DateTime.utc(last.year, last.month),
          DateTime.utc(last.year, last.month, t.day.clamp(1, last.day)),
        );
      }(),
      ReportPeriodKind.month => _monthRange(r.from.year, r.from.month - 1),
    };
  }

  /// Bagian nama berkas ekspor: `hari-ini`, `7-hari`, atau `yyyy-mm`.
  String fileKey(DateTime today) => switch (kind) {
    ReportPeriodKind.today => 'hari-ini',
    ReportPeriodKind.last7Days => '7-hari',
    _ => () {
      final from = range(today).from;
      return '${from.year}-${from.month.toString().padLeft(2, '0')}';
    }(),
  };

  @override
  bool operator ==(Object other) =>
      other is ReportPeriod &&
      other.kind == kind &&
      other.year == year &&
      other.monthOfYear == monthOfYear;

  @override
  int get hashCode => Object.hash(kind, year, monthOfYear);

  @override
  String toString() => kind == ReportPeriodKind.month
      ? 'ReportPeriod.month($year, $monthOfYear)'
      : 'ReportPeriod.${kind.name}';
}

/// Pilihan periode: hari ini, 7 hari, bulan ini, lalu 12 bulan sebelumnya
/// (terbaru dulu).
List<ReportPeriod> reportPeriodChoices(DateTime today) => [
  ReportPeriod.today,
  ReportPeriod.last7Days,
  ReportPeriod.thisMonth,
  for (var i = 1; i <= 12; i++)
    () {
      final d = DateTime.utc(today.year, today.month - i);
      return ReportPeriod.month(d.year, d.month);
    }(),
];

// --- Persen -----------------------------------------------------------------

/// [part] / [whole] dalam basis poin (bulat setengah menjauhi nol), atau
/// `null` bila [whole] ≤ 0.
int? ratioBp(Money part, Money whole) => whole.value <= 0
    ? null
    : divRoundHalfAway(
        BigInt.from(part.value) * BigInt.from(10000),
        BigInt.from(whole.value),
      );

/// Perubahan [current] terhadap [previous] dalam basis poin, atau `null`
/// bila [previous] ≤ 0 (persen tidak bermakna).
int? changeBp(Money current, Money previous) =>
    previous.value <= 0 ? null : ratioBp(current - previous, previous);

/// `2570` → `25,7%` (satu desimal).
String formatPercentBp(int bp, {String decimal = ','}) {
  final tenths = divRoundHalfAway(BigInt.from(bp), BigInt.from(10));
  final abs = tenths.abs();
  final sign = tenths < 0 ? '-' : '';
  return '$sign${abs ~/ 10}$decimal${abs % 10}%';
}

/// Bagian PB1 dari nilai retur [amount] nota bertotal [saleTotal] dengan PB1
/// [saleTax], proporsional, bulat setengah menjauhi nol.
Money returnTaxShare({
  required Money amount,
  required Money saleTax,
  required Money saleTotal,
}) {
  if (saleTax.value <= 0 || saleTotal.value <= 0) return Money.zero;
  return Money(
    divRoundHalfAway(
      BigInt.from(amount.value) * BigInt.from(saleTax.value),
      BigInt.from(saleTotal.value),
    ),
  );
}

// --- Fakta masukan ----------------------------------------------------------

/// Metode bayar untuk laporan; [credit] = bagian nota yang belum dibayar
/// saat jual (piutang).
enum ReportPaymentMethod { cash, card, transfer, qris, credit }

class ReportPayment {
  const ReportPayment(this.method, this.amount, this.change);

  final ReportPaymentMethod method;
  final Money amount;

  /// Kembalian (hanya tunai).
  final Money change;

  Money get net => amount - change;
}

/// Baris nota: jumlah dalam mili-satuan baris, [factorMilli] = isi satu
/// satuan baris dalam mili-satuan dasar, [unitCost] per satuan dasar.
class ReportSaleLine {
  const ReportSaleLine({
    required this.key,
    required this.variantKey,
    required this.name,
    required this.quantityMilli,
    required this.factorMilli,
    required this.lineTotal,
    required this.unitCost,
  });

  final String key;
  final String variantKey;
  final String name;
  final int quantityMilli;
  final int factorMilli;
  final Money lineTotal;
  final Money unitCost;

  Qty baseQty(int milli) => Qty(milli).toBaseUnit(factorMilli);

  Money costOf(int milli) => unitCost.timesMilli(baseQty(milli).milli);
}

/// Nota terhitung (bukan void, bukan open bill).
class ReportSale {
  const ReportSale({
    required this.staffKey,
    required this.subtotal,
    required this.tierDiscount,
    required this.service,
    required this.tax,
    required this.total,
    required this.credit,
    this.taxInclusive = false,
    this.rounding = Money.zero,
    required this.paidAtSale,
    required this.payments,
    required this.lines,
  });

  final String staffKey;
  final Money subtotal;
  final Money tierDiscount;
  final Money service;
  final Money tax;
  final Money total;

  /// PB1 sudah termasuk harga (bagian dari [subtotal], bukan tambahan).
  final bool taxInclusive;

  /// Selisih pembulatan total (bagian dari [total]).
  final Money rounding;

  /// Nota kredit (berpelanggan dan belum lunas saat jual).
  final bool credit;
  final Money paidAtSale;
  final List<ReportPayment> payments;
  final List<ReportSaleLine> lines;

  /// PB1 yang terkandung dalam harga (nol bila pajak ditambahkan).
  Money get includedTax => taxInclusive ? tax : Money.zero;

  /// Bagian nota yang menjadi penjualan bersih (tanpa PB1, dengan
  /// pembulatan).
  Money get netContribution =>
      subtotal - tierDiscount + service - includedTax + rounding;
}

class ReportReturnLine {
  const ReportReturnLine(this.line, this.quantityMilli);

  /// Baris nota asal.
  final ReportSaleLine line;

  /// Jumlah diretur dalam satuan baris (mili).
  final int quantityMilli;
}

/// Dokumen retur pada periode beserta data nota asalnya.
class ReportReturn {
  const ReportReturn({
    required this.saleStaffKey,
    required this.amount,
    required this.saleTax,
    required this.saleTotal,
    required this.restock,
    required this.lines,
  });

  final String saleStaffKey;
  final Money amount;
  final Money saleTax;
  final Money saleTotal;
  final bool restock;
  final List<ReportReturnLine> lines;

  Money get taxShare =>
      returnTaxShare(amount: amount, saleTax: saleTax, saleTotal: saleTotal);

  /// Nilai retur yang mengurangi penjualan bersih (tanpa PB1).
  Money get netAmount => amount - taxShare;
}

class ExpenseLine {
  const ExpenseLine(this.name, this.amount);

  final String name;
  final Money amount;
}

// --- Laba rugi --------------------------------------------------------------

class ProfitAndLoss {
  const ProfitAndLoss({
    required this.grossSales,
    required this.discount,
    required this.service,
    required this.returns,
    required this.cogs,
    this.includedTax = Money.zero,
    this.rounding = Money.zero,
    required this.expenses,
    required this.stockAdjustment,
    required this.taxCollected,
    required this.missingCostCount,
    required this.saleCount,
  });

  /// Laba rugi dari dokumen periode (aturan di spec F1-16).
  factory ProfitAndLoss.compute({
    required List<ReportSale> sales,
    required List<ReportReturn> returns,
    required List<ExpenseLine> expenses,
    required Money stockAdjustment,
  }) {
    var cogs = Money.zero;
    final missing = <String>{};
    for (final s in sales) {
      for (final l in s.lines) {
        cogs += l.costOf(l.quantityMilli);
        if (l.unitCost.value == 0) missing.add(l.variantKey);
      }
    }
    for (final r in returns) {
      if (!r.restock) continue;
      for (final rl in r.lines) {
        cogs -= rl.line.costOf(rl.quantityMilli);
      }
    }
    final byName = <String, Money>{};
    for (final e in expenses) {
      byName[e.name] = (byName[e.name] ?? Money.zero) + e.amount;
    }
    final lines = [for (final e in byName.entries) ExpenseLine(e.key, e.value)]
      ..sort((a, b) {
        final c = b.amount.compareTo(a.amount);
        return c != 0 ? c : a.name.compareTo(b.name);
      });
    return ProfitAndLoss(
      grossSales: Money.sum(sales.map((s) => s.subtotal)),
      discount: Money.sum(sales.map((s) => s.tierDiscount)),
      service: Money.sum(sales.map((s) => s.service)),
      includedTax: Money.sum(sales.map((s) => s.includedTax)),
      rounding: Money.sum(sales.map((s) => s.rounding)),
      returns: Money.sum(returns.map((r) => r.netAmount)),
      cogs: cogs,
      expenses: lines,
      stockAdjustment: stockAdjustment,
      taxCollected:
          Money.sum(sales.map((s) => s.tax)) -
          Money.sum(returns.map((r) => r.taxShare)),
      missingCostCount: missing.length,
      saleCount: sales.length,
    );
  }

  final Money grossSales;
  final Money discount;
  final Money service;

  /// PB1 yang terkandung dalam harga nota "harga sudah termasuk pajak".
  final Money includedTax;

  /// Selisih pembulatan total nota.
  final Money rounding;

  /// Retur penjualan tanpa bagian PB1.
  final Money returns;
  final Money cogs;

  /// Beban operasional per jenis, terbesar dulu.
  final List<ExpenseLine> expenses;

  /// Nilai penyesuaian stok bertanda (negatif = rugi).
  final Money stockAdjustment;

  /// PB1 dipungut (bukan pendapatan).
  final Money taxCollected;

  /// Varian terjual dengan harga pokok 0.
  final int missingCostCount;
  final int saleCount;

  Money get netSales =>
      grossSales - discount + service - includedTax + rounding - returns;
  Money get grossProfit => netSales - cogs;
  int? get grossMarginBp => ratioBp(grossProfit, netSales);
  Money get totalExpenses => Money.sum(expenses.map((e) => e.amount));
  Money get netProfit => grossProfit - totalExpenses + stockAdjustment;
  int? get expenseRatioBp => ratioBp(totalExpenses, netSales);
}

// --- Rincian penjualan ------------------------------------------------------

class BreakdownRow {
  const BreakdownRow({
    required this.key,
    required this.name,
    required this.value,
    this.quantity = Qty.zero,
    this.count = 0,
  });

  final String key;
  final String name;

  /// Jumlah bersih dalam satuan dasar (produk/kategori).
  final Qty quantity;

  /// Jumlah nota (kasir).
  final int count;

  /// Penjualan bersih tanpa PB1.
  final Money value;
}

int _byValueThenName(BreakdownRow a, BreakdownRow b) {
  final c = b.value.compareTo(a.value);
  return c != 0 ? c : a.name.compareTo(b.name);
}

/// Per varian: qty dasar terjual − diretur, nilai `line_total` − nilai retur
/// proporsional qty (kumulatif per baris, bulat ke bawah). Nama dari baris
/// nota terakhir. Urut nilai menurun lalu nama.
List<BreakdownRow> salesByProduct(
  List<ReportSale> sales,
  List<ReportReturn> returns,
) {
  final qty = <String, int>{};
  final value = <String, Money>{};
  final names = <String, String>{};
  void add(ReportSaleLine l, int baseMilli, Money v) {
    qty[l.variantKey] = (qty[l.variantKey] ?? 0) + baseMilli;
    value[l.variantKey] = (value[l.variantKey] ?? Money.zero) + v;
    names[l.variantKey] = l.name;
  }

  for (final s in sales) {
    for (final l in s.lines) {
      add(l, l.baseQty(l.quantityMilli).milli, l.lineTotal);
    }
  }
  final returned = <String, (ReportSaleLine, int)>{};
  for (final r in returns) {
    for (final rl in r.lines) {
      final prev = returned[rl.line.key]?.$2 ?? 0;
      returned[rl.line.key] = (rl.line, prev + rl.quantityMilli);
    }
  }
  for (final (line, milli) in returned.values) {
    final v = milli >= line.quantityMilli
        ? line.lineTotal
        : Money(
            (BigInt.from(line.lineTotal.value) *
                    BigInt.from(milli) ~/
                    BigInt.from(line.quantityMilli))
                .toInt(),
          );
    names.putIfAbsent(line.variantKey, () => line.name);
    qty[line.variantKey] =
        (qty[line.variantKey] ?? 0) - line.baseQty(milli).milli;
    value[line.variantKey] = (value[line.variantKey] ?? Money.zero) - v;
  }
  return [
    for (final k in names.keys)
      BreakdownRow(
        key: k,
        name: names[k]!,
        quantity: Qty(qty[k] ?? 0),
        value: value[k] ?? Money.zero,
      ),
  ]..sort(_byValueThenName);
}

/// Baris per produk dikelompokkan [categoryOf] (kunci varian → nama
/// kategori); tanpa kategori = kunci dan nama kosong.
List<BreakdownRow> salesByCategory(
  List<BreakdownRow> products,
  Map<String, String?> categoryOf,
) {
  final qty = <String, int>{};
  final value = <String, Money>{};
  for (final p in products) {
    final c = categoryOf[p.key] ?? '';
    qty[c] = (qty[c] ?? 0) + p.quantity.milli;
    value[c] = (value[c] ?? Money.zero) + p.value;
  }
  return [
    for (final c in value.keys)
      BreakdownRow(key: c, name: c, quantity: Qty(qty[c]!), value: value[c]!),
  ]..sort(_byValueThenName);
}

/// Per kasir nota: jumlah nota dan penjualan bersih (bagian nota − retur
/// tanpa PB1). Nama = kunci; aplikasi menerjemahkan ke nama staf.
List<BreakdownRow> salesByStaff(
  List<ReportSale> sales,
  List<ReportReturn> returns,
) {
  final count = <String, int>{};
  final value = <String, Money>{};
  for (final s in sales) {
    count[s.staffKey] = (count[s.staffKey] ?? 0) + 1;
    value[s.staffKey] = (value[s.staffKey] ?? Money.zero) + s.netContribution;
  }
  for (final r in returns) {
    count.putIfAbsent(r.saleStaffKey, () => 0);
    value[r.saleStaffKey] = (value[r.saleStaffKey] ?? Money.zero) - r.netAmount;
  }
  return [
    for (final k in count.keys)
      BreakdownRow(key: k, name: k, count: count[k]!, value: value[k]!),
  ]..sort(_byValueThenName);
}

/// Produk terlaris: qty bersih menurun, lalu nilai, lalu nama. Produk
/// dengan qty ≤ 0 tidak ikut.
List<BreakdownRow> topProducts(List<BreakdownRow> products, {int limit = 20}) {
  final rows = products.where((p) => p.quantity.milli > 0).toList()
    ..sort((a, b) {
      final q = b.quantity.milli.compareTo(a.quantity.milli);
      return q != 0 ? q : _byValueThenName(a, b);
    });
  return rows.take(limit).toList();
}

// --- Metode bayar -----------------------------------------------------------

class PaymentMixRow {
  const PaymentMixRow(this.method, this.amount, this.shareBp);

  final ReportPaymentMethod method;
  final Money amount;

  /// Porsi terhadap Σ total nota.
  final int shareBp;
}

/// Penjualan per metode bayar (sebelum retur): tunai bersih kembalian,
/// non tunai, dan kredit (total − dibayar saat jual). Hanya metode bernilai,
/// urut terbesar.
List<PaymentMixRow> paymentMix(List<ReportSale> sales) {
  final sums = <ReportPaymentMethod, Money>{};
  void add(ReportPaymentMethod m, Money v) {
    if (v.value == 0) return;
    sums[m] = (sums[m] ?? Money.zero) + v;
  }

  for (final s in sales) {
    for (final p in s.payments) {
      add(p.method, p.net);
    }
    if (s.credit) add(ReportPaymentMethod.credit, s.total - s.paidAtSale);
  }
  final whole = Money.sum(sums.values);
  return [
    for (final e in sums.entries)
      PaymentMixRow(e.key, e.value, ratioBp(e.value, whole) ?? 0),
  ]..sort((a, b) {
    final c = b.amount.compareTo(a.amount);
    return c != 0 ? c : a.method.index.compareTo(b.method.index);
  });
}

// --- Stok (v0.21.0) ---------------------------------------------------------

/// Satu pergerakan stok (qty milli satuan dasar, positif = masuk).
class StockMove {
  const StockMove({
    required this.key,
    required this.quantityMilli,
    required this.at,
  });

  final String key;
  final int quantityMilli;
  final DateTime at;
}

/// Kartu stok ringkas satu varian pada periode.
class StockMovementRow {
  const StockMovementRow({
    required this.key,
    required this.name,
    required this.opening,
    required this.inflow,
    required this.outflow,
    this.value,
  });

  final String key;
  final String name;
  final Qty opening;
  final Qty inflow;

  /// Nilai mutlak pergerakan keluar.
  final Qty outflow;

  /// Akhir × harga pokok saat ini; `null` tanpa izin laba.
  final Money? value;

  Qty get closing => opening + inflow - outflow;
}

/// Kartu stok ringkas per varian di [names] dari stok saat ini ([current],
/// qty milli) dan pergerakan sejak [start] ([moves]; yang lebih awal
/// diabaikan): awal = saat ini − Σ pergerakan sejak [start]; masuk dan
/// keluar = pergerakan dalam `[start, end)`. Hanya pergerakan sejak awal
/// periode yang perlu dimuat. Varian tanpa stok dan tanpa pergerakan
/// dilewati. Dengan [valueOf] (nilai stok akhir), baris urut nilai menurun;
/// tanpa itu urut nama.
List<StockMovementRow> stockMovementRows({
  required Iterable<StockMove> moves,
  required DateTime start,
  required DateTime end,
  required Map<String, String> names,
  required Map<String, int> current,
  Money Function(String key, Qty closing)? valueOf,
}) {
  final since = <String, int>{};
  final inflow = <String, int>{};
  final outflow = <String, int>{};
  final moved = <String>{};
  for (final m in moves) {
    if (!names.containsKey(m.key) || m.at.isBefore(start)) continue;
    since[m.key] = (since[m.key] ?? 0) + m.quantityMilli;
    if (!m.at.isBefore(end)) continue;
    moved.add(m.key);
    if (m.quantityMilli >= 0) {
      inflow[m.key] = (inflow[m.key] ?? 0) + m.quantityMilli;
    } else {
      outflow[m.key] = (outflow[m.key] ?? 0) - m.quantityMilli;
    }
  }
  final rows = <StockMovementRow>[];
  for (final MapEntry(:key, value: name) in names.entries) {
    final opening = Qty((current[key] ?? 0) - (since[key] ?? 0));
    final row = StockMovementRow(
      key: key,
      name: name,
      opening: opening,
      inflow: Qty(inflow[key] ?? 0),
      outflow: Qty(outflow[key] ?? 0),
    );
    if (!moved.contains(key) &&
        row.opening == Qty.zero &&
        row.closing == Qty.zero) {
      continue;
    }
    rows.add(
      valueOf == null
          ? row
          : StockMovementRow(
              key: key,
              name: name,
              opening: row.opening,
              inflow: row.inflow,
              outflow: row.outflow,
              value: valueOf(key, row.closing),
            ),
    );
  }
  rows.sort((a, b) {
    if (valueOf != null) {
      final c = b.value!.compareTo(a.value!);
      if (c != 0) return c;
    }
    final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    return n != 0 ? n : a.key.compareTo(b.key);
  });
  return rows;
}

/// Nilai stok [qty] dari stok saat ini senilai [value] untuk [current]
/// (rata-rata tertimbang semua lokasi): tepat [value] bila [qty] =
/// [current], selain itu proporsional (bulat setengah menjauhi nol). Tanpa
/// stok saat ini memakai [fallback] per satuan dasar.
Money stockValueOf({
  required Money value,
  required Qty current,
  required Qty qty,
  required Money fallback,
}) {
  if (qty == current) return value;
  if (current.milli <= 0) return fallback.timesMilli(qty.milli);
  return Money(
    divRoundHalfAway(
      BigInt.from(value.value) * BigInt.from(qty.milli),
      BigInt.from(current.milli),
    ),
  );
}

// --- Kelompok total (kas, retur) --------------------------------------------

/// Jumlah catatan dan total per kunci.
class GroupTotal<K> {
  const GroupTotal(this.key, this.count, this.total);

  final K key;
  final int count;
  final Money total;
}

/// Mengelompokkan [items] per kunci: urut total menurun, lalu kunci
/// (`toString`).
List<GroupTotal<K>> groupTotals<K>(Iterable<(K, Money)> items) {
  final count = <K, int>{};
  final total = <K, Money>{};
  for (final (key, amount) in items) {
    count[key] = (count[key] ?? 0) + 1;
    total[key] = (total[key] ?? Money.zero) + amount;
  }
  return [
    for (final key in count.keys) GroupTotal(key, count[key]!, total[key]!),
  ]..sort((a, b) {
    final c = b.total.compareTo(a.total);
    return c != 0 ? c : '${a.key}'.compareTo('${b.key}');
  });
}
