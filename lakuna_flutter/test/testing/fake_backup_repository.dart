import 'package:lakuna_flutter/data/repositories/backup_repository.dart';
import 'package:lakuna_flutter/data/services/backup_files.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// Manifest contoh untuk tes.
BackupManifest sampleManifest({
  String tenantName = 'Warung Contoh',
  DateTime? createdAt,
}) => BackupManifest(
  appVersion: '0.25.0',
  schemaVersion: '20261104045959871-manual-discount',
  tenantId: '01a1a4fb-0000-7000-8000-000000000001',
  tenantName: tenantName,
  outletId: '01a1a4fb-0000-7000-8000-000000000002',
  outletCode: 'PST',
  outletName: 'Cabang Pusat',
  deviceId: '01a1a4fb-0000-7000-8000-000000000003',
  deviceCode: 'K01',
  createdAt: createdAt ?? DateTime.utc(2026, 10, 26, 2),
  sales: 128,
  products: 42,
  dbSizeBytes: 2048,
  dbSha256: 'abc',
  media: const ['a.png'],
);

/// [BackupRepository] palsu di memori.
class FakeBackupRepository implements BackupRepository {
  FakeBackupRepository({
    this.stats = (sales: 1240, products: 86, sizeBytes: 18 * 1024 * 1024),
    this.last,
  });

  BackupStats stats;
  DateTime? last;
  DateTime now = DateTime.utc(2026, 11, 4, 9);

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;

  /// Manifest yang dikembalikan [inspect]; galat bila diisi [inspectError].
  BackupManifest manifest = sampleManifest();
  Exception? inspectError;

  final created = <String>[];
  final staged = <String>[];

  Result<T> _r<T>(T Function() ok) {
    final e = nextError;
    nextError = null;
    return e == null ? Result.ok(ok()) : Result.error(e);
  }

  @override
  Future<Result<BackupOverview>> load() async =>
      _r(() => (stats: stats, lastBackupAt: last));

  @override
  Future<Result<CreatedBackup>> createBackup() async => _r(() {
    const name = 'lakuna-backup-PST-261104-1600.zip';
    created.add(name);
    return (path: '/tmp/$name', fileName: name, manifest: sampleManifest());
  });

  @override
  Future<Result<DateTime>> recordBackup() async => _r(() => last = now);

  @override
  Future<DateTime?> lastBackupAt() async => last;

  @override
  Future<Result<BackupManifest>> inspect(String path) async {
    if (inspectError case final e?) return Result.error(e);
    return _r(() => manifest);
  }

  @override
  Future<Result<BackupManifest>> stageRestore(String path) async => _r(() {
    staged.add(path);
    return manifest;
  });

  /// Toko sudah ada: pulihkan dari onboarding ditolak.
  bool storeExists = false;

  @override
  Future<Result<BackupManifest>> inspectForSetup(String path) async {
    if (storeExists) return const Result.error(StoreAlreadySetUp());
    return inspect(path);
  }

  @override
  Future<Result<BackupManifest>> stageRestoreForSetup(String path) async {
    if (storeExists) return const Result.error(StoreAlreadySetUp());
    return stageRestore(path);
  }
}

/// [BackupFiles] palsu: hasil serah dan berkas pilihan bisa diatur.
class FakeBackupFiles extends BackupFiles {
  FakeBackupFiles({this.delivery = const BackupSaved('/docs/Lakuna/Backup')});

  BackupDelivery delivery;
  String? picked = '/tmp/lakuna-backup-PST-261026-0900.zip';
  final delivered = <String>[];

  @override
  Future<BackupDelivery> deliver(
    String path, {
    required String fileName,
  }) async {
    delivered.add(fileName);
    return delivery;
  }

  @override
  Future<String?> pickBackup() async => picked;
}
