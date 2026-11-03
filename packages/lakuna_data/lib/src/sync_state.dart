import 'package:lakuna_client/lakuna_client.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

/// Kunci tabel `sync_state`.
enum SyncStateKey {
  deviceId('device_id'),
  tenantId('tenant_id'),
  outletId('outlet_id'),
  lastHlc('last_hlc'),
  pullCursor('pull_cursor');

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
