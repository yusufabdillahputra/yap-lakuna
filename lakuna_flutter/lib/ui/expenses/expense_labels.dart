import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/expenses_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../purchases/purchase_labels.dart' show fundingLabel;
import 'expense_form_view_model.dart';

String expenseFundingLabel(AppLocalizations l10n, FundingSource source) =>
    fundingLabel(l10n, fundingKind(source));

/// Sumber dana di tabel, mis. *Kas laci · sesi Sari*.
String expenseFundingText(AppLocalizations l10n, ExpenseRow row) {
  final base = expenseFundingLabel(l10n, row.expense.fundingSource);
  final opener = row.sessionStaffName;
  return opener == null || opener.isEmpty
      ? base
      : l10n.expenseFundingSession(base, opener);
}

String expensePeriodLabel(AppLocalizations l10n, ExpensePeriod period) =>
    switch (period) {
      ExpensePeriod.last30Days => l10n.expensePeriod30Days,
      ExpensePeriod.thisMonth => l10n.expensePeriodThisMonth,
      ExpensePeriod.lastMonth => l10n.expensePeriodLastMonth,
    };

String expenseIssueMessage(AppLocalizations l10n, ExpenseIssue issue) =>
    switch (issue) {
      ExpenseIssue.description => l10n.expenseErrDescription(
        ExpenseLimits.description,
      ),
      ExpenseIssue.category => l10n.expenseErrCategory,
      ExpenseIssue.amount => l10n.expenseErrAmount,
    };

String expenseDrawerIssueMessage(
  AppLocalizations l10n,
  ExpenseDrawerIssue issue,
) => switch (issue) {
  ExpenseDrawerIssue.notPermitted => l10n.expenseDrawerNotPermitted,
  ExpenseDrawerIssue.noSession => l10n.expenseDrawerNoSession,
  ExpenseDrawerIssue.notToday => l10n.expenseDrawerNotToday,
};

/// Pesan galat repositori modul pengeluaran.
String expenseErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      ExpenseInvalid(:final issues) when issues.isNotEmpty =>
        expenseIssueMessage(l10n, issues.first),
      ExpenseDateInvalid() => l10n.expenseErrDate,
      ExpenseReceiptInvalid() => l10n.expenseReceiptInvalid,
      ExpenseNotFound() => l10n.expenseErrNotFound,
      ExpenseAlreadyVoided() => l10n.expenseErrAlreadyVoided,
      ExpenseVoidReasonInvalid() => l10n.expenseErrReason(
        ExpenseLimits.voidReason,
      ),
      ExpenseCategoryInvalid() => l10n.expenseCategoryErrName(
        ExpenseLimits.categoryName,
      ),
      ExpenseCategoryNameTaken() => l10n.expenseCategoryErrTaken,
      ExpenseCategoryInUse() => l10n.expenseCategoryErrInUse,
      ExpenseCategoryNotFound() => l10n.expenseErrCategory,
      CashSessionNotOpen() => l10n.expenseDrawerNoSession,
      NotPermitted() ||
      ExpenseActorNotPermitted() => l10n.expenseErrNotPermitted,
      _ => l10n.expenseErrGeneric,
    };

/// Berkas Excel daftar pengeluaran (sesuai filter).
Uint8List expenseWorkbook(AppLocalizations l10n, List<ExpenseRow> rows) {
  String two(int n) => n.toString().padLeft(2, '0');
  return buildXlsx(
    l10n.expensesTitle,
    [
      [
        l10n.expenseColDate,
        l10n.expenseColNumber,
        l10n.expenseColDescription,
        l10n.expenseColCategory,
        l10n.expenseColFunding,
        l10n.expenseColAmount,
        l10n.expenseColReceipt,
        l10n.expenseColStatus,
      ],
      for (final r in rows)
        [
          '${r.expense.spentOn.year}-${two(r.expense.spentOn.month)}-'
              '${two(r.expense.spentOn.day)}',
          r.expense.number,
          r.expense.description,
          r.categoryName,
          expenseFundingText(l10n, r),
          XlsxNumber(r.expense.amount),
          r.hasReceipt ? l10n.expenseHasReceipt : l10n.expenseNoReceipt,
          r.voided ? l10n.expenseVoided : l10n.expenseActive,
        ],
    ],
    widths: const [12, 24, 32, 20, 22, 14, 12, 12],
  );
}
