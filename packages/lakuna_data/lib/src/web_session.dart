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

/// Kredensial perangkat web yang tersimpan di database sesinya.
typedef WebSessionCredentials = ({
  UuidValue deviceId,
  String deviceToken,
  String serverUrl,
});

/// Membaca kredensial perangkat web dari database sesi [databasePath];
/// `null` bila belum disiapkan [prepareWebSession]. Dipakai untuk
/// melanjutkan pull pertama setelah tab ditutup (Fokus review 2).
Future<WebSessionCredentials?> readWebSession(String databasePath) async {
  final store = await LakunaStore.open(databasePath, media: MemoryMediaBlobs());
  try {
    final id = await store.syncState(SyncStateKey.deviceId);
    final token = await StateTokenVault(store).readToken();
    final server = await store.syncState(SyncStateKey.serverUrl);
    if (id == null || token == null || server == null) return null;
    return (
      deviceId: UuidValue.fromString(id),
      deviceToken: token,
      serverUrl: server,
    );
  } finally {
    await store.close();
  }
}

/// Menyimpan kredensial perangkat web [deviceId] di database sesi
/// [databasePath] (dibuat kosong bila belum ada) tanpa menarik data.
/// Tidak mengubah apa pun bila token sudah sama.
Future<void> prepareWebSession({
  required String databasePath,
  required UuidValue deviceId,
  required String deviceToken,
  required String serverUrl,
  DateTime Function()? clock,
}) async {
  final store = await LakunaStore.open(
    databasePath,
    clock: clock,
    media: MemoryMediaBlobs(),
  );
  try {
    if (await StateTokenVault(store).readToken() == deviceToken) return;
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
  } finally {
    await store.close();
  }
}

/// Menyiapkan database sesi web di [databasePath] untuk perangkat
/// [deviceId] ([prepareWebSession]) lalu menarik semua data toko. Database
/// yang sudah memuat [deviceToken] (pull pertama terputus) dilanjutkan dari
/// kursornya. Melempar [SyncOfflineException] bila server tak terjangkau
/// dan [HostingJoinIncomplete] bila data toko belum lengkap. Database
/// ditutup sebelum kembali; aplikasi membukanya lagi saat dimulai ulang.
Future<void> joinHostingWeb({
  required String databasePath,
  required UuidValue deviceId,
  required String deviceToken,
  required String serverUrl,
  required SyncTransport transport,
  PullProgress? onPull,
  DateTime Function()? clock,
}) async {
  // ID perangkat dibaca sekali saat database dibuka, jadi kredensial
  // ditulis sebelum database dibuka untuk pull.
  await prepareWebSession(
    databasePath: databasePath,
    deviceId: deviceId,
    deviceToken: deviceToken,
    serverUrl: serverUrl,
    clock: clock,
  );
  final store = await LakunaStore.open(
    databasePath,
    clock: clock,
    media: MemoryMediaBlobs(),
  );
  try {
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
