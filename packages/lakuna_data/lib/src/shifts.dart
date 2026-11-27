import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'stock.dart' show CatalogScope;
import 'staff_access.dart';
import 'store.dart';

/// Isian shift ditolak aturan `lakuna_domain` (F1-03g).
class ShiftInvalid implements Exception {
  const ShiftInvalid(this.issues);

  final Set<ShiftIssue> issues;

  @override
  String toString() => 'ShiftInvalid($issues)';
}

/// Nama shift sudah dipakai shift lain di cabang ini.
class ShiftNameTaken implements Exception {
  @override
  String toString() => 'ShiftNameTaken';
}

/// Shift tidak ada di cabang ini atau sudah dihapus.
class ShiftNotFound implements Exception {
  @override
  String toString() => 'ShiftNotFound';
}

/// Shift masih dipakai [sessions] sesi kasir, jadi tidak bisa dihapus.
class ShiftInUse implements Exception {
  const ShiftInUse(this.sessions);

  final int sessions;

  @override
  String toString() => 'ShiftInUse($sessions)';
}

/// Staf tidak punya [permission] untuk mengubah master shift.
class ShiftActorNotPermitted implements Exception {
  const ShiftActorNotPermitted(this.permission);

  final Permission permission;

  @override
  String toString() => 'ShiftActorNotPermitted(${permission.key})';
}

/// Shift cabang beserta jumlah sesi kasir yang memakainya.
class ShiftRow {
  const ShiftRow({required this.shift, required this.usage});

  final Shift shift;
  final int usage;
}

Future<List<Shift>> _shifts(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) => Shift.db.find(
  session,
  where: (s) =>
      s.tenantId.equals(scope.tenantId) &
      s.outletId.equals(scope.outletId) &
      s.deletedAt.equals(null),
  transaction: transaction,
);

void _sort(List<Shift> shifts) => shifts.sort((a, b) {
  final byStart = a.startMinute.compareTo(b.startMinute);
  return byStart != 0
      ? byStart
      : a.name.toLowerCase().compareTo(b.name.toLowerCase());
});

/// Shift aktif cabang, urut jam mulai lalu nama, tanpa jumlah pemakai
/// (pilihan shift saat buka sesi; boleh dibaca semua staf).
Future<List<Shift>> activeShifts(LakunaStore store, CatalogScope scope) async {
  final shifts = await _shifts(store.session, scope);
  _sort(shifts);
  return shifts;
}

/// [activeShifts] beserta jumlah sesi kasir pemakai tiap shift (tab
/// Master data › Shift).
Future<List<ShiftRow>> listShifts(LakunaStore store, CatalogScope scope) async {
  final shifts = await activeShifts(store, scope);
  return [
    for (final s in shifts)
      ShiftRow(
        shift: s,
        usage: await CashSession.db.count(
          store.session,
          where: (c) =>
              c.tenantId.equals(scope.tenantId) &
              c.shiftId.equals(s.id) &
              c.deletedAt.equals(null),
        ),
      ),
  ];
}

/// Shift [ids] cabang [scope] termasuk yang sudah dihapus lunak, untuk
/// nama shift di sesi lama.
Future<Map<UuidValue, Shift>> shiftsById(
  DatabaseSession session,
  CatalogScope scope,
  Iterable<UuidValue> ids, {
  Transaction? transaction,
}) async {
  final wanted = ids.toSet();
  if (wanted.isEmpty) return const {};
  final rows = await Shift.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.id.inSet(wanted),
    transaction: transaction,
  );
  return {for (final s in rows) s.id: s};
}

/// Shift aktif [id] di cabang [scope]; [ShiftNotFound] bila tidak ada.
Future<Shift> requireActiveShift(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue id, {
  Transaction? transaction,
}) async {
  final shift = await Shift.db.findFirstRow(
    session,
    where: (s) =>
        s.id.equals(id) &
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.deletedAt.equals(null),
    transaction: transaction,
  );
  if (shift == null) throw ShiftNotFound();
  return shift;
}

Future<void> _requireActor(
  LakunaStore store,
  CatalogScope scope,
  UuidValue staffId,
) async {
  final staff = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: staffId,
  );
  if (staff == null || !staff.permissions.contains(Permission.settingsManage)) {
    throw const ShiftActorNotPermitted(Permission.settingsManage);
  }
}

/// Membuat atau mengubah ([id]) shift. Butuh `settings:manage`; nama unik
/// per cabang tanpa membedakan huruf.
Future<Shift> saveShift(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  UuidValue? id,
  required String name,
  required int startMinute,
  required int endMinute,
}) async {
  final issues = validateShift(name: name, start: startMinute, end: endMinute);
  if (issues.isNotEmpty) throw ShiftInvalid(issues);
  await _requireActor(store, scope, staffId);
  final clean = name.trim();
  return store.write(actor: staffId, (w) async {
    final shifts = await _shifts(w.session, scope, transaction: w.transaction);
    if (shifts.any(
      (s) => s.id != id && s.name.toLowerCase() == clean.toLowerCase(),
    )) {
      throw ShiftNameTaken();
    }
    final s = await w.stamp();
    if (id == null) {
      return w.insert(
        Shift(
          tenantId: scope.tenantId,
          outletId: scope.outletId,
          name: clean,
          startMinute: startMinute,
          endMinute: endMinute,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    final old = shifts.where((x) => x.id == id).firstOrNull;
    if (old == null) throw ShiftNotFound();
    return w.update(
      old.copyWith(
        name: clean,
        startMinute: startMinute,
        endMinute: endMinute,
        version: old.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

/// Hapus lunak shift yang belum dipakai sesi kasir mana pun
/// ([ShiftInUse]). Butuh `settings:manage`.
Future<void> deleteShift(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue shiftId,
}) async {
  await _requireActor(store, scope, staffId);
  await store.write(actor: staffId, (w) async {
    final shift = await requireActiveShift(
      w.session,
      scope,
      shiftId,
      transaction: w.transaction,
    );
    final used = await CashSession.db.count(
      w.session,
      where: (c) =>
          c.tenantId.equals(scope.tenantId) &
          c.shiftId.equals(shiftId) &
          c.deletedAt.equals(null),
      transaction: w.transaction,
    );
    if (used > 0) throw ShiftInUse(used);
    final s = await w.stamp();
    await w.update(
      shift.copyWith(
        deletedAt: s.now,
        version: shift.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}
