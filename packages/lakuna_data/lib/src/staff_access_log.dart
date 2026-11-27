import 'package:lakuna_client/lakuna_client.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show ColumnOrderingOperations;

import 'stock.dart' show CatalogScope;
import 'store.dart';

/// Kursor halaman log masuk/keluar: baris terakhir halaman sebelumnya.
class StaffAccessCursor {
  const StaffAccessCursor({
    required this.occurredAt,
    required this.hlc,
    required this.id,
  });

  final DateTime occurredAt;

  /// HLC baris: urutan tulis di perangkat yang sama, termasuk kejadian di
  /// milidetik yang sama (UUID v7 tidak urut di dalam satu milidetik).
  final String hlc;
  final UuidValue id;
}

/// Urutan log terbaru dulu: waktu, lalu HLC, lalu id (teks heksadesimal id
/// sama urutannya dengan byte UUID di SQLite).
int _newestFirst(StaffAccessLog a, StaffAccessLog b) {
  final byTime = b.occurredAt.compareTo(a.occurredAt);
  if (byTime != 0) return byTime;
  final byHlc = b.hlc.compareTo(a.hlc);
  return byHlc != 0 ? byHlc : b.id.uuid.compareTo(a.id.uuid);
}

/// Satu kejadian log beserta nama staf dan kode perangkatnya (F1-03h).
class StaffAccessRow {
  const StaffAccessRow({
    required this.log,
    required this.staffName,
    required this.deviceCode,
  });

  final StaffAccessLog log;

  /// Nama staf, termasuk staf yang sudah dihapus; `?` bila tidak dikenal.
  final String staffName;

  /// Kode perangkat (mis. `K01`); `?` bila tidak dikenal.
  final String deviceCode;
}

/// Satu halaman log, terbaru dulu.
class StaffAccessPage {
  const StaffAccessPage({required this.rows, required this.hasMore});

  final List<StaffAccessRow> rows;

  /// Masih ada baris lebih lama dari [next].
  final bool hasMore;

  /// Kursor untuk halaman berikutnya, `null` bila halaman kosong.
  StaffAccessCursor? get next => rows.isEmpty
      ? null
      : StaffAccessCursor(
          occurredAt: rows.last.log.occurredAt,
          hlc: rows.last.log.hlc,
          id: rows.last.log.id,
        );
}

/// Mencatat kejadian masuk/keluar [staffId] di perangkat `scope.deviceId`
/// (F1-03h). Lewat `store.write` agar ikut outbox sinkron.
Future<StaffAccessLog> recordStaffAccess(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required StaffAccessKind kind,
}) => store.write(actor: staffId, (w) async {
  final s = await w.stamp();
  return w.insert(
    StaffAccessLog(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      deviceId: scope.deviceId,
      staffId: staffId,
      kind: kind,
      occurredAt: s.now,
      createdAt: s.now,
      updatedAt: s.now,
      createdBy: staffId,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

/// Log masuk/keluar cabang [scope], terbaru dulu, [limit] baris per halaman.
/// [staffId] menyaring satu staf; [before] = kursor halaman sebelumnya.
Future<StaffAccessPage> listStaffAccess(
  LakunaStore store,
  CatalogScope scope, {
  UuidValue? staffId,
  StaffAccessCursor? before,
  int limit = 50,
}) async {
  final session = store.session;
  bool keep(StaffAccessLog l) =>
      l.tenantId == scope.tenantId &&
      l.outletId == scope.outletId &&
      l.deletedAt == null &&
      (staffId == null || l.staffId == staffId);

  final logs = <StaffAccessLog>[];
  if (before != null) {
    // Baris lain di waktu yang sama dengan kursor: sisanya ditentukan HLC
    // lalu id, dipilah di Dart.
    final cursor = StaffAccessLog(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      deviceId: scope.deviceId,
      staffId: scope.deviceId,
      kind: StaffAccessKind.signOut,
      occurredAt: before.occurredAt,
      hlc: before.hlc,
      id: before.id,
    );
    final same = await StaffAccessLog.db.find(
      session,
      where: (l) =>
          l.tenantId.equals(scope.tenantId) &
          l.outletId.equals(scope.outletId) &
          l.occurredAt.equals(before.occurredAt),
    );
    logs
      ..addAll(same.where((l) => keep(l) && _newestFirst(cursor, l) < 0))
      ..sort(_newestFirst);
  }
  final older = await StaffAccessLog.db.find(
    session,
    where: (l) {
      var e =
          l.tenantId.equals(scope.tenantId) &
          l.outletId.equals(scope.outletId) &
          l.deletedAt.equals(null);
      if (staffId != null) e = e & l.staffId.equals(staffId);
      if (before != null) e = e & (l.occurredAt < before.occurredAt);
      return e;
    },
    orderByList: (l) => [l.occurredAt.desc(), l.hlc.desc(), l.id.desc()],
    limit: limit + 1,
  );
  logs.addAll(older);

  final page = logs.take(limit).toList();
  final staffIds = {for (final l in page) l.staffId};
  final deviceIds = {for (final l in page) l.deviceId};
  final staff = staffIds.isEmpty
      ? const <StaffMember>[]
      : await StaffMember.db.find(session, where: (s) => s.id.inSet(staffIds));
  final devices = deviceIds.isEmpty
      ? const <Device>[]
      : await Device.db.find(session, where: (d) => d.id.inSet(deviceIds));
  final names = {for (final s in staff) s.id: s.name};
  final codes = {for (final d in devices) d.id: d.code};
  return StaffAccessPage(
    rows: [
      for (final l in page)
        StaffAccessRow(
          log: l,
          staffName: names[l.staffId] ?? '?',
          deviceCode: codes[l.deviceId] ?? '?',
        ),
    ],
    hasMore: logs.length > limit,
  );
}
