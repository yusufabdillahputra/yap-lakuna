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

  /// No description provided for @menuMore.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get menuMore;

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
  /// **'Kasir retail, sesi kasir, produk, dan stok sudah bisa dipakai. Pembelian, riwayat, dan laporan menyusul di rilis berikutnya.'**
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

  /// No description provided for @productsTitle.
  ///
  /// In id, this message translates to:
  /// **'Produk & stok'**
  String get productsTitle;

  /// No description provided for @productsTitleMobile.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get productsTitleMobile;

  /// No description provided for @productsSummary.
  ///
  /// In id, this message translates to:
  /// **'{active} produk aktif · {low} di bawah stok minimum'**
  String productsSummary(int active, int low);

  /// No description provided for @productsSummaryShort.
  ///
  /// In id, this message translates to:
  /// **'{active} aktif · {low} di bawah minimum'**
  String productsSummaryShort(int active, int low);

  /// No description provided for @productsNew.
  ///
  /// In id, this message translates to:
  /// **'Produk baru'**
  String get productsNew;

  /// No description provided for @productsSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nama, SKU, atau barcode'**
  String get productsSearchHint;

  /// No description provided for @productsCategoryFilter.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get productsCategoryFilter;

  /// No description provided for @productsAllCategories.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get productsAllCategories;

  /// No description provided for @productsBelowMinimumChip.
  ///
  /// In id, this message translates to:
  /// **'Di bawah minimum ({count})'**
  String productsBelowMinimumChip(int count);

  /// No description provided for @productsColProduct.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get productsColProduct;

  /// No description provided for @productsColCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get productsColCategory;

  /// No description provided for @productsColVariantUnit.
  ///
  /// In id, this message translates to:
  /// **'Varian / satuan'**
  String get productsColVariantUnit;

  /// No description provided for @productsColCost.
  ///
  /// In id, this message translates to:
  /// **'Harga beli'**
  String get productsColCost;

  /// No description provided for @productsColPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga jual'**
  String get productsColPrice;

  /// No description provided for @productsColTiers.
  ///
  /// In id, this message translates to:
  /// **'Grosir'**
  String get productsColTiers;

  /// No description provided for @productsColStock.
  ///
  /// In id, this message translates to:
  /// **'Stok'**
  String get productsColStock;

  /// No description provided for @productsVariantsCount.
  ///
  /// In id, this message translates to:
  /// **'{count} varian'**
  String productsVariantsCount(int count);

  /// No description provided for @productsStockFootnote.
  ///
  /// In id, this message translates to:
  /// **'Stok dihitung dari riwayat pergerakan (stok awal, pembelian, penjualan, retur, penyesuaian).'**
  String get productsStockFootnote;

  /// No description provided for @productsEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada produk'**
  String get productsEmptyTitle;

  /// No description provided for @productsEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan produk pertama agar bisa dijual di kasir.'**
  String get productsEmptyBody;

  /// No description provided for @productsNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada produk yang cocok.'**
  String get productsNoMatch;

  /// No description provided for @productsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Produk gagal dimuat.'**
  String get productsLoadFailed;

  /// No description provided for @productsStock.
  ///
  /// In id, this message translates to:
  /// **'Stok {qty}'**
  String productsStock(String qty);

  /// No description provided for @productsStockMin.
  ///
  /// In id, this message translates to:
  /// **'Stok {qty} / min {min}'**
  String productsStockMin(String qty, String min);

  /// No description provided for @productsInactive.
  ///
  /// In id, this message translates to:
  /// **'Tidak dijual'**
  String get productsInactive;

  /// No description provided for @productFormNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Produk baru'**
  String get productFormNewTitle;

  /// No description provided for @productFormEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Edit produk · {name}'**
  String productFormEditTitle(String name);

  /// No description provided for @productFormCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get productFormCancel;

  /// No description provided for @productFormSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get productFormSave;

  /// No description provided for @productFormBasicInfo.
  ///
  /// In id, this message translates to:
  /// **'Info dasar'**
  String get productFormBasicInfo;

  /// No description provided for @productFormName.
  ///
  /// In id, this message translates to:
  /// **'Nama produk'**
  String get productFormName;

  /// No description provided for @productFormCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get productFormCategory;

  /// No description provided for @productFormKind.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get productFormKind;

  /// No description provided for @productKindGoods.
  ///
  /// In id, this message translates to:
  /// **'Barang (lacak stok)'**
  String get productKindGoods;

  /// No description provided for @productKindService.
  ///
  /// In id, this message translates to:
  /// **'Jasa (tanpa stok)'**
  String get productKindService;

  /// No description provided for @productKindMenu.
  ///
  /// In id, this message translates to:
  /// **'Menu F&B'**
  String get productKindMenu;

  /// No description provided for @productFormBaseUnit.
  ///
  /// In id, this message translates to:
  /// **'Satuan dasar'**
  String get productFormBaseUnit;

  /// No description provided for @productFormBaseUnitHint.
  ///
  /// In id, this message translates to:
  /// **'pcs, botol, kg'**
  String get productFormBaseUnitHint;

  /// No description provided for @productFormSku.
  ///
  /// In id, this message translates to:
  /// **'SKU induk'**
  String get productFormSku;

  /// No description provided for @productFormBrand.
  ///
  /// In id, this message translates to:
  /// **'Merek'**
  String get productFormBrand;

  /// No description provided for @productFormActive.
  ///
  /// In id, this message translates to:
  /// **'Dijual di kasir'**
  String get productFormActive;

  /// No description provided for @productFormTaxable.
  ///
  /// In id, this message translates to:
  /// **'Kena pajak (PB1/PPN)'**
  String get productFormTaxable;

  /// No description provided for @productFormTaxableHint.
  ///
  /// In id, this message translates to:
  /// **'Mengikuti pengaturan pajak toko'**
  String get productFormTaxableHint;

  /// No description provided for @productFormOptional.
  ///
  /// In id, this message translates to:
  /// **'Opsional'**
  String get productFormOptional;

  /// No description provided for @productTabVariants.
  ///
  /// In id, this message translates to:
  /// **'Varian'**
  String get productTabVariants;

  /// No description provided for @productTabUnits.
  ///
  /// In id, this message translates to:
  /// **'Satuan & konversi'**
  String get productTabUnits;

  /// No description provided for @productTabTiers.
  ///
  /// In id, this message translates to:
  /// **'Harga grosir'**
  String get productTabTiers;

  /// No description provided for @productTabUnitsShort.
  ///
  /// In id, this message translates to:
  /// **'Satuan'**
  String get productTabUnitsShort;

  /// No description provided for @productTabTiersShort.
  ///
  /// In id, this message translates to:
  /// **'Grosir'**
  String get productTabTiersShort;

  /// No description provided for @productVariantName.
  ///
  /// In id, this message translates to:
  /// **'Varian'**
  String get productVariantName;

  /// No description provided for @productVariantNameHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 2 L'**
  String get productVariantNameHint;

  /// No description provided for @productVariantSku.
  ///
  /// In id, this message translates to:
  /// **'SKU'**
  String get productVariantSku;

  /// No description provided for @productVariantBarcode.
  ///
  /// In id, this message translates to:
  /// **'Barcode'**
  String get productVariantBarcode;

  /// No description provided for @productCostPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga beli'**
  String get productCostPrice;

  /// No description provided for @productSellPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga jual'**
  String get productSellPrice;

  /// No description provided for @productMinStock.
  ///
  /// In id, this message translates to:
  /// **'Stok min'**
  String get productMinStock;

  /// No description provided for @productOpeningStock.
  ///
  /// In id, this message translates to:
  /// **'Stok awal'**
  String get productOpeningStock;

  /// No description provided for @productAddVariant.
  ///
  /// In id, this message translates to:
  /// **'Tambah varian'**
  String get productAddVariant;

  /// No description provided for @productRemoveRow.
  ///
  /// In id, this message translates to:
  /// **'Hapus baris'**
  String get productRemoveRow;

  /// No description provided for @productVariantFallback.
  ///
  /// In id, this message translates to:
  /// **'Varian {index}'**
  String productVariantFallback(int index);

  /// No description provided for @productSelectVariant.
  ///
  /// In id, this message translates to:
  /// **'Varian'**
  String get productSelectVariant;

  /// No description provided for @productBaseUnitRow.
  ///
  /// In id, this message translates to:
  /// **'satuan dasar'**
  String get productBaseUnitRow;

  /// No description provided for @productUnitName.
  ///
  /// In id, this message translates to:
  /// **'Satuan'**
  String get productUnitName;

  /// No description provided for @productUnitFactor.
  ///
  /// In id, this message translates to:
  /// **'Isi ({unit})'**
  String productUnitFactor(String unit);

  /// No description provided for @productUnitPriceHint.
  ///
  /// In id, this message translates to:
  /// **'Kosong = harga × isi'**
  String get productUnitPriceHint;

  /// No description provided for @productAddUnit.
  ///
  /// In id, this message translates to:
  /// **'Tambah satuan'**
  String get productAddUnit;

  /// No description provided for @productUnitsHelp.
  ///
  /// In id, this message translates to:
  /// **'Stok selalu disimpan dalam satuan dasar ({unit}). Jual 1 {conversion} = keluar {factor} {unit} dari kartu stok.'**
  String productUnitsHelp(String unit, String conversion, String factor);

  /// No description provided for @productUnitsHelpBase.
  ///
  /// In id, this message translates to:
  /// **'Stok selalu disimpan dalam satuan dasar ({unit}).'**
  String productUnitsHelpBase(String unit);

  /// No description provided for @productUnitsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada satuan konversi, mis. dus berisi 12.'**
  String get productUnitsEmpty;

  /// No description provided for @productTierMinQty.
  ///
  /// In id, this message translates to:
  /// **'Mulai jumlah ({unit})'**
  String productTierMinQty(String unit);

  /// No description provided for @productTierPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga per {unit}'**
  String productTierPrice(String unit);

  /// No description provided for @productTierAppliesTo.
  ///
  /// In id, this message translates to:
  /// **'Berlaku untuk'**
  String get productTierAppliesTo;

  /// No description provided for @productTierAllCustomers.
  ///
  /// In id, this message translates to:
  /// **'Semua pelanggan'**
  String get productTierAllCustomers;

  /// No description provided for @productAddTier.
  ///
  /// In id, this message translates to:
  /// **'Tambah tingkat harga'**
  String get productAddTier;

  /// No description provided for @productTiersHelp.
  ///
  /// In id, this message translates to:
  /// **'Harga grosir dipakai otomatis di kasir saat jumlah beli mencapai tingkatnya.'**
  String get productTiersHelp;

  /// No description provided for @productTiersEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada harga grosir.'**
  String get productTiersEmpty;

  /// No description provided for @productBaseUnitPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'satuan dasar'**
  String get productBaseUnitPlaceholder;

  /// No description provided for @productSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Produk gagal disimpan. Coba lagi.'**
  String get productSaveFailed;

  /// No description provided for @productNotFound.
  ///
  /// In id, this message translates to:
  /// **'Produk tidak ditemukan atau sudah dihapus.'**
  String get productNotFound;

  /// No description provided for @productFixErrors.
  ///
  /// In id, this message translates to:
  /// **'Periksa isian yang ditandai merah.'**
  String get productFixErrors;

  /// No description provided for @productErrorNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin {permission}.'**
  String productErrorNotPermitted(String permission);

  /// No description provided for @productErrorTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} karakter'**
  String productErrorTooLong(int max);

  /// No description provided for @productErrorNegative.
  ///
  /// In id, this message translates to:
  /// **'Tidak boleh negatif'**
  String get productErrorNegative;

  /// No description provided for @productErrorNotPositive.
  ///
  /// In id, this message translates to:
  /// **'Harus lebih dari 0'**
  String get productErrorNotPositive;

  /// No description provided for @productErrorDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Kembar di produk ini'**
  String get productErrorDuplicate;

  /// No description provided for @productErrorSameAsBase.
  ///
  /// In id, this message translates to:
  /// **'Sama dengan satuan dasar'**
  String get productErrorSameAsBase;

  /// No description provided for @productErrorFactorTooSmall.
  ///
  /// In id, this message translates to:
  /// **'Isi harus lebih dari 1'**
  String get productErrorFactorTooSmall;

  /// No description provided for @productErrorMinQtyTooSmall.
  ///
  /// In id, this message translates to:
  /// **'Harus lebih dari 1'**
  String get productErrorMinQtyTooSmall;

  /// No description provided for @productErrorTaken.
  ///
  /// In id, this message translates to:
  /// **'Sudah dipakai {name}'**
  String productErrorTaken(String name);

  /// No description provided for @productErrorVariantsRequired.
  ///
  /// In id, this message translates to:
  /// **'Minimal satu varian'**
  String get productErrorVariantsRequired;

  /// No description provided for @cashierContext.
  ///
  /// In id, this message translates to:
  /// **'Kasir: {name} · Sesi dibuka {time}'**
  String cashierContext(String name, String time);

  /// No description provided for @cashierSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari produk atau scan barcode…'**
  String get cashierSearchHint;

  /// No description provided for @cashierScannerReady.
  ///
  /// In id, this message translates to:
  /// **'Scanner siap'**
  String get cashierScannerReady;

  /// No description provided for @cashierScanUnknown.
  ///
  /// In id, this message translates to:
  /// **'Barcode tidak dikenal: {code}'**
  String cashierScanUnknown(String code);

  /// No description provided for @cashierAllCategories.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get cashierAllCategories;

  /// No description provided for @cashierNoProducts.
  ///
  /// In id, this message translates to:
  /// **'Belum ada produk aktif. Tambahkan di menu Produk.'**
  String get cashierNoProducts;

  /// No description provided for @cashierNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada produk yang cocok.'**
  String get cashierNoMatch;

  /// No description provided for @cashierStock.
  ///
  /// In id, this message translates to:
  /// **'Stok {qty}'**
  String cashierStock(String qty);

  /// No description provided for @cashierOrder.
  ///
  /// In id, this message translates to:
  /// **'Pesanan'**
  String get cashierOrder;

  /// No description provided for @cashierWalkIn.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan umum · Ambil sendiri'**
  String get cashierWalkIn;

  /// No description provided for @cashierCartEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada barang. Scan barcode atau ketuk produk.'**
  String get cashierCartEmpty;

  /// No description provided for @cashierTierNote.
  ///
  /// In id, this message translates to:
  /// **'grosir ≥ {qty}'**
  String cashierTierNote(String qty);

  /// No description provided for @cashierSubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get cashierSubtotal;

  /// No description provided for @cashierTierDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon grosir'**
  String get cashierTierDiscount;

  /// No description provided for @cashierTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get cashierTotal;

  /// No description provided for @cashierClear.
  ///
  /// In id, this message translates to:
  /// **'Kosongkan'**
  String get cashierClear;

  /// No description provided for @cashierPay.
  ///
  /// In id, this message translates to:
  /// **'Bayar'**
  String get cashierPay;

  /// No description provided for @cashierPayAmount.
  ///
  /// In id, this message translates to:
  /// **'Bayar {amount}'**
  String cashierPayAmount(String amount);

  /// No description provided for @cashierMobileSummary.
  ///
  /// In id, this message translates to:
  /// **'{lines} produk · {items} item'**
  String cashierMobileSummary(int lines, String items);

  /// No description provided for @cashierViewOrder.
  ///
  /// In id, this message translates to:
  /// **'Lihat pesanan'**
  String get cashierViewOrder;

  /// No description provided for @cashierPickTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih varian / satuan'**
  String get cashierPickTitle;

  /// No description provided for @cashierQtyTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah jumlah'**
  String get cashierQtyTitle;

  /// No description provided for @cashierQtyLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah ({unit})'**
  String cashierQtyLabel(String unit);

  /// No description provided for @cashierQtySave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get cashierQtySave;

  /// No description provided for @cashierCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cashierCancel;

  /// No description provided for @cashierDecrease.
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get cashierDecrease;

  /// No description provided for @cashierIncrease.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get cashierIncrease;

  /// No description provided for @cashierNoSessionTitle.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi kasir dulu'**
  String get cashierNoSessionTitle;

  /// No description provided for @cashierNoSessionBody.
  ///
  /// In id, this message translates to:
  /// **'Penjualan dicatat ke sesi kasir perangkat ini agar uang laci bisa direkap saat tutup sesi.'**
  String get cashierNoSessionBody;

  /// No description provided for @cashierOpenSession.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi kasir'**
  String get cashierOpenSession;

  /// No description provided for @cashierLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Kasir gagal dimuat.'**
  String get cashierLoadFailed;

  /// No description provided for @paymentTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran · Total {amount}'**
  String paymentTitle(String amount);

  /// No description provided for @paymentBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke pesanan'**
  String get paymentBack;

  /// No description provided for @paymentLines.
  ///
  /// In id, this message translates to:
  /// **'{count} item'**
  String paymentLines(int count);

  /// No description provided for @paymentCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get paymentCash;

  /// No description provided for @paymentCashHint.
  ///
  /// In id, this message translates to:
  /// **'Hitung kembalian'**
  String get paymentCashHint;

  /// No description provided for @paymentCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu debit / kredit'**
  String get paymentCard;

  /// No description provided for @paymentCardHint.
  ///
  /// In id, this message translates to:
  /// **'EDC terpisah'**
  String get paymentCardHint;

  /// No description provided for @paymentTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer bank'**
  String get paymentTransfer;

  /// No description provided for @paymentTransferHint.
  ///
  /// In id, this message translates to:
  /// **'Cek mutasi dulu'**
  String get paymentTransferHint;

  /// No description provided for @paymentReceived.
  ///
  /// In id, this message translates to:
  /// **'Uang diterima'**
  String get paymentReceived;

  /// No description provided for @paymentExact.
  ///
  /// In id, this message translates to:
  /// **'Uang pas'**
  String get paymentExact;

  /// No description provided for @paymentChange.
  ///
  /// In id, this message translates to:
  /// **'Kembalian'**
  String get paymentChange;

  /// No description provided for @paymentShort.
  ///
  /// In id, this message translates to:
  /// **'Kurang {amount}'**
  String paymentShort(String amount);

  /// No description provided for @paymentApproval.
  ///
  /// In id, this message translates to:
  /// **'No. approval kartu (opsional)'**
  String get paymentApproval;

  /// No description provided for @paymentApprovalHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 004512'**
  String get paymentApprovalHint;

  /// No description provided for @paymentReference.
  ///
  /// In id, this message translates to:
  /// **'Referensi transfer (opsional)'**
  String get paymentReference;

  /// No description provided for @paymentReferenceTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 40 karakter'**
  String get paymentReferenceTooLong;

  /// No description provided for @paymentNonCashNote.
  ///
  /// In id, this message translates to:
  /// **'Jumlah dibayar sama dengan total {amount}.'**
  String paymentNonCashNote(String amount);

  /// No description provided for @paymentFinish.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan pembayaran'**
  String get paymentFinish;

  /// No description provided for @paymentErrorSession.
  ///
  /// In id, this message translates to:
  /// **'Sesi kasir sudah ditutup. Buka sesi lagi untuk melanjutkan.'**
  String get paymentErrorSession;

  /// No description provided for @paymentErrorUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Ada produk yang tidak tersedia lagi. Periksa pesanan.'**
  String get paymentErrorUnavailable;

  /// No description provided for @paymentErrorShort.
  ///
  /// In id, this message translates to:
  /// **'Uang diterima kurang dari total.'**
  String get paymentErrorShort;

  /// No description provided for @paymentErrorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran gagal disimpan. Coba lagi.'**
  String get paymentErrorGeneric;

  /// No description provided for @successHeader.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran selesai'**
  String get successHeader;

  /// No description provided for @successReceiptNo.
  ///
  /// In id, this message translates to:
  /// **'Nota {number}'**
  String successReceiptNo(String number);

  /// No description provided for @successTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran berhasil'**
  String get successTitle;

  /// No description provided for @successDetail.
  ///
  /// In id, this message translates to:
  /// **'{method} {amount} · {time} · {name}'**
  String successDetail(String method, String amount, String time, String name);

  /// No description provided for @successChange.
  ///
  /// In id, this message translates to:
  /// **'Kembalian'**
  String get successChange;

  /// No description provided for @successNegativeTitle.
  ///
  /// In id, this message translates to:
  /// **'Stok jadi minus'**
  String get successNegativeTitle;

  /// No description provided for @successNegativeBody.
  ///
  /// In id, this message translates to:
  /// **'{name} sekarang {qty}. Cek stok atau catat penyesuaian.'**
  String successNegativeBody(String name, String qty);

  /// No description provided for @successPrintNote.
  ///
  /// In id, this message translates to:
  /// **'Cetak otomatis setelah bayar bisa diaktifkan di Pengaturan › Struk & printer.'**
  String get successPrintNote;

  /// No description provided for @successNew.
  ///
  /// In id, this message translates to:
  /// **'Transaksi baru'**
  String get successNew;

  /// No description provided for @receiptNo.
  ///
  /// In id, this message translates to:
  /// **'No'**
  String get receiptNo;

  /// No description provided for @receiptDate.
  ///
  /// In id, this message translates to:
  /// **'Tgl'**
  String get receiptDate;

  /// No description provided for @receiptCashier.
  ///
  /// In id, this message translates to:
  /// **'Kasir'**
  String get receiptCashier;

  /// No description provided for @receiptTotal.
  ///
  /// In id, this message translates to:
  /// **'TOTAL'**
  String get receiptTotal;

  /// No description provided for @receiptChange.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get receiptChange;

  /// No description provided for @receiptThanks.
  ///
  /// In id, this message translates to:
  /// **'Terima kasih, sampai jumpa lagi!'**
  String get receiptThanks;

  /// Harga termurah di kartu produk kasir bila varian berbeda harga.
  ///
  /// In id, this message translates to:
  /// **'mulai {price}'**
  String cashierPriceFrom(String price);

  /// No description provided for @paymentErrorPermission.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin menyimpan penjualan. Minta pemilik atau manajer.'**
  String get paymentErrorPermission;

  /// No description provided for @paymentQris.
  ///
  /// In id, this message translates to:
  /// **'QRIS statis'**
  String get paymentQris;

  /// No description provided for @paymentQrisHint.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi manual'**
  String get paymentQrisHint;

  /// No description provided for @paymentSplit.
  ///
  /// In id, this message translates to:
  /// **'Bagi beberapa metode'**
  String get paymentSplit;

  /// No description provided for @paymentSplitHint.
  ///
  /// In id, this message translates to:
  /// **'Split payment'**
  String get paymentSplitHint;

  /// No description provided for @paymentSplitSummary.
  ///
  /// In id, this message translates to:
  /// **'Split · {count} metode'**
  String paymentSplitSummary(int count);

  /// No description provided for @paymentErrorQrisOff.
  ///
  /// In id, this message translates to:
  /// **'QRIS statis tidak aktif di cabang ini. Pilih metode lain.'**
  String get paymentErrorQrisOff;

  /// No description provided for @paymentErrorUnconfirmed.
  ///
  /// In id, this message translates to:
  /// **'QRIS belum dikonfirmasi Sudah Terbayar.'**
  String get paymentErrorUnconfirmed;

  /// No description provided for @paymentErrorSplit.
  ///
  /// In id, this message translates to:
  /// **'Pembagian pembayaran tidak sah. Periksa nominal tiap metode.'**
  String get paymentErrorSplit;

  /// No description provided for @paymentErrorConfirmPermission.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin konfirmasi pembayaran QRIS. Minta supervisor.'**
  String get paymentErrorConfirmPermission;

  /// No description provided for @qrisPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu konfirmasi kasir'**
  String get qrisPending;

  /// No description provided for @qrisInstruction.
  ///
  /// In id, this message translates to:
  /// **'Scan QRIS, ketik nominal persis'**
  String get qrisInstruction;

  /// No description provided for @qrisSettlement.
  ///
  /// In id, this message translates to:
  /// **'Dana masuk ke: {target}'**
  String qrisSettlement(String target);

  /// No description provided for @qrisStep1.
  ///
  /// In id, this message translates to:
  /// **'Tunjukkan stiker QRIS ke pelanggan.'**
  String get qrisStep1;

  /// No description provided for @qrisStep2.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan scan dan mengetik nominal {amount}.'**
  String qrisStep2(String amount);

  /// No description provided for @qrisStep3.
  ///
  /// In id, this message translates to:
  /// **'Cek notifikasi atau mutasi dana masuk.'**
  String get qrisStep3;

  /// No description provided for @qrisStep4.
  ///
  /// In id, this message translates to:
  /// **'Tekan Sudah Terbayar bila dana sudah masuk.'**
  String get qrisStep4;

  /// No description provided for @qrisWarning.
  ///
  /// In id, this message translates to:
  /// **'Jangan konfirmasi dari tangkapan layar pelanggan saja. Pastikan dana benar-benar masuk.'**
  String get qrisWarning;

  /// No description provided for @qrisEnlarge.
  ///
  /// In id, this message translates to:
  /// **'Perbesar gambar QRIS'**
  String get qrisEnlarge;

  /// No description provided for @qrisTapFullscreen.
  ///
  /// In id, this message translates to:
  /// **'Ketuk gambar untuk layar penuh'**
  String get qrisTapFullscreen;

  /// No description provided for @qrisImageLabel.
  ///
  /// In id, this message translates to:
  /// **'Stiker QRIS statis toko'**
  String get qrisImageLabel;

  /// No description provided for @qrisClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get qrisClose;

  /// No description provided for @qrisNotReceived.
  ///
  /// In id, this message translates to:
  /// **'Belum masuk'**
  String get qrisNotReceived;

  /// No description provided for @qrisPaid.
  ///
  /// In id, this message translates to:
  /// **'Sudah Terbayar'**
  String get qrisPaid;

  /// No description provided for @qrisNoPermission.
  ///
  /// In id, this message translates to:
  /// **'Butuh izin konfirmasi pembayaran (payments:confirm).'**
  String get qrisNoPermission;

  /// No description provided for @splitTitle.
  ///
  /// In id, this message translates to:
  /// **'Split payment'**
  String get splitTitle;

  /// No description provided for @splitHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: sebagian tunai, sisa QRIS atau kartu.'**
  String get splitHint;

  /// No description provided for @splitAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal'**
  String get splitAmount;

  /// No description provided for @splitAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah metode'**
  String get splitAdd;

  /// No description provided for @splitRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get splitRemove;

  /// No description provided for @splitConfirm.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi'**
  String get splitConfirm;

  /// No description provided for @splitReceived.
  ///
  /// In id, this message translates to:
  /// **'Diterima'**
  String get splitReceived;

  /// No description provided for @splitPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get splitPending;

  /// No description provided for @splitRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa'**
  String get splitRemaining;

  /// No description provided for @splitCashExists.
  ///
  /// In id, this message translates to:
  /// **'Tunai sudah ada. Hapus dulu untuk mengubah.'**
  String get splitCashExists;

  /// No description provided for @splitOverRemaining.
  ///
  /// In id, this message translates to:
  /// **'Melebihi sisa. Kembalian hanya dari tunai.'**
  String get splitOverRemaining;

  /// No description provided for @splitPendingNote.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi semua QRIS yang menunggu sebelum menyelesaikan.'**
  String get splitPendingNote;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsSectionPayments.
  ///
  /// In id, this message translates to:
  /// **'Metode pembayaran'**
  String get settingsSectionPayments;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In id, this message translates to:
  /// **'Tampilan & bahasa'**
  String get settingsSectionAppearance;

  /// No description provided for @settingsBranchScope.
  ///
  /// In id, this message translates to:
  /// **'Berlaku untuk {outlet} · semua perangkat cabang ini'**
  String settingsBranchScope(String outlet);

  /// No description provided for @qrisSettingsBreadcrumb.
  ///
  /// In id, this message translates to:
  /// **'Metode pembayaran › QRIS statis'**
  String get qrisSettingsBreadcrumb;

  /// No description provided for @qrisSettingsImageTitle.
  ///
  /// In id, this message translates to:
  /// **'Gambar QRIS statis'**
  String get qrisSettingsImageTitle;

  /// No description provided for @qrisSettingsImageSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Dipakai di layar Bayar QRIS dan bisa dicetak ulang sebagai stiker meja'**
  String get qrisSettingsImageSubtitle;

  /// No description provided for @qrisSettingsNoImage.
  ///
  /// In id, this message translates to:
  /// **'Belum ada gambar QRIS'**
  String get qrisSettingsNoImage;

  /// No description provided for @qrisSettingsFileInfo.
  ///
  /// In id, this message translates to:
  /// **'{name} · {size}'**
  String qrisSettingsFileInfo(String name, String size);

  /// No description provided for @qrisSettingsReplace.
  ///
  /// In id, this message translates to:
  /// **'Ganti gambar QRIS'**
  String get qrisSettingsReplace;

  /// No description provided for @qrisSettingsUpload.
  ///
  /// In id, this message translates to:
  /// **'Unggah gambar QRIS'**
  String get qrisSettingsUpload;

  /// No description provided for @qrisSettingsUploadHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih file stiker dari perangkat. PNG, JPG, atau WebP, maks 5 MB.'**
  String get qrisSettingsUploadHint;

  /// No description provided for @qrisSettingsPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih file'**
  String get qrisSettingsPick;

  /// No description provided for @qrisSettingsCheckTitle.
  ///
  /// In id, this message translates to:
  /// **'Hasil pemeriksaan'**
  String get qrisSettingsCheckTitle;

  /// No description provided for @qrisSettingsPortrait.
  ///
  /// In id, this message translates to:
  /// **'Rasio vertikal terdeteksi ({ratio}). Gambar ditampilkan utuh, tidak dipotong.'**
  String qrisSettingsPortrait(String ratio);

  /// No description provided for @qrisSettingsNotPortrait.
  ///
  /// In id, this message translates to:
  /// **'Gambar tidak vertikal ({ratio}). Pastikan ini stiker QRIS utuh.'**
  String qrisSettingsNotPortrait(String ratio);

  /// No description provided for @qrisSettingsResolution.
  ///
  /// In id, this message translates to:
  /// **'Resolusi {width} × {height} px.'**
  String qrisSettingsResolution(int width, int height);

  /// No description provided for @qrisSettingsLowResolution.
  ///
  /// In id, this message translates to:
  /// **'Resolusi {width} × {height} px. Disarankan ≥ 1000 px lebar agar tajam di tablet.'**
  String qrisSettingsLowResolution(int width, int height);

  /// No description provided for @qrisSettingsUnsupported.
  ///
  /// In id, this message translates to:
  /// **'File bukan PNG, JPG, atau WebP.'**
  String get qrisSettingsUnsupported;

  /// No description provided for @qrisSettingsTooLarge.
  ///
  /// In id, this message translates to:
  /// **'File lebih dari 5 MB.'**
  String get qrisSettingsTooLarge;

  /// No description provided for @qrisSettingsWholeTitle.
  ///
  /// In id, this message translates to:
  /// **'Unggah stiker utuh, bukan potongan QR'**
  String get qrisSettingsWholeTitle;

  /// No description provided for @qrisSettingsWholeBody.
  ///
  /// In id, this message translates to:
  /// **'Pakai file asli dari bank/PJP atau foto lurus seluruh stiker: header QRIS + GPN, nama merchant, NMID, kode terminal, QR, dan tulisan \"SATU QRIS UNTUK SEMUA\". Pelanggan perlu melihat nama toko untuk yakin sebelum membayar.'**
  String get qrisSettingsWholeBody;

  /// No description provided for @qrisSettingsMerchantTitle.
  ///
  /// In id, this message translates to:
  /// **'Data merchant'**
  String get qrisSettingsMerchantTitle;

  /// No description provided for @qrisSettingsMerchantName.
  ///
  /// In id, this message translates to:
  /// **'Nama merchant di QRIS'**
  String get qrisSettingsMerchantName;

  /// No description provided for @qrisSettingsNmid.
  ///
  /// In id, this message translates to:
  /// **'NMID'**
  String get qrisSettingsNmid;

  /// No description provided for @qrisSettingsNmidHint.
  ///
  /// In id, this message translates to:
  /// **'Nomor ID merchant nasional'**
  String get qrisSettingsNmidHint;

  /// No description provided for @qrisSettingsTerminal.
  ///
  /// In id, this message translates to:
  /// **'Kode terminal'**
  String get qrisSettingsTerminal;

  /// No description provided for @qrisSettingsSettlement.
  ///
  /// In id, this message translates to:
  /// **'Dana masuk ke'**
  String get qrisSettingsSettlement;

  /// No description provided for @qrisSettingsSettlementHint.
  ///
  /// In id, this message translates to:
  /// **'Petunjuk untuk kasir saat cek mutasi, mis. Rekening BCA 123-456-7890'**
  String get qrisSettingsSettlementHint;

  /// No description provided for @qrisSettingsEnabled.
  ///
  /// In id, this message translates to:
  /// **'QRIS statis aktif di kasir'**
  String get qrisSettingsEnabled;

  /// No description provided for @qrisSettingsRequirePaid.
  ///
  /// In id, this message translates to:
  /// **'Wajib tekan \"Sudah Terbayar\"'**
  String get qrisSettingsRequirePaid;

  /// No description provided for @qrisSettingsRequirePaidHint.
  ///
  /// In id, this message translates to:
  /// **'Selalu aktif untuk QRIS statis; tidak bisa dimatikan'**
  String get qrisSettingsRequirePaidHint;

  /// No description provided for @qrisSettingsSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get qrisSettingsSave;

  /// No description provided for @qrisSettingsCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get qrisSettingsCancel;

  /// No description provided for @qrisSettingsSaved.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan QRIS tersimpan'**
  String get qrisSettingsSaved;

  /// No description provided for @qrisSettingsImageMissing.
  ///
  /// In id, this message translates to:
  /// **'Unggah gambar QRIS sebelum mengaktifkan.'**
  String get qrisSettingsImageMissing;

  /// No description provided for @qrisSettingsTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} karakter'**
  String qrisSettingsTooLong(int max);

  /// No description provided for @qrisSettingsNmidInvalid.
  ///
  /// In id, this message translates to:
  /// **'Hanya huruf dan angka, maks 20'**
  String get qrisSettingsNmidInvalid;

  /// No description provided for @qrisSettingsLoadError.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan QRIS gagal dimuat.'**
  String get qrisSettingsLoadError;

  /// No description provided for @receiptSampleNumber.
  ///
  /// In id, this message translates to:
  /// **'PST-K01-261103-0001'**
  String get receiptSampleNumber;

  /// No description provided for @receiptPrinterTitle.
  ///
  /// In id, this message translates to:
  /// **'Printer struk'**
  String get receiptPrinterTitle;

  /// No description provided for @receiptPrinterNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada printer'**
  String get receiptPrinterNone;

  /// No description provided for @receiptPrinterNoneHint.
  ///
  /// In id, this message translates to:
  /// **'Atur di Pengaturan › Struk & printer. Tanpa printer, Cetak struk membuka dialog cetak sistem.'**
  String get receiptPrinterNoneHint;

  /// No description provided for @printerKindBluetooth.
  ///
  /// In id, this message translates to:
  /// **'Bluetooth'**
  String get printerKindBluetooth;

  /// No description provided for @printerKindNetwork.
  ///
  /// In id, this message translates to:
  /// **'Jaringan (LAN)'**
  String get printerKindNetwork;

  /// No description provided for @printerKindSystem.
  ///
  /// In id, this message translates to:
  /// **'Dialog cetak sistem'**
  String get printerKindSystem;

  /// No description provided for @receiptPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak struk'**
  String get receiptPrint;

  /// No description provided for @receiptShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan PDF'**
  String get receiptShare;

  /// No description provided for @receiptPrinted.
  ///
  /// In id, this message translates to:
  /// **'Struk terkirim ke printer.'**
  String get receiptPrinted;

  /// No description provided for @receiptPdfSaved.
  ///
  /// In id, this message translates to:
  /// **'PDF disimpan di {path}'**
  String receiptPdfSaved(String path);

  /// No description provided for @receiptShareError.
  ///
  /// In id, this message translates to:
  /// **'PDF struk gagal dibuat.'**
  String get receiptShareError;

  /// No description provided for @printerRetry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get printerRetry;

  /// No description provided for @printerErrorBluetoothOff.
  ///
  /// In id, this message translates to:
  /// **'Bluetooth mati. Nyalakan lalu coba lagi.'**
  String get printerErrorBluetoothOff;

  /// No description provided for @printerErrorPermission.
  ///
  /// In id, this message translates to:
  /// **'Izin Bluetooth ditolak. Izinkan di pengaturan perangkat.'**
  String get printerErrorPermission;

  /// No description provided for @printerErrorConnect.
  ///
  /// In id, this message translates to:
  /// **'Printer tidak bisa dihubungi. Pastikan menyala dan dalam jangkauan.'**
  String get printerErrorConnect;

  /// No description provided for @printerErrorWrite.
  ///
  /// In id, this message translates to:
  /// **'Data gagal terkirim ke printer.'**
  String get printerErrorWrite;

  /// No description provided for @printerErrorTimeout.
  ///
  /// In id, this message translates to:
  /// **'Printer tidak menjawab.'**
  String get printerErrorTimeout;

  /// No description provided for @printerErrorUnsupported.
  ///
  /// In id, this message translates to:
  /// **'Jenis printer ini tidak didukung di perangkat ini.'**
  String get printerErrorUnsupported;

  /// No description provided for @printerErrorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Struk gagal dicetak.'**
  String get printerErrorGeneric;

  /// No description provided for @settingsSectionReceipt.
  ///
  /// In id, this message translates to:
  /// **'Struk & printer'**
  String get settingsSectionReceipt;

  /// No description provided for @receiptSettingsBreadcrumb.
  ///
  /// In id, this message translates to:
  /// **'Struk & printer'**
  String get receiptSettingsBreadcrumb;

  /// No description provided for @receiptDeviceTitle.
  ///
  /// In id, this message translates to:
  /// **'Printer perangkat ini'**
  String get receiptDeviceTitle;

  /// No description provided for @receiptDeviceSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Disimpan di perangkat ini saja, tidak ikut ke perangkat lain.'**
  String get receiptDeviceSubtitle;

  /// No description provided for @printerSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari printer'**
  String get printerSearch;

  /// No description provided for @printerBluetoothEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada printer yang dipasangkan. Pasangkan printer di pengaturan Bluetooth perangkat, lalu cari lagi.'**
  String get printerBluetoothEmpty;

  /// No description provided for @printerBluetoothUnsupported.
  ///
  /// In id, this message translates to:
  /// **'Printer Bluetooth tersedia di Android. Di perangkat ini pakai printer jaringan atau dialog cetak sistem.'**
  String get printerBluetoothUnsupported;

  /// No description provided for @printerSelected.
  ///
  /// In id, this message translates to:
  /// **'Terpilih'**
  String get printerSelected;

  /// No description provided for @printerChoose.
  ///
  /// In id, this message translates to:
  /// **'Pilih'**
  String get printerChoose;

  /// No description provided for @printerAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat printer'**
  String get printerAddress;

  /// No description provided for @printerAddressHint.
  ///
  /// In id, this message translates to:
  /// **'IP atau nama host, port bawaan 9100. Contoh 192.168.1.50:9100'**
  String get printerAddressHint;

  /// No description provided for @printerAddressInvalid.
  ///
  /// In id, this message translates to:
  /// **'Alamat tidak sah. Contoh 192.168.1.50 atau 192.168.1.50:9100'**
  String get printerAddressInvalid;

  /// No description provided for @printerUseAddress.
  ///
  /// In id, this message translates to:
  /// **'Pakai alamat ini'**
  String get printerUseAddress;

  /// No description provided for @printerSystemNote.
  ///
  /// In id, this message translates to:
  /// **'Struk dikirim sebagai PDF ke dialog cetak sistem operasi, untuk printer USB atau printer dengan driver.'**
  String get printerSystemNote;

  /// No description provided for @printerUseSystem.
  ///
  /// In id, this message translates to:
  /// **'Pakai dialog cetak sistem'**
  String get printerUseSystem;

  /// No description provided for @printerTest.
  ///
  /// In id, this message translates to:
  /// **'Tes cetak'**
  String get printerTest;

  /// No description provided for @printerTestSent.
  ///
  /// In id, this message translates to:
  /// **'Tes cetak terkirim.'**
  String get printerTestSent;

  /// No description provided for @printerForget.
  ///
  /// In id, this message translates to:
  /// **'Lupakan printer'**
  String get printerForget;

  /// No description provided for @receiptOutletTitle.
  ///
  /// In id, this message translates to:
  /// **'Struk cabang ini'**
  String get receiptOutletTitle;

  /// No description provided for @receiptPaperWidth.
  ///
  /// In id, this message translates to:
  /// **'Lebar kertas'**
  String get receiptPaperWidth;

  /// No description provided for @receiptPaperOption.
  ///
  /// In id, this message translates to:
  /// **'{mm} mm · {columns} kolom'**
  String receiptPaperOption(int mm, int columns);

  /// No description provided for @receiptHeader.
  ///
  /// In id, this message translates to:
  /// **'Header struk'**
  String get receiptHeader;

  /// No description provided for @receiptHeaderHint.
  ///
  /// In id, this message translates to:
  /// **'Alamat, telepon, atau teks lain di bawah nama toko. Maks 4 baris.'**
  String get receiptHeaderHint;

  /// No description provided for @receiptFooter.
  ///
  /// In id, this message translates to:
  /// **'Footer struk'**
  String get receiptFooter;

  /// No description provided for @receiptFooterHint.
  ///
  /// In id, this message translates to:
  /// **'Pesan penutup. Maks 4 baris.'**
  String get receiptFooterHint;

  /// No description provided for @receiptTooManyLines.
  ///
  /// In id, this message translates to:
  /// **'Maks 4 baris'**
  String get receiptTooManyLines;

  /// No description provided for @receiptLineTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maks 48 karakter per baris'**
  String get receiptLineTooLong;

  /// No description provided for @receiptAutoPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak otomatis setelah bayar'**
  String get receiptAutoPrint;

  /// No description provided for @receiptAutoPrintHint.
  ///
  /// In id, this message translates to:
  /// **'Hanya untuk printer Bluetooth atau jaringan.'**
  String get receiptAutoPrintHint;

  /// No description provided for @receiptPreviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau struk'**
  String get receiptPreviewTitle;

  /// No description provided for @receiptSettingsSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get receiptSettingsSave;

  /// No description provided for @receiptSettingsCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get receiptSettingsCancel;

  /// No description provided for @receiptSettingsSaved.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan struk tersimpan'**
  String get receiptSettingsSaved;

  /// No description provided for @receiptSettingsLoadError.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan struk gagal dimuat.'**
  String get receiptSettingsLoadError;

  /// No description provided for @stockTitle.
  ///
  /// In id, this message translates to:
  /// **'Stok'**
  String get stockTitle;

  /// No description provided for @stockSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{location} · {outlet}'**
  String stockSubtitle(String location, String outlet);

  /// No description provided for @stockTabList.
  ///
  /// In id, this message translates to:
  /// **'Daftar produk'**
  String get stockTabList;

  /// No description provided for @stockTabAdjustment.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian'**
  String get stockTabAdjustment;

  /// No description provided for @stockTabCard.
  ///
  /// In id, this message translates to:
  /// **'Kartu stok'**
  String get stockTabCard;

  /// No description provided for @stockTabMinimum.
  ///
  /// In id, this message translates to:
  /// **'Stok minimum'**
  String get stockTabMinimum;

  /// No description provided for @stockTabLocations.
  ///
  /// In id, this message translates to:
  /// **'Lokasi stok'**
  String get stockTabLocations;

  /// No description provided for @stockLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data stok gagal dimuat.'**
  String get stockLoadFailed;

  /// No description provided for @stockSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nama, SKU, atau barcode'**
  String get stockSearchHint;

  /// No description provided for @stockLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get stockLocation;

  /// No description provided for @stockColProduct.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get stockColProduct;

  /// No description provided for @stockColStock.
  ///
  /// In id, this message translates to:
  /// **'Stok'**
  String get stockColStock;

  /// No description provided for @stockColMinimum.
  ///
  /// In id, this message translates to:
  /// **'Minimum'**
  String get stockColMinimum;

  /// No description provided for @stockColValue.
  ///
  /// In id, this message translates to:
  /// **'Nilai (HPP)'**
  String get stockColValue;

  /// No description provided for @stockColSystem.
  ///
  /// In id, this message translates to:
  /// **'Sistem'**
  String get stockColSystem;

  /// No description provided for @stockColPhysical.
  ///
  /// In id, this message translates to:
  /// **'Fisik'**
  String get stockColPhysical;

  /// No description provided for @stockColDifference.
  ///
  /// In id, this message translates to:
  /// **'Selisih'**
  String get stockColDifference;

  /// No description provided for @stockColReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get stockColReason;

  /// No description provided for @stockBadgeLow.
  ///
  /// In id, this message translates to:
  /// **'Di bawah minimum'**
  String get stockBadgeLow;

  /// No description provided for @stockBadgeNegative.
  ///
  /// In id, this message translates to:
  /// **'Minus'**
  String get stockBadgeNegative;

  /// No description provided for @stockEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada produk barang. Tambahkan di menu Produk.'**
  String get stockEmpty;

  /// No description provided for @stockNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada produk yang cocok.'**
  String get stockNoMatch;

  /// No description provided for @stockValueTotal.
  ///
  /// In id, this message translates to:
  /// **'Nilai stok {value}'**
  String stockValueTotal(String value);

  /// No description provided for @stockAdjustmentNew.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian stok baru'**
  String get stockAdjustmentNew;

  /// No description provided for @stockAdjustmentMeta.
  ///
  /// In id, this message translates to:
  /// **'{number} · {staff}'**
  String stockAdjustmentMeta(String number, String staff);

  /// No description provided for @stockReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan umum'**
  String get stockReasonLabel;

  /// No description provided for @stockReasonRoutineCheck.
  ///
  /// In id, this message translates to:
  /// **'Cek rutin'**
  String get stockReasonRoutineCheck;

  /// No description provided for @stockReasonDamaged.
  ///
  /// In id, this message translates to:
  /// **'Rusak'**
  String get stockReasonDamaged;

  /// No description provided for @stockReasonLost.
  ///
  /// In id, this message translates to:
  /// **'Hilang'**
  String get stockReasonLost;

  /// No description provided for @stockReasonExpired.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa'**
  String get stockReasonExpired;

  /// No description provided for @stockReasonOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get stockReasonOther;

  /// No description provided for @stockNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get stockNoteLabel;

  /// No description provided for @stockNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Mis. cek rutin mingguan'**
  String get stockNoteHint;

  /// No description provided for @stockLineNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Alasan baris'**
  String get stockLineNoteHint;

  /// No description provided for @stockAddLabel.
  ///
  /// In id, this message translates to:
  /// **'Scan / tambah produk'**
  String get stockAddLabel;

  /// No description provided for @stockAddHint.
  ///
  /// In id, this message translates to:
  /// **'Scan barcode atau ketik nama produk'**
  String get stockAddHint;

  /// No description provided for @stockAddNotFound.
  ///
  /// In id, this message translates to:
  /// **'Produk \"{code}\" tidak ditemukan.'**
  String stockAddNotFound(String code);

  /// No description provided for @stockAddAlready.
  ///
  /// In id, this message translates to:
  /// **'Produk ini sudah ada di daftar penyesuaian.'**
  String get stockAddAlready;

  /// No description provided for @stockLinesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tambah produk yang dihitung, lalu isi stok fisiknya. Baris yang fisiknya kosong tidak disimpan.'**
  String get stockLinesEmpty;

  /// No description provided for @stockTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get stockTotal;

  /// No description provided for @stockSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan penyesuaian'**
  String get stockSave;

  /// No description provided for @stockClear.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get stockClear;

  /// No description provided for @stockSaved.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian {number} tersimpan.'**
  String stockSaved(String number);

  /// No description provided for @stockPermissionNote.
  ///
  /// In id, this message translates to:
  /// **'Butuh izin stock:adjust. Tercatat sebagai pergerakan stok dengan alasan, bisa diaudit.'**
  String get stockPermissionNote;

  /// No description provided for @stockNoPermission.
  ///
  /// In id, this message translates to:
  /// **'Anda hanya bisa melihat stok. Penyesuaian butuh izin stock:adjust.'**
  String get stockNoPermission;

  /// No description provided for @stockErrorEmpty.
  ///
  /// In id, this message translates to:
  /// **'Isi stok fisik minimal satu produk.'**
  String get stockErrorEmpty;

  /// No description provided for @stockErrorNegative.
  ///
  /// In id, this message translates to:
  /// **'Stok fisik tidak boleh minus.'**
  String get stockErrorNegative;

  /// No description provided for @stockErrorDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Produk yang sama ada dua kali.'**
  String get stockErrorDuplicate;

  /// No description provided for @stockErrorNotGoods.
  ///
  /// In id, this message translates to:
  /// **'Jasa dan menu tidak punya stok.'**
  String get stockErrorNotGoods;

  /// No description provided for @stockErrorUnknownVariant.
  ///
  /// In id, this message translates to:
  /// **'Produk sudah dihapus atau tidak ditemukan.'**
  String get stockErrorUnknownVariant;

  /// No description provided for @stockErrorUnknownLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi stok tidak ditemukan.'**
  String get stockErrorUnknownLocation;

  /// No description provided for @stockErrorNoChange.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada selisih: stok fisik sama dengan stok sistem.'**
  String get stockErrorNoChange;

  /// No description provided for @stockErrorNoteTooLong.
  ///
  /// In id, this message translates to:
  /// **'Alasan atau catatan terlalu panjang.'**
  String get stockErrorNoteTooLong;

  /// No description provided for @stockErrorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian gagal disimpan.'**
  String get stockErrorGeneric;

  /// No description provided for @stockRecentTitle.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian terakhir'**
  String get stockRecentTitle;

  /// No description provided for @stockRecentEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada penyesuaian.'**
  String get stockRecentEmpty;

  /// No description provided for @stockRecentMeta.
  ///
  /// In id, this message translates to:
  /// **'{reason} · {count} produk · {staff}'**
  String stockRecentMeta(String reason, int count, String staff);

  /// No description provided for @stockCardTitle.
  ///
  /// In id, this message translates to:
  /// **'Kartu stok'**
  String get stockCardTitle;

  /// No description provided for @stockCardCurrent.
  ///
  /// In id, this message translates to:
  /// **'Stok sekarang {stock} · minimum {minimum}'**
  String stockCardCurrent(String stock, String minimum);

  /// No description provided for @stockCardCurrentNoMin.
  ///
  /// In id, this message translates to:
  /// **'Stok sekarang {stock}'**
  String stockCardCurrentNoMin(String stock);

  /// No description provided for @stockCardProduct.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get stockCardProduct;

  /// No description provided for @stockColTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get stockColTime;

  /// No description provided for @stockColDescription.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get stockColDescription;

  /// No description provided for @stockColInOut.
  ///
  /// In id, this message translates to:
  /// **'Masuk/keluar'**
  String get stockColInOut;

  /// No description provided for @stockColBalance.
  ///
  /// In id, this message translates to:
  /// **'Saldo'**
  String get stockColBalance;

  /// No description provided for @stockCardEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pergerakan.'**
  String get stockCardEmpty;

  /// No description provided for @stockCardNote.
  ///
  /// In id, this message translates to:
  /// **'Kartu stok = daftar pergerakan (ledger). Saldo tidak pernah diedit langsung, selalu lewat entri baru.'**
  String get stockCardNote;

  /// No description provided for @stockCardOpening.
  ///
  /// In id, this message translates to:
  /// **'Saldo sebelumnya {balance}'**
  String stockCardOpening(String balance);

  /// No description provided for @stockSourceOpening.
  ///
  /// In id, this message translates to:
  /// **'Stok awal'**
  String get stockSourceOpening;

  /// No description provided for @stockSourceSale.
  ///
  /// In id, this message translates to:
  /// **'Penjualan'**
  String get stockSourceSale;

  /// No description provided for @stockSourceSaleReturn.
  ///
  /// In id, this message translates to:
  /// **'Retur penjualan'**
  String get stockSourceSaleReturn;

  /// No description provided for @stockSourcePurchase.
  ///
  /// In id, this message translates to:
  /// **'Pembelian'**
  String get stockSourcePurchase;

  /// No description provided for @stockSourcePurchaseReturn.
  ///
  /// In id, this message translates to:
  /// **'Retur pembelian'**
  String get stockSourcePurchaseReturn;

  /// No description provided for @stockSourceTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get stockSourceTransfer;

  /// No description provided for @stockSourceAdjustment.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian'**
  String get stockSourceAdjustment;

  /// No description provided for @stockMinimumTitle.
  ///
  /// In id, this message translates to:
  /// **'Di bawah stok minimum'**
  String get stockMinimumTitle;

  /// No description provided for @stockMinimumCount.
  ///
  /// In id, this message translates to:
  /// **'{count} produk'**
  String stockMinimumCount(int count);

  /// No description provided for @stockMinimumEmpty.
  ///
  /// In id, this message translates to:
  /// **'Semua stok di atas minimum.'**
  String get stockMinimumEmpty;

  /// No description provided for @stockMinimumPurchaseSoon.
  ///
  /// In id, this message translates to:
  /// **'Pesanan pembelian dari daftar ini menyusul bersama modul Pembelian.'**
  String get stockMinimumPurchaseSoon;

  /// No description provided for @stockLocationsHint.
  ///
  /// In id, this message translates to:
  /// **'Etalase, gudang, atau rak terpisah di cabang ini.'**
  String get stockLocationsHint;

  /// No description provided for @stockLocationDefault.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get stockLocationDefault;

  /// No description provided for @stockLocationNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama lokasi'**
  String get stockLocationNameLabel;

  /// No description provided for @stockLocationAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah lokasi'**
  String get stockLocationAdd;

  /// No description provided for @stockLocationRename.
  ///
  /// In id, this message translates to:
  /// **'Ganti nama'**
  String get stockLocationRename;

  /// No description provided for @stockLocationSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get stockLocationSave;

  /// No description provided for @stockLocationCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get stockLocationCancel;

  /// No description provided for @stockLocationErrorEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama lokasi wajib diisi.'**
  String get stockLocationErrorEmpty;

  /// No description provided for @stockLocationErrorTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama lokasi maks 40 karakter.'**
  String get stockLocationErrorTooLong;

  /// No description provided for @stockLocationErrorDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Nama lokasi sudah dipakai di cabang ini.'**
  String get stockLocationErrorDuplicate;

  /// No description provided for @stockRemoveLine.
  ///
  /// In id, this message translates to:
  /// **'Hapus baris'**
  String get stockRemoveLine;
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
