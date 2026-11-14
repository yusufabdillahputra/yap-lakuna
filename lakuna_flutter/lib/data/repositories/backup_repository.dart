import 'dart:io';

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

/// Status backup otomatis harian di perangkat ini (F1-19d).
typedef AutoBackupState = ({
  /// Sakelar *Backup otomatis harian* (bawaan menyala).
  bool enabled,

  /// Backup otomatis terakhir yang berhasil.
  DateTime? lastAt,

  /// Percobaan terakhir gagal (dicoba lagi pada pemeriksaan berikutnya).
  bool failed,
});

/// Berapa berkas backup otomatis yang disimpan di folder *Otomatis*.
const autoBackupKeep = 7;

/// Jarak minimum antar backup otomatis.
const autoBackupInterval = Duration(hours: 24);

/// Backup & pulihkan data perangkat (F1-19). Semua aksi butuh
/// `backup:manage`, kecuali backup otomatis yang dijalankan sistem.
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

  /// Status backup otomatis (F1-19d; tanpa cek izin).
  Future<AutoBackupState> autoBackup();

  /// Menyalakan/mematikan backup otomatis di perangkat ini.
  Future<Result<void>> setAutoBackup(bool enabled);

  /// Membuat backup otomatis ke [folder] (tanpa staf; toko harus siap),
  /// lalu menyisakan [autoBackupKeep] berkas terbaru. Mengembalikan lokasi
  /// berkas.
  Future<Result<String>> runAutoBackup(Directory folder);

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

/// Backup otomatis gagal karena galat yang bukan [Exception] (F1-19d).
class AutoBackupFailed implements Exception {
  const AutoBackupFailed(this.message);

  final String message;

  @override
  String toString() => 'AutoBackupFailed: $message';
}

/// Pengingat backup muncul bila backup terakhir lebih lama dari ini.
const backupReminderAge = Duration(days: 7);

/// Apakah pemilik perlu diingatkan untuk backup.
bool backupOverdue(DateTime? lastBackupAt, DateTime now) =>
    lastBackupAt == null || now.difference(lastBackupAt) > backupReminderAge;
