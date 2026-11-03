// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lakuna';

  @override
  String get appTagline => 'Offline point of sale for small businesses';

  @override
  String get offlineBadge => 'Offline · data on this device';

  @override
  String get menuHome => 'Home';

  @override
  String get menuCashier => 'Cashier';

  @override
  String get menuHistory => 'History';

  @override
  String get menuProducts => 'Products';

  @override
  String get menuStock => 'Stock';

  @override
  String get menuPurchases => 'Purchases';

  @override
  String get menuCustomers => 'Customers';

  @override
  String get menuSuppliers => 'Suppliers';

  @override
  String get menuExpenses => 'Expenses';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuUsers => 'Users & roles';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuGuide => 'Guide';

  @override
  String get menuGroupSales => 'Sales';

  @override
  String get menuGroupInventory => 'Inventory';

  @override
  String get menuGroupContacts => 'Contacts';

  @override
  String get menuGroupFinance => 'Finance';

  @override
  String get menuGroupSystem => 'System';

  @override
  String get homeWelcomeTitle => 'Welcome to Lakuna';

  @override
  String get homeWelcomeBody =>
      'The app foundation is ready. Cashier, product, and stock modules arrive in upcoming releases.';

  @override
  String get homeDeviceLabel => 'Device ID';

  @override
  String get homeDataLabel => 'Data location';

  @override
  String get homeVersionLabel => 'Version';

  @override
  String comingSoonTitle(String module) {
    return '$module is coming soon';
  }

  @override
  String get comingSoonBody =>
      'This module is being built and will be available in an upcoming release.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsSaveError =>
      'Settings could not be saved. Please try again.';

  @override
  String get onboardingWelcome => 'Welcome';

  @override
  String get onboardingHeadline => 'Set up your store in 4 steps';

  @override
  String get onboardingOfflineNote =>
      'All data is stored on this device. You can turn on the hosted version at any time.';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingStepLanguage => 'Language & theme';

  @override
  String get onboardingStepBusiness => 'Business type & branch';

  @override
  String get onboardingStepOwner => 'Owner account & PIN';

  @override
  String get onboardingStepSummary => 'Ready to sell';

  @override
  String get onboardingTitleLanguage => 'Choose language and theme';

  @override
  String get onboardingTitleBusiness => 'Business type & first branch';

  @override
  String get onboardingTitleOwner => 'Owner account & PIN';

  @override
  String get onboardingTitleSummary => 'Review, then start selling';

  @override
  String get businessTypeLabel => 'Business type';

  @override
  String get businessRetail => 'Retail';

  @override
  String get businessRetailDesc =>
      'Grocery, wholesale, hardware store, phone counter.';

  @override
  String get businessFnb => 'F&B';

  @override
  String get businessFnbDesc =>
      'Food stall, café, coffee shop. With tables & open bills.';

  @override
  String get businessMixed => 'Mixed';

  @override
  String get businessMixedDesc => 'Sell goods as well as food and drinks.';

  @override
  String get fieldBusinessName => 'Business name';

  @override
  String get fieldOutletName => 'Branch name';

  @override
  String get fieldOutletCode => 'Branch code (for receipt numbers)';

  @override
  String get fieldDeviceCode => 'Device code';

  @override
  String get fieldTimezone => 'Time zone';

  @override
  String get fieldOwnerName => 'Owner name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordConfirm => 'Repeat password';

  @override
  String get fieldPin => 'PIN (6 digits)';

  @override
  String get fieldPinConfirm => 'Repeat PIN';

  @override
  String get receiptPreviewLabel => 'Sample receipt number';

  @override
  String get receiptPreviewNote =>
      'Branch, device, date, sequence. Safe even when several cashiers are offline.';

  @override
  String get ownerNote =>
      'The PIN is used to sign in and switch cashiers. The email and password are used to sign in as the owner.';

  @override
  String get errorRequired => 'Required';

  @override
  String get errorTooLong => 'Up to 60 characters';

  @override
  String get errorInvalidCode => '2–6 letters or digits';

  @override
  String get errorInvalidEmail => 'Invalid email format';

  @override
  String get errorPasswordTooShort => 'At least 8 characters';

  @override
  String get errorPasswordMismatch => 'The passwords do not match';

  @override
  String get errorInvalidPin => 'The PIN must be 6 digits';

  @override
  String get errorPinMismatch => 'The PINs do not match';

  @override
  String get errorInvalidTimezone => 'Choose a time zone';

  @override
  String get summaryBusiness => 'Business';

  @override
  String get summaryOutlet => 'Branch';

  @override
  String get summaryDevice => 'Device';

  @override
  String get summaryOwner => 'Owner';

  @override
  String get summaryNote =>
      'Your data is saved only after you press Start selling.';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonNextBusiness => 'Next: business type';

  @override
  String get buttonNextOwner => 'Next: owner account';

  @override
  String get buttonNextSummary => 'Next: summary';

  @override
  String get buttonStartSelling => 'Start selling';

  @override
  String get setupFailed => 'The store could not be saved. Please try again.';

  @override
  String get homeStoreLabel => 'Store';

  @override
  String get setupAlreadyDone =>
      'This device already holds incomplete store data. Restore from a backup or contact support.';

  @override
  String get loginTitle => 'Who\'s on duty?';

  @override
  String get loginSelectStaff => 'Choose your name to enter your PIN.';

  @override
  String loginEnterPinFor(String name) {
    return 'Enter $name\'s PIN';
  }

  @override
  String get loginNoPin => 'No PIN yet';

  @override
  String get loginPinNote =>
      'PINs are verified on this device. 5 wrong attempts → locked for 1 minute.';

  @override
  String get loginOwnerLink => 'Sign in with email & password (owner)';

  @override
  String get loginOwnerTitle => 'Sign in as owner';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginBackToPin => 'Back to PIN';

  @override
  String get loginBackToStaff => 'Choose someone else';

  @override
  String get loginKeypadCancel => 'Cancel';

  @override
  String get loginKeypadDelete => 'Delete one digit';

  @override
  String loginWrongPin(int count) {
    return 'Wrong PIN. $count attempts left.';
  }

  @override
  String loginLocked(int seconds) {
    return 'Too many attempts. Try again in $seconds s.';
  }

  @override
  String get loginWrongCredentials => 'Wrong email or password.';

  @override
  String get loginStaffUnavailable =>
      'This staff member is no longer active at this branch.';

  @override
  String get loginFailed => 'Sign-in failed. Try again.';

  @override
  String get loginLoadFailed => 'Could not load the staff list.';

  @override
  String get loginRetry => 'Try again';

  @override
  String get switchCashier => 'Switch cashier';

  @override
  String get homeStaffLabel => 'On duty';

  @override
  String get roleOwner => 'Owner';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleCashier => 'Cashier';

  @override
  String get roleWaiter => 'Waiter';

  @override
  String get roleStockKeeper => 'Stock keeper';
}
