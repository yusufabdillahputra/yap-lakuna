import 'package:lakuna_data/lakuna_data.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Pengaturan › Metode pembayaran (F1-18, 1.26b). Butuh `settings:manage`,
/// dicek di sini juga.
abstract class PaymentSettingsRepository {
  /// QRIS statis cabang ini. Gagal dengan `NotPermitted` atau
  /// `StoreNotReady`.
  Future<Result<QrisConfig>> loadQris();

  /// Menyimpan QRIS statis; [image] baru menggantikan gambar lama. Gagal
  /// dengan `NotPermitted`, `QrisImageInvalid`, atau `QrisSettingsInvalid`.
  Future<Result<QrisConfig>> saveQris(
    QrisStaticSettings settings, {
    QrisImageUpload? image,
  });
}
