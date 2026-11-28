import 'package:lakuna_client/lakuna_client.dart';

/// Jalur ke server sync versi hosting (F2-01). Implementasi nyata memanggil
/// endpoint `sync` dengan token perangkat; tes memakai versi palsu.
abstract interface class SyncTransport {
  /// Mengirim [entries] (urut `id` outbox). Melempar bila jaringan gagal.
  Future<SyncPushReply> push(List<SyncPushEntry> entries);

  /// Perubahan tenant dengan `seq > afterSeq`.
  Future<SyncPullPage> pull(int afterSeq);

  /// Versi server dan apakah token masih dikenal.
  Future<SyncServerStatus> status();

  /// Perangkat kasir tenant dan konflik terbuka (dashboard F2-02 tahap 3).
  Future<TenantStatus> tenantStatus();
}
