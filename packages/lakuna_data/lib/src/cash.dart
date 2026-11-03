import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import 'package:serverpod_database/serverpod_database.dart' show Transaction;

import 'store.dart';
import 'store_setup.dart';
import 'sync_tx.dart';

/// Batas query sesi kasir: tenant, cabang, dan perangkat (F1-03).
class CashScope {
  const CashScope({
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
  });

  factory CashScope.of(StoreContext ctx) => CashScope(
    tenantId: ctx.tenant.id,
    outletId: ctx.outlet.id,
    deviceId: ctx.device.id,
  );

  final UuidValue tenantId;
  final UuidValue outletId;
  final UuidValue deviceId;
}

/// Perangkat ini sudah punya sesi kasir terbuka.
class CashSessionAlreadyOpen implements Exception {
  @override
  String toString() => 'CashSessionAlreadyOpen';
}

/// Sesi tidak ditemukan di cabang/perangkat ini atau sudah ditutup.
class CashSessionNotOpen implements Exception {
  @override
  String toString() => 'CashSessionNotOpen';
}

/// Field formulir sesi kasir yang bisa ditolak.
enum CashField { openingCash, amount, note, count }

/// Input sesi kasir ditolak aturan `lakuna_domain`; tidak ada yang ditulis.
class CashInputInvalid implements Exception {
  const CashInputInvalid(this.field, this.error);

  final CashField field;
  final CashError error;

  @override
  String toString() => 'CashInputInvalid($field: $error)';
}

/// Sesi terbuka perangkat di [scope], atau `null`.
Future<CashSession?> findOpenCashSession(
  LakunaStore store,
  CashScope scope, {
  Transaction? transaction,
}) => CashSession.db.findFirstRow(
  store.session,
  where: (c) =>
      c.tenantId.equals(scope.tenantId) &
      c.outletId.equals(scope.outletId) &
      c.deviceId.equals(scope.deviceId) &
      c.status.equals(CashSessionStatus.opened) &
      c.deletedAt.equals(null),
  orderBy: (c) => c.openedAt,
  transaction: transaction,
);

/// Membuka sesi kasir dengan saldo awal [openingCash]. Melempar
/// [CashInputInvalid] bila saldo/catatan tidak sah dan
/// [CashSessionAlreadyOpen] bila perangkat sudah punya sesi terbuka.
Future<CashSession> openCashSession(
  LakunaStore store,
  CashScope scope, {
  required UuidValue staffId,
  required Money openingCash,
  String note = '',
}) async {
  _reject(CashField.openingCash, validateOpeningCash(openingCash));
  _reject(CashField.note, validateOpeningNote(note));
  return store.write(actor: staffId, (w) async {
    final existing = await findOpenCashSession(
      store,
      scope,
      transaction: w.transaction,
    );
    if (existing != null) throw CashSessionAlreadyOpen();
    final s = await w.stamp();
    return w.insert(
      CashSession(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        status: CashSessionStatus.opened,
        openedBy: staffId,
        openedAt: s.now,
        openingCash: openingCash.value,
        openingNote: _noteOrNull(note),
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
}

/// Mencatat uang masuk/keluar laci di sesi [sessionId] yang masih terbuka.
Future<CashMovement> recordCashMovement(
  LakunaStore store,
  CashScope scope, {
  required UuidValue sessionId,
  required UuidValue staffId,
  required CashDirection direction,
  required Money amount,
  required String note,
  String source = 'manual',
}) async {
  _reject(CashField.amount, validateMovementAmount(amount));
  _reject(CashField.note, validateMovementNote(note));
  return store.write(actor: staffId, (w) async {
    await _openSession(w, scope, sessionId);
    final s = await w.stamp();
    return w.insert(
      CashMovement(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        cashSessionId: sessionId,
        direction: direction,
        amount: amount.value,
        note: note.trim(),
        source: source,
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
}

/// Gerakan kas sesi [sessionId], urut waktu catat.
Future<List<CashMovement>> listCashMovements(
  LakunaStore store,
  CashScope scope,
  UuidValue sessionId, {
  Transaction? transaction,
}) async {
  final rows = await CashMovement.db.find(
    store.session,
    where: (m) =>
        m.tenantId.equals(scope.tenantId) &
        m.outletId.equals(scope.outletId) &
        m.cashSessionId.equals(sessionId) &
        m.deletedAt.equals(null),
    transaction: transaction,
  );
  rows.sort((a, b) {
    final byTime = a.createdAt.compareTo(b.createdAt);
    return byTime != 0 ? byTime : a.id.uuid.compareTo(b.id.uuid);
  });
  return rows;
}

/// Komponen kas laci [session]. Penjualan dan retur tunai bernilai 0 sampai
/// modul penjualan (F1-04/F1-05/F1-11) ada.
Future<CashDrawer> cashDrawerFor(
  LakunaStore store,
  CashScope scope,
  CashSession session, {
  Transaction? transaction,
}) async {
  final movements = await listCashMovements(
    store,
    scope,
    session.id,
    transaction: transaction,
  );
  Money total(CashDirection d) => Money.sum(
    movements.where((m) => m.direction == d).map((m) => Money(m.amount)),
  );
  return CashDrawer(
    openingCash: Money(session.openingCash),
    inflow: total(CashDirection.inflow),
    outflow: total(CashDirection.outflow),
  );
}

/// Menutup sesi [sessionId] dengan hasil hitung [count]. Pemeriksaan
/// "masih terbuka", hitung seharusnya, dan pembaruan sesi berada dalam satu
/// transaksi, jadi menutup dua kali tidak menimpa hasil pertama.
Future<CashSession> closeCashSession(
  LakunaStore store,
  CashScope scope, {
  required UuidValue sessionId,
  required UuidValue staffId,
  required CashCount count,
  String note = '',
}) async {
  if (!count.isValid) {
    throw const CashInputInvalid(CashField.count, CashError.negative);
  }
  return store.write(actor: staffId, (w) async {
    final session = await _openSession(w, scope, sessionId);
    final drawer = await cashDrawerFor(
      store,
      scope,
      session,
      transaction: w.transaction,
    );
    final counted = count.total;
    final difference = drawer.differenceFor(counted);
    _reject(CashField.note, validateClosingNote(difference, note));
    final s = await w.stamp();
    return w.update(
      session.copyWith(
        status: CashSessionStatus.closed,
        closedBy: staffId,
        closedAt: s.now,
        expectedCash: drawer.expectedCash.value,
        countedCash: counted.value,
        difference: difference.value,
        countedBreakdown: jsonEncode(count.toJson()),
        closingNote: _noteOrNull(note),
        version: session.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

Future<CashSession> _openSession(
  SyncTx w,
  CashScope scope,
  UuidValue sessionId,
) async {
  final session = await CashSession.db.findFirstRow(
    w.session,
    where: (c) =>
        c.id.equals(sessionId) &
        c.tenantId.equals(scope.tenantId) &
        c.outletId.equals(scope.outletId) &
        c.deviceId.equals(scope.deviceId) &
        c.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (session == null || session.status != CashSessionStatus.opened) {
    throw CashSessionNotOpen();
  }
  return session;
}

void _reject(CashField field, CashError? error) {
  if (error != null) throw CashInputInvalid(field, error);
}

String? _noteOrNull(String note) {
  final trimmed = note.trim();
  return trimmed.isEmpty ? null : trimmed;
}
