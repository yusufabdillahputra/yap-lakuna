/// Pemadatan outbox dan progres unggah data awal saat aktivasi versi
/// hosting (F2-01 aturan 13, 15, 16).
library;

import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

import '../store.dart';
import '../sync_state.dart';
import 'sync_rows.dart';

/// Jumlah baris per transaksi pemadatan.
const initialUploadChunk = 500;

/// Batas HLC di depan jam server (aturan 13).
const _maxClockAhead = Duration(minutes: 5);

/// Kelompok progres di layar 2.1.
enum UploadGroup { store, catalog, partners, sales, purchases, stock, media }

/// Kelompok progres tabel sync [table].
UploadGroup uploadGroupOf(String table) => switch (table) {
  'units' ||
  'categories' ||
  'modifier_groups' ||
  'modifiers' ||
  'products' ||
  'product_variants' ||
  'product_units' ||
  'price_tiers' ||
  'product_modifier_groups' => UploadGroup.catalog,
  'customer_groups' || 'customers' || 'suppliers' => UploadGroup.partners,
  'shifts' ||
  'cash_sessions' ||
  'cash_movements' ||
  'dining_areas' ||
  'dining_tables' ||
  'sales' ||
  'kitchen_tickets' ||
  'sale_items' ||
  'sale_item_modifiers' ||
  'payments' ||
  'sale_returns' ||
  'sale_return_items' ||
  'debt_payments' ||
  'debt_payment_allocations' => UploadGroup.sales,
  'purchases' ||
  'purchase_items' ||
  'purchase_invoice_pages' ||
  'purchase_returns' ||
  'purchase_return_items' ||
  'expense_categories' ||
  'expenses' => UploadGroup.purchases,
  'stock_adjustments' ||
  'stock_adjustment_items' ||
  'stock_movements' => UploadGroup.stock,
  'media_files' => UploadGroup.media,
  _ => UploadGroup.store,
};

/// Progres satu kelompok: entri `acked` / semua entri outbox kelompok itu.
typedef UploadGroupProgress = ({UploadGroup group, int acked, int total});

/// Mengganti outbox dengan satu entri snapshot per baris tabel sync, urut
/// dependensi (aturan 15). Bisa dilanjutkan: kursor disimpan di transaksi
/// yang sama dengan setiap potongan, jadi aplikasi yang ditutup di tengah
/// jalan tidak melewatkan atau menggandakan baris. Bila `last_hlc` lebih
/// dari 5 menit di depan [serverNow], baris dan snapshot distempel ulang
/// dengan HLC dari waktu server (aturan 13).
///
/// [afterChunk] dipanggil setelah setiap potongan selesai (untuk tes).
Future<void> prepareInitialUpload(
  LakunaStore store, {
  required DateTime serverNow,
  int chunkSize = initialUploadChunk,
  Future<void> Function()? afterChunk,
}) async {
  final session = store.session;
  final state = await store.syncState(SyncStateKey.initialUpload);
  if (state == 'done') return;
  if (state == null) await _start(store, serverNow);
  while (!await session.db.transaction(
    (tx) => _chunk(store, tx, serverNow, chunkSize),
  )) {
    await afterChunk?.call();
  }
}

Future<void> _start(
  LakunaStore store,
  DateTime serverNow,
) => store.session.db.transaction((tx) async {
  final session = store.session;
  await SyncOutboxEntry.db.deleteWhere(
    session,
    where: (e) => e.id.notEquals(null),
    transaction: tx,
  );
  final last = Hlc.tryParse(
    await readSyncState(session, SyncStateKey.lastHlc, transaction: tx) ?? '',
  );
  final limit = serverNow.add(_maxClockAhead).millisecondsSinceEpoch;
  final restamp = last != null && last.millis > limit;
  if (restamp) {
    await writeSyncState(
      session,
      SyncStateKey.lastHlc,
      Hlc(serverNow.millisecondsSinceEpoch, 0, store.deviceId.uuid).toString(),
      transaction: tx,
    );
  }
  await writeSyncState(
    session,
    SyncStateKey.initialUpload,
    restamp ? 'restamp' : 'pending',
    transaction: tx,
  );
  await writeSyncState(
    session,
    SyncStateKey.initialUploadCursor,
    '0:',
    transaction: tx,
  );
});

/// Satu potongan pemadatan; `true` bila semua tabel selesai.
Future<bool> _chunk(
  LakunaStore store,
  Transaction tx,
  DateTime serverNow,
  int chunkSize,
) async {
  final session = store.session;
  final cursor =
      await readSyncState(
        session,
        SyncStateKey.initialUploadCursor,
        transaction: tx,
      ) ??
      '0:';
  final sep = cursor.indexOf(':');
  final index = int.parse(cursor.substring(0, sep));
  final lastId = cursor.substring(sep + 1);
  if (index >= syncTables.length) {
    await writeSyncState(
      session,
      SyncStateKey.initialUpload,
      'done',
      transaction: tx,
    );
    return true;
  }
  final table = syncTables[index];
  final type = syncRowType(table.name)!;
  final selfParent = table.selfParentColumn;
  final List<TableRow<UuidValue?>> rows;
  if (selfParent != null) {
    rows = _parentsFirst(await type.after(session, tx), selfParent);
  } else {
    rows = await type.after(
      session,
      tx,
      after: lastId.isEmpty ? null : UuidValue.fromString(lastId),
      limit: chunkSize,
    );
  }
  final restamp =
      await readSyncState(
        session,
        SyncStateKey.initialUpload,
        transaction: tx,
      ) ==
      'restamp';
  Hlc? clock = restamp
      ? Hlc.parse(
          (await readSyncState(
            session,
            SyncStateKey.lastHlc,
            transaction: tx,
          ))!,
        )
      : null;
  for (var row in rows) {
    if (clock != null) {
      clock = clock.tick(serverNow.millisecondsSinceEpoch);
      row = await type.put(
        session,
        tx,
        type.fromJson({
          ...(row.toJson() as Map<String, dynamic>),
          'hlc': clock.toString(),
        }),
        exists: true,
      );
    }
    final json = row.toJson() as Map<String, dynamic>;
    await SyncOutboxEntry.db.insertRow(
      session,
      SyncOutboxEntry(
        entity: table.name,
        rowId: row.id!,
        op: SyncOp.upsert,
        payloadJson: jsonEncode(json),
        hlc: json['hlc'] as String,
      ),
      transaction: tx,
    );
  }
  if (clock != null) {
    await writeSyncState(
      session,
      SyncStateKey.lastHlc,
      clock.toString(),
      transaction: tx,
    );
  }
  final next = selfParent != null || rows.length < chunkSize
      ? '${index + 1}:'
      : '$index:${rows.last.id!.uuid}';
  await writeSyncState(
    session,
    SyncStateKey.initialUploadCursor,
    next,
    transaction: tx,
  );
  return false;
}

/// Urutan induk sebelum anak untuk tabel yang merujuk dirinya sendiri.
List<TableRow<UuidValue?>> _parentsFirst(
  List<TableRow<UuidValue?>> rows,
  String parentKey,
) {
  final byId = {for (final r in rows) r.id!.uuid: r};
  final out = <TableRow<UuidValue?>>[];
  final seen = <String>{};
  void visit(TableRow<UuidValue?> r, Set<String> path) {
    final id = r.id!.uuid;
    if (seen.contains(id) || !path.add(id)) return;
    final parent = byId[(r.toJson() as Map<String, dynamic>)[parentKey]];
    if (parent != null) visit(parent, path);
    seen.add(id);
    out.add(r);
  }

  for (final r in rows) {
    visit(r, <String>{});
  }
  return out;
}

/// Progres unggah per kelompok dari isi outbox (aturan 16).
Future<List<UploadGroupProgress>> initialUploadProgress(
  LakunaStore store,
) async {
  final rows = await store.session.db.unsafeQuery(
    'SELECT table_name, status, COUNT(*) FROM sync_outbox '
    'GROUP BY table_name, status',
  );
  final acked = <UploadGroup, int>{};
  final total = <UploadGroup, int>{};
  for (final r in rows) {
    final group = uploadGroupOf(r[0]! as String);
    final count = r[2]! as int;
    total[group] = (total[group] ?? 0) + count;
    if (r[1] == OutboxStatus.acked.name) {
      acked[group] = (acked[group] ?? 0) + count;
    }
  }
  return [
    for (final g in UploadGroup.values)
      (group: g, acked: acked[g] ?? 0, total: total[g] ?? 0),
  ];
}
