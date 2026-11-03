import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Area dan meja cabang (Master data › Meja & area).
class DiningSetup {
  const DiningSetup({required this.areas, required this.tables});

  final List<DiningArea> areas;
  final List<DiningTable> tables;
}

/// Isi layar *Atur denah* (1.7d): area, meja, dan gambar denah per area.
class FloorPlanSetup {
  const FloorPlanSetup({
    required this.areas,
    required this.tables,
    this.images = const {},
  });

  final List<DiningArea> areas;
  final List<DiningTable> tables;
  final Map<UuidValue, FloorImage> images;
}

/// Pengaturan meja F&B (F1-10): area, meja, tarif service & PB1. Semua aksi
/// butuh `settings:manage` (dicek di sini juga).
abstract class DiningAdminRepository {
  Future<Result<DiningSetup>> load();

  Future<Result<DiningArea>> createArea(String name);

  Future<Result<DiningArea>> renameArea(UuidValue id, String name);

  /// Pindah [delta] posisi (−1 naik, +1 turun).
  Future<Result<void>> moveArea(UuidValue id, int delta);

  /// Ditolak (`DiningInUse`) bila area masih punya meja.
  Future<Result<void>> deleteArea(UuidValue id);

  /// Semua atau tidak sama sekali (satu transaksi).
  Future<Result<List<DiningTable>>> createTables(List<DiningTableDraft> drafts);

  Future<Result<DiningTable>> updateTable(UuidValue id, DiningTableDraft draft);

  Future<Result<void>> moveTable(UuidValue id, int delta);

  /// Ditolak (`DiningInUse(openBill: true)`) bila meja punya bill terbuka.
  Future<Result<void>> deleteTable(UuidValue id);

  // --- Denah (F1-10 v0.14.0) ------------------------------------------------

  Future<Result<FloorPlanSetup>> loadFloorPlan();

  /// Gambar denah area [areaId]; area jadi mode denah. Gagal dengan
  /// `FloorImageInvalid`.
  Future<Result<DiningArea>> saveFloorImage(
    UuidValue areaId,
    Uint8List bytes,
    String fileName,
  );

  /// *Simpan tata letak* (satu transaksi). Gagal dengan
  /// `DiningNameInvalid` / `FloorTableInvalid` (indeks draf) atau
  /// `DiningInUse`.
  Future<Result<void>> saveFloorLayout(
    UuidValue areaId, {
    required DiningLayoutMode mode,
    required List<FloorTableDraft> tables,
    List<UuidValue> deleted = const [],
  });

  Future<Result<FnbRates>> rates();

  Future<Result<FnbRates>> saveRates(FnbRates rates);
}
