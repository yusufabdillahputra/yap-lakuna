import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_client/migrations/migration_registry.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

import 'platform/media_blobs.dart';
import 'sync_state.dart';
import 'sync_tx.dart';

/// Database lokal Lakuna (SQLite di perangkat) beserta identitas perangkat.
class LakunaStore {
  LakunaStore._(
    this.session,
    this.deviceId,
    this._clock,
    this.path,
    this.media,
  );

  /// Sesi database sisi klien Serverpod.
  final ClientDatabaseSession session;

  /// ID perangkat ini (UUIDv7), dibuat sekali saat database pertama dibuka.
  final UuidValue deviceId;

  final DateTime Function() _clock;

  /// Waktu sekarang (UTC) menurut jam store.
  DateTime now() => _clock().toUtc();

  /// Lokasi file database.
  final String path;

  /// Isi berkas media (stiker QRIS, foto): folder `media` di samping
  /// database, atau cache memori di web (F2-02 aturan 8).
  final MediaBlobs media;

  /// Folder berkas media di samping database (hanya native).
  String get mediaDirectory => switch (media) {
    FileMediaBlobs(:final directory) => directory,
    _ => throw UnsupportedError('Media perangkat ini tidak berupa folder'),
  };

  /// Membuka (atau membuat) database di [path] dan menjalankan migrasi.
  static Future<LakunaStore> open(
    String path, {
    DateTime Function()? clock,
    bool isDebugMode = false,
    MediaBlobs? media,
  }) async {
    final session = await ClientDatabaseSession.open(
      path,
      Protocol(),
      clientMigrations: MigrationRegistry.migrations,
      isDebugMode: isDebugMode,
    );
    final deviceId = await session.db.transaction((tx) async {
      final existing = await readSyncState(
        session,
        SyncStateKey.deviceId,
        transaction: tx,
      );
      if (existing != null) return UuidValue.fromString(existing);
      final id = newId();
      await writeSyncState(session, SyncStateKey.deviceId, id, transaction: tx);
      return UuidValue.fromString(id);
    });
    return LakunaStore._(
      session,
      deviceId,
      clock ?? DateTime.now,
      path,
      media ?? defaultMediaBlobs(path),
    );
  }

  /// Dipanggil setelah setiap transaksi [write] berhasil (mis. penjadwal
  /// sync versi hosting, F2-01).
  void Function()? afterWrite;

  /// Mengambil berkas media yang belum ada di perangkat ini (versi hosting:
  /// unduh dari server, F2-01 aturan 20). `null` = gambar placeholder.
  Future<Uint8List?> Function(MediaFile media)? fetchMedia;

  /// Menjalankan [body] dalam satu transaksi tulis yang tercatat di outbox.
  Future<R> write<R>(
    Future<R> Function(SyncTx w) body, {
    UuidValue? actor,
  }) async {
    final result = await session.db.transaction(
      (tx) => body(
        SyncTx(
          session: session,
          transaction: tx,
          deviceId: deviceId,
          clock: _clock,
          actor: actor,
        ),
      ),
    );
    afterWrite?.call();
    return result;
  }

  Future<String?> syncState(SyncStateKey key) => readSyncState(session, key);

  Future<void> close() => session.close();
}
