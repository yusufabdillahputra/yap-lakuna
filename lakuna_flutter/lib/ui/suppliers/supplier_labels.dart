import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../purchases/purchase_labels.dart' show fundingLabel;
import 'supplier_panel_view_model.dart';

String supplierFundingLabel(AppLocalizations l10n, FundingSource source) =>
    fundingLabel(l10n, fundingKind(source));

String supplierIssueMessage(AppLocalizations l10n, SupplierIssue issue) =>
    switch (issue) {
      SupplierIssue.name => l10n.supplierErrName(SupplierLimits.name),
      SupplierIssue.phone => l10n.supplierErrPhone,
      SupplierIssue.contactName => l10n.supplierErrContact(
        SupplierLimits.contactName,
      ),
      SupplierIssue.category => l10n.supplierErrCategory(
        SupplierLimits.category,
      ),
      SupplierIssue.address => l10n.supplierErrAddress(SupplierLimits.address),
      SupplierIssue.note => l10n.supplierErrNote(SupplierLimits.note),
      SupplierIssue.termDays => l10n.supplierErrTerm(
        SupplierLimits.maxTermDays,
      ),
    };

String supplierPaymentIssueMessage(
  AppLocalizations l10n,
  DebtPaymentIssue issue,
) => switch (issue) {
  DebtPaymentIssue.amount => l10n.supplierErrAmount,
  DebtPaymentIssue.overOutstanding => l10n.supplierErrOver,
  DebtPaymentIssue.allocationNegative ||
  DebtPaymentIssue.allocationUnknown ||
  DebtPaymentIssue.allocationOverRemaining => l10n.supplierErrAllocation,
  DebtPaymentIssue.allocationTotal => l10n.supplierErrAllocationTotal,
};

String drawerIssueMessage(AppLocalizations l10n, DrawerIssue issue) =>
    switch (issue) {
      DrawerIssue.notPermitted => l10n.supplierDrawerNotPermitted,
      DrawerIssue.noSession => l10n.supplierDrawerNoSession,
      DrawerIssue.notToday => l10n.supplierDrawerNotToday,
    };

String proofIssueMessage(AppLocalizations l10n, ProofIssue issue) =>
    switch (issue) {
      ProofIssue.tooLarge => l10n.supplierProofTooLarge,
      ProofIssue.invalid => l10n.supplierProofInvalid,
    };

/// Pesan galat repositori modul supplier.
String supplierErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      SupplierInvalid(:final issues) when issues.isNotEmpty =>
        supplierIssueMessage(l10n, issues.first),
      SupplierNameTaken() => l10n.supplierErrNameTaken,
      SupplierHasDebt() => l10n.supplierErrHasDebt,
      SupplierNotFound() => l10n.supplierErrNotFound,
      SupplierPaymentInvalid(:final issue) => supplierPaymentIssueMessage(
        l10n,
        issue,
      ),
      SupplierPaymentDateInvalid() => l10n.supplierErrDate,
      SupplierPaymentDrawerDate() => l10n.supplierDrawerNotToday,
      SupplierPaymentProofInvalid() => l10n.supplierProofInvalid,
      SupplierPaymentTextInvalid() => l10n.supplierErrText,
      CashSessionNotOpen() => l10n.supplierErrNoSession,
      DebtPaymentAlreadyVoided() => l10n.debtErrAlreadyVoided,
      DebtPaymentVoidReasonInvalid() => l10n.debtVoidErrReason(
        debtPaymentVoidReasonMax,
      ),
      DebtPaymentNotFound() => l10n.supplierErrNotFound,
      NotPermitted() ||
      SupplierActorNotPermitted() => l10n.supplierErrNotPermitted,
      _ => l10n.supplierErrGeneric,
    };
