import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/expenses_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Layar *Pengeluaran* (1.22): daftar per periode, cari, ringkasan per
/// jenis, dan ekspor Excel.
class ExpensesViewModel extends ChangeNotifier {
  ExpensesViewModel({
    required this._repository,
    this._exporter = const PlatformSpreadsheetExporter(),
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    export = Command1(_export)..addListener(notifyListeners);
  }

  final ExpensesRepository _repository;
  final SpreadsheetExporter _exporter;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    export.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Memuat setup (jenis, hari ini) lalu daftar periode terpilih.
  late final Command0<void> load;

  /// Menyimpan berkas Excel; hasil = lokasi berkas (desktop) atau `null`.
  late final Command1<String?, Uint8List> export;

  ExpensesSetup? _setup;
  List<ExpenseRow>? _rows;
  Exception? _error;
  var _period = ExpensePeriod.last30Days;
  var _query = '';
  String? _exportPath;
  var _loadToken = 0;

  ExpensesSetup? get setup => _setup;
  Exception? get error => _error;
  ExpensePeriod get period => _period;
  String get query => _query;
  String? get exportPath => _exportPath;

  /// Rentang periode terpilih (`null` sebelum setup dimuat).
  DateRange? get range =>
      _setup == null ? null : expensePeriodRange(_period, _setup!.today);

  /// Semua pengeluaran periode ini (`null` saat memuat).
  List<ExpenseRow>? get allRows => _rows;

  /// Baris setelah dicari (keterangan, nomor, jenis).
  List<ExpenseRow>? get rows {
    final all = _rows;
    if (all == null) return null;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return [
      for (final r in all)
        if (r.expense.description.toLowerCase().contains(q) ||
            r.expense.number.toLowerCase().contains(q) ||
            r.categoryName.toLowerCase().contains(q))
          r,
    ];
  }

  /// Total dan rincian per jenis untuk seluruh periode (tanpa yang batal).
  (Money, List<ExpenseCategoryTotal>) get summary =>
      summarizeExpenses(_rows ?? const []);

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  Future<void> setPeriod(ExpensePeriod period) async {
    if (_period == period) return;
    _period = period;
    _rows = null;
    notifyListeners();
    await refresh();
  }

  /// Memuat ulang daftar periode ini (setup tetap).
  Future<void> refresh() async {
    if (_setup == null) {
      await load.execute();
      return;
    }
    await _list();
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    switch (await _repository.load()) {
      case Ok(:final value):
        _setup = value;
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
    return _list();
  }

  Future<Result<void>> _list() async {
    final token = ++_loadToken;
    final result = await _repository.list(range!);
    if (token != _loadToken) return const Result.ok(null);
    switch (result) {
      case Ok(:final value):
        _rows = value;
        _error = null;
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  /// Nama berkas ekspor: `pengeluaran-<periode>-<yymmdd>.xlsx`.
  String exportFileName() {
    final today = _setup?.today ?? DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${two(today.year % 100)}${two(today.month)}${two(today.day)}';
    final period = switch (_period) {
      ExpensePeriod.last30Days => '30-hari',
      ExpensePeriod.thisMonth => 'bulan-ini',
      ExpensePeriod.lastMonth => 'bulan-lalu',
    };
    return 'pengeluaran-$period-$date.xlsx';
  }

  Future<Result<String?>> _export(Uint8List bytes) async {
    _exportPath = null;
    try {
      final path = await _exporter.save(bytes, fileName: exportFileName());
      _exportPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
