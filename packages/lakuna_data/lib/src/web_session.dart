/// Perangkat web versi hosting (F2-02 aturan 2, 6, 6a): database sesi
/// per perangkat web yang diisi langsung oleh pull, tanpa staging.
library;

import 'package:lakuna_client/lakuna_client.dart';

import 'hosting.dart' show HostingJoinIncomplete;
import 'platform/media_blobs.dart';
import 'platform/token_vault.dart';
import 'store.dart';
import 'store_setup.dart';
import 'sync/sync_engine.dart';
import 'sync/sync_transport.dart';
import 'sync_state.dart';

/// Nama database sesi untuk perangkat web [deviceId].
String webDatabaseName(UuidValue deviceId) => 'lakuna-${deviceId.uuid}.sqlite';

/// Menyiapkan database sesi web di [databasePath] untuk perangkat
/// [deviceId] lalu menarik semua data toko. Database yang sudah memuat
/// [deviceToken] (pull pertama terputus) dilanjutkan dari kursornya.
/// Melempar [SyncOfflineException] bila server tak terjangkau dan
/// [HostingJoinIncomplete] bila data toko belum lengkap. Database ditutup
/// sebelum kembali; aplikasi membukanya lagi saat dimulai ulang.
Future<void> joinHostingWeb({
  required String databasePath,
  required UuidValue deviceId,
  required String deviceToken,
  required String serverUrl,
  required SyncTransport transport,
  PullProgress? onPull,
  DateTime Function()? clock,
}) async {
  MediaBlobs media() => MemoryMediaBlobs();
  var store = await LakunaStore.open(
    databasePath,
    clock: clock,
    media: media(),
  );
  try {
    final vault = StateTokenVault(store);
    if (await vault.readToken() != deviceToken) {
      await store.session.db.transaction((tx) async {
        for (final (key, value) in [
          (SyncStateKey.deviceId, deviceId.uuid),
          (SyncStateKey.initialUpload, 'done'),
          (SyncStateKey.initialUploadAcked, '1'),
          (SyncStateKey.serverUrl, serverUrl),
          (SyncStateKey.webDeviceToken, deviceToken),
        ]) {
          await writeSyncState(store.session, key, value, transaction: tx);
        }
      });
      // ID perangkat dibaca sekali saat database dibuka.
      await store.close();
      store = await LakunaStore.open(
        databasePath,
        clock: clock,
        media: media(),
      );
    }
    final cycle = await SyncEngine(store, transport).runCycle(onPull: onPull);
    if (cycle.outcome == SyncCycleOutcome.offline) {
      throw const SyncOfflineException();
    }
    if (await loadStoreContext(store) == null) {
      throw const HostingJoinIncomplete();
    }
  } finally {
    await store.close();
  }
}
