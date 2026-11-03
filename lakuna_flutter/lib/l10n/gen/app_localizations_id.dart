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
  String get menuMore => 'Lainnya';

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
      'Kasir retail dan F&B, sesi kasir, produk, stok, riwayat transaksi, dan pembelian sudah bisa dipakai. Pelanggan, supplier, dan laporan menyusul di rilis berikutnya.';

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
  String get fieldPasswordConfirm => 'Ulangi kata sandi';

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
  String get errorPasswordMismatch => 'Kata sandi tidak sama';

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

  @override
  String get loginTitle => 'Siapa yang bertugas?';

  @override
  String get loginSelectStaff => 'Pilih nama Anda untuk memasukkan PIN.';

  @override
  String loginEnterPinFor(String name) {
    return 'Masukkan PIN $name';
  }

  @override
  String get loginNoPin => 'Belum punya PIN';

  @override
  String get loginPinNote =>
      'PIN diverifikasi di perangkat ini. 5 kali salah → dikunci 1 menit.';

  @override
  String get loginOwnerLink => 'Masuk dengan email & kata sandi (pemilik)';

  @override
  String get loginOwnerTitle => 'Masuk sebagai pemilik';

  @override
  String get loginSubmit => 'Masuk';

  @override
  String get loginBackToPin => 'Kembali ke PIN';

  @override
  String get loginBackToStaff => 'Pilih staf lain';

  @override
  String get loginKeypadCancel => 'Batal';

  @override
  String get loginKeypadDelete => 'Hapus satu angka';

  @override
  String loginWrongPin(int count) {
    return 'PIN salah. Sisa $count percobaan.';
  }

  @override
  String loginLocked(int seconds) {
    return 'Terlalu banyak percobaan. Coba lagi dalam $seconds detik.';
  }

  @override
  String get loginWrongCredentials => 'Email atau kata sandi salah.';

  @override
  String get loginStaffUnavailable =>
      'Staf ini tidak lagi aktif di cabang ini.';

  @override
  String get loginFailed => 'Gagal masuk. Coba lagi.';

  @override
  String get loginLoadFailed => 'Daftar staf gagal dimuat.';

  @override
  String get loginRetry => 'Coba lagi';

  @override
  String get switchCashier => 'Ganti kasir';

  @override
  String get homeStaffLabel => 'Bertugas';

  @override
  String get roleOwner => 'Pemilik';

  @override
  String get roleManager => 'Manajer';

  @override
  String get roleCashier => 'Kasir';

  @override
  String get roleWaiter => 'Pelayan';

  @override
  String get roleStockKeeper => 'Staf gudang';

  @override
  String get menuCashSession => 'Sesi kasir';

  @override
  String get cashDrawerTitle => 'Sesi kasir · Kas laci';

  @override
  String cashCashierLabel(String name) {
    return 'Kasir: $name';
  }

  @override
  String get cashOpenTitle => 'Buka sesi kasir';

  @override
  String get cashOpenBody =>
      'Hitung uang di laci sebelum mulai berjualan, lalu catat sebagai saldo awal.';

  @override
  String get cashOpeningCash => 'Saldo awal laci';

  @override
  String get cashOpeningNote => 'Catatan (opsional)';

  @override
  String get cashOpenButton => 'Buka sesi';

  @override
  String get cashActive => 'Sesi aktif';

  @override
  String cashOpenedBy(String time, String name, String device) {
    return 'Dibuka $time oleh $name · $device';
  }

  @override
  String get cashExpected => 'Perkiraan uang di laci';

  @override
  String get cashCloseButton => 'Tutup sesi';

  @override
  String get cashMovementsTitle => 'Gerakan kas sesi ini';

  @override
  String get cashColTime => 'Jam';

  @override
  String get cashColNote => 'Keterangan';

  @override
  String get cashColSource => 'Sumber';

  @override
  String get cashColAmount => 'Jumlah';

  @override
  String get cashOpeningRow => 'Saldo awal';

  @override
  String get cashSourceOpening => 'Buka sesi';

  @override
  String get cashSourceManual => 'Manual';

  @override
  String get cashMovementsFootnote =>
      'Pengeluaran, bayar hutang, dan retur tunai dari modul lain akan tercatat otomatis di sesi yang sedang buka.';

  @override
  String get cashRecordTitle => 'Catat uang laci';

  @override
  String get cashOutflow => 'Uang keluar';

  @override
  String get cashInflow => 'Uang masuk';

  @override
  String get cashAmount => 'Jumlah';

  @override
  String get cashNote => 'Keterangan';

  @override
  String get cashNoteHint => 'Mis. beli es batu';

  @override
  String get cashSave => 'Simpan';

  @override
  String cashNeedsPermission(String permission) {
    return 'Butuh izin $permission.';
  }

  @override
  String cashCloseTitle(String name) {
    return 'Tutup sesi kasir · $name';
  }

  @override
  String get cashBackToDrawer => 'Kembali ke kas laci';

  @override
  String get cashStatTransactions => 'Transaksi';

  @override
  String get cashStatSales => 'Penjualan';

  @override
  String get cashStatVoids => 'Void / retur';

  @override
  String get cashRecapTitle => 'Rekap kas laci';

  @override
  String cashRecapOpening(String time) {
    return 'Saldo awal ($time)';
  }

  @override
  String get cashRecapCashSales => 'Penjualan tunai';

  @override
  String get cashRecapCashRefunds => 'Retur tunai';

  @override
  String get cashRecapInflow => 'Uang masuk lain';

  @override
  String get cashRecapOutflow => 'Uang keluar';

  @override
  String get cashRecapExpected => 'Seharusnya di laci';

  @override
  String get cashRecapNonCash => 'QRIS statis (terkonfirmasi) · kartu';

  @override
  String get cashRecapFootnote =>
      'QRIS statis & kartu tidak masuk laci, ditampilkan terpisah untuk dicocokkan dengan mutasi rekening.';

  @override
  String get cashCountTitle => 'Hitung uang fisik';

  @override
  String cashSheetsLabel(String denomination) {
    return 'Lembar Rp $denomination';
  }

  @override
  String get cashCoins => 'Receh';

  @override
  String get cashCounted => 'Uang dihitung';

  @override
  String get cashDifference => 'Selisih';

  @override
  String get cashDifferenceExact => 'Pas';

  @override
  String get cashClosingNote => 'Catatan selisih';

  @override
  String get cashClosingNoteHint => 'Wajib diisi bila ada selisih';

  @override
  String get cashClosedTitle => 'Sesi kasir ditutup';

  @override
  String cashClosedBody(String time) {
    return 'Ditutup $time. Rekap tersimpan di perangkat ini.';
  }

  @override
  String get cashStartNew => 'Buka sesi baru';

  @override
  String get cashErrorNegative => 'Tidak boleh negatif';

  @override
  String get cashErrorNotPositive => 'Harus lebih dari 0';

  @override
  String get cashErrorTooLong => 'Maksimal 200 karakter';

  @override
  String cashErrorNotPermitted(String permission) {
    return 'Anda tidak punya izin $permission.';
  }

  @override
  String get cashErrorAlreadyOpen =>
      'Sesi sudah dibuka di layar lain. Data dimuat ulang.';

  @override
  String get cashErrorNotOpen =>
      'Sesi sudah ditutup di layar lain. Data dimuat ulang.';

  @override
  String get cashErrorFailed => 'Gagal menyimpan. Coba lagi.';

  @override
  String get cashLoadFailed => 'Sesi kasir gagal dimuat.';

  @override
  String get productsTitle => 'Produk & stok';

  @override
  String get productsTitleMobile => 'Produk';

  @override
  String productsSummary(int active, int low) {
    return '$active produk aktif · $low di bawah stok minimum';
  }

  @override
  String productsSummaryShort(int active, int low) {
    return '$active aktif · $low di bawah minimum';
  }

  @override
  String get productsNew => 'Produk baru';

  @override
  String get productsSearchHint => 'Cari nama, SKU, atau barcode';

  @override
  String get productsCategoryFilter => 'Kategori';

  @override
  String get productsAllCategories => 'Semua';

  @override
  String productsBelowMinimumChip(int count) {
    return 'Di bawah minimum ($count)';
  }

  @override
  String get productsColProduct => 'Produk';

  @override
  String get productsColCategory => 'Kategori';

  @override
  String get productsColVariantUnit => 'Varian / satuan';

  @override
  String get productsColCost => 'Harga beli';

  @override
  String get productsColPrice => 'Harga jual';

  @override
  String get productsColTiers => 'Grosir';

  @override
  String get productsColStock => 'Stok';

  @override
  String productsVariantsCount(int count) {
    return '$count varian';
  }

  @override
  String get productsStockFootnote =>
      'Stok dihitung dari riwayat pergerakan (stok awal, pembelian, penjualan, retur, penyesuaian).';

  @override
  String get productsEmptyTitle => 'Belum ada produk';

  @override
  String get productsEmptyBody =>
      'Tambahkan produk pertama agar bisa dijual di kasir.';

  @override
  String get productsNoMatch => 'Tidak ada produk yang cocok.';

  @override
  String get productsLoadFailed => 'Produk gagal dimuat.';

  @override
  String productsStock(String qty) {
    return 'Stok $qty';
  }

  @override
  String productsStockMin(String qty, String min) {
    return 'Stok $qty / min $min';
  }

  @override
  String get productsInactive => 'Tidak dijual';

  @override
  String get productFormNewTitle => 'Produk baru';

  @override
  String productFormEditTitle(String name) {
    return 'Edit produk · $name';
  }

  @override
  String get productFormCancel => 'Batal';

  @override
  String get productFormSave => 'Simpan';

  @override
  String get productFormBasicInfo => 'Info dasar';

  @override
  String get productFormName => 'Nama produk';

  @override
  String get productFormCategory => 'Kategori';

  @override
  String get productFormKind => 'Jenis';

  @override
  String get productKindGoods => 'Barang (lacak stok)';

  @override
  String get productKindService => 'Jasa (tanpa stok)';

  @override
  String get productKindMenu => 'Menu F&B';

  @override
  String get productFormBaseUnit => 'Satuan dasar';

  @override
  String get productFormBaseUnitHint => 'pcs, botol, kg';

  @override
  String get productFormSku => 'SKU induk';

  @override
  String get productFormBrand => 'Merek';

  @override
  String get productFormActive => 'Dijual di kasir';

  @override
  String get productFormTaxable => 'Kena pajak (PB1/PPN)';

  @override
  String get productFormTaxableHint => 'Mengikuti pengaturan pajak toko';

  @override
  String get productFormOptional => 'Opsional';

  @override
  String get productTabVariants => 'Varian';

  @override
  String get productTabUnits => 'Satuan & konversi';

  @override
  String get productTabTiers => 'Harga grosir';

  @override
  String get productTabUnitsShort => 'Satuan';

  @override
  String get productTabTiersShort => 'Grosir';

  @override
  String get productVariantName => 'Varian';

  @override
  String get productVariantNameHint => 'mis. 2 L';

  @override
  String get productVariantSku => 'SKU';

  @override
  String get productVariantBarcode => 'Barcode';

  @override
  String get productCostPrice => 'Harga beli';

  @override
  String get productSellPrice => 'Harga jual';

  @override
  String get productMinStock => 'Stok min';

  @override
  String get productOpeningStock => 'Stok awal';

  @override
  String get productAddVariant => 'Tambah varian';

  @override
  String get productRemoveRow => 'Hapus baris';

  @override
  String productVariantFallback(int index) {
    return 'Varian $index';
  }

  @override
  String get productSelectVariant => 'Varian';

  @override
  String get productBaseUnitRow => 'satuan dasar';

  @override
  String get productUnitName => 'Satuan';

  @override
  String productUnitFactor(String unit) {
    return 'Isi ($unit)';
  }

  @override
  String get productUnitPriceHint => 'Kosong = harga × isi';

  @override
  String get productAddUnit => 'Tambah satuan';

  @override
  String productUnitsHelp(String unit, String conversion, String factor) {
    return 'Stok selalu disimpan dalam satuan dasar ($unit). Jual 1 $conversion = keluar $factor $unit dari kartu stok.';
  }

  @override
  String productUnitsHelpBase(String unit) {
    return 'Stok selalu disimpan dalam satuan dasar ($unit).';
  }

  @override
  String get productUnitsEmpty =>
      'Belum ada satuan konversi, mis. dus berisi 12.';

  @override
  String productTierMinQty(String unit) {
    return 'Mulai jumlah ($unit)';
  }

  @override
  String productTierPrice(String unit) {
    return 'Harga per $unit';
  }

  @override
  String get productTierAppliesTo => 'Berlaku untuk';

  @override
  String get productTierAllCustomers => 'Semua pelanggan';

  @override
  String get productAddTier => 'Tambah tingkat harga';

  @override
  String get productTiersHelp =>
      'Harga grosir dipakai otomatis di kasir saat jumlah beli mencapai tingkatnya.';

  @override
  String get productTiersEmpty => 'Belum ada harga grosir.';

  @override
  String get productBaseUnitPlaceholder => 'satuan dasar';

  @override
  String get productSaveFailed => 'Produk gagal disimpan. Coba lagi.';

  @override
  String get productNotFound => 'Produk tidak ditemukan atau sudah dihapus.';

  @override
  String get productFixErrors => 'Periksa isian yang ditandai merah.';

  @override
  String productErrorNotPermitted(String permission) {
    return 'Anda tidak punya izin $permission.';
  }

  @override
  String productErrorTooLong(int max) {
    return 'Maksimal $max karakter';
  }

  @override
  String get productErrorNegative => 'Tidak boleh negatif';

  @override
  String get productErrorNotPositive => 'Harus lebih dari 0';

  @override
  String get productErrorDuplicate => 'Kembar di produk ini';

  @override
  String get productErrorSameAsBase => 'Sama dengan satuan dasar';

  @override
  String get productErrorFactorTooSmall => 'Isi harus lebih dari 1';

  @override
  String get productErrorMinQtyTooSmall => 'Harus lebih dari 1';

  @override
  String productErrorTaken(String name) {
    return 'Sudah dipakai $name';
  }

  @override
  String get productErrorVariantsRequired => 'Minimal satu varian';

  @override
  String cashierContext(String name, String time) {
    return 'Kasir: $name · Sesi dibuka $time';
  }

  @override
  String get cashierSearchHint => 'Cari produk atau scan barcode…';

  @override
  String get cashierScannerReady => 'Scanner siap';

  @override
  String cashierScanUnknown(String code) {
    return 'Barcode tidak dikenal: $code';
  }

  @override
  String get cashierAllCategories => 'Semua';

  @override
  String get cashierNoProducts =>
      'Belum ada produk aktif. Tambahkan di menu Produk.';

  @override
  String get cashierNoMatch => 'Tidak ada produk yang cocok.';

  @override
  String cashierStock(String qty) {
    return 'Stok $qty';
  }

  @override
  String get cashierOrder => 'Pesanan';

  @override
  String get cashierWalkIn => 'Pelanggan umum · Ambil sendiri';

  @override
  String get cashierCartEmpty =>
      'Belum ada barang. Scan barcode atau ketuk produk.';

  @override
  String cashierTierNote(String qty) {
    return 'grosir ≥ $qty';
  }

  @override
  String get cashierSubtotal => 'Subtotal';

  @override
  String get cashierTierDiscount => 'Diskon grosir';

  @override
  String get cashierTotal => 'Total';

  @override
  String get cashierClear => 'Kosongkan';

  @override
  String get cashierPay => 'Bayar';

  @override
  String cashierPayAmount(String amount) {
    return 'Bayar $amount';
  }

  @override
  String cashierMobileSummary(int lines, String items) {
    return '$lines produk · $items item';
  }

  @override
  String get cashierViewOrder => 'Lihat pesanan';

  @override
  String get cashierPickTitle => 'Pilih varian / satuan';

  @override
  String get cashierQtyTitle => 'Ubah jumlah';

  @override
  String cashierQtyLabel(String unit) {
    return 'Jumlah ($unit)';
  }

  @override
  String get cashierQtySave => 'Simpan';

  @override
  String get cashierCancel => 'Batal';

  @override
  String get cashierDecrease => 'Kurangi';

  @override
  String get cashierIncrease => 'Tambah';

  @override
  String get cashierNoSessionTitle => 'Buka sesi kasir dulu';

  @override
  String get cashierNoSessionBody =>
      'Penjualan dicatat ke sesi kasir perangkat ini agar uang laci bisa direkap saat tutup sesi.';

  @override
  String get cashierOpenSession => 'Buka sesi kasir';

  @override
  String get cashierLoadFailed => 'Kasir gagal dimuat.';

  @override
  String paymentTitle(String amount) {
    return 'Pembayaran · Total $amount';
  }

  @override
  String get paymentBack => 'Kembali ke pesanan';

  @override
  String paymentLines(int count) {
    return '$count item';
  }

  @override
  String get paymentCash => 'Tunai';

  @override
  String get paymentCashHint => 'Hitung kembalian';

  @override
  String get paymentCard => 'Kartu debit / kredit';

  @override
  String get paymentCardHint => 'EDC terpisah';

  @override
  String get paymentTransfer => 'Transfer bank';

  @override
  String get paymentTransferHint => 'Cek mutasi dulu';

  @override
  String get paymentReceived => 'Uang diterima';

  @override
  String get paymentExact => 'Uang pas';

  @override
  String get paymentChange => 'Kembalian';

  @override
  String paymentShort(String amount) {
    return 'Kurang $amount';
  }

  @override
  String get paymentApproval => 'No. approval kartu (opsional)';

  @override
  String get paymentApprovalHint => 'mis. 004512';

  @override
  String get paymentReference => 'Referensi transfer (opsional)';

  @override
  String get paymentReferenceTooLong => 'Maksimal 40 karakter';

  @override
  String paymentNonCashNote(String amount) {
    return 'Jumlah dibayar sama dengan total $amount.';
  }

  @override
  String get paymentFinish => 'Selesaikan pembayaran';

  @override
  String get paymentErrorSession =>
      'Sesi kasir sudah ditutup. Buka sesi lagi untuk melanjutkan.';

  @override
  String get paymentErrorUnavailable =>
      'Ada produk yang tidak tersedia lagi. Periksa pesanan.';

  @override
  String get paymentErrorShort => 'Uang diterima kurang dari total.';

  @override
  String get paymentErrorGeneric => 'Pembayaran gagal disimpan. Coba lagi.';

  @override
  String get successHeader => 'Pembayaran selesai';

  @override
  String successReceiptNo(String number) {
    return 'Nota $number';
  }

  @override
  String get successTitle => 'Pembayaran berhasil';

  @override
  String successDetail(String method, String amount, String time, String name) {
    return '$method $amount · $time · $name';
  }

  @override
  String get successChange => 'Kembalian';

  @override
  String get successNegativeTitle => 'Stok jadi minus';

  @override
  String successNegativeBody(String name, String qty) {
    return '$name sekarang $qty. Cek stok atau catat penyesuaian.';
  }

  @override
  String get successPrintNote =>
      'Cetak otomatis setelah bayar bisa diaktifkan di Pengaturan › Struk & printer.';

  @override
  String get successNew => 'Transaksi baru';

  @override
  String get receiptNo => 'No';

  @override
  String get receiptDate => 'Tgl';

  @override
  String get receiptCashier => 'Kasir';

  @override
  String get receiptTotal => 'TOTAL';

  @override
  String get receiptChange => 'Kembali';

  @override
  String get receiptThanks => 'Terima kasih, sampai jumpa lagi!';

  @override
  String cashierPriceFrom(String price) {
    return 'mulai $price';
  }

  @override
  String get paymentErrorPermission =>
      'Anda tidak punya izin menyimpan penjualan. Minta pemilik atau manajer.';

  @override
  String get paymentQris => 'QRIS statis';

  @override
  String get paymentQrisHint => 'Konfirmasi manual';

  @override
  String get paymentSplit => 'Bagi beberapa metode';

  @override
  String get paymentSplitHint => 'Split payment';

  @override
  String paymentSplitSummary(int count) {
    return 'Split · $count metode';
  }

  @override
  String get paymentErrorQrisOff =>
      'QRIS statis tidak aktif di cabang ini. Pilih metode lain.';

  @override
  String get paymentErrorUnconfirmed =>
      'QRIS belum dikonfirmasi Sudah Terbayar.';

  @override
  String get paymentErrorSplit =>
      'Pembagian pembayaran tidak sah. Periksa nominal tiap metode.';

  @override
  String get paymentErrorConfirmPermission =>
      'Anda tidak punya izin konfirmasi pembayaran QRIS. Minta supervisor.';

  @override
  String get qrisPending => 'Menunggu konfirmasi kasir';

  @override
  String get qrisInstruction => 'Scan QRIS, ketik nominal persis';

  @override
  String qrisSettlement(String target) {
    return 'Dana masuk ke: $target';
  }

  @override
  String get qrisStep1 => 'Tunjukkan stiker QRIS ke pelanggan.';

  @override
  String qrisStep2(String amount) {
    return 'Pelanggan scan dan mengetik nominal $amount.';
  }

  @override
  String get qrisStep3 => 'Cek notifikasi atau mutasi dana masuk.';

  @override
  String get qrisStep4 => 'Tekan Sudah Terbayar bila dana sudah masuk.';

  @override
  String get qrisWarning =>
      'Jangan konfirmasi dari tangkapan layar pelanggan saja. Pastikan dana benar-benar masuk.';

  @override
  String get qrisEnlarge => 'Perbesar gambar QRIS';

  @override
  String get qrisTapFullscreen => 'Ketuk gambar untuk layar penuh';

  @override
  String get qrisImageLabel => 'Stiker QRIS statis toko';

  @override
  String get qrisClose => 'Tutup';

  @override
  String get qrisNotReceived => 'Belum masuk';

  @override
  String get qrisPaid => 'Sudah Terbayar';

  @override
  String get qrisNoPermission =>
      'Butuh izin konfirmasi pembayaran (payments:confirm).';

  @override
  String get splitTitle => 'Split payment';

  @override
  String get splitHint => 'Contoh: sebagian tunai, sisa QRIS atau kartu.';

  @override
  String get splitAmount => 'Nominal';

  @override
  String get splitAdd => 'Tambah metode';

  @override
  String get splitRemove => 'Hapus';

  @override
  String get splitConfirm => 'Konfirmasi';

  @override
  String get splitReceived => 'Diterima';

  @override
  String get splitPending => 'Menunggu';

  @override
  String get splitRemaining => 'Sisa';

  @override
  String get splitCashExists => 'Tunai sudah ada. Hapus dulu untuk mengubah.';

  @override
  String get splitOverRemaining => 'Melebihi sisa. Kembalian hanya dari tunai.';

  @override
  String get splitPendingNote =>
      'Konfirmasi semua QRIS yang menunggu sebelum menyelesaikan.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsSectionPayments => 'Metode pembayaran';

  @override
  String get settingsSectionAppearance => 'Tampilan & bahasa';

  @override
  String settingsBranchScope(String outlet) {
    return 'Berlaku untuk $outlet · semua perangkat cabang ini';
  }

  @override
  String get qrisSettingsBreadcrumb => 'Metode pembayaran › QRIS statis';

  @override
  String get qrisSettingsImageTitle => 'Gambar QRIS statis';

  @override
  String get qrisSettingsImageSubtitle =>
      'Dipakai di layar Bayar QRIS dan bisa dicetak ulang sebagai stiker meja';

  @override
  String get qrisSettingsNoImage => 'Belum ada gambar QRIS';

  @override
  String qrisSettingsFileInfo(String name, String size) {
    return '$name · $size';
  }

  @override
  String get qrisSettingsReplace => 'Ganti gambar QRIS';

  @override
  String get qrisSettingsUpload => 'Unggah gambar QRIS';

  @override
  String get qrisSettingsUploadHint =>
      'Pilih file stiker dari perangkat. PNG, JPG, atau WebP, maks 5 MB.';

  @override
  String get qrisSettingsPick => 'Pilih file';

  @override
  String get qrisSettingsCheckTitle => 'Hasil pemeriksaan';

  @override
  String qrisSettingsPortrait(String ratio) {
    return 'Rasio vertikal terdeteksi ($ratio). Gambar ditampilkan utuh, tidak dipotong.';
  }

  @override
  String qrisSettingsNotPortrait(String ratio) {
    return 'Gambar tidak vertikal ($ratio). Pastikan ini stiker QRIS utuh.';
  }

  @override
  String qrisSettingsResolution(int width, int height) {
    return 'Resolusi $width × $height px.';
  }

  @override
  String qrisSettingsLowResolution(int width, int height) {
    return 'Resolusi $width × $height px. Disarankan ≥ 1000 px lebar agar tajam di tablet.';
  }

  @override
  String get qrisSettingsUnsupported => 'File bukan PNG, JPG, atau WebP.';

  @override
  String get qrisSettingsTooLarge => 'File lebih dari 5 MB.';

  @override
  String get qrisSettingsWholeTitle => 'Unggah stiker utuh, bukan potongan QR';

  @override
  String get qrisSettingsWholeBody =>
      'Pakai file asli dari bank/PJP atau foto lurus seluruh stiker: header QRIS + GPN, nama merchant, NMID, kode terminal, QR, dan tulisan \"SATU QRIS UNTUK SEMUA\". Pelanggan perlu melihat nama toko untuk yakin sebelum membayar.';

  @override
  String get qrisSettingsMerchantTitle => 'Data merchant';

  @override
  String get qrisSettingsMerchantName => 'Nama merchant di QRIS';

  @override
  String get qrisSettingsNmid => 'NMID';

  @override
  String get qrisSettingsNmidHint => 'Nomor ID merchant nasional';

  @override
  String get qrisSettingsTerminal => 'Kode terminal';

  @override
  String get qrisSettingsSettlement => 'Dana masuk ke';

  @override
  String get qrisSettingsSettlementHint =>
      'Petunjuk untuk kasir saat cek mutasi, mis. Rekening BCA 123-456-7890';

  @override
  String get qrisSettingsEnabled => 'QRIS statis aktif di kasir';

  @override
  String get qrisSettingsRequirePaid => 'Wajib tekan \"Sudah Terbayar\"';

  @override
  String get qrisSettingsRequirePaidHint =>
      'Selalu aktif untuk QRIS statis; tidak bisa dimatikan';

  @override
  String get qrisSettingsSave => 'Simpan';

  @override
  String get qrisSettingsCancel => 'Batal';

  @override
  String get qrisSettingsSaved => 'Pengaturan QRIS tersimpan';

  @override
  String get qrisSettingsImageMissing =>
      'Unggah gambar QRIS sebelum mengaktifkan.';

  @override
  String qrisSettingsTooLong(int max) {
    return 'Maksimal $max karakter';
  }

  @override
  String get qrisSettingsNmidInvalid => 'Hanya huruf dan angka, maks 20';

  @override
  String get qrisSettingsLoadError => 'Pengaturan QRIS gagal dimuat.';

  @override
  String get receiptSampleNumber => 'PST-K01-261103-0001';

  @override
  String get receiptPrinterTitle => 'Printer struk';

  @override
  String get receiptPrinterNone => 'Belum ada printer';

  @override
  String get receiptPrinterNoneHint =>
      'Atur di Pengaturan › Struk & printer. Tanpa printer, Cetak struk membuka dialog cetak sistem.';

  @override
  String get printerKindBluetooth => 'Bluetooth';

  @override
  String get printerKindNetwork => 'Jaringan (LAN)';

  @override
  String get printerKindSystem => 'Dialog cetak sistem';

  @override
  String get receiptPrint => 'Cetak struk';

  @override
  String get receiptShare => 'Bagikan PDF';

  @override
  String get receiptPrinted => 'Struk terkirim ke printer.';

  @override
  String receiptPdfSaved(String path) {
    return 'PDF disimpan di $path';
  }

  @override
  String get receiptShareError => 'PDF struk gagal dibuat.';

  @override
  String get printerRetry => 'Coba lagi';

  @override
  String get printerErrorBluetoothOff =>
      'Bluetooth mati. Nyalakan lalu coba lagi.';

  @override
  String get printerErrorPermission =>
      'Izin Bluetooth ditolak. Izinkan di pengaturan perangkat.';

  @override
  String get printerErrorConnect =>
      'Printer tidak bisa dihubungi. Pastikan menyala dan dalam jangkauan.';

  @override
  String get printerErrorWrite => 'Data gagal terkirim ke printer.';

  @override
  String get printerErrorTimeout => 'Printer tidak menjawab.';

  @override
  String get printerErrorUnsupported =>
      'Jenis printer ini tidak didukung di perangkat ini.';

  @override
  String get printerErrorGeneric => 'Struk gagal dicetak.';

  @override
  String get settingsSectionReceipt => 'Struk & printer';

  @override
  String get receiptSettingsBreadcrumb => 'Struk & printer';

  @override
  String get receiptDeviceTitle => 'Printer perangkat ini';

  @override
  String get receiptDeviceSubtitle =>
      'Disimpan di perangkat ini saja, tidak ikut ke perangkat lain.';

  @override
  String get printerSearch => 'Cari printer';

  @override
  String get printerBluetoothEmpty =>
      'Belum ada printer yang dipasangkan. Pasangkan printer di pengaturan Bluetooth perangkat, lalu cari lagi.';

  @override
  String get printerBluetoothUnsupported =>
      'Printer Bluetooth tersedia di Android. Di perangkat ini pakai printer jaringan atau dialog cetak sistem.';

  @override
  String get printerSelected => 'Terpilih';

  @override
  String get printerChoose => 'Pilih';

  @override
  String get printerAddress => 'Alamat printer';

  @override
  String get printerAddressHint =>
      'IP atau nama host, port bawaan 9100. Contoh 192.168.1.50:9100';

  @override
  String get printerAddressInvalid =>
      'Alamat tidak sah. Contoh 192.168.1.50 atau 192.168.1.50:9100';

  @override
  String get printerUseAddress => 'Pakai alamat ini';

  @override
  String get printerSystemNote =>
      'Struk dikirim sebagai PDF ke dialog cetak sistem operasi, untuk printer USB atau printer dengan driver.';

  @override
  String get printerUseSystem => 'Pakai dialog cetak sistem';

  @override
  String get printerTest => 'Tes cetak';

  @override
  String get printerTestSent => 'Tes cetak terkirim.';

  @override
  String get printerForget => 'Lupakan printer';

  @override
  String get receiptOutletTitle => 'Struk cabang ini';

  @override
  String get receiptPaperWidth => 'Lebar kertas';

  @override
  String receiptPaperOption(int mm, int columns) {
    return '$mm mm · $columns kolom';
  }

  @override
  String get receiptHeader => 'Header struk';

  @override
  String get receiptHeaderHint =>
      'Alamat, telepon, atau teks lain di bawah nama toko. Maks 4 baris.';

  @override
  String get receiptFooter => 'Footer struk';

  @override
  String get receiptFooterHint => 'Pesan penutup. Maks 4 baris.';

  @override
  String get receiptTooManyLines => 'Maks 4 baris';

  @override
  String get receiptLineTooLong => 'Maks 48 karakter per baris';

  @override
  String get receiptAutoPrint => 'Cetak otomatis setelah bayar';

  @override
  String get receiptAutoPrintHint =>
      'Hanya untuk printer Bluetooth atau jaringan.';

  @override
  String get receiptPreviewTitle => 'Pratinjau struk';

  @override
  String get receiptSettingsSave => 'Simpan';

  @override
  String get receiptSettingsCancel => 'Batal';

  @override
  String get receiptSettingsSaved => 'Pengaturan struk tersimpan';

  @override
  String get receiptSettingsLoadError => 'Pengaturan struk gagal dimuat.';

  @override
  String get stockTitle => 'Stok';

  @override
  String stockSubtitle(String location, String outlet) {
    return '$location · $outlet';
  }

  @override
  String get stockTabList => 'Daftar produk';

  @override
  String get stockTabAdjustment => 'Penyesuaian';

  @override
  String get stockTabCard => 'Kartu stok';

  @override
  String get stockTabMinimum => 'Stok minimum';

  @override
  String get stockTabLocations => 'Lokasi stok';

  @override
  String get stockLoadFailed => 'Data stok gagal dimuat.';

  @override
  String get stockSearchHint => 'Cari nama, SKU, atau barcode';

  @override
  String get stockLocation => 'Lokasi';

  @override
  String get stockColProduct => 'Produk';

  @override
  String get stockColStock => 'Stok';

  @override
  String get stockColMinimum => 'Minimum';

  @override
  String get stockColValue => 'Nilai (HPP)';

  @override
  String get stockColSystem => 'Sistem';

  @override
  String get stockColPhysical => 'Fisik';

  @override
  String get stockColDifference => 'Selisih';

  @override
  String get stockColReason => 'Alasan';

  @override
  String get stockBadgeLow => 'Di bawah minimum';

  @override
  String get stockBadgeNegative => 'Minus';

  @override
  String get stockEmpty => 'Belum ada produk barang. Tambahkan di menu Produk.';

  @override
  String get stockNoMatch => 'Tidak ada produk yang cocok.';

  @override
  String stockValueTotal(String value) {
    return 'Nilai stok $value';
  }

  @override
  String get stockAdjustmentNew => 'Penyesuaian stok baru';

  @override
  String stockAdjustmentMeta(String number, String staff) {
    return '$number · $staff';
  }

  @override
  String get stockReasonLabel => 'Alasan umum';

  @override
  String get stockReasonRoutineCheck => 'Cek rutin';

  @override
  String get stockReasonDamaged => 'Rusak';

  @override
  String get stockReasonLost => 'Hilang';

  @override
  String get stockReasonExpired => 'Kedaluwarsa';

  @override
  String get stockReasonOther => 'Lainnya';

  @override
  String get stockNoteLabel => 'Catatan';

  @override
  String get stockNoteHint => 'Mis. cek rutin mingguan';

  @override
  String get stockLineNoteHint => 'Alasan baris';

  @override
  String get stockAddLabel => 'Scan / tambah produk';

  @override
  String get stockAddHint => 'Scan barcode atau ketik nama produk';

  @override
  String stockAddNotFound(String code) {
    return 'Produk \"$code\" tidak ditemukan.';
  }

  @override
  String get stockAddAlready => 'Produk ini sudah ada di daftar penyesuaian.';

  @override
  String get stockLinesEmpty =>
      'Tambah produk yang dihitung, lalu isi stok fisiknya. Baris yang fisiknya kosong tidak disimpan.';

  @override
  String get stockTotal => 'Total';

  @override
  String get stockSave => 'Simpan penyesuaian';

  @override
  String get stockClear => 'Batal';

  @override
  String stockSaved(String number) {
    return 'Penyesuaian $number tersimpan.';
  }

  @override
  String get stockPermissionNote =>
      'Butuh izin stock:adjust. Tercatat sebagai pergerakan stok dengan alasan, bisa diaudit.';

  @override
  String get stockNoPermission =>
      'Anda hanya bisa melihat stok. Penyesuaian butuh izin stock:adjust.';

  @override
  String get stockErrorEmpty => 'Isi stok fisik minimal satu produk.';

  @override
  String get stockErrorNegative => 'Stok fisik tidak boleh minus.';

  @override
  String get stockErrorDuplicate => 'Produk yang sama ada dua kali.';

  @override
  String get stockErrorNotGoods => 'Jasa dan menu tidak punya stok.';

  @override
  String get stockErrorUnknownVariant =>
      'Produk sudah dihapus atau tidak ditemukan.';

  @override
  String get stockErrorUnknownLocation => 'Lokasi stok tidak ditemukan.';

  @override
  String get stockErrorNoChange =>
      'Tidak ada selisih: stok fisik sama dengan stok sistem.';

  @override
  String get stockErrorNoteTooLong => 'Alasan atau catatan terlalu panjang.';

  @override
  String get stockErrorGeneric => 'Penyesuaian gagal disimpan.';

  @override
  String get stockRecentTitle => 'Penyesuaian terakhir';

  @override
  String get stockRecentEmpty => 'Belum ada penyesuaian.';

  @override
  String stockRecentMeta(String reason, int count, String staff) {
    return '$reason · $count produk · $staff';
  }

  @override
  String get stockCardTitle => 'Kartu stok';

  @override
  String stockCardCurrent(String stock, String minimum) {
    return 'Stok sekarang $stock · minimum $minimum';
  }

  @override
  String stockCardCurrentNoMin(String stock) {
    return 'Stok sekarang $stock';
  }

  @override
  String get stockCardProduct => 'Produk';

  @override
  String get stockColTime => 'Waktu';

  @override
  String get stockColDescription => 'Keterangan';

  @override
  String get stockColInOut => 'Masuk/keluar';

  @override
  String get stockColBalance => 'Saldo';

  @override
  String get stockCardEmpty => 'Belum ada pergerakan.';

  @override
  String get stockCardNote =>
      'Kartu stok = daftar pergerakan (ledger). Saldo tidak pernah diedit langsung, selalu lewat entri baru.';

  @override
  String stockCardOpening(String balance) {
    return 'Saldo sebelumnya $balance';
  }

  @override
  String get stockSourceOpening => 'Stok awal';

  @override
  String get stockSourceSale => 'Penjualan';

  @override
  String get stockSourceSaleReturn => 'Retur penjualan';

  @override
  String get stockSourcePurchase => 'Pembelian';

  @override
  String get stockSourcePurchaseReturn => 'Retur pembelian';

  @override
  String get stockSourceTransfer => 'Transfer';

  @override
  String get stockSourceAdjustment => 'Penyesuaian';

  @override
  String get stockMinimumTitle => 'Di bawah stok minimum';

  @override
  String stockMinimumCount(int count) {
    return '$count produk';
  }

  @override
  String get stockMinimumEmpty => 'Semua stok di atas minimum.';

  @override
  String get stockMinimumPurchaseSoon =>
      'Pesanan pembelian dari daftar ini menyusul bersama modul Pembelian.';

  @override
  String get stockLocationsHint =>
      'Etalase, gudang, atau rak terpisah di cabang ini.';

  @override
  String get stockLocationDefault => 'Bawaan';

  @override
  String get stockLocationNameLabel => 'Nama lokasi';

  @override
  String get stockLocationAdd => 'Tambah lokasi';

  @override
  String get stockLocationRename => 'Ganti nama';

  @override
  String get stockLocationSave => 'Simpan';

  @override
  String get stockLocationCancel => 'Batal';

  @override
  String get stockLocationErrorEmpty => 'Nama lokasi wajib diisi.';

  @override
  String get stockLocationErrorTooLong => 'Nama lokasi maks 40 karakter.';

  @override
  String get stockLocationErrorDuplicate =>
      'Nama lokasi sudah dipakai di cabang ini.';

  @override
  String get stockRemoveLine => 'Hapus baris';

  @override
  String get menuMasterData => 'Master data';

  @override
  String get masterTitle => 'Master data';

  @override
  String get masterSubtitle =>
      'Data referensi yang dipakai produk, stok, kasir & laporan';

  @override
  String get masterTabCategories => 'Kategori';

  @override
  String get masterTabUnits => 'Satuan';

  @override
  String get masterTabLocations => 'Lokasi stok';

  @override
  String get masterTabPayments => 'Metode pembayaran';

  @override
  String get masterLoadFailed => 'Gagal memuat master data.';

  @override
  String get masterCategoryAdd => 'Kategori';

  @override
  String get masterColCategory => 'Kategori';

  @override
  String get masterColProducts => 'Produk';

  @override
  String get masterColActive => 'Aktif';

  @override
  String get masterCategoryEdit => 'Ubah';

  @override
  String masterMoveUp(String name) {
    return 'Naikkan $name';
  }

  @override
  String masterMoveDown(String name) {
    return 'Turunkan $name';
  }

  @override
  String get masterOrderHint =>
      'Urutan ini dipakai tab kategori di layar kasir. Ketuk panah untuk menaikkan atau menurunkan.';

  @override
  String masterProductCount(int count) {
    return '$count produk';
  }

  @override
  String get masterCategoryHidden => 'Tidak di kasir';

  @override
  String get masterCategoryInactive => 'Nonaktif';

  @override
  String get masterCategoryEmpty =>
      'Belum ada kategori. Tambahkan di sini atau langsung dari form produk.';

  @override
  String get masterFormNew => 'Kategori baru';

  @override
  String get masterFormEdit => 'Ubah kategori';

  @override
  String get masterFormName => 'Nama kategori';

  @override
  String get masterFormParent => 'Kategori induk';

  @override
  String get masterFormParentNone => '(tidak ada)';

  @override
  String get masterFormParentLocked =>
      'Kategori ini punya subkategori, jadi tidak bisa diberi induk.';

  @override
  String get masterFormColor => 'Warna';

  @override
  String get masterColorNone => 'Tanpa warna';

  @override
  String masterColorPick(int number) {
    return 'Warna $number';
  }

  @override
  String get masterFormShowInCashier => 'Tampil di kasir';

  @override
  String get masterFormShowInCashierHint =>
      'Muncul sebagai tab kategori di layar kasir.';

  @override
  String get masterFormActive => 'Aktif';

  @override
  String get masterFormActiveHint =>
      'Kategori nonaktif tidak tampil di kasir dan tidak disarankan di form produk; produknya tetap dijual.';

  @override
  String get masterFormCancel => 'Batal';

  @override
  String get masterFormSave => 'Simpan kategori';

  @override
  String get masterFormDelete => 'Hapus kategori';

  @override
  String masterCategorySaved(String name) {
    return 'Kategori $name tersimpan.';
  }

  @override
  String get masterErrNameEmpty => 'Nama kategori wajib diisi.';

  @override
  String masterErrNameTooLong(int max) {
    return 'Nama kategori maks $max karakter.';
  }

  @override
  String get masterErrNameDuplicate => 'Nama kategori sudah dipakai.';

  @override
  String get masterErrParentMissing => 'Kategori induk tidak ditemukan.';

  @override
  String get masterErrParentSelf =>
      'Kategori tidak bisa menjadi induk dirinya sendiri.';

  @override
  String get masterErrParentNested =>
      'Induk harus kategori utama (hanya satu tingkat).';

  @override
  String get masterErrHasChildren =>
      'Kategori yang punya subkategori tidak bisa diberi induk.';

  @override
  String get masterErrColor => 'Pilih warna dari palet.';

  @override
  String masterInUseProducts(int count) {
    return 'Tidak bisa dihapus: masih dipakai $count produk.';
  }

  @override
  String masterInUseChildren(int count) {
    return 'Tidak bisa dihapus: masih punya $count subkategori.';
  }

  @override
  String get masterActionFailed => 'Gagal menyimpan. Coba lagi.';

  @override
  String get masterUnitsHint =>
      'Satuan dipakai di form produk sebagai satuan dasar dan satuan konversi. Ganti nama langsung terlihat di semua produk.';

  @override
  String get masterUnitName => 'Nama satuan';

  @override
  String get masterUnitAdd => 'Tambah satuan';

  @override
  String masterUnitRename(String name) {
    return 'Ganti nama $name';
  }

  @override
  String masterUnitDelete(String name) {
    return 'Hapus $name';
  }

  @override
  String get masterUnitSave => 'Simpan';

  @override
  String get masterUnitCancel => 'Batal';

  @override
  String get masterUnitErrEmpty => 'Nama satuan wajib diisi.';

  @override
  String masterUnitErrTooLong(int max) {
    return 'Nama satuan maks $max karakter.';
  }

  @override
  String get masterUnitErrDuplicate => 'Nama satuan sudah dipakai.';

  @override
  String get masterUnitEmpty =>
      'Belum ada satuan. Satuan juga dibuat otomatis dari form produk.';

  @override
  String get masterLocationsHint =>
      'Lokasi stok per cabang (etalase, gudang). Tambah dan ganti nama lokasi di layar Stok.';

  @override
  String get masterLocationsManage => 'Kelola di Stok';

  @override
  String get masterPaymentsHint =>
      'Metode bayar yang tersedia di kasir. QRIS statis, struk, dan printer diatur di Pengaturan.';

  @override
  String get masterPaymentsOpen => 'Buka Pengaturan';

  @override
  String get masterPaymentQrisHint =>
      'Gambar stiker QRIS + tombol Sudah Terbayar';

  @override
  String get masterPaymentAlways => 'Selalu tersedia';

  @override
  String masterInUseBoth(int products, int children) {
    return 'Tidak bisa dihapus: masih dipakai $products produk dan punya $children subkategori.';
  }

  @override
  String masterDeleteTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get masterDeleteBody =>
      'Data yang dihapus tidak tampil lagi di daftar dan pilihan.';

  @override
  String get masterDeleteConfirm => 'Hapus';

  @override
  String get masterDeleteCancel => 'Batal';

  @override
  String get menuTables => 'Meja';

  @override
  String billTableLabel(String label) {
    return 'Meja $label';
  }

  @override
  String billTakeAwayLabel(String label) {
    return 'Take away $label';
  }

  @override
  String paymentBillLines(String label, int count) {
    return '$label · $count item';
  }

  @override
  String get successBackToTables => 'Kembali ke meja';

  @override
  String get receiptOrder => 'Pesanan';

  @override
  String get receiptSubtotal => 'Subtotal';

  @override
  String receiptService(String pct) {
    return 'Service $pct';
  }

  @override
  String receiptTax(String pct) {
    return 'PB1 $pct';
  }

  @override
  String get cashierBillLoadFailed =>
      'Bill gagal dibuka. Mungkin sudah dibayar atau dibatalkan.';

  @override
  String get cashierBillBack => 'Kembali ke meja';

  @override
  String get diningTitle => 'Meja';

  @override
  String diningSubtitle(String staff, int occupied, int total) {
    return 'Pelayan: $staff · $occupied dari $total meja terisi';
  }

  @override
  String get diningDineIn => 'Dine in';

  @override
  String get diningTakeAway => 'Take away';

  @override
  String get diningLegendEmpty => 'Kosong';

  @override
  String get diningLegendOpen => 'Terisi · open bill';

  @override
  String get diningLegendRequested => 'Minta bill';

  @override
  String get diningAllAreas => 'Semua';

  @override
  String get diningNoArea => 'Tanpa area';

  @override
  String get diningNoTables =>
      'Belum ada meja. Tambahkan di Master data › Meja & area.';

  @override
  String diningSeats(int count) {
    return '$count kursi';
  }

  @override
  String diningMinutes(int m) {
    return '$m mnt';
  }

  @override
  String diningHours(int h, int m) {
    return '$h j $m mnt';
  }

  @override
  String diningDays(int d) {
    return '$d hari';
  }

  @override
  String get diningTakeAwayNew => 'Take away baru';

  @override
  String get diningTakeAwayNone => 'Belum ada take away terbuka.';

  @override
  String diningTakeAwayItems(int count, String time) {
    return '$count item · $time';
  }

  @override
  String get diningStatusNew => 'Baru';

  @override
  String get diningStatusKitchen => 'Di dapur';

  @override
  String get diningStatusServed => 'Disajikan';

  @override
  String get diningStatusReady => 'Siap ambil';

  @override
  String get diningStatusEmpty => 'Kosong';

  @override
  String get diningDeleteEmpty => 'Hapus bill kosong';

  @override
  String get diningSelectHint =>
      'Pilih meja atau take away untuk melihat bill.';

  @override
  String diningBillTableTitle(String label) {
    return 'Meja $label · Open bill';
  }

  @override
  String diningBillTakeAwayTitle(String label) {
    return '$label · Take away';
  }

  @override
  String diningBillGuests(int count) {
    return '$count tamu';
  }

  @override
  String diningBillOpened(String time) {
    return 'dibuka $time';
  }

  @override
  String diningBillServer(String name) {
    return 'Pelayan $name';
  }

  @override
  String get diningAddMenu => 'Menu';

  @override
  String get diningBillEmpty => 'Belum ada item. Ketuk + Menu untuk menambah.';

  @override
  String get diningMarkServed => 'Tandai disajikan';

  @override
  String get diningRemoveItem => 'Hapus item';

  @override
  String get diningSubtotal => 'Subtotal';

  @override
  String diningService(String pct) {
    return 'Service $pct (dine in)';
  }

  @override
  String diningTax(String pct) {
    return 'PB1 $pct';
  }

  @override
  String get diningTotal => 'Total';

  @override
  String diningSend(int count) {
    return 'Kirim ke dapur ($count item baru)';
  }

  @override
  String get diningRequestBill => 'Minta bill';

  @override
  String get diningCancelRequest => 'Batal minta bill';

  @override
  String get diningMove => 'Pindah meja';

  @override
  String get diningVoid => 'Batalkan bill';

  @override
  String diningPay(String amount) {
    return 'Tutup & bayar · $amount';
  }

  @override
  String get diningPayNoPermission =>
      'Pembayaran oleh kasir (butuh izin penjualan).';

  @override
  String get diningBack => 'Kembali ke meja';

  @override
  String diningOpenTitle(String label) {
    return 'Buka meja $label';
  }

  @override
  String get diningGuests => 'Jumlah tamu';

  @override
  String get diningGuestsInvalid => 'Isi 1–99 tamu.';

  @override
  String get diningOpen => 'Buka bill';

  @override
  String get diningCancel => 'Batal';

  @override
  String get diningCustomerName => 'Nama pemesan (opsional)';

  @override
  String get diningCreate => 'Buat';

  @override
  String diningMoveTitle(String label) {
    return 'Pindahkan $label ke';
  }

  @override
  String get diningMoveNone => 'Tidak ada meja kosong.';

  @override
  String diningVoidTitle(String label) {
    return 'Batalkan bill $label?';
  }

  @override
  String get diningVoidBody =>
      'Bill ditutup tanpa pembayaran dan stok tidak berubah. Alasan tersimpan di riwayat.';

  @override
  String get diningVoidReason => 'Alasan';

  @override
  String get diningVoidReasonInvalid =>
      'Alasan wajib diisi, maks 120 karakter.';

  @override
  String get diningVoidKeep => 'Kembali';

  @override
  String diningMenuTitle(String label) {
    return 'Tambah menu · $label';
  }

  @override
  String get diningSearch => 'Cari menu';

  @override
  String get diningNote => 'Catatan dapur untuk item berikutnya (opsional)';

  @override
  String get diningNoteTooLong => 'Catatan maks 120 karakter.';

  @override
  String diningAdded(String name) {
    return 'Ditambahkan: $name';
  }

  @override
  String get diningDone => 'Selesai';

  @override
  String get diningNoMenu => 'Menu tidak ditemukan.';

  @override
  String get diningLoadFailed => 'Data meja gagal dimuat.';

  @override
  String get diningErrorLocked =>
      'Item yang sudah di dapur tidak bisa diubah atau dihapus.';

  @override
  String get diningErrorOccupied => 'Meja sudah punya bill terbuka.';

  @override
  String get diningErrorNothingToSend => 'Tidak ada item baru untuk dikirim.';

  @override
  String get diningErrorNotFound => 'Bill tidak ditemukan atau sudah ditutup.';

  @override
  String get diningErrorNotEmpty => 'Bill masih berisi item.';

  @override
  String get diningErrorUnavailable => 'Menu tidak tersedia lagi.';

  @override
  String get diningErrorInput => 'Isian tidak sah.';

  @override
  String get diningErrorPermission => 'Anda tidak punya izin untuk aksi ini.';

  @override
  String get diningErrorGeneric => 'Aksi gagal. Coba lagi.';

  @override
  String get ticketDialogTitle => 'Terkirim ke dapur';

  @override
  String get ticketHeading => 'TIKET DAPUR';

  @override
  String ticketDineIn(String label) {
    return 'Meja $label · Dine in';
  }

  @override
  String ticketTakeAway(String label) {
    return '$label · Take away';
  }

  @override
  String get ticketNo => 'No';

  @override
  String get ticketTime => 'Jam';

  @override
  String get ticketStaff => 'Pelayan';

  @override
  String get ticketFooter => 'Item baru saja · tanpa harga';

  @override
  String get ticketPrint => 'Cetak tiket';

  @override
  String get ticketClose => 'Tutup';

  @override
  String get ticketPrinted => 'Tiket terkirim ke printer.';

  @override
  String get ticketPrintFailed =>
      'Tiket gagal dicetak. Periksa printer di Pengaturan › Struk & printer.';

  @override
  String get masterTabTables => 'Meja & area';

  @override
  String get diningSetupHint =>
      'Meja dipakai di layar Meja (F&B). Nama meja unik per cabang; area opsional.';

  @override
  String get diningSetupAreas => 'Area';

  @override
  String get diningSetupAreaAdd => 'Tambah area';

  @override
  String diningSetupAreaTables(int count) {
    return '$count meja';
  }

  @override
  String get diningSetupAreasEmpty =>
      'Belum ada area. Contoh: Indoor, Teras, Lantai 2.';

  @override
  String get diningSetupTables => 'Meja';

  @override
  String get diningSetupTableAdd => 'Tambah meja';

  @override
  String get diningSetupTableRange => 'Tambah beberapa';

  @override
  String get diningSetupTablesEmpty =>
      'Belum ada meja. Pakai Tambah beberapa untuk membuat M1–M12 sekaligus.';

  @override
  String get diningSetupNoArea => 'Tanpa area';

  @override
  String get diningSetupName => 'Nama';

  @override
  String get diningSetupArea => 'Area';

  @override
  String get diningSetupSeats => 'Kursi';

  @override
  String get diningSetupPrefix => 'Awalan';

  @override
  String get diningSetupFrom => 'Mulai';

  @override
  String get diningSetupTo => 'Sampai';

  @override
  String diningSetupPreview(String names) {
    return 'Akan dibuat: $names';
  }

  @override
  String get diningSetupRangeInvalid =>
      'Rentang tidak sah (1–50 meja sekaligus).';

  @override
  String get diningSetupNewArea => 'Area baru';

  @override
  String get diningSetupRenameArea => 'Ganti nama area';

  @override
  String get diningSetupNewTable => 'Meja baru';

  @override
  String get diningSetupEditTable => 'Ubah meja';

  @override
  String get diningSetupSave => 'Simpan';

  @override
  String get diningSetupCancel => 'Batal';

  @override
  String get diningSetupDelete => 'Hapus';

  @override
  String diningSetupDeleteTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get diningSetupDeleteBody =>
      'Data yang dihapus tidak tampil lagi di layar Meja.';

  @override
  String get diningSetupMoveUp => 'Naikkan';

  @override
  String get diningSetupMoveDown => 'Turunkan';

  @override
  String get diningSetupEdit => 'Ubah';

  @override
  String get diningSetupErrNameEmpty => 'Nama wajib diisi.';

  @override
  String diningSetupErrNameTooLong(int max) {
    return 'Nama maks $max karakter.';
  }

  @override
  String get diningSetupErrNameDuplicate => 'Nama sudah dipakai.';

  @override
  String diningSetupErrNameDuplicateAt(String name) {
    return 'Nama $name sudah dipakai.';
  }

  @override
  String get diningSetupErrSeats => 'Kursi 1–99.';

  @override
  String diningSetupErrAreaInUse(int count) {
    return 'Area masih punya $count meja. Pindahkan atau hapus mejanya dulu.';
  }

  @override
  String get diningSetupErrTableBusy => 'Meja masih punya bill terbuka.';

  @override
  String get diningSetupErrGeneric => 'Aksi gagal. Coba lagi.';

  @override
  String get diningSetupLoadFailed => 'Data meja gagal dimuat.';

  @override
  String get settingsSectionTaxes => 'Pajak & service';

  @override
  String get fnbRatesTitle => 'Pajak & service';

  @override
  String get fnbRatesSubtitle =>
      'Berlaku untuk open bill di layar Meja cabang ini.';

  @override
  String get fnbRatesService => 'Service charge (%)';

  @override
  String get fnbRatesServiceHint => '0–30%, kelipatan 0,5';

  @override
  String get fnbRatesTax => 'PB1 / pajak restoran (%)';

  @override
  String get fnbRatesTaxHint => '0–20%, kelipatan 0,5';

  @override
  String get fnbRatesInvalidService => 'Isi 0–30 dengan kelipatan 0,5.';

  @override
  String get fnbRatesInvalidTax => 'Isi 0–20 dengan kelipatan 0,5.';

  @override
  String get fnbRatesNote =>
      'Service hanya untuk dine in. PB1 dihitung dari subtotal + service.';

  @override
  String get fnbRatesPreview => 'Contoh dine in';

  @override
  String get fnbRatesSave => 'Simpan tarif';

  @override
  String get fnbRatesSaved => 'Tarif tersimpan.';

  @override
  String get fnbRatesLoadFailed => 'Tarif gagal dimuat.';

  @override
  String get fnbRatesSaveFailed => 'Tarif gagal disimpan.';

  @override
  String get masterTabModifiers => 'Grup modifier';

  @override
  String get modifierHint =>
      'Perubahan berlaku untuk pesanan baru; nota lama menyimpan salinan nama & harga modifier.';

  @override
  String get modifierGroups => 'Grup modifier';

  @override
  String get modifierAdd => 'Tambah grup';

  @override
  String get modifierEmpty =>
      'Belum ada grup modifier. Contoh: Ukuran, Level gula, Topping.';

  @override
  String get modifierLoadFailed => 'Grup modifier gagal dimuat.';

  @override
  String modifierRuleRequired(int count) {
    return 'Wajib · pilih $count';
  }

  @override
  String modifierRuleRequiredRange(int min, int max) {
    return 'Wajib · pilih $min–$max';
  }

  @override
  String modifierRuleOptional(int max) {
    return 'Opsional · maks $max';
  }

  @override
  String modifierOptionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count opsi',
    );
    return '$_temp0';
  }

  @override
  String modifierUsedBy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dipakai $count menu',
      zero: 'belum dipakai menu',
    );
    return '$_temp0';
  }

  @override
  String get modifierNewGroup => 'Grup modifier baru';

  @override
  String get modifierEditGroup => 'Ubah grup modifier';

  @override
  String get modifierName => 'Nama grup';

  @override
  String get modifierRequired => 'Wajib dipilih';

  @override
  String get modifierRequiredHint =>
      'Pelanggan harus memilih sebelum menu masuk bill.';

  @override
  String get modifierMin => 'Minimal pilih';

  @override
  String get modifierMax => 'Maksimal pilih';

  @override
  String get modifierMaxHint => 'Maksimal 1 tampil sebagai pilihan tunggal.';

  @override
  String get modifierOptions => 'Opsi';

  @override
  String get modifierOptionName => 'Nama opsi';

  @override
  String get modifierOptionPrice => 'Tambahan harga';

  @override
  String get modifierOptionPriceHint => 'Minus untuk potongan, mis. -3.000.';

  @override
  String get modifierOptionDefault => 'Bawaan';

  @override
  String get modifierOptionAvailable => 'Tersedia';

  @override
  String get modifierOptionSoldOut => 'Habis';

  @override
  String get modifierOptionAdd => 'Tambah opsi';

  @override
  String get modifierOptionRemove => 'Hapus opsi';

  @override
  String get modifierErrNameEmpty => 'Nama grup wajib diisi.';

  @override
  String modifierErrNameTooLong(int max) {
    return 'Maksimal $max karakter.';
  }

  @override
  String get modifierErrNameDuplicate => 'Nama grup sudah dipakai.';

  @override
  String modifierErrSelectRange(int max) {
    return 'Minimal harus ≤ maksimal, maksimal 1–$max.';
  }

  @override
  String get modifierErrMinAboveOptions =>
      'Minimal pilih melebihi jumlah opsi.';

  @override
  String modifierErrOptionCount(int max) {
    return 'Isi 1–$max opsi.';
  }

  @override
  String get modifierErrOptionNameEmpty => 'Nama opsi wajib diisi.';

  @override
  String get modifierErrOptionNameDuplicate => 'Nama opsi kembar.';

  @override
  String get modifierErrOptionPrice =>
      'Tambahan harga −Rp 1.000.000 s.d. Rp 1.000.000.';

  @override
  String get modifierErrDefaultsAboveMax =>
      'Opsi bawaan lebih banyak dari maksimal pilih.';

  @override
  String modifierErrInUse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Grup masih dipasang di $count menu. Lepas dulu dari form menu.',
    );
    return '$_temp0';
  }

  @override
  String get modifierErrGeneric => 'Gagal menyimpan. Coba lagi.';

  @override
  String modifierDeleteTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get modifierDeleteBody =>
      'Opsi grup ikut terhapus. Nota lama tetap menyimpan salinannya.';

  @override
  String get productTabModifiers => 'Modifier';

  @override
  String get productErrorModifierMissing =>
      'Ada grup modifier yang sudah dihapus. Lepas lalu simpan lagi.';

  @override
  String get productModifiersEmpty =>
      'Belum ada grup terpasang. Menu langsung masuk bill tanpa pilihan.';

  @override
  String get productModifiersHelp =>
      'Urutan grup di sini = urutan di lembar pilih modifier layar Meja.';

  @override
  String get productModifiersNoMaster =>
      'Belum ada grup modifier. Buat dulu di Master data › Grup modifier.';

  @override
  String get productModifierAttach => 'Tambah grup';

  @override
  String get productModifierRemove => 'Lepas';

  @override
  String modifierSheetAdd(String total) {
    return 'Tambah ke bill · $total';
  }

  @override
  String get modifierSheetQty => 'Jumlah';

  @override
  String get modifierSheetLess => 'Kurangi';

  @override
  String get modifierSheetMore => 'Tambah';

  @override
  String get modifierSheetPriceInvalid =>
      'Potongan modifier melebihi harga menu.';

  @override
  String get modifierSheetNote => 'Catatan untuk dapur (opsional)';

  @override
  String get diningErrorModifierRequired =>
      'Pilihan modifier belum lengkap atau tidak sah. Buka lagi menunya.';

  @override
  String get diningErrorModifierSoldOut =>
      'Ada opsi modifier yang habis. Pilih opsi lain.';

  @override
  String get diningErrorModifierPrice =>
      'Potongan modifier melebihi harga menu.';

  @override
  String get diningSplit => 'Split bill';

  @override
  String diningSplitStatus(int paid, int total) {
    return 'Split · $paid dari $total tamu lunas';
  }

  @override
  String diningContinueSplit(String amount) {
    return 'Lanjutkan split · $amount';
  }

  @override
  String get diningErrorSplitLocked =>
      'Bill terkunci karena sudah ada pembayaran bagian. Lanjutkan di layar Split bill.';

  @override
  String paymentPartSubtitle(String bill, String label) {
    return '$bill · Bagian tamu $label';
  }

  @override
  String paymentPartNext(String bill) {
    return '$bill · Tamu berikutnya';
  }

  @override
  String get paymentPartWait => 'Simpan, tunggu konfirmasi';

  @override
  String paymentPartDue(String label) {
    return 'Bagian tamu $label';
  }

  @override
  String get paymentPartBack => 'Kembali ke split';

  @override
  String receiptGuestPayment(String label, String method) {
    return 'Tamu $label · $method';
  }

  @override
  String get cashSessionErrorOpenSplit =>
      'Masih ada split bill yang sebagian dibayar. Lunasi atau batalkan bagian yang menunggu sebelum menutup sesi.';

  @override
  String billSplitTitle(String bill, int guests) {
    return 'Split bill · $bill · $guests tamu';
  }

  @override
  String billSplitRates(String service, String tax) {
    return 'Service $service · PB1 $tax';
  }

  @override
  String get billSplitRatesOff => 'Pajak & service: tidak aktif';

  @override
  String get billSplitChooseMode => 'Pilih cara membagi tagihan.';

  @override
  String get billSplitModeItem => 'Per item';

  @override
  String get billSplitModeEqual => 'Bagi rata';

  @override
  String get billSplitModeAmount => 'Nominal bebas';

  @override
  String get billSplitGuests => 'Jumlah tamu';

  @override
  String get billSplitGuestLess => 'Kurangi tamu';

  @override
  String get billSplitGuestMore => 'Tambah tamu';

  @override
  String get billSplitItems => 'Item di bill';

  @override
  String get billSplitItemsHint =>
      'Ketuk tamu untuk memberi satu porsi. Item lebih dari 1 dibagi per porsi.';

  @override
  String billSplitPortionPrice(String price) {
    return '$price / porsi';
  }

  @override
  String billSplitUnassignedCount(int count) {
    return '$count porsi belum punya tamu.';
  }

  @override
  String billSplitGuest(String label) {
    return 'Tamu $label';
  }

  @override
  String get billSplitGuestEmpty => 'Belum ada porsi.';

  @override
  String get billSplitStatusUnpaid => 'Belum bayar';

  @override
  String billSplitStatusPaid(String methods) {
    return 'Lunas · $methods';
  }

  @override
  String get billSplitStatusPending => 'QRIS statis · menunggu';

  @override
  String get billSplitCancelPayment => 'Batalkan';

  @override
  String billSplitPay(String label) {
    return 'Bayar bagian $label';
  }

  @override
  String billSplitNextGuest(String label) {
    return 'Tamu berikutnya ($label)';
  }

  @override
  String get billSplitAmount => 'Nominal';

  @override
  String billSplitAmountHint(String amount) {
    return 'Maks $amount';
  }

  @override
  String get billSplitPayAmount => 'Bayar';

  @override
  String get billSplitTotal => 'Total bill';

  @override
  String billSplitPaid(String labels) {
    return 'Sudah dibayar ($labels)';
  }

  @override
  String billSplitPending(String labels) {
    return 'Menunggu konfirmasi ($labels)';
  }

  @override
  String get billSplitRemaining => 'Sisa tagihan';

  @override
  String get billSplitNote =>
      'Bill tetap terbuka sampai semua bagian lunas. Tiap bagian dicatat sebagai pembayaran di nota yang sama, jadi laporan & stok tidak terpecah.';

  @override
  String get billSplitCancel => 'Batalkan split';

  @override
  String get billSplitLocked =>
      'Pembagian terkunci karena sudah ada pembayaran bagian. Batalkan bagian QRIS yang menunggu untuk mengubahnya.';

  @override
  String get billSplitDone => 'Bill lunas';

  @override
  String billSplitDoneBody(String number) {
    return 'Semua bagian lunas. Nota $number tersimpan.';
  }

  @override
  String get billSplitLoadFailed => 'Split bill tidak bisa dimuat.';

  @override
  String get billSplitErrorLocked =>
      'Sudah ada pembayaran bagian; pembagian tidak bisa diubah.';

  @override
  String get billSplitErrorGuests => 'Jumlah tamu 2–8.';

  @override
  String get billSplitErrorUnassigned => 'Bagikan semua porsi ke tamu dulu.';

  @override
  String get billSplitErrorPartPaid => 'Tamu ini sudah membayar.';

  @override
  String get billSplitErrorAmount =>
      'Nominal harus lebih dari 0 dan tidak melebihi sisa tagihan.';

  @override
  String get billSplitErrorNothingDue => 'Tamu ini tidak punya tagihan.';

  @override
  String get billSplitErrorPending =>
      'Hanya QRIS yang bisa menunggu konfirmasi.';

  @override
  String get billSplitErrorGeneric => 'Split bill gagal. Coba lagi.';

  @override
  String diningVoidSplitPaid(String amount) {
    return 'Bagian yang sudah dibayar ($amount) dikembalikan ke tamu dan tidak masuk sesi kasir.';
  }

  @override
  String get floorErrorImageTooLarge => 'Gambar denah lebih dari 5 MB.';

  @override
  String get floorErrorImageFormat =>
      'Format tidak didukung. Pakai PNG, JPG, WebP, atau SVG.';

  @override
  String get floorErrorNameEmpty => 'Nama meja wajib diisi.';

  @override
  String get floorErrorNameTooLong => 'Nama meja maksimal 20 karakter.';

  @override
  String get floorErrorNameDuplicate =>
      'Nama meja sudah dipakai di cabang ini.';

  @override
  String get floorErrorSeats => 'Kursi 1 sampai 99.';

  @override
  String get floorErrorSize => 'Lebar dan tinggi 20 sampai 600.';

  @override
  String get floorErrorPosition => 'Posisi meja di luar denah.';

  @override
  String get floorErrorInUse => 'Meja yang dihapus masih punya bill terbuka.';

  @override
  String get floorErrorPermission => 'Butuh izin Kelola pengaturan.';

  @override
  String get floorErrorGeneric => 'Tata letak gagal disimpan. Coba lagi.';

  @override
  String floorErrorOn(String table, String message) {
    return '$table: $message';
  }

  @override
  String get floorShapeRound => 'Bulat';

  @override
  String get floorShapeSquare => 'Kotak';

  @override
  String get floorShapeLong => 'Panjang';

  @override
  String get floorShapeBar => 'Kursi bar';

  @override
  String get floorDiscardTitle => 'Buang perubahan?';

  @override
  String get floorDiscardBody =>
      'Perubahan tata letak yang belum disimpan akan hilang.';

  @override
  String get floorDiscardKeep => 'Batal';

  @override
  String get floorDiscardConfirm => 'Buang';

  @override
  String get floorLoadFailed => 'Denah gagal dimuat.';

  @override
  String get floorBack => 'Kembali';

  @override
  String get floorNoArea =>
      'Belum ada area. Tambah area dulu, mis. Indoor atau Teras.';

  @override
  String get floorTitle => 'Atur denah meja';

  @override
  String get floorSubtitle => 'Pengaturan › Meja & area (F&B)';

  @override
  String get floorAddArea => '+ Area';

  @override
  String get floorAddAreaTitle => 'Area baru';

  @override
  String get floorAreaName => 'Nama area';

  @override
  String get floorAddAreaSave => 'Tambah';

  @override
  String get floorGridInfoTitle => 'Mode Grid';

  @override
  String floorGridInfoBody(String area) {
    return 'Meja area $area tampil sebagai kotak berurutan di layar Meja. Pilih Denah untuk mengunggah gambar denah dan mengatur posisi meja.';
  }

  @override
  String floorSeats(int count) {
    return '$count kursi';
  }

  @override
  String get floorUndo => 'Urungkan';

  @override
  String get floorRedo => 'Ulangi';

  @override
  String get floorReplaceImage => 'Ganti gambar denah';

  @override
  String get floorOpacity => 'Transparansi denah';

  @override
  String floorSnap(int size) {
    return 'Snap ke grid $size px';
  }

  @override
  String floorZoom(int percent) {
    return 'Zoom $percent%';
  }

  @override
  String get floorZoomIn => 'Perbesar';

  @override
  String get floorZoomOut => 'Perkecil';

  @override
  String get floorZoomFit => 'Pas layar';

  @override
  String floorUploadTitle(String area) {
    return 'Unggah gambar denah area $area';
  }

  @override
  String get floorUploadBody =>
      'Foto sketsa tangan, hasil export aplikasi denah, atau gambar dari arsitek. PNG / JPG / WebP / SVG, maks. 5 MB.';

  @override
  String get floorPickFile => 'Pilih file';

  @override
  String get floorTakePhoto => 'Ambil foto';

  @override
  String get floorTipsTitle => 'Tips gambar';

  @override
  String get floorTipAngle => 'Sudut pandang';

  @override
  String get floorTipAngleValue => 'Dari atas, lurus';

  @override
  String get floorTipSize => 'Ukuran';

  @override
  String get floorTipSizeValue => 'Lebar minimal 1200 px';

  @override
  String get floorTipContent => 'Isi';

  @override
  String get floorTipContentValue => 'Dinding, pintu, dapur, bar';

  @override
  String get floorTipStorage =>
      'Gambar disimpan di perangkat. Saat hosting aktif, ikut diunggah ke Object Storage seperti foto produk.';

  @override
  String get floorTipGrid =>
      'Tidak punya denah? Pilih mode Grid. Meja tampil seperti biasa dan bisa diganti kapan saja.';

  @override
  String floorPreset(String shape, int seats) {
    return '$shape · $seats kursi';
  }

  @override
  String get floorAddTable => 'Tambah meja';

  @override
  String get floorAddTableHint =>
      'Ketuk untuk menaruh meja di tengah tampilan.';

  @override
  String get floorUnplaced => 'Belum ditempatkan';

  @override
  String get floorUnplacedHint =>
      'Meja yang sudah ada di mode grid tapi belum punya posisi. Ketuk untuk menaruh.';

  @override
  String get floorUnplacedNone => 'Semua meja sudah ditempatkan.';

  @override
  String floorModeTitle(String area) {
    return 'Mode tata letak · $area';
  }

  @override
  String get floorModeGrid => 'Grid';

  @override
  String get floorModeGridHint =>
      'Tanpa denah. Meja tampil sebagai kotak berurutan.';

  @override
  String get floorModeFloor => 'Denah';

  @override
  String get floorModeFloorHint =>
      'Unggah gambar denah, lalu atur posisi meja.';

  @override
  String floorSelected(String name) {
    return 'Meja $name dipilih';
  }

  @override
  String get floorSelectHint =>
      'Ketuk meja di denah untuk mengubah nama, kursi, bentuk, dan ukurannya.';

  @override
  String get floorName => 'Nama';

  @override
  String get floorSeatsLabel => 'Kursi';

  @override
  String get floorShape => 'Bentuk';

  @override
  String get floorWidth => 'Lebar';

  @override
  String get floorHeight => 'Tinggi';

  @override
  String get floorOrientation => 'Orientasi';

  @override
  String get floorHorizontal => 'Mendatar';

  @override
  String get floorVertical => 'Tegak';

  @override
  String get floorCanMerge => 'Boleh digabung dengan meja sebelah';

  @override
  String get floorDelete => 'Hapus meja';

  @override
  String get floorUnsaved => 'Ada perubahan yang belum disimpan.';

  @override
  String get floorSave => 'Simpan tata letak';

  @override
  String get floorSaving => 'Menyimpan…';

  @override
  String get diningLayoutGrid => 'Grid';

  @override
  String get diningLayoutFloor => 'Denah';

  @override
  String get diningArrange => 'Atur denah';

  @override
  String get diningFloorLocked => 'Posisi terkunci · geser & zoom saja';

  @override
  String get diningUnplaced => 'Belum ditempatkan';

  @override
  String get diningNoFloorArea => 'Belum ada area mode denah.';

  @override
  String get approvalTitle => 'Persetujuan manajer';

  @override
  String get approvalStaff => 'Penyetuju';

  @override
  String get approvalPin => 'PIN penyetuju';

  @override
  String get approvalCancel => 'Batal';

  @override
  String get approvalSubmit => 'Setujui';

  @override
  String get approvalNone =>
      'Tidak ada staf lain yang berizin dan punya PIN di cabang ini.';

  @override
  String get approvalNotPermitted =>
      'Staf ini tidak punya izin untuk tindakan ini.';

  @override
  String get approvalVoidSale =>
      'Void transaksi butuh izin sales:void. Minta staf yang berizin memasukkan PIN-nya.';

  @override
  String get approvalVoidBill =>
      'Batalkan bill butuh izin sales:void. Minta staf yang berizin memasukkan PIN-nya.';

  @override
  String get historyTitle => 'Riwayat transaksi';

  @override
  String get historyLoadFailed => 'Riwayat gagal dimuat.';

  @override
  String historySummary(String range, int count, String total) {
    return '$range · $count transaksi · $total';
  }

  @override
  String get historyExport => 'Ekspor Excel';

  @override
  String historyExportSaved(String path) {
    return 'Excel disimpan di $path';
  }

  @override
  String get historyExportFailed => 'Ekspor gagal. Coba lagi.';

  @override
  String get historyEmpty => 'Belum ada transaksi untuk filter ini.';

  @override
  String get historyPickSale =>
      'Pilih nota untuk melihat rincian, retur, cetak ulang, atau void.';

  @override
  String get historyRangeToday => 'Hari ini';

  @override
  String get historyRangeYesterday => 'Kemarin';

  @override
  String get historyRangeWeek => '7 hari';

  @override
  String get historyFilterStaff => 'Kasir';

  @override
  String get historyFilterAllStaff => 'Semua kasir';

  @override
  String get historyFilterMethod => 'Metode';

  @override
  String get historyFilterAllMethods => 'Semua metode';

  @override
  String get historyFilterStatus => 'Status';

  @override
  String get historyStatusAll => 'Semua status';

  @override
  String get historyStatusCompleted => 'Selesai';

  @override
  String get historyStatusPartial => 'Retur sebagian';

  @override
  String get historyStatusReturned => 'Diretur';

  @override
  String get historyStatusReturnedAny => 'Retur';

  @override
  String get historyStatusVoided => 'Void';

  @override
  String get historyColNumber => 'Nota';

  @override
  String get historyColDate => 'Tanggal';

  @override
  String get historyColTime => 'Jam';

  @override
  String get historyColStaff => 'Kasir';

  @override
  String get historyColMethod => 'Metode';

  @override
  String get historyColTotal => 'Total';

  @override
  String get historyColReturned => 'Retur';

  @override
  String get historyColNet => 'Bersih';

  @override
  String get historyColStatus => 'Status';

  @override
  String get historyBack => 'Kembali';

  @override
  String get historyTotalOriginal => 'Total awal';

  @override
  String get historyReturnedTotal => 'Sudah diretur';

  @override
  String get historyNet => 'Nilai bersih';

  @override
  String historyVoidedBy(String name, String reason) {
    return 'Di-void oleh $name: $reason';
  }

  @override
  String get historyItems => 'Item';

  @override
  String historyItemReturned(String qty) {
    return 'diretur $qty';
  }

  @override
  String get historyReturnAll => 'Retur semua';

  @override
  String historyReturnQty(String left) {
    return 'Jumlah retur (sisa $left)';
  }

  @override
  String get historyReturns => 'Retur';

  @override
  String get historyReturnTitle => 'Retur barang';

  @override
  String get historyReturnReason => 'Alasan';

  @override
  String get historyReasonDamaged => 'Barang rusak';

  @override
  String get historyReasonWrongItem => 'Salah ambil';

  @override
  String get historyReasonExpired => 'Kedaluwarsa';

  @override
  String get historyReasonOther => 'Lainnya';

  @override
  String get historyReturnNote => 'Catatan (opsional)';

  @override
  String get historyReturnNoteRequired => 'Catatan (wajib)';

  @override
  String get historyRefundMethod => 'Uang kembali';

  @override
  String get historyRefundCash => 'Tunai dari laci';

  @override
  String get historyRefundTransfer => 'Transfer';

  @override
  String get historyRefundDebt => 'Potong piutang';

  @override
  String get historyRefundCashNeedsSession =>
      'Uang kembali tunai butuh sesi kasir terbuka di perangkat ini.';

  @override
  String get historyRestock => 'Kembalikan barang ke stok';

  @override
  String historyReturnSubmit(String amount) {
    return 'Proses retur · $amount';
  }

  @override
  String get historyReprint => 'Cetak ulang struk';

  @override
  String get historyClose => 'Tutup';

  @override
  String get historyVoid => 'Void transaksi';

  @override
  String get historyVoidHint =>
      'Butuh izin sales:void (PIN manajer). Void membalik stok dan pembayaran lewat entri baru; data lama tidak dihapus.';

  @override
  String historyVoidTitle(String number) {
    return 'Void nota $number?';
  }

  @override
  String get historyVoidBody =>
      'Stok dikembalikan dan nota tidak lagi dihitung di rekap sesi.';

  @override
  String get historyVoidReason => 'Alasan void';

  @override
  String get historyVoidKeep => 'Jangan void';

  @override
  String get historyVoidBlockStatus => 'Nota ini sudah void atau diretur.';

  @override
  String get historyVoidBlockReturned =>
      'Nota yang sudah diretur tidak bisa di-void.';

  @override
  String get historyVoidBlockNotToday => 'Void hanya untuk nota hari ini.';

  @override
  String get historyVoidBlockSession =>
      'Void hanya untuk nota di sesi kasir yang masih buka di perangkat ini.';

  @override
  String get historyErrReturnEmpty => 'Isi jumlah retur minimal satu item.';

  @override
  String get historyErrReturnQuantity => 'Jumlah retur melebihi sisa item.';

  @override
  String get historyErrReturnNote =>
      'Catatan wajib untuk alasan Lainnya (maks. 200 karakter).';

  @override
  String get historyErrReturnStatus => 'Nota ini tidak bisa diretur lagi.';

  @override
  String get historyErrRefundMethod => 'Cara uang kembali ini belum tersedia.';

  @override
  String get historyErrNoSession =>
      'Buka sesi kasir dulu untuk uang kembali tunai.';

  @override
  String get historyErrVoidReason => 'Alasan wajib diisi (maks. 120 karakter).';

  @override
  String get historyErrNotPermitted =>
      'Anda tidak punya izin untuk tindakan ini.';

  @override
  String get historyErrNotFound => 'Nota tidak ditemukan.';

  @override
  String get historyErrGeneric => 'Terjadi kesalahan. Coba lagi.';

  @override
  String get receiptBannerReprint => 'CETAK ULANG';

  @override
  String get receiptBannerVoid => 'VOID';

  @override
  String get receiptReturned => 'Retur';

  @override
  String get receiptNet => 'Bersih';

  @override
  String get stockNoteVoid => 'Nota di-void';

  @override
  String get purchasesTitle => 'Pembelian';

  @override
  String get purchasesSubtitle =>
      'Barang masuk dari supplier, termasuk retur pembelian';

  @override
  String get purchasesNew => 'Pembelian baru';

  @override
  String get purchasesTabPurchases => 'Pembelian';

  @override
  String get purchasesTabReturns => 'Retur pembelian';

  @override
  String get purchasesSearch => 'Cari nomor / supplier';

  @override
  String get purchasesColNumber => 'Nomor';

  @override
  String get purchasesColSupplier => 'Supplier';

  @override
  String get purchasesColTotal => 'Total';

  @override
  String get purchasesColStatus => 'Status';

  @override
  String get purchasesColValue => 'Nilai';

  @override
  String get purchasesColSource => 'Pembelian asal';

  @override
  String get purchasesStatusDraft => 'Draf';

  @override
  String get purchasesStatusPaid => 'Lunas';

  @override
  String get purchasesStatusDebt => 'Hutang';

  @override
  String get purchasesDraftTag => 'draf';

  @override
  String get purchasesReturnTag => 'retur';

  @override
  String get purchasesNoSupplier => 'Tanpa supplier';

  @override
  String get purchasesEmpty => 'Belum ada pembelian.';

  @override
  String get purchasesReturnsEmpty => 'Belum ada retur pembelian.';

  @override
  String get purchasesLoadFailed => 'Pembelian gagal dimuat.';

  @override
  String purchaseFormNew(String number) {
    return 'Pembelian baru · $number';
  }

  @override
  String purchaseFormDraft(String number) {
    return 'Draf · $number';
  }

  @override
  String get purchaseSupplier => 'Supplier';

  @override
  String get purchaseSupplierNew => '+ Supplier baru';

  @override
  String get purchaseSupplierNewName => 'Nama supplier baru';

  @override
  String get purchaseSupplierPick => 'Pilih dari daftar';

  @override
  String get purchaseInvoiceNo => 'No. faktur supplier';

  @override
  String get purchaseDate => 'Tanggal';

  @override
  String get purchaseLocation => 'Masuk ke lokasi';

  @override
  String get purchaseColProduct => 'Produk';

  @override
  String get purchaseColUnit => 'Satuan';

  @override
  String get purchaseColQty => 'Qty';

  @override
  String get purchaseColPrice => 'Harga beli';

  @override
  String get purchaseColSubtotal => 'Subtotal';

  @override
  String get purchaseRemoveLine => 'Hapus baris';

  @override
  String get purchaseScan => '+ Scan / cari produk';

  @override
  String get purchaseScanHint => 'Barcode, SKU, atau nama produk';

  @override
  String purchaseScanNotFound(String code) {
    return 'Produk \"$code\" tidak ditemukan.';
  }

  @override
  String get purchaseNoLines =>
      'Belum ada produk. Scan barcode atau cari nama produk.';

  @override
  String get purchasePaidNow => 'Bayar sekarang';

  @override
  String get purchasePayInFull => 'Bayar lunas';

  @override
  String get purchaseFundingFrom => 'Dari';

  @override
  String get fundingStoreCash => 'Kas toko';

  @override
  String get fundingDrawer => 'Kas laci';

  @override
  String get fundingBank => 'Rekening bank';

  @override
  String get purchaseDueOn => 'Jatuh tempo sisa';

  @override
  String get purchaseNote => 'Catatan';

  @override
  String get purchaseSubtotal => 'Subtotal';

  @override
  String get purchaseDiscount => 'Diskon faktur';

  @override
  String get purchaseShipping => 'Ongkos kirim';

  @override
  String get purchaseTotal => 'Total';

  @override
  String get purchaseDebtLeft => 'Sisa jadi hutang';

  @override
  String get purchaseSaveDraft => 'Simpan draf';

  @override
  String get purchaseReceive => 'Terima barang & simpan';

  @override
  String get purchaseDeleteDraft => 'Hapus draf';

  @override
  String purchaseReceiveNote(String location) {
    return 'Saat disimpan: stok $location bertambah (ledger), harga pokok rata-rata diperbarui, hutang supplier tercatat.';
  }

  @override
  String purchaseDraftSaved(String number) {
    return 'Draf $number disimpan.';
  }

  @override
  String get purchaseErrLines => 'Tambahkan minimal satu produk.';

  @override
  String get purchaseErrQty => 'Qty harus lebih dari 0.';

  @override
  String get purchaseErrPrice => 'Harga beli tidak sah.';

  @override
  String get purchaseErrDiscount => 'Diskon tidak boleh melebihi subtotal.';

  @override
  String get purchaseErrShipping => 'Ongkos kirim tidak sah.';

  @override
  String get purchaseErrPaid => 'Bayar tidak boleh melebihi total.';

  @override
  String get purchaseErrSupplier =>
      'Pilih atau ketik supplier untuk pembelian yang berhutang.';

  @override
  String get purchaseErrDueOn =>
      'Isi jatuh tempo, tidak sebelum tanggal pembelian.';

  @override
  String purchaseErrInvoiceNo(int max) {
    return 'No. faktur maksimal $max karakter.';
  }

  @override
  String purchaseErrNote(int max) {
    return 'Catatan maksimal $max karakter.';
  }

  @override
  String get purchaseErrDrawer =>
      'Bayar dari kas laci butuh sesi kasir yang terbuka di perangkat ini.';

  @override
  String get purchaseErrNotEditable =>
      'Pembelian ini sudah diterima dan tidak bisa diubah.';

  @override
  String get purchaseErrNotFound => 'Pembelian tidak ditemukan.';

  @override
  String get purchaseErrNotPermitted =>
      'Anda tidak punya izin mengelola pembelian.';

  @override
  String get purchaseErrGeneric => 'Pembelian gagal disimpan. Coba lagi.';

  @override
  String purchaseFrom(String supplier) {
    return 'Pembelian dari $supplier';
  }

  @override
  String get purchaseBadgePaid => 'Lunas';

  @override
  String get purchaseBadgeDebt => 'Belum lunas · hutang';

  @override
  String get purchaseCreatedBy => 'Dibuat oleh';

  @override
  String get purchaseReceivedTitle => 'Barang diterima';

  @override
  String purchaseReceivedSubtitle(String location) {
    return 'Stok $location bertambah lewat ledger saat pembelian disimpan';
  }

  @override
  String get purchaseColAvgCost => 'HPP rata-rata';

  @override
  String get purchaseColSellPrice => 'Harga jual';

  @override
  String get purchaseColSuggested => 'Saran jual';

  @override
  String get purchaseColChangePrice => 'Ubah harga';

  @override
  String get purchaseBelowSuggested => 'Di bawah saran';

  @override
  String get purchaseSafe => 'Aman';

  @override
  String purchaseApplyPrices(int count) {
    return 'Terapkan harga jual ($count produk)';
  }

  @override
  String get purchasePricesApplied => 'Harga jual diperbarui.';

  @override
  String get purchaseAvgCostNote =>
      'HPP memakai rata-rata tertimbang (moving average) dalam satuan dasar. Saran jual menjaga margin harga jual saat barang diterima. Centang \"Ubah harga\" lalu Terapkan harga jual.';

  @override
  String get purchaseSummary => 'Ringkasan';

  @override
  String get purchasePaidSoFar => 'Sudah dibayar';

  @override
  String get purchaseReturned => 'Diretur';

  @override
  String get purchaseDebt => 'Sisa hutang';

  @override
  String purchaseDueIn(String date, int days) {
    return 'Jatuh tempo $date ($days hari lagi).';
  }

  @override
  String purchaseDueToday(String date) {
    return 'Jatuh tempo $date (hari ini).';
  }

  @override
  String purchaseOverdue(String date, int days) {
    return 'Jatuh tempo $date (lewat $days hari).';
  }

  @override
  String get purchasePayments => 'Pembayaran';

  @override
  String get purchasePaymentDate => 'Tanggal';

  @override
  String get purchasePaymentDesc => 'Keterangan';

  @override
  String get purchasePaymentFrom => 'Dari';

  @override
  String get purchasePaymentAmount => 'Jumlah';

  @override
  String get purchaseDownPayment => 'Bayar di muka';

  @override
  String purchaseReturnReduction(String number) {
    return 'Retur $number (pengurang hutang)';
  }

  @override
  String purchaseReturnRefund(String number) {
    return 'Retur $number (uang kembali)';
  }

  @override
  String get purchaseNoPayments => 'Belum ada pembayaran.';

  @override
  String get purchasePayDebt => 'Bayar hutang';

  @override
  String get purchasePayDebtLater =>
      'Pelunasan hutang menyusul di modul Supplier & hutang.';

  @override
  String get purchaseActions => 'Tindakan';

  @override
  String get purchaseReturnAction => 'Retur pembelian';

  @override
  String get purchaseReturnActionNote =>
      'Membuat dokumen RB-… yang mengurangi stok & hutang. Pembelian yang sudah diterima tidak bisa dihapus, hanya diretur.';

  @override
  String get purchaseReturnTitle => 'Retur pembelian';

  @override
  String purchaseReturnRemaining(String qty) {
    return 'Sisa $qty';
  }

  @override
  String get purchaseReturnQty => 'Qty retur';

  @override
  String get purchaseReturnNote => 'Catatan retur';

  @override
  String get purchaseRefundTo => 'Uang kembali ke';

  @override
  String purchaseReturnSplit(String debt, String refund) {
    return 'Mengurangi hutang $debt · uang kembali $refund';
  }

  @override
  String purchaseReturnSubmit(String amount) {
    return 'Proses retur · $amount';
  }

  @override
  String get purchaseReturnCancel => 'Batal';

  @override
  String get purchaseReturnErrEmpty => 'Isi qty retur minimal satu barang.';

  @override
  String get purchaseReturnErrQty => 'Qty retur melebihi sisa.';

  @override
  String get purchaseReturnErrStock =>
      'Stok di lokasi pembelian tidak cukup untuk diretur.';

  @override
  String get purchaseReturnErrRefund => 'Pilih ke mana uang kembali.';

  @override
  String get purchaseReturnErrStatus =>
      'Hanya pembelian yang sudah diterima yang bisa diretur.';

  @override
  String purchaseReturnDone(String number) {
    return 'Retur $number tercatat.';
  }

  @override
  String get purchaseReturnsMade => 'Retur yang sudah dibuat';

  @override
  String get purchaseDetailLoadFailed => 'Detail pembelian gagal dimuat.';

  @override
  String get purchaseErrLocation =>
      'Lokasi stok tidak ditemukan. Pilih lokasi lain.';

  @override
  String get purchaseRefundToHint => 'Pilih kas atau rekening';
}
