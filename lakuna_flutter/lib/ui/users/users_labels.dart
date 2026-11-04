import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/session_repository.dart';
import '../../data/repositories/users_repository.dart';
import '../../l10n/gen/app_localizations.dart';

/// Label manusia untuk izin di matriks 1.25 (kunci teknis ditampilkan di
/// bawahnya dari [Permission.key]).
String permissionLabel(AppLocalizations l10n, Permission p) => switch (p) {
  Permission.salesCreate => l10n.permSalesCreate,
  Permission.salesVoid => l10n.permSalesVoid,
  Permission.salesDiscount => l10n.permSalesDiscount,
  Permission.salesReturn => l10n.permSalesReturn,
  Permission.paymentsConfirm => l10n.permPaymentsConfirm,
  Permission.openBillsManage => l10n.permOpenBillsManage,
  Permission.cashSessionOpen => l10n.permCashSessionOpen,
  Permission.cashSessionClose => l10n.permCashSessionClose,
  Permission.cashMovementsCreate => l10n.permCashMovementsCreate,
  Permission.productsManage => l10n.permProductsManage,
  Permission.customersManage => l10n.permCustomersManage,
  Permission.suppliersManage => l10n.permSuppliersManage,
  Permission.purchasesManage => l10n.permPurchasesManage,
  Permission.stockAdjust => l10n.permStockAdjust,
  Permission.debtsManage => l10n.permDebtsManage,
  Permission.expensesManage => l10n.permExpensesManage,
  Permission.reportsView => l10n.permReportsView,
  Permission.reportsViewProfit => l10n.permReportsViewProfit,
  Permission.settingsManage => l10n.permSettingsManage,
  Permission.usersManage => l10n.permUsersManage,
  Permission.backupManage => l10n.permBackupManage,
  Permission.syncManage => l10n.permSyncManage,
};

/// Galat isian nama, PIN, atau kata sandi.
String staffIssueLabel(AppLocalizations l10n, StaffIssue issue) =>
    switch (issue) {
      StaffIssue.required => l10n.errorRequired,
      StaffIssue.tooLong => l10n.errorTooLong,
      StaffIssue.invalidPin => l10n.errorInvalidPin,
      StaffIssue.pinMismatch => l10n.errorPinMismatch,
      StaffIssue.passwordTooShort => l10n.errorPasswordTooShort,
      StaffIssue.passwordMismatch => l10n.errorPasswordMismatch,
      StaffIssue.beyondOwnPermissions => l10n.usersErrBeyond,
    };

/// Pesan galat repositori Pengguna & role.
String usersErrorMessage(AppLocalizations l10n, Exception e) => switch (e) {
  StaffNameTaken() => l10n.usersErrNameTaken,
  StaffNameInvalid(:final issue) ||
  RoleNameInvalid(:final issue) => staffIssueLabel(l10n, issue),
  StaffOwnerLocked() => l10n.usersErrOwnerLocked,
  StaffNotFound() || StaffUnavailable() => l10n.usersErrStaffNotFound,
  StaffNoPassword() => l10n.usersErrNoPassword,
  StaffSelfChange() => l10n.usersErrSelf,
  StaffBeyondPermissions() => l10n.usersErrBeyond,
  RoleNotFound() => l10n.usersErrRoleNotFound,
  RoleNameTaken() => l10n.usersErrRoleTaken,
  RoleInUse() => l10n.usersErrRoleInUse,
  NotPermitted() || UsersActorNotPermitted() => l10n.usersErrNotPermitted,
  WrongCurrentSecret(:final remainingAttempts?) => l10n.usersErrWrongPin(
    remainingAttempts,
  ),
  WrongCurrentSecret() => l10n.usersErrWrongPassword,
  CredentialsLocked(:final retryAfter) => l10n.usersErrLocked(
    retryAfter.inSeconds,
  ),
  _ => l10n.usersErrGeneric,
};
