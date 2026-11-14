import 'package:lakuna_data/lakuna_data.dart' show BackupManifest, BackupStats;

import '../../utils/result.dart';

export 'package:lakuna_data/lakuna_data.dart'
    show
        BackupInvalid,
        BackupLocked,
        BackupManifest,
        BackupStats,
        BackupTooNew,
        BackupWrongPassword;

/// Ringkasan layar *Data & backup* (1.13).
typedef BackupOverview = ({BackupStats stats, DateTime? lastBackupAt});

/// Berkas backup yang baru dibuat di folder sementara.
typedef CreatedBackup = ({
  String path,
  String fileName,
  BackupManifest manifest,

  /// Dikunci kata sandi (F1-19c).
  bool locked,
});

/// Backup & pulihkan data perangkat (F1-19). Semua aksi butuh
/// `backup:manage`.
abstract class BackupRepository {
  Future<Result<BackupOverview>> load();

  /// Membuat berkas backup di folder sementara; dengan [password] isinya
  /// dikunci (F1-19c).
  Future<Result<CreatedBackup>> createBackup({String? password});

  /// Mencatat waktu backup terakhir setelah berkas disimpan/dibagikan.
  Future<Result<DateTime>> recordBackup();

  /// Waktu backup terakhir di perangkat ini (tanpa cek izin; untuk
  /// pengingat Beranda).
  Future<DateTime?> lastBackupAt();

  /// Memeriksa berkas backup tanpa mengubah data. Backup terkunci tanpa
  /// [password] → `BackupLocked`; salah → `BackupWrongPassword`.
  Future<Result<BackupManifest>> inspect(String path, {String? password});

  /// Menyiapkan backup untuk dipasang saat aplikasi dimuat ulang.
  Future<Result<BackupManifest>> stageRestore(
    String path, {
    String? password,
  });

  /// [inspect] dari onboarding (F1-19b): tanpa staf, hanya bila toko belum
  /// dibuat di perangkat ini (selain itu `StoreAlreadySetUp`).
  Future<Result<BackupManifest>> inspectForSetup(
    String path, {
    String? password,
  });

  /// [stageRestore] dari onboarding (F1-19b), aturan sama dengan
  /// [inspectForSetup].
  Future<Result<BackupManifest>> stageRestoreForSetup(
    String path, {
    String? password,
  });
}

/// Toko sudah dibuat di perangkat ini: pulihkan lewat Pengaturan
/// (`backup:manage`), bukan dari onboarding.
class StoreAlreadySetUp implements Exception {
  const StoreAlreadySetUp();

  @override
  String toString() => 'StoreAlreadySetUp';
}

/// Pengingat backup muncul bila backup terakhir lebih lama dari ini.
const backupReminderAge = Duration(days: 7);

/// Apakah pemilik perlu diingatkan untuk backup.
bool backupOverdue(DateTime? lastBackupAt, DateTime now) =>
    lastBackupAt == null || now.difference(lastBackupAt) > backupReminderAge;
