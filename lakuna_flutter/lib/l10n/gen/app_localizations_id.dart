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
      'Kasir retail, sesi kasir, produk, dan stok sudah bisa dipakai. Pembelian, riwayat, dan laporan menyusul di rilis berikutnya.';

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
}
