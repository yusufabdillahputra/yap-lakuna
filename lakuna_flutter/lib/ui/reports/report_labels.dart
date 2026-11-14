import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/repository_errors.dart';
import '../../data/services/report_document.dart';
import '../../data/services/spreadsheet_exporter.dart' show XlsxNumber;
import '../../l10n/gen/app_localizations.dart';
import '../core/date_range_label.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;
import '../customers/customer_labels.dart';
import '../history/history_labels.dart'
    show refundMethodLabel, returnReasonLabel;
import '../purchases/purchase_labels.dart' show formatCalendarDate;
import '../receipt/receipt_content.dart' show receiptDate;
import 'reports_view_model.dart';

export '../core/date_range_label.dart' show reportRangeLabel;

bool _en(AppLocalizations l10n) => l10n.localeName.startsWith('en');

/// `25,7%` (id) / `25.7%` (en); `–` bila tidak bermakna.
String percentLabel(AppLocalizations l10n, int? bp, {bool signed = false}) {
  if (bp == null) return '–';
  final text = formatPercentBp(bp, decimal: _en(l10n) ? '.' : ',');
  return signed && bp > 0 ? '+$text' : text;
}

/// Uang tanpa `BuildContext` (ekspor): `Rp 12.500` / `IDR 12,500`.
String moneyLabel(AppLocalizations l10n, Money m) =>
    _en(l10n) ? m.formatEn() : m.formatIdr();

/// Qty dengan pemisah bahasa, mis. `2,5` / `2.5`.
String qtyLabel(AppLocalizations l10n, Qty q) =>
    _en(l10n) ? q.format(decimal: '.', group: ',') : q.format();

String reportPeriodLabel(AppLocalizations l10n, ReportPeriod p) =>
    switch (p.kind) {
      ReportPeriodKind.today => l10n.reportsPeriodToday,
      ReportPeriodKind.last7Days => l10n.reportsPeriod7Days,
      ReportPeriodKind.thisMonth => l10n.reportsPeriodThisMonth,
      ReportPeriodKind.month => formatLongMonth(l10n, p.year, p.monthOfYear),
      ReportPeriodKind.custom => reportRangeLabel(l10n, p.range(DateTime(0))),
    };

/// Nama periode pembanding: *kemarin*, *7 hari sebelumnya*, atau bulannya.
String previousPeriodLabel(
  AppLocalizations l10n,
  ReportPeriod p,
  DateTime today,
) => switch (p.kind) {
  ReportPeriodKind.today => l10n.reportsPrevToday,
  ReportPeriodKind.last7Days => l10n.reportsPrev7Days,
  ReportPeriodKind.thisMonth => () {
    final r = p.previousRange(today);
    final month = formatLongMonth(l10n, r.to.year, r.to.month);
    return r.to.day == 1 ? '1 $month' : '1–${r.to.day} $month';
  }(),
  ReportPeriodKind.month => () {
    final from = p.previousRange(today).from;
    return formatLongMonth(l10n, from.year, from.month);
  }(),
  ReportPeriodKind.custom => l10n.reportsPrevDays(p.days),
};

String reportTabLabel(AppLocalizations l10n, ReportTab tab) => switch (tab) {
  ReportTab.summary => l10n.reportsTabSummary,
  ReportTab.sales => l10n.reportsTabSales,
  ReportTab.top => l10n.reportsTabTop,
  ReportTab.profit => l10n.reportsTabProfit,
  ReportTab.stock => l10n.reportsTabStock,
  ReportTab.cash => l10n.reportsTabCash,
  ReportTab.debts => l10n.reportsTabDebts,
  ReportTab.returns => l10n.reportsTabReturns,
};

String cashSourceLabel(AppLocalizations l10n, CashSourceKind k) => switch (k) {
  CashSourceKind.manualIn => l10n.reportsSourceManualIn,
  CashSourceKind.manualOut => l10n.reportsSourceManualOut,
  CashSourceKind.expense => l10n.reportsSourceExpense,
  CashSourceKind.expenseVoid => l10n.reportsSourceExpenseVoid,
  CashSourceKind.supplierPayment => l10n.reportsSourceSupplierPayment,
  CashSourceKind.purchase => l10n.reportsSourcePurchase,
  CashSourceKind.purchaseRefund => l10n.reportsSourcePurchaseRefund,
  CashSourceKind.debtPayment => l10n.reportsSourceDebtPayment,
  CashSourceKind.debtPaymentVoid => l10n.reportsSourceDebtPaymentVoid,
  CashSourceKind.supplierPaymentVoid => l10n.reportsSourceSupplierPaymentVoid,
  CashSourceKind.other => l10n.reportsSourceOther,
};

/// Cara refund retur; sebagian memotong piutang → `Tunai dari laci +
/// potong piutang`.
String returnRefundLabel(AppLocalizations l10n, ReturnReportLine r) {
  final method = refundMethodLabel(l10n, r.refundMethod);
  return r.debtReduction > Money.zero &&
          r.refundMethod != RefundMethod.debt &&
          r.debtReduction < r.amount
      ? l10n.reportsRefundMixed(method)
      : method;
}

/// Qty + satuan dasar varian [key], mis. `18 pcs`.
String unitQty(
  AppLocalizations l10n,
  Map<String, String> unitOf,
  String key,
  Qty q,
) {
  final unit = unitOf[key];
  final text = qtyLabel(l10n, q);
  return unit == null ? text : '$text $unit';
}

/// Uang bertanda untuk tampilan: `+ Rp 5.000` / `− Rp 5.000` / `Rp 0`.
String signedMoneyLabel(AppLocalizations l10n, Money m) => m.value == 0
    ? moneyLabel(l10n, m)
    : '${m.isNegative ? '−' : '+'} ${moneyLabel(l10n, Money(m.value.abs()))}';

String salesGroupLabel(AppLocalizations l10n, SalesGroup g) => switch (g) {
  SalesGroup.product => l10n.reportsGroupProduct,
  SalesGroup.staff => l10n.reportsGroupStaff,
  SalesGroup.category => l10n.reportsGroupCategory,
};

String reportMethodLabel(AppLocalizations l10n, ReportPaymentMethod m) =>
    switch (m) {
      ReportPaymentMethod.cash => paymentMethodLabel(l10n, PaymentMethod.cash),
      ReportPaymentMethod.card => paymentMethodLabel(l10n, PaymentMethod.card),
      ReportPaymentMethod.transfer => paymentMethodLabel(
        l10n,
        PaymentMethod.transfer,
      ),
      ReportPaymentMethod.qris => paymentMethodLabel(
        l10n,
        PaymentMethod.qrisStatic,
      ),
      ReportPaymentMethod.credit => l10n.reportsMethodCredit,
    };

String reportErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      NotPermitted() => l10n.reportsNotPermitted,
      _ => l10n.reportsLoadFailed,
    };

/// Nama baris rincian: kasir → nama staf, kategori kosong → *Tanpa
/// kategori*.
String breakdownName(
  AppLocalizations l10n,
  ReportData data,
  SalesGroup group,
  BreakdownRow row,
) => switch (group) {
  SalesGroup.staff => data.staffNames[row.key] ?? row.key,
  SalesGroup.category => row.name.isEmpty ? l10n.reportsNoCategory : row.name,
  SalesGroup.product => row.name,
};

/// Qty bersih + satuan dasar, mis. `3 pcs`.
String breakdownQty(AppLocalizations l10n, ReportData data, BreakdownRow r) {
  final unit = data.unitOf[r.key];
  final q = qtyLabel(l10n, r.quantity);
  return unit == null ? q : '$q $unit';
}

/// Kolom jumlah tab Penjualan: jumlah nota (kasir), qty dasar (produk),
/// atau `–` (kategori: satuan dasarnya bisa campur pcs dan kg).
String breakdownCount(
  AppLocalizations l10n,
  ReportData data,
  SalesGroup group,
  BreakdownRow r,
) => switch (group) {
  SalesGroup.staff => '${r.count}',
  SalesGroup.category => '–',
  SalesGroup.product => breakdownQty(l10n, data, r),
};

List<BreakdownRow> breakdownRows(ReportData data, SalesGroup group) =>
    switch (group) {
      SalesGroup.product => data.byProduct,
      SalesGroup.staff => data.byStaff,
      SalesGroup.category => data.byCategory,
    };

/// Baris laba rugi (label, nilai bertanda untuk tampilan, gaya).
enum PlStyle { item, detail, subtotal, total }

class PlLine {
  const PlLine(
    this.label,
    this.amount,
    this.style, {
    this.negative = false,
    this.positive = false,
  });

  final String label;

  /// Nilai mutlak yang ditampilkan.
  final Money amount;
  final PlStyle style;

  /// Ditampilkan dengan tanda `−`.
  final bool negative;

  /// Disorot hijau (laba kotor).
  final bool positive;

  /// Nilai bertanda untuk ekspor.
  Money get signed => negative ? -amount : amount;
}

/// Baris laba rugi sesuai urutan 1.24.
List<PlLine> profitLines(AppLocalizations l10n, ProfitAndLoss pl) => [
  PlLine(l10n.reportsPlGross, pl.grossSales, PlStyle.item),
  PlLine(l10n.reportsPlDiscount, pl.discount, PlStyle.detail, negative: true),
  if (pl.service.value != 0)
    PlLine(l10n.reportsPlService, pl.service, PlStyle.detail),
  if (pl.includedTax.value != 0)
    PlLine(
      l10n.reportsPlIncludedTax,
      pl.includedTax,
      PlStyle.detail,
      negative: true,
    ),
  if (pl.rounding.value != 0)
    PlLine(
      l10n.reportsPlRounding,
      Money(pl.rounding.value.abs()),
      PlStyle.detail,
      negative: pl.rounding.isNegative,
    ),
  PlLine(l10n.reportsPlReturns, pl.returns, PlStyle.detail, negative: true),
  PlLine(l10n.reportsPlNet, pl.netSales, PlStyle.subtotal),
  PlLine(l10n.reportsPlCogs, pl.cogs, PlStyle.detail, negative: true),
  PlLine(
    l10n.reportsPlGrossProfit(percentLabel(l10n, pl.grossMarginBp)),
    Money(pl.grossProfit.value.abs()),
    PlStyle.subtotal,
    negative: pl.grossProfit.isNegative,
    positive: !pl.grossProfit.isNegative,
  ),
  for (final e in pl.expenses)
    PlLine(
      e.name.isEmpty ? l10n.reportsNoCategory : e.name,
      e.amount,
      PlStyle.detail,
    ),
  PlLine(
    l10n.reportsPlExpensesTotal,
    pl.totalExpenses,
    PlStyle.subtotal,
    negative: true,
  ),
  PlLine(
    l10n.reportsPlAdjustment,
    Money(pl.stockAdjustment.value.abs()),
    PlStyle.item,
    negative: pl.stockAdjustment.isNegative,
  ),
  PlLine(
    l10n.reportsPlNetProfit,
    Money(pl.netProfit.value.abs()),
    PlStyle.total,
    negative: pl.netProfit.isNegative,
  ),
];

/// Catatan laba rugi: PB1 dipungut dan produk tanpa harga pokok.
List<String> profitNotes(AppLocalizations l10n, ProfitAndLoss pl) => [
  if (pl.taxCollected.value != 0)
    l10n.reportsPlTax(moneyLabel(l10n, pl.taxCollected)),
  if (pl.missingCostCount > 0) l10n.reportsPlMissingCost(pl.missingCostCount),
];

/// Tabel tab aktif untuk unduhan PDF/Excel.
ReportTable reportTable(
  AppLocalizations l10n,
  ReportData data,
  ReportTab tab,
  SalesGroup group, {
  StockReport? stock,
  CashReport? cash,
  DebtReport? debts,
  ReturnsReport? returns,
}) {
  final period = reportPeriodLabel(l10n, data.period);
  final subtitle = l10n.reportsDocSubtitle(
    data.outletName,
    formatLongDate(l10n, data.today),
  );
  XlsxNumber money(Money m) => XlsxNumber(m.value);
  String title(String name) => '$name · $period';
  switch (tab) {
    case ReportTab.summary:
      return ReportTable(
        title: title(l10n.reportsTabSummary),
        subtitle: subtitle,
        headers: [l10n.reportsColLine, l10n.reportsColAmount, ''],
        widths: const [36, 18, 18],
        rows: [
          ReportRow([
            l10n.reportsKpiSales,
            money(data.netSales),
            l10n.reportsKpiSalesNote(data.saleCount),
          ], strong: true),
          if (data.profit case final pl?)
            ReportRow([
              l10n.reportsKpiGrossProfit,
              money(pl.grossProfit),
              percentLabel(l10n, pl.grossMarginBp),
            ]),
          ReportRow([l10n.reportsKpiAverage, money(data.averagePerSale), '']),
          ReportRow([
            l10n.reportsKpiOverdue,
            money(data.overdue),
            l10n.reportsKpiOverdueNote(data.overdueCustomers),
          ]),
          ReportRow([l10n.reportsByMethod, null, null], strong: true),
          for (final m in data.payments)
            ReportRow([
              reportMethodLabel(l10n, m.method),
              money(m.amount),
              percentLabel(l10n, m.shareBp),
            ], indent: true),
          ReportRow([l10n.reportsTop, null, null], strong: true),
          for (final t in data.top.take(5))
            ReportRow([
              t.name,
              money(t.value),
              breakdownQty(l10n, data, t),
            ], indent: true),
        ],
        notes: [l10n.reportsByMethodNote, l10n.reportsSalesNote],
      );
    case ReportTab.sales:
      final rows = breakdownRows(data, group);
      final total = Money.sum(rows.map((r) => r.value));
      return ReportTable(
        title: title(
          '${l10n.reportsTabSales} ${salesGroupLabel(l10n, group).toLowerCase()}',
        ),
        subtitle: subtitle,
        headers: [
          switch (group) {
            SalesGroup.product => l10n.reportsColProduct,
            SalesGroup.staff => l10n.reportsColStaff,
            SalesGroup.category => l10n.reportsColCategory,
          },
          if (group == SalesGroup.staff)
            l10n.reportsColReceipts
          else
            l10n.reportsColQty,
          if (group == SalesGroup.staff)
            l10n.reportsColNet
          else
            l10n.reportsColValue,
          l10n.reportsColShare,
        ],
        widths: const [36, 14, 18, 10],
        rows: [
          for (final r in rows)
            ReportRow([
              breakdownName(l10n, data, group, r),
              if (group == SalesGroup.staff)
                r.count
              else
                breakdownCount(l10n, data, group, r),
              money(r.value),
              percentLabel(l10n, ratioBp(r.value, total)),
            ]),
          ReportRow([
            l10n.reportsTotal,
            if (group == SalesGroup.staff) data.saleCount else '',
            money(total),
            '',
          ], strong: true),
        ],
        notes: [l10n.reportsSalesNote],
      );
    case ReportTab.top:
      return ReportTable(
        title: title(l10n.reportsTabTop),
        subtitle: subtitle,
        headers: [
          l10n.reportsColRank,
          l10n.reportsColProduct,
          l10n.reportsColQty,
          l10n.reportsColValue,
        ],
        widths: const [5, 36, 14, 18],
        flex: const [1, 5, 2, 2],
        rows: [
          for (final (i, t) in data.top.indexed)
            ReportRow([
              '${i + 1}',
              t.name,
              breakdownQty(l10n, data, t),
              money(t.value),
            ]),
        ],
        notes: [l10n.reportsSalesNote],
      );
    case ReportTab.profit:
      final pl = data.profit!;
      return ReportTable(
        title: l10n.reportsPlTitle(period),
        subtitle: subtitle,
        headers: [l10n.reportsColLine, l10n.reportsColAmount],
        widths: const [44, 20],
        rows: [
          for (final line in profitLines(l10n, pl))
            ReportRow(
              [line.label, money(line.signed)],
              strong:
                  line.style == PlStyle.subtotal || line.style == PlStyle.total,
              indent: line.style == PlStyle.detail,
            ),
        ],
        notes: [...profitNotes(l10n, pl), l10n.reportsHowBody],
      );
    case ReportTab.stock:
      final r = stock!;
      final value = r.totalValue != null;
      return ReportTable(
        title: title(l10n.reportsTabStock),
        subtitle: subtitle,
        headers: [
          l10n.reportsColProduct,
          l10n.reportsColOpening,
          l10n.reportsColIn,
          l10n.reportsColOut,
          l10n.reportsColClosing,
          if (value) l10n.reportsColClosingValue,
        ],
        widths: [36, 12, 12, 12, 12, if (value) 18],
        flex: [4, 2, 2, 2, 2, if (value) 3],
        rows: [
          for (final x in r.rows)
            ReportRow([
              x.name,
              unitQty(l10n, r.unitOf, x.key, x.opening),
              unitQty(l10n, r.unitOf, x.key, x.inflow),
              unitQty(l10n, r.unitOf, x.key, x.outflow),
              unitQty(l10n, r.unitOf, x.key, x.closing),
              if (value) money(x.value!),
            ]),
          if (value)
            ReportRow([
              l10n.reportsTotal,
              '',
              '',
              '',
              '',
              money(Money.sum(r.rows.map((x) => x.value!))),
            ], strong: true),
        ],
        notes: [
          if (r.totalValue case final v?)
            '${l10n.reportsStockValue}: ${moneyLabel(l10n, v)}',
          '${l10n.reportsStockItems}: ${r.variantCount} · '
              '${l10n.reportsStockLow}: ${r.lowCount} · '
              '${l10n.reportsStockOut}: ${r.outCount}',
          l10n.reportsStockNote,
        ],
      );
    case ReportTab.cash:
      final r = cash!;
      return ReportTable(
        title: title(l10n.reportsTabCash),
        subtitle: subtitle,
        headers: [
          l10n.reportsColOpened,
          l10n.reportsColStaff,
          l10n.reportsColOpeningCash,
          l10n.reportsColExpected,
          l10n.reportsColCounted,
          l10n.reportsColDifference,
        ],
        widths: const [16, 22, 16, 16, 16, 16],
        flex: const [3, 3, 2, 2, 2, 2],
        rows: [
          for (final x in r.sessions)
            ReportRow([
              receiptDate(x.openedAt),
              x.staffName,
              money(x.opening),
              money(x.expected),
              if (x.counted case final c?) money(c) else null,
              if (x.difference case final d?) money(d) else null,
            ]),
          ReportRow([
            l10n.reportsTotal,
            '',
            '',
            '',
            '',
            money(r.totalDifference),
          ], strong: true),
        ],
        notes: [
          '${l10n.reportsCashMovements} (${l10n.reportsCashMovementsNote.toLowerCase()}):',
          for (final g in r.inflows)
            '${cashSourceLabel(l10n, g.key)} (${g.count}×): '
                '${signedMoneyLabel(l10n, g.total)}',
          for (final g in r.outflows)
            '${cashSourceLabel(l10n, g.key)} (${g.count}×): '
                '${signedMoneyLabel(l10n, -g.total)}',
          if (r.inflows.isEmpty && r.outflows.isEmpty)
            l10n.reportsCashNoMovements,
          if (r.openCount > 0) l10n.reportsCashOpenNote,
          l10n.reportsCashNote,
        ],
      );
    case ReportTab.debts:
      final r = debts!;
      return ReportTable(
        title:
            '${l10n.reportsTabDebts} · '
            '${l10n.reportsDebtAsOf(formatLongDate(l10n, r.today))}',
        subtitle: subtitle,
        headers: [
          l10n.reportsColLine,
          l10n.reportsColOpenCount,
          l10n.reportsColOverdueCount,
          l10n.reportsColNearestDue,
          l10n.reportsColRemaining,
        ],
        widths: const [36, 14, 14, 18, 18],
        flex: const [4, 2, 2, 2, 2],
        rows: [
          ReportRow([
            l10n.reportsDebtCustomers,
            null,
            null,
            null,
            null,
          ], strong: true),
          for (final c in r.customers)
            ReportRow([
              c.customer.name,
              c.openCount,
              c.overdueCount,
              null,
              money(c.outstanding),
            ], indent: true),
          ReportRow([
            l10n.reportsTotal,
            null,
            null,
            null,
            money(r.receivable),
          ], strong: true),
          ReportRow([
            l10n.reportsDebtSuppliers,
            null,
            null,
            null,
            null,
          ], strong: true),
          for (final x in r.suppliers)
            ReportRow([
              x.supplier.name,
              x.openCount,
              x.overdueCount,
              if (x.nearestDue case final d?) formatCalendarDate(d) else null,
              money(x.debt),
            ], indent: true),
          ReportRow([
            l10n.reportsTotal,
            null,
            null,
            null,
            money(r.payable),
          ], strong: true),
        ],
        notes: [
          '${l10n.reportsKpiOverdue}: ${moneyLabel(l10n, r.overdue)} '
              '(${l10n.reportsKpiOverdueNote(r.overdueCustomers)})',
          l10n.reportsDebtNote,
        ],
      );
    case ReportTab.returns:
      final r = returns!;
      return ReportTable(
        title: title(l10n.reportsTabReturns),
        subtitle: subtitle,
        headers: [
          l10n.reportsColTime,
          l10n.reportsColReturnNo,
          l10n.reportsColReceiptNo,
          l10n.reportsColHandledBy,
          l10n.reportsColReason,
          l10n.reportsColRestock,
          l10n.reportsColRefund,
          l10n.reportsColAmount,
        ],
        widths: const [15, 24, 22, 16, 16, 8, 12, 14],
        flex: const [3, 4, 4, 3, 3, 2, 2, 3],
        rows: [
          for (final x in r.lines)
            ReportRow([
              receiptDate(x.returnedAt),
              x.number,
              x.saleNumber,
              x.staffName,
              returnReasonLabel(l10n, x.reason),
              x.restock ? l10n.reportsYes : l10n.reportsNo,
              returnRefundLabel(l10n, x),
              money(x.amount),
            ]),
          ReportRow([
            l10n.reportsTotal,
            '',
            '',
            '',
            '',
            '',
            '',
            money(r.total),
          ], strong: true),
        ],
        notes: [
          for (final g in r.byReason)
            '${returnReasonLabel(l10n, g.key)} (${g.count}×): '
                '${moneyLabel(l10n, g.total)}',
        ],
      );
  }
}
