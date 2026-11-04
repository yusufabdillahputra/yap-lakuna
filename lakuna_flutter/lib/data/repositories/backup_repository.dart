import 'package:lakuna_data/lakuna_data.dart' show BackupManifest, BackupStats;

import '../../utils/result.dart';

export 'package:lakuna_data/lakuna_data.dart'
    show BackupInvalid, BackupManifest, BackupStats, BackupTooNew;

/// Ringkasan layar *Data & backup* (1.13).
typedef BackupOverview = ({BackupStats stats, DateTime? lastBackupAt});

/// Berkas backup yang baru dibuat di folder sementara.
typedef CreatedBackup = ({
  String path,
  String fileName,
  BackupManifest manifest,
});

/// Backup & pulihkan data perangkat (F1-19). Semua aksi butuh
/// `backup:manage`.
abstract class BackupRepository {
  Future<Result<BackupOverview>> load();

  /// Membuat berkas backup di folder sementara.
  Future<Result<CreatedBackup>> createBackup();

  /// Mencatat waktu backup terakhir setelah berkas disimpan/dibagikan.
  Future<Result<DateTime>> recordBackup();

  /// Waktu backup terakhir di perangkat ini (tanpa cek izin; untuk
  /// pengingat Beranda).
  Future<DateTime?> lastBackupAt();

  /// Memeriksa berkas backup tanpa mengubah data.
  Future<Result<BackupManifest>> inspect(String path);

  /// Menyiapkan backup untuk dipasang saat aplikasi dimuat ulang.
  Future<Result<BackupManifest>> stageRestore(String path);
}

/// Pengingat backup muncul bila backup terakhir lebih lama dari ini.
const backupReminderAge = Duration(days: 7);

/// Apakah pemilik perlu diingatkan untuk backup.
bool backupOverdue(DateTime? lastBackupAt, DateTime now) =>
    lastBackupAt == null || now.difference(lastBackupAt) > backupReminderAge;
