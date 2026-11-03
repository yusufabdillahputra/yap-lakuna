import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;
import 'package:lakuna_domain/lakuna_domain.dart';

import 'sync_state.dart';

/// Nilai kolom sync untuk satu perubahan baris.
class SyncStamp {
  const SyncStamp({
    required this.hlc,
    required this.deviceId,
    required this.now,
    this.actor,
  });

  /// HLC baru (sudah lebih besar dari semua HLC sebelumnya di perangkat ini).
  final Hlc hlc;
  final UuidValue deviceId;
  final DateTime now;

  /// Staf yang melakukan perubahan, untuk `created_by`/`updated_by`.
  final UuidValue? actor;
}

/// Konteks satu transaksi tulis. Setiap [insert]/[update] juga menambah satu
/// entri `sync_outbox` di transaksi yang sama, sehingga tidak ada perubahan
/// yang terlewat saat sync.
class SyncTx {
  SyncTx({
    required this.session,
    required this.transaction,
    required this.deviceId,
    required DateTime Function() clock,
    this.actor,
  }) : _clock = clock;

  final DatabaseSession session;
  final Transaction transaction;
  final UuidValue deviceId;
  final UuidValue? actor;
  final DateTime Function() _clock;

  /// Membuat stempel baru: HLC berikutnya dan waktu sekarang (UTC).
  Future<SyncStamp> stamp() async {
    final now = _clock().toUtc();
    final last = Hlc.tryParse(
          await readSyncState(
                session,
                SyncStateKey.lastHlc,
                transaction: transaction,
              ) ??
              '',
        ) ??
        Hlc(0, 0, deviceId.uuid);
    final next = Hlc(last.millis, last.counter, deviceId.uuid)
        .tick(now.millisecondsSinceEpoch);
    await writeSyncState(
      session,
      SyncStateKey.lastHlc,
      next.toString(),
      transaction: transaction,
    );
    return SyncStamp(hlc: next, deviceId: deviceId, now: now, actor: actor);
  }

  /// Menyisipkan [row] lalu mencatatnya di outbox dengan HLC dari [stamp].
  Future<T> insert<T extends TableRow<UuidValue?>>(T row, SyncStamp stamp) async {
    final saved = await session.db.insertRow<T>(row, transaction: transaction);
    await _record(saved, stamp, SyncOp.upsert);
    return saved;
  }

  /// Memperbarui [row] lalu mencatatnya di outbox. Pemanggil mengisi kolom
  /// sync (`version`, `updated_at`, `hlc`, ...) dari [stamp].
  Future<T> update<T extends TableRow<UuidValue?>>(T row, SyncStamp stamp) async {
    final saved = await session.db.updateRow<T>(row, transaction: transaction);
    await _record(saved, stamp, SyncOp.upsert);
    return saved;
  }

  Future<void> _record(
    TableRow<UuidValue?> row,
    SyncStamp stamp,
    SyncOp op,
  ) async {
    await SyncOutboxEntry.db.insertRow(
      session,
      SyncOutboxEntry(
        entity: row.table.tableName,
        rowId: row.id!,
        op: op,
        payloadJson: jsonEncode(row.toJson()),
        hlc: stamp.hlc.toString(),
      ),
      transaction: transaction,
    );
  }
}
