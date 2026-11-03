import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../data/repositories/purchases_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tab daftar layar Pembelian (1.19).
enum PurchaseTab { purchases, returns }

/// Daftar pembelian dan retur pembelian (1.19, F1-12).
class PurchasesViewModel extends ChangeNotifier {
  PurchasesViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final PurchasesRepository _repository;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Perintah yang selesai setelah layar ditutup tidak memberi tahu lagi.
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;

  var _tab = PurchaseTab.purchases;
  var _query = '';
  List<PurchaseRow>? _rows;
  List<PurchaseReturnRow>? _returns;
  Exception? _error;
  String? _timezone;
  var _setupLoaded = false;

  /// Nomor permintaan terakhir; hasil yang lebih lama dibuang.
  var _request = 0;

  PurchaseTab get tab => _tab;
  String get query => _query;
  List<PurchaseRow>? get rows => _rows;
  List<PurchaseReturnRow>? get returns => _returns;
  Exception? get error => _error;

  /// Zona waktu cabang untuk tanggal retur.
  String? get timezone => _timezone;

  Future<Result<void>> _load() async {
    final request = ++_request;
    if (!_setupLoaded) {
      if (await _repository.load() case Ok(:final value)) {
        _timezone = value.timezone;
        _setupLoaded = true;
      }
    }
    final query = _query;
    final rows = await _repository.list(query: query);
    final returns = await _repository.listReturns(query: query);
    if (request != _request) return const Result.ok(null);
    switch ((rows, returns)) {
      case (Ok(value: final r), Ok(value: final x)):
        _rows = r;
        _returns = x;
        _error = null;
        return const Result.ok(null);
      case (Error(:final error), _) || (_, Error(:final error)):
        _error = error;
        return Result.error(error);
    }
  }

  Future<void> refresh() => _load().then((_) => notifyListeners());

  void setTab(PurchaseTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    unawaited(refresh());
  }
}
