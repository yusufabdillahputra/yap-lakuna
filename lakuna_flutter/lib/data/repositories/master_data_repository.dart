import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Layar Master data (F1-09, 1.17). Semua aksi butuh `products:manage`
/// (dicek di sini juga).
abstract class MasterDataRepository {
  /// Kategori urut master, dengan jumlah produk.
  Future<Result<List<CategoryRow>>> categories();

  Future<Result<ProductCategory>> createCategory(CategoryDraft draft);

  Future<Result<ProductCategory>> updateCategory(
    UuidValue id,
    CategoryDraft draft,
  );

  Future<Result<ProductCategory>> setCategoryActive(UuidValue id, bool active);

  /// Pindah [delta] posisi (−1 naik, +1 turun).
  Future<Result<void>> moveCategory(UuidValue id, int delta);

  Future<Result<void>> deleteCategory(UuidValue id);

  /// Satuan urut nama, dengan jumlah produk.
  Future<Result<List<UnitRow>>> units();

  Future<Result<MeasureUnit>> createUnit(String name);

  Future<Result<MeasureUnit>> renameUnit(UuidValue id, String name);

  Future<Result<void>> deleteUnit(UuidValue id);

  /// Lokasi stok cabang (baca saja di Master data).
  Future<Result<List<StockLocation>>> locations();

  /// Grup modifier urut master, dengan opsi dan jumlah menu (1.17b).
  Future<Result<List<ModifierGroupDetail>>> modifierGroups();

  /// Buat ([id] `null`) atau ubah grup. Gagal dengan `ModifierGroupInvalid`.
  Future<Result<ModifierGroup>> saveModifierGroup(
    UuidValue? id,
    ModifierGroupDraft draft,
  );

  Future<Result<void>> moveModifierGroup(UuidValue id, int delta);

  /// Ditolak (`MasterInUse`) bila grup masih dipasang di menu.
  Future<Result<void>> deleteModifierGroup(UuidValue id);
}
