import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show normalizePhone;

import '../../data/repositories/customers_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Daftar pelanggan dengan piutang (1.20, F1-13).
class CustomersViewModel extends ChangeNotifier {
  CustomersViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final CustomersRepository _repository;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;

  CustomersSetup? _setup;
  CustomersOverview? _overview;
  Exception? _error;
  var _query = '';
  UuidValue? _selected;
  var _request = 0;

  CustomersSetup? get setup => _setup;
  CustomersOverview? get overview => _overview;
  Exception? get error => _error;
  String get query => _query;
  UuidValue? get selected => _selected;

  bool get canManage => _setup?.canManage ?? false;

  /// Baris yang cocok dengan [query] (nama atau HP).
  List<CustomerRow> get rows {
    final all = _overview?.rows ?? const <CustomerRow>[];
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    final digits = normalizePhone(q);
    return [
      for (final r in all)
        if (r.customer.name.toLowerCase().contains(q) ||
            (digits.length >= 3 && (r.customer.phone ?? '').contains(digits)))
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
            !l.rows.any((r) => r.customer.id == _selected)) {
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
