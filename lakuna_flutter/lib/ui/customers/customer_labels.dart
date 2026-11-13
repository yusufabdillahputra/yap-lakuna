import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/customers_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;

/// Nomor HP tampilan `0813-2222-1010` dari digit tersimpan.
String formatPhone(String? phone) {
  if (phone == null || phone.isEmpty) return '';
  if (phone.length < 8) return phone;
  final head = phone.substring(0, 4);
  final rest = phone.substring(4);
  final mid = rest.length > 4 ? rest.substring(0, rest.length - 4) : '';
  final tail = rest.substring(mid.length);
  return [head, if (mid.isNotEmpty) mid, tail].join('-');
}

/// Tanggal panjang `3 November 2026` / `3 November 2026` (en: `November 3,
/// 2026`).
String formatLongDate(AppLocalizations l10n, DateTime d) {
  final english = l10n.localeName.startsWith('en');
  return english
      ? '${_enMonths[d.month - 1]} ${d.day}, ${d.year}'
      : '${d.day} ${_idMonths[d.month - 1]} ${d.year}';
}

/// Bulan panjang `Oktober 2026` / `October 2026`.
String formatLongMonth(AppLocalizations l10n, int year, int month) =>
    '${(l10n.localeName.startsWith('en') ? _enMonths : _idMonths)[month - 1]} '
    '$year';

const _idMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const _enMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Bulan dan tahun singkat `Mar 2026`.
String formatMonthYear(AppLocalizations l10n, DateTime d) {
  final long = formatLongDate(l10n, DateTime(d.year, d.month));
  final english = l10n.localeName.startsWith('en');
  final month = english ? long.split(' ').first : long.split(' ')[1];
  return '${month.substring(0, 3)} ${d.year}';
}

/// Metode pembayaran piutang di kuitansi: tunai membedakan kas laci dan kas
/// toko.
String debtPaymentMethodLabel(AppLocalizations l10n, DebtPayment payment) =>
    switch (payment.method) {
      PaymentMethod.cash when payment.cashSessionId != null =>
        l10n.debtMethodCashDrawer,
      PaymentMethod.cash => l10n.debtMethodCashStore,
      final m? => paymentMethodLabel(l10n, m),
      null => '',
    };

String customerIssueMessage(AppLocalizations l10n, CustomerIssue issue) =>
    switch (issue) {
      CustomerIssue.name => l10n.customerErrName(CustomerLimits.name),
      CustomerIssue.phone => l10n.customerErrPhone,
      CustomerIssue.address => l10n.customerErrAddress(CustomerLimits.address),
      CustomerIssue.note => l10n.customerErrNote(CustomerLimits.note),
      CustomerIssue.group => l10n.customerErrGroup(CustomerLimits.groupName),
      CustomerIssue.creditLimit => l10n.customerErrLimit,
    };

String debtPaymentIssueMessage(
  AppLocalizations l10n,
  DebtPaymentIssue issue,
) => switch (issue) {
  DebtPaymentIssue.amount => l10n.debtErrAmount,
  DebtPaymentIssue.overOutstanding => l10n.debtErrOver,
  DebtPaymentIssue.allocationNegative ||
  DebtPaymentIssue.allocationUnknown ||
  DebtPaymentIssue.allocationOverRemaining => l10n.debtErrAllocation,
  DebtPaymentIssue.allocationTotal => l10n.debtErrAllocationTotal,
};

String customerGroupIssueMessage(
  AppLocalizations l10n,
  CustomerGroupIssue issue,
) => switch (issue) {
  CustomerGroupIssue.name => l10n.groupErrName(CustomerLimits.groupName),
  CustomerGroupIssue.termDays => l10n.groupErrTerm(CustomerLimits.maxTermDays),
};

String creditIssueMessage(AppLocalizations l10n, CreditIssue issue) =>
    switch (issue) {
      CreditIssue.noLimit => l10n.creditNoLimit,
      CreditIssue.downPayment => l10n.creditErrDownPayment,
      CreditIssue.dueOn => l10n.creditErrDueOn,
      CreditIssue.overLimit => l10n.creditErrOverLimit,
    };

/// Pesan galat repositori modul pelanggan.
String customerErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      CustomerInvalid(:final issues) when issues.isNotEmpty =>
        customerIssueMessage(l10n, issues.first),
      CustomerPhoneTaken() => l10n.customerErrPhoneTaken,
      CustomerHasDebt() => l10n.customerErrHasDebt,
      CustomerNotFound() => l10n.customerErrNotFound,
      CustomerGroupInvalid(:final issues) when issues.isNotEmpty =>
        customerGroupIssueMessage(l10n, issues.first),
      CustomerGroupNameTaken() => l10n.groupErrTaken,
      CustomerGroupInUse() => l10n.groupErrInUse,
      CustomerGroupHasPrices() => l10n.groupErrHasPrices,
      CustomerGroupNotFound() => l10n.groupErrNotFound,
      DebtPaymentInvalid(:final issue) => debtPaymentIssueMessage(l10n, issue),
      DebtPaymentDateInvalid() => l10n.debtErrDate,
      DebtPaymentMethodInvalid() => l10n.debtErrMethod,
      DebtPaymentNotFound() => l10n.kuitansiErrNotFound,
      DebtPaymentAlreadyVoided() => l10n.debtErrAlreadyVoided,
      DebtPaymentVoidReasonInvalid() => l10n.debtVoidErrReason(
        debtPaymentVoidReasonMax,
      ),
      CashSessionNotOpen() => l10n.debtErrNoSession,
      SaleCreditInvalid(:final issue) => creditIssueMessage(l10n, issue),
      NotPermitted() ||
      CustomerActorNotPermitted() => l10n.customerErrNotPermitted,
      _ => l10n.customerErrGeneric,
    };
