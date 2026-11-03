import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_client/migrations/migration_registry.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

import 'sync_state.dart';
import 'sync_tx.dart';

/// Database lokal Lakuna (SQLite di perangkat) beserta identitas perangkat.
class LakunaStore {
  LakunaStore._(this.session, this.deviceId, this._clock);

  /// Sesi database sisi klien Serverpod.
  final ClientDatabaseSession session;

  /// ID perangkat ini (UUIDv7), dibuat sekali saat database pertama dibuka.
  final UuidValue deviceId;

  final DateTime Function() _clock;

  /// Membuka (atau membuat) database di [path] dan menjalankan migrasi.
  static Future<LakunaStore> open(
    String path, {
    DateTime Function()? clock,
    bool isDebugMode = false,
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
    return LakunaStore._(session, deviceId, clock ?? DateTime.now);
  }

  /// Menjalankan [body] dalam satu transaksi tulis yang tercatat di outbox.
  Future<R> write<R>(
    Future<R> Function(SyncTx w) body, {
    UuidValue? actor,
  }) {
    return session.db.transaction(
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
  }

  Future<String?> syncState(SyncStateKey key) => readSyncState(session, key);

  Future<void> close() => session.close();
}
