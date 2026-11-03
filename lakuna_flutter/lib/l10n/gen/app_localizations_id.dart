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
}
