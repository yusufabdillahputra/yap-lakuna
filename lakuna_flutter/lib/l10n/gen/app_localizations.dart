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

  /// No description provided for @onboardingWelcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang'**
  String get onboardingWelcome;

  /// No description provided for @onboardingHeadline.
  ///
  /// In id, this message translates to:
  /// **'Siapkan toko Anda dalam 4 langkah'**
  String get onboardingHeadline;

  /// No description provided for @onboardingOfflineNote.
  ///
  /// In id, this message translates to:
  /// **'Semua data tersimpan di perangkat ini. Anda bisa mengaktifkan versi hosting kapan saja.'**
  String get onboardingOfflineNote;

  /// No description provided for @onboardingStepOf.
  ///
  /// In id, this message translates to:
  /// **'Langkah {current} dari {total}'**
  String onboardingStepOf(int current, int total);

  /// No description provided for @onboardingStepLanguage.
  ///
  /// In id, this message translates to:
  /// **'Bahasa & tema'**
  String get onboardingStepLanguage;

  /// No description provided for @onboardingStepBusiness.
  ///
  /// In id, this message translates to:
  /// **'Jenis usaha & cabang'**
  String get onboardingStepBusiness;

  /// No description provided for @onboardingStepOwner.
  ///
  /// In id, this message translates to:
  /// **'Akun pemilik & PIN'**
  String get onboardingStepOwner;

  /// No description provided for @onboardingStepSummary.
  ///
  /// In id, this message translates to:
  /// **'Siap jualan'**
  String get onboardingStepSummary;

  /// No description provided for @onboardingTitleLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa dan tema'**
  String get onboardingTitleLanguage;

  /// No description provided for @onboardingTitleBusiness.
  ///
  /// In id, this message translates to:
  /// **'Jenis usaha & cabang pertama'**
  String get onboardingTitleBusiness;

  /// No description provided for @onboardingTitleOwner.
  ///
  /// In id, this message translates to:
  /// **'Akun pemilik & PIN'**
  String get onboardingTitleOwner;

  /// No description provided for @onboardingTitleSummary.
  ///
  /// In id, this message translates to:
  /// **'Periksa, lalu mulai jualan'**
  String get onboardingTitleSummary;

  /// No description provided for @businessTypeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jenis usaha'**
  String get businessTypeLabel;

  /// No description provided for @businessRetail.
  ///
  /// In id, this message translates to:
  /// **'Retail'**
  String get businessRetail;

  /// No description provided for @businessRetailDesc.
  ///
  /// In id, this message translates to:
  /// **'Toko kelontong, grosir, toko bangunan, counter HP.'**
  String get businessRetailDesc;

  /// No description provided for @businessFnb.
  ///
  /// In id, this message translates to:
  /// **'F&B'**
  String get businessFnb;

  /// No description provided for @businessFnbDesc.
  ///
  /// In id, this message translates to:
  /// **'Warung makan, kafe, kedai kopi. Ada meja & open bill.'**
  String get businessFnbDesc;

  /// No description provided for @businessMixed.
  ///
  /// In id, this message translates to:
  /// **'Campuran'**
  String get businessMixed;

  /// No description provided for @businessMixedDesc.
  ///
  /// In id, this message translates to:
  /// **'Jual barang sekaligus makanan/minuman.'**
  String get businessMixedDesc;

  /// No description provided for @fieldBusinessName.
  ///
  /// In id, this message translates to:
  /// **'Nama usaha'**
  String get fieldBusinessName;

  /// No description provided for @fieldOutletName.
  ///
  /// In id, this message translates to:
  /// **'Nama cabang'**
  String get fieldOutletName;

  /// No description provided for @fieldOutletCode.
  ///
  /// In id, this message translates to:
  /// **'Kode cabang (untuk nomor nota)'**
  String get fieldOutletCode;

  /// No description provided for @fieldDeviceCode.
  ///
  /// In id, this message translates to:
  /// **'Kode perangkat'**
  String get fieldDeviceCode;

  /// No description provided for @fieldTimezone.
  ///
  /// In id, this message translates to:
  /// **'Zona waktu'**
  String get fieldTimezone;

  /// No description provided for @fieldOwnerName.
  ///
  /// In id, this message translates to:
  /// **'Nama pemilik'**
  String get fieldOwnerName;

  /// No description provided for @fieldEmail.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @fieldPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get fieldPassword;

  /// No description provided for @fieldPasswordConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi'**
  String get fieldPasswordConfirm;

  /// No description provided for @fieldPin.
  ///
  /// In id, this message translates to:
  /// **'PIN (6 angka)'**
  String get fieldPin;

  /// No description provided for @fieldPinConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ulangi PIN'**
  String get fieldPinConfirm;

  /// No description provided for @receiptPreviewLabel.
  ///
  /// In id, this message translates to:
  /// **'Contoh nomor nota'**
  String get receiptPreviewLabel;

  /// No description provided for @receiptPreviewNote.
  ///
  /// In id, this message translates to:
  /// **'Cabang, perangkat, tanggal, urutan. Aman walau beberapa kasir offline.'**
  String get receiptPreviewNote;

  /// No description provided for @ownerNote.
  ///
  /// In id, this message translates to:
  /// **'PIN dipakai untuk masuk dan ganti kasir. Email dan kata sandi dipakai untuk masuk sebagai pemilik.'**
  String get ownerNote;

  /// No description provided for @errorRequired.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi'**
  String get errorRequired;

  /// No description provided for @errorTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 60 karakter'**
  String get errorTooLong;

  /// No description provided for @errorInvalidCode.
  ///
  /// In id, this message translates to:
  /// **'2–6 huruf atau angka'**
  String get errorInvalidCode;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak sama'**
  String get errorPasswordMismatch;

  /// No description provided for @errorInvalidPin.
  ///
  /// In id, this message translates to:
  /// **'PIN harus 6 angka'**
  String get errorInvalidPin;

  /// No description provided for @errorPinMismatch.
  ///
  /// In id, this message translates to:
  /// **'PIN tidak sama'**
  String get errorPinMismatch;

  /// No description provided for @errorInvalidTimezone.
  ///
  /// In id, this message translates to:
  /// **'Pilih zona waktu'**
  String get errorInvalidTimezone;

  /// No description provided for @summaryBusiness.
  ///
  /// In id, this message translates to:
  /// **'Usaha'**
  String get summaryBusiness;

  /// No description provided for @summaryOutlet.
  ///
  /// In id, this message translates to:
  /// **'Cabang'**
  String get summaryOutlet;

  /// No description provided for @summaryDevice.
  ///
  /// In id, this message translates to:
  /// **'Perangkat'**
  String get summaryDevice;

  /// No description provided for @summaryOwner.
  ///
  /// In id, this message translates to:
  /// **'Pemilik'**
  String get summaryOwner;

  /// No description provided for @summaryNote.
  ///
  /// In id, this message translates to:
  /// **'Data baru disimpan setelah Anda menekan Mulai jualan.'**
  String get summaryNote;

  /// No description provided for @buttonBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get buttonBack;

  /// No description provided for @buttonNextBusiness.
  ///
  /// In id, this message translates to:
  /// **'Lanjut: jenis usaha'**
  String get buttonNextBusiness;

  /// No description provided for @buttonNextOwner.
  ///
  /// In id, this message translates to:
  /// **'Lanjut: akun pemilik'**
  String get buttonNextOwner;

  /// No description provided for @buttonNextSummary.
  ///
  /// In id, this message translates to:
  /// **'Lanjut: ringkasan'**
  String get buttonNextSummary;

  /// No description provided for @buttonStartSelling.
  ///
  /// In id, this message translates to:
  /// **'Mulai jualan'**
  String get buttonStartSelling;

  /// No description provided for @setupFailed.
  ///
  /// In id, this message translates to:
  /// **'Toko gagal disimpan. Coba lagi.'**
  String get setupFailed;

  /// No description provided for @homeStoreLabel.
  ///
  /// In id, this message translates to:
  /// **'Toko'**
  String get homeStoreLabel;

  /// No description provided for @setupAlreadyDone.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini sudah berisi data toko yang belum lengkap. Pulihkan dari backup atau hubungi dukungan.'**
  String get setupAlreadyDone;

  /// No description provided for @loginTitle.
  ///
  /// In id, this message translates to:
  /// **'Siapa yang bertugas?'**
  String get loginTitle;

  /// No description provided for @loginSelectStaff.
  ///
  /// In id, this message translates to:
  /// **'Pilih nama Anda untuk memasukkan PIN.'**
  String get loginSelectStaff;

  /// No description provided for @loginEnterPinFor.
  ///
  /// In id, this message translates to:
  /// **'Masukkan PIN {name}'**
  String loginEnterPinFor(String name);

  /// No description provided for @loginNoPin.
  ///
  /// In id, this message translates to:
  /// **'Belum punya PIN'**
  String get loginNoPin;

  /// No description provided for @loginPinNote.
  ///
  /// In id, this message translates to:
  /// **'PIN diverifikasi di perangkat ini. 5 kali salah → dikunci 1 menit.'**
  String get loginPinNote;

  /// No description provided for @loginOwnerLink.
  ///
  /// In id, this message translates to:
  /// **'Masuk dengan email & kata sandi (pemilik)'**
  String get loginOwnerLink;

  /// No description provided for @loginOwnerTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk sebagai pemilik'**
  String get loginOwnerTitle;

  /// No description provided for @loginSubmit.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginSubmit;

  /// No description provided for @loginBackToPin.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke PIN'**
  String get loginBackToPin;

  /// No description provided for @loginBackToStaff.
  ///
  /// In id, this message translates to:
  /// **'Pilih staf lain'**
  String get loginBackToStaff;

  /// No description provided for @loginKeypadCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get loginKeypadCancel;

  /// No description provided for @loginKeypadDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus satu angka'**
  String get loginKeypadDelete;

  /// No description provided for @loginWrongPin.
  ///
  /// In id, this message translates to:
  /// **'PIN salah. Sisa {count} percobaan.'**
  String loginWrongPin(int count);

  /// No description provided for @loginLocked.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak percobaan. Coba lagi dalam {seconds} detik.'**
  String loginLocked(int seconds);

  /// No description provided for @loginWrongCredentials.
  ///
  /// In id, this message translates to:
  /// **'Email atau kata sandi salah.'**
  String get loginWrongCredentials;

  /// No description provided for @loginStaffUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Staf ini tidak lagi aktif di cabang ini.'**
  String get loginStaffUnavailable;

  /// No description provided for @loginFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal masuk. Coba lagi.'**
  String get loginFailed;

  /// No description provided for @loginLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Daftar staf gagal dimuat.'**
  String get loginLoadFailed;

  /// No description provided for @loginRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get loginRetry;

  /// No description provided for @switchCashier.
  ///
  /// In id, this message translates to:
  /// **'Ganti kasir'**
  String get switchCashier;

  /// No description provided for @homeStaffLabel.
  ///
  /// In id, this message translates to:
  /// **'Bertugas'**
  String get homeStaffLabel;

  /// No description provided for @roleOwner.
  ///
  /// In id, this message translates to:
  /// **'Pemilik'**
  String get roleOwner;

  /// No description provided for @roleManager.
  ///
  /// In id, this message translates to:
  /// **'Manajer'**
  String get roleManager;

  /// No description provided for @roleCashier.
  ///
  /// In id, this message translates to:
  /// **'Kasir'**
  String get roleCashier;

  /// No description provided for @roleWaiter.
  ///
  /// In id, this message translates to:
  /// **'Pelayan'**
  String get roleWaiter;

  /// No description provided for @roleStockKeeper.
  ///
  /// In id, this message translates to:
  /// **'Staf gudang'**
  String get roleStockKeeper;

  /// No description provided for @menuCashSession.
  ///
  /// In id, this message translates to:
  /// **'Sesi kasir'**
  String get menuCashSession;

  /// No description provided for @cashDrawerTitle.
  ///
  /// In id, this message translates to:
  /// **'Sesi kasir · Kas laci'**
  String get cashDrawerTitle;

  /// No description provided for @cashCashierLabel.
  ///
  /// In id, this message translates to:
  /// **'Kasir: {name}'**
  String cashCashierLabel(String name);

  /// No description provided for @cashOpenTitle.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi kasir'**
  String get cashOpenTitle;

  /// No description provided for @cashOpenBody.
  ///
  /// In id, this message translates to:
  /// **'Hitung uang di laci sebelum mulai berjualan, lalu catat sebagai saldo awal.'**
  String get cashOpenBody;

  /// No description provided for @cashOpeningCash.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal laci'**
  String get cashOpeningCash;

  /// No description provided for @cashOpeningNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get cashOpeningNote;

  /// No description provided for @cashOpenButton.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi'**
  String get cashOpenButton;

  /// No description provided for @cashActive.
  ///
  /// In id, this message translates to:
  /// **'Sesi aktif'**
  String get cashActive;

  /// No description provided for @cashOpenedBy.
  ///
  /// In id, this message translates to:
  /// **'Dibuka {time} oleh {name} · {device}'**
  String cashOpenedBy(String time, String name, String device);

  /// No description provided for @cashExpected.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan uang di laci'**
  String get cashExpected;

  /// No description provided for @cashCloseButton.
  ///
  /// In id, this message translates to:
  /// **'Tutup sesi'**
  String get cashCloseButton;

  /// No description provided for @cashMovementsTitle.
  ///
  /// In id, this message translates to:
  /// **'Gerakan kas sesi ini'**
  String get cashMovementsTitle;

  /// No description provided for @cashColTime.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get cashColTime;

  /// No description provided for @cashColNote.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get cashColNote;

  /// No description provided for @cashColSource.
  ///
  /// In id, this message translates to:
  /// **'Sumber'**
  String get cashColSource;

  /// No description provided for @cashColAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get cashColAmount;

  /// No description provided for @cashOpeningRow.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal'**
  String get cashOpeningRow;

  /// No description provided for @cashSourceOpening.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi'**
  String get cashSourceOpening;

  /// No description provided for @cashSourceManual.
  ///
  /// In id, this message translates to:
  /// **'Manual'**
  String get cashSourceManual;

  /// No description provided for @cashMovementsFootnote.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran, bayar hutang, dan retur tunai dari modul lain akan tercatat otomatis di sesi yang sedang buka.'**
  String get cashMovementsFootnote;

  /// No description provided for @cashRecordTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat uang laci'**
  String get cashRecordTitle;

  /// No description provided for @cashOutflow.
  ///
  /// In id, this message translates to:
  /// **'Uang keluar'**
  String get cashOutflow;

  /// No description provided for @cashInflow.
  ///
  /// In id, this message translates to:
  /// **'Uang masuk'**
  String get cashInflow;

  /// No description provided for @cashAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get cashAmount;

  /// No description provided for @cashNote.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get cashNote;

  /// No description provided for @cashNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Mis. beli es batu'**
  String get cashNoteHint;

  /// No description provided for @cashSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get cashSave;

  /// No description provided for @cashNeedsPermission.
  ///
  /// In id, this message translates to:
  /// **'Butuh izin {permission}.'**
  String cashNeedsPermission(String permission);

  /// No description provided for @cashCloseTitle.
  ///
  /// In id, this message translates to:
  /// **'Tutup sesi kasir · {name}'**
  String cashCloseTitle(String name);

  /// No description provided for @cashBackToDrawer.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke kas laci'**
  String get cashBackToDrawer;

  /// No description provided for @cashStatTransactions.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get cashStatTransactions;

  /// No description provided for @cashStatSales.
  ///
  /// In id, this message translates to:
  /// **'Penjualan'**
  String get cashStatSales;

  /// No description provided for @cashStatVoids.
  ///
  /// In id, this message translates to:
  /// **'Void / retur'**
  String get cashStatVoids;

  /// No description provided for @cashRecapTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekap kas laci'**
  String get cashRecapTitle;

  /// No description provided for @cashRecapOpening.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal ({time})'**
  String cashRecapOpening(String time);

  /// No description provided for @cashRecapCashSales.
  ///
  /// In id, this message translates to:
  /// **'Penjualan tunai'**
  String get cashRecapCashSales;

  /// No description provided for @cashRecapInflow.
  ///
  /// In id, this message translates to:
  /// **'Uang masuk lain'**
  String get cashRecapInflow;

  /// No description provided for @cashRecapOutflow.
  ///
  /// In id, this message translates to:
  /// **'Uang keluar'**
  String get cashRecapOutflow;

  /// No description provided for @cashRecapExpected.
  ///
  /// In id, this message translates to:
  /// **'Seharusnya di laci'**
  String get cashRecapExpected;

  /// No description provided for @cashRecapNonCash.
  ///
  /// In id, this message translates to:
  /// **'QRIS statis (terkonfirmasi) · kartu'**
  String get cashRecapNonCash;

  /// No description provided for @cashRecapFootnote.
  ///
  /// In id, this message translates to:
  /// **'QRIS statis & kartu tidak masuk laci, ditampilkan terpisah untuk dicocokkan dengan mutasi rekening.'**
  String get cashRecapFootnote;

  /// No description provided for @cashCountTitle.
  ///
  /// In id, this message translates to:
  /// **'Hitung uang fisik'**
  String get cashCountTitle;

  /// No description provided for @cashSheetsLabel.
  ///
  /// In id, this message translates to:
  /// **'Lembar Rp {denomination}'**
  String cashSheetsLabel(String denomination);

  /// No description provided for @cashCoins.
  ///
  /// In id, this message translates to:
  /// **'Receh'**
  String get cashCoins;

  /// No description provided for @cashCounted.
  ///
  /// In id, this message translates to:
  /// **'Uang dihitung'**
  String get cashCounted;

  /// No description provided for @cashDifference.
  ///
  /// In id, this message translates to:
  /// **'Selisih'**
  String get cashDifference;

  /// No description provided for @cashDifferenceExact.
  ///
  /// In id, this message translates to:
  /// **'Pas'**
  String get cashDifferenceExact;

  /// No description provided for @cashClosingNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan selisih'**
  String get cashClosingNote;

  /// No description provided for @cashClosingNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Wajib diisi bila ada selisih'**
  String get cashClosingNoteHint;

  /// No description provided for @cashClosedTitle.
  ///
  /// In id, this message translates to:
  /// **'Sesi kasir ditutup'**
  String get cashClosedTitle;

  /// No description provided for @cashClosedBody.
  ///
  /// In id, this message translates to:
  /// **'Ditutup {time}. Rekap tersimpan di perangkat ini.'**
  String cashClosedBody(String time);

  /// No description provided for @cashStartNew.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi baru'**
  String get cashStartNew;

  /// No description provided for @cashErrorNegative.
  ///
  /// In id, this message translates to:
  /// **'Tidak boleh negatif'**
  String get cashErrorNegative;

  /// No description provided for @cashErrorNotPositive.
  ///
  /// In id, this message translates to:
  /// **'Harus lebih dari 0'**
  String get cashErrorNotPositive;

  /// No description provided for @cashErrorTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 200 karakter'**
  String get cashErrorTooLong;

  /// No description provided for @cashErrorNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin {permission}.'**
  String cashErrorNotPermitted(String permission);

  /// No description provided for @cashErrorAlreadyOpen.
  ///
  /// In id, this message translates to:
  /// **'Sesi sudah dibuka di layar lain. Data dimuat ulang.'**
  String get cashErrorAlreadyOpen;

  /// No description provided for @cashErrorNotOpen.
  ///
  /// In id, this message translates to:
  /// **'Sesi sudah ditutup di layar lain. Data dimuat ulang.'**
  String get cashErrorNotOpen;

  /// No description provided for @cashErrorFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get cashErrorFailed;

  /// No description provided for @cashLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Sesi kasir gagal dimuat.'**
  String get cashLoadFailed;
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
