import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart'
    show ManualDiscount, Money, SalesRules;

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Sesi kasir terbuka yang dipakai kasir (F1-04).
class CashierSession {
  const CashierSession({
    required this.id,
    required this.openedAt,
    required this.openedByName,
  });

  final UuidValue id;
  final DateTime openedAt;
  final String openedByName;
}

/// QRIS statis cabang yang ditampilkan di layar bayar (1.6 / 1.6m).
class CashierQris {
  const CashierQris({
    required this.image,
    this.merchantName = '',
    this.nmid = '',
    this.terminalCode = '',
    this.settlementNote = '',
  });

  /// Stiker utuh (PNG/JPG/WebP).
  final Uint8List image;
  final String merchantName;
  final String nmid;
  final String terminalCode;

  /// *Dana masuk ke*.
  final String settlementNote;
}

/// Isi layar kasir: produk yang bisa dijual, kategorinya, dan sesi kasir.
class CashierData {
  const CashierData({
    required this.products,
    required this.categories,
    this.categoryParents = const {},
    required this.businessName,
    required this.outletName,
    required this.staffName,
    this.timezone,
    this.session,
    this.qris,
    this.canConfirmPayments = false,
    this.canSellOnCredit = false,
    this.receipt = const ReceiptConfig(settings: ReceiptSettings()),
    this.printer,
    this.salesRules = const SalesRules(),
    this.canDiscount = false,
  });

  /// Produk aktif dengan minimal satu varian, urut nama.
  final List<CatalogProduct> products;

  /// Chip kategori: aktif, *Tampil di kasir*, punya produk aktif (langsung
  /// atau lewat subkategori), urut master (F1-09).
  final List<ProductCategory> categories;

  /// Subkategori → induk, agar chip induk ikut memuat produk subkategori.
  final Map<UuidValue, UuidValue> categoryParents;
  final String businessName;
  final String outletName;

  /// Staf yang sedang bertugas.
  final String staffName;

  /// Zona waktu cabang (ID IANA).
  final String? timezone;

  /// `null` bila perangkat belum membuka sesi kasir.
  final CashierSession? session;

  /// `null` bila QRIS statis nonaktif atau gambarnya belum ada.
  final CashierQris? qris;

  /// Staf boleh menekan *Sudah Terbayar* (`payments:confirm`).
  final bool canConfirmPayments;

  /// Staf boleh menyimpan nota sebagai piutang (`debts:manage`, F1-13).
  final bool canSellOnCredit;

  /// Pengaturan struk cabang ini (F1-06).
  final ReceiptConfig receipt;

  /// Printer terpilih di perangkat ini; `null` = belum ada.
  final PrinterSelection? printer;

  /// Aturan *Penjualan & stok* cabang (pembulatan total, F1-18).
  final SalesRules salesRules;

  /// Staf boleh memberi diskon manual tanpa persetujuan (`sales:discount`,
  /// F1-04b).
  final bool canDiscount;
}

/// Kasir retail dan pembayaran (F1-04/F1-05). Izin `sales:create` dicek di
/// sini juga, bukan hanya di menu. Namanya bukan `SaleRepository` karena
/// nama itu dipakai kode generate Serverpod.
abstract class CashierRepository {
  /// Gagal dengan `NotPermitted` atau `StoreNotReady`.
  Future<Result<CashierData>> load();

  /// Menyimpan penjualan dengan satu atau beberapa pembayaran. Gagal
  /// dengan `NotPermitted` (termasuk QRIS tanpa `payments:confirm`),
  /// `CashSessionNotOpen`, `SaleItemUnavailable`, `SalePaymentShort`, atau
  /// galat input lain dari `checkoutSale`. [credit] = jual kredit (F1-13):
  /// [payments] kosong, butuh `debts:manage`, gagal dengan
  /// `SaleCreditInvalid`. [discount] = diskon nota; diskon baris ada di
  /// [lines]. [discountApproverId] = penyetuju PIN (F1-04b) yang baru
  /// diverifikasi di sesi ini; gagal dengan `NotPermitted`,
  /// `DiscountNotPermitted`, `DiscountTooLarge`. [customerId] = pelanggan
  /// nota non-kredit (F1-04d, `CustomerNotFound`). [parkedSaleId] = nota
  /// tersimpan asal keranjang, dihapus saat lunas (`ParkedSaleNotFound`).
  Future<Result<CheckoutResult>> checkout({
    required List<SaleLineRequest> lines,
    required List<SalePaymentRequest> payments,
    SaleCredit? credit,
    ManualDiscount? discount,
    UuidValue? discountApproverId,
    UuidValue? customerId,
    UuidValue? parkedSaleId,
  });

  /// Pelanggan untuk pemilih kredit (1.5b), dengan limit dan piutangnya.
  /// Butuh `debts:manage`.
  Future<Result<CustomersOverview>> creditCustomers();

  /// Pelanggan untuk pemilih di kepala Pesanan (1.4b, F1-04d); cukup
  /// `sales:create`.
  Future<Result<CustomersOverview>> customers();

  /// *Simpan nota* (F1-04d). [replaceId] = nota tersimpan asal keranjang.
  /// Gagal dengan `SaleEmpty`, `SaleItemUnavailable`, `CustomerNotFound`,
  /// `ParkedNoteTooLong`.
  Future<Result<Sale>> park({
    required List<SaleLineRequest> lines,
    ManualDiscount? discount,
    UuidValue? customerId,
    String? note,
    UuidValue? replaceId,
  });

  /// Nota tersimpan cabang ini, terbaru dulu.
  Future<Result<List<ParkedSaleRow>>> parkedSales();

  /// Isi nota tersimpan untuk dilanjutkan; `ParkedSaleNotFound` bila sudah
  /// dibayar atau dihapus.
  Future<Result<ParkedSale>> loadParked(UuidValue id);

  /// Menghapus nota tersimpan.
  Future<Result<void>> deleteParked(UuidValue id);

  /// Open bill F1-10 yang akan dibayar. Gagal dengan `NotPermitted` atau
  /// `BillNotFound`.
  Future<Result<OpenBill>> loadBill(UuidValue billId);

  /// *Tutup & bayar* open bill [billId]. Galat sama dengan [checkout];
  /// bill tanpa item → `SaleEmpty`. [credit] (F1-13b): nota kredit,
  /// [payments] kosong, butuh `debts:manage`.
  Future<Result<CheckoutResult>> payBill(
    UuidValue billId,
    List<SalePaymentRequest> payments, {
    SaleCredit? credit,
  });

  /// Bagian split bill (F1-10c): tamu [guest] (per item / rata) atau
  /// nominal [amount] (nominal bebas). [pending] menyimpan QRIS sebagai
  /// *menunggu* (tanpa `payments:confirm`). Hasil memuat struk bila bill
  /// lunas.
  Future<Result<SplitPayResult>> payBillPart(
    UuidValue billId, {
    String? guest,
    Money? amount,
    required List<SalePaymentRequest> payments,
    bool pending = false,
  });
}
