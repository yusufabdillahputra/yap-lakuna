import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/services/report_document.dart';
import '../../data/services/spreadsheet_exporter.dart' show XlsxNumber;
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart' show formatClock;
import '../customers/customer_labels.dart' show formatLongDate;
import '../reports/report_labels.dart' show moneyLabel, qtyLabel;
import 'purchase_labels.dart' show formatCalendarDate;

/// Isi PDF *Cetak / bagikan PDF* pembelian [d] (F1-12c): barang, ringkasan
/// bayar, retur, dan catatan. Baris ringkasan bernilai nol yang opsional
/// (diskon, ongkir, bayar hutang, retur) tidak dicetak.
ReportTable purchasePrintTable(
  AppLocalizations l10n,
  PurchaseDetail d, {
  required String staff,
  required DateTime printedAt,
  String? timezone,
}) {
  final p = d.purchase;
  XlsxNumber money(Money m) => XlsxNumber(m.value);
  ReportRow sum(String label, Money value, {bool strong = false}) =>
      ReportRow([label, '', '', money(value)], strong: strong);
  final local = outletLocalTime(printedAt, timezone);
  return ReportTable(
    title: l10n.purchasePrintTitle(p.number),
    subtitle: [
      d.supplier?.name ?? l10n.purchasesNoSupplier,
      if (p.invoiceNo case final no?) l10n.purchasePrintInvoiceNo(no),
      formatCalendarDate(p.purchasedOn),
      d.locationName,
      '${d.staffName} · ${d.deviceCode}',
    ].join(' · '),
    headers: [
      l10n.purchaseColProduct,
      l10n.purchaseColQty,
      l10n.purchaseColPrice,
      l10n.purchaseColSubtotal,
    ],
    widths: [40, 18, 16, 16],
    flex: [6, 3, 3, 3],
    rows: [
      for (final item in d.items)
        ReportRow([
          [
            item.variantName.isEmpty
                ? item.productName
                : '${item.productName} ${item.variantName}',
            ?d.skus[item.variantId],
          ].join(' · '),
          [
            '${qtyLabel(l10n, Qty(item.quantityMilli))} ${item.unitName}',
            if (item.factorMilli != 1000)
              '(${qtyLabel(l10n, Qty(item.factorMilli))} '
                  '${d.baseUnits[item.variantId] ?? ''})',
          ].join(' '),
          money(Money(item.unitPrice)),
          money(Money(item.lineTotal)),
        ]),
      sum(l10n.purchaseSubtotal, Money(p.subtotal)),
      if (p.discount > 0) sum(l10n.purchaseDiscount, Money(-p.discount)),
      if (p.shipping > 0) sum(l10n.purchaseShipping, Money(p.shipping)),
      sum(l10n.purchaseTotal, Money(p.total), strong: true),
      sum(l10n.purchasePrintPaidUpfront, Money(p.paidAmount)),
      if (d.debtPayments.isNotEmpty)
        sum(l10n.purchasePrintDebtPaid, d.debtPaid),
      if (d.returns.isNotEmpty) sum(l10n.purchaseReturned, d.returnedAmount),
      sum(l10n.purchaseDebt, d.debt, strong: true),
    ],
    notes: [
      if (p.dueOn case final due? when d.debt.value > 0)
        l10n.purchasePrintDue(formatCalendarDate(due)),
      if (p.note case final note? when note.trim().isNotEmpty)
        l10n.purchasePrintNoteLine(note.trim()),
      for (final r in d.returns)
        l10n.purchasePrintReturn(
          r.number,
          formatCalendarDate(outletLocalTime(r.returnedAt, timezone)),
          moneyLabel(l10n, Money(r.amount)),
        ),
      l10n.purchasePrintPrinted(
        '${formatLongDate(l10n, local)} ${formatClock(printedAt, timezone)}',
        staff,
      ),
    ],
  );
}

/// `pembelian-<nomor>.pdf`, nomor huruf kecil. Cetak ulang menimpa berkas
/// lama dengan isi terbaru.
String purchasePrintFileName(String number) =>
    'pembelian-${number.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-')}.pdf';
