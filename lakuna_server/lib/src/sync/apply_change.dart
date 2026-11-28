/// Penerap satu entri `sync.push` di server (F2-01 aturan 1, 5–8).
///
/// Baris ditulis generik lewat `jsonb_populate_record`, jadi penerap ini
/// tidak perlu tahu kelas model setiap tabel: daftar tabel dan aturan
/// final ada di `syncTables` (lakuna_domain), nama dan tipe kolom dari
/// `TableDefinition` Serverpod. Kunci payload = nama field Dart, yang
/// selalu camelCase dari nama kolom (dijaga tes `sync_columns_test`).
library;

import 'dart:convert';

import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/protocol.dart' show ColumnType, TableDefinition;

import '../generated/protocol.dart';

/// Tenant dan perangkat pemilik token yang mengirim push.
class DeviceAuth {
  const DeviceAuth({required this.tenantId, required this.deviceId});

  final UuidValue tenantId;
  final UuidValue deviceId;
}

/// Node HLC untuk baris hasil gabung server (aturan 7b/8b).
const serverHlcNode = 'server';

/// Batas HLC di depan jam server (aturan 13).
const maxClockAhead = Duration(minutes: 5);

final Map<String, TableDefinition> _definitions = {
  for (final t in Protocol().getTargetTableDefinitions())
    if (t.module == 'lakuna') t.name: t,
};

/// Nama field Dart untuk kolom [column] (`tenant_id` → `tenantId`).
String dartNameOf(String column) {
  final parts = column.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

/// Menerapkan [entry] dari perangkat [auth] di dalam [tx]. Setiap entri
/// dijalankan di savepoint sendiri, jadi galat satu entri tidak membatalkan
/// entri lain di batch yang sama.
Future<SyncPushResult> applyPushEntry(
  Session session,
  Transaction tx,
  DeviceAuth auth,
  SyncPushEntry entry, {
  required DateTime serverNow,
}) async {
  SyncPushResult reject(SyncRejectReason reason) => SyncPushResult(
    rowId: entry.rowId,
    hlc: entry.hlc,
    kind: SyncResultKind.rejected,
    reason: reason,
  );

  final table = syncTableByName(entry.tableName);
  final def = _definitions[entry.tableName];
  if (table == null || def == null || entry.op != SyncOp.upsert) {
    return reject(SyncRejectReason.table);
  }
  final Map<String, Object?> payload;
  try {
    final decoded = jsonDecode(entry.payloadJson);
    if (decoded is! Map<String, Object?>) return reject(SyncRejectReason.table);
    payload = decoded;
  } on FormatException {
    return reject(SyncRejectReason.table);
  }
  if (payload['id'] != entry.rowId.uuid) return reject(SyncRejectReason.table);
  final rowTenant = table.name == 'tenants'
      ? payload['id']
      : payload['tenantId'];
  if (rowTenant != auth.tenantId.uuid) return reject(SyncRejectReason.tenant);
  if (payload['originDeviceId'] != auth.deviceId.uuid) {
    return reject(SyncRejectReason.device);
  }
  final hlc = Hlc.tryParse(entry.hlc);
  if (hlc == null ||
      payload['hlc'] != entry.hlc ||
      hlc.millis > serverNow.add(maxClockAhead).millisecondsSinceEpoch) {
    return reject(SyncRejectReason.clock);
  }

  final applier = _Applier(session, tx, auth, table, def, entry, serverNow);
  if (await applier.alreadyApplied()) {
    return SyncPushResult(
      rowId: entry.rowId,
      hlc: entry.hlc,
      kind: SyncResultKind.applied,
    );
  }
  final incoming = _Row.fromPayload(def, payload);
  final savepoint = await tx.createSavepoint();
  try {
    final result = await applier.apply(incoming, hlc);
    await savepoint.release();
    return result;
  } on DatabaseQueryException catch (e) {
    await savepoint.rollback();
    switch (e.code) {
      case '23503':
        return reject(SyncRejectReason.dependency);
      case '23505':
        if (table.name == 'settings') {
          final merged = await applier.mergeSetting(incoming, hlc);
          if (merged != null) return merged;
        }
        await applier.logConflict(incoming, winnerHlc: null, reason: 'unique');
        return reject(SyncRejectReason.unique);
    }
    rethrow;
  }
}

/// Satu baris dengan kunci nama field Dart dan nilai bentuk JSON yang
/// seragam (UUID huruf kecil, waktu ISO UTC berakhiran `Z`).
class _Row {
  _Row(this.values);

  /// Payload perangkat. Kunci yang hilang untuk kolom boleh kosong berarti
  /// `null` (`toJson` model melewati nilai null); kunci yang hilang untuk
  /// kolom wajib (aplikasi lama) dibiarkan hilang agar default/nilai server
  /// dipakai.
  factory _Row.fromPayload(TableDefinition def, Map<String, Object?> payload) {
    final values = <String, Object?>{};
    for (final c in def.columns) {
      final key = dartNameOf(c.name);
      if (payload.containsKey(key)) {
        values[key] = _normalize(c.columnType, payload[key]);
      } else if (c.isNullable) {
        values[key] = null;
      }
    }
    return _Row(values);
  }

  factory _Row.fromDatabase(TableDefinition def, Map<String, Object?> json) =>
      _Row({
        for (final c in def.columns)
          dartNameOf(c.name): _normalize(c.columnType, json[c.name]),
      });

  final Map<String, Object?> values;

  Object? operator [](String key) => values[key];

  String get hlc => values['hlc']! as String;

  _Row copyWith(Map<String, Object?> changes) => _Row({...values, ...changes});

  String toJson() => jsonEncode(values);

  static Object? _normalize(ColumnType type, Object? value) {
    if (value == null) return null;
    return switch (type) {
      ColumnType.timestampWithoutTimeZone => _utc(value as String),
      ColumnType.uuid => (value as String).toLowerCase(),
      _ => value,
    };
  }

  /// Postgres menyimpan waktu UTC tanpa zona; payload memakai `Z`.
  static String _utc(String text) {
    final zoned = RegExp(r'(Z|[+-]\d\d:?\d\d)$').hasMatch(text);
    return DateTime.parse(zoned ? text : '${text}Z').toUtc().toIso8601String();
  }
}

class _Applier {
  _Applier(
    this.session,
    this.tx,
    this.auth,
    this.table,
    this.def,
    this.entry,
    this.serverNow,
  );

  final Session session;
  final Transaction tx;
  final DeviceAuth auth;
  final SyncTable table;
  final TableDefinition def;
  final SyncPushEntry entry;
  final DateTime serverNow;

  SyncPushResult _result(SyncResultKind kind, [_Row? server]) => SyncPushResult(
    rowId: entry.rowId,
    hlc: entry.hlc,
    kind: kind,
    serverPayloadJson: server?.toJson(),
  );

  Future<bool> alreadyApplied() async =>
      await SyncChange.db.count(
        session,
        where: (c) => c.rowId.equals(entry.rowId) & c.hlc.equals(entry.hlc),
        transaction: tx,
      ) >
      0;

  Future<SyncPushResult> apply(_Row incoming, Hlc hlc) async {
    final existing = await _load(entry.rowId);
    if (existing == null) {
      await _write(incoming, origin: auth.deviceId);
      return _result(SyncResultKind.applied);
    }
    final existingTenant = table.name == 'tenants'
        ? existing['id']
        : existing['tenantId'];
    if (existingTenant != auth.tenantId.uuid) {
      return _result(SyncResultKind.rejected).copyWith(
        reason: SyncRejectReason.tenant,
      );
    }
    final incomingNewer = hlc > Hlc.parse(existing.hlc);
    final rule = table.finalStatus;
    final existingFinal = rule != null && rule.isFinal(existing.values);
    if (existingFinal && _contentChanged(rule, existing, incoming)) {
      await logConflict(incoming, winnerHlc: existing.hlc, reason: 'final');
      return _result(SyncResultKind.rejected).copyWith(
        reason: SyncRejectReason.finalDocument,
      );
    }
    final es = existing['status'] as String?;
    final is_ = incoming['status'] as String?;
    final merged = rule != null && es != null && is_ != null
        ? rule.mergeStatus(es, is_)
        : null;
    if (merged != null && es != is_) {
      final incomingStronger = merged == is_;
      if (incomingStronger && incomingNewer) {
        await _write(incoming, origin: auth.deviceId);
        return _result(SyncResultKind.applied);
      }
      if (!incomingStronger && !incomingNewer) {
        return _stale(existing, incoming);
      }
      // Gabung monoton (aturan 7b): status tidak pernah mundur.
      final base = incomingStronger
          ? (existingFinal
                ? existing.copyWith(_statusPart(incoming))
                : incoming)
          : existing;
      final result = base.copyWith({
        'hlc': _bump(existing.hlc, incoming.hlc),
        'originDeviceId': null,
      });
      await _write(result, origin: null);
      await logConflict(incoming, winnerHlc: result.hlc, reason: 'merged');
      return _result(SyncResultKind.merged, result);
    }
    if (!incomingNewer) return _stale(existing, incoming);
    await _write(incoming, origin: auth.deviceId);
    return _result(SyncResultKind.applied);
  }

  /// Bentrok kunci alami `settings` (aturan 8b): gabung LWW ke baris server
  /// yang sudah ada. `null` bila bentroknya bukan di kunci alami.
  Future<SyncPushResult?> mergeSetting(_Row incoming, Hlc hlc) async {
    final rows = await session.db.unsafeQuery(
      'SELECT row_to_json(t)::text FROM "settings" t '
      'WHERE tenant_id = @tenant AND scope_key = @scope AND key = @key',
      parameters: QueryParameters.named({
        'tenant': auth.tenantId.uuid,
        'scope': incoming['scopeKey'],
        'key': incoming['key'],
      }),
      transaction: tx,
    );
    if (rows.isEmpty) return null;
    final existing = _Row.fromDatabase(
      def,
      jsonDecode(rows.first.first as String) as Map<String, Object?>,
    );
    if (existing['id'] == incoming['id']) return null;
    final winner = hlc > Hlc.parse(existing.hlc)
        ? incoming.copyWith({
            'id': existing['id'],
            'createdAt': existing['createdAt'],
            'createdBy': existing['createdBy'],
          })
        : existing;
    final result = winner.copyWith({
      'hlc': _bump(existing.hlc, incoming.hlc),
      'originDeviceId': null,
    });
    final savepoint = await tx.createSavepoint();
    try {
      await _write(result, origin: null);
      await savepoint.release();
    } on DatabaseQueryException {
      await savepoint.rollback();
      return null;
    }
    await logConflict(incoming, winnerHlc: result.hlc, reason: 'merged');
    return _result(SyncResultKind.merged, result);
  }

  Future<SyncPushResult> _stale(_Row existing, _Row incoming) async {
    if (existing['originDeviceId'] != incoming['originDeviceId'] &&
        _differs(existing, incoming, ignore: syncColumns)) {
      await logConflict(incoming, winnerHlc: existing.hlc, reason: 'lww');
    }
    return _result(SyncResultKind.stale, existing);
  }

  /// Kolom status (dan kolom void) dari [row] untuk gabung monoton.
  Map<String, Object?> _statusPart(_Row row) => {
    for (final key in const ['status', 'voidedAt', 'voidedBy', 'voidReason'])
      if (row.values.containsKey(key)) key: row[key],
  };

  bool _contentChanged(FinalStatusRule rule, _Row existing, _Row incoming) =>
      _differs(
        existing,
        incoming,
        ignore: {...syncColumns, ...rule.mutableColumns},
      );

  bool _differs(_Row a, _Row b, {required Set<String> ignore}) {
    for (final key in b.values.keys) {
      if (ignore.contains(key)) continue;
      if (a[key] != b[key]) return true;
    }
    return false;
  }

  /// HLC server yang lebih besar dari [a] dan [b].
  String _bump(String a, String b) {
    final ha = Hlc.parse(a);
    final hb = Hlc.parse(b);
    final max = ha > hb ? ha : hb;
    return Hlc(
      max.millis,
      max.counter,
      serverHlcNode,
    ).tick(serverNow.millisecondsSinceEpoch).toString();
  }

  Future<_Row?> _load(UuidValue id) async {
    final rows = await session.db.unsafeQuery(
      'SELECT row_to_json(t)::text FROM "${def.name}" t WHERE id = @id',
      parameters: QueryParameters.named({'id': id.uuid}),
      transaction: tx,
    );
    if (rows.isEmpty) return null;
    return _Row.fromDatabase(
      def,
      jsonDecode(rows.first.first as String) as Map<String, Object?>,
    );
  }

  /// Menulis [row] (sisip atau perbarui) lalu mencatatnya di log perubahan.
  Future<void> _write(_Row row, {required UuidValue? origin}) async {
    final columns = <String>[];
    final json = <String, Object?>{};
    for (final c in def.columns) {
      final key = dartNameOf(c.name);
      if (!row.values.containsKey(key)) continue;
      columns.add('"${c.name}"');
      json[c.name] = row[key];
    }
    final list = columns.join(', ');
    final updates = columns
        .where((c) => c != '"id"')
        .map((c) => '$c = EXCLUDED.$c')
        .join(', ');
    await session.db.unsafeQuery(
      'INSERT INTO "${def.name}" ($list) '
      'SELECT $list FROM jsonb_populate_record(NULL::"${def.name}", @row::jsonb) '
      'ON CONFLICT (id) DO UPDATE SET $updates',
      parameters: QueryParameters.named({'row': jsonEncode(json)}),
      transaction: tx,
    );
    final stored = (await _load(UuidValue.fromString(row['id']! as String)))!;
    await SyncChange.db.insertRow(
      session,
      SyncChange(
        tenantId: auth.tenantId,
        outletId: _outletOf(stored),
        entity: table.name,
        rowId: UuidValue.fromString(stored['id']! as String),
        hlc: stored.hlc,
        originDeviceId: origin,
        payloadJson: stored.toJson(),
        receivedAt: serverNow,
      ),
      transaction: tx,
    );
  }

  UuidValue? _outletOf(_Row row) {
    final id = table.name == 'outlets' ? row['id'] : row['outletId'];
    return id == null ? null : UuidValue.fromString(id as String);
  }

  Future<void> logConflict(
    _Row incoming, {
    required String? winnerHlc,
    required String reason,
  }) async {
    await SyncConflict.db.insertRow(
      session,
      SyncConflict(
        tenantId: auth.tenantId,
        entity: table.name,
        rowId: entry.rowId,
        winnerHlc: winnerHlc,
        loserHlc: entry.hlc,
        loserDeviceId: auth.deviceId,
        loserPayloadJson: entry.payloadJson,
        reason: reason,
        createdAt: serverNow,
      ),
      transaction: tx,
    );
  }
}
