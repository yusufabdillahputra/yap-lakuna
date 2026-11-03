import 'package:lakuna_data/lakuna_data.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Pengaturan › Struk & printer (F1-06, 1.26): struk per cabang dan printer
/// per perangkat. Membaca boleh siapa pun yang login (kasir mencetak);
/// mengubah butuh `settings:manage`, dicek di sini juga.
abstract class ReceiptSettingsRepository {
  /// Struk cabang ini. Gagal dengan `StoreNotReady`.
  Future<Result<ReceiptConfig>> loadReceipt();

  /// Gagal dengan `NotPermitted` atau `ReceiptSettingsInvalid`.
  Future<Result<ReceiptConfig>> saveReceipt(ReceiptSettings settings);

  /// Printer terpilih di perangkat ini; `null` bila belum ada.
  Future<Result<PrinterSelection?>> loadPrinter();

  /// Memilih atau (dengan `null`) melupakan printer. Gagal dengan
  /// `NotPermitted`.
  Future<Result<void>> savePrinter(PrinterSelection? printer);
}
