import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart' show BusinessType;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/backup_repository.dart' as backups;
import '../../data/repositories/backup_repository.dart' show BackupRepository;
import '../../data/repositories/dining_repository.dart';
import '../../data/repositories/reports_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../core/menu.dart';

/// Bagian hari untuk sapaan Beranda (jam cabang).
enum DayPart {
  /// 04.00–10.59.
  morning,

  /// 11.00–14.59.
  midday,

  /// 15.00–17.59.
  afternoon,

  /// 18.00–03.59.
  night;

  static DayPart at(int hour) => switch (hour) {
    >= 4 && < 11 => morning,
    >= 11 && < 15 => midday,
    >= 15 && < 18 => afternoon,
    _ => night,
  };
}

/// Ringkasan *Penjualan hari ini* (laporan F1-16 periode hari ini).
typedef SalesToday = ({Money total, int count, Money average});

/// Kunci modul di grid Beranda (urutan kanvas 1.10; Meja untuk F&B).
const homeModuleKeys = [
  'cashier',
  'tables',
  'history',
  'products',
  'stock',
  'purchases',
  'expenses',
  'customers',
  'reports',
];

/// View model Beranda (1.10, F1-20). Setiap sumber dimuat sendiri; galat
/// atau izin yang kurang hanya menyembunyikan bagiannya.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._store,
    required this._session,
    this._reports,
    this._stock,
    this._dining,
    this._backup,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final StoreRepository _store;
  final SessionRepository _session;
  final ReportsRepository? _reports;
  final StockRepository? _stock;
  final DiningRepository? _dining;
  final BackupRepository? _backup;
  final DateTime Function() _clock;

  late final Command0<void> load;

  SalesToday? _sales;
  int? _belowMinimum;
  int? _pendingQris;
  var _backupLoaded = false;
  DateTime? _lastBackupAt;
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

  Set<Permission> get _permissions => _session.current?.permissions ?? const {};

  bool _allows(String key) =>
      menuEntryByKey(key)?.allows(_permissions) ?? false;

  /// Waktu sekarang di zona cabang.
  DateTime get _localNow {
    final ctx = _store.current;
    return outletLocalTime(
      _clock(),
      ctx?.outlet.timezone ?? ctx?.tenant.timezone,
    );
  }

  DayPart get dayPart => DayPart.at(_localNow.hour);

  String get staffName => _session.current?.name ?? '';

  /// Meja hanya untuk usaha F&B / campuran yang staf-nya berizin.
  bool get _showsTables =>
      _allows('tables') &&
      _store.current?.tenant.businessType != BusinessType.retail;

  /// Modul grid yang boleh dibuka staf.
  List<MenuEntry> get modules => [
    for (final key in homeModuleKeys)
      if (menuEntryByKey(key) case final e?
          when e.allows(_permissions) && (key != 'tables' || _showsTables))
        e,
  ];

  /// `null` bila tanpa `reports:view` atau gagal dimuat.
  SalesToday? get sales => _sales;

  /// Jumlah varian di bawah stok minimum; `null` = baris disembunyikan.
  int? get belowMinimum => _belowMinimum;

  /// QRIS bagian split bill yang menunggu; `null` = baris disembunyikan.
  int? get pendingQris => _pendingQris;

  /// Baris backup tampil (staf `backup:manage`, data termuat).
  bool get showBackup => _backupLoaded;
  DateTime? get lastBackupAt => _lastBackupAt;

  /// Hari sejak backup terakhir menurut tanggal cabang (0 = hari ini,
  /// 1 = kemarin); `null` bila belum pernah.
  int? get backupDaysAgo {
    final at = _lastBackupAt;
    if (at == null) return null;
    final ctx = _store.current;
    final tz = ctx?.outlet.timezone ?? ctx?.tenant.timezone;
    DateTime day(DateTime t) {
      final l = outletLocalTime(t, tz);
      return DateTime.utc(l.year, l.month, l.day);
    }

    final days = day(_clock()).difference(day(at)).inDays;
    return days < 0 ? 0 : days;
  }

  bool get backupOverdue =>
      _backupLoaded && backups.backupOverdue(_lastBackupAt, _clock().toUtc());

  /// Galat salah satu sumber (termasuk galat non-`Exception`) hanya
  /// menyembunyikan bagiannya; setiap bagian tampil begitu datanya ada.
  Future<void> _source<T>(
    Future<T> Function() fetch,
    void Function(T? value) apply,
  ) async {
    T? value;
    try {
      value = await fetch();
    } catch (e) {
      debugPrint('Beranda: $e');
      value = null;
    }
    apply(value);
    notifyListeners();
  }

  T? _ok<T>(Result<T>? result) => switch (result) {
    Ok(:final value) => value,
    _ => null,
  };

  /// `null` dari [BackupRepository.lastBackupAt] berarti belum pernah
  /// backup; galat menyembunyikan barisnya.
  Future<void> _loadBackup(BackupRepository backup) async {
    try {
      _lastBackupAt = await backup.lastBackupAt();
      _backupLoaded = true;
    } catch (e) {
      debugPrint('Beranda: $e');
      _backupLoaded = false;
    }
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final permissions = _permissions;
    await Future.wait([
      if (_reports case final r?
          when permissions.contains(
            Permission.reportsView,
          ))
        _source(() => r.load(ReportPeriod.today), (res) {
          _sales = switch (_ok(res)) {
            final value? => (
              total: value.netSales,
              count: value.saleCount,
              average: value.averagePerSale,
            ),
            null => null,
          };
        }),
      if (_stock case final s? when _allows('stock'))
        _source(
          s.belowMinimum,
          (res) => _belowMinimum = _ok(res)?.length,
        ),
      if (_dining case final d? when _showsTables)
        _source(d.pendingQrisCount, (res) => _pendingQris = _ok(res)),
      if (_backup case final b?
          when permissions.contains(
            Permission.backupManage,
          ))
        _loadBackup(b),
    ]);
    return const Result.ok(null);
  }
}
