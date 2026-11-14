import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_client/lakuna_client.dart' show ProductCategory;

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Pengaturan › Struk & printer (F1-06, 1.26): struk per cabang dan printer
/// per perangkat. Membaca boleh siapa pun yang login (kasir mencetak);
/// mengubah butuh `settings:manage`, dicek di sini juga.
abstract class ReceiptSettingsRepository {
  /// Struk cabang ini. Gagal dengan `StoreNotReady`.
  Future<Result<ReceiptConfig>> loadReceipt();

  /// Gagal dengan `NotPermitted` atau `ReceiptSettingsInvalid`.
  /// [logo] baru / [removeLogo] (F1-06b); gagal juga dengan
  /// `ReceiptLogoInvalid`.
  Future<Result<ReceiptConfig>> saveReceipt(
    ReceiptSettings settings, {
    ReceiptLogoUpload? logo,
    bool removeLogo = false,
  });

  /// Printer terpilih di perangkat ini; `null` bila belum ada.
  Future<Result<PrinterSelection?>> loadPrinter();

  /// Memilih atau (dengan `null`) melupakan printer. Gagal dengan
  /// `NotPermitted`.
  Future<Result<void>> savePrinter(PrinterSelection? printer);

  /// Printer dapur di perangkat ini (F1-10e); `null` = sama dengan printer
  /// struk.
  Future<Result<KitchenPrinter?>> loadKitchenPrinter();

  /// Memilih atau (dengan `null`) melupakan printer dapur. Gagal dengan
  /// `NotPermitted`.
  Future<Result<void>> saveKitchenPrinter(KitchenPrinter? kitchen);

  /// Printer bar perangkat ini (F1-10j); `null` = tidak dipakai.
  Future<Result<KitchenPrinter?>> loadBarPrinter();

  /// Memilih atau (dengan `null`) melupakan printer bar beserta
  /// kategorinya. Gagal dengan `NotPermitted`.
  Future<Result<void>> saveBarPrinter(KitchenPrinter? bar);

  /// Kategori menu induk (tanpa sub-kategori) untuk pilihan kategori
  /// printer bar, urut seperti master data.
  Future<Result<List<ProductCategory>>> menuCategories();
}
