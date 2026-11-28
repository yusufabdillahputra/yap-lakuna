/// Menerapkan baris dari server (pull dan balasan `stale`/`merged`) ke
/// database perangkat tanpa outbox (F2-01 aturan 2, 5, 7b, 8b, 17).
library;

import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

import '../store.dart';
import '../sync_state.dart';
import 'sync_rows.dart';

/// Varian+lokasi yang stoknya perlu dihitung ulang.
typedef StockKey = ({UuidValue variantId, UuidValue locationId});

/// Hasil penerapan sekumpulan perubahan.
class IncomingResult {
  IncomingResult(this.failed, this.touchedStock);

  /// Perubahan yang gagal (mis. FK ke baris yang belum ada): diparkir.
  final List<SyncPullChange> failed;
  final Set<StockKey> touchedStock;
}

/// Menerapkan [changes] di [tx], masing-masing dalam savepoint. LWW per
/// baris dengan HLC; untuk dokumen final, status yang lebih kuat dari
/// server tetap diambil walau HLC lokal lebih baru (status tidak pernah
/// mundur). `last_hlc` perangkat dimajukan melewati HLC yang diterima.
Future<IncomingResult> applyIncoming(
  LakunaStore store,
  Transaction tx,
  List<SyncPullChange> changes,
) async {
  final failed = <SyncPullChange>[];
  final touched = <StockKey>{};
  final session = store.session;
  var clock =
      Hlc.tryParse(
        await readSyncState(session, SyncStateKey.lastHlc, transaction: tx) ??
            '',
      ) ??
      Hlc(0, 0, store.deviceId.uuid);
  final nowMillis = store.now().millisecondsSinceEpoch;
  for (final change in changes) {
    final type = syncRowType(change.tableName);
    if (type == null) continue;
    final savepoint = await tx.createSavepoint();
    try {
      final json = jsonDecode(change.payloadJson) as Map<String, dynamic>;
      final key = await applyServerRow(store, tx, type, json);
      if (key != null) touched.add(key);
      await savepoint.release();
      final h = Hlc.tryParse(change.hlc);
      if (h != null) clock = clock.receive(h, nowMillis);
    } on Object {
      await savepoint.rollback();
      failed.add(change);
    }
  }
  await writeSyncState(
    session,
    SyncStateKey.lastHlc,
    clock.toString(),
    transaction: tx,
  );
  return IncomingResult(failed, touched);
}

/// Menulis satu baris server [json] ke tabel [type] bila menang LWW.
/// Mengembalikan kunci stok bila barisnya pergerakan stok.
Future<StockKey?> applyServerRow(
  LakunaStore store,
  Transaction tx,
  SyncRowType type,
  Map<String, dynamic> json,
) async {
  final session = store.session;
  final incoming = type.fromJson(json);
  final local = await type.byId(session, tx, incoming.id!);
  final table = syncTableByName(type.tableName)!;
  if (local == null) {
    if (table.name == 'settings') await _dropSettingTwin(store, tx, json);
    await type.put(session, tx, incoming, exists: false);
  } else {
    final localJson = local.toJson() as Map<String, dynamic>;
    final localHlc = Hlc.parse(localJson['hlc'] as String);
    final incomingHlc = Hlc.parse(json['hlc'] as String);
    if (incomingHlc > localHlc) {
      await type.put(session, tx, incoming, exists: true);
    } else {
      final merged = _strongerStatus(table, localJson, json);
      if (merged == null) return null;
      await type.put(session, tx, type.fromJson(merged), exists: true);
    }
  }
  if (table.name != 'stock_movements') return null;
  return (
    variantId: UuidValue.fromString(json['variantId'] as String),
    locationId: UuidValue.fromString(json['stockLocationId'] as String),
  );
}

/// Baris lokal dengan status [local] ditambah bagian status [server] bila
/// status server lebih kuat (aturan 7b); `null` bila tidak ada yang
/// diubah.
Map<String, dynamic>? _strongerStatus(
  SyncTable table,
  Map<String, dynamic> local,
  Map<String, dynamic> server,
) {
  final rule = table.finalStatus;
  final ls = local['status'] as String?;
  final ss = server['status'] as String?;
  if (rule == null || ls == null || ss == null || ls == ss) return null;
  if (rule.mergeStatus(ls, ss) != ss) return null;
  return {
    ...local,
    for (final k in const ['status', 'voidedAt', 'voidedBy', 'voidReason'])
      if (server.containsKey(k)) k: server[k],
  };
}

/// Aturan 8b: baris `settings` lokal dengan kunci alami sama tetapi ID lain
/// dihapus, karena server memakai barisnya sendiri.
Future<void> _dropSettingTwin(
  LakunaStore store,
  Transaction tx,
  Map<String, dynamic> json,
) async {
  final twins = await Setting.db.find(
    store.session,
    where: (s) =>
        s.tenantId.equals(UuidValue.fromString(json['tenantId'] as String)) &
        s.scopeKey.equals(json['scopeKey'] as String) &
        s.key.equals(json['key'] as String),
    transaction: tx,
  );
  for (final t in twins) {
    if (t.id.uuid != json['id']) {
      await Setting.db.deleteRow(store.session, t, transaction: tx);
    }
  }
}
