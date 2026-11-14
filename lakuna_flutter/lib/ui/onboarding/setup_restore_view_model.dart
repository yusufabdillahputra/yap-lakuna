import 'package:flutter/foundation.dart';

import '../../data/repositories/backup_repository.dart';
import '../../data/services/backup_files.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../settings/backup_view_model.dart' show RestoreNotConfirmed;

/// Pulihkan backup dari onboarding (1.1, F1-19b): pilih berkas, ringkasan,
/// ketik nama toko, lalu backup disiapkan dan aplikasi dimuat ulang.
class SetupRestoreViewModel extends ChangeNotifier {
  SetupRestoreViewModel({
    required this._repository,
    required this._files,
    this._restart,
  }) {
    pick = Command0(_pick)..addListener(notifyListeners);
    restore = Command0(_restore)..addListener(notifyListeners);
    unlock = Command0(_unlock)..addListener(notifyListeners);
  }

  final BackupRepository _repository;
  final BackupFiles _files;

  /// Memuat ulang aplikasi setelah backup disiapkan (`null` di tes).
  final Future<void> Function()? _restart;

  late final Command0<void> pick;
  late final Command0<void> restore;

  /// Membuka backup terkunci dengan [unlockPassword] (F1-19c).
  late final Command0<void> unlock;

  String? _path;
  BackupManifest? _manifest;
  var _confirmText = '';
  var _staged = false;
  var _needsPassword = false;
  var _unlockPassword = '';
  var _unlockRevision = 0;
  String? _password;

  /// Naik setiap berkas dipilih (isian kata sandi dibuat ulang; hasil buka
  /// kunci yang tertinggal diabaikan).
  int get unlockRevision => _unlockRevision;

  /// Berkas yang dipilih terkunci dan belum dibuka (F1-19c).
  bool get needsPassword => _needsPassword;
  String get unlockPassword => _unlockPassword;
  bool get canUnlock =>
      _needsPassword && _unlockPassword.isNotEmpty && !unlock.running;

  void setUnlockPassword(String value) {
    _unlockPassword = value;
    notifyListeners();
  }

  /// Backup sudah disiapkan; tanpa muat ulang otomatis (tidak ada
  /// `AppRestart`) pengguna diminta membuka ulang aplikasi.
  bool get staged => _staged;
  var _disposed = false;

  // Perintah tidak dibuang: [restore] masih menunggu [_restart] saat
  // aplikasi dimuat ulang dan dialog ini dilepas (sama dengan
  // `BackupViewModel`); pemberitahuannya diredam lewat [_disposed].
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  /// Isi backup yang dipilih (menunggu konfirmasi).
  BackupManifest? get manifest => _manifest;
  String get confirmText => _confirmText;
  bool get busy => pick.running || restore.running || unlock.running || _staged;

  /// Nama toko yang diketik cocok (tidak peka huruf, spasi tepi diabaikan).
  bool get _nameMatches {
    final m = _manifest;
    return m != null &&
        _confirmText.trim().toLowerCase() == m.tenantName.trim().toLowerCase();
  }

  bool get canConfirm => _nameMatches && !restore.running && !_staged;

  void setConfirmText(String value) {
    _confirmText = value;
    notifyListeners();
  }

  Future<Result<void>> _pick() async {
    final String? path;
    try {
      path = await _files.pickBackup();
    } on Exception catch (e) {
      return Result.error(e);
    }
    // Batal memilih: pilihan sebelumnya tetap.
    if (path == null) return const Result.ok(null);
    _path = null;
    _manifest = null;
    _confirmText = '';
    _needsPassword = false;
    _unlockPassword = '';
    _password = null;
    _unlockRevision++;
    restore.clearResult();
    unlock.clearResult();
    final result = await _repository.inspectForSetup(path);
    switch (result) {
      case Ok(:final value):
        _path = path;
        _manifest = value;
      case Error(error: BackupLocked()):
        _path = path;
        _needsPassword = true;
        return const Result.ok(null);
      case Error():
    }
    return result;
  }

  Future<Result<void>> _unlock() async {
    final path = _path;
    final password = _unlockPassword;
    if (path == null || !_needsPassword || password.isEmpty) {
      return const Result.error(BackupLocked());
    }
    final revision = _unlockRevision;
    final result = await _repository.inspectForSetup(path, password: password);
    // Berkas lain dipilih selagi kunci dibuka.
    if (revision != _unlockRevision) return const Result.ok(null);
    if (result case Ok(:final value)) {
      _needsPassword = false;
      _unlockPassword = '';
      _password = password;
      _manifest = value;
    }
    return result;
  }

  Future<Result<void>> _restore() async {
    final path = _path;
    if (path == null || !_nameMatches) {
      return const Result.error(RestoreNotConfirmed());
    }
    final result = await _repository.stageRestoreForSetup(
      path,
      password: _password,
    );
    if (result case Error(:final error)) return Result.error(error);
    _staged = true;
    await _restart?.call();
    return const Result.ok(null);
  }
}
