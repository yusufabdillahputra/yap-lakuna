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
}
