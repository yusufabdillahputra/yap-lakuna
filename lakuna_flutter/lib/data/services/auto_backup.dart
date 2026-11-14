import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../utils/result.dart';
import '../repositories/backup_repository.dart';
import 'backup_files.dart';

/// Folder backup otomatis desktop: `Dokumen/Lakuna/Backup/Otomatis`.
Future<Directory> autoBackupDirectory() async =>
    Directory(p.join((await backupDirectory()).path, 'Otomatis'));

/// Apakah backup otomatis didukung di platform ini (desktop saja, F1-19d).
bool get autoBackupSupported =>
    Platform.isLinux || Platform.isWindows || Platform.isMacOS;

/// Menjalankan backup otomatis harian (F1-19d): pemeriksaan pertama
/// [firstCheck] setelah [start], lalu setiap [period]; backup dibuat bila
/// sakelar menyala dan backup otomatis terakhir ≥ [autoBackupInterval]
/// lalu (atau belum pernah).
class AutoBackupScheduler {
  AutoBackupScheduler({
    required this._repository,
    required this._folder,
    DateTime Function()? clock,
    this.firstCheck = const Duration(minutes: 2),
    this.period = const Duration(hours: 1),
  }) : _clock = clock ?? DateTime.now;

  final BackupRepository _repository;
  final Future<Directory> Function() _folder;
  final DateTime Function() _clock;
  final Duration firstCheck;
  final Duration period;

  Timer? _first;
  Timer? _periodic;
  Future<bool>? _inFlight;

  void start() {
    _cancelTimers();
    _first = Timer(firstCheck, () {
      unawaited(runIfDue());
      _periodic = Timer.periodic(period, (_) => unawaited(runIfDue()));
    });
  }

  void _cancelTimers() {
    _first?.cancel();
    _periodic?.cancel();
    _first = null;
    _periodic = null;
  }

  /// Menghentikan jadwal dan menunggu backup yang sedang berjalan agar
  /// database tidak ditutup di tengah penyalinan.
  Future<void> dispose() async {
    _cancelTimers();
    await _inFlight;
  }

  /// Membuat backup bila jatuh tempo; `true` bila backup berhasil dibuat.
  /// Pemeriksaan yang tumpang tindih dilewati.
  Future<bool> runIfDue() {
    if (_inFlight != null) return Future.value(false);
    final run = _run();
    _inFlight = run;
    return run.whenComplete(() => _inFlight = null);
  }

  Future<bool> _run() async {
    try {
      final state = await _repository.autoBackup();
      if (!state.enabled) return false;
      final last = state.lastAt;
      final now = _clock().toUtc();
      // Waktu terakhir di masa depan (jam perangkat dimundurkan): anggap
      // jatuh tempo agar backup tidak berhenti berhari-hari.
      if (last != null &&
          !last.isAfter(now) &&
          now.difference(last) < autoBackupInterval) {
        return false;
      }
      final result = await _repository.runAutoBackup(await _folder());
      return result is Ok<String>;
      // Penjadwal latar tidak boleh menjatuhkan aplikasi karena galat apa pun.
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      return false;
    }
  }
}
