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
  /// **'Produk pertama'**
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
  /// **'Produk pertama, lalu mulai jualan'**
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
  /// **'Lanjut: produk'**
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

  /// No description provided for @cashRecapCashRefunds.
  ///
  /// In id, this message translates to:
  /// **'Retur tunai'**
  String get cashRecapCashRefunds;

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
  /// **'Harga grosir dipakai otomatis di kasir saat jumlah beli mencapai tingkatnya. Harga untuk grup pelanggan dipakai bila pelanggan grup itu dipilih di kasir; bila ada dua harga, yang termurah dipakai.'**
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

  /// No description provided for @menuMasterData.
  ///
  /// In id, this message translates to:
  /// **'Master data'**
  String get menuMasterData;

  /// No description provided for @masterTitle.
  ///
  /// In id, this message translates to:
  /// **'Master data'**
  String get masterTitle;

  /// No description provided for @masterSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Data referensi yang dipakai produk, stok, kasir & laporan'**
  String get masterSubtitle;

  /// No description provided for @masterTabCategories.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get masterTabCategories;

  /// No description provided for @masterTabUnits.
  ///
  /// In id, this message translates to:
  /// **'Satuan'**
  String get masterTabUnits;

  /// No description provided for @masterTabLocations.
  ///
  /// In id, this message translates to:
  /// **'Lokasi stok'**
  String get masterTabLocations;

  /// No description provided for @masterTabPayments.
  ///
  /// In id, this message translates to:
  /// **'Metode pembayaran'**
  String get masterTabPayments;

  /// No description provided for @masterLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat master data.'**
  String get masterLoadFailed;

  /// No description provided for @masterCategoryAdd.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get masterCategoryAdd;

  /// No description provided for @masterColCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get masterColCategory;

  /// No description provided for @masterColProducts.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get masterColProducts;

  /// No description provided for @masterColActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get masterColActive;

  /// No description provided for @masterCategoryEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get masterCategoryEdit;

  /// No description provided for @masterMoveUp.
  ///
  /// In id, this message translates to:
  /// **'Naikkan {name}'**
  String masterMoveUp(String name);

  /// No description provided for @masterMoveDown.
  ///
  /// In id, this message translates to:
  /// **'Turunkan {name}'**
  String masterMoveDown(String name);

  /// No description provided for @masterOrderHint.
  ///
  /// In id, this message translates to:
  /// **'Urutan ini dipakai tab kategori di layar kasir. Ketuk panah untuk menaikkan atau menurunkan.'**
  String get masterOrderHint;

  /// No description provided for @masterProductCount.
  ///
  /// In id, this message translates to:
  /// **'{count} produk'**
  String masterProductCount(int count);

  /// No description provided for @masterCategoryHidden.
  ///
  /// In id, this message translates to:
  /// **'Tidak di kasir'**
  String get masterCategoryHidden;

  /// No description provided for @masterCategoryInactive.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get masterCategoryInactive;

  /// No description provided for @masterCategoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori. Tambahkan di sini atau langsung dari form produk.'**
  String get masterCategoryEmpty;

  /// No description provided for @masterFormNew.
  ///
  /// In id, this message translates to:
  /// **'Kategori baru'**
  String get masterFormNew;

  /// No description provided for @masterFormEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah kategori'**
  String get masterFormEdit;

  /// No description provided for @masterFormName.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori'**
  String get masterFormName;

  /// No description provided for @masterFormParent.
  ///
  /// In id, this message translates to:
  /// **'Kategori induk'**
  String get masterFormParent;

  /// No description provided for @masterFormParentNone.
  ///
  /// In id, this message translates to:
  /// **'(tidak ada)'**
  String get masterFormParentNone;

  /// No description provided for @masterFormParentLocked.
  ///
  /// In id, this message translates to:
  /// **'Kategori ini punya subkategori, jadi tidak bisa diberi induk.'**
  String get masterFormParentLocked;

  /// No description provided for @masterFormColor.
  ///
  /// In id, this message translates to:
  /// **'Warna'**
  String get masterFormColor;

  /// No description provided for @masterColorNone.
  ///
  /// In id, this message translates to:
  /// **'Tanpa warna'**
  String get masterColorNone;

  /// No description provided for @masterColorPick.
  ///
  /// In id, this message translates to:
  /// **'Warna {number}'**
  String masterColorPick(int number);

  /// No description provided for @masterFormShowInCashier.
  ///
  /// In id, this message translates to:
  /// **'Tampil di kasir'**
  String get masterFormShowInCashier;

  /// No description provided for @masterFormShowInCashierHint.
  ///
  /// In id, this message translates to:
  /// **'Muncul sebagai tab kategori di layar kasir.'**
  String get masterFormShowInCashierHint;

  /// No description provided for @masterFormActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get masterFormActive;

  /// No description provided for @masterFormActiveHint.
  ///
  /// In id, this message translates to:
  /// **'Kategori nonaktif tidak tampil di kasir dan tidak disarankan di form produk; produknya tetap dijual.'**
  String get masterFormActiveHint;

  /// No description provided for @masterFormCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get masterFormCancel;

  /// No description provided for @masterFormSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan kategori'**
  String get masterFormSave;

  /// No description provided for @masterFormDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus kategori'**
  String get masterFormDelete;

  /// No description provided for @masterCategorySaved.
  ///
  /// In id, this message translates to:
  /// **'Kategori {name} tersimpan.'**
  String masterCategorySaved(String name);

  /// No description provided for @masterErrNameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori wajib diisi.'**
  String get masterErrNameEmpty;

  /// No description provided for @masterErrNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori maks {max} karakter.'**
  String masterErrNameTooLong(int max);

  /// No description provided for @masterErrNameDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Nama kategori sudah dipakai.'**
  String get masterErrNameDuplicate;

  /// No description provided for @masterErrParentMissing.
  ///
  /// In id, this message translates to:
  /// **'Kategori induk tidak ditemukan.'**
  String get masterErrParentMissing;

  /// No description provided for @masterErrParentSelf.
  ///
  /// In id, this message translates to:
  /// **'Kategori tidak bisa menjadi induk dirinya sendiri.'**
  String get masterErrParentSelf;

  /// No description provided for @masterErrParentNested.
  ///
  /// In id, this message translates to:
  /// **'Induk harus kategori utama (hanya satu tingkat).'**
  String get masterErrParentNested;

  /// No description provided for @masterErrHasChildren.
  ///
  /// In id, this message translates to:
  /// **'Kategori yang punya subkategori tidak bisa diberi induk.'**
  String get masterErrHasChildren;

  /// No description provided for @masterErrColor.
  ///
  /// In id, this message translates to:
  /// **'Pilih warna dari palet.'**
  String get masterErrColor;

  /// No description provided for @masterInUseProducts.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa dihapus: masih dipakai {count} produk.'**
  String masterInUseProducts(int count);

  /// No description provided for @masterInUseChildren.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa dihapus: masih punya {count} subkategori.'**
  String masterInUseChildren(int count);

  /// No description provided for @masterActionFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get masterActionFailed;

  /// No description provided for @masterUnitsHint.
  ///
  /// In id, this message translates to:
  /// **'Satuan dipakai di form produk sebagai satuan dasar dan satuan konversi. Ganti nama langsung terlihat di semua produk.'**
  String get masterUnitsHint;

  /// No description provided for @masterUnitName.
  ///
  /// In id, this message translates to:
  /// **'Nama satuan'**
  String get masterUnitName;

  /// No description provided for @masterUnitAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah satuan'**
  String get masterUnitAdd;

  /// No description provided for @masterUnitRename.
  ///
  /// In id, this message translates to:
  /// **'Ganti nama {name}'**
  String masterUnitRename(String name);

  /// No description provided for @masterUnitDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus {name}'**
  String masterUnitDelete(String name);

  /// No description provided for @masterUnitSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get masterUnitSave;

  /// No description provided for @masterUnitCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get masterUnitCancel;

  /// No description provided for @masterUnitErrEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama satuan wajib diisi.'**
  String get masterUnitErrEmpty;

  /// No description provided for @masterUnitErrTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama satuan maks {max} karakter.'**
  String masterUnitErrTooLong(int max);

  /// No description provided for @masterUnitErrDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Nama satuan sudah dipakai.'**
  String get masterUnitErrDuplicate;

  /// No description provided for @masterUnitEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada satuan. Satuan juga dibuat otomatis dari form produk.'**
  String get masterUnitEmpty;

  /// No description provided for @masterLocationsHint.
  ///
  /// In id, this message translates to:
  /// **'Lokasi stok per cabang (etalase, gudang). Tambah dan ganti nama lokasi di layar Stok.'**
  String get masterLocationsHint;

  /// No description provided for @masterLocationsManage.
  ///
  /// In id, this message translates to:
  /// **'Kelola di Stok'**
  String get masterLocationsManage;

  /// No description provided for @masterPaymentsHint.
  ///
  /// In id, this message translates to:
  /// **'Metode bayar yang tersedia di kasir. QRIS statis, struk, dan printer diatur di Pengaturan.'**
  String get masterPaymentsHint;

  /// No description provided for @masterPaymentsOpen.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get masterPaymentsOpen;

  /// No description provided for @masterPaymentQrisHint.
  ///
  /// In id, this message translates to:
  /// **'Gambar stiker QRIS + tombol Sudah Terbayar'**
  String get masterPaymentQrisHint;

  /// No description provided for @masterPaymentAlways.
  ///
  /// In id, this message translates to:
  /// **'Selalu tersedia'**
  String get masterPaymentAlways;

  /// No description provided for @masterInUseBoth.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa dihapus: masih dipakai {products} produk dan punya {children} subkategori.'**
  String masterInUseBoth(int products, int children);

  /// No description provided for @masterDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {name}?'**
  String masterDeleteTitle(String name);

  /// No description provided for @masterDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Data yang dihapus tidak tampil lagi di daftar dan pilihan.'**
  String get masterDeleteBody;

  /// No description provided for @masterDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get masterDeleteConfirm;

  /// No description provided for @masterDeleteCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get masterDeleteCancel;

  /// No description provided for @menuTables.
  ///
  /// In id, this message translates to:
  /// **'Meja'**
  String get menuTables;

  /// No description provided for @billTableLabel.
  ///
  /// In id, this message translates to:
  /// **'Meja {label}'**
  String billTableLabel(String label);

  /// No description provided for @billTakeAwayLabel.
  ///
  /// In id, this message translates to:
  /// **'Take away {label}'**
  String billTakeAwayLabel(String label);

  /// No description provided for @paymentBillLines.
  ///
  /// In id, this message translates to:
  /// **'{label} · {count} item'**
  String paymentBillLines(String label, int count);

  /// No description provided for @successBackToTables.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke meja'**
  String get successBackToTables;

  /// No description provided for @receiptOrder.
  ///
  /// In id, this message translates to:
  /// **'Pesanan'**
  String get receiptOrder;

  /// No description provided for @receiptSubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get receiptSubtotal;

  /// No description provided for @receiptService.
  ///
  /// In id, this message translates to:
  /// **'Service {pct}'**
  String receiptService(String pct);

  /// No description provided for @receiptTax.
  ///
  /// In id, this message translates to:
  /// **'PB1 {pct}'**
  String receiptTax(String pct);

  /// No description provided for @cashierBillLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Bill gagal dibuka. Mungkin sudah dibayar atau dibatalkan.'**
  String get cashierBillLoadFailed;

  /// No description provided for @cashierBillBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke meja'**
  String get cashierBillBack;

  /// No description provided for @diningTitle.
  ///
  /// In id, this message translates to:
  /// **'Meja'**
  String get diningTitle;

  /// No description provided for @diningSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pelayan: {staff} · {occupied} dari {total} meja terisi'**
  String diningSubtitle(String staff, int occupied, int total);

  /// No description provided for @diningDineIn.
  ///
  /// In id, this message translates to:
  /// **'Dine in'**
  String get diningDineIn;

  /// No description provided for @diningTakeAway.
  ///
  /// In id, this message translates to:
  /// **'Take away'**
  String get diningTakeAway;

  /// No description provided for @diningLegendEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kosong'**
  String get diningLegendEmpty;

  /// No description provided for @diningLegendOpen.
  ///
  /// In id, this message translates to:
  /// **'Terisi · open bill'**
  String get diningLegendOpen;

  /// No description provided for @diningLegendRequested.
  ///
  /// In id, this message translates to:
  /// **'Minta bill'**
  String get diningLegendRequested;

  /// No description provided for @diningAllAreas.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get diningAllAreas;

  /// No description provided for @diningNoArea.
  ///
  /// In id, this message translates to:
  /// **'Tanpa area'**
  String get diningNoArea;

  /// No description provided for @diningNoTables.
  ///
  /// In id, this message translates to:
  /// **'Belum ada meja. Tambahkan di Master data › Meja & area.'**
  String get diningNoTables;

  /// No description provided for @diningSeats.
  ///
  /// In id, this message translates to:
  /// **'{count} kursi'**
  String diningSeats(int count);

  /// No description provided for @diningMinutes.
  ///
  /// In id, this message translates to:
  /// **'{m} mnt'**
  String diningMinutes(int m);

  /// No description provided for @diningHours.
  ///
  /// In id, this message translates to:
  /// **'{h} j {m} mnt'**
  String diningHours(int h, int m);

  /// No description provided for @diningDays.
  ///
  /// In id, this message translates to:
  /// **'{d} hari'**
  String diningDays(int d);

  /// No description provided for @diningTakeAwayNew.
  ///
  /// In id, this message translates to:
  /// **'Take away baru'**
  String get diningTakeAwayNew;

  /// No description provided for @diningTakeAwayNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada take away terbuka.'**
  String get diningTakeAwayNone;

  /// No description provided for @diningTakeAwayItems.
  ///
  /// In id, this message translates to:
  /// **'{count} item · {time}'**
  String diningTakeAwayItems(int count, String time);

  /// No description provided for @diningStatusNew.
  ///
  /// In id, this message translates to:
  /// **'Baru'**
  String get diningStatusNew;

  /// No description provided for @diningStatusKitchen.
  ///
  /// In id, this message translates to:
  /// **'Di dapur'**
  String get diningStatusKitchen;

  /// No description provided for @diningStatusServed.
  ///
  /// In id, this message translates to:
  /// **'Disajikan'**
  String get diningStatusServed;

  /// No description provided for @diningStatusReady.
  ///
  /// In id, this message translates to:
  /// **'Siap ambil'**
  String get diningStatusReady;

  /// No description provided for @diningStatusEmpty.
  ///
  /// In id, this message translates to:
  /// **'Kosong'**
  String get diningStatusEmpty;

  /// No description provided for @diningDeleteEmpty.
  ///
  /// In id, this message translates to:
  /// **'Hapus bill kosong'**
  String get diningDeleteEmpty;

  /// No description provided for @diningSelectHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih meja atau take away untuk melihat bill.'**
  String get diningSelectHint;

  /// No description provided for @diningBillTableTitle.
  ///
  /// In id, this message translates to:
  /// **'Meja {label} · Open bill'**
  String diningBillTableTitle(String label);

  /// No description provided for @diningBillTakeAwayTitle.
  ///
  /// In id, this message translates to:
  /// **'{label} · Take away'**
  String diningBillTakeAwayTitle(String label);

  /// No description provided for @diningBillGuests.
  ///
  /// In id, this message translates to:
  /// **'{count} tamu'**
  String diningBillGuests(int count);

  /// No description provided for @diningBillOpened.
  ///
  /// In id, this message translates to:
  /// **'dibuka {time}'**
  String diningBillOpened(String time);

  /// No description provided for @diningBillServer.
  ///
  /// In id, this message translates to:
  /// **'Pelayan {name}'**
  String diningBillServer(String name);

  /// No description provided for @diningAddMenu.
  ///
  /// In id, this message translates to:
  /// **'Menu'**
  String get diningAddMenu;

  /// No description provided for @diningBillEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada item. Ketuk + Menu untuk menambah.'**
  String get diningBillEmpty;

  /// No description provided for @diningMarkServed.
  ///
  /// In id, this message translates to:
  /// **'Tandai disajikan'**
  String get diningMarkServed;

  /// No description provided for @diningRemoveItem.
  ///
  /// In id, this message translates to:
  /// **'Hapus item'**
  String get diningRemoveItem;

  /// No description provided for @diningSubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get diningSubtotal;

  /// No description provided for @diningService.
  ///
  /// In id, this message translates to:
  /// **'Service {pct} (dine in)'**
  String diningService(String pct);

  /// No description provided for @diningTax.
  ///
  /// In id, this message translates to:
  /// **'PB1 {pct}'**
  String diningTax(String pct);

  /// No description provided for @diningTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get diningTotal;

  /// No description provided for @diningSend.
  ///
  /// In id, this message translates to:
  /// **'Kirim ke dapur ({count} item baru)'**
  String diningSend(int count);

  /// No description provided for @diningRequestBill.
  ///
  /// In id, this message translates to:
  /// **'Minta bill'**
  String get diningRequestBill;

  /// No description provided for @diningCancelRequest.
  ///
  /// In id, this message translates to:
  /// **'Batal minta bill'**
  String get diningCancelRequest;

  /// No description provided for @diningMove.
  ///
  /// In id, this message translates to:
  /// **'Pindah meja'**
  String get diningMove;

  /// No description provided for @diningVoid.
  ///
  /// In id, this message translates to:
  /// **'Batalkan bill'**
  String get diningVoid;

  /// No description provided for @diningPay.
  ///
  /// In id, this message translates to:
  /// **'Tutup & bayar · {amount}'**
  String diningPay(String amount);

  /// No description provided for @diningPayNoPermission.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran oleh kasir (butuh izin penjualan).'**
  String get diningPayNoPermission;

  /// No description provided for @diningBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke meja'**
  String get diningBack;

  /// No description provided for @diningOpenTitle.
  ///
  /// In id, this message translates to:
  /// **'Buka meja {label}'**
  String diningOpenTitle(String label);

  /// No description provided for @diningGuests.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tamu'**
  String get diningGuests;

  /// No description provided for @diningGuestsInvalid.
  ///
  /// In id, this message translates to:
  /// **'Isi 1–99 tamu.'**
  String get diningGuestsInvalid;

  /// No description provided for @diningOpen.
  ///
  /// In id, this message translates to:
  /// **'Buka bill'**
  String get diningOpen;

  /// No description provided for @diningCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get diningCancel;

  /// No description provided for @diningCustomerName.
  ///
  /// In id, this message translates to:
  /// **'Nama pemesan (opsional)'**
  String get diningCustomerName;

  /// No description provided for @diningCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat'**
  String get diningCreate;

  /// No description provided for @diningMoveTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindahkan {label} ke'**
  String diningMoveTitle(String label);

  /// No description provided for @diningMoveNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada meja kosong.'**
  String get diningMoveNone;

  /// No description provided for @diningVoidTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan bill {label}?'**
  String diningVoidTitle(String label);

  /// No description provided for @diningVoidBody.
  ///
  /// In id, this message translates to:
  /// **'Bill ditutup tanpa pembayaran dan stok tidak berubah. Alasan tersimpan di riwayat.'**
  String get diningVoidBody;

  /// No description provided for @diningVoidReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get diningVoidReason;

  /// No description provided for @diningVoidReasonInvalid.
  ///
  /// In id, this message translates to:
  /// **'Alasan wajib diisi, maks 120 karakter.'**
  String get diningVoidReasonInvalid;

  /// No description provided for @diningVoidKeep.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get diningVoidKeep;

  /// No description provided for @diningMenuTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah menu · {label}'**
  String diningMenuTitle(String label);

  /// No description provided for @diningSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari menu'**
  String get diningSearch;

  /// No description provided for @diningNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan dapur untuk item berikutnya (opsional)'**
  String get diningNote;

  /// No description provided for @diningNoteTooLong.
  ///
  /// In id, this message translates to:
  /// **'Catatan maks 120 karakter.'**
  String get diningNoteTooLong;

  /// No description provided for @diningAdded.
  ///
  /// In id, this message translates to:
  /// **'Ditambahkan: {name}'**
  String diningAdded(String name);

  /// No description provided for @diningDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get diningDone;

  /// No description provided for @diningNoMenu.
  ///
  /// In id, this message translates to:
  /// **'Menu tidak ditemukan.'**
  String get diningNoMenu;

  /// No description provided for @diningLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data meja gagal dimuat.'**
  String get diningLoadFailed;

  /// No description provided for @diningErrorLocked.
  ///
  /// In id, this message translates to:
  /// **'Item yang sudah di dapur tidak bisa diubah atau dihapus.'**
  String get diningErrorLocked;

  /// No description provided for @diningErrorOccupied.
  ///
  /// In id, this message translates to:
  /// **'Meja sudah punya bill terbuka.'**
  String get diningErrorOccupied;

  /// No description provided for @diningErrorNothingToSend.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada item baru untuk dikirim.'**
  String get diningErrorNothingToSend;

  /// No description provided for @diningErrorNotFound.
  ///
  /// In id, this message translates to:
  /// **'Bill tidak ditemukan atau sudah ditutup.'**
  String get diningErrorNotFound;

  /// No description provided for @diningErrorNotEmpty.
  ///
  /// In id, this message translates to:
  /// **'Bill masih berisi item.'**
  String get diningErrorNotEmpty;

  /// No description provided for @diningErrorUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Menu tidak tersedia lagi.'**
  String get diningErrorUnavailable;

  /// No description provided for @diningErrorInput.
  ///
  /// In id, this message translates to:
  /// **'Isian tidak sah.'**
  String get diningErrorInput;

  /// No description provided for @diningErrorPermission.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin untuk aksi ini.'**
  String get diningErrorPermission;

  /// No description provided for @diningErrorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Aksi gagal. Coba lagi.'**
  String get diningErrorGeneric;

  /// No description provided for @ticketDialogTitle.
  ///
  /// In id, this message translates to:
  /// **'Terkirim ke dapur'**
  String get ticketDialogTitle;

  /// No description provided for @ticketHeading.
  ///
  /// In id, this message translates to:
  /// **'TIKET DAPUR'**
  String get ticketHeading;

  /// No description provided for @ticketDineIn.
  ///
  /// In id, this message translates to:
  /// **'Meja {label} · Dine in'**
  String ticketDineIn(String label);

  /// No description provided for @ticketTakeAway.
  ///
  /// In id, this message translates to:
  /// **'{label} · Take away'**
  String ticketTakeAway(String label);

  /// No description provided for @ticketNo.
  ///
  /// In id, this message translates to:
  /// **'No'**
  String get ticketNo;

  /// No description provided for @ticketTime.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get ticketTime;

  /// No description provided for @ticketStaff.
  ///
  /// In id, this message translates to:
  /// **'Pelayan'**
  String get ticketStaff;

  /// No description provided for @ticketFooter.
  ///
  /// In id, this message translates to:
  /// **'Item baru saja · tanpa harga'**
  String get ticketFooter;

  /// No description provided for @ticketPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak tiket'**
  String get ticketPrint;

  /// No description provided for @ticketClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get ticketClose;

  /// No description provided for @ticketPrinted.
  ///
  /// In id, this message translates to:
  /// **'Tiket terkirim ke printer.'**
  String get ticketPrinted;

  /// No description provided for @ticketPrintFailed.
  ///
  /// In id, this message translates to:
  /// **'Tiket gagal dicetak. Periksa printer di Pengaturan › Struk & printer.'**
  String get ticketPrintFailed;

  /// No description provided for @masterTabTables.
  ///
  /// In id, this message translates to:
  /// **'Meja & area'**
  String get masterTabTables;

  /// No description provided for @diningSetupHint.
  ///
  /// In id, this message translates to:
  /// **'Meja dipakai di layar Meja (F&B). Nama meja unik per cabang; area opsional.'**
  String get diningSetupHint;

  /// No description provided for @diningSetupAreas.
  ///
  /// In id, this message translates to:
  /// **'Area'**
  String get diningSetupAreas;

  /// No description provided for @diningSetupAreaAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah area'**
  String get diningSetupAreaAdd;

  /// No description provided for @diningSetupAreaTables.
  ///
  /// In id, this message translates to:
  /// **'{count} meja'**
  String diningSetupAreaTables(int count);

  /// No description provided for @diningSetupAreasEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada area. Contoh: Indoor, Teras, Lantai 2.'**
  String get diningSetupAreasEmpty;

  /// No description provided for @diningSetupTables.
  ///
  /// In id, this message translates to:
  /// **'Meja'**
  String get diningSetupTables;

  /// No description provided for @diningSetupTableAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah meja'**
  String get diningSetupTableAdd;

  /// No description provided for @diningSetupTableRange.
  ///
  /// In id, this message translates to:
  /// **'Tambah beberapa'**
  String get diningSetupTableRange;

  /// No description provided for @diningSetupTablesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada meja. Pakai Tambah beberapa untuk membuat M1–M12 sekaligus.'**
  String get diningSetupTablesEmpty;

  /// No description provided for @diningSetupNoArea.
  ///
  /// In id, this message translates to:
  /// **'Tanpa area'**
  String get diningSetupNoArea;

  /// No description provided for @diningSetupName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get diningSetupName;

  /// No description provided for @diningSetupArea.
  ///
  /// In id, this message translates to:
  /// **'Area'**
  String get diningSetupArea;

  /// No description provided for @diningSetupSeats.
  ///
  /// In id, this message translates to:
  /// **'Kursi'**
  String get diningSetupSeats;

  /// No description provided for @diningSetupPrefix.
  ///
  /// In id, this message translates to:
  /// **'Awalan'**
  String get diningSetupPrefix;

  /// No description provided for @diningSetupFrom.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get diningSetupFrom;

  /// No description provided for @diningSetupTo.
  ///
  /// In id, this message translates to:
  /// **'Sampai'**
  String get diningSetupTo;

  /// No description provided for @diningSetupPreview.
  ///
  /// In id, this message translates to:
  /// **'Akan dibuat: {names}'**
  String diningSetupPreview(String names);

  /// No description provided for @diningSetupRangeInvalid.
  ///
  /// In id, this message translates to:
  /// **'Rentang tidak sah (1–50 meja sekaligus).'**
  String get diningSetupRangeInvalid;

  /// No description provided for @diningSetupNewArea.
  ///
  /// In id, this message translates to:
  /// **'Area baru'**
  String get diningSetupNewArea;

  /// No description provided for @diningSetupRenameArea.
  ///
  /// In id, this message translates to:
  /// **'Ganti nama area'**
  String get diningSetupRenameArea;

  /// No description provided for @diningSetupNewTable.
  ///
  /// In id, this message translates to:
  /// **'Meja baru'**
  String get diningSetupNewTable;

  /// No description provided for @diningSetupEditTable.
  ///
  /// In id, this message translates to:
  /// **'Ubah meja'**
  String get diningSetupEditTable;

  /// No description provided for @diningSetupSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get diningSetupSave;

  /// No description provided for @diningSetupCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get diningSetupCancel;

  /// No description provided for @diningSetupDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get diningSetupDelete;

  /// No description provided for @diningSetupDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {name}?'**
  String diningSetupDeleteTitle(String name);

  /// No description provided for @diningSetupDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Data yang dihapus tidak tampil lagi di layar Meja.'**
  String get diningSetupDeleteBody;

  /// No description provided for @diningSetupMoveUp.
  ///
  /// In id, this message translates to:
  /// **'Naikkan'**
  String get diningSetupMoveUp;

  /// No description provided for @diningSetupMoveDown.
  ///
  /// In id, this message translates to:
  /// **'Turunkan'**
  String get diningSetupMoveDown;

  /// No description provided for @diningSetupEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get diningSetupEdit;

  /// No description provided for @diningSetupErrNameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi.'**
  String get diningSetupErrNameEmpty;

  /// No description provided for @diningSetupErrNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama maks {max} karakter.'**
  String diningSetupErrNameTooLong(int max);

  /// No description provided for @diningSetupErrNameDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Nama sudah dipakai.'**
  String get diningSetupErrNameDuplicate;

  /// No description provided for @diningSetupErrNameDuplicateAt.
  ///
  /// In id, this message translates to:
  /// **'Nama {name} sudah dipakai.'**
  String diningSetupErrNameDuplicateAt(String name);

  /// No description provided for @diningSetupErrSeats.
  ///
  /// In id, this message translates to:
  /// **'Kursi 1–99.'**
  String get diningSetupErrSeats;

  /// No description provided for @diningSetupErrAreaInUse.
  ///
  /// In id, this message translates to:
  /// **'Area masih punya {count} meja. Pindahkan atau hapus mejanya dulu.'**
  String diningSetupErrAreaInUse(int count);

  /// No description provided for @diningSetupErrTableBusy.
  ///
  /// In id, this message translates to:
  /// **'Meja masih punya bill terbuka.'**
  String get diningSetupErrTableBusy;

  /// No description provided for @diningSetupErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Aksi gagal. Coba lagi.'**
  String get diningSetupErrGeneric;

  /// No description provided for @diningSetupLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data meja gagal dimuat.'**
  String get diningSetupLoadFailed;

  /// No description provided for @settingsSectionTaxes.
  ///
  /// In id, this message translates to:
  /// **'Pajak & service'**
  String get settingsSectionTaxes;

  /// No description provided for @fnbRatesTitle.
  ///
  /// In id, this message translates to:
  /// **'Pajak & service'**
  String get fnbRatesTitle;

  /// No description provided for @fnbRatesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Berlaku untuk open bill di layar Meja cabang ini.'**
  String get fnbRatesSubtitle;

  /// No description provided for @fnbRatesService.
  ///
  /// In id, this message translates to:
  /// **'Service charge (%)'**
  String get fnbRatesService;

  /// No description provided for @fnbRatesServiceHint.
  ///
  /// In id, this message translates to:
  /// **'0–30%, kelipatan 0,5'**
  String get fnbRatesServiceHint;

  /// No description provided for @fnbRatesTax.
  ///
  /// In id, this message translates to:
  /// **'PB1 / pajak restoran (%)'**
  String get fnbRatesTax;

  /// No description provided for @fnbRatesTaxHint.
  ///
  /// In id, this message translates to:
  /// **'0–20%, kelipatan 0,5'**
  String get fnbRatesTaxHint;

  /// No description provided for @fnbRatesInvalidService.
  ///
  /// In id, this message translates to:
  /// **'Isi 0–30 dengan kelipatan 0,5.'**
  String get fnbRatesInvalidService;

  /// No description provided for @fnbRatesInvalidTax.
  ///
  /// In id, this message translates to:
  /// **'Isi 0–20 dengan kelipatan 0,5.'**
  String get fnbRatesInvalidTax;

  /// No description provided for @fnbRatesNote.
  ///
  /// In id, this message translates to:
  /// **'Service hanya untuk dine in. PB1 dihitung dari subtotal + service.'**
  String get fnbRatesNote;

  /// No description provided for @fnbRatesPreview.
  ///
  /// In id, this message translates to:
  /// **'Contoh dine in'**
  String get fnbRatesPreview;

  /// No description provided for @fnbRatesSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan tarif'**
  String get fnbRatesSave;

  /// No description provided for @fnbRatesSaved.
  ///
  /// In id, this message translates to:
  /// **'Tarif tersimpan.'**
  String get fnbRatesSaved;

  /// No description provided for @fnbRatesLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Tarif gagal dimuat.'**
  String get fnbRatesLoadFailed;

  /// No description provided for @fnbRatesSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Tarif gagal disimpan.'**
  String get fnbRatesSaveFailed;

  /// No description provided for @masterTabModifiers.
  ///
  /// In id, this message translates to:
  /// **'Grup modifier'**
  String get masterTabModifiers;

  /// No description provided for @modifierHint.
  ///
  /// In id, this message translates to:
  /// **'Perubahan berlaku untuk pesanan baru; nota lama menyimpan salinan nama & harga modifier.'**
  String get modifierHint;

  /// No description provided for @modifierGroups.
  ///
  /// In id, this message translates to:
  /// **'Grup modifier'**
  String get modifierGroups;

  /// No description provided for @modifierAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah grup'**
  String get modifierAdd;

  /// No description provided for @modifierEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada grup modifier. Contoh: Ukuran, Level gula, Topping.'**
  String get modifierEmpty;

  /// No description provided for @modifierLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Grup modifier gagal dimuat.'**
  String get modifierLoadFailed;

  /// No description provided for @modifierRuleRequired.
  ///
  /// In id, this message translates to:
  /// **'Wajib · pilih {count}'**
  String modifierRuleRequired(int count);

  /// No description provided for @modifierRuleRequiredRange.
  ///
  /// In id, this message translates to:
  /// **'Wajib · pilih {min}–{max}'**
  String modifierRuleRequiredRange(int min, int max);

  /// No description provided for @modifierRuleOptional.
  ///
  /// In id, this message translates to:
  /// **'Opsional · maks {max}'**
  String modifierRuleOptional(int max);

  /// No description provided for @modifierOptionCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} opsi}}'**
  String modifierOptionCount(int count);

  /// No description provided for @modifierUsedBy.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{belum dipakai menu} other{dipakai {count} menu}}'**
  String modifierUsedBy(int count);

  /// No description provided for @modifierNewGroup.
  ///
  /// In id, this message translates to:
  /// **'Grup modifier baru'**
  String get modifierNewGroup;

  /// No description provided for @modifierEditGroup.
  ///
  /// In id, this message translates to:
  /// **'Ubah grup modifier'**
  String get modifierEditGroup;

  /// No description provided for @modifierName.
  ///
  /// In id, this message translates to:
  /// **'Nama grup'**
  String get modifierName;

  /// No description provided for @modifierRequired.
  ///
  /// In id, this message translates to:
  /// **'Wajib dipilih'**
  String get modifierRequired;

  /// No description provided for @modifierRequiredHint.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan harus memilih sebelum menu masuk bill.'**
  String get modifierRequiredHint;

  /// No description provided for @modifierMin.
  ///
  /// In id, this message translates to:
  /// **'Minimal pilih'**
  String get modifierMin;

  /// No description provided for @modifierMax.
  ///
  /// In id, this message translates to:
  /// **'Maksimal pilih'**
  String get modifierMax;

  /// No description provided for @modifierMaxHint.
  ///
  /// In id, this message translates to:
  /// **'Maksimal 1 tampil sebagai pilihan tunggal.'**
  String get modifierMaxHint;

  /// No description provided for @modifierOptions.
  ///
  /// In id, this message translates to:
  /// **'Opsi'**
  String get modifierOptions;

  /// No description provided for @modifierOptionName.
  ///
  /// In id, this message translates to:
  /// **'Nama opsi'**
  String get modifierOptionName;

  /// No description provided for @modifierOptionPrice.
  ///
  /// In id, this message translates to:
  /// **'Tambahan harga'**
  String get modifierOptionPrice;

  /// No description provided for @modifierOptionPriceHint.
  ///
  /// In id, this message translates to:
  /// **'Minus untuk potongan, mis. -3.000.'**
  String get modifierOptionPriceHint;

  /// No description provided for @modifierOptionDefault.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get modifierOptionDefault;

  /// No description provided for @modifierOptionAvailable.
  ///
  /// In id, this message translates to:
  /// **'Tersedia'**
  String get modifierOptionAvailable;

  /// No description provided for @modifierOptionSoldOut.
  ///
  /// In id, this message translates to:
  /// **'Habis'**
  String get modifierOptionSoldOut;

  /// No description provided for @modifierOptionAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah opsi'**
  String get modifierOptionAdd;

  /// No description provided for @modifierOptionRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus opsi'**
  String get modifierOptionRemove;

  /// No description provided for @modifierErrNameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama grup wajib diisi.'**
  String get modifierErrNameEmpty;

  /// No description provided for @modifierErrNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} karakter.'**
  String modifierErrNameTooLong(int max);

  /// No description provided for @modifierErrNameDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Nama grup sudah dipakai.'**
  String get modifierErrNameDuplicate;

  /// No description provided for @modifierErrSelectRange.
  ///
  /// In id, this message translates to:
  /// **'Minimal harus ≤ maksimal, maksimal 1–{max}.'**
  String modifierErrSelectRange(int max);

  /// No description provided for @modifierErrMinAboveOptions.
  ///
  /// In id, this message translates to:
  /// **'Minimal pilih melebihi jumlah opsi.'**
  String get modifierErrMinAboveOptions;

  /// No description provided for @modifierErrOptionCount.
  ///
  /// In id, this message translates to:
  /// **'Isi 1–{max} opsi.'**
  String modifierErrOptionCount(int max);

  /// No description provided for @modifierErrOptionNameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama opsi wajib diisi.'**
  String get modifierErrOptionNameEmpty;

  /// No description provided for @modifierErrOptionNameDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Nama opsi kembar.'**
  String get modifierErrOptionNameDuplicate;

  /// No description provided for @modifierErrOptionPrice.
  ///
  /// In id, this message translates to:
  /// **'Tambahan harga −Rp 1.000.000 s.d. Rp 1.000.000.'**
  String get modifierErrOptionPrice;

  /// No description provided for @modifierErrDefaultsAboveMax.
  ///
  /// In id, this message translates to:
  /// **'Opsi bawaan lebih banyak dari maksimal pilih.'**
  String get modifierErrDefaultsAboveMax;

  /// No description provided for @modifierErrInUse.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{Grup masih dipasang di {count} menu. Lepas dulu dari form menu.}}'**
  String modifierErrInUse(int count);

  /// No description provided for @modifierErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get modifierErrGeneric;

  /// No description provided for @modifierDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {name}?'**
  String modifierDeleteTitle(String name);

  /// No description provided for @modifierDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Opsi grup ikut terhapus. Nota lama tetap menyimpan salinannya.'**
  String get modifierDeleteBody;

  /// No description provided for @productTabModifiers.
  ///
  /// In id, this message translates to:
  /// **'Modifier'**
  String get productTabModifiers;

  /// No description provided for @productErrorModifierMissing.
  ///
  /// In id, this message translates to:
  /// **'Ada grup modifier yang sudah dihapus. Lepas lalu simpan lagi.'**
  String get productErrorModifierMissing;

  /// No description provided for @productModifiersEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada grup terpasang. Menu langsung masuk bill tanpa pilihan.'**
  String get productModifiersEmpty;

  /// No description provided for @productModifiersHelp.
  ///
  /// In id, this message translates to:
  /// **'Urutan grup di sini = urutan di lembar pilih modifier layar Meja.'**
  String get productModifiersHelp;

  /// No description provided for @productModifiersNoMaster.
  ///
  /// In id, this message translates to:
  /// **'Belum ada grup modifier. Buat dulu di Master data › Grup modifier.'**
  String get productModifiersNoMaster;

  /// No description provided for @productModifierAttach.
  ///
  /// In id, this message translates to:
  /// **'Tambah grup'**
  String get productModifierAttach;

  /// No description provided for @productModifierRemove.
  ///
  /// In id, this message translates to:
  /// **'Lepas'**
  String get productModifierRemove;

  /// No description provided for @modifierSheetAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah ke bill · {total}'**
  String modifierSheetAdd(String total);

  /// No description provided for @modifierSheetQty.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get modifierSheetQty;

  /// No description provided for @modifierSheetLess.
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get modifierSheetLess;

  /// No description provided for @modifierSheetMore.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get modifierSheetMore;

  /// No description provided for @modifierSheetPriceInvalid.
  ///
  /// In id, this message translates to:
  /// **'Potongan modifier melebihi harga menu.'**
  String get modifierSheetPriceInvalid;

  /// No description provided for @modifierSheetNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan untuk dapur (opsional)'**
  String get modifierSheetNote;

  /// No description provided for @diningErrorModifierRequired.
  ///
  /// In id, this message translates to:
  /// **'Pilihan modifier belum lengkap atau tidak sah. Buka lagi menunya.'**
  String get diningErrorModifierRequired;

  /// No description provided for @diningErrorModifierSoldOut.
  ///
  /// In id, this message translates to:
  /// **'Ada opsi modifier yang habis. Pilih opsi lain.'**
  String get diningErrorModifierSoldOut;

  /// No description provided for @diningErrorModifierPrice.
  ///
  /// In id, this message translates to:
  /// **'Potongan modifier melebihi harga menu.'**
  String get diningErrorModifierPrice;

  /// No description provided for @diningSplit.
  ///
  /// In id, this message translates to:
  /// **'Split bill'**
  String get diningSplit;

  /// No description provided for @diningSplitStatus.
  ///
  /// In id, this message translates to:
  /// **'Split · {paid} dari {total} tamu lunas'**
  String diningSplitStatus(int paid, int total);

  /// No description provided for @diningContinueSplit.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan split · {amount}'**
  String diningContinueSplit(String amount);

  /// No description provided for @diningErrorSplitLocked.
  ///
  /// In id, this message translates to:
  /// **'Bill terkunci karena sudah ada pembayaran bagian. Lanjutkan di layar Split bill.'**
  String get diningErrorSplitLocked;

  /// No description provided for @paymentPartSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{bill} · Bagian tamu {label}'**
  String paymentPartSubtitle(String bill, String label);

  /// No description provided for @paymentPartNext.
  ///
  /// In id, this message translates to:
  /// **'{bill} · Tamu berikutnya'**
  String paymentPartNext(String bill);

  /// No description provided for @paymentPartWait.
  ///
  /// In id, this message translates to:
  /// **'Simpan, tunggu konfirmasi'**
  String get paymentPartWait;

  /// No description provided for @paymentPartDue.
  ///
  /// In id, this message translates to:
  /// **'Bagian tamu {label}'**
  String paymentPartDue(String label);

  /// No description provided for @paymentPartBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke split'**
  String get paymentPartBack;

  /// No description provided for @receiptGuestPayment.
  ///
  /// In id, this message translates to:
  /// **'Tamu {label} · {method}'**
  String receiptGuestPayment(String label, String method);

  /// No description provided for @cashSessionErrorOpenSplit.
  ///
  /// In id, this message translates to:
  /// **'Masih ada split bill yang bagiannya dibayar di sesi ini. Lunasi atau batalkan bagian yang menunggu sebelum menutup sesi.'**
  String get cashSessionErrorOpenSplit;

  /// No description provided for @billSplitTitle.
  ///
  /// In id, this message translates to:
  /// **'Split bill · {bill} · {guests} tamu'**
  String billSplitTitle(String bill, int guests);

  /// No description provided for @billSplitRates.
  ///
  /// In id, this message translates to:
  /// **'Service {service} · PB1 {tax}'**
  String billSplitRates(String service, String tax);

  /// No description provided for @billSplitRatesOff.
  ///
  /// In id, this message translates to:
  /// **'Pajak & service: tidak aktif'**
  String get billSplitRatesOff;

  /// No description provided for @billSplitChooseMode.
  ///
  /// In id, this message translates to:
  /// **'Pilih cara membagi tagihan.'**
  String get billSplitChooseMode;

  /// No description provided for @billSplitModeItem.
  ///
  /// In id, this message translates to:
  /// **'Per item'**
  String get billSplitModeItem;

  /// No description provided for @billSplitModeEqual.
  ///
  /// In id, this message translates to:
  /// **'Bagi rata'**
  String get billSplitModeEqual;

  /// No description provided for @billSplitModeAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal bebas'**
  String get billSplitModeAmount;

  /// No description provided for @billSplitGuests.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tamu'**
  String get billSplitGuests;

  /// No description provided for @billSplitGuestLess.
  ///
  /// In id, this message translates to:
  /// **'Kurangi tamu'**
  String get billSplitGuestLess;

  /// No description provided for @billSplitGuestMore.
  ///
  /// In id, this message translates to:
  /// **'Tambah tamu'**
  String get billSplitGuestMore;

  /// No description provided for @billSplitItems.
  ///
  /// In id, this message translates to:
  /// **'Item di bill'**
  String get billSplitItems;

  /// No description provided for @billSplitItemsHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk tamu untuk memberi satu porsi. Item lebih dari 1 dibagi per porsi.'**
  String get billSplitItemsHint;

  /// No description provided for @billSplitPortionPrice.
  ///
  /// In id, this message translates to:
  /// **'{price} / porsi'**
  String billSplitPortionPrice(String price);

  /// No description provided for @billSplitUnassignedCount.
  ///
  /// In id, this message translates to:
  /// **'{count} porsi belum punya tamu.'**
  String billSplitUnassignedCount(int count);

  /// No description provided for @billSplitGuest.
  ///
  /// In id, this message translates to:
  /// **'Tamu {label}'**
  String billSplitGuest(String label);

  /// No description provided for @billSplitGuestEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada porsi.'**
  String get billSplitGuestEmpty;

  /// No description provided for @billSplitStatusUnpaid.
  ///
  /// In id, this message translates to:
  /// **'Belum bayar'**
  String get billSplitStatusUnpaid;

  /// No description provided for @billSplitStatusPaid.
  ///
  /// In id, this message translates to:
  /// **'Lunas · {methods}'**
  String billSplitStatusPaid(String methods);

  /// No description provided for @billSplitStatusPending.
  ///
  /// In id, this message translates to:
  /// **'QRIS statis · menunggu'**
  String get billSplitStatusPending;

  /// No description provided for @billSplitCancelPayment.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get billSplitCancelPayment;

  /// No description provided for @billSplitPay.
  ///
  /// In id, this message translates to:
  /// **'Bayar bagian {label}'**
  String billSplitPay(String label);

  /// No description provided for @billSplitNextGuest.
  ///
  /// In id, this message translates to:
  /// **'Tamu berikutnya ({label})'**
  String billSplitNextGuest(String label);

  /// No description provided for @billSplitAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal'**
  String get billSplitAmount;

  /// No description provided for @billSplitAmountHint.
  ///
  /// In id, this message translates to:
  /// **'Maks {amount}'**
  String billSplitAmountHint(String amount);

  /// No description provided for @billSplitPayAmount.
  ///
  /// In id, this message translates to:
  /// **'Bayar'**
  String get billSplitPayAmount;

  /// No description provided for @billSplitTotal.
  ///
  /// In id, this message translates to:
  /// **'Total bill'**
  String get billSplitTotal;

  /// No description provided for @billSplitPaid.
  ///
  /// In id, this message translates to:
  /// **'Sudah dibayar ({labels})'**
  String billSplitPaid(String labels);

  /// No description provided for @billSplitPending.
  ///
  /// In id, this message translates to:
  /// **'Menunggu konfirmasi ({labels})'**
  String billSplitPending(String labels);

  /// No description provided for @billSplitRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa tagihan'**
  String get billSplitRemaining;

  /// No description provided for @billSplitNote.
  ///
  /// In id, this message translates to:
  /// **'Bill tetap terbuka sampai semua bagian lunas. Tiap bagian dicatat sebagai pembayaran di nota yang sama, jadi laporan & stok tidak terpecah.'**
  String get billSplitNote;

  /// No description provided for @billSplitCancel.
  ///
  /// In id, this message translates to:
  /// **'Batalkan split'**
  String get billSplitCancel;

  /// No description provided for @billSplitLocked.
  ///
  /// In id, this message translates to:
  /// **'Pembagian terkunci karena sudah ada pembayaran bagian. Batalkan bagian QRIS yang menunggu untuk mengubahnya.'**
  String get billSplitLocked;

  /// No description provided for @billSplitDone.
  ///
  /// In id, this message translates to:
  /// **'Bill lunas'**
  String get billSplitDone;

  /// No description provided for @billSplitDoneBody.
  ///
  /// In id, this message translates to:
  /// **'Semua bagian lunas. Nota {number} tersimpan.'**
  String billSplitDoneBody(String number);

  /// No description provided for @billSplitLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Split bill tidak bisa dimuat.'**
  String get billSplitLoadFailed;

  /// No description provided for @billSplitErrorLocked.
  ///
  /// In id, this message translates to:
  /// **'Sudah ada pembayaran bagian; pembagian tidak bisa diubah.'**
  String get billSplitErrorLocked;

  /// No description provided for @billSplitErrorGuests.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tamu 2–8.'**
  String get billSplitErrorGuests;

  /// No description provided for @billSplitErrorUnassigned.
  ///
  /// In id, this message translates to:
  /// **'Bagikan semua porsi ke tamu dulu.'**
  String get billSplitErrorUnassigned;

  /// No description provided for @billSplitErrorPartPaid.
  ///
  /// In id, this message translates to:
  /// **'Tamu ini sudah membayar.'**
  String get billSplitErrorPartPaid;

  /// No description provided for @billSplitErrorAmount.
  ///
  /// In id, this message translates to:
  /// **'Nominal harus lebih dari 0 dan tidak melebihi sisa tagihan.'**
  String get billSplitErrorAmount;

  /// No description provided for @billSplitErrorNothingDue.
  ///
  /// In id, this message translates to:
  /// **'Tamu ini tidak punya tagihan.'**
  String get billSplitErrorNothingDue;

  /// No description provided for @billSplitErrorPending.
  ///
  /// In id, this message translates to:
  /// **'Hanya QRIS yang bisa menunggu konfirmasi.'**
  String get billSplitErrorPending;

  /// No description provided for @billSplitErrorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Split bill gagal. Coba lagi.'**
  String get billSplitErrorGeneric;

  /// No description provided for @diningVoidSplitPaid.
  ///
  /// In id, this message translates to:
  /// **'Bagian yang sudah dibayar ({amount}) dikembalikan ke tamu dan tidak masuk sesi kasir.'**
  String diningVoidSplitPaid(String amount);

  /// No description provided for @floorErrorImageTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Gambar denah lebih dari 5 MB.'**
  String get floorErrorImageTooLarge;

  /// No description provided for @floorErrorImageFormat.
  ///
  /// In id, this message translates to:
  /// **'Format tidak didukung. Pakai PNG, JPG, WebP, atau SVG.'**
  String get floorErrorImageFormat;

  /// No description provided for @floorErrorNameEmpty.
  ///
  /// In id, this message translates to:
  /// **'Nama meja wajib diisi.'**
  String get floorErrorNameEmpty;

  /// No description provided for @floorErrorNameTooLong.
  ///
  /// In id, this message translates to:
  /// **'Nama meja maksimal 20 karakter.'**
  String get floorErrorNameTooLong;

  /// No description provided for @floorErrorNameDuplicate.
  ///
  /// In id, this message translates to:
  /// **'Nama meja sudah dipakai di cabang ini.'**
  String get floorErrorNameDuplicate;

  /// No description provided for @floorErrorSeats.
  ///
  /// In id, this message translates to:
  /// **'Kursi 1 sampai 99.'**
  String get floorErrorSeats;

  /// No description provided for @floorErrorSize.
  ///
  /// In id, this message translates to:
  /// **'Lebar dan tinggi 20 sampai 600.'**
  String get floorErrorSize;

  /// No description provided for @floorErrorPosition.
  ///
  /// In id, this message translates to:
  /// **'Posisi meja di luar denah.'**
  String get floorErrorPosition;

  /// No description provided for @floorErrorInUse.
  ///
  /// In id, this message translates to:
  /// **'Meja yang dihapus masih punya bill terbuka.'**
  String get floorErrorInUse;

  /// No description provided for @floorErrorPermission.
  ///
  /// In id, this message translates to:
  /// **'Butuh izin Kelola pengaturan.'**
  String get floorErrorPermission;

  /// No description provided for @floorErrorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Tata letak gagal disimpan. Coba lagi.'**
  String get floorErrorGeneric;

  /// No description provided for @floorErrorOn.
  ///
  /// In id, this message translates to:
  /// **'{table}: {message}'**
  String floorErrorOn(String table, String message);

  /// No description provided for @floorShapeRound.
  ///
  /// In id, this message translates to:
  /// **'Bulat'**
  String get floorShapeRound;

  /// No description provided for @floorShapeSquare.
  ///
  /// In id, this message translates to:
  /// **'Kotak'**
  String get floorShapeSquare;

  /// No description provided for @floorShapeLong.
  ///
  /// In id, this message translates to:
  /// **'Panjang'**
  String get floorShapeLong;

  /// No description provided for @floorShapeBar.
  ///
  /// In id, this message translates to:
  /// **'Kursi bar'**
  String get floorShapeBar;

  /// No description provided for @floorDiscardTitle.
  ///
  /// In id, this message translates to:
  /// **'Buang perubahan?'**
  String get floorDiscardTitle;

  /// No description provided for @floorDiscardBody.
  ///
  /// In id, this message translates to:
  /// **'Perubahan tata letak yang belum disimpan akan hilang.'**
  String get floorDiscardBody;

  /// No description provided for @floorDiscardKeep.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get floorDiscardKeep;

  /// No description provided for @floorDiscardConfirm.
  ///
  /// In id, this message translates to:
  /// **'Buang'**
  String get floorDiscardConfirm;

  /// No description provided for @floorLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Denah gagal dimuat.'**
  String get floorLoadFailed;

  /// No description provided for @floorBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get floorBack;

  /// No description provided for @floorNoArea.
  ///
  /// In id, this message translates to:
  /// **'Belum ada area. Tambah area dulu, mis. Indoor atau Teras.'**
  String get floorNoArea;

  /// No description provided for @floorTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur denah meja'**
  String get floorTitle;

  /// No description provided for @floorSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan › Meja & area (F&B)'**
  String get floorSubtitle;

  /// No description provided for @floorAddArea.
  ///
  /// In id, this message translates to:
  /// **'+ Area'**
  String get floorAddArea;

  /// No description provided for @floorAddAreaTitle.
  ///
  /// In id, this message translates to:
  /// **'Area baru'**
  String get floorAddAreaTitle;

  /// No description provided for @floorAreaName.
  ///
  /// In id, this message translates to:
  /// **'Nama area'**
  String get floorAreaName;

  /// No description provided for @floorAddAreaSave.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get floorAddAreaSave;

  /// No description provided for @floorGridInfoTitle.
  ///
  /// In id, this message translates to:
  /// **'Mode Grid'**
  String get floorGridInfoTitle;

  /// No description provided for @floorGridInfoBody.
  ///
  /// In id, this message translates to:
  /// **'Meja area {area} tampil sebagai kotak berurutan di layar Meja. Pilih Denah untuk mengunggah gambar denah dan mengatur posisi meja.'**
  String floorGridInfoBody(String area);

  /// No description provided for @floorSeats.
  ///
  /// In id, this message translates to:
  /// **'{count} kursi'**
  String floorSeats(int count);

  /// No description provided for @floorUndo.
  ///
  /// In id, this message translates to:
  /// **'Urungkan'**
  String get floorUndo;

  /// No description provided for @floorRedo.
  ///
  /// In id, this message translates to:
  /// **'Ulangi'**
  String get floorRedo;

  /// No description provided for @floorReplaceImage.
  ///
  /// In id, this message translates to:
  /// **'Ganti gambar denah'**
  String get floorReplaceImage;

  /// No description provided for @floorOpacity.
  ///
  /// In id, this message translates to:
  /// **'Transparansi denah'**
  String get floorOpacity;

  /// No description provided for @floorSnap.
  ///
  /// In id, this message translates to:
  /// **'Snap ke grid {size} px'**
  String floorSnap(int size);

  /// No description provided for @floorZoom.
  ///
  /// In id, this message translates to:
  /// **'Zoom {percent}%'**
  String floorZoom(int percent);

  /// No description provided for @floorZoomIn.
  ///
  /// In id, this message translates to:
  /// **'Perbesar'**
  String get floorZoomIn;

  /// No description provided for @floorZoomOut.
  ///
  /// In id, this message translates to:
  /// **'Perkecil'**
  String get floorZoomOut;

  /// No description provided for @floorZoomFit.
  ///
  /// In id, this message translates to:
  /// **'Pas layar'**
  String get floorZoomFit;

  /// No description provided for @floorUploadTitle.
  ///
  /// In id, this message translates to:
  /// **'Unggah gambar denah area {area}'**
  String floorUploadTitle(String area);

  /// No description provided for @floorUploadBody.
  ///
  /// In id, this message translates to:
  /// **'Foto sketsa tangan, hasil export aplikasi denah, atau gambar dari arsitek. PNG / JPG / WebP / SVG, maks. 5 MB.'**
  String get floorUploadBody;

  /// No description provided for @floorPickFile.
  ///
  /// In id, this message translates to:
  /// **'Pilih file'**
  String get floorPickFile;

  /// No description provided for @floorTakePhoto.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto'**
  String get floorTakePhoto;

  /// No description provided for @floorTipsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tips gambar'**
  String get floorTipsTitle;

  /// No description provided for @floorTipAngle.
  ///
  /// In id, this message translates to:
  /// **'Sudut pandang'**
  String get floorTipAngle;

  /// No description provided for @floorTipAngleValue.
  ///
  /// In id, this message translates to:
  /// **'Dari atas, lurus'**
  String get floorTipAngleValue;

  /// No description provided for @floorTipSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran'**
  String get floorTipSize;

  /// No description provided for @floorTipSizeValue.
  ///
  /// In id, this message translates to:
  /// **'Lebar minimal 1200 px'**
  String get floorTipSizeValue;

  /// No description provided for @floorTipContent.
  ///
  /// In id, this message translates to:
  /// **'Isi'**
  String get floorTipContent;

  /// No description provided for @floorTipContentValue.
  ///
  /// In id, this message translates to:
  /// **'Dinding, pintu, dapur, bar'**
  String get floorTipContentValue;

  /// No description provided for @floorTipStorage.
  ///
  /// In id, this message translates to:
  /// **'Gambar disimpan di perangkat. Saat hosting aktif, ikut diunggah ke Object Storage seperti foto produk.'**
  String get floorTipStorage;

  /// No description provided for @floorTipGrid.
  ///
  /// In id, this message translates to:
  /// **'Tidak punya denah? Pilih mode Grid. Meja tampil seperti biasa dan bisa diganti kapan saja.'**
  String get floorTipGrid;

  /// No description provided for @floorPreset.
  ///
  /// In id, this message translates to:
  /// **'{shape} · {seats} kursi'**
  String floorPreset(String shape, int seats);

  /// No description provided for @floorAddTable.
  ///
  /// In id, this message translates to:
  /// **'Tambah meja'**
  String get floorAddTable;

  /// No description provided for @floorAddTableHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk menaruh meja di tengah tampilan.'**
  String get floorAddTableHint;

  /// No description provided for @floorUnplaced.
  ///
  /// In id, this message translates to:
  /// **'Belum ditempatkan'**
  String get floorUnplaced;

  /// No description provided for @floorUnplacedHint.
  ///
  /// In id, this message translates to:
  /// **'Meja yang sudah ada di mode grid tapi belum punya posisi. Ketuk untuk menaruh.'**
  String get floorUnplacedHint;

  /// No description provided for @floorUnplacedNone.
  ///
  /// In id, this message translates to:
  /// **'Semua meja sudah ditempatkan.'**
  String get floorUnplacedNone;

  /// No description provided for @floorModeTitle.
  ///
  /// In id, this message translates to:
  /// **'Mode tata letak · {area}'**
  String floorModeTitle(String area);

  /// No description provided for @floorModeGrid.
  ///
  /// In id, this message translates to:
  /// **'Grid'**
  String get floorModeGrid;

  /// No description provided for @floorModeGridHint.
  ///
  /// In id, this message translates to:
  /// **'Tanpa denah. Meja tampil sebagai kotak berurutan.'**
  String get floorModeGridHint;

  /// No description provided for @floorModeFloor.
  ///
  /// In id, this message translates to:
  /// **'Denah'**
  String get floorModeFloor;

  /// No description provided for @floorModeFloorHint.
  ///
  /// In id, this message translates to:
  /// **'Unggah gambar denah, lalu atur posisi meja.'**
  String get floorModeFloorHint;

  /// No description provided for @floorSelected.
  ///
  /// In id, this message translates to:
  /// **'Meja {name} dipilih'**
  String floorSelected(String name);

  /// No description provided for @floorSelectHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk meja di denah untuk mengubah nama, kursi, bentuk, dan ukurannya.'**
  String get floorSelectHint;

  /// No description provided for @floorName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get floorName;

  /// No description provided for @floorSeatsLabel.
  ///
  /// In id, this message translates to:
  /// **'Kursi'**
  String get floorSeatsLabel;

  /// No description provided for @floorShape.
  ///
  /// In id, this message translates to:
  /// **'Bentuk'**
  String get floorShape;

  /// No description provided for @floorWidth.
  ///
  /// In id, this message translates to:
  /// **'Lebar'**
  String get floorWidth;

  /// No description provided for @floorHeight.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get floorHeight;

  /// No description provided for @floorOrientation.
  ///
  /// In id, this message translates to:
  /// **'Orientasi'**
  String get floorOrientation;

  /// No description provided for @floorHorizontal.
  ///
  /// In id, this message translates to:
  /// **'Mendatar'**
  String get floorHorizontal;

  /// No description provided for @floorVertical.
  ///
  /// In id, this message translates to:
  /// **'Tegak'**
  String get floorVertical;

  /// No description provided for @floorCanMerge.
  ///
  /// In id, this message translates to:
  /// **'Boleh digabung dengan meja sebelah'**
  String get floorCanMerge;

  /// No description provided for @floorDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus meja'**
  String get floorDelete;

  /// No description provided for @floorUnsaved.
  ///
  /// In id, this message translates to:
  /// **'Ada perubahan yang belum disimpan.'**
  String get floorUnsaved;

  /// No description provided for @floorSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan tata letak'**
  String get floorSave;

  /// No description provided for @floorSaving.
  ///
  /// In id, this message translates to:
  /// **'Menyimpan…'**
  String get floorSaving;

  /// No description provided for @diningLayoutGrid.
  ///
  /// In id, this message translates to:
  /// **'Grid'**
  String get diningLayoutGrid;

  /// No description provided for @diningLayoutFloor.
  ///
  /// In id, this message translates to:
  /// **'Denah'**
  String get diningLayoutFloor;

  /// No description provided for @diningArrange.
  ///
  /// In id, this message translates to:
  /// **'Atur denah'**
  String get diningArrange;

  /// No description provided for @diningFloorLocked.
  ///
  /// In id, this message translates to:
  /// **'Posisi terkunci · geser & zoom saja'**
  String get diningFloorLocked;

  /// No description provided for @diningUnplaced.
  ///
  /// In id, this message translates to:
  /// **'Belum ditempatkan'**
  String get diningUnplaced;

  /// No description provided for @diningNoFloorArea.
  ///
  /// In id, this message translates to:
  /// **'Belum ada area mode denah.'**
  String get diningNoFloorArea;

  /// No description provided for @approvalTitle.
  ///
  /// In id, this message translates to:
  /// **'Persetujuan manajer'**
  String get approvalTitle;

  /// No description provided for @approvalStaff.
  ///
  /// In id, this message translates to:
  /// **'Penyetuju'**
  String get approvalStaff;

  /// No description provided for @approvalPin.
  ///
  /// In id, this message translates to:
  /// **'PIN penyetuju'**
  String get approvalPin;

  /// No description provided for @approvalCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get approvalCancel;

  /// No description provided for @approvalSubmit.
  ///
  /// In id, this message translates to:
  /// **'Setujui'**
  String get approvalSubmit;

  /// No description provided for @approvalNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada staf lain yang berizin dan punya PIN di cabang ini.'**
  String get approvalNone;

  /// No description provided for @approvalNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Staf ini tidak punya izin untuk tindakan ini.'**
  String get approvalNotPermitted;

  /// No description provided for @approvalVoidSale.
  ///
  /// In id, this message translates to:
  /// **'Void transaksi butuh izin sales:void. Minta staf yang berizin memasukkan PIN-nya.'**
  String get approvalVoidSale;

  /// No description provided for @approvalVoidBill.
  ///
  /// In id, this message translates to:
  /// **'Batalkan bill butuh izin sales:void. Minta staf yang berizin memasukkan PIN-nya.'**
  String get approvalVoidBill;

  /// No description provided for @historyTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat transaksi'**
  String get historyTitle;

  /// No description provided for @historyLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Riwayat gagal dimuat.'**
  String get historyLoadFailed;

  /// No description provided for @historySummary.
  ///
  /// In id, this message translates to:
  /// **'{range} · {count} transaksi · {total}'**
  String historySummary(String range, int count, String total);

  /// No description provided for @historyExport.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Excel'**
  String get historyExport;

  /// No description provided for @historyExportSaved.
  ///
  /// In id, this message translates to:
  /// **'Excel disimpan di {path}'**
  String historyExportSaved(String path);

  /// No description provided for @historyExportFailed.
  ///
  /// In id, this message translates to:
  /// **'Ekspor gagal. Coba lagi.'**
  String get historyExportFailed;

  /// No description provided for @historyEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada transaksi untuk filter ini.'**
  String get historyEmpty;

  /// No description provided for @historyPickSale.
  ///
  /// In id, this message translates to:
  /// **'Pilih nota untuk melihat rincian, retur, cetak ulang, atau void.'**
  String get historyPickSale;

  /// No description provided for @historyRangeToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get historyRangeToday;

  /// No description provided for @historyRangeYesterday.
  ///
  /// In id, this message translates to:
  /// **'Kemarin'**
  String get historyRangeYesterday;

  /// No description provided for @historyRangeWeek.
  ///
  /// In id, this message translates to:
  /// **'7 hari'**
  String get historyRangeWeek;

  /// No description provided for @historyFilterStaff.
  ///
  /// In id, this message translates to:
  /// **'Kasir'**
  String get historyFilterStaff;

  /// No description provided for @historyFilterAllStaff.
  ///
  /// In id, this message translates to:
  /// **'Semua kasir'**
  String get historyFilterAllStaff;

  /// No description provided for @historyFilterMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get historyFilterMethod;

  /// No description provided for @historyFilterAllMethods.
  ///
  /// In id, this message translates to:
  /// **'Semua metode'**
  String get historyFilterAllMethods;

  /// No description provided for @historyFilterStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get historyFilterStatus;

  /// No description provided for @historyStatusAll.
  ///
  /// In id, this message translates to:
  /// **'Semua status'**
  String get historyStatusAll;

  /// No description provided for @historyStatusCompleted.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get historyStatusCompleted;

  /// No description provided for @historyStatusPartial.
  ///
  /// In id, this message translates to:
  /// **'Retur sebagian'**
  String get historyStatusPartial;

  /// No description provided for @historyStatusReturned.
  ///
  /// In id, this message translates to:
  /// **'Diretur'**
  String get historyStatusReturned;

  /// No description provided for @historyStatusReturnedAny.
  ///
  /// In id, this message translates to:
  /// **'Retur'**
  String get historyStatusReturnedAny;

  /// No description provided for @historyStatusVoided.
  ///
  /// In id, this message translates to:
  /// **'Void'**
  String get historyStatusVoided;

  /// No description provided for @historyColNumber.
  ///
  /// In id, this message translates to:
  /// **'Nota'**
  String get historyColNumber;

  /// No description provided for @historyColDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get historyColDate;

  /// No description provided for @historyColTime.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get historyColTime;

  /// No description provided for @historyColStaff.
  ///
  /// In id, this message translates to:
  /// **'Kasir'**
  String get historyColStaff;

  /// No description provided for @historyColMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get historyColMethod;

  /// No description provided for @historyColTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get historyColTotal;

  /// No description provided for @historyColReturned.
  ///
  /// In id, this message translates to:
  /// **'Retur'**
  String get historyColReturned;

  /// No description provided for @historyColNet.
  ///
  /// In id, this message translates to:
  /// **'Bersih'**
  String get historyColNet;

  /// No description provided for @historyColStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get historyColStatus;

  /// No description provided for @historyBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get historyBack;

  /// No description provided for @historyTotalOriginal.
  ///
  /// In id, this message translates to:
  /// **'Total awal'**
  String get historyTotalOriginal;

  /// No description provided for @historyReturnedTotal.
  ///
  /// In id, this message translates to:
  /// **'Sudah diretur'**
  String get historyReturnedTotal;

  /// No description provided for @historyNet.
  ///
  /// In id, this message translates to:
  /// **'Nilai bersih'**
  String get historyNet;

  /// No description provided for @historyVoidedBy.
  ///
  /// In id, this message translates to:
  /// **'Di-void oleh {name}: {reason}'**
  String historyVoidedBy(String name, String reason);

  /// No description provided for @historyItems.
  ///
  /// In id, this message translates to:
  /// **'Item'**
  String get historyItems;

  /// No description provided for @historyItemReturned.
  ///
  /// In id, this message translates to:
  /// **'diretur {qty}'**
  String historyItemReturned(String qty);

  /// No description provided for @historyReturnAll.
  ///
  /// In id, this message translates to:
  /// **'Retur semua'**
  String get historyReturnAll;

  /// No description provided for @historyReturnQty.
  ///
  /// In id, this message translates to:
  /// **'Jumlah retur (sisa {left})'**
  String historyReturnQty(String left);

  /// No description provided for @historyReturns.
  ///
  /// In id, this message translates to:
  /// **'Retur'**
  String get historyReturns;

  /// No description provided for @historyReturnTitle.
  ///
  /// In id, this message translates to:
  /// **'Retur barang'**
  String get historyReturnTitle;

  /// No description provided for @historyReturnReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get historyReturnReason;

  /// No description provided for @historyReasonDamaged.
  ///
  /// In id, this message translates to:
  /// **'Barang rusak'**
  String get historyReasonDamaged;

  /// No description provided for @historyReasonWrongItem.
  ///
  /// In id, this message translates to:
  /// **'Salah ambil'**
  String get historyReasonWrongItem;

  /// No description provided for @historyReasonExpired.
  ///
  /// In id, this message translates to:
  /// **'Kedaluwarsa'**
  String get historyReasonExpired;

  /// No description provided for @historyReasonOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get historyReasonOther;

  /// No description provided for @historyReturnNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get historyReturnNote;

  /// No description provided for @historyReturnNoteRequired.
  ///
  /// In id, this message translates to:
  /// **'Catatan (wajib)'**
  String get historyReturnNoteRequired;

  /// No description provided for @historyRefundMethod.
  ///
  /// In id, this message translates to:
  /// **'Uang kembali'**
  String get historyRefundMethod;

  /// No description provided for @historyRefundCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai dari laci'**
  String get historyRefundCash;

  /// No description provided for @historyRefundTransfer.
  ///
  /// In id, this message translates to:
  /// **'Transfer'**
  String get historyRefundTransfer;

  /// No description provided for @historyRefundDebt.
  ///
  /// In id, this message translates to:
  /// **'Potong piutang'**
  String get historyRefundDebt;

  /// No description provided for @historyRefundCashNeedsSession.
  ///
  /// In id, this message translates to:
  /// **'Uang kembali tunai butuh sesi kasir terbuka di perangkat ini.'**
  String get historyRefundCashNeedsSession;

  /// No description provided for @historyRestock.
  ///
  /// In id, this message translates to:
  /// **'Kembalikan barang ke stok'**
  String get historyRestock;

  /// No description provided for @historyReturnSubmit.
  ///
  /// In id, this message translates to:
  /// **'Proses retur · {amount}'**
  String historyReturnSubmit(String amount);

  /// No description provided for @historyReprint.
  ///
  /// In id, this message translates to:
  /// **'Cetak ulang struk'**
  String get historyReprint;

  /// No description provided for @historyClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get historyClose;

  /// No description provided for @historyVoid.
  ///
  /// In id, this message translates to:
  /// **'Void transaksi'**
  String get historyVoid;

  /// No description provided for @historyVoidHint.
  ///
  /// In id, this message translates to:
  /// **'Butuh izin sales:void (PIN manajer). Void membalik stok dan pembayaran lewat entri baru; data lama tidak dihapus.'**
  String get historyVoidHint;

  /// No description provided for @historyVoidTitle.
  ///
  /// In id, this message translates to:
  /// **'Void nota {number}?'**
  String historyVoidTitle(String number);

  /// No description provided for @historyVoidBody.
  ///
  /// In id, this message translates to:
  /// **'Stok dikembalikan dan nota tidak lagi dihitung di rekap sesi.'**
  String get historyVoidBody;

  /// No description provided for @historyVoidReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan void'**
  String get historyVoidReason;

  /// No description provided for @historyVoidKeep.
  ///
  /// In id, this message translates to:
  /// **'Jangan void'**
  String get historyVoidKeep;

  /// No description provided for @historyVoidBlockStatus.
  ///
  /// In id, this message translates to:
  /// **'Nota ini sudah void atau diretur.'**
  String get historyVoidBlockStatus;

  /// No description provided for @historyVoidBlockReturned.
  ///
  /// In id, this message translates to:
  /// **'Nota yang sudah diretur tidak bisa di-void.'**
  String get historyVoidBlockReturned;

  /// No description provided for @historyVoidBlockNotToday.
  ///
  /// In id, this message translates to:
  /// **'Void hanya untuk nota hari ini.'**
  String get historyVoidBlockNotToday;

  /// No description provided for @historyVoidBlockSession.
  ///
  /// In id, this message translates to:
  /// **'Void hanya untuk nota di sesi kasir yang masih buka di perangkat ini, dengan semua pembayaran diterima di sesi itu. Pakai Retur untuk nota lain.'**
  String get historyVoidBlockSession;

  /// No description provided for @historyErrReturnEmpty.
  ///
  /// In id, this message translates to:
  /// **'Isi jumlah retur minimal satu item.'**
  String get historyErrReturnEmpty;

  /// No description provided for @historyErrReturnQuantity.
  ///
  /// In id, this message translates to:
  /// **'Jumlah retur melebihi sisa item.'**
  String get historyErrReturnQuantity;

  /// No description provided for @historyErrReturnNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan wajib untuk alasan Lainnya (maks. 200 karakter).'**
  String get historyErrReturnNote;

  /// No description provided for @historyErrReturnStatus.
  ///
  /// In id, this message translates to:
  /// **'Nota ini tidak bisa diretur lagi.'**
  String get historyErrReturnStatus;

  /// No description provided for @historyErrRefundMethod.
  ///
  /// In id, this message translates to:
  /// **'Cara uang kembali ini belum tersedia.'**
  String get historyErrRefundMethod;

  /// No description provided for @historyErrNoSession.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi kasir dulu untuk uang kembali tunai.'**
  String get historyErrNoSession;

  /// No description provided for @historyErrVoidReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan wajib diisi (maks. 120 karakter).'**
  String get historyErrVoidReason;

  /// No description provided for @historyErrNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin untuk tindakan ini.'**
  String get historyErrNotPermitted;

  /// No description provided for @historyErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Nota tidak ditemukan.'**
  String get historyErrNotFound;

  /// No description provided for @historyErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Coba lagi.'**
  String get historyErrGeneric;

  /// No description provided for @receiptBannerReprint.
  ///
  /// In id, this message translates to:
  /// **'CETAK ULANG'**
  String get receiptBannerReprint;

  /// No description provided for @receiptBannerVoid.
  ///
  /// In id, this message translates to:
  /// **'VOID'**
  String get receiptBannerVoid;

  /// No description provided for @receiptReturned.
  ///
  /// In id, this message translates to:
  /// **'Retur'**
  String get receiptReturned;

  /// No description provided for @receiptNet.
  ///
  /// In id, this message translates to:
  /// **'Bersih'**
  String get receiptNet;

  /// No description provided for @stockNoteVoid.
  ///
  /// In id, this message translates to:
  /// **'Nota di-void'**
  String get stockNoteVoid;

  /// No description provided for @purchasesTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembelian'**
  String get purchasesTitle;

  /// No description provided for @purchasesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Barang masuk dari supplier, termasuk retur pembelian'**
  String get purchasesSubtitle;

  /// No description provided for @purchasesNew.
  ///
  /// In id, this message translates to:
  /// **'Pembelian baru'**
  String get purchasesNew;

  /// No description provided for @purchasesTabPurchases.
  ///
  /// In id, this message translates to:
  /// **'Pembelian'**
  String get purchasesTabPurchases;

  /// No description provided for @purchasesTabReturns.
  ///
  /// In id, this message translates to:
  /// **'Retur pembelian'**
  String get purchasesTabReturns;

  /// No description provided for @purchasesSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari nomor / supplier'**
  String get purchasesSearch;

  /// No description provided for @purchasesColNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor'**
  String get purchasesColNumber;

  /// No description provided for @purchasesColSupplier.
  ///
  /// In id, this message translates to:
  /// **'Supplier'**
  String get purchasesColSupplier;

  /// No description provided for @purchasesColTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get purchasesColTotal;

  /// No description provided for @purchasesColStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get purchasesColStatus;

  /// No description provided for @purchasesColValue.
  ///
  /// In id, this message translates to:
  /// **'Nilai'**
  String get purchasesColValue;

  /// No description provided for @purchasesColSource.
  ///
  /// In id, this message translates to:
  /// **'Pembelian asal'**
  String get purchasesColSource;

  /// No description provided for @purchasesStatusDraft.
  ///
  /// In id, this message translates to:
  /// **'Draf'**
  String get purchasesStatusDraft;

  /// No description provided for @purchasesStatusPaid.
  ///
  /// In id, this message translates to:
  /// **'Lunas'**
  String get purchasesStatusPaid;

  /// No description provided for @purchasesStatusDebt.
  ///
  /// In id, this message translates to:
  /// **'Hutang'**
  String get purchasesStatusDebt;

  /// No description provided for @purchasesDraftTag.
  ///
  /// In id, this message translates to:
  /// **'draf'**
  String get purchasesDraftTag;

  /// No description provided for @purchasesReturnTag.
  ///
  /// In id, this message translates to:
  /// **'retur'**
  String get purchasesReturnTag;

  /// No description provided for @purchasesNoSupplier.
  ///
  /// In id, this message translates to:
  /// **'Tanpa supplier'**
  String get purchasesNoSupplier;

  /// No description provided for @purchasesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pembelian.'**
  String get purchasesEmpty;

  /// No description provided for @purchasesReturnsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada retur pembelian.'**
  String get purchasesReturnsEmpty;

  /// No description provided for @purchasesLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Pembelian gagal dimuat.'**
  String get purchasesLoadFailed;

  /// No description provided for @purchaseFormNew.
  ///
  /// In id, this message translates to:
  /// **'Pembelian baru · {number}'**
  String purchaseFormNew(String number);

  /// No description provided for @purchaseFormDraft.
  ///
  /// In id, this message translates to:
  /// **'Draf · {number}'**
  String purchaseFormDraft(String number);

  /// No description provided for @purchaseSupplier.
  ///
  /// In id, this message translates to:
  /// **'Supplier'**
  String get purchaseSupplier;

  /// No description provided for @purchaseSupplierNew.
  ///
  /// In id, this message translates to:
  /// **'+ Supplier baru'**
  String get purchaseSupplierNew;

  /// No description provided for @purchaseSupplierNewName.
  ///
  /// In id, this message translates to:
  /// **'Nama supplier baru'**
  String get purchaseSupplierNewName;

  /// No description provided for @purchaseSupplierPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari daftar'**
  String get purchaseSupplierPick;

  /// No description provided for @purchaseInvoiceNo.
  ///
  /// In id, this message translates to:
  /// **'No. faktur supplier'**
  String get purchaseInvoiceNo;

  /// No description provided for @purchaseDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get purchaseDate;

  /// No description provided for @purchaseLocation.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke lokasi'**
  String get purchaseLocation;

  /// No description provided for @purchaseColProduct.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get purchaseColProduct;

  /// No description provided for @purchaseColUnit.
  ///
  /// In id, this message translates to:
  /// **'Satuan'**
  String get purchaseColUnit;

  /// No description provided for @purchaseColQty.
  ///
  /// In id, this message translates to:
  /// **'Qty'**
  String get purchaseColQty;

  /// No description provided for @purchaseColPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga beli'**
  String get purchaseColPrice;

  /// No description provided for @purchaseColSubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get purchaseColSubtotal;

  /// No description provided for @purchaseRemoveLine.
  ///
  /// In id, this message translates to:
  /// **'Hapus baris'**
  String get purchaseRemoveLine;

  /// No description provided for @purchaseScan.
  ///
  /// In id, this message translates to:
  /// **'+ Scan / cari produk'**
  String get purchaseScan;

  /// No description provided for @purchaseScanHint.
  ///
  /// In id, this message translates to:
  /// **'Barcode, SKU, atau nama produk'**
  String get purchaseScanHint;

  /// No description provided for @purchaseScanNotFound.
  ///
  /// In id, this message translates to:
  /// **'Produk \"{code}\" tidak ditemukan.'**
  String purchaseScanNotFound(String code);

  /// No description provided for @purchaseNoLines.
  ///
  /// In id, this message translates to:
  /// **'Belum ada produk. Scan barcode atau cari nama produk.'**
  String get purchaseNoLines;

  /// No description provided for @purchasePaidNow.
  ///
  /// In id, this message translates to:
  /// **'Bayar sekarang'**
  String get purchasePaidNow;

  /// No description provided for @purchasePayInFull.
  ///
  /// In id, this message translates to:
  /// **'Bayar lunas'**
  String get purchasePayInFull;

  /// No description provided for @purchaseFundingFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get purchaseFundingFrom;

  /// No description provided for @fundingStoreCash.
  ///
  /// In id, this message translates to:
  /// **'Kas toko'**
  String get fundingStoreCash;

  /// No description provided for @fundingDrawer.
  ///
  /// In id, this message translates to:
  /// **'Kas laci'**
  String get fundingDrawer;

  /// No description provided for @fundingBank.
  ///
  /// In id, this message translates to:
  /// **'Rekening bank'**
  String get fundingBank;

  /// No description provided for @purchaseDueOn.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo sisa'**
  String get purchaseDueOn;

  /// No description provided for @purchaseNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get purchaseNote;

  /// No description provided for @purchaseSubtotal.
  ///
  /// In id, this message translates to:
  /// **'Subtotal'**
  String get purchaseSubtotal;

  /// No description provided for @purchaseDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon faktur'**
  String get purchaseDiscount;

  /// No description provided for @purchaseShipping.
  ///
  /// In id, this message translates to:
  /// **'Ongkos kirim'**
  String get purchaseShipping;

  /// No description provided for @purchaseTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get purchaseTotal;

  /// No description provided for @purchaseDebtLeft.
  ///
  /// In id, this message translates to:
  /// **'Sisa jadi hutang'**
  String get purchaseDebtLeft;

  /// No description provided for @purchaseSaveDraft.
  ///
  /// In id, this message translates to:
  /// **'Simpan draf'**
  String get purchaseSaveDraft;

  /// No description provided for @purchaseReceive.
  ///
  /// In id, this message translates to:
  /// **'Terima barang & simpan'**
  String get purchaseReceive;

  /// No description provided for @purchaseDeleteDraft.
  ///
  /// In id, this message translates to:
  /// **'Hapus draf'**
  String get purchaseDeleteDraft;

  /// No description provided for @purchaseReceiveNote.
  ///
  /// In id, this message translates to:
  /// **'Saat disimpan: stok {location} bertambah (ledger), harga pokok rata-rata diperbarui, hutang supplier tercatat.'**
  String purchaseReceiveNote(String location);

  /// No description provided for @purchaseDraftSaved.
  ///
  /// In id, this message translates to:
  /// **'Draf {number} disimpan.'**
  String purchaseDraftSaved(String number);

  /// No description provided for @purchaseErrLines.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan minimal satu produk.'**
  String get purchaseErrLines;

  /// No description provided for @purchaseErrQty.
  ///
  /// In id, this message translates to:
  /// **'Qty harus lebih dari 0.'**
  String get purchaseErrQty;

  /// No description provided for @purchaseErrPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga beli tidak sah.'**
  String get purchaseErrPrice;

  /// No description provided for @purchaseErrDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon tidak boleh melebihi subtotal.'**
  String get purchaseErrDiscount;

  /// No description provided for @purchaseErrShipping.
  ///
  /// In id, this message translates to:
  /// **'Ongkos kirim tidak sah.'**
  String get purchaseErrShipping;

  /// No description provided for @purchaseErrPaid.
  ///
  /// In id, this message translates to:
  /// **'Bayar tidak boleh melebihi total.'**
  String get purchaseErrPaid;

  /// No description provided for @purchaseErrSupplier.
  ///
  /// In id, this message translates to:
  /// **'Pilih atau ketik supplier untuk pembelian yang berhutang.'**
  String get purchaseErrSupplier;

  /// No description provided for @purchaseErrDueOn.
  ///
  /// In id, this message translates to:
  /// **'Isi jatuh tempo, tidak sebelum tanggal pembelian.'**
  String get purchaseErrDueOn;

  /// No description provided for @purchaseErrInvoiceNo.
  ///
  /// In id, this message translates to:
  /// **'No. faktur maksimal {max} karakter.'**
  String purchaseErrInvoiceNo(int max);

  /// No description provided for @purchaseErrNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan maksimal {max} karakter.'**
  String purchaseErrNote(int max);

  /// No description provided for @purchaseErrDrawer.
  ///
  /// In id, this message translates to:
  /// **'Bayar dari kas laci butuh sesi kasir yang terbuka di perangkat ini.'**
  String get purchaseErrDrawer;

  /// No description provided for @purchaseErrNotEditable.
  ///
  /// In id, this message translates to:
  /// **'Pembelian ini sudah diterima dan tidak bisa diubah.'**
  String get purchaseErrNotEditable;

  /// No description provided for @purchaseErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pembelian tidak ditemukan.'**
  String get purchaseErrNotFound;

  /// No description provided for @purchaseErrNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin mengelola pembelian.'**
  String get purchaseErrNotPermitted;

  /// No description provided for @purchaseErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Pembelian gagal disimpan. Coba lagi.'**
  String get purchaseErrGeneric;

  /// No description provided for @purchaseFrom.
  ///
  /// In id, this message translates to:
  /// **'Pembelian dari {supplier}'**
  String purchaseFrom(String supplier);

  /// No description provided for @purchaseBadgePaid.
  ///
  /// In id, this message translates to:
  /// **'Lunas'**
  String get purchaseBadgePaid;

  /// No description provided for @purchaseBadgeDebt.
  ///
  /// In id, this message translates to:
  /// **'Belum lunas · hutang'**
  String get purchaseBadgeDebt;

  /// No description provided for @purchaseCreatedBy.
  ///
  /// In id, this message translates to:
  /// **'Dibuat oleh'**
  String get purchaseCreatedBy;

  /// No description provided for @purchaseReceivedTitle.
  ///
  /// In id, this message translates to:
  /// **'Barang diterima'**
  String get purchaseReceivedTitle;

  /// No description provided for @purchaseReceivedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Stok {location} bertambah lewat ledger saat pembelian disimpan'**
  String purchaseReceivedSubtitle(String location);

  /// No description provided for @purchaseColAvgCost.
  ///
  /// In id, this message translates to:
  /// **'HPP rata-rata'**
  String get purchaseColAvgCost;

  /// No description provided for @purchaseColSellPrice.
  ///
  /// In id, this message translates to:
  /// **'Harga jual'**
  String get purchaseColSellPrice;

  /// No description provided for @purchaseColSuggested.
  ///
  /// In id, this message translates to:
  /// **'Saran jual'**
  String get purchaseColSuggested;

  /// No description provided for @purchaseColChangePrice.
  ///
  /// In id, this message translates to:
  /// **'Ubah harga'**
  String get purchaseColChangePrice;

  /// No description provided for @purchaseBelowSuggested.
  ///
  /// In id, this message translates to:
  /// **'Di bawah saran'**
  String get purchaseBelowSuggested;

  /// No description provided for @purchaseSafe.
  ///
  /// In id, this message translates to:
  /// **'Aman'**
  String get purchaseSafe;

  /// No description provided for @purchaseApplyPrices.
  ///
  /// In id, this message translates to:
  /// **'Terapkan harga jual ({count} produk)'**
  String purchaseApplyPrices(int count);

  /// No description provided for @purchasePricesApplied.
  ///
  /// In id, this message translates to:
  /// **'Harga jual diperbarui.'**
  String get purchasePricesApplied;

  /// No description provided for @purchaseAvgCostNote.
  ///
  /// In id, this message translates to:
  /// **'HPP memakai rata-rata tertimbang (moving average) dalam satuan dasar. Saran jual menjaga margin harga jual saat barang diterima. Centang \"Ubah harga\" lalu Terapkan harga jual.'**
  String get purchaseAvgCostNote;

  /// No description provided for @purchaseSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get purchaseSummary;

  /// No description provided for @purchasePaidSoFar.
  ///
  /// In id, this message translates to:
  /// **'Sudah dibayar'**
  String get purchasePaidSoFar;

  /// No description provided for @purchaseReturned.
  ///
  /// In id, this message translates to:
  /// **'Diretur'**
  String get purchaseReturned;

  /// No description provided for @purchaseDebt.
  ///
  /// In id, this message translates to:
  /// **'Sisa hutang'**
  String get purchaseDebt;

  /// No description provided for @purchaseDueIn.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo {date} ({days} hari lagi).'**
  String purchaseDueIn(String date, int days);

  /// No description provided for @purchaseDueToday.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo {date} (hari ini).'**
  String purchaseDueToday(String date);

  /// No description provided for @purchaseOverdue.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo {date} (lewat {days} hari).'**
  String purchaseOverdue(String date, int days);

  /// No description provided for @purchasePayments.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran'**
  String get purchasePayments;

  /// No description provided for @purchasePaymentDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get purchasePaymentDate;

  /// No description provided for @purchasePaymentDesc.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get purchasePaymentDesc;

  /// No description provided for @purchasePaymentFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get purchasePaymentFrom;

  /// No description provided for @purchasePaymentAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get purchasePaymentAmount;

  /// No description provided for @purchaseDownPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar di muka'**
  String get purchaseDownPayment;

  /// No description provided for @purchaseReturnReduction.
  ///
  /// In id, this message translates to:
  /// **'Retur {number} (pengurang hutang)'**
  String purchaseReturnReduction(String number);

  /// No description provided for @purchaseReturnRefund.
  ///
  /// In id, this message translates to:
  /// **'Retur {number} (uang kembali)'**
  String purchaseReturnRefund(String number);

  /// No description provided for @purchaseNoPayments.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pembayaran.'**
  String get purchaseNoPayments;

  /// No description provided for @purchasePayDebt.
  ///
  /// In id, this message translates to:
  /// **'Bayar hutang'**
  String get purchasePayDebt;

  /// No description provided for @purchaseActions.
  ///
  /// In id, this message translates to:
  /// **'Tindakan'**
  String get purchaseActions;

  /// No description provided for @purchaseReturnAction.
  ///
  /// In id, this message translates to:
  /// **'Retur pembelian'**
  String get purchaseReturnAction;

  /// No description provided for @purchaseReturnActionNote.
  ///
  /// In id, this message translates to:
  /// **'Membuat dokumen RB-… yang mengurangi stok & hutang. Pembelian yang sudah diterima tidak bisa dihapus, hanya diretur.'**
  String get purchaseReturnActionNote;

  /// No description provided for @purchaseReturnTitle.
  ///
  /// In id, this message translates to:
  /// **'Retur pembelian'**
  String get purchaseReturnTitle;

  /// No description provided for @purchaseReturnRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa {qty}'**
  String purchaseReturnRemaining(String qty);

  /// No description provided for @purchaseReturnQty.
  ///
  /// In id, this message translates to:
  /// **'Qty retur'**
  String get purchaseReturnQty;

  /// No description provided for @purchaseReturnNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan retur'**
  String get purchaseReturnNote;

  /// No description provided for @purchaseRefundTo.
  ///
  /// In id, this message translates to:
  /// **'Uang kembali ke'**
  String get purchaseRefundTo;

  /// No description provided for @purchaseReturnSplit.
  ///
  /// In id, this message translates to:
  /// **'Mengurangi hutang {debt} · uang kembali {refund}'**
  String purchaseReturnSplit(String debt, String refund);

  /// No description provided for @purchaseReturnSubmit.
  ///
  /// In id, this message translates to:
  /// **'Proses retur · {amount}'**
  String purchaseReturnSubmit(String amount);

  /// No description provided for @purchaseReturnCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get purchaseReturnCancel;

  /// No description provided for @purchaseReturnErrEmpty.
  ///
  /// In id, this message translates to:
  /// **'Isi qty retur minimal satu barang.'**
  String get purchaseReturnErrEmpty;

  /// No description provided for @purchaseReturnErrQty.
  ///
  /// In id, this message translates to:
  /// **'Qty retur melebihi sisa.'**
  String get purchaseReturnErrQty;

  /// No description provided for @purchaseReturnErrStock.
  ///
  /// In id, this message translates to:
  /// **'Stok di lokasi pembelian tidak cukup untuk diretur.'**
  String get purchaseReturnErrStock;

  /// No description provided for @purchaseReturnErrRefund.
  ///
  /// In id, this message translates to:
  /// **'Pilih ke mana uang kembali.'**
  String get purchaseReturnErrRefund;

  /// No description provided for @purchaseReturnErrStatus.
  ///
  /// In id, this message translates to:
  /// **'Hanya pembelian yang sudah diterima yang bisa diretur.'**
  String get purchaseReturnErrStatus;

  /// No description provided for @purchaseReturnDone.
  ///
  /// In id, this message translates to:
  /// **'Retur {number} tercatat.'**
  String purchaseReturnDone(String number);

  /// No description provided for @purchaseReturnsMade.
  ///
  /// In id, this message translates to:
  /// **'Retur yang sudah dibuat'**
  String get purchaseReturnsMade;

  /// No description provided for @purchaseDetailLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Detail pembelian gagal dimuat.'**
  String get purchaseDetailLoadFailed;

  /// No description provided for @purchaseErrLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi stok tidak ditemukan. Pilih lokasi lain.'**
  String get purchaseErrLocation;

  /// No description provided for @purchaseRefundToHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih kas atau rekening'**
  String get purchaseRefundToHint;

  /// No description provided for @customersTitle.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan & piutang'**
  String get customersTitle;

  /// No description provided for @customersSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{count} pelanggan · piutang dicatat per nota'**
  String customersSubtitle(int count);

  /// No description provided for @customersImport.
  ///
  /// In id, this message translates to:
  /// **'Import Excel'**
  String get customersImport;

  /// No description provided for @customersNew.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get customersNew;

  /// No description provided for @customersSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari nama atau HP'**
  String get customersSearch;

  /// No description provided for @customersColCustomer.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get customersColCustomer;

  /// No description provided for @customersColGroup.
  ///
  /// In id, this message translates to:
  /// **'Grup'**
  String get customersColGroup;

  /// No description provided for @customersColDebt.
  ///
  /// In id, this message translates to:
  /// **'Piutang'**
  String get customersColDebt;

  /// No description provided for @customersEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pelanggan. Tambah pelanggan atau import dari Excel.'**
  String get customersEmpty;

  /// No description provided for @customersNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pelanggan yang cocok.'**
  String get customersNoMatch;

  /// No description provided for @customersLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data pelanggan gagal dimuat.'**
  String get customersLoadFailed;

  /// No description provided for @customersSelectHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih pelanggan untuk melihat piutang dan menerima pembayaran.'**
  String get customersSelectHint;

  /// No description provided for @customersTotalDebt.
  ///
  /// In id, this message translates to:
  /// **'Total piutang'**
  String get customersTotalDebt;

  /// No description provided for @customersTotalDebtSub.
  ///
  /// In id, this message translates to:
  /// **'{debtors} pelanggan · {overdue} nota lewat jatuh tempo'**
  String customersTotalDebtSub(int debtors, int overdue);

  /// No description provided for @customerOverdueCount.
  ///
  /// In id, this message translates to:
  /// **'{count} nota terlambat'**
  String customerOverdueCount(int count);

  /// No description provided for @customerGroupLabel.
  ///
  /// In id, this message translates to:
  /// **'Grup {group}'**
  String customerGroupLabel(String group);

  /// No description provided for @customerSince.
  ///
  /// In id, this message translates to:
  /// **'pelanggan sejak {date}'**
  String customerSince(String date);

  /// No description provided for @customerEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah data'**
  String get customerEdit;

  /// No description provided for @customerLimit.
  ///
  /// In id, this message translates to:
  /// **'Limit kredit'**
  String get customerLimit;

  /// No description provided for @customerDebt.
  ///
  /// In id, this message translates to:
  /// **'Piutang'**
  String get customerDebt;

  /// No description provided for @customerRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa limit'**
  String get customerRemaining;

  /// No description provided for @customerReceiveTitle.
  ///
  /// In id, this message translates to:
  /// **'Terima pembayaran'**
  String get customerReceiveTitle;

  /// No description provided for @customerAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah diterima'**
  String get customerAmount;

  /// No description provided for @customerPayAll.
  ///
  /// In id, this message translates to:
  /// **'Lunasi semua'**
  String get customerPayAll;

  /// No description provided for @customerMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get customerMethod;

  /// No description provided for @customerPaidOn.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get customerPaidOn;

  /// No description provided for @customerNoteOptional.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get customerNoteOptional;

  /// No description provided for @customerCashDrawerHint.
  ///
  /// In id, this message translates to:
  /// **'Tunai masuk ke laci sesi kasir yang terbuka.'**
  String get customerCashDrawerHint;

  /// No description provided for @customerCashStoreHint.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada sesi kasir terbuka: tunai dicatat sebagai kas toko.'**
  String get customerCashStoreHint;

  /// No description provided for @customerColInvoice.
  ///
  /// In id, this message translates to:
  /// **'Nota'**
  String get customerColInvoice;

  /// No description provided for @customerColDue.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo'**
  String get customerColDue;

  /// No description provided for @customerColTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get customerColTotal;

  /// No description provided for @customerColRest.
  ///
  /// In id, this message translates to:
  /// **'Sisa'**
  String get customerColRest;

  /// No description provided for @customerColAllocation.
  ///
  /// In id, this message translates to:
  /// **'Alokasi'**
  String get customerColAllocation;

  /// No description provided for @customerTotalRow.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get customerTotalRow;

  /// No description provided for @customerDueShort.
  ///
  /// In id, this message translates to:
  /// **'tempo {date}'**
  String customerDueShort(String date);

  /// No description provided for @customerOverdue.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get customerOverdue;

  /// No description provided for @customerAutoHint.
  ///
  /// In id, this message translates to:
  /// **'Alokasi otomatis ke nota paling lama dulu. Setelah disimpan, sisa piutang {name} {amount}.'**
  String customerAutoHint(String name, String amount);

  /// No description provided for @customerManualHint.
  ///
  /// In id, this message translates to:
  /// **'Alokasi manual: isi nominal per nota. Totalnya harus sama dengan jumlah diterima.'**
  String get customerManualHint;

  /// No description provided for @customerManual.
  ///
  /// In id, this message translates to:
  /// **'Atur alokasi manual'**
  String get customerManual;

  /// No description provided for @customerAuto.
  ///
  /// In id, this message translates to:
  /// **'Alokasi otomatis'**
  String get customerAuto;

  /// No description provided for @customerSaveAndPrint.
  ///
  /// In id, this message translates to:
  /// **'Simpan & cetak kuitansi'**
  String get customerSaveAndPrint;

  /// No description provided for @customerNoDebt.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan ini tidak punya piutang.'**
  String get customerNoDebt;

  /// No description provided for @customerPayments.
  ///
  /// In id, this message translates to:
  /// **'Riwayat pembayaran'**
  String get customerPayments;

  /// No description provided for @customerNoPayments.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pembayaran piutang.'**
  String get customerNoPayments;

  /// No description provided for @customerDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus pelanggan'**
  String get customerDelete;

  /// No description provided for @customerDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {name}?'**
  String customerDeleteTitle(String name);

  /// No description provided for @customerDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan hilang dari daftar. Nota dan pembayaran lamanya tetap tersimpan.'**
  String get customerDeleteBody;

  /// No description provided for @customerDeleteAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get customerDeleteAction;

  /// No description provided for @customerCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get customerCancel;

  /// No description provided for @customerSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get customerSave;

  /// No description provided for @customerFormNew.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan baru'**
  String get customerFormNew;

  /// No description provided for @customerFormEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah pelanggan'**
  String get customerFormEdit;

  /// No description provided for @customerFieldName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get customerFieldName;

  /// No description provided for @customerFieldPhone.
  ///
  /// In id, this message translates to:
  /// **'No. HP (opsional)'**
  String get customerFieldPhone;

  /// No description provided for @customerFieldGroup.
  ///
  /// In id, this message translates to:
  /// **'Grup'**
  String get customerFieldGroup;

  /// No description provided for @customerGroupNone.
  ///
  /// In id, this message translates to:
  /// **'Tanpa grup (tempo 14 hari)'**
  String get customerGroupNone;

  /// No description provided for @customerGroupOption.
  ///
  /// In id, this message translates to:
  /// **'{name} · tempo {days} hari'**
  String customerGroupOption(String name, int days);

  /// No description provided for @customerGroupNew.
  ///
  /// In id, this message translates to:
  /// **'+ Grup baru'**
  String get customerGroupNew;

  /// No description provided for @customerFieldNewGroup.
  ///
  /// In id, this message translates to:
  /// **'Nama grup baru'**
  String get customerFieldNewGroup;

  /// No description provided for @customerNewGroupHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Grosir'**
  String get customerNewGroupHint;

  /// No description provided for @customerFieldLimit.
  ///
  /// In id, this message translates to:
  /// **'Limit kredit'**
  String get customerFieldLimit;

  /// No description provided for @customerLimitHint.
  ///
  /// In id, this message translates to:
  /// **'0 = tidak boleh belanja kredit.'**
  String get customerLimitHint;

  /// No description provided for @customerFieldAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat (opsional)'**
  String get customerFieldAddress;

  /// No description provided for @customerFieldNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get customerFieldNote;

  /// No description provided for @customerErrName.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi, maksimal {max} karakter.'**
  String customerErrName(int max);

  /// No description provided for @customerErrPhone.
  ///
  /// In id, this message translates to:
  /// **'Nomor HP harus 8–15 digit.'**
  String get customerErrPhone;

  /// No description provided for @customerErrPhoneTaken.
  ///
  /// In id, this message translates to:
  /// **'Nomor HP sudah dipakai pelanggan lain.'**
  String get customerErrPhoneTaken;

  /// No description provided for @customerErrAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat maksimal {max} karakter.'**
  String customerErrAddress(int max);

  /// No description provided for @customerErrNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan maksimal {max} karakter.'**
  String customerErrNote(int max);

  /// No description provided for @customerErrGroup.
  ///
  /// In id, this message translates to:
  /// **'Nama grup wajib diisi, maksimal {max} karakter.'**
  String customerErrGroup(int max);

  /// No description provided for @customerErrLimit.
  ///
  /// In id, this message translates to:
  /// **'Limit kredit tidak boleh negatif.'**
  String get customerErrLimit;

  /// No description provided for @customerErrHasDebt.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan masih punya piutang; lunasi dulu sebelum dihapus.'**
  String get customerErrHasDebt;

  /// No description provided for @customerErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan tidak ditemukan.'**
  String get customerErrNotFound;

  /// No description provided for @customerErrNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin untuk aksi ini.'**
  String get customerErrNotPermitted;

  /// No description provided for @customerErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get customerErrGeneric;

  /// No description provided for @debtErrAmount.
  ///
  /// In id, this message translates to:
  /// **'Isi jumlah lebih dari 0.'**
  String get debtErrAmount;

  /// No description provided for @debtErrOver.
  ///
  /// In id, this message translates to:
  /// **'Jumlah melebihi total piutang.'**
  String get debtErrOver;

  /// No description provided for @debtErrAllocation.
  ///
  /// In id, this message translates to:
  /// **'Alokasi per nota tidak boleh melebihi sisa nota itu.'**
  String get debtErrAllocation;

  /// No description provided for @debtErrAllocationTotal.
  ///
  /// In id, this message translates to:
  /// **'Total alokasi harus sama dengan jumlah diterima.'**
  String get debtErrAllocationTotal;

  /// No description provided for @debtErrDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal bayar tidak boleh setelah hari ini.'**
  String get debtErrDate;

  /// No description provided for @debtErrMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode ini tidak bisa dipakai untuk pembayaran piutang.'**
  String get debtErrMethod;

  /// No description provided for @debtMethodCashDrawer.
  ///
  /// In id, this message translates to:
  /// **'Tunai · kas laci'**
  String get debtMethodCashDrawer;

  /// No description provided for @debtMethodCashStore.
  ///
  /// In id, this message translates to:
  /// **'Tunai · kas toko'**
  String get debtMethodCashStore;

  /// No description provided for @groupErrName.
  ///
  /// In id, this message translates to:
  /// **'Nama grup wajib diisi, maksimal {max} karakter.'**
  String groupErrName(int max);

  /// No description provided for @groupErrTerm.
  ///
  /// In id, this message translates to:
  /// **'Tempo 0–{max} hari.'**
  String groupErrTerm(int max);

  /// No description provided for @groupErrTaken.
  ///
  /// In id, this message translates to:
  /// **'Nama grup sudah ada.'**
  String get groupErrTaken;

  /// No description provided for @groupErrInUse.
  ///
  /// In id, this message translates to:
  /// **'Grup masih dipakai pelanggan; pindahkan pelanggannya dulu.'**
  String get groupErrInUse;

  /// No description provided for @groupErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Grup tidak ditemukan.'**
  String get groupErrNotFound;

  /// No description provided for @creditNoLimit.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan ini tidak punya limit kredit. Atur limit di menu Pelanggan.'**
  String get creditNoLimit;

  /// No description provided for @creditErrDownPayment.
  ///
  /// In id, this message translates to:
  /// **'DP harus 0 atau lebih dan kurang dari total nota.'**
  String get creditErrDownPayment;

  /// No description provided for @creditErrDueOn.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo tidak boleh sebelum hari ini.'**
  String get creditErrDueOn;

  /// No description provided for @creditErrOverLimit.
  ///
  /// In id, this message translates to:
  /// **'Piutang berjalan + piutang baru melebihi limit kredit.'**
  String get creditErrOverLimit;

  /// No description provided for @importTitle.
  ///
  /// In id, this message translates to:
  /// **'Import pelanggan'**
  String get importTitle;

  /// No description provided for @importIntro.
  ///
  /// In id, this message translates to:
  /// **'Pilih berkas Excel (.xlsx) atau CSV. Kolom: Nama (wajib), HP, Alamat, Grup, Limit, Catatan. Judul kolom boleh Indonesia atau English.'**
  String get importIntro;

  /// No description provided for @importPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih berkas'**
  String get importPick;

  /// No description provided for @importTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Berkas lebih dari 2 MB.'**
  String get importTooLarge;

  /// No description provided for @importUnreadable.
  ///
  /// In id, this message translates to:
  /// **'Berkas tidak bisa dibaca. Simpan sebagai .xlsx atau .csv lalu coba lagi.'**
  String get importUnreadable;

  /// No description provided for @importMissingName.
  ///
  /// In id, this message translates to:
  /// **'Kolom Nama tidak ditemukan di baris judul.'**
  String get importMissingName;

  /// No description provided for @importEmpty.
  ///
  /// In id, this message translates to:
  /// **'Berkas tidak berisi baris pelanggan.'**
  String get importEmpty;

  /// No description provided for @importReady.
  ///
  /// In id, this message translates to:
  /// **'{count} baris siap diimport.'**
  String importReady(int count);

  /// No description provided for @importUpdateNote.
  ///
  /// In id, this message translates to:
  /// **'Nomor HP yang sudah terdaftar memperbarui pelanggan itu; grup baru dibuat otomatis.'**
  String get importUpdateNote;

  /// No description provided for @importRejected.
  ///
  /// In id, this message translates to:
  /// **'{count} baris dilewati:'**
  String importRejected(int count);

  /// No description provided for @importRejectLine.
  ///
  /// In id, this message translates to:
  /// **'Baris {line}: {reason}'**
  String importRejectLine(int line, String reason);

  /// No description provided for @importMoreRejected.
  ///
  /// In id, this message translates to:
  /// **'…dan {count} baris lain.'**
  String importMoreRejected(int count);

  /// No description provided for @importReasonName.
  ///
  /// In id, this message translates to:
  /// **'nama kosong atau terlalu panjang'**
  String get importReasonName;

  /// No description provided for @importReasonPhone.
  ///
  /// In id, this message translates to:
  /// **'nomor HP tidak sah'**
  String get importReasonPhone;

  /// No description provided for @importReasonLimit.
  ///
  /// In id, this message translates to:
  /// **'limit bukan angka'**
  String get importReasonLimit;

  /// No description provided for @importReasonText.
  ///
  /// In id, this message translates to:
  /// **'teks terlalu panjang'**
  String get importReasonText;

  /// No description provided for @importReasonDuplicate.
  ///
  /// In id, this message translates to:
  /// **'nomor HP dobel di berkas'**
  String get importReasonDuplicate;

  /// No description provided for @importRun.
  ///
  /// In id, this message translates to:
  /// **'Import {count} pelanggan'**
  String importRun(int count);

  /// No description provided for @importDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai: {created} pelanggan baru, {updated} diperbarui.'**
  String importDone(int created, int updated);

  /// No description provided for @importClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get importClose;

  /// No description provided for @kuitansiCrumb.
  ///
  /// In id, this message translates to:
  /// **'Kuitansi {number}'**
  String kuitansiCrumb(String number);

  /// No description provided for @kuitansiSavedTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran piutang tersimpan'**
  String get kuitansiSavedTitle;

  /// No description provided for @kuitansiSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{amount} dari {customer} dialokasikan ke {count} nota'**
  String kuitansiSubtitle(String amount, String customer, int count);

  /// No description provided for @kuitansiSaved.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan'**
  String get kuitansiSaved;

  /// No description provided for @kuitansiBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke pelanggan'**
  String get kuitansiBack;

  /// No description provided for @kuitansiPreviewA5.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau A5 / PDF'**
  String get kuitansiPreviewA5;

  /// No description provided for @kuitansiPreviewThermal.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau struk {paper}'**
  String kuitansiPreviewThermal(String paper);

  /// No description provided for @kuitansiPanelTitle.
  ///
  /// In id, this message translates to:
  /// **'Kuitansi'**
  String get kuitansiPanelTitle;

  /// No description provided for @kuitansiPanelSub.
  ///
  /// In id, this message translates to:
  /// **'Dibuat otomatis setelah pembayaran disimpan.'**
  String get kuitansiPanelSub;

  /// No description provided for @kuitansiFormat.
  ///
  /// In id, this message translates to:
  /// **'Format'**
  String get kuitansiFormat;

  /// No description provided for @kuitansiFormatA5.
  ///
  /// In id, this message translates to:
  /// **'A5 / PDF'**
  String get kuitansiFormatA5;

  /// No description provided for @kuitansiFormatA5Hint.
  ///
  /// In id, this message translates to:
  /// **'Untuk arsip & dikirim lewat WhatsApp'**
  String get kuitansiFormatA5Hint;

  /// No description provided for @kuitansiFormatThermal.
  ///
  /// In id, this message translates to:
  /// **'Struk {paper}'**
  String kuitansiFormatThermal(String paper);

  /// No description provided for @kuitansiFormatThermalHint.
  ///
  /// In id, this message translates to:
  /// **'Dicetak di printer kasir'**
  String get kuitansiFormatThermalHint;

  /// No description provided for @kuitansiShowDetails.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan rincian per nota'**
  String get kuitansiShowDetails;

  /// No description provided for @kuitansiShowBalance.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan sisa piutang'**
  String get kuitansiShowBalance;

  /// No description provided for @kuitansiCity.
  ///
  /// In id, this message translates to:
  /// **'Kota pada tanda tangan'**
  String get kuitansiCity;

  /// No description provided for @kuitansiCityHint.
  ///
  /// In id, this message translates to:
  /// **'Dari alamat cabang'**
  String get kuitansiCityHint;

  /// No description provided for @kuitansiPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak'**
  String get kuitansiPrint;

  /// No description provided for @kuitansiShare.
  ///
  /// In id, this message translates to:
  /// **'Bagikan PDF'**
  String get kuitansiShare;

  /// No description provided for @kuitansiPrinted.
  ///
  /// In id, this message translates to:
  /// **'Kuitansi terkirim ke printer.'**
  String get kuitansiPrinted;

  /// No description provided for @kuitansiSavedPdf.
  ///
  /// In id, this message translates to:
  /// **'PDF disimpan di {path}'**
  String kuitansiSavedPdf(String path);

  /// No description provided for @kuitansiReprintNote.
  ///
  /// In id, this message translates to:
  /// **'Kuitansi bisa dicetak ulang dari Pelanggan › riwayat pembayaran. Cetak ulang diberi tanda \"SALINAN\".'**
  String get kuitansiReprintNote;

  /// No description provided for @kuitansiErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran tidak ditemukan.'**
  String get kuitansiErrNotFound;

  /// No description provided for @kuitansiDocTitle.
  ///
  /// In id, this message translates to:
  /// **'KUITANSI'**
  String get kuitansiDocTitle;

  /// No description provided for @kuitansiCopy.
  ///
  /// In id, this message translates to:
  /// **'SALINAN'**
  String get kuitansiCopy;

  /// No description provided for @kuitansiReceivedFrom.
  ///
  /// In id, this message translates to:
  /// **'Telah terima dari'**
  String get kuitansiReceivedFrom;

  /// No description provided for @kuitansiAmountWords.
  ///
  /// In id, this message translates to:
  /// **'Uang sejumlah'**
  String get kuitansiAmountWords;

  /// No description provided for @kuitansiFor.
  ///
  /// In id, this message translates to:
  /// **'Untuk pembayaran'**
  String get kuitansiFor;

  /// No description provided for @kuitansiForDetails.
  ///
  /// In id, this message translates to:
  /// **'Piutang {count} nota (lihat rincian)'**
  String kuitansiForDetails(int count);

  /// No description provided for @kuitansiForShort.
  ///
  /// In id, this message translates to:
  /// **'Piutang {count} nota'**
  String kuitansiForShort(int count);

  /// No description provided for @kuitansiMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode'**
  String get kuitansiMethod;

  /// No description provided for @kuitansiNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get kuitansiNote;

  /// No description provided for @kuitansiColInvoice.
  ///
  /// In id, this message translates to:
  /// **'Nota'**
  String get kuitansiColInvoice;

  /// No description provided for @kuitansiColBefore.
  ///
  /// In id, this message translates to:
  /// **'Sisa sebelum'**
  String get kuitansiColBefore;

  /// No description provided for @kuitansiColPaid.
  ///
  /// In id, this message translates to:
  /// **'Dibayar'**
  String get kuitansiColPaid;

  /// No description provided for @kuitansiCashier.
  ///
  /// In id, this message translates to:
  /// **'Kasir'**
  String get kuitansiCashier;

  /// No description provided for @kuitansiFootnote.
  ///
  /// In id, this message translates to:
  /// **'Sisa piutang {customer} setelah pembayaran ini: {amount}.'**
  String kuitansiFootnote(String customer, String amount);

  /// No description provided for @kuitansiThermalBanner.
  ///
  /// In id, this message translates to:
  /// **'KUITANSI PIUTANG'**
  String get kuitansiThermalBanner;

  /// No description provided for @kuitansiFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get kuitansiFrom;

  /// No description provided for @kuitansiPaid.
  ///
  /// In id, this message translates to:
  /// **'DIBAYAR'**
  String get kuitansiPaid;

  /// No description provided for @kuitansiBalance.
  ///
  /// In id, this message translates to:
  /// **'Sisa piutang'**
  String get kuitansiBalance;

  /// No description provided for @historyStatusUnpaid.
  ///
  /// In id, this message translates to:
  /// **'Belum lunas'**
  String get historyStatusUnpaid;

  /// No description provided for @historyCustomer.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get historyCustomer;

  /// No description provided for @historyDueOn.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo'**
  String get historyDueOn;

  /// No description provided for @historyCredit.
  ///
  /// In id, this message translates to:
  /// **'Jadi piutang'**
  String get historyCredit;

  /// No description provided for @historyOutstanding.
  ///
  /// In id, this message translates to:
  /// **'Sisa piutang'**
  String get historyOutstanding;

  /// No description provided for @historyReturnDebtOnly.
  ///
  /// In id, this message translates to:
  /// **'Retur ini memotong piutang {amount}; tidak ada uang kembali.'**
  String historyReturnDebtOnly(String amount);

  /// No description provided for @historyReturnDebtSplit.
  ///
  /// In id, this message translates to:
  /// **'Memotong piutang {debt}, uang kembali {refund}.'**
  String historyReturnDebtSplit(String debt, String refund);

  /// No description provided for @historyVoidBlockDebtPaid.
  ///
  /// In id, this message translates to:
  /// **'Nota kredit ini sudah menerima pembayaran piutang, jadi tidak bisa di-void. Pakai retur.'**
  String get historyVoidBlockDebtPaid;

  /// No description provided for @receiptCustomer.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get receiptCustomer;

  /// No description provided for @receiptDebt.
  ///
  /// In id, this message translates to:
  /// **'Piutang'**
  String get receiptDebt;

  /// No description provided for @receiptDueOn.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo'**
  String get receiptDueOn;

  /// No description provided for @cashRecapCredit.
  ///
  /// In id, this message translates to:
  /// **'Penjualan kredit (piutang)'**
  String get cashRecapCredit;

  /// No description provided for @paymentCredit.
  ///
  /// In id, this message translates to:
  /// **'Kredit / piutang'**
  String get paymentCredit;

  /// No description provided for @paymentCreditHint.
  ///
  /// In id, this message translates to:
  /// **'Sisa jadi piutang pelanggan'**
  String get paymentCreditHint;

  /// No description provided for @creditTitle.
  ///
  /// In id, this message translates to:
  /// **'Kredit / piutang'**
  String get creditTitle;

  /// No description provided for @creditSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Nota disimpan dengan sisa sebagai piutang pelanggan.'**
  String get creditSubtitle;

  /// No description provided for @creditPickCustomer.
  ///
  /// In id, this message translates to:
  /// **'Pilih pelanggan'**
  String get creditPickCustomer;

  /// No description provided for @creditNoCustomers.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pelanggan. Tambah pelanggan dan limit kreditnya di menu Pelanggan.'**
  String get creditNoCustomers;

  /// No description provided for @creditLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Daftar pelanggan gagal dimuat.'**
  String get creditLoadFailed;

  /// No description provided for @creditTerm.
  ///
  /// In id, this message translates to:
  /// **'tempo standar {days} hari'**
  String creditTerm(int days);

  /// No description provided for @creditChange.
  ///
  /// In id, this message translates to:
  /// **'Ganti'**
  String get creditChange;

  /// No description provided for @creditRunning.
  ///
  /// In id, this message translates to:
  /// **'Piutang berjalan'**
  String get creditRunning;

  /// No description provided for @creditDownPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar sekarang (DP)'**
  String get creditDownPayment;

  /// No description provided for @creditDownPaymentHint.
  ///
  /// In id, this message translates to:
  /// **'Boleh 0. Dibayar tunai lewat laci sesi aktif.'**
  String get creditDownPaymentHint;

  /// No description provided for @creditDueOn.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo'**
  String get creditDueOn;

  /// No description provided for @creditDueOnHint.
  ///
  /// In id, this message translates to:
  /// **'Hari ini + tempo standar pelanggan'**
  String get creditDueOnHint;

  /// No description provided for @creditInvoiceTotal.
  ///
  /// In id, this message translates to:
  /// **'Total nota'**
  String get creditInvoiceTotal;

  /// No description provided for @creditPaidNow.
  ///
  /// In id, this message translates to:
  /// **'Dibayar sekarang'**
  String get creditPaidNow;

  /// No description provided for @creditBecomesDebt.
  ///
  /// In id, this message translates to:
  /// **'Jadi piutang'**
  String get creditBecomesDebt;

  /// No description provided for @creditRemainingAfter.
  ///
  /// In id, this message translates to:
  /// **'Sisa limit setelah ini'**
  String get creditRemainingAfter;

  /// No description provided for @creditOverLimitTitle.
  ///
  /// In id, this message translates to:
  /// **'Melebihi limit'**
  String get creditOverLimitTitle;

  /// No description provided for @creditOverLimit.
  ///
  /// In id, this message translates to:
  /// **'Piutang berjalan + piutang baru melebihi limit {limit}. Kurangi nominal atau naikkan DP.'**
  String creditOverLimit(String limit);

  /// No description provided for @creditFootnote.
  ///
  /// In id, this message translates to:
  /// **'Nota tercatat Belum lunas di Riwayat dan masuk daftar piutang pelanggan. Pelanggan wajib dipilih.'**
  String get creditFootnote;

  /// No description provided for @creditSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan sebagai piutang'**
  String get creditSave;

  /// No description provided for @successCredit.
  ///
  /// In id, this message translates to:
  /// **'Piutang {name}'**
  String successCredit(String name);

  /// No description provided for @masterTabCustomerGroups.
  ///
  /// In id, this message translates to:
  /// **'Grup pelanggan'**
  String get masterTabCustomerGroups;

  /// No description provided for @customerGroupsHint.
  ///
  /// In id, this message translates to:
  /// **'Tempo standar grup mengisi jatuh tempo otomatis saat jual kredit. Pelanggan tanpa grup memakai 14 hari.'**
  String get customerGroupsHint;

  /// No description provided for @customerGroupsNew.
  ///
  /// In id, this message translates to:
  /// **'Grup'**
  String get customerGroupsNew;

  /// No description provided for @customerGroupsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada grup pelanggan.'**
  String get customerGroupsEmpty;

  /// No description provided for @customerGroupsRowSub.
  ///
  /// In id, this message translates to:
  /// **'Tempo {days} hari · {count} pelanggan'**
  String customerGroupsRowSub(int days, int count);

  /// No description provided for @customerGroupsNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Grup pelanggan baru'**
  String get customerGroupsNewTitle;

  /// No description provided for @customerGroupsEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah grup pelanggan'**
  String get customerGroupsEditTitle;

  /// No description provided for @customerGroupsName.
  ///
  /// In id, this message translates to:
  /// **'Nama grup'**
  String get customerGroupsName;

  /// No description provided for @customerGroupsTerm.
  ///
  /// In id, this message translates to:
  /// **'Tempo standar (hari)'**
  String get customerGroupsTerm;

  /// No description provided for @customerGroupsTermHint.
  ///
  /// In id, this message translates to:
  /// **'0–365 hari. 0 = jatuh tempo hari itu juga.'**
  String get customerGroupsTermHint;

  /// No description provided for @cashSourcePurchase.
  ///
  /// In id, this message translates to:
  /// **'Pembelian'**
  String get cashSourcePurchase;

  /// No description provided for @cashSourceDebtPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar piutang'**
  String get cashSourceDebtPayment;

  /// No description provided for @historyMethodCredit.
  ///
  /// In id, this message translates to:
  /// **'Kredit'**
  String get historyMethodCredit;

  /// No description provided for @suppliersTitle.
  ///
  /// In id, this message translates to:
  /// **'Supplier & hutang'**
  String get suppliersTitle;

  /// No description provided for @suppliersSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{count} supplier · hutang dicatat per pembelian'**
  String suppliersSubtitle(int count);

  /// No description provided for @suppliersNew.
  ///
  /// In id, this message translates to:
  /// **'Supplier'**
  String get suppliersNew;

  /// No description provided for @suppliersSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari nama, kategori, atau telepon'**
  String get suppliersSearch;

  /// No description provided for @suppliersColSupplier.
  ///
  /// In id, this message translates to:
  /// **'Supplier'**
  String get suppliersColSupplier;

  /// No description provided for @suppliersColDebt.
  ///
  /// In id, this message translates to:
  /// **'Hutang'**
  String get suppliersColDebt;

  /// No description provided for @suppliersEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada supplier. Tambahkan supplier atau catat pembelian pertama.'**
  String get suppliersEmpty;

  /// No description provided for @suppliersNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada supplier yang cocok.'**
  String get suppliersNoMatch;

  /// No description provided for @suppliersSelectHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih supplier untuk melihat hutang dan membayarnya.'**
  String get suppliersSelectHint;

  /// No description provided for @suppliersLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Data supplier gagal dimuat.'**
  String get suppliersLoadFailed;

  /// No description provided for @suppliersTotalDebt.
  ///
  /// In id, this message translates to:
  /// **'Total hutang'**
  String get suppliersTotalDebt;

  /// No description provided for @suppliersNearestDue.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo terdekat: {date}'**
  String suppliersNearestDue(String date);

  /// No description provided for @suppliersNoDue.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hutang jatuh tempo'**
  String get suppliersNoDue;

  /// No description provided for @suppliersOverdueCount.
  ///
  /// In id, this message translates to:
  /// **'{count} pembelian terlambat'**
  String suppliersOverdueCount(int count);

  /// No description provided for @supplierPayTitle.
  ///
  /// In id, this message translates to:
  /// **'{name} · bayar hutang'**
  String supplierPayTitle(String name);

  /// No description provided for @supplierContact.
  ///
  /// In id, this message translates to:
  /// **'Kontak: {name}'**
  String supplierContact(String name);

  /// No description provided for @supplierTerm.
  ///
  /// In id, this message translates to:
  /// **'tempo standar {days} hari'**
  String supplierTerm(int days);

  /// No description provided for @supplierHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat pembelian'**
  String get supplierHistory;

  /// No description provided for @supplierEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah data'**
  String get supplierEdit;

  /// No description provided for @supplierNoDebt.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hutang ke supplier ini.'**
  String get supplierNoDebt;

  /// No description provided for @supplierAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah dibayar'**
  String get supplierAmount;

  /// No description provided for @supplierPayAll.
  ///
  /// In id, this message translates to:
  /// **'Lunasi semua'**
  String get supplierPayAll;

  /// No description provided for @supplierFunding.
  ///
  /// In id, this message translates to:
  /// **'Sumber dana'**
  String get supplierFunding;

  /// No description provided for @supplierReference.
  ///
  /// In id, this message translates to:
  /// **'No. bukti transfer'**
  String get supplierReference;

  /// No description provided for @supplierReferenceHint.
  ///
  /// In id, this message translates to:
  /// **'Opsional'**
  String get supplierReferenceHint;

  /// No description provided for @supplierPaidOn.
  ///
  /// In id, this message translates to:
  /// **'Tanggal bayar'**
  String get supplierPaidOn;

  /// No description provided for @supplierNoteOptional.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get supplierNoteOptional;

  /// No description provided for @supplierColPurchase.
  ///
  /// In id, this message translates to:
  /// **'Pembelian'**
  String get supplierColPurchase;

  /// No description provided for @supplierColDue.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo'**
  String get supplierColDue;

  /// No description provided for @supplierColTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get supplierColTotal;

  /// No description provided for @supplierColRest.
  ///
  /// In id, this message translates to:
  /// **'Sisa'**
  String get supplierColRest;

  /// No description provided for @supplierColPay.
  ///
  /// In id, this message translates to:
  /// **'Bayar'**
  String get supplierColPay;

  /// No description provided for @supplierTotalRow.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get supplierTotalRow;

  /// No description provided for @supplierOverdue.
  ///
  /// In id, this message translates to:
  /// **'Terlambat'**
  String get supplierOverdue;

  /// No description provided for @supplierDueShort.
  ///
  /// In id, this message translates to:
  /// **'tempo {date}'**
  String supplierDueShort(String date);

  /// No description provided for @supplierAutoHint.
  ///
  /// In id, this message translates to:
  /// **'Alokasi otomatis ke jatuh tempo terdekat dulu. Setelah disimpan, sisa hutang ke {name} {amount}.'**
  String supplierAutoHint(String name, String amount);

  /// No description provided for @supplierAutoHintDue.
  ///
  /// In id, this message translates to:
  /// **'Alokasi otomatis ke jatuh tempo terdekat dulu. Setelah disimpan, sisa hutang ke {name} {amount} (jatuh tempo {date}).'**
  String supplierAutoHintDue(String name, String amount, String date);

  /// No description provided for @supplierManualHint.
  ///
  /// In id, this message translates to:
  /// **'Isi kolom Bayar per pembelian; jumlahnya harus sama dengan jumlah dibayar.'**
  String get supplierManualHint;

  /// No description provided for @supplierDrawerHint.
  ///
  /// In id, this message translates to:
  /// **'Bayar dari kas laci akan tercatat sebagai uang keluar di sesi kasir yang sedang buka.'**
  String get supplierDrawerHint;

  /// No description provided for @supplierDrawerNoSession.
  ///
  /// In id, this message translates to:
  /// **'Kas laci butuh sesi kasir terbuka di perangkat ini.'**
  String get supplierDrawerNoSession;

  /// No description provided for @supplierDrawerNotToday.
  ///
  /// In id, this message translates to:
  /// **'Kas laci hanya untuk pembayaran hari ini. Pilih kas toko atau rekening bank untuk tanggal lain.'**
  String get supplierDrawerNotToday;

  /// No description provided for @supplierDrawerNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin memakai kas laci.'**
  String get supplierDrawerNotPermitted;

  /// No description provided for @supplierManual.
  ///
  /// In id, this message translates to:
  /// **'Atur alokasi manual'**
  String get supplierManual;

  /// No description provided for @supplierAuto.
  ///
  /// In id, this message translates to:
  /// **'Alokasi otomatis'**
  String get supplierAuto;

  /// No description provided for @supplierAttachProof.
  ///
  /// In id, this message translates to:
  /// **'Lampirkan foto bukti'**
  String get supplierAttachProof;

  /// No description provided for @supplierTakePhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto bukti'**
  String get supplierTakePhoto;

  /// No description provided for @supplierRemoveProof.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get supplierRemoveProof;

  /// No description provided for @supplierProofTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Foto bukti maksimal 20 MB.'**
  String get supplierProofTooLarge;

  /// No description provided for @supplierProofInvalid.
  ///
  /// In id, this message translates to:
  /// **'Pilih gambar PNG, JPG, atau WebP.'**
  String get supplierProofInvalid;

  /// No description provided for @supplierSavePayment.
  ///
  /// In id, this message translates to:
  /// **'Simpan pembayaran'**
  String get supplierSavePayment;

  /// No description provided for @supplierPaid.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran {number} tersimpan.'**
  String supplierPaid(String number);

  /// No description provided for @supplierPayments.
  ///
  /// In id, this message translates to:
  /// **'Riwayat pembayaran'**
  String get supplierPayments;

  /// No description provided for @supplierNoPayments.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pembayaran hutang.'**
  String get supplierNoPayments;

  /// No description provided for @supplierProofTitle.
  ///
  /// In id, this message translates to:
  /// **'Bukti {number}'**
  String supplierProofTitle(String number);

  /// No description provided for @supplierProofMissing.
  ///
  /// In id, this message translates to:
  /// **'Foto bukti belum ada di perangkat ini.'**
  String get supplierProofMissing;

  /// No description provided for @supplierDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus supplier'**
  String get supplierDelete;

  /// No description provided for @supplierDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus {name}?'**
  String supplierDeleteTitle(String name);

  /// No description provided for @supplierDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Pembelian lama tetap menyimpan nama supplier ini.'**
  String get supplierDeleteBody;

  /// No description provided for @supplierDeleteAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get supplierDeleteAction;

  /// No description provided for @supplierCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get supplierCancel;

  /// No description provided for @supplierClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get supplierClose;

  /// No description provided for @supplierFormNew.
  ///
  /// In id, this message translates to:
  /// **'Supplier baru'**
  String get supplierFormNew;

  /// No description provided for @supplierFormEdit.
  ///
  /// In id, this message translates to:
  /// **'Ubah supplier'**
  String get supplierFormEdit;

  /// No description provided for @supplierFieldName.
  ///
  /// In id, this message translates to:
  /// **'Nama supplier'**
  String get supplierFieldName;

  /// No description provided for @supplierFieldContact.
  ///
  /// In id, this message translates to:
  /// **'Kontak (nama orang)'**
  String get supplierFieldContact;

  /// No description provided for @supplierFieldPhone.
  ///
  /// In id, this message translates to:
  /// **'No. telepon'**
  String get supplierFieldPhone;

  /// No description provided for @supplierFieldCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori barang'**
  String get supplierFieldCategory;

  /// No description provided for @supplierCategoryHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Sembako, Minuman'**
  String get supplierCategoryHint;

  /// No description provided for @supplierFieldTerm.
  ///
  /// In id, this message translates to:
  /// **'Tempo standar (hari)'**
  String get supplierFieldTerm;

  /// No description provided for @supplierTermHint.
  ///
  /// In id, this message translates to:
  /// **'Mengisi jatuh tempo bawaan di Pembelian.'**
  String get supplierTermHint;

  /// No description provided for @supplierFieldAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get supplierFieldAddress;

  /// No description provided for @supplierFieldNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get supplierFieldNote;

  /// No description provided for @supplierSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get supplierSave;

  /// No description provided for @supplierErrName.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi, maksimal {max} karakter.'**
  String supplierErrName(int max);

  /// No description provided for @supplierErrPhone.
  ///
  /// In id, this message translates to:
  /// **'Nomor telepon 8–15 digit.'**
  String get supplierErrPhone;

  /// No description provided for @supplierErrContact.
  ///
  /// In id, this message translates to:
  /// **'Kontak maksimal {max} karakter.'**
  String supplierErrContact(int max);

  /// No description provided for @supplierErrCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori maksimal {max} karakter.'**
  String supplierErrCategory(int max);

  /// No description provided for @supplierErrAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat maksimal {max} karakter.'**
  String supplierErrAddress(int max);

  /// No description provided for @supplierErrNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan maksimal {max} karakter.'**
  String supplierErrNote(int max);

  /// No description provided for @supplierErrTerm.
  ///
  /// In id, this message translates to:
  /// **'Tempo 0–{max} hari.'**
  String supplierErrTerm(int max);

  /// No description provided for @supplierErrNameTaken.
  ///
  /// In id, this message translates to:
  /// **'Nama supplier sudah dipakai.'**
  String get supplierErrNameTaken;

  /// No description provided for @supplierErrHasDebt.
  ///
  /// In id, this message translates to:
  /// **'Supplier masih punya hutang. Lunasi dulu sebelum dihapus.'**
  String get supplierErrHasDebt;

  /// No description provided for @supplierErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Supplier tidak ditemukan.'**
  String get supplierErrNotFound;

  /// No description provided for @supplierErrAmount.
  ///
  /// In id, this message translates to:
  /// **'Isi jumlah dibayar.'**
  String get supplierErrAmount;

  /// No description provided for @supplierErrOver.
  ///
  /// In id, this message translates to:
  /// **'Jumlah melebihi total hutang.'**
  String get supplierErrOver;

  /// No description provided for @supplierErrAllocation.
  ///
  /// In id, this message translates to:
  /// **'Bayar per pembelian tidak boleh melebihi sisanya.'**
  String get supplierErrAllocation;

  /// No description provided for @supplierErrAllocationTotal.
  ///
  /// In id, this message translates to:
  /// **'Jumlah kolom Bayar harus sama dengan jumlah dibayar.'**
  String get supplierErrAllocationTotal;

  /// No description provided for @supplierErrDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal bayar tidak boleh di masa depan.'**
  String get supplierErrDate;

  /// No description provided for @supplierErrNoSession.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi kasir dulu untuk bayar dari kas laci.'**
  String get supplierErrNoSession;

  /// No description provided for @supplierErrText.
  ///
  /// In id, this message translates to:
  /// **'Catatan atau no. bukti terlalu panjang.'**
  String get supplierErrText;

  /// No description provided for @supplierErrNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin untuk tindakan ini.'**
  String get supplierErrNotPermitted;

  /// No description provided for @supplierErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get supplierErrGeneric;

  /// No description provided for @supplierHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat pembelian {name}'**
  String supplierHistoryTitle(String name);

  /// No description provided for @supplierHistoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pembelian dari supplier ini.'**
  String get supplierHistoryEmpty;

  /// No description provided for @supplierHistoryPaid.
  ///
  /// In id, this message translates to:
  /// **'Lunas'**
  String get supplierHistoryPaid;

  /// No description provided for @cashSourceSupplierPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar hutang supplier'**
  String get cashSourceSupplierPayment;

  /// No description provided for @purchaseDebtPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar hutang {number}'**
  String purchaseDebtPayment(String number);

  /// No description provided for @expensesTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get expensesTitle;

  /// No description provided for @expensesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Biaya operasional di luar pembelian barang dagang'**
  String get expensesSubtitle;

  /// No description provided for @expensesExport.
  ///
  /// In id, this message translates to:
  /// **'Ekspor Excel'**
  String get expensesExport;

  /// No description provided for @expensesNew.
  ///
  /// In id, this message translates to:
  /// **'Catat pengeluaran'**
  String get expensesNew;

  /// No description provided for @expensesSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari pengeluaran'**
  String get expensesSearch;

  /// No description provided for @expensesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran di periode ini.'**
  String get expensesEmpty;

  /// No description provided for @expensesNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pengeluaran yang cocok.'**
  String get expensesNoMatch;

  /// No description provided for @expensesByCategory.
  ///
  /// In id, this message translates to:
  /// **'Per jenis · {period}'**
  String expensesByCategory(String period);

  /// No description provided for @expensesTotal.
  ///
  /// In id, this message translates to:
  /// **'Total {amount}'**
  String expensesTotal(String amount);

  /// No description provided for @expensesByCategoryEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran yang dihitung.'**
  String get expensesByCategoryEmpty;

  /// No description provided for @expensePeriod30Days.
  ///
  /// In id, this message translates to:
  /// **'30 hari terakhir'**
  String get expensePeriod30Days;

  /// No description provided for @expensePeriodThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan ini'**
  String get expensePeriodThisMonth;

  /// No description provided for @expensePeriodLastMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan lalu'**
  String get expensePeriodLastMonth;

  /// No description provided for @expenseColDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get expenseColDate;

  /// No description provided for @expenseColNumber.
  ///
  /// In id, this message translates to:
  /// **'Nomor'**
  String get expenseColNumber;

  /// No description provided for @expenseColDescription.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get expenseColDescription;

  /// No description provided for @expenseColCategory.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get expenseColCategory;

  /// No description provided for @expenseColFunding.
  ///
  /// In id, this message translates to:
  /// **'Sumber dana'**
  String get expenseColFunding;

  /// No description provided for @expenseColAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get expenseColAmount;

  /// No description provided for @expenseColReceipt.
  ///
  /// In id, this message translates to:
  /// **'Bukti'**
  String get expenseColReceipt;

  /// No description provided for @expenseColStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get expenseColStatus;

  /// No description provided for @expenseHasReceipt.
  ///
  /// In id, this message translates to:
  /// **'Ada foto'**
  String get expenseHasReceipt;

  /// No description provided for @expenseNoReceipt.
  ///
  /// In id, this message translates to:
  /// **'Tanpa foto'**
  String get expenseNoReceipt;

  /// No description provided for @expenseVoided.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get expenseVoided;

  /// No description provided for @expenseActive.
  ///
  /// In id, this message translates to:
  /// **'Tercatat'**
  String get expenseActive;

  /// No description provided for @expenseFundingSession.
  ///
  /// In id, this message translates to:
  /// **'{funding} · sesi {name}'**
  String expenseFundingSession(String funding, String name);

  /// No description provided for @expenseFormTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat pengeluaran'**
  String get expenseFormTitle;

  /// No description provided for @expenseDescription.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get expenseDescription;

  /// No description provided for @expenseDescriptionHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Galon air minum'**
  String get expenseDescriptionHint;

  /// No description provided for @expenseCategory.
  ///
  /// In id, this message translates to:
  /// **'Jenis pengeluaran'**
  String get expenseCategory;

  /// No description provided for @expenseCategoryHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih jenis'**
  String get expenseCategoryHint;

  /// No description provided for @expenseAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get expenseAmount;

  /// No description provided for @expenseFunding.
  ///
  /// In id, this message translates to:
  /// **'Sumber dana'**
  String get expenseFunding;

  /// No description provided for @expenseFundingDrawerActive.
  ///
  /// In id, this message translates to:
  /// **'Kas laci (sesi aktif)'**
  String get expenseFundingDrawerActive;

  /// No description provided for @expenseDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get expenseDate;

  /// No description provided for @expenseReceiptPick.
  ///
  /// In id, this message translates to:
  /// **'Lampirkan foto nota'**
  String get expenseReceiptPick;

  /// No description provided for @expenseReceiptCamera.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto nota'**
  String get expenseReceiptCamera;

  /// No description provided for @expenseReceiptInvalid.
  ///
  /// In id, this message translates to:
  /// **'Foto nota harus gambar PNG/JPEG/WebP, maksimal 20 MB.'**
  String get expenseReceiptInvalid;

  /// No description provided for @expenseReceiptMissing.
  ///
  /// In id, this message translates to:
  /// **'Foto nota belum ada di perangkat ini.'**
  String get expenseReceiptMissing;

  /// No description provided for @expenseCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get expenseCancel;

  /// No description provided for @expenseSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan pengeluaran'**
  String get expenseSave;

  /// No description provided for @expenseClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get expenseClose;

  /// No description provided for @expenseErrDescription.
  ///
  /// In id, this message translates to:
  /// **'Keterangan wajib diisi, maksimal {max} karakter.'**
  String expenseErrDescription(int max);

  /// No description provided for @expenseErrCategory.
  ///
  /// In id, this message translates to:
  /// **'Pilih jenis pengeluaran.'**
  String get expenseErrCategory;

  /// No description provided for @expenseErrAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah harus lebih dari 0 dan maksimal Rp 1.000.000.000.'**
  String get expenseErrAmount;

  /// No description provided for @expenseErrDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tidak boleh di masa depan.'**
  String get expenseErrDate;

  /// No description provided for @expenseErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran tidak ditemukan.'**
  String get expenseErrNotFound;

  /// No description provided for @expenseErrAlreadyVoided.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran ini sudah dibatalkan.'**
  String get expenseErrAlreadyVoided;

  /// No description provided for @expenseErrReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan wajib diisi, maksimal {max} karakter.'**
  String expenseErrReason(int max);

  /// No description provided for @expenseErrNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin untuk pengeluaran ini.'**
  String get expenseErrNotPermitted;

  /// No description provided for @expenseErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran gagal diproses. Coba lagi.'**
  String get expenseErrGeneric;

  /// No description provided for @expenseDrawerNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Kas laci butuh izin cash_movements:create.'**
  String get expenseDrawerNotPermitted;

  /// No description provided for @expenseDrawerNoSession.
  ///
  /// In id, this message translates to:
  /// **'Kas laci butuh sesi kasir terbuka di perangkat ini.'**
  String get expenseDrawerNoSession;

  /// No description provided for @expenseDrawerNotToday.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran dari kas laci harus bertanggal hari ini.'**
  String get expenseDrawerNotToday;

  /// No description provided for @expenseDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Rincian pengeluaran'**
  String get expenseDetailTitle;

  /// No description provided for @expenseRecordedBy.
  ///
  /// In id, this message translates to:
  /// **'Dicatat oleh'**
  String get expenseRecordedBy;

  /// No description provided for @expenseVoidInfo.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan oleh {name}: {reason}'**
  String expenseVoidInfo(String name, String reason);

  /// No description provided for @expenseVoid.
  ///
  /// In id, this message translates to:
  /// **'Batalkan pengeluaran'**
  String get expenseVoid;

  /// No description provided for @expenseVoidReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan batal'**
  String get expenseVoidReason;

  /// No description provided for @expenseVoidReasonHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Salah jumlah, akan dicatat ulang'**
  String get expenseVoidReasonHint;

  /// No description provided for @expenseVoidDrawerHint.
  ///
  /// In id, this message translates to:
  /// **'Uang dikembalikan ke laci di sesi kasir yang sedang buka.'**
  String get expenseVoidDrawerHint;

  /// No description provided for @expenseVoidConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, batalkan'**
  String get expenseVoidConfirm;

  /// No description provided for @masterTabExpenseCategories.
  ///
  /// In id, this message translates to:
  /// **'Jenis pengeluaran'**
  String get masterTabExpenseCategories;

  /// No description provided for @expenseCategoriesNew.
  ///
  /// In id, this message translates to:
  /// **'Jenis'**
  String get expenseCategoriesNew;

  /// No description provided for @expenseCategoriesHint.
  ///
  /// In id, this message translates to:
  /// **'Dipakai di layar Pengeluaran dan laporan laba rugi.'**
  String get expenseCategoriesHint;

  /// No description provided for @expenseCategoriesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada jenis pengeluaran.'**
  String get expenseCategoriesEmpty;

  /// No description provided for @expenseCategoriesUsage.
  ///
  /// In id, this message translates to:
  /// **'{count} pengeluaran'**
  String expenseCategoriesUsage(int count);

  /// No description provided for @expenseCategoriesNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Jenis pengeluaran baru'**
  String get expenseCategoriesNewTitle;

  /// No description provided for @expenseCategoriesEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah jenis pengeluaran'**
  String get expenseCategoriesEditTitle;

  /// No description provided for @expenseCategoriesName.
  ///
  /// In id, this message translates to:
  /// **'Nama jenis'**
  String get expenseCategoriesName;

  /// No description provided for @expenseCategoryErrName.
  ///
  /// In id, this message translates to:
  /// **'Nama wajib diisi, maksimal {max} karakter.'**
  String expenseCategoryErrName(int max);

  /// No description provided for @expenseCategoryErrTaken.
  ///
  /// In id, this message translates to:
  /// **'Nama jenis sudah dipakai.'**
  String get expenseCategoryErrTaken;

  /// No description provided for @expenseCategoryErrInUse.
  ///
  /// In id, this message translates to:
  /// **'Jenis ini sudah dipakai pengeluaran, jadi tidak bisa dihapus. Ganti namanya bila perlu.'**
  String get expenseCategoryErrInUse;

  /// No description provided for @cashExpenseBadge.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran · {name}'**
  String cashExpenseBadge(String name);

  /// No description provided for @cashSourceExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get cashSourceExpense;

  /// No description provided for @cashSourceExpenseVoid.
  ///
  /// In id, this message translates to:
  /// **'Batal pengeluaran'**
  String get cashSourceExpenseVoid;

  /// No description provided for @cashAsExpense.
  ///
  /// In id, this message translates to:
  /// **'Catat juga sebagai pengeluaran'**
  String get cashAsExpense;

  /// No description provided for @cashAsExpenseHint.
  ///
  /// In id, this message translates to:
  /// **'Agar ikut laporan laba rugi (1.24)'**
  String get cashAsExpenseHint;

  /// No description provided for @cashAsExpenseNeedsNote.
  ///
  /// In id, this message translates to:
  /// **'Keterangan wajib diisi dan menjadi keterangan pengeluaran.'**
  String get cashAsExpenseNeedsNote;

  /// No description provided for @expenseCategorySave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get expenseCategorySave;

  /// No description provided for @expenseReceiptOpen.
  ///
  /// In id, this message translates to:
  /// **'Buka foto nota'**
  String get expenseReceiptOpen;

  /// No description provided for @expenseFundingDrawer.
  ///
  /// In id, this message translates to:
  /// **'Kas laci'**
  String get expenseFundingDrawer;

  /// No description provided for @reportsTitle.
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get reportsTitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{period} · {outlet}'**
  String reportsSubtitle(String period, String outlet);

  /// No description provided for @reportsPeriod.
  ///
  /// In id, this message translates to:
  /// **'Periode'**
  String get reportsPeriod;

  /// No description provided for @reportsPeriodToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get reportsPeriodToday;

  /// No description provided for @reportsPeriod7Days.
  ///
  /// In id, this message translates to:
  /// **'7 hari terakhir'**
  String get reportsPeriod7Days;

  /// No description provided for @reportsPeriodThisMonth.
  ///
  /// In id, this message translates to:
  /// **'Bulan ini'**
  String get reportsPeriodThisMonth;

  /// No description provided for @reportsDownloadPdf.
  ///
  /// In id, this message translates to:
  /// **'Unduh PDF'**
  String get reportsDownloadPdf;

  /// No description provided for @reportsDownloadExcel.
  ///
  /// In id, this message translates to:
  /// **'Unduh Excel'**
  String get reportsDownloadExcel;

  /// No description provided for @reportsTabSummary.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get reportsTabSummary;

  /// No description provided for @reportsTabSales.
  ///
  /// In id, this message translates to:
  /// **'Penjualan'**
  String get reportsTabSales;

  /// No description provided for @reportsTabTop.
  ///
  /// In id, this message translates to:
  /// **'Produk terlaris'**
  String get reportsTabTop;

  /// No description provided for @reportsTabProfit.
  ///
  /// In id, this message translates to:
  /// **'Laba rugi'**
  String get reportsTabProfit;

  /// No description provided for @reportsKpiSales.
  ///
  /// In id, this message translates to:
  /// **'Penjualan'**
  String get reportsKpiSales;

  /// No description provided for @reportsKpiSalesNote.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi'**
  String reportsKpiSalesNote(int count);

  /// No description provided for @reportsKpiGrossProfit.
  ///
  /// In id, this message translates to:
  /// **'Laba kotor'**
  String get reportsKpiGrossProfit;

  /// No description provided for @reportsKpiGrossProfitNote.
  ///
  /// In id, this message translates to:
  /// **'Dari harga pokok saat jual'**
  String get reportsKpiGrossProfitNote;

  /// No description provided for @reportsKpiAverage.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata per nota'**
  String get reportsKpiAverage;

  /// No description provided for @reportsKpiAverageNote.
  ///
  /// In id, this message translates to:
  /// **'Penjualan bersih ÷ transaksi'**
  String get reportsKpiAverageNote;

  /// No description provided for @reportsKpiOverdue.
  ///
  /// In id, this message translates to:
  /// **'Piutang jatuh tempo'**
  String get reportsKpiOverdue;

  /// No description provided for @reportsKpiOverdueNote.
  ///
  /// In id, this message translates to:
  /// **'{count} pelanggan'**
  String reportsKpiOverdueNote(int count);

  /// No description provided for @reportsByMethod.
  ///
  /// In id, this message translates to:
  /// **'Penjualan per metode bayar'**
  String get reportsByMethod;

  /// No description provided for @reportsByMethodNote.
  ///
  /// In id, this message translates to:
  /// **'Nilai nota sebelum retur'**
  String get reportsByMethodNote;

  /// No description provided for @reportsMethodCredit.
  ///
  /// In id, this message translates to:
  /// **'Kredit (piutang)'**
  String get reportsMethodCredit;

  /// No description provided for @reportsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada penjualan pada periode ini.'**
  String get reportsEmpty;

  /// No description provided for @reportsTop.
  ///
  /// In id, this message translates to:
  /// **'Produk terlaris'**
  String get reportsTop;

  /// No description provided for @reportsFull.
  ///
  /// In id, this message translates to:
  /// **'Laporan lengkap'**
  String get reportsFull;

  /// No description provided for @reportsLinkSalesProduct.
  ///
  /// In id, this message translates to:
  /// **'Penjualan per produk'**
  String get reportsLinkSalesProduct;

  /// No description provided for @reportsLinkSalesStaff.
  ///
  /// In id, this message translates to:
  /// **'Penjualan per kasir'**
  String get reportsLinkSalesStaff;

  /// No description provided for @reportsLinkSalesCategory.
  ///
  /// In id, this message translates to:
  /// **'Penjualan per kategori'**
  String get reportsLinkSalesCategory;

  /// No description provided for @reportsLinkProfit.
  ///
  /// In id, this message translates to:
  /// **'Laba rugi'**
  String get reportsLinkProfit;

  /// No description provided for @reportsLinkStock.
  ///
  /// In id, this message translates to:
  /// **'Kartu stok'**
  String get reportsLinkStock;

  /// No description provided for @reportsLinkDebts.
  ///
  /// In id, this message translates to:
  /// **'Hutang & piutang'**
  String get reportsLinkDebts;

  /// No description provided for @reportsLinkReturns.
  ///
  /// In id, this message translates to:
  /// **'Retur'**
  String get reportsLinkReturns;

  /// No description provided for @reportsLinkExpenses.
  ///
  /// In id, this message translates to:
  /// **'Pemasukan & pengeluaran'**
  String get reportsLinkExpenses;

  /// No description provided for @reportsLinkSessions.
  ///
  /// In id, this message translates to:
  /// **'Rekap sesi kasir'**
  String get reportsLinkSessions;

  /// No description provided for @reportsGroupProduct.
  ///
  /// In id, this message translates to:
  /// **'Per produk'**
  String get reportsGroupProduct;

  /// No description provided for @reportsGroupStaff.
  ///
  /// In id, this message translates to:
  /// **'Per kasir'**
  String get reportsGroupStaff;

  /// No description provided for @reportsGroupCategory.
  ///
  /// In id, this message translates to:
  /// **'Per kategori'**
  String get reportsGroupCategory;

  /// No description provided for @reportsColProduct.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get reportsColProduct;

  /// No description provided for @reportsColStaff.
  ///
  /// In id, this message translates to:
  /// **'Kasir'**
  String get reportsColStaff;

  /// No description provided for @reportsColCategory.
  ///
  /// In id, this message translates to:
  /// **'Kategori'**
  String get reportsColCategory;

  /// No description provided for @reportsColQty.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get reportsColQty;

  /// No description provided for @reportsColReceipts.
  ///
  /// In id, this message translates to:
  /// **'Nota'**
  String get reportsColReceipts;

  /// No description provided for @reportsColNet.
  ///
  /// In id, this message translates to:
  /// **'Penjualan bersih'**
  String get reportsColNet;

  /// No description provided for @reportsColShare.
  ///
  /// In id, this message translates to:
  /// **'Porsi'**
  String get reportsColShare;

  /// No description provided for @reportsColRank.
  ///
  /// In id, this message translates to:
  /// **'#'**
  String get reportsColRank;

  /// No description provided for @reportsColValue.
  ///
  /// In id, this message translates to:
  /// **'Nilai'**
  String get reportsColValue;

  /// No description provided for @reportsColLine.
  ///
  /// In id, this message translates to:
  /// **'Keterangan'**
  String get reportsColLine;

  /// No description provided for @reportsColAmount.
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get reportsColAmount;

  /// No description provided for @reportsColMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode bayar'**
  String get reportsColMethod;

  /// No description provided for @reportsNoCategory.
  ///
  /// In id, this message translates to:
  /// **'Tanpa kategori'**
  String get reportsNoCategory;

  /// No description provided for @reportsTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get reportsTotal;

  /// No description provided for @reportsSalesNote.
  ///
  /// In id, this message translates to:
  /// **'Per produk dan kategori: nilai baris setelah harga grosir dan retur, tanpa service dan PB1. Per kasir: penjualan bersih seperti di laba rugi. Jumlah dalam satuan dasar.'**
  String get reportsSalesNote;

  /// No description provided for @reportsPlTitle.
  ///
  /// In id, this message translates to:
  /// **'Laba rugi · {period}'**
  String reportsPlTitle(String period);

  /// No description provided for @reportsPlSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{outlet} · semua kasir'**
  String reportsPlSubtitle(String outlet);

  /// No description provided for @reportsPlGross.
  ///
  /// In id, this message translates to:
  /// **'Penjualan kotor'**
  String get reportsPlGross;

  /// No description provided for @reportsPlDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon'**
  String get reportsPlDiscount;

  /// No description provided for @reportsPlService.
  ///
  /// In id, this message translates to:
  /// **'Service charge'**
  String get reportsPlService;

  /// No description provided for @reportsPlReturns.
  ///
  /// In id, this message translates to:
  /// **'Retur penjualan'**
  String get reportsPlReturns;

  /// No description provided for @reportsPlNet.
  ///
  /// In id, this message translates to:
  /// **'Penjualan bersih'**
  String get reportsPlNet;

  /// No description provided for @reportsPlCogs.
  ///
  /// In id, this message translates to:
  /// **'Harga pokok penjualan (HPP)'**
  String get reportsPlCogs;

  /// No description provided for @reportsPlGrossProfit.
  ///
  /// In id, this message translates to:
  /// **'Laba kotor · margin {margin}'**
  String reportsPlGrossProfit(String margin);

  /// No description provided for @reportsPlExpensesTotal.
  ///
  /// In id, this message translates to:
  /// **'Total beban operasional'**
  String get reportsPlExpensesTotal;

  /// No description provided for @reportsPlExpensesNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengeluaran'**
  String get reportsPlExpensesNone;

  /// No description provided for @reportsPlAdjustment.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian stok (selisih, rusak, hilang)'**
  String get reportsPlAdjustment;

  /// No description provided for @reportsPlNetProfit.
  ///
  /// In id, this message translates to:
  /// **'Laba bersih'**
  String get reportsPlNetProfit;

  /// No description provided for @reportsPlTax.
  ///
  /// In id, this message translates to:
  /// **'PB1 dipungut {amount}: bukan pendapatan, tidak ikut dihitung.'**
  String reportsPlTax(String amount);

  /// No description provided for @reportsPlMissingCost.
  ///
  /// In id, this message translates to:
  /// **'{count} produk terjual tanpa harga pokok: HPP-nya dihitung 0.'**
  String reportsPlMissingCost(int count);

  /// No description provided for @reportsVsPrevious.
  ///
  /// In id, this message translates to:
  /// **'{change} dibanding {period}'**
  String reportsVsPrevious(String change, String period);

  /// No description provided for @reportsPreviousValue.
  ///
  /// In id, this message translates to:
  /// **'{period}: {amount}'**
  String reportsPreviousValue(String period, String amount);

  /// No description provided for @reportsPrevToday.
  ///
  /// In id, this message translates to:
  /// **'kemarin'**
  String get reportsPrevToday;

  /// No description provided for @reportsPrev7Days.
  ///
  /// In id, this message translates to:
  /// **'7 hari sebelumnya'**
  String get reportsPrev7Days;

  /// No description provided for @reportsMargin.
  ///
  /// In id, this message translates to:
  /// **'Margin kotor'**
  String get reportsMargin;

  /// No description provided for @reportsMarginNote.
  ///
  /// In id, this message translates to:
  /// **'Laba kotor ÷ penjualan bersih'**
  String get reportsMarginNote;

  /// No description provided for @reportsExpenseRatio.
  ///
  /// In id, this message translates to:
  /// **'Beban / penjualan'**
  String get reportsExpenseRatio;

  /// No description provided for @reportsHowTitle.
  ///
  /// In id, this message translates to:
  /// **'Cara hitung'**
  String get reportsHowTitle;

  /// No description provided for @reportsHowBody.
  ///
  /// In id, this message translates to:
  /// **'HPP dihitung dari harga pokok rata-rata tertimbang saat jual. Pengeluaran diambil dari menu Pengeluaran. Gaji otomatis baru ada di Fase 3.'**
  String get reportsHowBody;

  /// No description provided for @reportsDocSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{outlet} · dibuat {date}'**
  String reportsDocSubtitle(String outlet, String date);

  /// No description provided for @reportsNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin melihat laporan.'**
  String get reportsNotPermitted;

  /// No description provided for @reportsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Laporan gagal dimuat.'**
  String get reportsLoadFailed;

  /// No description provided for @reportsTabStock.
  ///
  /// In id, this message translates to:
  /// **'Stok'**
  String get reportsTabStock;

  /// No description provided for @reportsTabCash.
  ///
  /// In id, this message translates to:
  /// **'Kas & sesi'**
  String get reportsTabCash;

  /// No description provided for @reportsTabDebts.
  ///
  /// In id, this message translates to:
  /// **'Piutang & hutang'**
  String get reportsTabDebts;

  /// No description provided for @reportsTabReturns.
  ///
  /// In id, this message translates to:
  /// **'Retur'**
  String get reportsTabReturns;

  /// No description provided for @reportsStockValue.
  ///
  /// In id, this message translates to:
  /// **'Nilai stok'**
  String get reportsStockValue;

  /// No description provided for @reportsStockValueNote.
  ///
  /// In id, this message translates to:
  /// **'Harga pokok rata-rata saat ini'**
  String get reportsStockValueNote;

  /// No description provided for @reportsStockItems.
  ///
  /// In id, this message translates to:
  /// **'Produk barang'**
  String get reportsStockItems;

  /// No description provided for @reportsStockItemsNote.
  ///
  /// In id, this message translates to:
  /// **'Varian yang stoknya dilacak'**
  String get reportsStockItemsNote;

  /// No description provided for @reportsStockLow.
  ///
  /// In id, this message translates to:
  /// **'Stok menipis'**
  String get reportsStockLow;

  /// No description provided for @reportsStockLowNote.
  ///
  /// In id, this message translates to:
  /// **'Di bawah atau sama dengan minimum'**
  String get reportsStockLowNote;

  /// No description provided for @reportsStockOut.
  ///
  /// In id, this message translates to:
  /// **'Stok habis'**
  String get reportsStockOut;

  /// No description provided for @reportsStockOutNote.
  ///
  /// In id, this message translates to:
  /// **'Stok nol atau minus'**
  String get reportsStockOutNote;

  /// No description provided for @reportsStockMovement.
  ///
  /// In id, this message translates to:
  /// **'Pergerakan stok'**
  String get reportsStockMovement;

  /// No description provided for @reportsStockNote.
  ///
  /// In id, this message translates to:
  /// **'Semua lokasi stok cabang ini, jumlah dalam satuan dasar. Masuk: stok awal, pembelian, retur jual, penyesuaian lebih. Keluar: penjualan, retur beli, penyesuaian kurang. Nilai akhir = stok akhir × harga pokok rata-rata saat ini.'**
  String get reportsStockNote;

  /// No description provided for @reportsStockEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada barang dengan stok atau pergerakan pada periode ini.'**
  String get reportsStockEmpty;

  /// No description provided for @reportsColOpening.
  ///
  /// In id, this message translates to:
  /// **'Awal'**
  String get reportsColOpening;

  /// No description provided for @reportsColIn.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get reportsColIn;

  /// No description provided for @reportsColOut.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get reportsColOut;

  /// No description provided for @reportsColClosing.
  ///
  /// In id, this message translates to:
  /// **'Akhir'**
  String get reportsColClosing;

  /// No description provided for @reportsColClosingValue.
  ///
  /// In id, this message translates to:
  /// **'Nilai akhir'**
  String get reportsColClosingValue;

  /// No description provided for @reportsCashSessions.
  ///
  /// In id, this message translates to:
  /// **'Sesi kasir'**
  String get reportsCashSessions;

  /// No description provided for @reportsCashSessionsNote.
  ///
  /// In id, this message translates to:
  /// **'{count} masih buka'**
  String reportsCashSessionsNote(int count);

  /// No description provided for @reportsCashDifference.
  ///
  /// In id, this message translates to:
  /// **'Total selisih'**
  String get reportsCashDifference;

  /// No description provided for @reportsCashDifferenceNote.
  ///
  /// In id, this message translates to:
  /// **'Sesi yang sudah ditutup'**
  String get reportsCashDifferenceNote;

  /// No description provided for @reportsCashIn.
  ///
  /// In id, this message translates to:
  /// **'Kas masuk lain'**
  String get reportsCashIn;

  /// No description provided for @reportsCashOut.
  ///
  /// In id, this message translates to:
  /// **'Kas keluar'**
  String get reportsCashOut;

  /// No description provided for @reportsCashMovementsNote.
  ///
  /// In id, this message translates to:
  /// **'Di luar penjualan'**
  String get reportsCashMovementsNote;

  /// No description provided for @reportsCashMovements.
  ///
  /// In id, this message translates to:
  /// **'Kas masuk & keluar'**
  String get reportsCashMovements;

  /// No description provided for @reportsCashOpen.
  ///
  /// In id, this message translates to:
  /// **'Masih buka'**
  String get reportsCashOpen;

  /// No description provided for @reportsCashEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada sesi kasir yang aktif pada periode ini.'**
  String get reportsCashEmpty;

  /// No description provided for @reportsCashNoMovements.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kas masuk atau keluar di luar penjualan.'**
  String get reportsCashNoMovements;

  /// No description provided for @reportsCashNote.
  ///
  /// In id, this message translates to:
  /// **'Seharusnya = saldo awal + tunai bersih − refund tunai + kas masuk − kas keluar. Sesi yang masih buka dihitung sampai sekarang.'**
  String get reportsCashNote;

  /// No description provided for @reportsColOpened.
  ///
  /// In id, this message translates to:
  /// **'Dibuka'**
  String get reportsColOpened;

  /// No description provided for @reportsColOpeningCash.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal'**
  String get reportsColOpeningCash;

  /// No description provided for @reportsColExpected.
  ///
  /// In id, this message translates to:
  /// **'Seharusnya'**
  String get reportsColExpected;

  /// No description provided for @reportsColCounted.
  ///
  /// In id, this message translates to:
  /// **'Dihitung'**
  String get reportsColCounted;

  /// No description provided for @reportsColDifference.
  ///
  /// In id, this message translates to:
  /// **'Selisih'**
  String get reportsColDifference;

  /// No description provided for @reportsColSource.
  ///
  /// In id, this message translates to:
  /// **'Sumber'**
  String get reportsColSource;

  /// No description provided for @reportsColEntries.
  ///
  /// In id, this message translates to:
  /// **'Catatan'**
  String get reportsColEntries;

  /// No description provided for @reportsSourceManualIn.
  ///
  /// In id, this message translates to:
  /// **'Kas masuk manual'**
  String get reportsSourceManualIn;

  /// No description provided for @reportsSourceManualOut.
  ///
  /// In id, this message translates to:
  /// **'Kas keluar manual'**
  String get reportsSourceManualOut;

  /// No description provided for @reportsSourceExpense.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get reportsSourceExpense;

  /// No description provided for @reportsSourceExpenseVoid.
  ///
  /// In id, this message translates to:
  /// **'Batal pengeluaran'**
  String get reportsSourceExpenseVoid;

  /// No description provided for @reportsSourceSupplierPayment.
  ///
  /// In id, this message translates to:
  /// **'Bayar hutang supplier'**
  String get reportsSourceSupplierPayment;

  /// No description provided for @reportsSourcePurchase.
  ///
  /// In id, this message translates to:
  /// **'Bayar pembelian'**
  String get reportsSourcePurchase;

  /// No description provided for @reportsSourceDebtPayment.
  ///
  /// In id, this message translates to:
  /// **'Terima piutang'**
  String get reportsSourceDebtPayment;

  /// No description provided for @reportsSourceOther.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get reportsSourceOther;

  /// No description provided for @reportsDebtAsOf.
  ///
  /// In id, this message translates to:
  /// **'Posisi per {date}'**
  String reportsDebtAsOf(String date);

  /// No description provided for @reportsDebtReceivable.
  ///
  /// In id, this message translates to:
  /// **'Piutang pelanggan'**
  String get reportsDebtReceivable;

  /// No description provided for @reportsDebtCustomersNote.
  ///
  /// In id, this message translates to:
  /// **'{count} pelanggan'**
  String reportsDebtCustomersNote(int count);

  /// No description provided for @reportsDebtPayable.
  ///
  /// In id, this message translates to:
  /// **'Hutang supplier'**
  String get reportsDebtPayable;

  /// No description provided for @reportsDebtSuppliersNote.
  ///
  /// In id, this message translates to:
  /// **'{count} supplier'**
  String reportsDebtSuppliersNote(int count);

  /// No description provided for @reportsDebtOverduePurchases.
  ///
  /// In id, this message translates to:
  /// **'Nota beli lewat tempo'**
  String get reportsDebtOverduePurchases;

  /// No description provided for @reportsDebtOverduePurchasesNote.
  ///
  /// In id, this message translates to:
  /// **'Bayar dari layar Supplier'**
  String get reportsDebtOverduePurchasesNote;

  /// No description provided for @reportsDebtCustomers.
  ///
  /// In id, this message translates to:
  /// **'Piutang per pelanggan'**
  String get reportsDebtCustomers;

  /// No description provided for @reportsDebtSuppliers.
  ///
  /// In id, this message translates to:
  /// **'Hutang per supplier'**
  String get reportsDebtSuppliers;

  /// No description provided for @reportsDebtNoReceivable.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada piutang pelanggan.'**
  String get reportsDebtNoReceivable;

  /// No description provided for @reportsDebtNoPayable.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hutang supplier.'**
  String get reportsDebtNoPayable;

  /// No description provided for @reportsDebtNote.
  ///
  /// In id, this message translates to:
  /// **'Posisi hari ini, tidak tergantung periode yang dipilih.'**
  String get reportsDebtNote;

  /// No description provided for @reportsColCustomer.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get reportsColCustomer;

  /// No description provided for @reportsColSupplier.
  ///
  /// In id, this message translates to:
  /// **'Supplier'**
  String get reportsColSupplier;

  /// No description provided for @reportsColOpenCount.
  ///
  /// In id, this message translates to:
  /// **'Nota terbuka'**
  String get reportsColOpenCount;

  /// No description provided for @reportsColOverdueCount.
  ///
  /// In id, this message translates to:
  /// **'Lewat tempo'**
  String get reportsColOverdueCount;

  /// No description provided for @reportsColNearestDue.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo terdekat'**
  String get reportsColNearestDue;

  /// No description provided for @reportsColRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa'**
  String get reportsColRemaining;

  /// No description provided for @reportsReturnsCountNote.
  ///
  /// In id, this message translates to:
  /// **'Retur penjualan pada periode'**
  String get reportsReturnsCountNote;

  /// No description provided for @reportsReturnsTotal.
  ///
  /// In id, this message translates to:
  /// **'Nilai retur'**
  String get reportsReturnsTotal;

  /// No description provided for @reportsReturnsTotalNote.
  ///
  /// In id, this message translates to:
  /// **'Termasuk bagian service dan PB1'**
  String get reportsReturnsTotalNote;

  /// No description provided for @reportsReturnsRestock.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke stok'**
  String get reportsReturnsRestock;

  /// No description provided for @reportsReturnsDamaged.
  ///
  /// In id, this message translates to:
  /// **'Rusak / kedaluwarsa'**
  String get reportsReturnsDamaged;

  /// No description provided for @reportsReturnsOfCount.
  ///
  /// In id, this message translates to:
  /// **'dari {count} retur'**
  String reportsReturnsOfCount(int count);

  /// No description provided for @reportsReturnsByReason.
  ///
  /// In id, this message translates to:
  /// **'Per alasan'**
  String get reportsReturnsByReason;

  /// No description provided for @reportsReturnsList.
  ///
  /// In id, this message translates to:
  /// **'Daftar retur'**
  String get reportsReturnsList;

  /// No description provided for @reportsReturnsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada retur pada periode ini.'**
  String get reportsReturnsEmpty;

  /// No description provided for @reportsColTime.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get reportsColTime;

  /// No description provided for @reportsColReturnNo.
  ///
  /// In id, this message translates to:
  /// **'No retur'**
  String get reportsColReturnNo;

  /// No description provided for @reportsColReceiptNo.
  ///
  /// In id, this message translates to:
  /// **'No nota'**
  String get reportsColReceiptNo;

  /// No description provided for @reportsColHandledBy.
  ///
  /// In id, this message translates to:
  /// **'Petugas'**
  String get reportsColHandledBy;

  /// No description provided for @reportsColReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan'**
  String get reportsColReason;

  /// No description provided for @reportsColRestock.
  ///
  /// In id, this message translates to:
  /// **'Ke stok'**
  String get reportsColRestock;

  /// No description provided for @reportsColRefund.
  ///
  /// In id, this message translates to:
  /// **'Refund'**
  String get reportsColRefund;

  /// No description provided for @reportsYes.
  ///
  /// In id, this message translates to:
  /// **'Ya'**
  String get reportsYes;

  /// No description provided for @reportsNo.
  ///
  /// In id, this message translates to:
  /// **'Tidak'**
  String get reportsNo;

  /// No description provided for @reportsSourcePurchaseRefund.
  ///
  /// In id, this message translates to:
  /// **'Refund retur pembelian'**
  String get reportsSourcePurchaseRefund;

  /// No description provided for @reportsRefundMixed.
  ///
  /// In id, this message translates to:
  /// **'{method} + potong piutang'**
  String reportsRefundMixed(String method);

  /// No description provided for @reportsCashOpenNote.
  ///
  /// In id, this message translates to:
  /// **'Dihitung dan selisih kosong = sesi masih buka.'**
  String get reportsCashOpenNote;

  /// No description provided for @menuAccount.
  ///
  /// In id, this message translates to:
  /// **'Akun saya'**
  String get menuAccount;

  /// No description provided for @usersSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah staf, reset PIN, dan atur izin per role.'**
  String get usersSubtitle;

  /// No description provided for @usersTabUsers.
  ///
  /// In id, this message translates to:
  /// **'Pengguna'**
  String get usersTabUsers;

  /// No description provided for @usersTabRoles.
  ///
  /// In id, this message translates to:
  /// **'Role & izin'**
  String get usersTabRoles;

  /// No description provided for @usersListTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengguna outlet'**
  String get usersListTitle;

  /// No description provided for @usersListCount.
  ///
  /// In id, this message translates to:
  /// **'{outlet} · {count} pengguna aktif'**
  String usersListCount(String outlet, int count);

  /// No description provided for @usersAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get usersAdd;

  /// No description provided for @usersColUser.
  ///
  /// In id, this message translates to:
  /// **'Pengguna'**
  String get usersColUser;

  /// No description provided for @usersColRole.
  ///
  /// In id, this message translates to:
  /// **'Role'**
  String get usersColRole;

  /// No description provided for @usersColOutlet.
  ///
  /// In id, this message translates to:
  /// **'Cabang'**
  String get usersColOutlet;

  /// No description provided for @usersColStatus.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get usersColStatus;

  /// No description provided for @usersPinOnly.
  ///
  /// In id, this message translates to:
  /// **'PIN saja'**
  String get usersPinOnly;

  /// No description provided for @usersEmailAndPin.
  ///
  /// In id, this message translates to:
  /// **'Email + PIN'**
  String get usersEmailAndPin;

  /// No description provided for @usersAllOutlets.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get usersAllOutlets;

  /// No description provided for @usersStatusActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get usersStatusActive;

  /// No description provided for @usersStatusInactive.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get usersStatusInactive;

  /// No description provided for @usersStatusLocked.
  ///
  /// In id, this message translates to:
  /// **'PIN dikunci {seconds} dtk'**
  String usersStatusLocked(int seconds);

  /// No description provided for @usersUnlock.
  ///
  /// In id, this message translates to:
  /// **'Buka kunci'**
  String get usersUnlock;

  /// No description provided for @usersResetHint.
  ///
  /// In id, this message translates to:
  /// **'Reset PIN staf: buka pengguna, isi PIN baru dan ulangi PIN baru. Staf tidak perlu PIN lama.'**
  String get usersResetHint;

  /// No description provided for @usersOwnerHint.
  ///
  /// In id, this message translates to:
  /// **'Pemilik mengganti PIN dan kata sandinya di Akun saya.'**
  String get usersOwnerHint;

  /// No description provided for @usersEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pengguna lain. Tambah staf dengan PIN.'**
  String get usersEmpty;

  /// No description provided for @usersFormNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah pengguna'**
  String get usersFormNewTitle;

  /// No description provided for @usersFormEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah pengguna'**
  String get usersFormEditTitle;

  /// No description provided for @usersFormPermission.
  ///
  /// In id, this message translates to:
  /// **'Butuh izin users:manage'**
  String get usersFormPermission;

  /// No description provided for @usersFieldName.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get usersFieldName;

  /// No description provided for @usersFieldRole.
  ///
  /// In id, this message translates to:
  /// **'Role'**
  String get usersFieldRole;

  /// No description provided for @usersFieldRoleHint.
  ///
  /// In id, this message translates to:
  /// **'Izin mengikuti role; atur di tab Role & izin'**
  String get usersFieldRoleHint;

  /// No description provided for @usersFieldPin.
  ///
  /// In id, this message translates to:
  /// **'PIN (6 angka)'**
  String get usersFieldPin;

  /// No description provided for @usersFieldPinHint.
  ///
  /// In id, this message translates to:
  /// **'Staf memakai PIN ini untuk masuk di kasir'**
  String get usersFieldPinHint;

  /// No description provided for @usersFieldPinRetype.
  ///
  /// In id, this message translates to:
  /// **'Ulangi PIN'**
  String get usersFieldPinRetype;

  /// No description provided for @usersFieldActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get usersFieldActive;

  /// No description provided for @usersFieldActiveHint.
  ///
  /// In id, this message translates to:
  /// **'Pengguna nonaktif tidak muncul di layar login'**
  String get usersFieldActiveHint;

  /// No description provided for @usersCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get usersCancel;

  /// No description provided for @usersSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan pengguna'**
  String get usersSave;

  /// No description provided for @usersResetTitle.
  ///
  /// In id, this message translates to:
  /// **'Reset PIN'**
  String get usersResetTitle;

  /// No description provided for @usersResetPin.
  ///
  /// In id, this message translates to:
  /// **'PIN baru'**
  String get usersResetPin;

  /// No description provided for @usersResetRetype.
  ///
  /// In id, this message translates to:
  /// **'Ulangi PIN baru'**
  String get usersResetRetype;

  /// No description provided for @usersResetSubmit.
  ///
  /// In id, this message translates to:
  /// **'Reset PIN'**
  String get usersResetSubmit;

  /// No description provided for @usersResetDone.
  ///
  /// In id, this message translates to:
  /// **'PIN baru tersimpan dan kunci PIN dibuka.'**
  String get usersResetDone;

  /// No description provided for @usersErrNameTaken.
  ///
  /// In id, this message translates to:
  /// **'Nama sudah dipakai pengguna lain'**
  String get usersErrNameTaken;

  /// No description provided for @usersErrOwnerLocked.
  ///
  /// In id, this message translates to:
  /// **'Pemilik tidak bisa diubah di sini.'**
  String get usersErrOwnerLocked;

  /// No description provided for @usersErrSelf.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak bisa mengubah akun atau role Anda sendiri di sini.'**
  String get usersErrSelf;

  /// No description provided for @usersErrBeyond.
  ///
  /// In id, this message translates to:
  /// **'Anda hanya bisa memberi izin yang Anda miliki.'**
  String get usersErrBeyond;

  /// No description provided for @usersErrRoleNotFound.
  ///
  /// In id, this message translates to:
  /// **'Role tidak ditemukan.'**
  String get usersErrRoleNotFound;

  /// No description provided for @usersErrRoleTaken.
  ///
  /// In id, this message translates to:
  /// **'Nama role sudah dipakai.'**
  String get usersErrRoleTaken;

  /// No description provided for @usersErrRoleInUse.
  ///
  /// In id, this message translates to:
  /// **'Role masih dipakai pengguna. Pindahkan penggunanya dulu.'**
  String get usersErrRoleInUse;

  /// No description provided for @usersErrNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Anda tidak punya izin untuk aksi ini.'**
  String get usersErrNotPermitted;

  /// No description provided for @usersErrGeneric.
  ///
  /// In id, this message translates to:
  /// **'Gagal memproses. Coba lagi.'**
  String get usersErrGeneric;

  /// No description provided for @usersErrWrongPin.
  ///
  /// In id, this message translates to:
  /// **'PIN saat ini salah. Sisa {remaining} percobaan.'**
  String usersErrWrongPin(int remaining);

  /// No description provided for @usersErrWrongPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi saat ini salah.'**
  String get usersErrWrongPassword;

  /// No description provided for @usersErrLocked.
  ///
  /// In id, this message translates to:
  /// **'Terlalu banyak percobaan. Coba lagi dalam {seconds} detik.'**
  String usersErrLocked(int seconds);

  /// No description provided for @usersMatrixTitle.
  ///
  /// In id, this message translates to:
  /// **'Matriks izin per role'**
  String get usersMatrixTitle;

  /// No description provided for @usersMatrixPermission.
  ///
  /// In id, this message translates to:
  /// **'Izin'**
  String get usersMatrixPermission;

  /// No description provided for @usersMatrixNewRole.
  ///
  /// In id, this message translates to:
  /// **'Role custom'**
  String get usersMatrixNewRole;

  /// No description provided for @usersMatrixSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan perubahan'**
  String get usersMatrixSave;

  /// No description provided for @usersMatrixDiscard.
  ///
  /// In id, this message translates to:
  /// **'Batalkan'**
  String get usersMatrixDiscard;

  /// No description provided for @usersMatrixSaved.
  ///
  /// In id, this message translates to:
  /// **'Izin role tersimpan.'**
  String get usersMatrixSaved;

  /// No description provided for @usersMatrixNote.
  ///
  /// In id, this message translates to:
  /// **'Izin berformat resource:action. Tombol dan halaman yang tidak diizinkan otomatis disembunyikan. Pemilik selalu punya semua izin. Role disimpan di perangkat ini; perubahan berlaku saat staf masuk berikutnya.'**
  String get usersMatrixNote;

  /// No description provided for @usersMatrixMembers.
  ///
  /// In id, this message translates to:
  /// **'{count} pengguna'**
  String usersMatrixMembers(int count);

  /// No description provided for @usersRoleNewTitle.
  ///
  /// In id, this message translates to:
  /// **'Role custom baru'**
  String get usersRoleNewTitle;

  /// No description provided for @usersRoleRenameTitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti nama role'**
  String get usersRoleRenameTitle;

  /// No description provided for @usersRoleName.
  ///
  /// In id, this message translates to:
  /// **'Nama role'**
  String get usersRoleName;

  /// No description provided for @usersRoleNameHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Barista'**
  String get usersRoleNameHint;

  /// No description provided for @usersRoleCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat role'**
  String get usersRoleCreate;

  /// No description provided for @usersRoleRename.
  ///
  /// In id, this message translates to:
  /// **'Ganti nama'**
  String get usersRoleRename;

  /// No description provided for @usersRoleDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus role'**
  String get usersRoleDelete;

  /// No description provided for @permSalesCreate.
  ///
  /// In id, this message translates to:
  /// **'Buat transaksi'**
  String get permSalesCreate;

  /// No description provided for @permSalesVoid.
  ///
  /// In id, this message translates to:
  /// **'Void nota'**
  String get permSalesVoid;

  /// No description provided for @permSalesDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon manual'**
  String get permSalesDiscount;

  /// No description provided for @permSalesReturn.
  ///
  /// In id, this message translates to:
  /// **'Retur penjualan'**
  String get permSalesReturn;

  /// No description provided for @permPaymentsConfirm.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi bayar manual (QRIS, kartu)'**
  String get permPaymentsConfirm;

  /// No description provided for @permOpenBillsManage.
  ///
  /// In id, this message translates to:
  /// **'Kelola meja & open bill'**
  String get permOpenBillsManage;

  /// No description provided for @permCashSessionOpen.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi kasir'**
  String get permCashSessionOpen;

  /// No description provided for @permCashSessionClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup sesi kasir'**
  String get permCashSessionClose;

  /// No description provided for @permCashMovementsCreate.
  ///
  /// In id, this message translates to:
  /// **'Uang masuk / keluar laci'**
  String get permCashMovementsCreate;

  /// No description provided for @permProductsManage.
  ///
  /// In id, this message translates to:
  /// **'Kelola produk & harga'**
  String get permProductsManage;

  /// No description provided for @permCustomersManage.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan'**
  String get permCustomersManage;

  /// No description provided for @permSuppliersManage.
  ///
  /// In id, this message translates to:
  /// **'Supplier'**
  String get permSuppliersManage;

  /// No description provided for @permPurchasesManage.
  ///
  /// In id, this message translates to:
  /// **'Pembelian & retur beli'**
  String get permPurchasesManage;

  /// No description provided for @permStockAdjust.
  ///
  /// In id, this message translates to:
  /// **'Penyesuaian stok'**
  String get permStockAdjust;

  /// No description provided for @permDebtsManage.
  ///
  /// In id, this message translates to:
  /// **'Piutang & kredit'**
  String get permDebtsManage;

  /// No description provided for @permExpensesManage.
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get permExpensesManage;

  /// No description provided for @permReportsView.
  ///
  /// In id, this message translates to:
  /// **'Lihat laporan'**
  String get permReportsView;

  /// No description provided for @permReportsViewProfit.
  ///
  /// In id, this message translates to:
  /// **'Lihat laba rugi'**
  String get permReportsViewProfit;

  /// No description provided for @permSettingsManage.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan toko'**
  String get permSettingsManage;

  /// No description provided for @permUsersManage.
  ///
  /// In id, this message translates to:
  /// **'Pengguna & role'**
  String get permUsersManage;

  /// No description provided for @permBackupManage.
  ///
  /// In id, this message translates to:
  /// **'Backup & pulihkan'**
  String get permBackupManage;

  /// No description provided for @permSyncManage.
  ///
  /// In id, this message translates to:
  /// **'Sync & hosting'**
  String get permSyncManage;

  /// No description provided for @accountTitle.
  ///
  /// In id, this message translates to:
  /// **'Akun saya'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{name} · {role} · terbuka untuk setiap pengguna'**
  String accountSubtitle(String name, String role);

  /// No description provided for @accountPasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti kata sandi'**
  String get accountPasswordTitle;

  /// No description provided for @accountPasswordCurrent.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi saat ini'**
  String get accountPasswordCurrent;

  /// No description provided for @accountPasswordNew.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru'**
  String get accountPasswordNew;

  /// No description provided for @accountPasswordNewHint.
  ///
  /// In id, this message translates to:
  /// **'Minimal 8 karakter'**
  String get accountPasswordNewHint;

  /// No description provided for @accountPasswordRetype.
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi baru'**
  String get accountPasswordRetype;

  /// No description provided for @accountPasswordSubmit.
  ///
  /// In id, this message translates to:
  /// **'Ganti kata sandi'**
  String get accountPasswordSubmit;

  /// No description provided for @accountPasswordDone.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi baru tersimpan.'**
  String get accountPasswordDone;

  /// No description provided for @accountPasswordNone.
  ///
  /// In id, this message translates to:
  /// **'Akun ini masuk dengan PIN saja, tanpa kata sandi.'**
  String get accountPasswordNone;

  /// No description provided for @accountPinTitle.
  ///
  /// In id, this message translates to:
  /// **'Ganti PIN'**
  String get accountPinTitle;

  /// No description provided for @accountPinCurrent.
  ///
  /// In id, this message translates to:
  /// **'PIN saat ini'**
  String get accountPinCurrent;

  /// No description provided for @accountPinNew.
  ///
  /// In id, this message translates to:
  /// **'PIN baru'**
  String get accountPinNew;

  /// No description provided for @accountPinRetype.
  ///
  /// In id, this message translates to:
  /// **'Ulangi PIN baru'**
  String get accountPinRetype;

  /// No description provided for @accountPinSubmit.
  ///
  /// In id, this message translates to:
  /// **'Ganti PIN'**
  String get accountPinSubmit;

  /// No description provided for @accountPinDone.
  ///
  /// In id, this message translates to:
  /// **'PIN baru tersimpan.'**
  String get accountPinDone;

  /// No description provided for @usersErrStaffNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pengguna tidak ditemukan atau sudah nonaktif.'**
  String get usersErrStaffNotFound;

  /// No description provided for @usersErrNoPassword.
  ///
  /// In id, this message translates to:
  /// **'Akun ini tidak memakai kata sandi.'**
  String get usersErrNoPassword;

  /// No description provided for @usersRoleDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus role {name}?'**
  String usersRoleDeleteTitle(String name);

  /// No description provided for @usersRoleDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'Role yang masih dipakai pengguna tidak bisa dihapus.'**
  String get usersRoleDeleteBody;

  /// No description provided for @usersRoleDeleteConfirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get usersRoleDeleteConfirm;

  /// No description provided for @cashierRounding.
  ///
  /// In id, this message translates to:
  /// **'Pembulatan'**
  String get cashierRounding;

  /// No description provided for @saleErrorStockShort.
  ///
  /// In id, this message translates to:
  /// **'Stok tidak cukup: {names}. Stok minus dimatikan di Pengaturan › Penjualan & stok.'**
  String saleErrorStockShort(String names);

  /// No description provided for @reportsPlIncludedTax.
  ///
  /// In id, this message translates to:
  /// **'PB1 termasuk harga'**
  String get reportsPlIncludedTax;

  /// No description provided for @reportsPlRounding.
  ///
  /// In id, this message translates to:
  /// **'Pembulatan total'**
  String get reportsPlRounding;

  /// No description provided for @receiptTaxIncluded.
  ///
  /// In id, this message translates to:
  /// **'PB1 {pct} (termasuk)'**
  String receiptTaxIncluded(String pct);

  /// No description provided for @receiptRounding.
  ///
  /// In id, this message translates to:
  /// **'Pembulatan'**
  String get receiptRounding;

  /// No description provided for @diningTaxIncluded.
  ///
  /// In id, this message translates to:
  /// **'PB1 {pct} (termasuk)'**
  String diningTaxIncluded(String pct);

  /// No description provided for @fnbRatesInclusive.
  ///
  /// In id, this message translates to:
  /// **'Harga sudah termasuk pajak'**
  String get fnbRatesInclusive;

  /// No description provided for @fnbRatesInclusiveHint.
  ///
  /// In id, this message translates to:
  /// **'PB1 dipisahkan dari harga menu dan tidak ditambahkan ke total.'**
  String get fnbRatesInclusiveHint;

  /// No description provided for @settingsTextSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran tampilan'**
  String get settingsTextSize;

  /// No description provided for @settingsTextSizeNormal.
  ///
  /// In id, this message translates to:
  /// **'Normal'**
  String get settingsTextSizeNormal;

  /// No description provided for @settingsTextSizeLarge.
  ///
  /// In id, this message translates to:
  /// **'Besar'**
  String get settingsTextSizeLarge;

  /// No description provided for @storeSettingsPhoneInvalid.
  ///
  /// In id, this message translates to:
  /// **'Hanya angka, spasi, + dan -'**
  String get storeSettingsPhoneInvalid;

  /// No description provided for @storeSettingsLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan toko gagal dimuat.'**
  String get storeSettingsLoadFailed;

  /// No description provided for @storeSettingsBusinessTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil toko'**
  String get storeSettingsBusinessTitle;

  /// No description provided for @storeSettingsBusinessSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Berlaku untuk semua cabang'**
  String get storeSettingsBusinessSubtitle;

  /// No description provided for @storeSettingsBusinessName.
  ///
  /// In id, this message translates to:
  /// **'Nama usaha'**
  String get storeSettingsBusinessName;

  /// No description provided for @storeSettingsBusinessType.
  ///
  /// In id, this message translates to:
  /// **'Jenis usaha'**
  String get storeSettingsBusinessType;

  /// No description provided for @storeSettingsBusinessNote.
  ///
  /// In id, this message translates to:
  /// **'Jenis usaha dan zona waktu dipilih saat setup dan tidak bisa diubah karena menentukan menu dan tanggal di nomor nota.'**
  String get storeSettingsBusinessNote;

  /// No description provided for @storeSettingsBusinessSaved.
  ///
  /// In id, this message translates to:
  /// **'Profil toko tersimpan.'**
  String get storeSettingsBusinessSaved;

  /// No description provided for @storeSettingsOutletTitle.
  ///
  /// In id, this message translates to:
  /// **'Cabang ini'**
  String get storeSettingsOutletTitle;

  /// No description provided for @storeSettingsOutletSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Alamat dan telepon tampil di kepala struk bawaan'**
  String get storeSettingsOutletSubtitle;

  /// No description provided for @storeSettingsOutletName.
  ///
  /// In id, this message translates to:
  /// **'Nama cabang'**
  String get storeSettingsOutletName;

  /// No description provided for @storeSettingsAddress.
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get storeSettingsAddress;

  /// No description provided for @storeSettingsPhone.
  ///
  /// In id, this message translates to:
  /// **'Telepon'**
  String get storeSettingsPhone;

  /// No description provided for @storeSettingsOutletCode.
  ///
  /// In id, this message translates to:
  /// **'Kode cabang'**
  String get storeSettingsOutletCode;

  /// No description provided for @storeSettingsDeviceCode.
  ///
  /// In id, this message translates to:
  /// **'Kode perangkat'**
  String get storeSettingsDeviceCode;

  /// No description provided for @storeSettingsOutletNote.
  ///
  /// In id, this message translates to:
  /// **'Kode cabang dan perangkat dipakai di nomor nota (mis. PST-K01-…), jadi tidak bisa diubah.'**
  String get storeSettingsOutletNote;

  /// No description provided for @storeSettingsOutletSaved.
  ///
  /// In id, this message translates to:
  /// **'Data cabang tersimpan.'**
  String get storeSettingsOutletSaved;

  /// No description provided for @storeSettingsRulesTitle.
  ///
  /// In id, this message translates to:
  /// **'Penjualan & stok'**
  String get storeSettingsRulesTitle;

  /// No description provided for @storeSettingsRulesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Berlaku untuk semua perangkat cabang ini'**
  String get storeSettingsRulesSubtitle;

  /// No description provided for @storeSettingsNegativeStock.
  ///
  /// In id, this message translates to:
  /// **'Izinkan stok minus'**
  String get storeSettingsNegativeStock;

  /// No description provided for @storeSettingsNegativeStockHint.
  ///
  /// In id, this message translates to:
  /// **'Jika mati, produk habis tidak bisa dijual'**
  String get storeSettingsNegativeStockHint;

  /// No description provided for @storeSettingsRequireSession.
  ///
  /// In id, this message translates to:
  /// **'Wajib buka sesi kasir'**
  String get storeSettingsRequireSession;

  /// No description provided for @storeSettingsRequireSessionHint.
  ///
  /// In id, this message translates to:
  /// **'Selalu aktif: uang tunai dicatat per sesi kasir'**
  String get storeSettingsRequireSessionHint;

  /// No description provided for @storeSettingsRounding.
  ///
  /// In id, this message translates to:
  /// **'Pembulatan total'**
  String get storeSettingsRounding;

  /// No description provided for @storeSettingsRoundingHint.
  ///
  /// In id, this message translates to:
  /// **'Ke kelipatan terdekat, tepat setengah ke atas. Berlaku untuk semua metode bayar.'**
  String get storeSettingsRoundingHint;

  /// No description provided for @storeSettingsRoundingNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada'**
  String get storeSettingsRoundingNone;

  /// No description provided for @storeSettingsRounding100.
  ///
  /// In id, this message translates to:
  /// **'Ke Rp 100 terdekat'**
  String get storeSettingsRounding100;

  /// No description provided for @storeSettingsRounding500.
  ///
  /// In id, this message translates to:
  /// **'Ke Rp 500 terdekat'**
  String get storeSettingsRounding500;

  /// No description provided for @storeSettingsRulesSaved.
  ///
  /// In id, this message translates to:
  /// **'Aturan penjualan tersimpan.'**
  String get storeSettingsRulesSaved;

  /// No description provided for @storeSettingsSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get storeSettingsSave;

  /// No description provided for @storeSettingsSaveFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan. Coba lagi.'**
  String get storeSettingsSaveFailed;

  /// No description provided for @billSplitTaxIncluded.
  ///
  /// In id, this message translates to:
  /// **'{pct} (termasuk)'**
  String billSplitTaxIncluded(String pct);

  /// No description provided for @cashierDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon'**
  String get cashierDiscount;

  /// No description provided for @cashierDiscountBillTitle.
  ///
  /// In id, this message translates to:
  /// **'Diskon nota'**
  String get cashierDiscountBillTitle;

  /// No description provided for @cashierDiscountLineTitle.
  ///
  /// In id, this message translates to:
  /// **'Diskon baris'**
  String get cashierDiscountLineTitle;

  /// No description provided for @cashierDiscountHint.
  ///
  /// In id, this message translates to:
  /// **'Per nota, atau tekan lama baris untuk diskon per item.'**
  String get cashierDiscountHint;

  /// No description provided for @cashierDiscountPercent.
  ///
  /// In id, this message translates to:
  /// **'Persen (%)'**
  String get cashierDiscountPercent;

  /// No description provided for @cashierDiscountAmount.
  ///
  /// In id, this message translates to:
  /// **'Rupiah (Rp)'**
  String get cashierDiscountAmount;

  /// No description provided for @cashierDiscountValue.
  ///
  /// In id, this message translates to:
  /// **'Nilai diskon'**
  String get cashierDiscountValue;

  /// No description provided for @cashierDiscountBase.
  ///
  /// In id, this message translates to:
  /// **'Dari {amount}'**
  String cashierDiscountBase(String amount);

  /// No description provided for @cashierDiscountCut.
  ///
  /// In id, this message translates to:
  /// **'Potongan {amount}'**
  String cashierDiscountCut(String amount);

  /// No description provided for @cashierDiscountApply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get cashierDiscountApply;

  /// No description provided for @cashierDiscountRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus diskon'**
  String get cashierDiscountRemove;

  /// No description provided for @cashierDiscountTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Diskon tidak boleh melebihi atau menghabiskan total.'**
  String get cashierDiscountTooLarge;

  /// No description provided for @cashierDiscountInvalid.
  ///
  /// In id, this message translates to:
  /// **'Isi persen 0,01–100 atau nominal rupiah.'**
  String get cashierDiscountInvalid;

  /// No description provided for @cashierDiscountNeedsPin.
  ///
  /// In id, this message translates to:
  /// **'Setelah Terapkan, manajer memasukkan PIN untuk menyetujui diskon.'**
  String get cashierDiscountNeedsPin;

  /// No description provided for @cashierDiscountPct.
  ///
  /// In id, this message translates to:
  /// **'Diskon {pct}'**
  String cashierDiscountPct(String pct);

  /// No description provided for @cashierLineDiscounts.
  ///
  /// In id, this message translates to:
  /// **'Diskon per item'**
  String get cashierLineDiscounts;

  /// No description provided for @cashierBillDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon nota'**
  String get cashierBillDiscount;

  /// No description provided for @cashierBillDiscountPct.
  ///
  /// In id, this message translates to:
  /// **'Diskon nota {pct}'**
  String cashierBillDiscountPct(String pct);

  /// No description provided for @cashierDiscountApprovedBy.
  ///
  /// In id, this message translates to:
  /// **'disetujui {name}'**
  String cashierDiscountApprovedBy(String name);

  /// No description provided for @approvalDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon manual butuh izin sales:discount. Minta staf yang berizin memasukkan PIN-nya.'**
  String get approvalDiscount;

  /// No description provided for @saleErrorDiscountNotPermitted.
  ///
  /// In id, this message translates to:
  /// **'Diskon manual butuh izin atau persetujuan PIN manajer.'**
  String get saleErrorDiscountNotPermitted;

  /// No description provided for @saleErrorDiscountTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Diskon melebihi nilai baris atau membuat total nota nol.'**
  String get saleErrorDiscountTooLarge;

  /// No description provided for @receiptDiscount.
  ///
  /// In id, this message translates to:
  /// **'Diskon'**
  String get receiptDiscount;

  /// No description provided for @receiptDiscountPct.
  ///
  /// In id, this message translates to:
  /// **'Diskon {pct}'**
  String receiptDiscountPct(String pct);

  /// No description provided for @storeSettingsDiscountPin.
  ///
  /// In id, this message translates to:
  /// **'Diskon manual butuh PIN manajer'**
  String get storeSettingsDiscountPin;

  /// No description provided for @storeSettingsDiscountPinHint.
  ///
  /// In id, this message translates to:
  /// **'Kasir tanpa izin diskon bisa memberi diskon setelah manajer memasukkan PIN. Jika mati, hanya staf berizin yang bisa memberi diskon.'**
  String get storeSettingsDiscountPinHint;

  /// No description provided for @settingsSectionBackup.
  ///
  /// In id, this message translates to:
  /// **'Data & backup'**
  String get settingsSectionBackup;

  /// No description provided for @backupModeLabel.
  ///
  /// In id, this message translates to:
  /// **'Mode saat ini'**
  String get backupModeLabel;

  /// No description provided for @backupModeFree.
  ///
  /// In id, this message translates to:
  /// **'Gratis · offline'**
  String get backupModeFree;

  /// No description provided for @backupModeBody.
  ///
  /// In id, this message translates to:
  /// **'Semua data dan gambar tersimpan di perangkat ini saja. Lakukan backup rutin agar data tidak hilang jika HP atau komputer rusak.'**
  String get backupModeBody;

  /// No description provided for @backupStatSales.
  ///
  /// In id, this message translates to:
  /// **'Transaksi'**
  String get backupStatSales;

  /// No description provided for @backupStatProducts.
  ///
  /// In id, this message translates to:
  /// **'Produk'**
  String get backupStatProducts;

  /// No description provided for @backupStatSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran'**
  String get backupStatSize;

  /// No description provided for @backupLastNever.
  ///
  /// In id, this message translates to:
  /// **'Belum pernah backup'**
  String get backupLastNever;

  /// No description provided for @backupLastToday.
  ///
  /// In id, this message translates to:
  /// **'Backup terakhir hari ini'**
  String get backupLastToday;

  /// No description provided for @backupLastDays.
  ///
  /// In id, this message translates to:
  /// **'Backup terakhir {days} hari lalu'**
  String backupLastDays(int days);

  /// No description provided for @backupNow.
  ///
  /// In id, this message translates to:
  /// **'Backup sekarang'**
  String get backupNow;

  /// No description provided for @backupRestore.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get backupRestore;

  /// No description provided for @backupFileNote.
  ///
  /// In id, this message translates to:
  /// **'File backup berisi database dan semua gambar (.zip). Simpan di tempat aman karena isinya data toko Anda.'**
  String get backupFileNote;

  /// No description provided for @backupSavedTo.
  ///
  /// In id, this message translates to:
  /// **'Backup tersimpan di {path}'**
  String backupSavedTo(String path);

  /// No description provided for @backupShared.
  ///
  /// In id, this message translates to:
  /// **'Backup dibagikan.'**
  String get backupShared;

  /// No description provided for @backupDismissed.
  ///
  /// In id, this message translates to:
  /// **'Backup tidak dibagikan. Coba lagi dan pilih tujuan penyimpanan.'**
  String get backupDismissed;

  /// No description provided for @backupFailed.
  ///
  /// In id, this message translates to:
  /// **'Backup gagal. Pastikan ruang penyimpanan cukup lalu coba lagi.'**
  String get backupFailed;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan dari backup'**
  String get backupRestoreTitle;

  /// No description provided for @backupRestoreSummary.
  ///
  /// In id, this message translates to:
  /// **'{store} · {outlet} · perangkat {device}'**
  String backupRestoreSummary(String store, String outlet, String device);

  /// No description provided for @backupRestoreMade.
  ///
  /// In id, this message translates to:
  /// **'Dibuat {date} · {sales} transaksi · {products} produk'**
  String backupRestoreMade(String date, int sales, int products);

  /// No description provided for @backupRestoreWarning.
  ///
  /// In id, this message translates to:
  /// **'Semua data di perangkat ini akan diganti isi backup. Data saat ini dipindah ke folder \"sebelum-pulihkan\" di folder data, lalu aplikasi dimuat ulang dan Anda masuk lagi.'**
  String get backupRestoreWarning;

  /// No description provided for @backupRestoreConfirmLabel.
  ///
  /// In id, this message translates to:
  /// **'Ketik \"{store}\" untuk melanjutkan'**
  String backupRestoreConfirmLabel(String store);

  /// No description provided for @backupRestoreConfirm.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan & muat ulang'**
  String get backupRestoreConfirm;

  /// No description provided for @backupRestoreCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get backupRestoreCancel;

  /// No description provided for @backupInvalid.
  ///
  /// In id, this message translates to:
  /// **'Berkas ini bukan backup Lakuna yang utuh.'**
  String get backupInvalid;

  /// No description provided for @backupTooNew.
  ///
  /// In id, this message translates to:
  /// **'Backup ini dibuat versi Lakuna yang lebih baru. Perbarui aplikasi dulu.'**
  String get backupTooNew;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan gagal. Data perangkat ini tidak berubah.'**
  String get backupRestoreFailed;

  /// No description provided for @backupHostingTitle.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan versi hosting'**
  String get backupHostingTitle;

  /// No description provided for @backupHostingBody.
  ///
  /// In id, this message translates to:
  /// **'Sinkronkan semua cabang dan perangkat ke server toko Anda.'**
  String get backupHostingBody;

  /// No description provided for @backupHostingServer.
  ///
  /// In id, this message translates to:
  /// **'Alamat server'**
  String get backupHostingServer;

  /// No description provided for @backupHostingCode.
  ///
  /// In id, this message translates to:
  /// **'Kode aktivasi'**
  String get backupHostingCode;

  /// No description provided for @backupHostingConnect.
  ///
  /// In id, this message translates to:
  /// **'Hubungkan & unggah data'**
  String get backupHostingConnect;

  /// No description provided for @backupHostingSoon.
  ///
  /// In id, this message translates to:
  /// **'Tersedia di versi hosting (Fase 2).'**
  String get backupHostingSoon;

  /// No description provided for @startupErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Lakuna gagal dibuka'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorBody.
  ///
  /// In id, this message translates to:
  /// **'Database di perangkat ini tidak bisa dibuka. Data Anda tidak dihapus. Salin detail di bawah lalu hubungi dukungan.'**
  String get startupErrorBody;

  /// No description provided for @startupErrorPath.
  ///
  /// In id, this message translates to:
  /// **'Lokasi data: {path}'**
  String startupErrorPath(String path);

  /// No description provided for @startupErrorCopy.
  ///
  /// In id, this message translates to:
  /// **'Salin detail'**
  String get startupErrorCopy;

  /// No description provided for @homeRestoreFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan gagal'**
  String get homeRestoreFailedTitle;

  /// No description provided for @homeRestoreFailedBody.
  ///
  /// In id, this message translates to:
  /// **'Database dari backup tidak bisa dibuka, jadi data sebelumnya dikembalikan. Berkas backup yang gagal disimpan di folder pulihkan-gagal di lokasi data.'**
  String get homeRestoreFailedBody;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi, {name}'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingMidday.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang, {name}'**
  String homeGreetingMidday(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore, {name}'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingNight.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam, {name}'**
  String homeGreetingNight(String name);

  /// No description provided for @homeSalesTodayTitle.
  ///
  /// In id, this message translates to:
  /// **'Penjualan hari ini'**
  String get homeSalesTodayTitle;

  /// No description provided for @homeSalesTodayDetail.
  ///
  /// In id, this message translates to:
  /// **'{count} transaksi · rata-rata {average}'**
  String homeSalesTodayDetail(int count, String average);

  /// No description provided for @homeModulesLabel.
  ///
  /// In id, this message translates to:
  /// **'Modul'**
  String get homeModulesLabel;

  /// No description provided for @homeAttentionTitle.
  ///
  /// In id, this message translates to:
  /// **'Perlu perhatian'**
  String get homeAttentionTitle;

  /// No description provided for @homeAttentionLowStock.
  ///
  /// In id, this message translates to:
  /// **'{count} produk di bawah stok minimum'**
  String homeAttentionLowStock(int count);

  /// No description provided for @homeAttentionPendingQris.
  ///
  /// In id, this message translates to:
  /// **'{count} pembayaran QRIS menunggu konfirmasi'**
  String homeAttentionPendingQris(int count);

  /// No description provided for @homeAttentionBackupToday.
  ///
  /// In id, this message translates to:
  /// **'Backup terakhir hari ini {time}'**
  String homeAttentionBackupToday(String time);

  /// No description provided for @homeAttentionBackupYesterday.
  ///
  /// In id, this message translates to:
  /// **'Backup terakhir kemarin {time}'**
  String homeAttentionBackupYesterday(String time);

  /// No description provided for @homeAttentionBackupDays.
  ///
  /// In id, this message translates to:
  /// **'Backup terakhir {days} hari lalu'**
  String homeAttentionBackupDays(int days);

  /// No description provided for @homeAttentionBackupNever.
  ///
  /// In id, this message translates to:
  /// **'Data belum pernah di-backup'**
  String get homeAttentionBackupNever;

  /// No description provided for @homeAttentionView.
  ///
  /// In id, this message translates to:
  /// **'Lihat'**
  String get homeAttentionView;

  /// No description provided for @homeAttentionClear.
  ///
  /// In id, this message translates to:
  /// **'Semua beres, tidak ada yang perlu ditindak.'**
  String get homeAttentionClear;

  /// No description provided for @homeDeviceTitle.
  ///
  /// In id, this message translates to:
  /// **'Info perangkat'**
  String get homeDeviceTitle;

  /// No description provided for @guideTitle.
  ///
  /// In id, this message translates to:
  /// **'Panduan'**
  String get guideTitle;

  /// No description provided for @guideOffline.
  ///
  /// In id, this message translates to:
  /// **'Tersedia offline'**
  String get guideOffline;

  /// No description provided for @guideSearchLabel.
  ///
  /// In id, this message translates to:
  /// **'Cari panduan'**
  String get guideSearchLabel;

  /// No description provided for @guideSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari: cara retur, QRIS, backup…'**
  String get guideSearchHint;

  /// No description provided for @guideLanguageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa panduan'**
  String get guideLanguageLabel;

  /// No description provided for @guideContents.
  ///
  /// In id, this message translates to:
  /// **'Daftar isi'**
  String get guideContents;

  /// No description provided for @guideResults.
  ///
  /// In id, this message translates to:
  /// **'{count} hasil pencarian'**
  String guideResults(int count);

  /// No description provided for @guideNoResults.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada artikel yang cocok'**
  String get guideNoResults;

  /// No description provided for @guideLoadError.
  ///
  /// In id, this message translates to:
  /// **'Panduan gagal dimuat'**
  String get guideLoadError;

  /// No description provided for @guidePrevious.
  ///
  /// In id, this message translates to:
  /// **'Sebelumnya'**
  String get guidePrevious;

  /// No description provided for @guideNext.
  ///
  /// In id, this message translates to:
  /// **'Berikutnya'**
  String get guideNext;

  /// No description provided for @guideImageMissing.
  ///
  /// In id, this message translates to:
  /// **'Gambar belum tersedia'**
  String get guideImageMissing;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang Lakuna'**
  String get settingsSectionAbout;

  /// No description provided for @aboutTagline.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi kasir offline-first untuk UMKM, mode Retail dan F&B.'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get aboutVersion;

  /// No description provided for @aboutOpenGuide.
  ///
  /// In id, this message translates to:
  /// **'Buka Panduan'**
  String get aboutOpenGuide;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In id, this message translates to:
  /// **'Privasi data'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyLocal.
  ///
  /// In id, this message translates to:
  /// **'Semua data toko (produk, transaksi, pelanggan, staf, dan gambar) disimpan di perangkat ini. Lakuna tidak mengirim data ke pihak lain dan tidak memakai iklan atau pelacak.'**
  String get aboutPrivacyLocal;

  /// No description provided for @aboutPrivacyHosted.
  ///
  /// In id, this message translates to:
  /// **'Versi hosted (sinkronisasi ke server) belum tersedia. Kebijakan privasi akan diperbarui sebelum versi itu dirilis.'**
  String get aboutPrivacyHosted;

  /// No description provided for @aboutPrivacyBackup.
  ///
  /// In id, this message translates to:
  /// **'File backup berisi seluruh data toko. Simpan di tempat yang aman.'**
  String get aboutPrivacyBackup;

  /// No description provided for @aboutLicensesTitle.
  ///
  /// In id, this message translates to:
  /// **'Lisensi open source'**
  String get aboutLicensesTitle;

  /// No description provided for @aboutLicensesSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Lakuna dibangun dengan paket dan font open source berikut.'**
  String get aboutLicensesSubtitle;

  /// No description provided for @aboutLicensesShow.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan lisensi'**
  String get aboutLicensesShow;

  /// No description provided for @aboutLicensesError.
  ///
  /// In id, this message translates to:
  /// **'Daftar lisensi gagal dimuat.'**
  String get aboutLicensesError;

  /// No description provided for @aboutLicenseCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, other{{count} lisensi}}'**
  String aboutLicenseCount(int count);

  /// No description provided for @cashierCustomerWalkIn.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan umum'**
  String get cashierCustomerWalkIn;

  /// No description provided for @cashierCustomerPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih pelanggan'**
  String get cashierCustomerPick;

  /// No description provided for @cashierCustomerClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus pelanggan dari nota'**
  String get cashierCustomerClear;

  /// No description provided for @cashierCustomerSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari nama atau HP'**
  String get cashierCustomerSearch;

  /// No description provided for @cashierCustomerNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada pelanggan. Tambah lewat menu Pelanggan.'**
  String get cashierCustomerNone;

  /// No description provided for @cashierCustomerNoMatch.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada pelanggan yang cocok.'**
  String get cashierCustomerNoMatch;

  /// No description provided for @cashierCustomerLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Daftar pelanggan gagal dimuat.'**
  String get cashierCustomerLoadFailed;

  /// No description provided for @cashierCustomerRemaining.
  ///
  /// In id, this message translates to:
  /// **'Sisa limit {amount}'**
  String cashierCustomerRemaining(String amount);

  /// No description provided for @cashierCustomerOverdue.
  ///
  /// In id, this message translates to:
  /// **'Lewat tempo'**
  String get cashierCustomerOverdue;

  /// No description provided for @cashierPark.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get cashierPark;

  /// No description provided for @cashierParkTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan nota'**
  String get cashierParkTitle;

  /// No description provided for @cashierParkBody.
  ///
  /// In id, this message translates to:
  /// **'Nota disimpan tanpa pembayaran dan bisa dilanjutkan nanti dari Nota tersimpan. Stok baru berkurang saat dibayar.'**
  String get cashierParkBody;

  /// No description provided for @cashierParkFor.
  ///
  /// In id, this message translates to:
  /// **'Atas nama {name}'**
  String cashierParkFor(String name);

  /// No description provided for @cashierParkNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get cashierParkNote;

  /// No description provided for @cashierParkNoteHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Meja depan'**
  String get cashierParkNoteHint;

  /// No description provided for @cashierParkNoteTooLong.
  ///
  /// In id, this message translates to:
  /// **'Catatan maksimal {max} karakter.'**
  String cashierParkNoteTooLong(int max);

  /// No description provided for @cashierParkFailed.
  ///
  /// In id, this message translates to:
  /// **'Nota gagal disimpan. Coba lagi.'**
  String get cashierParkFailed;

  /// No description provided for @cashierParkedButton.
  ///
  /// In id, this message translates to:
  /// **'Nota tersimpan ({count})'**
  String cashierParkedButton(int count);

  /// No description provided for @cashierParkedTitle.
  ///
  /// In id, this message translates to:
  /// **'Nota tersimpan'**
  String get cashierParkedTitle;

  /// No description provided for @cashierParkedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada nota tersimpan.'**
  String get cashierParkedEmpty;

  /// No description provided for @cashierParkedNoName.
  ///
  /// In id, this message translates to:
  /// **'Tanpa nama'**
  String get cashierParkedNoName;

  /// No description provided for @cashierParkedMeta.
  ///
  /// In id, this message translates to:
  /// **'{count} item · disimpan {time} oleh {staff}'**
  String cashierParkedMeta(int count, String time, String staff);

  /// No description provided for @cashierParkedResume.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get cashierParkedResume;

  /// No description provided for @cashierParkedDelete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get cashierParkedDelete;

  /// No description provided for @cashierParkedCartBusy.
  ///
  /// In id, this message translates to:
  /// **'Simpan atau kosongkan keranjang dulu.'**
  String get cashierParkedCartBusy;

  /// No description provided for @cashierParkedLoadFailed.
  ///
  /// In id, this message translates to:
  /// **'Nota tersimpan gagal dimuat.'**
  String get cashierParkedLoadFailed;

  /// No description provided for @cashierParkedResumeFailed.
  ///
  /// In id, this message translates to:
  /// **'Nota tidak bisa dilanjutkan (mungkin sudah dibayar atau dihapus).'**
  String get cashierParkedResumeFailed;

  /// No description provided for @cashierParkedDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus nota tersimpan?'**
  String get cashierParkedDeleteTitle;

  /// No description provided for @cashierParkedDeleteBody.
  ///
  /// In id, this message translates to:
  /// **'{name} akan dihapus. Stok tidak berubah karena nota belum dibayar.'**
  String cashierParkedDeleteBody(String name);

  /// No description provided for @cashierParkedDeleteFailed.
  ///
  /// In id, this message translates to:
  /// **'Nota tersimpan gagal dihapus.'**
  String get cashierParkedDeleteFailed;

  /// No description provided for @cashierParkedClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get cashierParkedClose;

  /// No description provided for @cashierResumeDropped.
  ///
  /// In id, this message translates to:
  /// **'{count} barang dibuang karena produknya sudah dihapus.'**
  String cashierResumeDropped(int count);

  /// No description provided for @cashierResumedFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari nota tersimpan'**
  String get cashierResumedFrom;

  /// No description provided for @paymentErrorParked.
  ///
  /// In id, this message translates to:
  /// **'Nota tersimpan ini sudah dibayar atau dihapus di tempat lain. Selesaikan lagi untuk mencatatnya sebagai penjualan baru.'**
  String get paymentErrorParked;

  /// No description provided for @cashierResumeDiscountDropped.
  ///
  /// In id, this message translates to:
  /// **'Diskon nota tersimpan dilepas karena Anda tidak punya izin diskon.'**
  String get cashierResumeDiscountDropped;

  /// No description provided for @approvalDiscountResumed.
  ///
  /// In id, this message translates to:
  /// **'Diskon dari nota tersimpan'**
  String get approvalDiscountResumed;

  /// No description provided for @productsImport.
  ///
  /// In id, this message translates to:
  /// **'Import Excel'**
  String get productsImport;

  /// No description provided for @productImportTitle.
  ///
  /// In id, this message translates to:
  /// **'Import produk'**
  String get productImportTitle;

  /// No description provided for @productImportIntro.
  ///
  /// In id, this message translates to:
  /// **'Pilih berkas Excel (.xlsx) atau CSV, satu baris satu produk. Kolom: Nama dan Harga jual (wajib), Kategori, Jenis (barang/jasa/menu), Satuan, SKU, Barcode, Harga beli, Stok awal, Stok minimum. Judul kolom boleh Indonesia atau English.'**
  String get productImportIntro;

  /// No description provided for @productImportMissingColumns.
  ///
  /// In id, this message translates to:
  /// **'Kolom Nama atau Harga jual tidak ditemukan di baris judul.'**
  String get productImportMissingColumns;

  /// No description provided for @productImportEmpty.
  ///
  /// In id, this message translates to:
  /// **'Berkas tidak berisi baris produk.'**
  String get productImportEmpty;

  /// No description provided for @productImportSkipNote.
  ///
  /// In id, this message translates to:
  /// **'Hanya menambah produk baru. Produk yang nama, SKU, atau barcode-nya sudah ada dilewati; ubah lewat form produk.'**
  String get productImportSkipNote;

  /// No description provided for @productImportReasonPrice.
  ///
  /// In id, this message translates to:
  /// **'harga jual kosong atau bukan rupiah bulat'**
  String get productImportReasonPrice;

  /// No description provided for @productImportReasonCost.
  ///
  /// In id, this message translates to:
  /// **'harga beli bukan rupiah bulat'**
  String get productImportReasonCost;

  /// No description provided for @productImportReasonStock.
  ///
  /// In id, this message translates to:
  /// **'stok bukan angka'**
  String get productImportReasonStock;

  /// No description provided for @productImportReasonKind.
  ///
  /// In id, this message translates to:
  /// **'jenis bukan barang, jasa, atau menu'**
  String get productImportReasonKind;

  /// No description provided for @productImportReasonCode.
  ///
  /// In id, this message translates to:
  /// **'SKU atau barcode dobel di berkas'**
  String get productImportReasonCode;

  /// No description provided for @productImportReasonName.
  ///
  /// In id, this message translates to:
  /// **'nama dobel di berkas'**
  String get productImportReasonName;

  /// No description provided for @productImportRun.
  ///
  /// In id, this message translates to:
  /// **'Import {count} produk'**
  String productImportRun(int count);

  /// No description provided for @productImportCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get productImportCancel;

  /// No description provided for @productImportDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai: {created} produk baru, {skipped} dilewati karena sudah ada.'**
  String productImportDone(int created, int skipped);

  /// No description provided for @productImportSkippedLines.
  ///
  /// In id, this message translates to:
  /// **'Baris dilewati: {lines}'**
  String productImportSkippedLines(String lines);

  /// No description provided for @diningDiscountHint.
  ///
  /// In id, this message translates to:
  /// **'Untuk seluruh bill. Service dan PB1 dihitung setelah diskon.'**
  String get diningDiscountHint;

  /// No description provided for @diningDiscountBlocksPay.
  ///
  /// In id, this message translates to:
  /// **'Diskon menghabiskan total bill. Ubah atau hapus diskon sebelum membayar.'**
  String get diningDiscountBlocksPay;

  /// No description provided for @cashierCustomerNew.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan baru'**
  String get cashierCustomerNew;

  /// No description provided for @productTierGroupMissing.
  ///
  /// In id, this message translates to:
  /// **'Grup pelanggan pada harga grosir sudah dihapus. Pilih ulang grupnya lalu simpan.'**
  String get productTierGroupMissing;

  /// No description provided for @groupErrHasPrices.
  ///
  /// In id, this message translates to:
  /// **'Grup masih dipakai di harga grosir produk; ubah harga grosirnya dulu.'**
  String get groupErrHasPrices;

  /// No description provided for @cashierGroupTierNote.
  ///
  /// In id, this message translates to:
  /// **'harga grup ≥ {qty}'**
  String cashierGroupTierNote(String qty);

  /// No description provided for @productArchive.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan produk'**
  String get productArchive;

  /// No description provided for @productArchiveHint.
  ///
  /// In id, this message translates to:
  /// **'Produk yang tidak dijual lagi. Riwayat penjualan dan pembelian tetap tersimpan, dan produk bisa dipulihkan.'**
  String get productArchiveHint;

  /// No description provided for @productArchiveTitle.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan {name}?'**
  String productArchiveTitle(String name);

  /// No description provided for @productArchiveBody.
  ///
  /// In id, this message translates to:
  /// **'Produk hilang dari Kasir, daftar produk, stok, dan pembelian. Riwayat penjualan dan pembelian tetap tersimpan. Produk bisa dipulihkan lewat tombol Diarsipkan di daftar produk.'**
  String get productArchiveBody;

  /// No description provided for @productArchiveStockWarning.
  ///
  /// In id, this message translates to:
  /// **'Stok tersisa {stock} {unit} tidak dihitung lagi di stok dan nilai stok.'**
  String productArchiveStockWarning(String stock, String unit);

  /// No description provided for @productArchiveConfirm.
  ///
  /// In id, this message translates to:
  /// **'Arsipkan'**
  String get productArchiveConfirm;

  /// No description provided for @productsArchived.
  ///
  /// In id, this message translates to:
  /// **'Diarsipkan ({count})'**
  String productsArchived(int count);

  /// No description provided for @productsArchivedTitle.
  ///
  /// In id, this message translates to:
  /// **'Produk diarsipkan'**
  String get productsArchivedTitle;

  /// No description provided for @productsArchivedEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada produk yang diarsipkan.'**
  String get productsArchivedEmpty;

  /// No description provided for @productsArchivedStock.
  ///
  /// In id, this message translates to:
  /// **'Stok {stock} {unit}'**
  String productsArchivedStock(String stock, String unit);

  /// No description provided for @productsRestore.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan'**
  String get productsRestore;

  /// No description provided for @productsRestored.
  ///
  /// In id, this message translates to:
  /// **'{name} dipulihkan ke daftar produk.'**
  String productsRestored(String name);

  /// No description provided for @productsRestoreTaken.
  ///
  /// In id, this message translates to:
  /// **'Barcode atau SKU produk ini sudah dipakai {name}. Ubah kodenya di {name} dulu, lalu pulihkan lagi.'**
  String productsRestoreTaken(String name);

  /// No description provided for @productsArchivedClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get productsArchivedClose;

  /// No description provided for @productsLabels.
  ///
  /// In id, this message translates to:
  /// **'Cetak label'**
  String get productsLabels;

  /// No description provided for @labelsTitle.
  ///
  /// In id, this message translates to:
  /// **'Cetak label barcode'**
  String get labelsTitle;

  /// No description provided for @labelsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih produk dan jumlah label. Barcode dipakai bila ada, selain itu SKU.'**
  String get labelsSubtitle;

  /// No description provided for @labelsBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get labelsBack;

  /// No description provided for @labelsSearch.
  ///
  /// In id, this message translates to:
  /// **'Cari nama, SKU, atau barcode'**
  String get labelsSearch;

  /// No description provided for @labelsSelectedOnly.
  ///
  /// In id, this message translates to:
  /// **'Hanya yang dipilih ({count})'**
  String labelsSelectedOnly(int count);

  /// No description provided for @labelsFillStock.
  ///
  /// In id, this message translates to:
  /// **'Isi sesuai stok'**
  String get labelsFillStock;

  /// No description provided for @labelsNoCode.
  ///
  /// In id, this message translates to:
  /// **'Tanpa barcode/SKU'**
  String get labelsNoCode;

  /// No description provided for @labelsBadCode.
  ///
  /// In id, this message translates to:
  /// **'Kode tidak bisa dicetak'**
  String get labelsBadCode;

  /// No description provided for @labelsEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada produk yang cocok.'**
  String get labelsEmpty;

  /// No description provided for @labelsLess.
  ///
  /// In id, this message translates to:
  /// **'Kurangi'**
  String get labelsLess;

  /// No description provided for @labelsMore.
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get labelsMore;

  /// No description provided for @labelsSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan label'**
  String get labelsSettings;

  /// No description provided for @labelsPaper.
  ///
  /// In id, this message translates to:
  /// **'Kertas'**
  String get labelsPaper;

  /// No description provided for @labelsPaperA4.
  ///
  /// In id, this message translates to:
  /// **'A4 · 24 label (3 × 8)'**
  String get labelsPaperA4;

  /// No description provided for @labelsPaperA4Hint.
  ///
  /// In id, this message translates to:
  /// **'Kertas stiker A4, 70 × 37 mm per label.'**
  String get labelsPaperA4Hint;

  /// No description provided for @labelsPaperRoll.
  ///
  /// In id, this message translates to:
  /// **'Label {size}'**
  String labelsPaperRoll(String size);

  /// No description provided for @labelsPaperRollHint.
  ///
  /// In id, this message translates to:
  /// **'Printer label, satu label per halaman.'**
  String get labelsPaperRollHint;

  /// No description provided for @labelsSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati label pertama'**
  String get labelsSkip;

  /// No description provided for @labelsSkipHint.
  ///
  /// In id, this message translates to:
  /// **'Untuk lembar yang sebagian sudah terpakai (0–23).'**
  String get labelsSkipHint;

  /// No description provided for @labelsShowPrice.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan harga'**
  String get labelsShowPrice;

  /// No description provided for @labelsPreview.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau'**
  String get labelsPreview;

  /// No description provided for @labelsPreviewEmpty.
  ///
  /// In id, this message translates to:
  /// **'Pilih produk untuk melihat pratinjau.'**
  String get labelsPreviewEmpty;

  /// No description provided for @labelsTotal.
  ///
  /// In id, this message translates to:
  /// **'{labels} label · {pages} halaman'**
  String labelsTotal(int labels, int pages);

  /// No description provided for @labelsOverLimit.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} label per cetak. Kurangi jumlahnya.'**
  String labelsOverLimit(int max);

  /// No description provided for @labelsPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak'**
  String get labelsPrint;

  /// No description provided for @labelsSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan PDF'**
  String get labelsSave;

  /// No description provided for @labelsSaved.
  ///
  /// In id, this message translates to:
  /// **'PDF disimpan di {path}'**
  String labelsSaved(String path);

  /// No description provided for @productPhotoPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih foto'**
  String get productPhotoPick;

  /// No description provided for @productPhotoChange.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get productPhotoChange;

  /// No description provided for @productPhotoTake.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto'**
  String get productPhotoTake;

  /// No description provided for @productPhotoRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get productPhotoRemove;

  /// No description provided for @productPhotoHint.
  ///
  /// In id, this message translates to:
  /// **'PNG, JPG, atau WebP, maks. 20 MB; dikecilkan otomatis. Tersimpan saat Simpan.'**
  String get productPhotoHint;

  /// No description provided for @productPhotoUnsupported.
  ///
  /// In id, this message translates to:
  /// **'Berkas bukan gambar PNG, JPG, atau WebP.'**
  String get productPhotoUnsupported;

  /// No description provided for @productPhotoTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Foto lebih dari 20 MB. Pilih foto yang lebih kecil.'**
  String get productPhotoTooLarge;

  /// No description provided for @productPhotoNotSaved.
  ///
  /// In id, this message translates to:
  /// **'Produk tersimpan, tetapi foto gagal disimpan. Coba Simpan lagi.'**
  String get productPhotoNotSaved;

  /// No description provided for @productPhotoUnreadable.
  ///
  /// In id, this message translates to:
  /// **'Foto tidak bisa dibuka. Periksa izin kamera atau pilih berkas lain.'**
  String get productPhotoUnreadable;

  /// No description provided for @recapTitle.
  ///
  /// In id, this message translates to:
  /// **'REKAP SESI KASIR'**
  String get recapTitle;

  /// No description provided for @recapDevice.
  ///
  /// In id, this message translates to:
  /// **'Perangkat'**
  String get recapDevice;

  /// No description provided for @recapOpened.
  ///
  /// In id, this message translates to:
  /// **'Dibuka'**
  String get recapOpened;

  /// No description provided for @recapOpenedBy.
  ///
  /// In id, this message translates to:
  /// **'Dibuka oleh'**
  String get recapOpenedBy;

  /// No description provided for @recapClosed.
  ///
  /// In id, this message translates to:
  /// **'Ditutup'**
  String get recapClosed;

  /// No description provided for @recapClosedBy.
  ///
  /// In id, this message translates to:
  /// **'Ditutup oleh'**
  String get recapClosedBy;

  /// No description provided for @recapCash.
  ///
  /// In id, this message translates to:
  /// **'Tunai'**
  String get recapCash;

  /// No description provided for @recapNonCash.
  ///
  /// In id, this message translates to:
  /// **'Non-tunai'**
  String get recapNonCash;

  /// No description provided for @recapCredit.
  ///
  /// In id, this message translates to:
  /// **'Kredit (piutang)'**
  String get recapCredit;

  /// No description provided for @recapOpening.
  ///
  /// In id, this message translates to:
  /// **'Saldo awal'**
  String get recapOpening;

  /// No description provided for @recapInflow.
  ///
  /// In id, this message translates to:
  /// **'Uang masuk'**
  String get recapInflow;

  /// No description provided for @recapOutflow.
  ///
  /// In id, this message translates to:
  /// **'Uang keluar'**
  String get recapOutflow;

  /// No description provided for @recapNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan: {note}'**
  String recapNote(String note);

  /// No description provided for @cashCloseAndPrint.
  ///
  /// In id, this message translates to:
  /// **'Tutup sesi & cetak rekap'**
  String get cashCloseAndPrint;

  /// No description provided for @cashRecapPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak rekap'**
  String get cashRecapPrint;

  /// No description provided for @cashRecapPrinted.
  ///
  /// In id, this message translates to:
  /// **'Rekap terkirim ke printer.'**
  String get cashRecapPrinted;

  /// No description provided for @cashRecapShareError.
  ///
  /// In id, this message translates to:
  /// **'PDF rekap gagal dibuat.'**
  String get cashRecapShareError;

  /// No description provided for @receiptLogo.
  ///
  /// In id, this message translates to:
  /// **'Logo struk'**
  String get receiptLogo;

  /// No description provided for @receiptLogoHint.
  ///
  /// In id, this message translates to:
  /// **'PNG atau JPG sampai 1 MB. Logo hitam putih dengan latar putih paling jelas di printer thermal.'**
  String get receiptLogoHint;

  /// No description provided for @receiptLogoPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih logo'**
  String get receiptLogoPick;

  /// No description provided for @receiptLogoChange.
  ///
  /// In id, this message translates to:
  /// **'Ganti logo'**
  String get receiptLogoChange;

  /// No description provided for @receiptLogoRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus logo'**
  String get receiptLogoRemove;

  /// No description provided for @receiptLogoMissing.
  ///
  /// In id, this message translates to:
  /// **'Berkas logo belum ada di perangkat ini.'**
  String get receiptLogoMissing;

  /// No description provided for @receiptShowLogo.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan logo di struk'**
  String get receiptShowLogo;

  /// No description provided for @receiptLogoUnsupported.
  ///
  /// In id, this message translates to:
  /// **'Logo harus PNG atau JPG.'**
  String get receiptLogoUnsupported;

  /// No description provided for @receiptLogoTooLarge.
  ///
  /// In id, this message translates to:
  /// **'Logo lebih dari 1 MB. Pilih berkas yang lebih kecil.'**
  String get receiptLogoTooLarge;

  /// No description provided for @diningMerge.
  ///
  /// In id, this message translates to:
  /// **'Gabung meja'**
  String get diningMerge;

  /// No description provided for @diningMergeTitle.
  ///
  /// In id, this message translates to:
  /// **'Gabungkan ke {label}'**
  String diningMergeTitle(String label);

  /// No description provided for @diningMergeHint.
  ///
  /// In id, this message translates to:
  /// **'Item, tiket dapur, dan tamu meja yang dipilih pindah ke bill ini. Meja itu menjadi kosong.'**
  String get diningMergeHint;

  /// No description provided for @diningMergeNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada meja lain yang bisa digabung. Meja harus berisi pesanan dan Boleh digabung dengan meja sebelah (Atur denah atau Data master › Meja & area), tanpa split, diskon nota, atau pelanggan berbeda.'**
  String get diningMergeNone;

  /// No description provided for @diningMergeOption.
  ///
  /// In id, this message translates to:
  /// **'{label} · {total}'**
  String diningMergeOption(String label, String total);

  /// No description provided for @diningErrorMergeSplit.
  ///
  /// In id, this message translates to:
  /// **'Bill sedang di-split atau sudah ada pembayaran bagian. Batalkan split dulu.'**
  String get diningErrorMergeSplit;

  /// No description provided for @diningErrorMergeDiscount.
  ///
  /// In id, this message translates to:
  /// **'Bill meja yang digabung punya diskon nota. Hapus diskonnya dulu.'**
  String get diningErrorMergeDiscount;

  /// No description provided for @diningErrorMergeGuests.
  ///
  /// In id, this message translates to:
  /// **'Jumlah tamu gabungan lebih dari 99.'**
  String get diningErrorMergeGuests;

  /// No description provided for @diningErrorMergeNotAllowed.
  ///
  /// In id, this message translates to:
  /// **'Meja ini tidak bisa digabung.'**
  String get diningErrorMergeNotAllowed;

  /// No description provided for @diningSetupCanMergeHint.
  ///
  /// In id, this message translates to:
  /// **'Bill meja ini bisa digabung dengan meja lain lewat Gabung meja.'**
  String get diningSetupCanMergeHint;

  /// No description provided for @diningSetupCanMerge.
  ///
  /// In id, this message translates to:
  /// **'Boleh digabung'**
  String get diningSetupCanMerge;

  /// No description provided for @kitchenPrinterTitle.
  ///
  /// In id, this message translates to:
  /// **'Printer dapur'**
  String get kitchenPrinterTitle;

  /// No description provided for @kitchenPrinterSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tiket dapur dicetak otomatis di sini saat Kirim ke dapur. Disimpan di perangkat ini saja.'**
  String get kitchenPrinterSubtitle;

  /// No description provided for @kitchenPrinterSame.
  ///
  /// In id, this message translates to:
  /// **'Sama dengan printer struk'**
  String get kitchenPrinterSame;

  /// No description provided for @kitchenPrinterSameNote.
  ///
  /// In id, this message translates to:
  /// **'Tiket dapur dicetak lewat tombol Cetak tiket ke printer struk perangkat ini.'**
  String get kitchenPrinterSameNote;

  /// No description provided for @kitchenPrinterForget.
  ///
  /// In id, this message translates to:
  /// **'Lupakan printer dapur'**
  String get kitchenPrinterForget;

  /// No description provided for @kitchenPaperWidth.
  ///
  /// In id, this message translates to:
  /// **'Lebar kertas tiket'**
  String get kitchenPaperWidth;

  /// No description provided for @kitchenPrinterTest.
  ///
  /// In id, this message translates to:
  /// **'Tes cetak tiket'**
  String get kitchenPrinterTest;

  /// No description provided for @kitchenPrinterTestSent.
  ///
  /// In id, this message translates to:
  /// **'Tiket contoh terkirim ke printer dapur.'**
  String get kitchenPrinterTestSent;

  /// No description provided for @ticketPrintingKitchen.
  ///
  /// In id, this message translates to:
  /// **'Mencetak tiket di printer dapur…'**
  String get ticketPrintingKitchen;

  /// No description provided for @ticketPrintedKitchen.
  ///
  /// In id, this message translates to:
  /// **'Tiket dicetak di printer dapur.'**
  String get ticketPrintedKitchen;

  /// No description provided for @ticketReprint.
  ///
  /// In id, this message translates to:
  /// **'Cetak ulang'**
  String get ticketReprint;

  /// No description provided for @diningCustomerPick.
  ///
  /// In id, this message translates to:
  /// **'Pilih pelanggan'**
  String get diningCustomerPick;

  /// No description provided for @diningCustomerChange.
  ///
  /// In id, this message translates to:
  /// **'Ganti'**
  String get diningCustomerChange;

  /// No description provided for @diningCustomerClear.
  ///
  /// In id, this message translates to:
  /// **'Hapus pelanggan'**
  String get diningCustomerClear;

  /// No description provided for @diningCustomerLabel.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan: {name}'**
  String diningCustomerLabel(String name);

  /// No description provided for @diningCustomerGroupLabel.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan: {name} · {group}'**
  String diningCustomerGroupLabel(String name, String group);

  /// No description provided for @diningCustomerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan {label}'**
  String diningCustomerTitle(String label);

  /// No description provided for @diningCustomerHint.
  ///
  /// In id, this message translates to:
  /// **'Harga grup pelanggan berlaku untuk semua item bill.'**
  String get diningCustomerHint;

  /// No description provided for @diningErrorCustomerBlocked.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan tidak bisa diubah selama bill di-split.'**
  String get diningErrorCustomerBlocked;

  /// No description provided for @diningErrorCustomerNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pelanggan tidak ditemukan atau sudah dihapus.'**
  String get diningErrorCustomerNotFound;

  /// No description provided for @diningErrorMergeCustomer.
  ///
  /// In id, this message translates to:
  /// **'Kedua meja punya pelanggan berbeda.'**
  String get diningErrorMergeCustomer;

  /// No description provided for @cashierErrorBillCustomerMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kredit harus atas nama pelanggan bill. Ganti pelanggan di panel meja.'**
  String get cashierErrorBillCustomerMismatch;

  /// No description provided for @diningServedWithoutTicket.
  ///
  /// In id, this message translates to:
  /// **'{count} item tanpa tiket dapur langsung ditandai disajikan.'**
  String diningServedWithoutTicket(int count);

  /// No description provided for @productKitchenTitle.
  ///
  /// In id, this message translates to:
  /// **'Dapur'**
  String get productKitchenTitle;

  /// No description provided for @productSendToKitchen.
  ///
  /// In id, this message translates to:
  /// **'Kirim ke tiket dapur'**
  String get productSendToKitchen;

  /// No description provided for @productSendToKitchenHint.
  ///
  /// In id, this message translates to:
  /// **'Mati untuk menu yang tidak dimasak (mis. air botol): item langsung disajikan tanpa tiket dapur.'**
  String get productSendToKitchenHint;

  /// No description provided for @productAllowNote.
  ///
  /// In id, this message translates to:
  /// **'Bisa catatan bebas'**
  String get productAllowNote;

  /// No description provided for @productAllowNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Mati bila menu tidak bisa diubah; catatan dapur diabaikan.'**
  String get productAllowNoteHint;

  /// No description provided for @diningNoteNotAllowed.
  ///
  /// In id, this message translates to:
  /// **'Catatan disimpan untuk menu berikutnya.'**
  String get diningNoteNotAllowed;

  /// No description provided for @debtVoidAction.
  ///
  /// In id, this message translates to:
  /// **'Batalkan pembayaran'**
  String get debtVoidAction;

  /// No description provided for @debtVoidTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan {number}?'**
  String debtVoidTitle(String number);

  /// No description provided for @debtVoidBodyCustomer.
  ///
  /// In id, this message translates to:
  /// **'Alokasi ke nota dihapus sehingga sisa piutang kembali seperti sebelum pembayaran. Pembayaran tetap tercatat dengan tanda Batal; catat ulang bila perlu.'**
  String get debtVoidBodyCustomer;

  /// No description provided for @debtVoidBodySupplier.
  ///
  /// In id, this message translates to:
  /// **'Alokasi ke pembelian dihapus sehingga sisa hutang kembali seperti sebelum pembayaran. Pembayaran tetap tercatat dengan tanda Batal; catat ulang bila perlu.'**
  String get debtVoidBodySupplier;

  /// No description provided for @debtVoidReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan batal'**
  String get debtVoidReason;

  /// No description provided for @debtVoidReasonHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Salah nominal, akan dicatat ulang'**
  String get debtVoidReasonHint;

  /// No description provided for @debtVoidErrReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan wajib diisi, maksimal {max} karakter.'**
  String debtVoidErrReason(int max);

  /// No description provided for @debtVoidDrawerOut.
  ///
  /// In id, this message translates to:
  /// **'Uang {amount} dikeluarkan dari laci di sesi kasir yang sedang buka.'**
  String debtVoidDrawerOut(String amount);

  /// No description provided for @debtVoidDrawerIn.
  ///
  /// In id, this message translates to:
  /// **'Uang {amount} dikembalikan ke laci di sesi kasir yang sedang buka.'**
  String debtVoidDrawerIn(String amount);

  /// No description provided for @debtVoidBack.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get debtVoidBack;

  /// No description provided for @debtVoidConfirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, batalkan'**
  String get debtVoidConfirm;

  /// No description provided for @debtVoided.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get debtVoided;

  /// No description provided for @debtVoidedInfo.
  ///
  /// In id, this message translates to:
  /// **'Batal: {reason}'**
  String debtVoidedInfo(String reason);

  /// No description provided for @debtErrAlreadyVoided.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran ini sudah dibatalkan.'**
  String get debtErrAlreadyVoided;

  /// No description provided for @debtErrNoSession.
  ///
  /// In id, this message translates to:
  /// **'Buka sesi kasir dulu: uang laci perlu dijurnal balik.'**
  String get debtErrNoSession;

  /// No description provided for @kuitansiVoidStamp.
  ///
  /// In id, this message translates to:
  /// **'BATAL'**
  String get kuitansiVoidStamp;

  /// No description provided for @kuitansiVoidReason.
  ///
  /// In id, this message translates to:
  /// **'Alasan batal'**
  String get kuitansiVoidReason;

  /// No description provided for @reportsSourceDebtPaymentVoid.
  ///
  /// In id, this message translates to:
  /// **'Batal bayar piutang'**
  String get reportsSourceDebtPaymentVoid;

  /// No description provided for @reportsSourceSupplierPaymentVoid.
  ///
  /// In id, this message translates to:
  /// **'Batal bayar hutang'**
  String get reportsSourceSupplierPaymentVoid;

  /// No description provided for @cashSourceDebtPaymentVoid.
  ///
  /// In id, this message translates to:
  /// **'Batal bayar piutang'**
  String get cashSourceDebtPaymentVoid;

  /// No description provided for @cashSourceSupplierPaymentVoid.
  ///
  /// In id, this message translates to:
  /// **'Batal bayar hutang'**
  String get cashSourceSupplierPaymentVoid;

  /// No description provided for @debtErrNotFound.
  ///
  /// In id, this message translates to:
  /// **'Pembayaran tidak ditemukan atau pelanggan/supplier-nya sudah dihapus.'**
  String get debtErrNotFound;

  /// No description provided for @suppliersImport.
  ///
  /// In id, this message translates to:
  /// **'Import Excel'**
  String get suppliersImport;

  /// No description provided for @supplierImportTitle.
  ///
  /// In id, this message translates to:
  /// **'Import supplier'**
  String get supplierImportTitle;

  /// No description provided for @supplierImportIntro.
  ///
  /// In id, this message translates to:
  /// **'Pilih berkas Excel (.xlsx) atau CSV. Kolom: Nama (wajib), Kontak, Telepon, Kategori, Tempo (hari), Alamat, Catatan. Judul kolom boleh Indonesia atau English.'**
  String get supplierImportIntro;

  /// No description provided for @supplierImportUpdateNote.
  ///
  /// In id, this message translates to:
  /// **'Nama supplier yang sudah terdaftar memperbarui supplier itu (kolom kosong tidak mengubah data lama). Supplier baru tanpa tempo memakai {days} hari.'**
  String supplierImportUpdateNote(int days);

  /// No description provided for @supplierImportEmpty.
  ///
  /// In id, this message translates to:
  /// **'Berkas tidak berisi baris supplier.'**
  String get supplierImportEmpty;

  /// No description provided for @supplierImportReasonPhone.
  ///
  /// In id, this message translates to:
  /// **'nomor telepon tidak sah'**
  String get supplierImportReasonPhone;

  /// No description provided for @supplierImportReasonTerm.
  ///
  /// In id, this message translates to:
  /// **'tempo bukan 0–365 hari'**
  String get supplierImportReasonTerm;

  /// No description provided for @supplierImportReasonDuplicate.
  ///
  /// In id, this message translates to:
  /// **'nama dobel di berkas'**
  String get supplierImportReasonDuplicate;

  /// No description provided for @supplierImportRun.
  ///
  /// In id, this message translates to:
  /// **'Import {count} supplier'**
  String supplierImportRun(int count);

  /// No description provided for @supplierImportDone.
  ///
  /// In id, this message translates to:
  /// **'Selesai: {created} supplier baru, {updated} diperbarui, {skipped} baris dilewati.'**
  String supplierImportDone(int created, int updated, int skipped);

  /// No description provided for @onboardingRestoreHint.
  ///
  /// In id, this message translates to:
  /// **'Pindah perangkat atau HP rusak? Pasang backup toko Anda di sini tanpa membuat toko baru.'**
  String get onboardingRestoreHint;

  /// No description provided for @onboardingRestoreAction.
  ///
  /// In id, this message translates to:
  /// **'Pulihkan dari backup'**
  String get onboardingRestoreAction;

  /// No description provided for @setupRestoreIntro.
  ///
  /// In id, this message translates to:
  /// **'Pilih berkas backup Lakuna (.zip) yang dibuat di Pengaturan › Data & backup perangkat lama.'**
  String get setupRestoreIntro;

  /// No description provided for @setupRestorePick.
  ///
  /// In id, this message translates to:
  /// **'Pilih berkas backup'**
  String get setupRestorePick;

  /// No description provided for @setupRestoreWarning.
  ///
  /// In id, this message translates to:
  /// **'Data backup dipasang di perangkat ini, lalu aplikasi dimuat ulang dan Anda masuk dengan PIN dari backup. Jangan memakai backup yang sama di dua perangkat sekaligus.'**
  String get setupRestoreWarning;

  /// No description provided for @setupRestoreAlreadySetUp.
  ///
  /// In id, this message translates to:
  /// **'Toko sudah dibuat di perangkat ini. Pulihkan lewat Pengaturan › Data & backup.'**
  String get setupRestoreAlreadySetUp;

  /// No description provided for @setupRestoreReopen.
  ///
  /// In id, this message translates to:
  /// **'Backup siap dipasang. Tutup lalu buka lagi aplikasi untuk menyelesaikan pemulihan.'**
  String get setupRestoreReopen;

  /// No description provided for @importTemplateDownload.
  ///
  /// In id, this message translates to:
  /// **'Unduh templat'**
  String get importTemplateDownload;

  /// No description provided for @importTemplateSaved.
  ///
  /// In id, this message translates to:
  /// **'Templat disimpan di {path}'**
  String importTemplateSaved(String path);

  /// No description provided for @importTemplateFailed.
  ///
  /// In id, this message translates to:
  /// **'Templat gagal disimpan. Coba lagi.'**
  String get importTemplateFailed;

  /// No description provided for @importReasonSample.
  ///
  /// In id, this message translates to:
  /// **'baris contoh dari templat, ganti atau hapus'**
  String get importReasonSample;

  /// No description provided for @stockPrintTitle.
  ///
  /// In id, this message translates to:
  /// **'Daftar stok · {location}'**
  String stockPrintTitle(String location);

  /// No description provided for @stockPrintSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{outlet} · dicetak {time} · {staff}'**
  String stockPrintSubtitle(String outlet, String time, String staff);

  /// No description provided for @stockPrintColCode.
  ///
  /// In id, this message translates to:
  /// **'SKU / Barcode'**
  String get stockPrintColCode;

  /// No description provided for @stockPrintColCounted.
  ///
  /// In id, this message translates to:
  /// **'Fisik'**
  String get stockPrintColCounted;

  /// No description provided for @stockPrintCounts.
  ///
  /// In id, this message translates to:
  /// **'{items} item · {below} di bawah minimum · {minus} stok minus'**
  String stockPrintCounts(int items, int below, int minus);

  /// No description provided for @stockPrintNote.
  ///
  /// In id, this message translates to:
  /// **'Tulis hasil hitung di kolom Fisik, lalu catat selisihnya di menu Stok, tab Penyesuaian.'**
  String get stockPrintNote;

  /// No description provided for @stockPrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak stok'**
  String get stockPrint;

  /// No description provided for @stockPrintSaved.
  ///
  /// In id, this message translates to:
  /// **'Daftar stok disimpan di {path}'**
  String stockPrintSaved(String path);

  /// No description provided for @stockPrintFailed.
  ///
  /// In id, this message translates to:
  /// **'Daftar stok gagal dibuat. Coba lagi.'**
  String get stockPrintFailed;

  /// No description provided for @stockRestock.
  ///
  /// In id, this message translates to:
  /// **'Buat pembelian'**
  String get stockRestock;

  /// No description provided for @purchaseRestockNote.
  ///
  /// In id, this message translates to:
  /// **'Diisi dari stok minimum {location}: {count} barang. Periksa jumlah dan harga sebelum menyimpan.'**
  String purchaseRestockNote(String location, int count);

  /// No description provided for @purchaseRestockSkipped.
  ///
  /// In id, this message translates to:
  /// **'{count} barang dilewati karena tidak bisa dibeli lagi (diarsip atau bukan barang).'**
  String purchaseRestockSkipped(int count);

  /// No description provided for @purchaseInvoicePhoto.
  ///
  /// In id, this message translates to:
  /// **'Foto faktur'**
  String get purchaseInvoicePhoto;

  /// No description provided for @purchaseInvoicePhotoPick.
  ///
  /// In id, this message translates to:
  /// **'Lampirkan foto faktur'**
  String get purchaseInvoicePhotoPick;

  /// No description provided for @purchaseInvoicePhotoCamera.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto faktur'**
  String get purchaseInvoicePhotoCamera;

  /// No description provided for @purchaseInvoicePhotoReplace.
  ///
  /// In id, this message translates to:
  /// **'Ganti foto'**
  String get purchaseInvoicePhotoReplace;

  /// No description provided for @purchaseInvoicePhotoRemove.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto'**
  String get purchaseInvoicePhotoRemove;

  /// No description provided for @purchaseInvoicePhotoView.
  ///
  /// In id, this message translates to:
  /// **'Lihat foto faktur'**
  String get purchaseInvoicePhotoView;

  /// No description provided for @purchaseInvoicePhotoNone.
  ///
  /// In id, this message translates to:
  /// **'Belum ada foto faktur.'**
  String get purchaseInvoicePhotoNone;

  /// No description provided for @purchaseInvoicePhotoMissing.
  ///
  /// In id, this message translates to:
  /// **'Foto faktur belum ada di perangkat ini.'**
  String get purchaseInvoicePhotoMissing;

  /// No description provided for @purchaseInvoicePhotoInvalid.
  ///
  /// In id, this message translates to:
  /// **'Foto faktur harus gambar PNG/JPEG/WebP, maksimal 20 MB.'**
  String get purchaseInvoicePhotoInvalid;

  /// No description provided for @purchaseInvoicePhotoFailed.
  ///
  /// In id, this message translates to:
  /// **'Foto faktur gagal disimpan. Periksa izin kamera atau coba berkas lain.'**
  String get purchaseInvoicePhotoFailed;

  /// No description provided for @purchaseInvoicePhotoRemoveTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus foto faktur?'**
  String get purchaseInvoicePhotoRemoveTitle;

  /// No description provided for @purchaseInvoicePhotoRemoveBody.
  ///
  /// In id, this message translates to:
  /// **'Stok, harga pokok, dan hutang tidak berubah.'**
  String get purchaseInvoicePhotoRemoveBody;

  /// No description provided for @purchaseInvoicePhotoCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get purchaseInvoicePhotoCancel;

  /// No description provided for @purchaseInvoicePhotoClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get purchaseInvoicePhotoClose;

  /// No description provided for @purchasePrint.
  ///
  /// In id, this message translates to:
  /// **'Cetak / bagikan PDF'**
  String get purchasePrint;

  /// No description provided for @purchasePrintHint.
  ///
  /// In id, this message translates to:
  /// **'PDF berisi barang, ringkasan bayar, dan retur; bisa dikirim ke supplier.'**
  String get purchasePrintHint;

  /// No description provided for @purchasePrintSaved.
  ///
  /// In id, this message translates to:
  /// **'PDF pembelian disimpan di {path}'**
  String purchasePrintSaved(String path);

  /// No description provided for @purchasePrintFailed.
  ///
  /// In id, this message translates to:
  /// **'PDF pembelian gagal dibuat. Coba lagi.'**
  String get purchasePrintFailed;

  /// No description provided for @purchasePrintTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembelian {number}'**
  String purchasePrintTitle(String number);

  /// No description provided for @purchasePrintInvoiceNo.
  ///
  /// In id, this message translates to:
  /// **'No. faktur {number}'**
  String purchasePrintInvoiceNo(String number);

  /// No description provided for @purchasePrintPaidUpfront.
  ///
  /// In id, this message translates to:
  /// **'Dibayar di muka'**
  String get purchasePrintPaidUpfront;

  /// No description provided for @purchasePrintDebtPaid.
  ///
  /// In id, this message translates to:
  /// **'Bayar hutang'**
  String get purchasePrintDebtPaid;

  /// No description provided for @purchasePrintDue.
  ///
  /// In id, this message translates to:
  /// **'Jatuh tempo sisa hutang: {date}'**
  String purchasePrintDue(String date);

  /// No description provided for @purchasePrintNoteLine.
  ///
  /// In id, this message translates to:
  /// **'Catatan: {note}'**
  String purchasePrintNoteLine(String note);

  /// No description provided for @purchasePrintReturn.
  ///
  /// In id, this message translates to:
  /// **'Retur {number} · {date} · {amount}'**
  String purchasePrintReturn(String number, String date, String amount);

  /// No description provided for @purchasePrintPrinted.
  ///
  /// In id, this message translates to:
  /// **'Dicetak {date} oleh {staff}'**
  String purchasePrintPrinted(String date, String staff);

  /// No description provided for @purchaseStockCard.
  ///
  /// In id, this message translates to:
  /// **'Buka kartu stok {product}'**
  String purchaseStockCard(String product);

  /// No description provided for @purchasePrintReturnDebt.
  ///
  /// In id, this message translates to:
  /// **'Retur memotong hutang'**
  String get purchasePrintReturnDebt;

  /// No description provided for @purchasePrintRefund.
  ///
  /// In id, this message translates to:
  /// **'Uang kembali dari retur: {amount}'**
  String purchasePrintRefund(String amount);

  /// No description provided for @stockCardFocusMissing.
  ///
  /// In id, this message translates to:
  /// **'Produk atau lokasi dari tautan tidak ditemukan lagi. Menampilkan kartu stok bawaan.'**
  String get stockCardFocusMissing;

  /// No description provided for @firstProductLabel.
  ///
  /// In id, this message translates to:
  /// **'Produk pertama'**
  String get firstProductLabel;

  /// No description provided for @firstProductAdd.
  ///
  /// In id, this message translates to:
  /// **'Tambah satu produk sekarang'**
  String get firstProductAdd;

  /// No description provided for @firstProductAddDesc.
  ///
  /// In id, this message translates to:
  /// **'Langsung bisa dijual di Kasir. Produk lain bisa ditambah nanti.'**
  String get firstProductAddDesc;

  /// No description provided for @firstProductImport.
  ///
  /// In id, this message translates to:
  /// **'Import dari Excel/CSV'**
  String get firstProductImport;

  /// No description provided for @firstProductImportDesc.
  ///
  /// In id, this message translates to:
  /// **'Setelah toko dibuat, layar Produk terbuka dengan dialog import.'**
  String get firstProductImportDesc;

  /// No description provided for @firstProductSkip.
  ///
  /// In id, this message translates to:
  /// **'Lewati, tambah nanti'**
  String get firstProductSkip;

  /// No description provided for @firstProductSkipDesc.
  ///
  /// In id, this message translates to:
  /// **'Tambah produk kapan saja dari menu Produk.'**
  String get firstProductSkipDesc;

  /// No description provided for @firstProductInvalid.
  ///
  /// In id, this message translates to:
  /// **'Periksa isian produk pertama.'**
  String get firstProductInvalid;

  /// No description provided for @firstProductOptional.
  ///
  /// In id, this message translates to:
  /// **'Opsional'**
  String get firstProductOptional;

  /// No description provided for @productGenerateBarcode.
  ///
  /// In id, this message translates to:
  /// **'Buat barcode'**
  String get productGenerateBarcode;

  /// No description provided for @labelsTooDense.
  ///
  /// In id, this message translates to:
  /// **'{count} produk memakai kode terlalu panjang untuk kertas ini'**
  String labelsTooDense(int count);

  /// No description provided for @labelsTooDenseMore.
  ///
  /// In id, this message translates to:
  /// **'{names}, dan {count} lainnya'**
  String labelsTooDenseMore(String names, int count);

  /// No description provided for @labelsTooDenseHint.
  ///
  /// In id, this message translates to:
  /// **'Garis barcode {names} jadi terlalu tipis untuk dipindai. Pakai kertas yang lebih lebar, SKU yang lebih pendek, atau tombol Buat barcode di form produk.'**
  String labelsTooDenseHint(String names);

  /// No description provided for @labelsGenerateMissing.
  ///
  /// In id, this message translates to:
  /// **'Buat barcode untuk {count} produk tanpa kode'**
  String labelsGenerateMissing(int count);

  /// No description provided for @labelsGenerateDense.
  ///
  /// In id, this message translates to:
  /// **'Ganti dengan barcode EAN-13'**
  String get labelsGenerateDense;

  /// No description provided for @labelsGenerateTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat {count} barcode?'**
  String labelsGenerateTitle(int count);

  /// No description provided for @labelsGenerateBody.
  ///
  /// In id, this message translates to:
  /// **'Lakuna membuat barcode EAN-13 toko berawalan 20 yang belum dipakai, lalu menyimpannya ke produk. SKU tidak berubah, dan barcode bisa diubah lagi di form produk.'**
  String get labelsGenerateBody;

  /// No description provided for @labelsGenerateConfirm.
  ///
  /// In id, this message translates to:
  /// **'Buat barcode'**
  String get labelsGenerateConfirm;

  /// No description provided for @labelsGenerateCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get labelsGenerateCancel;

  /// No description provided for @labelsGenerated.
  ///
  /// In id, this message translates to:
  /// **'{count} barcode dibuat dan disimpan. Produknya sudah dipilih untuk dicetak.'**
  String labelsGenerated(int count);

  /// No description provided for @labelsGenerateFailed.
  ///
  /// In id, this message translates to:
  /// **'Barcode gagal disimpan untuk: {names}'**
  String labelsGenerateFailed(String names);

  /// No description provided for @productImportUpdate.
  ///
  /// In id, this message translates to:
  /// **'Perbarui harga produk yang sudah ada'**
  String get productImportUpdate;

  /// No description provided for @productImportUpdateNote.
  ///
  /// In id, this message translates to:
  /// **'Produk yang cocok (SKU, barcode, atau nama bila baris tanpa kode) diperbarui harga jual, harga beli, dan stok minimumnya. Sel kosong tidak mengubah apa pun, stok tidak diubah, dan baris yang cocoknya ragu dilewati.'**
  String get productImportUpdateNote;

  /// No description provided for @productImportDoneUpdate.
  ///
  /// In id, this message translates to:
  /// **'Selesai: {created} produk baru, {updated} harga diperbarui, {unchanged} tidak berubah, {skipped} dilewati.'**
  String productImportDoneUpdate(
    int created,
    int updated,
    int unchanged,
    int skipped,
  );

  /// No description provided for @productImportSkippedUnclear.
  ///
  /// In id, this message translates to:
  /// **'Baris dilewati karena cocoknya ragu (kode kembar atau bertentangan, nama produk banyak varian, atau varian sudah diperbarui baris lain): {lines}'**
  String productImportSkippedUnclear(String lines);

  /// No description provided for @backupLock.
  ///
  /// In id, this message translates to:
  /// **'Kunci dengan kata sandi'**
  String get backupLock;

  /// No description provided for @backupLockNote.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak disimpan. Tanpa kata sandi ini backup tidak bisa dipulihkan.'**
  String get backupLockNote;

  /// No description provided for @backupPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi backup'**
  String get backupPassword;

  /// No description provided for @backupPasswordRetype.
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi'**
  String get backupPasswordRetype;

  /// No description provided for @backupPasswordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Minimal {min} karakter.'**
  String backupPasswordTooShort(int min);

  /// No description provided for @backupPasswordTooLong.
  ///
  /// In id, this message translates to:
  /// **'Maksimal {max} karakter.'**
  String backupPasswordTooLong(int max);

  /// No description provided for @backupPasswordMismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak sama.'**
  String get backupPasswordMismatch;

  /// No description provided for @backupSavedLockedTo.
  ///
  /// In id, this message translates to:
  /// **'Backup terkunci kata sandi tersimpan di {path}'**
  String backupSavedLockedTo(String path);

  /// No description provided for @backupSharedLocked.
  ///
  /// In id, this message translates to:
  /// **'Backup terkunci kata sandi dibagikan.'**
  String get backupSharedLocked;

  /// No description provided for @backupUnlockTitle.
  ///
  /// In id, this message translates to:
  /// **'Backup ini terkunci kata sandi'**
  String get backupUnlockTitle;

  /// No description provided for @backupUnlockBody.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kata sandi yang dipakai saat backup dibuat.'**
  String get backupUnlockBody;

  /// No description provided for @backupUnlock.
  ///
  /// In id, this message translates to:
  /// **'Buka'**
  String get backupUnlock;

  /// No description provided for @backupWrongPassword.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi salah. Coba lagi.'**
  String get backupWrongPassword;

  /// No description provided for @barPrinterTitle.
  ///
  /// In id, this message translates to:
  /// **'Printer bar'**
  String get barPrinterTitle;

  /// No description provided for @barPrinterSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Minuman dari kategori pilihan dicetak otomatis di bar saat Kirim ke dapur. Disimpan di perangkat ini saja.'**
  String get barPrinterSubtitle;

  /// No description provided for @barPrinterNone.
  ///
  /// In id, this message translates to:
  /// **'Tidak dipakai'**
  String get barPrinterNone;

  /// No description provided for @barPrinterNoneNote.
  ///
  /// In id, this message translates to:
  /// **'Semua item dicetak di tiket dapur.'**
  String get barPrinterNoneNote;

  /// No description provided for @barPrinterForget.
  ///
  /// In id, this message translates to:
  /// **'Lupakan printer bar'**
  String get barPrinterForget;

  /// No description provided for @barPrinterTest.
  ///
  /// In id, this message translates to:
  /// **'Tes cetak tiket bar'**
  String get barPrinterTest;

  /// No description provided for @barPrinterTestSent.
  ///
  /// In id, this message translates to:
  /// **'Tiket contoh terkirim ke printer bar.'**
  String get barPrinterTestSent;

  /// No description provided for @barCategories.
  ///
  /// In id, this message translates to:
  /// **'Kategori ke bar'**
  String get barCategories;

  /// No description provided for @barCategoriesHint.
  ///
  /// In id, this message translates to:
  /// **'Sub-kategori ikut kategori induknya. Item lain tetap ke dapur.'**
  String get barCategoriesHint;

  /// No description provided for @barCategoriesNeeded.
  ///
  /// In id, this message translates to:
  /// **'Pilih minimal satu kategori; sampai itu semua tiket tetap ke dapur.'**
  String get barCategoriesNeeded;

  /// No description provided for @barCategoriesEmpty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada kategori menu. Tambahkan kategori di Produk.'**
  String get barCategoriesEmpty;

  /// No description provided for @barTicketHeading.
  ///
  /// In id, this message translates to:
  /// **'TIKET BAR'**
  String get barTicketHeading;

  /// No description provided for @barTicketPrinting.
  ///
  /// In id, this message translates to:
  /// **'Mencetak di printer bar…'**
  String get barTicketPrinting;

  /// No description provided for @barTicketPrinted.
  ///
  /// In id, this message translates to:
  /// **'Tiket dicetak di printer bar.'**
  String get barTicketPrinted;

  /// No description provided for @barTicketReprint.
  ///
  /// In id, this message translates to:
  /// **'Cetak ulang tiket bar'**
  String get barTicketReprint;

  /// No description provided for @kitchenTicketSection.
  ///
  /// In id, this message translates to:
  /// **'Dapur'**
  String get kitchenTicketSection;

  /// No description provided for @barTicketSection.
  ///
  /// In id, this message translates to:
  /// **'Bar'**
  String get barTicketSection;

  /// No description provided for @receiptApproval.
  ///
  /// In id, this message translates to:
  /// **'No. approval'**
  String get receiptApproval;

  /// No description provided for @receiptTransferRef.
  ///
  /// In id, this message translates to:
  /// **'Ref. transfer'**
  String get receiptTransferRef;

  /// No description provided for @historySearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari no. nota, pelanggan, atau referensi'**
  String get historySearchHint;

  /// No description provided for @historySearchSummary.
  ///
  /// In id, this message translates to:
  /// **'Hasil pencarian · {count} transaksi · {total}'**
  String historySearchSummary(int count, String total);

  /// No description provided for @historySearchTruncated.
  ///
  /// In id, this message translates to:
  /// **'Menampilkan {limit} nota terbaru. Perjelas kata kunci untuk mempersempit hasil.'**
  String historySearchTruncated(int limit);

  /// No description provided for @historySearchEmpty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada nota yang cocok dengan pencarian.'**
  String get historySearchEmpty;

  /// No description provided for @reportsPeriodCustom.
  ///
  /// In id, this message translates to:
  /// **'Rentang tanggal…'**
  String get reportsPeriodCustom;

  /// No description provided for @reportsRangeTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih rentang tanggal'**
  String get reportsRangeTitle;

  /// No description provided for @reportsRangeFrom.
  ///
  /// In id, this message translates to:
  /// **'Dari'**
  String get reportsRangeFrom;

  /// No description provided for @reportsRangeTo.
  ///
  /// In id, this message translates to:
  /// **'Sampai'**
  String get reportsRangeTo;

  /// No description provided for @reportsRangeCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get reportsRangeCancel;

  /// No description provided for @reportsRangeApply.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get reportsRangeApply;

  /// No description provided for @reportsRangeErrOrder.
  ///
  /// In id, this message translates to:
  /// **'Tanggal akhir tidak boleh sebelum tanggal awal.'**
  String get reportsRangeErrOrder;

  /// No description provided for @reportsRangeErrFuture.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tidak boleh melewati hari ini.'**
  String get reportsRangeErrFuture;

  /// No description provided for @reportsRangeErrTooLong.
  ///
  /// In id, this message translates to:
  /// **'Rentang paling panjang {days} hari.'**
  String reportsRangeErrTooLong(int days);

  /// No description provided for @reportsPrevDays.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =1{hari sebelumnya} other{{count} hari sebelumnya}}'**
  String reportsPrevDays(int count);

  /// No description provided for @drawerShortfallWarning.
  ///
  /// In id, this message translates to:
  /// **'Uang di laci diperkirakan {cash}. Jumlah ini lebih {over} dari perkiraan; pastikan uangnya ada sebelum menyimpan.'**
  String drawerShortfallWarning(String cash, String over);
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
