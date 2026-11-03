import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Layar Stok (F1-08, 1.18). Melihat butuh `stock:adjust` atau
/// `products:manage`; menyimpan penyesuaian dan mengubah lokasi butuh
/// `stock:adjust`. Izin dicek di sini juga.
abstract class StockRepository {
  /// Lokasi stok cabang, bawaan dulu.
  Future<Result<List<StockLocation>>> locations();

  /// Daftar stok varian barang di [locationId] (bawaan bila `null`).
  Future<Result<List<StockRow>>> stock({UuidValue? locationId});

  /// Varian dengan stok ≤ minimum, paling kritis dulu.
  Future<Result<List<StockRow>>> belowMinimum({UuidValue? locationId});

  Future<Result<StockCard>> card({
    required UuidValue variantId,
    UuidValue? locationId,
  });

  /// Pratinjau nomor penyesuaian berikutnya.
  Future<Result<String>> nextAdjustmentNumber();

  Future<Result<List<StockAdjustmentSummary>>> recentAdjustments();

  /// Gagal dengan `NotPermitted` atau `StockAdjustmentInvalid`.
  Future<Result<StockAdjustmentResult>> saveAdjustment({
    required UuidValue locationId,
    required StockAdjustmentReason reason,
    required List<AdjustmentLine> lines,
    String? note,
  });

  /// Gagal dengan `NotPermitted` atau `StockLocationInvalid`.
  Future<Result<StockLocation>> createLocation(String name);

  /// Gagal dengan `NotPermitted`, `StockLocationInvalid`, atau
  /// `StockLocationNotFound`.
  Future<Result<StockLocation>> renameLocation(UuidValue id, String name);
}
