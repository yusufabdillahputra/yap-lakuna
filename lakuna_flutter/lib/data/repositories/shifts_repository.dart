import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show ShiftRow;

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Master data › Shift (F1-03g). Mengubah butuh `settings:manage` (dicek di
/// sini dan di `lakuna_data`).
abstract class ShiftsRepository {
  /// Shift aktif cabang, urut jam mulai, dengan jumlah sesi pemakainya.
  Future<Result<List<ShiftRow>>> list();

  /// Buat ([id] `null`) atau ubah shift. Gagal dengan `ShiftInvalid`,
  /// `ShiftNameTaken`, `ShiftNotFound`, atau [NotPermitted].
  Future<Result<Shift>> save({
    UuidValue? id,
    required String name,
    required int startMinute,
    required int endMinute,
  });

  /// Ditolak (`ShiftInUse`) bila shift dipakai sesi kasir.
  Future<Result<void>> delete(UuidValue id);
}
