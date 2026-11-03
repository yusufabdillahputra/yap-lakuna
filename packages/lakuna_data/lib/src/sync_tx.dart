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

/// Dilempar bila kolom sync sebuah baris tidak sesuai dengan [SyncStamp]
/// yang dipakai untuk menulisnya. Baris dan outbox tidak ditulis.
class SyncStampMismatch extends StateError {
  SyncStampMismatch(String table, String column, Object? expected, Object? got)
    : super(
        'Kolom sync $table.$column harus "$expected" dari stempel, '
        'tetapi berisi "$got".',
      );
}

/// Konteks satu transaksi tulis. Setiap [insert]/[update] juga menambah satu
/// entri `sync_outbox` di transaksi yang sama, sehingga tidak ada perubahan
/// yang terlewat saat sync.
class SyncTx {
  SyncTx({
    required this.session,
    required this.transaction,
    required this.deviceId,
    required this._clock,
    this.actor,
  });

  final DatabaseSession session;
  final Transaction transaction;
  final UuidValue deviceId;
  final UuidValue? actor;
  final DateTime Function() _clock;

  /// Membuat stempel baru: HLC berikutnya dan waktu sekarang (UTC).
  Future<SyncStamp> stamp() async {
    final now = _clock().toUtc();
    final last =
        Hlc.tryParse(
          await readSyncState(
                session,
                SyncStateKey.lastHlc,
                transaction: transaction,
              ) ??
              '',
        ) ??
        Hlc(0, 0, deviceId.uuid);
    final next = Hlc(
      last.millis,
      last.counter,
      deviceId.uuid,
    ).tick(now.millisecondsSinceEpoch);
    await writeSyncState(
      session,
      SyncStateKey.lastHlc,
      next.toString(),
      transaction: transaction,
    );
    return SyncStamp(hlc: next, deviceId: deviceId, now: now, actor: actor);
  }

  /// Menyisipkan [row] lalu mencatatnya di outbox dengan HLC dari [stamp].
  ///
  /// [row] wajib membawa `hlc` dan `originDeviceId` dari [stamp], serta
  /// `createdBy`/`updatedBy` = aktor bila transaksi punya aktor. Bila tidak,
  /// [SyncStampMismatch] dilempar sebelum apa pun ditulis.
  Future<T> insert<T extends TableRow<UuidValue?>>(
    T row,
    SyncStamp stamp,
  ) async {
    _check(row, stamp, const ['createdBy', 'updatedBy']);
    final saved = await session.db.insertRow<T>(row, transaction: transaction);
    await _record(saved, stamp, SyncOp.upsert);
    return saved;
  }

  /// Memperbarui [row] lalu mencatatnya di outbox. Pemanggil mengisi kolom
  /// sync (`version` + 1, `updatedAt`, `hlc`, `originDeviceId`,
  /// `updatedBy`) dari [stamp]; `hlc`, `originDeviceId`, dan `updatedBy`
  /// diperiksa seperti pada [insert].
  Future<T> update<T extends TableRow<UuidValue?>>(
    T row,
    SyncStamp stamp,
  ) async {
    _check(row, stamp, const ['updatedBy']);
    final saved = await session.db.updateRow<T>(row, transaction: transaction);
    await _record(saved, stamp, SyncOp.upsert);
    return saved;
  }

  void _check(
    TableRow<UuidValue?> row,
    SyncStamp stamp,
    List<String> actorColumns,
  ) {
    final json = row.toJson();
    final table = row.table.tableName;
    void expectValue(String column, Object? expected) {
      final got = json[column];
      if (got != expected) {
        throw SyncStampMismatch(table, column, expected, got);
      }
    }

    expectValue('hlc', stamp.hlc.toString());
    expectValue('originDeviceId', stamp.deviceId.toJson());
    final actor = stamp.actor;
    if (actor != null) {
      for (final column in actorColumns) {
        expectValue(column, actor.toJson());
      }
    }
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
