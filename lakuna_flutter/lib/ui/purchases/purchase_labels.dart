import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/purchases_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import 'purchase_detail_view_model.dart';

/// Tanggal kalender (tanpa zona) `dd/MM/yyyy`, mis. tanggal pembelian.
String formatCalendarDate(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}/${d.year}';
}

/// Tanggal kalender `dd/MM`.
String formatCalendarDayMonth(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.day)}/${two(d.month)}';
}

String fundingLabel(AppLocalizations l10n, FundingKind kind) => switch (kind) {
  FundingKind.storeCash => l10n.fundingStoreCash,
  FundingKind.drawer => l10n.fundingDrawer,
  FundingKind.bank => l10n.fundingBank,
};

/// Pesan satu galat isian pembelian.
String purchaseIssueMessage(AppLocalizations l10n, PurchaseIssue issue) =>
    switch (issue.field) {
      PurchaseField.lines => l10n.purchaseErrLines,
      PurchaseField.quantity => l10n.purchaseErrQty,
      PurchaseField.price => l10n.purchaseErrPrice,
      PurchaseField.discount => l10n.purchaseErrDiscount,
      PurchaseField.shipping => l10n.purchaseErrShipping,
      PurchaseField.paid => l10n.purchaseErrPaid,
      PurchaseField.funding => l10n.purchaseErrPaid,
      PurchaseField.supplier => l10n.purchaseErrSupplier,
      PurchaseField.dueOn => l10n.purchaseErrDueOn,
      PurchaseField.invoiceNo => l10n.purchaseErrInvoiceNo(
        PurchaseLimits.invoiceNo,
      ),
      PurchaseField.note => l10n.purchaseErrNote(PurchaseLimits.note),
    };

/// Pesan galat repositori untuk aksi form atau detail pembelian.
String purchaseErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      PurchaseInvalid(:final issues) when issues.isNotEmpty =>
        purchaseIssueMessage(l10n, issues.first),
      CashSessionNotOpen() => l10n.purchaseErrDrawer,
      PurchaseNotEditable() => l10n.purchaseErrNotEditable,
      PurchaseNotFound() => l10n.purchaseErrNotFound,
      NotPermitted() ||
      PurchaseActorNotPermitted() => l10n.purchaseErrNotPermitted,
      StockLocationNotFound() => l10n.purchaseErrLocation,
      PurchaseReturnInvalid(:final error) => purchaseReturnErrorMessage(
        l10n,
        error,
      ),
      _ => l10n.purchaseErrGeneric,
    };

String purchaseReturnErrorMessage(
  AppLocalizations l10n,
  PurchaseReturnError error,
) => switch (error) {
  PurchaseReturnError.empty => l10n.purchaseReturnErrEmpty,
  PurchaseReturnError.quantity => l10n.purchaseReturnErrQty,
  PurchaseReturnError.stock => l10n.purchaseReturnErrStock,
  PurchaseReturnError.status => l10n.purchaseReturnErrStatus,
  PurchaseReturnError.refundSource => l10n.purchaseReturnErrRefund,
  PurchaseReturnError.note => l10n.purchaseErrNote(PurchaseLimits.note),
};

String purchaseReturnIssueMessage(
  AppLocalizations l10n,
  PurchaseReturnIssue issue,
) => purchaseReturnErrorMessage(
  l10n,
  PurchaseReturnError.values.byName(issue.name),
);
