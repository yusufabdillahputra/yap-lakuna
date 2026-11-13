import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// View model daftar produk 1.15 / 1.15m (F1-07): cari, filter kategori,
/// dan chip *Di bawah minimum*.
class ProductListViewModel extends ChangeNotifier {
  ProductListViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final CatalogRepository _repository;
  late final Command0<ProductCatalog> load;

  ProductCatalog? _catalog;
  String _query = '';
  UuidValue? _categoryId;
  bool _lowStockOnly = false;

  bool get loaded => _catalog != null;
  String get query => _query;
  UuidValue? get categoryId => _categoryId;
  bool get lowStockOnly => _lowStockOnly;

  List<CatalogProduct> get _all => _catalog?.products ?? const [];

  /// Kategori yang punya produk, untuk pilihan filter dan chip.
  List<ProductCategory> get categories {
    final used = {for (final p in _all) p.categoryId};
    return [
      for (final c in _catalog?.categories ?? const <ProductCategory>[])
        if (used.contains(c.id)) c,
    ];
  }

  /// Produk aktif (*Dijual di kasir*).
  int get activeCount => _all.where((p) => p.isActive).length;

  /// Jumlah produk diarsipkan (tombol *Diarsipkan*, F1-07d).
  int get archivedCount => _catalog?.archivedCount ?? 0;

  /// Produk dengan varian di bawah stok minimum.
  int get lowStockCount => _all.where((p) => p.isLowStock).length;

  bool get isEmpty => loaded && _all.isEmpty;

  /// Produk setelah cari dan filter, urut nama.
  List<CatalogProduct> get products => [
    for (final p in _all)
      if ((_categoryId == null || p.categoryId == _categoryId) &&
          (!_lowStockOnly || p.isLowStock) &&
          productMatches(p, _query))
        p,
  ];

  void setQuery(String value) {
    if (value == _query) return;
    _query = value;
    notifyListeners();
  }

  /// `null` = semua kategori. Mematikan chip *Di bawah minimum*.
  void setCategory(UuidValue? id) {
    _categoryId = id;
    _lowStockOnly = false;
    notifyListeners();
  }

  /// Chip *Di bawah minimum*; mengosongkan filter kategori.
  void setLowStockOnly(bool value) {
    _lowStockOnly = value;
    if (value) _categoryId = null;
    notifyListeners();
  }

  Future<Result<ProductCatalog>> _load() async {
    final result = await _repository.loadCatalog();
    if (result case Ok(:final value)) {
      _catalog = value;
      if (_categoryId != null &&
          !value.categories.any((c) => c.id == _categoryId)) {
        _categoryId = null;
      }
    }
    return result;
  }
}

/// Cocok dengan kata kunci: nama (mengandung), SKU induk/varian, atau
/// barcode varian/satuan (mengandung, tanpa beda huruf).
bool productMatches(CatalogProduct p, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  bool has(String? s) => s != null && s.toLowerCase().contains(q);
  return has(p.name) ||
      has(p.sku) ||
      p.variants.any(
        (v) =>
            has(v.name) ||
            has(v.sku) ||
            has(v.barcode) ||
            v.units.any((u) => has(u.barcode)),
      );
}
