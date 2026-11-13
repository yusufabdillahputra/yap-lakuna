import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_data/lakuna_data.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Dialog *Produk diarsipkan* (1.15, F1-07d): daftar arsip dan *Pulihkan*.
class ArchivedProductsViewModel extends ChangeNotifier {
  ArchivedProductsViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    restore = Command1(_restore)..addListener(notifyListeners);
  }

  final CatalogRepository _repository;

  late final Command0<List<CatalogProduct>> load;

  /// Gagal dengan `ProductCodesTaken` bila kode sudah dipakai produk lain.
  late final Command1<void, UuidValue> restore;

  List<CatalogProduct>? _products;
  UuidValue? _failedId;
  String? _restoredName;

  /// `null` sebelum termuat.
  List<CatalogProduct>? get products => _products;

  /// Ada produk yang dipulihkan sejak dialog dibuka (daftar 1.15 dimuat
  /// ulang saat ditutup).
  bool get changed => _restoredName != null;

  /// Nama produk terakhir yang dipulihkan (pesan sukses).
  String? get restoredName => _restoredName;

  /// Galat pemulihan untuk produk [id], bila ada.
  Exception? errorFor(UuidValue id) => _failedId == id
      ? switch (restore.result) {
          Error(:final error) => error,
          _ => null,
        }
      : null;

  Future<Result<List<CatalogProduct>>> _load() async {
    final result = await _repository.archived();
    if (result case Ok(:final value)) _products = value;
    return result;
  }

  Future<Result<void>> _restore(UuidValue id) async {
    _failedId = id;
    final name = _products?.where((p) => p.id == id).firstOrNull?.name;
    final result = await _repository.restore(id);
    if (result is Ok) {
      _failedId = null;
      _restoredName = name;
      _products = [...?_products]..removeWhere((p) => p.id == id);
    }
    return result;
  }
}
