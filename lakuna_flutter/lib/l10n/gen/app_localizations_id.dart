// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Lakuna';

  @override
  String get appTagline => 'Kasir offline untuk UMKM';

  @override
  String get offlineBadge => 'Offline · data di perangkat ini';

  @override
  String get menuHome => 'Beranda';

  @override
  String get menuCashier => 'Kasir';

  @override
  String get menuHistory => 'Riwayat';

  @override
  String get menuProducts => 'Produk';

  @override
  String get menuStock => 'Stok';

  @override
  String get menuPurchases => 'Pembelian';

  @override
  String get menuCustomers => 'Pelanggan';

  @override
  String get menuSuppliers => 'Supplier';

  @override
  String get menuExpenses => 'Pengeluaran';

  @override
  String get menuReports => 'Laporan';

  @override
  String get menuUsers => 'Pengguna & role';

  @override
  String get menuSettings => 'Pengaturan';

  @override
  String get menuGuide => 'Panduan';

  @override
  String get menuGroupSales => 'Penjualan';

  @override
  String get menuGroupInventory => 'Inventori';

  @override
  String get menuGroupContacts => 'Kontak';

  @override
  String get menuGroupFinance => 'Keuangan';

  @override
  String get menuGroupSystem => 'Sistem';

  @override
  String get homeWelcomeTitle => 'Selamat datang di Lakuna';

  @override
  String get homeWelcomeBody =>
      'Fondasi aplikasi sudah siap. Modul kasir, produk, dan stok akan hadir di rilis berikutnya.';

  @override
  String get homeDeviceLabel => 'ID perangkat';

  @override
  String get homeDataLabel => 'Lokasi data';

  @override
  String get homeVersionLabel => 'Versi';

  @override
  String comingSoonTitle(String module) {
    return '$module segera hadir';
  }

  @override
  String get comingSoonBody =>
      'Modul ini sedang dibangun dan akan tersedia di rilis berikutnya.';

  @override
  String get settingsAppearance => 'Tampilan';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get themeSystem => 'Ikuti sistem';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get languageIndonesian => 'Bahasa Indonesia';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsSaveError => 'Pengaturan gagal disimpan. Coba lagi.';

  @override
  String get onboardingWelcome => 'Selamat datang';

  @override
  String get onboardingHeadline => 'Siapkan toko Anda dalam 4 langkah';

  @override
  String get onboardingOfflineNote =>
      'Semua data tersimpan di perangkat ini. Anda bisa mengaktifkan versi hosting kapan saja.';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Langkah $current dari $total';
  }

  @override
  String get onboardingStepLanguage => 'Bahasa & tema';

  @override
  String get onboardingStepBusiness => 'Jenis usaha & cabang';

  @override
  String get onboardingStepOwner => 'Akun pemilik & PIN';

  @override
  String get onboardingStepSummary => 'Siap jualan';

  @override
  String get onboardingTitleLanguage => 'Pilih bahasa dan tema';

  @override
  String get onboardingTitleBusiness => 'Jenis usaha & cabang pertama';

  @override
  String get onboardingTitleOwner => 'Akun pemilik & PIN';

  @override
  String get onboardingTitleSummary => 'Periksa, lalu mulai jualan';

  @override
  String get businessTypeLabel => 'Jenis usaha';

  @override
  String get businessRetail => 'Retail';

  @override
  String get businessRetailDesc =>
      'Toko kelontong, grosir, toko bangunan, counter HP.';

  @override
  String get businessFnb => 'F&B';

  @override
  String get businessFnbDesc =>
      'Warung makan, kafe, kedai kopi. Ada meja & open bill.';

  @override
  String get businessMixed => 'Campuran';

  @override
  String get businessMixedDesc => 'Jual barang sekaligus makanan/minuman.';

  @override
  String get fieldBusinessName => 'Nama usaha';

  @override
  String get fieldOutletName => 'Nama cabang';

  @override
  String get fieldOutletCode => 'Kode cabang (untuk nomor nota)';

  @override
  String get fieldDeviceCode => 'Kode perangkat';

  @override
  String get fieldTimezone => 'Zona waktu';

  @override
  String get fieldOwnerName => 'Nama pemilik';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPassword => 'Kata sandi';

  @override
  String get fieldPin => 'PIN (6 angka)';

  @override
  String get fieldPinConfirm => 'Ulangi PIN';

  @override
  String get receiptPreviewLabel => 'Contoh nomor nota';

  @override
  String get receiptPreviewNote =>
      'Cabang, perangkat, tanggal, urutan. Aman walau beberapa kasir offline.';

  @override
  String get ownerNote =>
      'PIN dipakai untuk masuk dan ganti kasir. Email dan kata sandi dipakai untuk masuk sebagai pemilik.';

  @override
  String get errorRequired => 'Wajib diisi';

  @override
  String get errorTooLong => 'Maksimal 60 karakter';

  @override
  String get errorInvalidCode => '2–6 huruf atau angka';

  @override
  String get errorInvalidEmail => 'Format email tidak valid';

  @override
  String get errorPasswordTooShort => 'Minimal 8 karakter';

  @override
  String get errorInvalidPin => 'PIN harus 6 angka';

  @override
  String get errorPinMismatch => 'PIN tidak sama';

  @override
  String get errorInvalidTimezone => 'Pilih zona waktu';

  @override
  String get summaryBusiness => 'Usaha';

  @override
  String get summaryOutlet => 'Cabang';

  @override
  String get summaryDevice => 'Perangkat';

  @override
  String get summaryOwner => 'Pemilik';

  @override
  String get summaryNote =>
      'Data baru disimpan setelah Anda menekan Mulai jualan.';

  @override
  String get buttonBack => 'Kembali';

  @override
  String get buttonNextBusiness => 'Lanjut: jenis usaha';

  @override
  String get buttonNextOwner => 'Lanjut: akun pemilik';

  @override
  String get buttonNextSummary => 'Lanjut: ringkasan';

  @override
  String get buttonStartSelling => 'Mulai jualan';

  @override
  String get setupFailed => 'Toko gagal disimpan. Coba lagi.';

  @override
  String get homeStoreLabel => 'Toko';

  @override
  String get setupAlreadyDone =>
      'Perangkat ini sudah berisi data toko yang belum lengkap. Pulihkan dari backup atau hubungi dukungan.';
}
