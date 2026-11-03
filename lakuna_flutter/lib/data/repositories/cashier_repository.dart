import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

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

/// Isi layar kasir: produk yang bisa dijual, kategorinya, dan sesi kasir.
class CashierData {
  const CashierData({
    required this.products,
    required this.categories,
    required this.businessName,
    required this.outletName,
    required this.staffName,
    this.timezone,
    this.session,
  });

  /// Produk aktif dengan minimal satu varian, urut nama.
  final List<CatalogProduct> products;

  /// Kategori yang punya produk aktif, urut nama.
  final List<ProductCategory> categories;
  final String businessName;
  final String outletName;

  /// Staf yang sedang bertugas.
  final String staffName;

  /// Zona waktu cabang (ID IANA).
  final String? timezone;

  /// `null` bila perangkat belum membuka sesi kasir.
  final CashierSession? session;
}

/// Kasir retail dan pembayaran (F1-04/F1-05). Izin `sales:create` dicek di
/// sini juga, bukan hanya di menu. Namanya bukan `SaleRepository` karena
/// nama itu dipakai kode generate Serverpod.
abstract class CashierRepository {
  /// Gagal dengan `NotPermitted` atau `StoreNotReady`.
  Future<Result<CashierData>> load();

  /// Menyimpan penjualan. Gagal dengan `NotPermitted`, `CashSessionNotOpen`,
  /// `SaleItemUnavailable`, `SalePaymentShort`, atau galat input lain dari
  /// `checkoutSale`.
  Future<Result<CheckoutResult>> checkout({
    required List<SaleLineRequest> lines,
    required SalePaymentRequest payment,
  });
}
