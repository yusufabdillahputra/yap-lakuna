import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show normalizePhone;

import '../../data/repositories/suppliers_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Daftar supplier dengan hutang (1.21, F1-14).
class SuppliersViewModel extends ChangeNotifier {
  SuppliersViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final SuppliersRepository _repository;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;

  SuppliersSetup? _setup;
  SuppliersOverview? _overview;
  Exception? _error;
  var _query = '';
  UuidValue? _selected;
  var _request = 0;

  SuppliersSetup? get setup => _setup;
  SuppliersOverview? get overview => _overview;
  Exception? get error => _error;
  String get query => _query;
  UuidValue? get selected => _selected;

  bool get canManage => _setup?.canManage ?? false;

  /// Baris yang cocok dengan [query] (nama, kontak, kategori, atau telepon).
  List<SupplierRow> get rows {
    final all = _overview?.rows ?? const <SupplierRow>[];
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    final digits = normalizePhone(q);
    bool has(String? s) => (s ?? '').toLowerCase().contains(q);
    return [
      for (final r in all)
        if (has(r.supplier.name) ||
            has(r.supplier.contactName) ||
            has(r.supplier.category) ||
            (digits.length >= 3 && (r.supplier.phone ?? '').contains(digits)))
          r,
    ];
  }

  Future<Result<void>> _load() async {
    final request = ++_request;
    final setup = await _repository.load();
    final list = await _repository.list();
    if (request != _request) return const Result.ok(null);
    switch ((setup, list)) {
      case (Ok(value: final s), Ok(value: final l)):
        _setup = s;
        _overview = l;
        _error = null;
        if (_selected != null &&
            !l.rows.any((r) => r.supplier.id == _selected)) {
          _selected = null;
        }
        return const Result.ok(null);
      case (Error(:final error), _) || (_, Error(:final error)):
        _error = error;
        return Result.error(error);
    }
  }

  Future<void> refresh() => _load().then((_) => notifyListeners());

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    notifyListeners();
  }

  void select(UuidValue? id) {
    if (_selected == id) return;
    _selected = id;
    notifyListeners();
  }
}
