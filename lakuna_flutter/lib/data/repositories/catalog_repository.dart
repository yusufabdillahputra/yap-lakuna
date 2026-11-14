import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Isi katalog untuk daftar produk dan saran isian form.
class ProductCatalog {
  const ProductCatalog({
    required this.products,
    required this.categories,
    required this.units,
    this.modifierGroups = const [],
    this.customerGroups = const [],
    this.archivedCount = 0,
  });

  final List<CatalogProduct> products;
  final List<ProductCategory> categories;
  final List<MeasureUnit> units;

  /// Grup modifier master (urut) untuk tab *Modifier* form produk (1.16b).
  final List<ModifierGroupDetail> modifierGroups;

  /// Grup pelanggan (urut nama) untuk kolom *Berlaku untuk* tab *Harga
  /// grosir* (F1-07c).
  final List<CustomerGroup> customerGroups;

  /// Jumlah produk diarsipkan (tombol *Diarsipkan* 1.15, F1-07d).
  final int archivedCount;
}

/// Katalog produk (F1-07). Semua aksi butuh `products:manage`; izin dicek
/// di sini juga, bukan hanya di menu.
abstract class CatalogRepository {
  /// Gagal dengan `NotPermitted` atau `StoreNotReady`.
  Future<Result<ProductCatalog>> loadCatalog();

  /// Produk [id], atau `null` bila tidak ada.
  Future<Result<CatalogProduct?>> loadProduct(UuidValue id);

  /// Menyimpan [draft] dan mengembalikan ID produk. Gagal dengan
  /// `NotPermitted`, `ProductInputInvalid`, `ProductCodesTaken`, atau
  /// `ProductNotFound`.
  Future<Result<UuidValue>> save(ProductDraft draft);

  /// Import produk baru dari berkas (F1-07b). Produk yang sudah ada
  /// dilewati, atau diperbarui harganya bila [updateExisting] (F1-07k).
  /// Gagal dengan `NotPermitted` atau `ProductInputInvalid`.
  Future<Result<ProductImportSummary>> importRows(
    List<ProductImportRow> rows, {
    bool updateExisting = false,
  });

  /// Mengarsipkan produk [id] (F1-07d). Gagal dengan `NotPermitted` atau
  /// `ProductNotFound`.
  Future<Result<void>> archive(UuidValue id);

  /// Produk diarsipkan, urut nama.
  Future<Result<List<CatalogProduct>>> archived();

  /// Memulihkan produk diarsipkan [id]. Gagal dengan `NotPermitted`,
  /// `ProductNotFound`, atau `ProductCodesTaken`.
  Future<Result<void>> restore(UuidValue id);

  /// Memasang foto produk [id] (F1-07f). Gagal dengan `NotPermitted`,
  /// `ProductNotFound`, atau `ProductPhotoInvalid`.
  Future<Result<void>> setPhoto(UuidValue id, ProductPhotoUpload photo);

  /// Melepas foto produk [id].
  Future<Result<void>> clearPhoto(UuidValue id);
}
