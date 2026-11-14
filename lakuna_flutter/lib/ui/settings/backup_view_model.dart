import 'dart:async';
import 'dart:io';
import 'dart:math' show max;

import 'package:flutter/foundation.dart';
import 'package:lakuna_domain/lakuna_domain.dart'
    show BackupPasswordProblem, backupPasswordProblem;

import '../../data/repositories/backup_repository.dart';
import '../../data/services/auto_backup.dart' as auto;
import '../../data/services/backup_files.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Konfirmasi pulihkan belum sesuai (nama toko tidak cocok).
class RestoreNotConfirmed implements Exception {
  const RestoreNotConfirmed();
}

/// Kata sandi backup belum sah (F1-19c); tombol sudah nonaktif, ini
/// penjaga bila perintah tetap dijalankan.
class BackupPasswordInvalid implements Exception {
  const BackupPasswordInvalid();
}

/// View model bagian *Data & backup* (1.13, F1-19).
class BackupViewModel extends ChangeNotifier {
  BackupViewModel({
    required this._repository,
    required this._files,
    this._restart,
    DateTime Function()? clock,
    this.autoSupported = false,
    Future<Directory> Function()? autoFolder,
  }) : _clock = clock ?? DateTime.now,
       _autoFolder = autoFolder ?? auto.autoBackupDirectory {
    load = Command0(_load)..addListener(notifyListeners);
    backupNow = Command0(_backupNow)..addListener(notifyListeners);
    pickRestore = Command0(_pickRestore)..addListener(notifyListeners);
    restore = Command0(_restore)..addListener(notifyListeners);
    unlock = Command0(_unlock)..addListener(notifyListeners);
    setAuto = Command1(_setAuto)..addListener(notifyListeners);
  }

  /// Backup otomatis harian tersedia di perangkat ini (desktop, F1-19d).
  final bool autoSupported;
  final Future<Directory> Function() _autoFolder;

  /// Menyalakan/mematikan backup otomatis harian.
  late final Command1<void, bool> setAuto;

  AutoBackupState? _auto;
  String? _autoFolderPath;

  AutoBackupState? get autoBackup => _auto;

  /// Lokasi folder backup otomatis (untuk keterangan).
  String? get autoFolderPath => _autoFolderPath;

  /// Hari sejak backup otomatis terakhir; `null` bila belum pernah.
  /// Tidak pernah negatif (jam perangkat dimundurkan).
  int? get daysSinceAutoBackup => switch (_auto?.lastAt) {
    final t? => max(0, _clock().toUtc().difference(t).inDays),
    null => null,
  };

  /// Lokasi folder dimuat terpisah agar layar tidak menunggu.
  Future<void> _loadAutoFolder() async {
    try {
      _autoFolderPath = (await _autoFolder()).path;
      notifyListeners();
    } on Exception {
      // Folder tidak bisa ditentukan: keterangan tanpa lokasi.
    }
  }

  Future<Result<void>> _setAuto(bool enabled) async {
    final result = await _repository.setAutoBackup(enabled);
    if (result is Ok<void>) _auto = await _repository.autoBackup();
    return result;
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

  /// Membuka backup terkunci dengan [unlockPassword] (F1-19c).
  late final Command0<void> unlock;

  BackupStats? _stats;
  DateTime? _lastBackupAt;
  BackupDelivery? _lastDelivery;
  String? _restorePath;
  BackupManifest? _pendingRestore;
  var _confirmText = '';
  var _disposed = false;

  // Kunci backup (F1-19c). Kata sandi hanya di memori dan dikosongkan
  // setelah backup dibuat atau pulihkan dibatalkan.
  var _lockEnabled = false;
  var _password = '';
  var _passwordRetype = '';
  var _passwordRevision = 0;
  var _lastBackupLocked = false;
  var _needsPassword = false;
  var _unlockPassword = '';
  var _unlockRevision = 0;
  String? _restorePassword;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  bool get lockEnabled => _lockEnabled;
  String get password => _password;
  String get passwordRetype => _passwordRetype;

  /// Naik setiap isian kata sandi dikosongkan (widget membuat ulang isian).
  int get passwordRevision => _passwordRevision;

  /// Masalah isian kata sandi; `null` bila sah atau sakelar mati.
  BackupPasswordProblem? get passwordProblem =>
      _lockEnabled ? backupPasswordProblem(_password, _passwordRetype) : null;

  bool get _busy =>
      backupNow.running ||
      pickRestore.running ||
      restore.running ||
      unlock.running;

  bool get canBackup => !_busy && passwordProblem == null;

  /// Backup terakhir dikunci kata sandi.
  bool get lastBackupLocked => _lastBackupLocked;

  /// Berkas yang dipilih terkunci dan belum dibuka.
  bool get needsPassword => _needsPassword;
  String get unlockPassword => _unlockPassword;

  /// Naik setiap pilihan pulihkan direset (widget membuat ulang isian kata
  /// sandi; hasil buka kunci yang tertinggal diabaikan).
  int get unlockRevision => _unlockRevision;
  bool get canUnlock =>
      _needsPassword && _unlockPassword.isNotEmpty && !unlock.running;

  void setLock(bool value) {
    _lockEnabled = value;
    if (!value) _clearPassword();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setPasswordRetype(String value) {
    _passwordRetype = value;
    notifyListeners();
  }

  void setUnlockPassword(String value) {
    _unlockPassword = value;
    notifyListeners();
  }

  void _clearPassword() {
    _password = '';
    _passwordRetype = '';
    _passwordRevision++;
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
    _resetRestore();
    pickRestore.clearResult();
    restore.clearResult();
    notifyListeners();
  }

  void _resetRestore() {
    _restorePath = null;
    _pendingRestore = null;
    _confirmText = '';
    _needsPassword = false;
    _unlockPassword = '';
    _restorePassword = null;
    _unlockRevision++;
    unlock.clearResult();
  }

  Future<Result<void>> _load() async {
    final result = await _repository.load();
    if (result case Ok(:final value)) {
      _stats = value.stats;
      _lastBackupAt = value.lastBackupAt;
      if (autoSupported) {
        _auto = await _repository.autoBackup();
        if (_autoFolderPath == null) unawaited(_loadAutoFolder());
      }
    }
    return result;
  }

  Future<Result<BackupDelivery>> _backupNow() async {
    if (passwordProblem != null) {
      return const Result.error(BackupPasswordInvalid());
    }
    _lastDelivery = null;
    final password = _lockEnabled ? _password : null;
    final created = await _repository.createBackup(password: password);
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
            _lastBackupLocked = value.locked;
            if (password != null) _clearPassword();
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
    _resetRestore();
    final path = await _files.pickBackup();
    if (path == null) return const Result.ok(null);
    final result = await _repository.inspect(path);
    switch (result) {
      case Ok(:final value):
        _restorePath = path;
        _pendingRestore = value;
      case Error(error: BackupLocked()):
        // Terkunci (F1-19c): minta kata sandi dulu, bukan galat.
        _restorePath = path;
        _needsPassword = true;
        return const Result.ok(null);
      case Error():
    }
    return result;
  }

  Future<Result<void>> _unlock() async {
    final path = _restorePath;
    final password = _unlockPassword;
    if (path == null || !_needsPassword || password.isEmpty) {
      return const Result.error(BackupLocked());
    }
    final revision = _unlockRevision;
    final result = await _repository.inspect(path, password: password);
    // Dibatalkan atau berkas lain dipilih selagi kunci dibuka.
    if (revision != _unlockRevision) return const Result.ok(null);
    if (result case Ok(:final value)) {
      _needsPassword = false;
      _unlockPassword = '';
      _restorePassword = password;
      _pendingRestore = value;
    }
    return result;
  }

  Future<Result<void>> _restore() async {
    final path = _restorePath;
    if (path == null || !canConfirmRestore) {
      return const Result.error(RestoreNotConfirmed());
    }
    final result = await _repository.stageRestore(
      path,
      password: _restorePassword,
    );
    if (result is Error<BackupManifest>) return result;
    await _restart?.call();
    return const Result.ok(null);
  }
}
