import 'package:lakuna_client/lakuna_client.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

/// Kunci tabel `sync_state`.
enum SyncStateKey {
  deviceId('device_id'),
  tenantId('tenant_id'),
  outletId('outlet_id'),
  lastHlc('last_hlc'),

  /// `last_seq` pull terakhir dari server (F2-01 aturan 2).
  pullCursor('pull_cursor'),

  /// Alamat server versi hosting (F2-01).
  serverUrl('server_url'),

  /// *Jeda sync* (`1`): siklus tidak memanggil server sampai dilanjutkan
  /// (aturan 16). Token perangkat tidak disimpan di database, lihat
  /// `HostingVault`.
  syncPaused('sync_paused'),

  /// Unggah data awal: `pending`/`restamp` (sedang dipadatkan) atau `done`
  /// (aturan 13, 15).
  initialUpload('initial_upload'),

  /// Jam stempel ulang pemadatan (aturan 13), terpisah dari `last_hlc` yang
  /// tetap dimajukan tulisan kasir selama pemadatan.
  restampHlc('restamp_hlc'),

  /// Unggah data awal sudah terkirim semua (`1`): progres per kelompok
  /// tidak ditampilkan lagi untuk perubahan sesudahnya (aturan 16).
  initialUploadAcked('initial_upload_acked'),

  /// ID `media_files` terakhir yang berkasnya sudah diunggah atau dilewati
  /// (aturan 19), urut ID.
  mediaUploadCursor('media_upload_cursor'),

  /// Posisi pemadatan: `<indeks tabel syncTables>:<ID terakhir>`.
  initialUploadCursor('initial_upload_cursor'),

  /// Waktu siklus sync terakhir yang berhasil (ISO UTC).
  lastSyncAt('last_sync_at'),

  /// Galat siklus sync terakhir (kosong bila berhasil).
  lastError('last_error'),

  /// Perubahan pull yang belum bisa diterapkan (JSON daftar), dicoba lagi
  /// setiap siklus (aturan 2).
  pullParked('pull_parked');

  const SyncStateKey(this.key);
  final String key;
}

Future<String?> readSyncState(
  DatabaseSession session,
  SyncStateKey key, {
  Transaction? transaction,
}) async {
  final row = await SyncStateEntry.db.findFirstRow(
    session,
    where: (t) => t.key.equals(key.key),
    transaction: transaction,
  );
  return row?.value;
}

Future<void> writeSyncState(
  DatabaseSession session,
  SyncStateKey key,
  String value, {
  Transaction? transaction,
}) async {
  final row = await SyncStateEntry.db.findFirstRow(
    session,
    where: (t) => t.key.equals(key.key),
    transaction: transaction,
  );
  if (row == null) {
    await SyncStateEntry.db.insertRow(
      session,
      SyncStateEntry(key: key.key, value: value),
      transaction: transaction,
    );
  } else {
    await SyncStateEntry.db.updateRow(
      session,
      row.copyWith(value: value),
      transaction: transaction,
    );
  }
}
