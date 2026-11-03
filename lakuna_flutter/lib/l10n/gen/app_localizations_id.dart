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
      'Cetak struk dan bagikan PDF hadir bersama modul Struk & printer.';

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
}
