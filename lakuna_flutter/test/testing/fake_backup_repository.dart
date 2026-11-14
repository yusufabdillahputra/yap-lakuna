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

  /// Kata sandi tiap [createBackup] (`null` = tanpa kunci).
  final createdPasswords = <String?>[];

  /// Backup yang dipilih terkunci dengan kata sandi ini (F1-19c).
  String? lockPassword;

  /// Bila diisi, [inspect] menunggu ini (untuk tes balapan).
  Future<void>? inspectGate;

  /// Kata sandi yang dipakai [stageRestore].
  final stagedPasswords = <String?>[];

  Result<T>? _locked<T>(String? password) {
    final lock = lockPassword;
    if (lock == null) return null;
    if (password == null) return const Result.error(BackupLocked());
    if (password != lock) return const Result.error(BackupWrongPassword());
    return null;
  }

  Result<T> _r<T>(T Function() ok) {
    final e = nextError;
    nextError = null;
    return e == null ? Result.ok(ok()) : Result.error(e);
  }

  @override
  Future<Result<BackupOverview>> load() async =>
      _r(() => (stats: stats, lastBackupAt: last));

  @override
  Future<Result<CreatedBackup>> createBackup({String? password}) async =>
      _r(() {
        const name = 'lakuna-backup-PST-261104-1600.zip';
        created.add(name);
        createdPasswords.add(password);
        return (
          path: '/tmp/$name',
          fileName: name,
          manifest: sampleManifest(),
          locked: password != null,
        );
      });

  @override
  Future<Result<DateTime>> recordBackup() async => _r(() => last = now);

  @override
  Future<DateTime?> lastBackupAt() async => last;

  @override
  Future<Result<BackupManifest>> inspect(
    String path, {
    String? password,
  }) async {
    if (inspectError case final e?) return Result.error(e);
    if (inspectGate case final gate?) await gate;
    if (_locked<BackupManifest>(password) case final r?) return r;
    return _r(() => manifest);
  }

  @override
  Future<Result<BackupManifest>> stageRestore(
    String path, {
    String? password,
  }) async {
    if (_locked<BackupManifest>(password) case final r?) return r;
    return _r(() {
      staged.add(path);
      stagedPasswords.add(password);
      return manifest;
    });
  }

  /// Toko sudah ada: pulihkan dari onboarding ditolak.
  bool storeExists = false;

  @override
  Future<Result<BackupManifest>> inspectForSetup(
    String path, {
    String? password,
  }) async {
    if (storeExists) return const Result.error(StoreAlreadySetUp());
    return inspect(path, password: password);
  }

  @override
  Future<Result<BackupManifest>> stageRestoreForSetup(
    String path, {
    String? password,
  }) async {
    if (storeExists) return const Result.error(StoreAlreadySetUp());
    return stageRestore(path, password: password);
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
