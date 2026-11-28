import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart'
    show DeviceStatus, TenantStatus, UuidValue;
import 'package:lakuna_data/lakuna_data.dart' show DashboardData;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/dashboard_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Satu baris tabel *Per cabang hari ini*.
class DashboardOutletRow {
  const DashboardOutletRow({
    required this.outletId,
    required this.name,
    required this.code,
    required this.sales,
    required this.transactions,
    required this.devices,
    required this.offline,
    required this.lastSync,
  });

  final String outletId;
  final String name;
  final String code;
  final Money sales;
  final int transactions;

  /// Perangkat kasir cabang ini (0 bila status perangkat tidak tersedia).
  final int devices;
  final int offline;

  /// Sync terakhir terbaru perangkat cabang ini.
  final DateTime? lastSync;
}

/// Butir kartu *Perlu perhatian* (F2-02 aturan 22).
sealed class AttentionItem {
  const AttentionItem();
}

class AttentionConflicts extends AttentionItem {
  const AttentionConflicts(this.count);
  final int count;
}

class AttentionDevice extends AttentionItem {
  const AttentionDevice(this.device, this.outletName);
  final DeviceStatus device;
  final String outletName;
}

class AttentionStock extends AttentionItem {
  const AttentionStock(this.outletId, this.outletName, this.count);
  final String outletId;
  final String outletName;
  final int count;
}

typedef PeriodicTimer = Timer Function(
  Duration every,
  void Function(Timer) tick,
);

/// Dashboard semua cabang 2.3 (F2-02 tahap 3): angka hari ini dari data
/// tersinkron, status perangkat dari server tiap 60 detik.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required this._repository,
    this._exporter = const PlatformSpreadsheetExporter(),
    DateTime Function()? clock,
    PeriodicTimer? periodic,
    this.pollEvery = const Duration(seconds: 60),
    this.timezone,
  }) : _clock = clock ?? DateTime.now,
       _periodic = periodic ?? Timer.periodic {
    load = Command0(_load)..addListener(notifyListeners);
    exportExcel = Command1(_export)..addListener(notifyListeners);
  }

  final DashboardRepository _repository;
  final SpreadsheetExporter _exporter;
  final DateTime Function() _clock;
  final PeriodicTimer _periodic;
  final Duration pollEvery;

  /// Zona waktu cabang perangkat/sesi ini, untuk tanggal hari ini.
  final String? timezone;

  /// Tanggal dan jam sekarang di zona waktu cabang ini.
  DateTime get localNow => outletLocalTime(_clock().toUtc(), timezone);

  late final Command0<void> load;
  late final Command1<String?, Uint8List> exportExcel;

  Timer? _timer;
  var _disposed = false;
  var _loadToken = 0;

  DashboardData? _data;
  DashboardData? get data => _data;

  TenantStatus? _status;
  var _statusFailed = false;

  String? _selected;

  /// Cabang terpilih (uuid); `null` = *Semua cabang*.
  String? get selectedOutlet => _selected;

  String? _exportPath;
  String? get exportPath => _exportPath;

  /// Memuat data lalu menyalakan muat ulang berkala.
  Future<void> start() async {
    await _reload();
    if (_disposed) return;
    _timer ??= _periodic(pollEvery, (_) => unawaited(_reload()));
  }

  /// Muat ulang diminta saat muatan lain berjalan: diulang sesudahnya agar
  /// pilihan cabang terbaru yang tampil (review I1).
  var _reloadPending = false;

  Future<void> _reload() async {
    if (_disposed) return;
    if (load.running) {
      _reloadPending = true;
      return;
    }
    await load.execute();
    while (_reloadPending && !_disposed) {
      _reloadPending = false;
      await load.execute();
    }
  }

  Future<void> selectOutlet(String? outletId) async {
    if (outletId == _selected) return;
    _selected = outletId;
    notifyListeners();
    await _reload();
  }

  /// Status perangkat dimuat terpisah: angka penjualan lokal tidak menunggu
  /// server yang lambat atau tak terjangkau (review I2).
  var _statusLoading = false;

  Future<void> _loadStatus() async {
    if (_statusLoading) return;
    _statusLoading = true;
    try {
      final result = await _repository.tenantStatus();
      if (_disposed) return;
      switch (result) {
        case Ok(:final value):
          _status = value;
          _statusFailed = false;
        case Error():
          _statusFailed = true;
      }
      notifyListeners();
    } finally {
      _statusLoading = false;
    }
  }

  Future<Result<void>> _load() async {
    final token = ++_loadToken;
    final selected = _selected;
    unawaited(_loadStatus());
    final result = await _repository.load(
      outletId: selected == null ? null : UuidValue.fromString(selected),
    );
    // Pilihan cabang berubah selama memuat: hasil lama dibuang.
    if (token != _loadToken || _disposed || selected != _selected) {
      return const Result.ok(null);
    }
    switch (result) {
      case Ok(:final value):
        _data = value;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  // --- Angka turunan ---------------------------------------------------

  List<OutletDay> get _outlets => _data?.outlets ?? const [];

  Money get totalSales => Money.sum(_outlets.map((o) => o.sales));
  int get transactions => _outlets.fold(0, (n, o) => n + o.transactions);
  Money get average => averagePerReceipt(totalSales, transactions);
  int get outletCount => _outlets.length;

  /// Jumlah semua cabang (terpilih) per jam dinding cabang.
  List<Money> get hourly => [
    for (var h = 0; h < 24; h++) Money.sum(_outlets.map((o) => o.hourly[h])),
  ];

  ({int from, int to}) get axis => hourAxis(hourly);

  List<({String productId, String name, Qty sold})> get top =>
      _data?.top ?? const [];

  /// Status perangkat dari server tidak bisa dimuat (offline).
  bool get devicesUnavailable => _statusFailed || _status == null;

  DateTime get _now => _clock().toUtc();

  List<DeviceStatus> get _devices {
    final status = _status;
    if (status == null || _statusFailed) return const [];
    final ids = {for (final o in _outlets) o.outletId};
    return [
      for (final d in status.devices)
        if (ids.contains(d.outletId.uuid)) d,
    ];
  }

  int get devicesTotal => _devices.length;
  int get devicesOnline => _devices
      .where((d) => deviceLiveness(d.lastSeenAt, _now) == DeviceLiveness.online)
      .length;

  /// Perangkat yang belum sync > 1 jam, paling lama dulu.
  List<DeviceStatus> get staleDevices =>
      _devices.where((d) => deviceStale(d.lastSeenAt, _now)).toList()
        ..sort((a, b) {
          final x = a.lastSeenAt;
          final y = b.lastSeenAt;
          if (x == null || y == null) return x == null ? -1 : 1;
          return x.compareTo(y);
        });

  int get conflicts => devicesUnavailable ? 0 : (_status?.openConflicts ?? 0);

  String _name(String outletId) =>
      _data?.outletInfo[outletId]?.name ?? outletId;

  List<DashboardOutletRow> get rows => [
    for (final o in _outlets)
      () {
        final devices = [
          for (final d in _devices)
            if (d.outletId.uuid == o.outletId) d,
        ];
        DateTime? last;
        for (final d in devices) {
          final seen = d.lastSeenAt;
          if (seen != null && (last == null || seen.isAfter(last))) {
            last = seen;
          }
        }
        final info = _data?.outletInfo[o.outletId];
        return DashboardOutletRow(
          outletId: o.outletId,
          name: info?.name ?? o.outletId,
          code: info?.code ?? '',
          sales: o.sales,
          transactions: o.transactions,
          devices: devices.length,
          offline: devices
              .where(
                (d) =>
                    deviceLiveness(d.lastSeenAt, _now) ==
                    DeviceLiveness.offline,
              )
              .length,
          lastSync: last,
        );
      }(),
  ];

  /// Sync terakhir terbaru dari semua perangkat terpilih.
  DateTime? get lastSync {
    DateTime? last;
    for (final r in rows) {
      final s = r.lastSync;
      if (s != null && (last == null || s.isAfter(last))) last = s;
    }
    return last;
  }

  List<AttentionItem> get attention => [
    if (conflicts > 0) AttentionConflicts(conflicts),
    for (final d in staleDevices) AttentionDevice(d, _name(d.outletId.uuid)),
    for (final o in _outlets)
      if ((_data?.belowMinimum[o.outletId] ?? 0) > 0)
        AttentionStock(
          o.outletId,
          _name(o.outletId),
          _data!.belowMinimum[o.outletId]!,
        ),
  ];

  /// *Semua beres*: tidak ada yang perlu perhatian dan status perangkat
  /// diketahui.
  bool get allClear => !devicesUnavailable && attention.isEmpty;

  // --- Ekspor ----------------------------------------------------------

  /// `dashboard-<semua-cabang|KODE>-<yymmdd>.xlsx`, tanggal cabang ini.
  String exportFileName() {
    final today = localNow;
    String two(int n) => n.toString().padLeft(2, '0');
    final date = '${two(today.year % 100)}${two(today.month)}${two(today.day)}';
    final selected = _selected;
    final scope = selected == null
        ? 'semua-cabang'
        : (_data?.outletInfo[selected]?.code ?? 'cabang');
    return 'dashboard-$scope-$date.xlsx';
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

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
