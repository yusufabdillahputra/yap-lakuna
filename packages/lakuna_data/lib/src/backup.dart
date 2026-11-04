import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_client/migrations/migration_registry.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import 'preferences.dart';
import 'store.dart';
import 'store_setup.dart';

/// Backup & pulihkan data perangkat (F1-19): satu `.zip` berisi
/// `manifest.json`, salinan database (`VACUUM INTO`), dan folder `media/`.

const _manifestName = 'manifest.json';
const _dbName = 'lakuna.sqlite';
const _mediaDir = 'media';
const _restoreDir = 'restore';
const _readyMarker = 'ready';
const _restoreDone = 'pulihkan-selesai';

/// Kunci [LocalPreferences]: waktu backup terakhir (ISO UTC).
const backupLastAtKey = 'backup.last_at';

/// Versi skema (migrasi) yang dikenal aplikasi ini.
List<String> get lakunaSchemaVersions => MigrationRegistry.versions;

/// Berkas bukan backup Lakuna yang utuh (bukan zip, manifest hilang,
/// checksum database tidak cocok).
class BackupInvalid implements Exception {
  const BackupInvalid(this.reason);

  final String reason;

  @override
  String toString() => 'BackupInvalid($reason)';
}

/// Backup dibuat aplikasi yang lebih baru (versi skema tidak dikenal).
class BackupTooNew implements Exception {
  const BackupTooNew(this.schemaVersion);

  final String schemaVersion;

  @override
  String toString() => 'BackupTooNew($schemaVersion)';
}

/// Isi `manifest.json` backup.
class BackupManifest {
  const BackupManifest({
    this.app = 'lakuna',
    this.format = 1,
    required this.appVersion,
    required this.schemaVersion,
    required this.tenantId,
    required this.tenantName,
    required this.outletId,
    required this.outletCode,
    required this.outletName,
    required this.deviceId,
    required this.deviceCode,
    required this.createdAt,
    required this.sales,
    required this.products,
    required this.dbSizeBytes,
    required this.dbSha256,
    required this.media,
  });

  factory BackupManifest.fromJson(Map<String, Object?> json) {
    T field<T>(String key) {
      final v = json[key];
      if (v is! T) throw BackupInvalid('manifest.$key');
      return v;
    }

    final created = DateTime.tryParse(field<String>('createdAt'));
    if (created == null) throw const BackupInvalid('manifest.createdAt');
    return BackupManifest(
      app: field<String>('app'),
      format: field<int>('format'),
      appVersion: field<String>('appVersion'),
      schemaVersion: field<String>('schemaVersion'),
      tenantId: field<String>('tenantId'),
      tenantName: field<String>('tenantName'),
      outletId: field<String>('outletId'),
      outletCode: field<String>('outletCode'),
      outletName: field<String>('outletName'),
      deviceId: field<String>('deviceId'),
      deviceCode: field<String>('deviceCode'),
      createdAt: created.toUtc(),
      sales: field<int>('sales'),
      products: field<int>('products'),
      dbSizeBytes: field<int>('dbSizeBytes'),
      dbSha256: field<String>('dbSha256'),
      media: [for (final m in field<List<Object?>>('media')) '$m'],
    );
  }

  final String app;
  final int format;
  final String appVersion;

  /// Migrasi `lakuna` terakhir di database backup.
  final String schemaVersion;
  final String tenantId;
  final String tenantName;
  final String outletId;
  final String outletCode;
  final String outletName;
  final String deviceId;
  final String deviceCode;

  /// Waktu backup (UTC).
  final DateTime createdAt;

  /// Jumlah nota (penjualan) dan produk aktif.
  final int sales;
  final int products;
  final int dbSizeBytes;
  final String dbSha256;

  /// Nama berkas di folder `media/`.
  final List<String> media;

  Map<String, Object?> toJson() => {
    'app': app,
    'format': format,
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'tenantId': tenantId,
    'tenantName': tenantName,
    'outletId': outletId,
    'outletCode': outletCode,
    'outletName': outletName,
    'deviceId': deviceId,
    'deviceCode': deviceCode,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'sales': sales,
    'products': products,
    'dbSizeBytes': dbSizeBytes,
    'dbSha256': dbSha256,
    'media': media,
  };

  @override
  bool operator ==(Object other) =>
      other is BackupManifest &&
      jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;

  @override
  String toString() => 'BackupManifest(${jsonEncode(toJson())})';
}

/// Ringkasan data perangkat untuk layar Data & backup.
typedef BackupStats = ({int sales, int products, int sizeBytes});

Future<int> _salesCount(LakunaStore store, StoreContext ctx) => Sale.db.count(
  store.session,
  where: (s) => s.tenantId.equals(ctx.tenant.id) & s.deletedAt.equals(null),
);

Future<int> _productsCount(LakunaStore store, StoreContext ctx) =>
    Product.db.count(
      store.session,
      where: (p) => p.tenantId.equals(ctx.tenant.id) & p.deletedAt.equals(null),
    );

List<File> _mediaFiles(String mediaDirectory) {
  final dir = Directory(mediaDirectory);
  if (!dir.existsSync()) return const [];
  return [
    for (final e in dir.listSync())
      if (e is File) e,
  ]..sort((a, b) => a.path.compareTo(b.path));
}

String _baseName(String path) => path.split(RegExp(r'[\\/]')).last;

/// Jumlah nota, produk, dan ukuran data (database + gambar).
Future<BackupStats> backupStats(LakunaStore store, StoreContext ctx) async {
  final db = File(store.path);
  final size =
      (db.existsSync() ? db.lengthSync() : 0) +
      _mediaFiles(store.mediaDirectory)
          .fold<int>(0, (sum, f) => sum + f.lengthSync());
  return (
    sales: await _salesCount(store, ctx),
    products: await _productsCount(store, ctx),
    sizeBytes: size,
  );
}

String _two(int v) => v.toString().padLeft(2, '0');

String _stamp(DateTime t) =>
    '${_two(t.year % 100)}${_two(t.month)}${_two(t.day)}-'
    '${_two(t.hour)}${_two(t.minute)}';

/// `lakuna-backup-<KODECABANG>-<YYMMDD-HHMM>.zip` (waktu lokal cabang).
String backupFileName(StoreContext ctx, DateTime now) {
  final local = outletLocalTime(
    now,
    ctx.outlet.timezone ?? ctx.tenant.timezone,
  );
  return 'lakuna-backup-${ctx.outlet.code}-${_stamp(local)}.zip';
}

Future<String> _schemaVersion(LakunaStore store) async {
  final rows = await store.session.db.unsafeQuery(
    "SELECT version FROM serverpod_migrations WHERE module = 'lakuna'",
  );
  if (rows.isEmpty) return '';
  return '${rows.first.first}';
}

/// Membuat backup ke [outPath]. Database disalin dengan `VACUUM INTO`
/// (snapshot konsisten; kasir tetap bisa jalan). Berkas sementara dihapus
/// bila gagal.
Future<BackupManifest> createBackup(
  LakunaStore store,
  StoreContext ctx, {
  required String outPath,
  required String appVersion,
  DateTime? now,
}) async {
  final createdAt = (now ?? DateTime.now()).toUtc();
  final temp = await Directory.systemTemp.createTemp('lakuna_backup_');
  final snapshot = File('${temp.path}${Platform.pathSeparator}$_dbName');
  final out = File(outPath);
  try {
    final escaped = snapshot.path.replaceAll("'", "''");
    await store.session.db.unsafeExecute("VACUUM INTO '$escaped'");
    final digest = await sha256.bind(snapshot.openRead()).first;
    final media = _mediaFiles(store.mediaDirectory);
    final manifest = BackupManifest(
      appVersion: appVersion,
      schemaVersion: await _schemaVersion(store),
      tenantId: ctx.tenant.id.uuid,
      tenantName: ctx.tenant.name,
      outletId: ctx.outlet.id.uuid,
      outletCode: ctx.outlet.code,
      outletName: ctx.outlet.name,
      deviceId: store.deviceId.uuid,
      deviceCode: ctx.device.code,
      createdAt: createdAt,
      sales: await _salesCount(store, ctx),
      products: await _productsCount(store, ctx),
      dbSizeBytes: snapshot.lengthSync(),
      dbSha256: digest.toString(),
      media: [for (final f in media) _baseName(f.path)],
    );
    await out.parent.create(recursive: true);
    final encoder = ZipFileEncoder()..create(out.path);
    try {
      encoder.addArchiveFile(
        ArchiveFile.string(
          _manifestName,
          const JsonEncoder.withIndent('  ').convert(manifest.toJson()),
        ),
      );
      await encoder.addFile(snapshot, _dbName);
      for (final f in media) {
        await encoder.addFile(f, '$_mediaDir/${_baseName(f.path)}');
      }
    } finally {
      await encoder.close();
    }
    return manifest;
  } catch (_) {
    if (out.existsSync()) await out.delete();
    rethrow;
  } finally {
    await temp.delete(recursive: true);
  }
}

/// Membuka zip, menjalankan [body], lalu selalu menutup berkasnya (di
/// Windows berkas yang masih terbuka tidak bisa dipindah atau dihapus).
Future<T> _withArchive<T>(
  String zipPath,
  Future<T> Function(Archive archive) body,
) async {
  if (!File(zipPath).existsSync()) throw const BackupInvalid('missing');
  final InputFileStream input;
  try {
    input = InputFileStream(zipPath);
  } on Object {
    throw const BackupInvalid('zip');
  }
  Archive? archive;
  try {
    try {
      archive = ZipDecoder().decodeStream(input);
    } on Object {
      throw const BackupInvalid('zip');
    }
    return await body(archive);
  } finally {
    await archive?.clear();
    await input.close();
  }
}

/// Memeriksa manifest dan isi zip tanpa membaca database ke memori.
/// Checksum database diperiksa [stageRestore] saat berkas diekstrak.
BackupManifest _validate(Archive archive, List<String> knownVersions) {
  final manifestFile = archive.findFile(_manifestName);
  if (manifestFile == null) throw const BackupInvalid('manifest');
  final BackupManifest manifest;
  try {
    final json = jsonDecode(utf8.decode(manifestFile.content));
    if (json is! Map<String, Object?>) throw const BackupInvalid('manifest');
    manifest = BackupManifest.fromJson(json);
  } on BackupInvalid {
    rethrow;
  } on Object {
    throw const BackupInvalid('manifest');
  }
  if (manifest.app != 'lakuna' || manifest.format != 1) {
    throw const BackupInvalid('app');
  }
  if (manifest.schemaVersion.isEmpty) throw const BackupInvalid('manifest');
  final db = archive.findFile(_dbName);
  if (db == null || db.size != manifest.dbSizeBytes) {
    throw const BackupInvalid('database');
  }
  if (!knownVersions.contains(manifest.schemaVersion)) {
    throw BackupTooNew(manifest.schemaVersion);
  }
  return manifest;
}

/// Nama gambar yang aman diekstrak: `media/<nama>` tanpa folder, `..`,
/// atau karakter jalur Windows.
bool _safeMediaEntry(String name) {
  if (!name.startsWith('$_mediaDir/')) return false;
  final file = name.substring(_mediaDir.length + 1);
  return file.isNotEmpty &&
      file != '.' &&
      file != '..' &&
      !file.contains(RegExp(r'[/\\:]'));
}

/// Memeriksa berkas backup tanpa mengubah data. [knownVersions] = migrasi
/// yang dikenal aplikasi ini (`MigrationRegistry.versions`).
Future<BackupManifest> inspectBackup(
  String zipPath, {
  required List<String> knownVersions,
}) => _withArchive(zipPath, (a) async => _validate(a, knownVersions));

String _join(String a, String b) => '$a${Platform.pathSeparator}$b';

/// Mengekstrak backup yang sah ke `<dataDir>/restore/` dan menandainya
/// siap. Database ditulis langsung ke berkas (tidak ditampung di memori)
/// lalu checksum-nya dicocokkan. Data aktif belum berubah;
/// [applyPendingRestore] memasangnya setelah database ditutup.
Future<BackupManifest> stageRestore(
  String zipPath, {
  required String dataDir,
  required List<String> knownVersions,
}) => _withArchive(zipPath, (archive) async {
  final manifest = _validate(archive, knownVersions);
  final target = Directory(_join(dataDir, _restoreDir));
  if (target.existsSync()) await target.delete(recursive: true);
  await target.create(recursive: true);
  try {
    for (final f in archive.files) {
      if (!f.isFile) continue;
      final name = f.name;
      if (name != _dbName && !_safeMediaEntry(name)) continue;
      final dest = File(
        _join(target.path, name.replaceAll('/', Platform.pathSeparator)),
      );
      await dest.parent.create(recursive: true);
      final out = OutputFileStream(dest.path);
      try {
        f.writeContent(out);
      } on Object {
        throw const BackupInvalid('zip');
      } finally {
        await out.close();
      }
    }
    final db = File(_join(target.path, _dbName));
    final digest = await sha256.bind(db.openRead()).first;
    if (db.lengthSync() != manifest.dbSizeBytes ||
        digest.toString() != manifest.dbSha256) {
      throw const BackupInvalid('checksum');
    }
    await File(_join(target.path, _readyMarker))
        .writeAsString(manifest.createdAt.toIso8601String(), flush: true);
  } catch (_) {
    await target.delete(recursive: true);
    rethrow;
  }
  return manifest;
});

/// Ada backup yang menunggu dipasang di [dataDir].
bool hasPendingRestore(String dataDir) =>
    File(_join(_join(dataDir, _restoreDir), _readyMarker)).existsSync();

const _applyingMarker = 'applying';
const _dbFiles = ['', '-wal', '-shm', '-journal'];

Future<void> _moveIfExists(FileSystemEntity from, String to) async {
  if (from.existsSync()) await from.rename(to);
}

/// Memasang backup yang sudah disiapkan [stageRestore]. Dipanggil sebelum
/// database dibuka. Data lama dipindah ke
/// `<dataDir>/sebelum-pulihkan-<YYMMDD-HHMM>/`. Mengembalikan folder itu,
/// atau `null` bila tidak ada yang dipasang.
///
/// Aman bila aplikasi mati di tengah jalan: folder tujuan dicatat di
/// `restore/applying` sebelum ada yang dipindah, dan setiap langkah hanya
/// jalan bila belum selesai. Setelah database backup dipindah masuk, data
/// aktif tidak pernah dipindah lagi.
Future<String?> applyPendingRestore(String dataDir, {DateTime? now}) async {
  if (!hasPendingRestore(dataDir)) return null;
  final staged = _join(dataDir, _restoreDir);
  final applying = File(_join(staged, _applyingMarker));
  final Directory keep;
  if (applying.existsSync()) {
    keep = Directory(applying.readAsStringSync().trim());
  } else {
    final base = _join(
      dataDir,
      'sebelum-pulihkan-${_stamp(now ?? DateTime.now())}',
    );
    var dir = Directory(base);
    for (var i = 2; dir.existsSync(); i++) {
      dir = Directory('$base-$i');
    }
    keep = dir;
    await applying.writeAsString(keep.path, flush: true);
  }
  await keep.create(recursive: true);

  final stagedDb = File(_join(staged, _dbName));
  if (stagedDb.existsSync()) {
    // Belum dipasang: pindahkan data lama (yang belum dipindah).
    for (final suffix in _dbFiles) {
      await _moveIfExists(
        File(_join(dataDir, '$_dbName$suffix')),
        _join(keep.path, '$_dbName$suffix'),
      );
    }
    await _moveIfExists(
      Directory(_join(dataDir, _mediaDir)),
      _join(keep.path, _mediaDir),
    );
    await stagedDb.rename(_join(dataDir, _dbName));
  }
  final media = Directory(_join(dataDir, _mediaDir));
  if (!media.existsSync()) {
    await _moveIfExists(Directory(_join(staged, _mediaDir)), media.path);
  }
  // Waktu backup dicatat [finishRestore] setelah database dibuka.
  await File(_join(dataDir, _restoreDone)).writeAsString(
    File(_join(staged, _readyMarker)).readAsStringSync(),
    flush: true,
  );
  await Directory(staged).delete(recursive: true);
  return keep.path;
}

/// Dipanggil setelah database hasil pulihkan dibuka: *backup terakhir*
/// diisi waktu backup yang dipasang (nilai di dalam backup sendiri lebih
/// lama dari backup itu).
Future<void> finishRestore(LakunaStore store) async {
  final done = File(_join(File(store.path).parent.path, _restoreDone));
  if (!done.existsSync()) return;
  final at = DateTime.tryParse(done.readAsStringSync().trim());
  if (at != null) {
    await LocalPreferences(store.session)
        .set(backupLastAtKey, at.toUtc().toIso8601String());
  }
  await done.delete();
}

/// Membatalkan pemasangan backup (mis. database backup gagal dibuka):
/// data backup dipindah ke `<dataDir>/pulihkan-gagal-<YYMMDD-HHMM>/` dan
/// data lama dari [keepPath] dikembalikan. Mengembalikan folder data gagal.
Future<String> undoRestore(
  String dataDir,
  String keepPath, {
  DateTime? now,
}) async {
  final base = _join(
    dataDir,
    'pulihkan-gagal-${_stamp(now ?? DateTime.now())}',
  );
  var failed = Directory(base);
  for (var i = 2; failed.existsSync(); i++) {
    failed = Directory('$base-$i');
  }
  await failed.create(recursive: true);
  for (final suffix in _dbFiles) {
    await _moveIfExists(
      File(_join(dataDir, '$_dbName$suffix')),
      _join(failed.path, '$_dbName$suffix'),
    );
    await _moveIfExists(
      File(_join(keepPath, '$_dbName$suffix')),
      _join(dataDir, '$_dbName$suffix'),
    );
  }
  await _moveIfExists(
    Directory(_join(dataDir, _mediaDir)),
    _join(failed.path, _mediaDir),
  );
  await _moveIfExists(
    Directory(_join(keepPath, _mediaDir)),
    _join(dataDir, _mediaDir),
  );
  final done = File(_join(dataDir, _restoreDone));
  if (done.existsSync()) await done.delete();
  final keep = Directory(keepPath);
  if (keep.existsSync() && keep.listSync().isEmpty) await keep.delete();
  return failed.path;
}
