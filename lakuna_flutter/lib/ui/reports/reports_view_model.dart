import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/reports_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tab layar Laporan (F1-16).
enum ReportTab {
  summary,
  sales,
  top,
  profit,
  stock,
  cash,
  debts,
  returns;

  /// Tab yang datanya dimuat terpisah saat dibuka (v0.21.0).
  bool get isExtra => index >= ReportTab.stock.index;
}

/// Pengelompokan tab Penjualan.
enum SalesGroup { product, staff, category }

/// Format berkas unduhan.
enum ReportFormat { pdf, xlsx }

/// Layar *Laporan* (1.23 ringkasan, 1.24 laba rugi): periode, tab, dan
/// unduhan PDF/Excel.
class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel({
    required this._repository,
    this._exporter = const PlatformSpreadsheetExporter(),
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    export = Command1(_export)..addListener(notifyListeners);
  }

  final ReportsRepository _repository;
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

  /// Memuat laporan periode terpilih.
  late final Command0<void> load;

  /// Menyimpan berkas; hasil = lokasi (desktop) atau `null` (berbagi).
  late final Command1<String?, (Uint8List, ReportFormat)> export;

  ReportData? _data;
  Exception? _error;
  var _period = ReportPeriod.today;
  var _tab = ReportTab.summary;
  var _group = SalesGroup.product;
  String? _exportPath;
  var _loadToken = 0;

  // Data tab lanjutan: satu tab + periode terakhir yang dimuat.
  Object? _extra;
  (ReportTab, ReportPeriod?)? _extraKey;
  Exception? _extraError;
  var _extraToken = 0;

  /// Data periode terpilih; `null` selama periode baru dimuat agar angka
  /// periode lama tidak tampil atau terunduh di bawah label periode baru.
  ReportData? get data => _data?.period == _period ? _data : null;

  /// Sedang memuat (periode awal atau periode baru).
  bool get loading => _loading;
  var _loading = false;
  Exception? get error => _error;
  ReportPeriod get period => _period;
  ReportTab get tab => _tab;
  SalesGroup get group => _group;
  String? get exportPath => _exportPath;

  /// Tab Laba rugi hanya untuk `reports:view_profit`.
  List<ReportTab> get tabs => [
    ReportTab.summary,
    ReportTab.sales,
    ReportTab.top,
    if (_data?.canViewProfit ?? false) ReportTab.profit,
    ReportTab.stock,
    ReportTab.cash,
    ReportTab.debts,
    ReportTab.returns,
  ];

  /// Kunci data tab [tab]: Piutang & hutang tidak tergantung periode.
  (ReportTab, ReportPeriod?) _keyOf(ReportTab tab) =>
      (tab, tab == ReportTab.debts ? null : _period);

  T? _extraOf<T>(ReportTab tab) =>
      _extraKey == _keyOf(tab) && _extra is T ? _extra as T : null;

  StockReport? get stock => _extraOf(ReportTab.stock);
  CashReport? get cash => _extraOf(ReportTab.cash);
  DebtReport? get debts => _extraOf(ReportTab.debts);
  ReturnsReport? get returns => _extraOf(ReportTab.returns);

  /// Galat muat tab lanjutan yang aktif.
  Exception? get extraError =>
      _tab.isExtra && _extraKey == _keyOf(_tab) ? _extraError : null;

  /// Data tab aktif sudah siap (untuk unduh).
  bool get ready =>
      data != null &&
      (!_tab.isExtra || (_extraKey == _keyOf(_tab) && _extra != null));

  /// Pilihan periode relatif ke hari ini di cabang.
  List<ReportPeriod> get periods =>
      reportPeriodChoices(_data?.today ?? DateTime.now());

  Future<void> setPeriod(ReportPeriod period) async {
    if (period == _period) return;
    _period = period;
    export.clearResult();
    notifyListeners();
    await Future.wait([
      _fetch(),
      // Piutang & hutang tidak tergantung periode.
      if (_tab != ReportTab.debts) _fetchExtra(),
    ]);
  }

  void setTab(ReportTab tab) {
    if (tab == _tab || !tabs.contains(tab)) return;
    _tab = tab;
    export.clearResult();
    notifyListeners();
    if (tab.isExtra && _extraKey != _keyOf(tab)) unawaited(_fetchExtra());
  }

  void setGroup(SalesGroup group) {
    if (group == _group) return;
    _group = group;
    export.clearResult();
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final results = await Future.wait([_fetch(), _fetchExtra()]);
    return results.first;
  }

  Future<Result<void>> _fetchExtra() async {
    final tab = _tab;
    if (!tab.isExtra) return const Result.ok(null);
    final key = _keyOf(tab);
    final token = ++_extraToken;
    final Result<Object> result = switch (tab) {
      ReportTab.stock => await _repository.loadStock(_period),
      ReportTab.cash => await _repository.loadCash(_period),
      ReportTab.debts => await _repository.loadDebts(),
      _ => await _repository.loadReturns(_period),
    };
    if (token != _extraToken) return const Result.ok(null);
    _extraKey = key;
    switch (result) {
      case Ok(:final value):
        _extra = value;
        _extraError = null;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        _extra = null;
        _extraError = error;
        notifyListeners();
        return Result.error(error);
    }
  }

  Future<Result<void>> _fetch() async {
    final token = ++_loadToken;
    _loading = true;
    final result = await _repository.load(_period);
    if (token != _loadToken) return const Result.ok(null);
    _loading = false;
    switch (result) {
      case Ok(:final value):
        _data = value;
        _error = null;
        if (!tabs.contains(_tab)) _tab = ReportTab.summary;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        _data = null;
        _error = error;
        notifyListeners();
        return Result.error(error);
    }
  }

  /// `laporan-<tab>-<periode>-<yymmdd>.<ext>`, mis.
  /// `laporan-laba-rugi-2026-10-261104.pdf`.
  String exportFileName(ReportFormat format) {
    final today = data?.today ?? DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${two(today.year % 100)}${two(today.month)}${two(today.day)}';
    final tab = switch (_tab) {
      ReportTab.summary => 'ringkasan',
      ReportTab.sales => switch (_group) {
        SalesGroup.product => 'penjualan-produk',
        SalesGroup.staff => 'penjualan-kasir',
        SalesGroup.category => 'penjualan-kategori',
      },
      ReportTab.top => 'produk-terlaris',
      ReportTab.profit => 'laba-rugi',
      ReportTab.stock => 'stok',
      ReportTab.cash => 'kas-sesi',
      ReportTab.debts => 'piutang-hutang',
      ReportTab.returns => 'retur',
    };
    // Piutang & hutang = posisi hari ini, tanpa periode.
    final period = _tab == ReportTab.debts ? '' : '-${_period.fileKey(today)}';
    return 'laporan-$tab$period-$date.${format.name}';
  }

  Future<Result<String?>> _export((Uint8List, ReportFormat) file) async {
    _exportPath = null;
    try {
      final path = await _exporter.save(
        file.$1,
        fileName: exportFileName(file.$2),
      );
      _exportPath = path;
      return Result.ok(path);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
