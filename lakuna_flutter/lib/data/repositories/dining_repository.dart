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
    this.modifierGroups = const {},
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

  /// Grup modifier per produk (urut 1.16b) untuk sheet 1.8; produk tanpa
  /// grup tidak ada di peta.
  final Map<UuidValue, List<ModifierGroupDetail>> modifierGroups;

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
    modifierGroups: modifierGroups,
  );
}

/// Meja & open bill (F1-10). Semua aksi butuh `open_bills:manage`;
/// [voidBill] juga `sales:void`.
abstract class DiningRepository {
  Future<Result<DiningData>> load();

  /// Meja dan bill terbuka saja (tanpa menu).
  Future<Result<DiningOverview>> overview();

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

  Future<Result<OpenBill>> moveBill(UuidValue billId, UuidValue tableId);

  Future<Result<void>> voidBill(UuidValue billId, String reason);

  Future<Result<void>> deleteEmptyBill(UuidValue billId);
}
