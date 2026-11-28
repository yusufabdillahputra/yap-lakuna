/// Penyimpanan token perangkat versi hosting (F2-01 aturan 11, F2-02
/// aturan 10).
library;

import '../hosting.dart' show HostingVault;
import '../store.dart';
import '../sync_state.dart';
import 'media_blobs.dart' show isWebPlatform;

abstract interface class TokenVault {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> deleteToken();
}

/// Token di `sync_state` database (web): tidak ada berkas di browser, dan
/// database sesi web dihapus bersama tokennya.
class StateTokenVault implements TokenVault {
  StateTokenVault(this.store);

  final LakunaStore store;

  @override
  Future<String?> readToken() async {
    final token = await store.syncState(SyncStateKey.webDeviceToken);
    return token == null || token.isEmpty ? null : token;
  }

  @override
  Future<void> writeToken(String token) =>
      writeSyncState(store.session, SyncStateKey.webDeviceToken, token);

  @override
  Future<void> deleteToken() =>
      writeSyncState(store.session, SyncStateKey.webDeviceToken, '');
}

/// Brankas token untuk [store]: berkas di samping database (native) atau
/// `sync_state` (web).
TokenVault tokenVaultOf(LakunaStore store) =>
    isWebPlatform ? StateTokenVault(store) : HostingVault.of(store);
