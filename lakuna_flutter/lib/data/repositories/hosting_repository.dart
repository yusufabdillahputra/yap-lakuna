import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart'
    show PairingOutlet, SyncServerStatus, UuidValue;
import 'package:lakuna_data/lakuna_data.dart'
    show HostingState, UploadGroupProgress;

import '../../utils/result.dart';

export 'package:lakuna_client/lakuna_client.dart'
    show
        ActivationException,
        ActivationFailure,
        PairingOutlet,
        SyncServerStatus;
export 'package:lakuna_data/lakuna_data.dart'
    show
        HostingAlreadyActive,
        HostingAppTooOld,
        HostingJoinIncomplete,
        HostingNotActive,
        HostingNotPermitted,
        HostingServerTooOld,
        HostingState,
        SyncOfflineException,
        UploadGroup,
        UploadGroupProgress;

/// Keadaan chip status di bilah atas (F2-01, *Desain UI*).
enum SyncChipKind {
  /// Versi hosting belum aktif: *Offline · data di perangkat ini*.
  local,

  /// *Tersinkron · 14.32*.
  synced,

  /// *Menyinkronkan… (120)*.
  syncing,

  /// *Menunggu jaringan (35)*.
  waiting,

  /// *Sync dijeda (35)*.
  paused,

  /// *Perlu perhatian*: galat atau konflik.
  attention,
}

/// Ringkasan untuk chip status dan kartu *Versi hosting*.
@immutable
class SyncStatus {
  const SyncStatus({
    required this.kind,
    this.pending = 0,
    this.conflicts = 0,
    this.lastSyncAt,
    this.error,
  });

  static const local = SyncStatus(kind: SyncChipKind.local);

  final SyncChipKind kind;
  final int pending;
  final int conflicts;
  final DateTime? lastSyncAt;

  /// Kode galat terakhir (`clock`, `invalidToken`, `network`, `local`, ...).
  final String? error;

  @override
  bool operator ==(Object other) =>
      other is SyncStatus &&
      other.kind == kind &&
      other.pending == pending &&
      other.conflicts == conflicts &&
      other.lastSyncAt == lastSyncAt &&
      other.error == error;

  @override
  int get hashCode => Object.hash(kind, pending, conflicts, lastSyncAt, error);
}

/// Isian kode pasang yang ditampilkan di perangkat lama.
typedef PairingCodeShare = ({
  String code,

  /// `<alamat>#<kode>` untuk disalin ke perangkat baru.
  String shareText,
  DateTime expiresAt,
});

/// Versi hosting (F2-01): aktivasi perangkat pertama, kode pasang, gabung,
/// dan status sync. Semua aksi pengelolaan butuh `sync:manage`.
abstract class HostingRepository extends ChangeNotifier {
  /// Status terakhir untuk chip; [SyncStatus.local] bila belum aktif.
  SyncStatus get status;

  /// Alamat `LAKUNA_HOSTING_URL` (pilihan *Server Lakuna*), `null` bila
  /// build ini tidak membawanya.
  String? get lakunaServerUrl;

  Future<Result<HostingState>> load();

  /// Memeriksa server (`sync.status`); alamat tidak sah → [ArgumentError].
  Future<Result<SyncServerStatus>> checkServer(String serverUrl);

  /// Login akun pemilik di server (langkah 2).
  Future<Result<void>> login(
    String serverUrl, {
    required String email,
    required String password,
  });

  /// Daftar akun pemilik baru: kirim kode verifikasi ke [email].
  Future<Result<UuidValue>> startRegistration(String serverUrl, String email);

  /// Kode verifikasi email → token pendaftaran.
  Future<Result<String>> verifyRegistration(
    String serverUrl, {
    required UuidValue requestId,
    required String code,
  });

  /// Menyelesaikan pendaftaran dengan kata sandi; akun langsung login.
  Future<Result<void>> finishRegistration(
    String serverUrl, {
    required String registrationToken,
    required String password,
  });

  /// Aktivasi perangkat pertama dengan akun yang sudah login (langkah 3),
  /// lalu sync otomatis menyala.
  Future<Result<void>> activate(
    String serverUrl, {
    required String activationCode,
  });

  /// Progres unggah data awal per kelompok.
  Future<Result<List<UploadGroupProgress>>> uploadProgress();

  Future<Result<void>> setPaused(bool paused);

  /// *Sync sekarang*.
  void syncNow();

  Future<Result<PairingCodeShare>> createPairingCode();

  // --- Gabung (perangkat baru) -------------------------------------------

  /// Cabang yang bisa dipilih untuk [code] di [serverUrl].
  Future<Result<List<PairingOutlet>>> pairingOutlets(
    String serverUrl,
    String code,
  );

  /// Jumlah penjualan di database lokal (peringatan sebelum gabung).
  Future<Result<int>> localSales();

  /// Backup data lama, pasang di server, tarik data toko, lalu siap
  /// dipasang saat aplikasi dimuat ulang.
  Future<Result<void>> join(
    String serverUrl, {
    required String code,
    required UuidValue outletId,
    required String deviceCode,
    required String deviceName,
  });
}

/// Alamat server tidak sah (https wajib, kecuali `localhost` untuk uji).
class InvalidServerUrl implements Exception {
  const InvalidServerUrl();

  @override
  String toString() => 'InvalidServerUrl';
}
