import 'dart:io';

import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart'
    as data
    show createBackup, inspectBackup, stageRestore;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:path/path.dart' as p;

import '../../utils/result.dart';
import 'backup_repository.dart';
import 'repository_errors.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [BackupRepository] di atas database dan folder data perangkat.
class LocalBackupRepository implements BackupRepository {
  LocalBackupRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._preferences,
    required this._appVersion,
    DateTime Function()? clock,
    Directory? exportDirectory,
  }) : _clock = clock ?? DateTime.now,
       _exports =
           exportDirectory ??
           Directory(p.join(Directory.systemTemp.path, 'lakuna-backup-ekspor'));

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final LocalPreferences _preferences;
  final String _appVersion;
  final DateTime Function() _clock;

  /// Folder sementara berkas backup sebelum disimpan / dibagikan. Isinya
  /// (salinan penuh data toko) dihapus setiap kali backup baru dibuat; di
  /// ponsel berkas tidak dihapus segera karena aplikasi tujuan bagikan
  /// mungkin masih membacanya.
  final Directory _exports;

  String get _dataDir => p.dirname(_store.path);

  @override
  Future<Result<BackupOverview>> load() => _guard(
    (ctx) async => (
      stats: await backupStats(_store, ctx),
      lastBackupAt: await lastBackupAt(),
    ),
  );

  @override
  Future<Result<CreatedBackup>> createBackup() => _guard((ctx) async {
    final now = _clock();
    final fileName = backupFileName(ctx, now);
    if (_exports.existsSync()) await _exports.delete(recursive: true);
    await _exports.create(recursive: true);
    final path = p.join(_exports.path, fileName);
    final manifest = await data.createBackup(
      _store,
      ctx,
      outPath: path,
      appVersion: _appVersion,
      now: now,
    );
    return (path: path, fileName: fileName, manifest: manifest);
  });

  @override
  Future<Result<DateTime>> recordBackup() => _guard((_) async {
    final now = _clock().toUtc();
    await _preferences.set(backupLastAtKey, now.toIso8601String());
    return now;
  });

  @override
  Future<DateTime?> lastBackupAt() async {
    final raw = await _preferences.get(backupLastAtKey);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  @override
  Future<Result<BackupManifest>> inspect(String path) => _guard(
    (_) => data.inspectBackup(path, knownVersions: lakunaSchemaVersions),
  );

  @override
  Future<Result<BackupManifest>> stageRestore(String path) => _guard(
    (_) => data.stageRestore(
      path,
      dataDir: _dataDir,
      knownVersions: lakunaSchemaVersions,
    ),
  );

  @override
  Future<Result<BackupManifest>> inspectForSetup(String path) => _beforeSetup(
    () => data.inspectBackup(path, knownVersions: lakunaSchemaVersions),
  );

  @override
  Future<Result<BackupManifest>> stageRestoreForSetup(String path) =>
      _beforeSetup(
        () => data.stageRestore(
          path,
          dataDir: _dataDir,
          knownVersions: lakunaSchemaVersions,
        ),
      );

  /// Onboarding belum punya staf; satu-satunya syarat adalah belum ada toko,
  /// agar data toko yang ada tidak bisa ditimpa tanpa `backup:manage`.
  Future<Result<T>> _beforeSetup<T>(Future<T> Function() body) async {
    if (_stores.current != null) {
      return const Result.error(StoreAlreadySetUp());
    }
    // Baca ulang dari database: `current` bisa belum termuat.
    switch (await _stores.load()) {
      case Ok(value: null):
        break;
      case Ok():
        return const Result.error(StoreAlreadySetUp());
      case Error(:final error):
        return Result.error(error);
    }
    try {
      return Result.ok(await body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<T>> _guard<T>(Future<T> Function(StoreContext ctx) body) async {
    const permission = Permission.backupManage;
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(permission)) {
      return const Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(ctx));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
