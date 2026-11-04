import 'package:lakuna_client/lakuna_client.dart' show DebtPayment;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/customers_repository.dart';
import '../../data/services/kuitansi_pdf.dart';
import '../../l10n/gen/app_localizations.dart';
import '../receipt/receipt_content.dart';
import 'customer_labels.dart';

String _money(AppLocalizations l10n, Money m) =>
    l10n.localeName.startsWith('en') ? m.formatEn() : m.formatIdr();

String _dueNote(AppLocalizations l10n, DebtPaymentReceipt r) {
  final rest = r.balanceAfter;
  return l10n.kuitansiFootnote(r.customer.name, _money(l10n, rest));
}

/// Isi kuitansi A5 (1.20b) untuk PDF dan pratinjau.
KuitansiDocument kuitansiDocument(
  AppLocalizations l10n, {
  required DebtPaymentReceipt receipt,
  required CustomersSetup setup,
  required bool copy,
  required bool showDetails,
  required bool showBalance,
  required String city,
}) {
  final p = receipt.payment;
  final paidOn = p.paidOn;
  final date = formatLongDate(
    l10n,
    DateTime(paidOn.year, paidOn.month, paidOn.day),
  );
  return KuitansiDocument(
    title: l10n.kuitansiDocTitle,
    number: p.number,
    storeName: setup.businessName,
    storeLine: [
      setup.outletName,
      ?setup.outletAddress,
      ?setup.outletPhone,
    ].join(' · '),
    banner: copy ? l10n.kuitansiCopy : null,
    fields: [
      KuitansiField(l10n.kuitansiReceivedFrom, receipt.customer.name),
      KuitansiField(
        l10n.kuitansiAmountWords,
        rupiahInWords(receipt.amount),
        italic: true,
      ),
      KuitansiField(
        l10n.kuitansiFor,
        showDetails
            ? l10n.kuitansiForDetails(receipt.lines.length)
            : l10n.kuitansiForShort(receipt.lines.length),
      ),
      KuitansiField(l10n.kuitansiMethod, debtPaymentMethodLabel(l10n, p)),
      if (p.note case final note?) KuitansiField(l10n.kuitansiNote, note),
    ],
    tableHead: showDetails
        ? [
            l10n.kuitansiColInvoice,
            l10n.kuitansiColBefore,
            l10n.kuitansiColPaid,
          ]
        : const [],
    tableRows: [
      if (showDetails)
        for (final line in receipt.lines)
          [
            line.saleNumber,
            _money(l10n, line.balanceBefore),
            _money(l10n, line.amount),
          ],
    ],
    placeDate: city.trim().isEmpty ? date : '${city.trim()}, $date',
    amount: _money(l10n, receipt.amount),
    signName: receipt.staffName,
    signRole: l10n.kuitansiCashier,
    footnote: showBalance ? _dueNote(l10n, receipt) : null,
  );
}

/// Isi kuitansi struk thermal (1.20b).
ReceiptContent kuitansiReceiptContent(
  AppLocalizations l10n, {
  required DebtPaymentReceipt receipt,
  required CustomersSetup setup,
  required bool copy,
  required bool showDetails,
  required bool showBalance,
}) {
  final p = receipt.payment;
  return ReceiptContent(
    storeName: setup.businessName.toUpperCase(),
    outletName: setup.outletName,
    header: setup.receipt.headerLines,
    banner: [
      l10n.kuitansiThermalBanner,
      if (copy) l10n.kuitansiCopy,
    ].join(' · '),
    meta: [
      ReceiptPair(l10n.receiptNo, p.number),
      ReceiptPair(l10n.kuitansiFrom, receipt.customer.name),
      ReceiptPair(l10n.receiptDate, _thermalDate(p, setup.timezone)),
      ReceiptPair(l10n.receiptCashier, receipt.staffName),
    ],
    items: [
      if (showDetails)
        for (final line in receipt.lines)
          ReceiptItem(
            name: line.saleNumber,
            detail: '',
            amount: receiptAmount(l10n, line.amount.value),
          ),
    ],
    totals: [
      ReceiptPair(
        l10n.kuitansiPaid,
        receiptAmount(l10n, receipt.amount.value),
        bold: true,
      ),
      ReceiptPair(debtPaymentMethodLabel(l10n, p), ''),
      if (showBalance)
        ReceiptPair(
          l10n.kuitansiBalance,
          receiptAmount(l10n, receipt.balanceAfter.value),
        ),
    ],
    footer: [l10n.receiptThanks],
  );
}

/// Tanggal bayar (sama dengan kuitansi A5). Jam simpan ikut hanya bila
/// dibayar hari itu juga; pembayaran bertanggal mundur tanpa jam.
String _thermalDate(DebtPayment p, String? timezone) {
  final saved = outletLocalTime(p.createdAt, timezone);
  final paid = p.paidOn;
  if (saved.year == paid.year &&
      saved.month == paid.month &&
      saved.day == paid.day) {
    return receiptDate(saved);
  }
  return receiptDate(DateTime(paid.year, paid.month, paid.day))
      .split(' ')
      .first;
}
