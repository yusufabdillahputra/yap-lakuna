import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Lakuna'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In id, this message translates to:
  /// **'Kasir offline untuk UMKM'**
  String get appTagline;

  /// No description provided for @offlineBadge.
  ///
  /// In id, this message translates to:
  /// **'Offline · data di perangkat ini'**
  String get offlineBadge;

  /// No description provided for @menuHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get menuHome;

  /// No description provided for @menuCashier.
  ///
  /// In id, this message translates to:
  /// **'Kasir'**
  String get menuCashier;

  /// No description provided for @menuHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get menuHistory;

  /// No description provided for @menuProducts.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get menuProducts;

  /// No description provided for @menuStock.
  ///
  /// In id, this message translates to:
  /// **'Stok'**
  String get menuStock;

  /// No description provided for @menuPurchases.
  ///
  /// In id, this message translates to:
  /// **'Pembelian'**
  String get menuPurchases;

  /// No description provided for @menuCustomers.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get menuCustomers;

  /// No description provided for @menuSuppliers.
  ///
  /// In id, this message translates to:
  /// **'Supplier'**
  String get menuSuppliers;

  /// No description provided for @menuExpenses.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get menuExpenses;

  /// No description provided for @menuReports.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get menuReports;

  /// No description provided for @menuUsers.
  ///
  /// In id, this message translates to:
  /// **'Pengguna & role'**
  String get menuUsers;

  /// No description provided for @menuSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get menuSettings;

  /// No description provided for @menuGuide.
  ///
  /// In id, this message translates to:
  /// **'Panduan'**
  String get menuGuide;

  /// No description provided for @menuGroupSales.
  ///
  /// In id, this message translates to:
  /// **'Penjualan'**
  String get menuGroupSales;

  /// No description provided for @menuGroupInventory.
  ///
  /// In id, this message translates to:
  /// **'Inventori'**
  String get menuGroupInventory;

  /// No description provided for @menuGroupContacts.
  ///
  /// In id, this message translates to:
  /// **'Kontak'**
  String get menuGroupContacts;

  /// No description provided for @menuGroupFinance.
  ///
  /// In id, this message translates to:
  /// **'Keuangan'**
  String get menuGroupFinance;

  /// No description provided for @menuGroupSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get menuGroupSystem;

  /// No description provided for @homeWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang di Lakuna'**
  String get homeWelcomeTitle;

  /// No description provided for @homeWelcomeBody.
  ///
  /// In id, this message translates to:
  /// **'Fondasi aplikasi sudah siap. Modul kasir, produk, dan stok akan hadir di rilis berikutnya.'**
  String get homeWelcomeBody;

  /// No description provided for @homeDeviceLabel.
  ///
  /// In id, this message translates to:
  /// **'ID perangkat'**
  String get homeDeviceLabel;

  /// No description provided for @homeDataLabel.
  ///
  /// In id, this message translates to:
  /// **'Lokasi data'**
  String get homeDataLabel;

  /// No description provided for @homeVersionLabel.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get homeVersionLabel;

  /// No description provided for @comingSoonTitle.
  ///
  /// In id, this message translates to:
  /// **'{module} segera hadir'**
  String comingSoonTitle(String module);

  /// No description provided for @comingSoonBody.
  ///
  /// In id, this message translates to:
  /// **'Modul ini sedang dibangun dan akan tersedia di rilis berikutnya.'**
  String get comingSoonBody;

  /// No description provided for @settingsAppearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get themeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get settingsLanguage;

  /// No description provided for @languageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesian;

  /// No description provided for @languageEnglish.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsSaveError.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan gagal disimpan. Coba lagi.'**
  String get settingsSaveError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
