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
typedef BackupOverview = ({
  BackupStats stats,
  DateTime? lastBackupAt,

  /// Zona waktu cabang untuk tanggal kalender (F1-19e).
  String? timezone,
});

/// Berkas backup yang baru dibuat di folder sementara.
typedef CreatedBackup = ({
  String path,
  String fileName,
  BackupManifest manifest,

  /// Dikunci kata sandi (F1-19c).
  bool locked,
});

/// Status backup otomatis di perangkat ini (F1-19d, F1-19e).
typedef AutoBackupState = ({
  /// Sakelar *Backup otomatis* (bawaan menyala).
  bool enabled,

  /// Backup otomatis terakhir yang berhasil.
  DateTime? lastAt,

  /// Percobaan terakhir gagal (dicoba lagi pada pemeriksaan berikutnya).
  bool failed,

  /// Jarak antar backup otomatis dalam jam (F1-19e).
  int everyHours,

  /// Jumlah berkas yang disimpan di folder *Otomatis* (F1-19e).
  int keep,
});

/// Pilihan jarak backup otomatis (jam, F1-19e).
const autoBackupEveryChoices = [6, 12, 24];

/// Jarak bawaan antar backup otomatis (jam).
const autoBackupDefaultEvery = 24;

/// Pilihan jumlah berkas backup otomatis yang disimpan (F1-19e).
const autoBackupKeepChoices = [3, 7, 14, 30];

/// Jumlah bawaan berkas backup otomatis yang disimpan.
const autoBackupKeep = 7;

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

  /// Jarak backup otomatis; [hours] salah satu [autoBackupEveryChoices]
  /// (selain itu [AutoBackupChoiceInvalid]).
  Future<Result<void>> setAutoBackupEvery(int hours);

  /// Jumlah berkas yang disimpan; [count] salah satu
  /// [autoBackupKeepChoices] (selain itu [AutoBackupChoiceInvalid]).
  Future<Result<void>> setAutoBackupKeep(int count);

  /// Membuat backup otomatis ke [folder] (tanpa staf; toko harus siap),
  /// lalu menyisakan berkas terbaru sebanyak [AutoBackupState.keep].
  /// Mengembalikan lokasi berkas.
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

/// Nilai jarak / jumlah simpanan backup otomatis bukan salah satu
/// pilihan (F1-19e).
class AutoBackupChoiceInvalid implements Exception {
  const AutoBackupChoiceInvalid(this.value);

  final int value;

  @override
  String toString() => 'AutoBackupChoiceInvalid($value)';
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
