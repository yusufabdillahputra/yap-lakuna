import 'package:flutter/foundation.dart';

import '../../data/repositories/backup_repository.dart';
import '../../data/services/backup_files.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Konfirmasi pulihkan belum sesuai (nama toko tidak cocok).
class RestoreNotConfirmed implements Exception {
  const RestoreNotConfirmed();
}

/// View model bagian *Data & backup* (1.13, F1-19).
class BackupViewModel extends ChangeNotifier {
  BackupViewModel({
    required this._repository,
    required this._files,
    this._restart,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load)..addListener(notifyListeners);
    backupNow = Command0(_backupNow)..addListener(notifyListeners);
    pickRestore = Command0(_pickRestore)..addListener(notifyListeners);
    restore = Command0(_restore)..addListener(notifyListeners);
  }

  final BackupRepository _repository;
  final BackupFiles _files;

  /// Memuat ulang aplikasi setelah backup disiapkan (`null` di tes).
  final Future<void> Function()? _restart;
  final DateTime Function() _clock;

  late final Command0<void> load;
  late final Command0<BackupDelivery> backupNow;
  late final Command0<void> pickRestore;
  late final Command0<void> restore;

  BackupStats? _stats;
  DateTime? _lastBackupAt;
  BackupDelivery? _lastDelivery;
  String? _restorePath;
  BackupManifest? _pendingRestore;
  var _confirmText = '';
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

  BackupStats? get stats => _stats;
  DateTime? get lastBackupAt => _lastBackupAt;

  /// Hari sejak backup terakhir; `null` bila belum pernah.
  int? get daysSinceBackup => switch (_lastBackupAt) {
    final t? => _clock().toUtc().difference(t).inDays,
    null => null,
  };

  bool get overdue => backupOverdue(_lastBackupAt, _clock().toUtc());

  /// Hasil *Backup sekarang* terakhir (lokasi simpan / dibagikan).
  BackupDelivery? get lastDelivery => _lastDelivery;

  /// Isi backup yang dipilih untuk dipulihkan (menunggu konfirmasi).
  BackupManifest? get pendingRestore => _pendingRestore;
  String get confirmText => _confirmText;

  bool get canConfirmRestore {
    final m = _pendingRestore;
    return m != null &&
        _confirmText.trim().toLowerCase() == m.tenantName.trim().toLowerCase();
  }

  void setConfirmText(String value) {
    _confirmText = value;
    notifyListeners();
  }

  void cancelRestore() {
    _restorePath = null;
    _pendingRestore = null;
    _confirmText = '';
    pickRestore.clearResult();
    restore.clearResult();
    notifyListeners();
  }

  Future<Result<void>> _load() async {
    final result = await _repository.load();
    if (result case Ok(:final value)) {
      _stats = value.stats;
      _lastBackupAt = value.lastBackupAt;
    }
    return result;
  }

  Future<Result<BackupDelivery>> _backupNow() async {
    _lastDelivery = null;
    final created = await _repository.createBackup();
    switch (created) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        try {
          final delivery = await _files.deliver(
            value.path,
            fileName: value.fileName,
          );
          _lastDelivery = delivery;
          if (delivery is! BackupDismissed) {
            if (await _repository.recordBackup() case Ok(value: final at)) {
              _lastBackupAt = at;
            }
          }
          return Result.ok(delivery);
        } on Exception catch (e) {
          return Result.error(e);
        }
    }
  }

  Future<Result<void>> _pickRestore() async {
    _restorePath = null;
    _pendingRestore = null;
    _confirmText = '';
    final path = await _files.pickBackup();
    if (path == null) return const Result.ok(null);
    final result = await _repository.inspect(path);
    if (result case Ok(:final value)) {
      _restorePath = path;
      _pendingRestore = value;
    }
    return result;
  }

  Future<Result<void>> _restore() async {
    final path = _restorePath;
    if (path == null || !canConfirmRestore) {
      return const Result.error(RestoreNotConfirmed());
    }
    final result = await _repository.stageRestore(path);
    if (result is Error<BackupManifest>) return result;
    await _restart?.call();
    return const Result.ok(null);
  }
}
