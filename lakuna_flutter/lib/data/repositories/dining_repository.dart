import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Isi layar Meja (F1-10): meja, bill terbuka, dan menu yang bisa dipesan.
class DiningData {
  const DiningData({
    required this.overview,
    required this.products,
    required this.categories,
    this.categoryParents = const {},
    required this.staffName,
    this.timezone,
    this.canPay = false,
    this.canVoid = false,
    this.receipt = const ReceiptConfig(settings: ReceiptSettings()),
    this.printer,
    this.kitchenPrinter,
    this.modifierGroups = const {},
    this.floorImages = const {},
    this.canArrange = false,
    this.canDiscount = false,
    this.discountNeedsPin = true,
  });

  final DiningOverview overview;

  /// Produk aktif dengan minimal satu varian, urut nama.
  final List<CatalogProduct> products;

  /// Chip kategori menu (sama dengan kasir).
  final List<ProductCategory> categories;
  final Map<UuidValue, UuidValue> categoryParents;

  /// Staf yang sedang bertugas (pelayan).
  final String staffName;

  /// Zona waktu cabang (ID IANA).
  final String? timezone;

  /// Boleh *Tutup & bayar* (`sales:create`).
  final bool canPay;

  /// Boleh *Batalkan bill* (`sales:void`).
  final bool canVoid;

  /// Kertas struk cabang dipakai juga untuk tiket dapur.
  final ReceiptConfig receipt;
  final PrinterSelection? printer;

  /// Printer dapur khusus perangkat ini (F1-10e); `null` = tiket ke
  /// [printer] lewat *Cetak tiket*.
  final KitchenPrinter? kitchenPrinter;

  /// Grup modifier per produk (urut 1.16b) untuk sheet 1.8; produk tanpa
  /// grup tidak ada di peta.
  final Map<UuidValue, List<ModifierGroupDetail>> modifierGroups;

  /// Gambar denah per area (mode Denah 1.7b).
  final Map<UuidValue, FloorImage> floorImages;

  /// Boleh *Atur denah* (`settings:manage`).
  final bool canArrange;

  /// Staf bertugas punya `sales:discount` (F1-04e).
  final bool canDiscount;

  /// Sakelar *Diskon manual butuh PIN manajer*: staf tanpa izin boleh
  /// memberi diskon dengan persetujuan PIN.
  final bool discountNeedsPin;

  /// Tombol *Diskon* tampil di panel bill.
  bool get canOfferDiscount => canDiscount || discountNeedsPin;

  List<ModifierGroupDetail> groupsOf(CatalogProduct p) =>
      modifierGroups[p.id] ?? const [];

  DiningData withOverview(DiningOverview o) => DiningData(
    overview: o,
    products: products,
    categories: categories,
    categoryParents: categoryParents,
    staffName: staffName,
    timezone: timezone,
    canPay: canPay,
    canVoid: canVoid,
    receipt: receipt,
    printer: printer,
    kitchenPrinter: kitchenPrinter,
    modifierGroups: modifierGroups,
    floorImages: floorImages,
    canArrange: canArrange,
    canDiscount: canDiscount,
    discountNeedsPin: discountNeedsPin,
  );
}

/// Meja & open bill (F1-10). Semua aksi butuh `open_bills:manage`;
/// [voidBill] juga `sales:void`.
abstract class DiningRepository {
  Future<Result<DiningData>> load();

  /// Meja dan bill terbuka saja (tanpa menu).
  Future<Result<DiningOverview>> overview();

  /// Jumlah QRIS bagian split bill yang menunggu konfirmasi (Beranda).
  Future<Result<int>> pendingQrisCount();

  Future<Result<OpenBill>> openTable(UuidValue tableId, int guests);

  Future<Result<OpenBill>> openTakeAway(String? customerName);

  /// [modifierIds] = opsi terpilih di sheet 1.8 (gagal dengan
  /// `ModifierSelectionInvalid` / `ModifierPriceInvalid`).
  Future<Result<OpenBill>> addItem(
    UuidValue billId,
    SaleLineRequest line, {
    String? note,
    List<UuidValue> modifierIds = const [],
  });

  /// Nol menghapus item *Baru*.
  Future<Result<OpenBill>> setItemQuantity(UuidValue itemId, Qty quantity);

  Future<Result<OpenBill>> markServed(UuidValue itemId);

  Future<Result<KitchenSendResult>> sendToKitchen(UuidValue billId);

  Future<Result<OpenBill>> setBillRequested(UuidValue billId, bool requested);

  /// Diskon nota bill (F1-04e); `null` menghapus. [approverId] = penyetuju
  /// ber-`sales:discount` yang PIN-nya baru diverifikasi, bila staf tidak
  /// punya izin itu. Gagal dengan `NotPermitted`, `DiscountTooLarge`, atau
  /// `SplitLocked`.
  Future<Result<OpenBill>> setDiscount(
    UuidValue billId,
    ManualDiscount? discount, {
    UuidValue? approverId,
  });

  /// Diskon baris item [itemId] (F1-04g); `null` menghapus. Izin dan
  /// [approverId] sama dengan [setDiscount]. Gagal dengan `NotPermitted`,
  /// `DiscountTooLarge`, atau `SplitLocked`.
  Future<Result<OpenBill>> setItemDiscount(
    UuidValue itemId,
    ManualDiscount? discount, {
    UuidValue? approverId,
  });

  Future<Result<OpenBill>> moveBill(UuidValue billId, UuidValue tableId);

  /// *Gabung meja* (F1-10d): bill [sourceBillId] digabung ke
  /// [targetBillId]. Gagal dengan `BillMergeBlocked`.
  Future<Result<OpenBill>> mergeBill(
    UuidValue targetBillId,
    UuidValue sourceBillId,
  );

  /// Pelanggan untuk pemilih *Pelanggan* bill (F1-10f), urut nama.
  Future<Result<CustomersOverview>> customers();

  /// Memilih atau (`null`) menghapus pelanggan bill dan menghitung ulang
  /// harga grupnya (F1-10f). Gagal dengan `BillCustomerBlocked` atau
  /// `CustomerNotFound`.
  Future<Result<OpenBill>> setBillCustomer(
    UuidValue billId,
    UuidValue? customerId,
  );

  /// [approverId] = penyetuju ber-`sales:void` yang PIN-nya sudah
  /// diverifikasi (F1-11), bila staf bertugas tidak punya izin itu.
  Future<Result<void>> voidBill(
    UuidValue billId,
    String reason, {
    UuidValue? approverId,
  });

  Future<Result<void>> deleteEmptyBill(UuidValue billId);

  // --- Split bill (F1-10c) --------------------------------------------------

  /// Bill [billId] beserta izin bayar dan konfirmasi QRIS untuk layar 1.9.
  Future<Result<SplitBillData>> loadSplit(UuidValue billId);

  /// Mode split dan jumlah tamu; [mode] `null` membatalkan split. Gagal
  /// dengan `SplitInvalid` atau `SplitLocked`.
  Future<Result<OpenBill>> setSplit(
    UuidValue billId,
    SplitMode? mode,
    int guests,
  );

  /// Satu porsi item [itemId] ke tamu [guest] (`null` = belum dibagi).
  Future<Result<OpenBill>> assignPortion(UuidValue itemId, String? guest);

  /// *Sudah Terbayar* bagian QRIS menunggu; butuh `payments:confirm`.
  Future<Result<SplitPayResult>> confirmSplitPayment(UuidValue paymentId);

  /// Membatalkan bagian QRIS yang menunggu.
  Future<Result<OpenBill>> cancelSplitPayment(UuidValue paymentId);
}

/// Isi layar split bill 1.9.
class SplitBillData {
  const SplitBillData({
    required this.bill,
    required this.canPay,
    required this.canConfirm,
  });

  final OpenBill bill;

  /// `sales:create`: boleh membayar bagian.
  final bool canPay;

  /// `payments:confirm`: boleh menekan *Sudah Terbayar*.
  final bool canConfirm;
}
