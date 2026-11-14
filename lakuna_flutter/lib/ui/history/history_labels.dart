import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/repository_errors.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;
import '../reports/report_labels.dart' show reportRangeLabel;

/// Status nota di riwayat.
String saleStatusLabel(AppLocalizations l10n, SaleStatus status) =>
    switch (status) {
      SaleStatus.voided => l10n.historyStatusVoided,
      SaleStatus.partiallyReturned => l10n.historyStatusPartial,
      SaleStatus.returned => l10n.historyStatusReturned,
      _ => l10n.historyStatusCompleted,
    };

/// Label rentang; [HistoryRange.custom] memakai [days] (*1–15 Nov 2026*),
/// atau *Rentang tanggal…* bila belum dipilih (F1-11c).
String historyRangeLabel(
  AppLocalizations l10n,
  HistoryRange range, {
  DateRange? days,
}) => switch (range) {
  HistoryRange.today => l10n.historyRangeToday,
  HistoryRange.yesterday => l10n.historyRangeYesterday,
  HistoryRange.week => l10n.historyRangeWeek,
  HistoryRange.custom =>
    days == null ? l10n.reportsPeriodCustom : reportRangeLabel(l10n, days),
};

String historyStatusFilterLabel(AppLocalizations l10n, HistoryStatus s) =>
    switch (s) {
      HistoryStatus.all => l10n.historyStatusAll,
      HistoryStatus.completed => l10n.historyStatusCompleted,
      HistoryStatus.returned => l10n.historyStatusReturnedAny,
      HistoryStatus.voided => l10n.historyStatusVoided,
    };

String returnReasonLabel(AppLocalizations l10n, SaleReturnReason r) =>
    switch (r) {
      SaleReturnReason.damaged => l10n.historyReasonDamaged,
      SaleReturnReason.wrongItem => l10n.historyReasonWrongItem,
      SaleReturnReason.expired => l10n.historyReasonExpired,
      SaleReturnReason.other => l10n.historyReasonOther,
    };

String refundMethodLabel(AppLocalizations l10n, RefundMethod m) => switch (m) {
  RefundMethod.cash => l10n.historyRefundCash,
  RefundMethod.transfer => l10n.historyRefundTransfer,
  RefundMethod.debt => l10n.historyRefundDebt,
};

/// Metode bayar nota, digabung `Tunai + QRIS`.
/// Metode bayar nota; nota kredit (F1-13) ditambah *Kredit*.
String historyMethods(
  AppLocalizations l10n,
  List<PaymentMethod> methods, {
  bool credit = false,
}) {
  final labels = [
    for (final m in methods) paymentMethodLabel(l10n, m),
    if (credit) l10n.historyMethodCredit,
  ];
  return labels.isEmpty ? '—' : labels.join(' + ');
}

/// Kenapa nota tidak bisa di-void.
String voidBlockLabel(AppLocalizations l10n, VoidBlock block) =>
    switch (block) {
      VoidBlock.status => l10n.historyVoidBlockStatus,
      VoidBlock.returned => l10n.historyVoidBlockReturned,
      VoidBlock.notToday => l10n.historyVoidBlockNotToday,
      VoidBlock.session => l10n.historyVoidBlockSession,
      VoidBlock.debtPaid => l10n.historyVoidBlockDebtPaid,
    };

/// Pesan galat aksi riwayat (retur, void, muat).
String historyErrorMessage(
  AppLocalizations l10n,
  Exception error,
) => switch (error) {
  ReturnInvalid(error: ReturnError.empty) => l10n.historyErrReturnEmpty,
  ReturnInvalid(error: ReturnError.quantity) => l10n.historyErrReturnQuantity,
  ReturnInvalid(error: ReturnError.note) => l10n.historyErrReturnNote,
  ReturnInvalid(error: ReturnError.status) => l10n.historyErrReturnStatus,
  ReturnInvalid(error: ReturnError.refundMethod) => l10n.historyErrRefundMethod,
  CashSessionNotOpen() => l10n.historyErrNoSession,
  SaleVoidInvalid(error: VoidError.reason) => l10n.historyErrVoidReason,
  SaleVoidInvalid(:final block?) => voidBlockLabel(l10n, block),
  ApproverNotPermitted() => l10n.approvalNotPermitted,
  NotPermitted() => l10n.historyErrNotPermitted,
  SaleNotFound() => l10n.historyErrNotFound,
  _ => l10n.historyErrGeneric,
};

/// Berkas Excel daftar riwayat: satu baris per nota mengikuti filter.
Uint8List historyWorkbook(
  AppLocalizations l10n,
  HistoryPage page, {
  String? timezone,
}) {
  String two(int n) => n.toString().padLeft(2, '0');
  return buildXlsx(
    l10n.historyTitle,
    [
      [
        l10n.historyColNumber,
        l10n.historyColDate,
        l10n.historyColTime,
        l10n.historyColStaff,
        l10n.historyColMethod,
        l10n.historyColTotal,
        l10n.historyColReturned,
        l10n.historyColNet,
        l10n.historyColStatus,
      ],
      for (final r in page.rows)
        () {
          final local = outletLocalTime(r.sale.soldAt, timezone);
          return [
            r.sale.number,
            '${local.year}-${two(local.month)}-${two(local.day)}',
            '${two(local.hour)}.${two(local.minute)}',
            r.staffName,
            historyMethods(l10n, r.methods),
            XlsxNumber(r.sale.total),
            XlsxNumber(r.returned.value),
            XlsxNumber(r.net.value),
            saleStatusLabel(l10n, r.sale.status),
          ];
        }(),
    ],
    widths: const [24, 12, 8, 18, 18, 14, 14, 14, 16],
  );
}

/// Item yang bisa diretur ditampilkan dengan nama lengkap.
String saleItemName(SaleItem item) =>
    '${item.productName} ${item.variantName}'.trim();
