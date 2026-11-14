import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart' show Tenant;
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
  Future<Result<CreatedBackup>> createBackup({String? password}) =>
      _guard((ctx) async {
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
          password: password,
        );
        return (
          path: path,
          fileName: fileName,
          manifest: manifest,
          locked: password != null,
        );
      });

  @override
  Future<Result<DateTime>> recordBackup() => _guard((_) async {
    final now = _clock().toUtc();
    await _preferences.set(backupLastAtKey, now.toIso8601String());
    return now;
  });

  static const _autoKey = 'backup.auto';
  static const _autoLastKey = 'backup.autoLastAt';
  static const _autoFailedKey = 'backup.autoFailed';

  @override
  Future<AutoBackupState> autoBackup() async {
    final raw = await _preferences.get(_autoLastKey);
    return (
      enabled: await _preferences.get(_autoKey) != 'off',
      lastAt: raw == null ? null : DateTime.tryParse(raw)?.toUtc(),
      failed: await _preferences.get(_autoFailedKey) == '1',
    );
  }

  @override
  Future<Result<void>> setAutoBackup(bool enabled) =>
      _guard((_) => _preferences.set(_autoKey, enabled ? 'on' : 'off'));

  @override
  Future<Result<String>> runAutoBackup(Directory folder) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    // Folder sementara sendiri: tidak menghapus salinan backup manual yang
    // mungkin masih dibagikan.
    final temp = Directory('${_exports.path}-otomatis');
    File? part;
    try {
      final now = _clock();
      final fileName = backupFileName(ctx, now);
      if (temp.existsSync()) await temp.delete(recursive: true);
      await temp.create(recursive: true);
      final staged = p.join(temp.path, fileName);
      await data.createBackup(
        _store,
        ctx,
        outPath: staged,
        appVersion: _appVersion,
        now: now,
      );
      await folder.create(recursive: true);
      final target = p.join(folder.path, fileName);
      // Disalin ke `.part` lalu diganti nama: berkas setengah jadi (disk
      // penuh, aplikasi ditutup) tidak pernah tampak sebagai backup sah.
      part = await File(staged).copy('$target.part');
      await part.rename(target);
      part = null;
      await temp.delete(recursive: true);
      await _pruneAuto(folder);
      final at = now.toUtc().toIso8601String();
      await _preferences.set(_autoLastKey, at);
      await _preferences.set(backupLastAtKey, at);
      await _preferences.set(_autoFailedKey, '0');
      return Result.ok(target);
      // Galat apa pun (termasuk Error) dicatat sebagai gagal agar terlihat
      // di Pengaturan, bukan diam-diam hilang di penjadwal.
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      await _cleanAutoFailure(temp, part);
      return Result.error(e is Exception ? e : AutoBackupFailed('$e'));
    }
  }

  Future<void> _cleanAutoFailure(Directory temp, File? part) async {
    try {
      await _preferences.set(_autoFailedKey, '1');
    } on Exception {
      // Database tidak bisa ditulis: status gagal tidak tercatat.
    }
    try {
      if (part != null && part.existsSync()) await part.delete();
      if (temp.existsSync()) await temp.delete(recursive: true);
    } on FileSystemException {
      // Dibersihkan pada percobaan berikutnya.
    }
  }

  static final _autoName = RegExp(
    r'^lakuna-backup-.+-(\d{6}-\d{4}(?:-\d+)?)\.zip$',
  );

  /// Menyisakan [autoBackupKeep] berkas `lakuna-backup-*.zip` terbaru.
  /// Diurutkan menurut cap waktu di akhir nama (bukan nama penuh): kode
  /// cabang bisa berubah dan tidak boleh mendahului waktu.
  Future<void> _pruneAuto(Directory folder) async {
    final files = <(String, File)>[
      for (final e in folder.listSync())
        if (e is File)
          if (_autoName.firstMatch(p.basename(e.path)) case final m?)
            (m.group(1)!, e),
    ]..sort((a, b) => b.$1.compareTo(a.$1));
    for (final (_, old) in files.skip(autoBackupKeep)) {
      await old.delete();
    }
  }

  @override
  Future<DateTime?> lastBackupAt() async {
    final raw = await _preferences.get(backupLastAtKey);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  @override
  Future<Result<BackupManifest>> inspect(String path, {String? password}) =>
      _guard((_) => _inspect(path, password));

  @override
  Future<Result<BackupManifest>> stageRestore(
    String path, {
    String? password,
  }) => _guard((_) => _stage(path, password));

  @override
  Future<Result<BackupManifest>> inspectForSetup(
    String path, {
    String? password,
  }) => _beforeSetup(() => _inspect(path, password));

  @override
  Future<Result<BackupManifest>> stageRestoreForSetup(
    String path, {
    String? password,
  }) => _beforeSetup(() => _stage(path, password));

  Future<BackupManifest> _inspect(String path, String? password) =>
      data.inspectBackup(
        path,
        knownVersions: lakunaSchemaVersions,
        password: password,
      );

  Future<BackupManifest> _stage(String path, String? password) =>
      data.stageRestore(
        path,
        dataDir: _dataDir,
        knownVersions: lakunaSchemaVersions,
        password: password,
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
        // Sama dengan `setupStore`: tenant yang ada (walau data perangkat
        // tidak lengkap) tetap dianggap toko.
        final tenants = await Tenant.db.count(
          _store.session,
          where: (t) => t.deletedAt.equals(null),
        );
        if (tenants > 0) return const Result.error(StoreAlreadySetUp());
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
