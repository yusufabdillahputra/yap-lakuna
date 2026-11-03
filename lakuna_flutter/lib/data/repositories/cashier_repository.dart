import 'dart:typed_data';

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
    required this.businessName,
    required this.outletName,
    required this.staffName,
    this.timezone,
    this.session,
    this.qris,
    this.canConfirmPayments = false,
    this.receipt = const ReceiptConfig(settings: ReceiptSettings()),
    this.printer,
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

  /// `null` bila QRIS statis nonaktif atau gambarnya belum ada.
  final CashierQris? qris;

  /// Staf boleh menekan *Sudah Terbayar* (`payments:confirm`).
  final bool canConfirmPayments;

  /// Pengaturan struk cabang ini (F1-06).
  final ReceiptConfig receipt;

  /// Printer terpilih di perangkat ini; `null` = belum ada.
  final PrinterSelection? printer;
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
  /// galat input lain dari `checkoutSale`.
  Future<Result<CheckoutResult>> checkout({
    required List<SaleLineRequest> lines,
    required List<SalePaymentRequest> payments,
  });
}
