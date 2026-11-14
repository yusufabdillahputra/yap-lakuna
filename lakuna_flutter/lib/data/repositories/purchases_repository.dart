import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Money, Qty;

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Isian awal *Pembelian baru* dari daftar stok minimum (F1-08c): lokasi
/// terima dan varian + jumlah saran (satuan dasar).
@immutable
class PurchaseRestock {
  const PurchaseRestock({
    required this.locationId,
    required this.locationName,
    required this.lines,
  });

  final UuidValue locationId;
  final String locationName;
  final List<({UuidValue variantId, Qty quantity})> lines;
}

/// Data awal layar Pembelian (F1-12, 1.19).
@immutable
class PurchaseSetup {
  const PurchaseSetup({
    required this.locations,
    required this.suppliers,
    required this.products,
    required this.today,
    required this.nextNumber,
    this.timezone,
    this.hasOpenSession = false,
    this.canUseDrawer = true,
    this.canEditPrices = true,
    this.staffName = '',
  });

  /// Lokasi stok cabang, bawaan dulu.
  final List<StockLocation> locations;
  final List<Supplier> suppliers;

  /// Produk aktif yang melacak stok (bisa dibeli).
  final List<CatalogProduct> products;

  /// Tanggal lokal cabang hari ini.
  final DateTime today;

  /// Nomor PB berikutnya untuk judul form.
  final String nextNumber;
  final String? timezone;

  /// Perangkat ini punya sesi kasir terbuka (bayar dari kas laci).
  final bool hasOpenSession;

  /// Staf boleh memakai uang laci (`cash_movements:create`).
  final bool canUseDrawer;

  /// Staf boleh menerapkan harga jual (`products:manage`).
  final bool canEditPrices;

  /// Nama staf yang bertugas (tercetak di PDF pembelian, F1-12c).
  final String staffName;
}

/// Pembelian dan retur beli (F1-12). Semua aksi butuh `purchases:manage`,
/// dicek di sini juga.
abstract class PurchasesRepository {
  Future<Result<PurchaseSetup>> load();

  Future<Result<List<PurchaseRow>>> list({String query = ''});

  Future<Result<List<PurchaseReturnRow>>> listReturns({String query = ''});

  /// Gagal dengan `PurchaseNotFound`.
  Future<Result<PurchaseDetail>> detail(UuidValue id);

  /// Gagal dengan `PurchaseInvalid` atau `PurchaseNotEditable`.
  Future<Result<Purchase>> saveDraft(PurchaseRequest request);

  /// Gagal dengan `PurchaseInvalid`, `PurchaseNotEditable`, atau
  /// `CashSessionNotOpen`.
  Future<Result<Purchase>> receive(PurchaseRequest request);

  Future<Result<void>> deleteDraft(UuidValue id);

  /// Gagal dengan `PurchaseReturnInvalid` atau `CashSessionNotOpen`.
  Future<Result<PurchaseReturn>> returnPurchase({
    required UuidValue purchaseId,
    required List<PurchaseReturnLine> lines,
    String? note,
    FundingSource? refundSource,
  });

  /// Harga jual baru per varian (satuan dasar).
  Future<Result<void>> applySellPrices(Map<UuidValue, Money> prices);

  /// Isi foto faktur pembelian [id] (F1-12b); `null` bila tidak ada atau
  /// berkasnya belum ada di perangkat ini.
  Future<Result<Uint8List?>> invoicePhoto(UuidValue id);

  /// Memasang atau mengganti foto faktur. Gagal dengan
  /// `PurchaseInvoicePhotoInvalid` atau `PurchaseNotFound`.
  Future<Result<Purchase>> setInvoicePhoto(
    UuidValue id,
    PurchaseInvoicePhoto photo,
  );

  /// Mengosongkan foto faktur.
  Future<Result<Purchase>> clearInvoicePhoto(UuidValue id);
}
