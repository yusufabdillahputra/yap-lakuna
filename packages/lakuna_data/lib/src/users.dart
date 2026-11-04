import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'stock.dart' show CatalogScope;
import 'staff_access.dart';
import 'store.dart';
import 'sync_tx.dart';

// Pengguna & role (F1-17, layar 1.25 / 1.25b). Staf = `staff_members` +
// `outlet_members`; izin role di tabel `roles` (role bawaan baru disimpan saat
// matriksnya diubah). Hash PIN/kata sandi dihitung pemanggil.

// --- Galat --------------------------------------------------------------------

/// Aktor bukan staf aktif cabang ini atau tidak punya [permission].
class UsersActorNotPermitted implements Exception {
  const UsersActorNotPermitted(this.permission);

  final Permission permission;

  @override
  String toString() => 'UsersActorNotPermitted(${permission.key})';
}

class StaffNameInvalid implements Exception {
  const StaffNameInvalid(this.issue);

  final StaffIssue issue;

  @override
  String toString() => 'StaffNameInvalid($issue)';
}

/// Nama staf sudah dipakai staf lain di tenant (tanpa membedakan huruf).
class StaffNameTaken implements Exception {
  @override
  String toString() => 'StaffNameTaken';
}

class StaffNotFound implements Exception {
  @override
  String toString() => 'StaffNotFound';
}

/// Pemilik (atau role `owner`) tidak bisa diubah lewat Pengguna & role.
class StaffOwnerLocked implements Exception {
  @override
  String toString() => 'StaffOwnerLocked';
}

/// Aktor yang bukan pemilik mencoba mengubah dirinya atau role-nya sendiri.
class StaffSelfChange implements Exception {
  @override
  String toString() => 'StaffSelfChange';
}

/// Aktor yang bukan pemilik memberi atau menyentuh izin di luar miliknya.
class StaffBeyondPermissions implements Exception {
  @override
  String toString() => 'StaffBeyondPermissions';
}

/// Akun tidak punya kata sandi (staf PIN saja).
class StaffNoPassword implements Exception {
  @override
  String toString() => 'StaffNoPassword';
}

class RoleNotFound implements Exception {
  @override
  String toString() => 'RoleNotFound';
}

class RoleNameInvalid implements Exception {
  const RoleNameInvalid(this.issue);

  final StaffIssue issue;

  @override
  String toString() => 'RoleNameInvalid($issue)';
}

class RoleNameTaken implements Exception {
  @override
  String toString() => 'RoleNameTaken';
}

/// Role custom masih dipakai staf, jadi tidak bisa dihapus.
class RoleInUse implements Exception {
  @override
  String toString() => 'RoleInUse';
}

// --- Baca ---------------------------------------------------------------------

/// Satu baris daftar pengguna 1.25 (termasuk staf nonaktif).
class StaffAccount {
  const StaffAccount({
    required this.staff,
    required this.roleKey,
    required this.roleName,
    required this.permissions,
  });

  final StaffMember staff;
  final String roleKey;

  /// Nama role tersimpan (lihat [OutletStaff.roleName]).
  final String? roleName;
  final Set<Permission> permissions;

  UuidValue get id => staff.id;
  String get name => staff.name;
  String? get email => staff.email;
  bool get isOwner => staff.isOwner;
  bool get isActive => staff.isActive;
  bool get hasPin => staff.pinHash?.isNotEmpty ?? false;
  bool get hasPassword => staff.passwordHash?.isNotEmpty ?? false;
}

/// Staf (aktif dan nonaktif) yang punya keanggotaan di cabang [scope]:
/// pemilik dulu, lalu urut nama.
Future<List<StaffAccount>> listStaffAccounts(
  LakunaStore store,
  CatalogScope scope,
) async {
  final members = await OutletMember.db.find(
    store.session,
    where: (m) =>
        m.tenantId.equals(scope.tenantId) &
        m.outletId.equals(scope.outletId) &
        m.deletedAt.equals(null),
  );
  if (members.isEmpty) return const [];
  final roleOf = {for (final m in members) m.staffMemberId: m.roleName};
  final staff = await StaffMember.db.find(
    store.session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.id.inSet(roleOf.keys.toSet()) &
        s.deletedAt.equals(null),
  );
  final stored = await storedRoles(store, tenantId: scope.tenantId);
  final result = [
    for (final s in staff)
      if (roleOf[s.id] case final key?)
        StaffAccount(
          staff: s,
          roleKey: key,
          roleName: stored[key]?.name,
          permissions: effectivePermissions(
            roleKey: key,
            isOwner: s.isOwner,
            stored: stored[key]?.permissionKeys,
          ),
        ),
  ];
  result.sort((a, b) {
    if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return result;
}

/// Satu kolom matriks izin 1.25.
class RoleSummary {
  const RoleSummary({
    required this.key,
    required this.name,
    required this.permissions,
    required this.memberCount,
  });

  final String key;

  /// Nama role custom; `null` untuk role bawaan (label dari terjemahan).
  final String? name;
  final Set<Permission> permissions;

  /// Jumlah staf (aktif dan nonaktif) di cabang ini yang memakai role ini.
  final int memberCount;

  bool get isOwner => key == DefaultRole.owner.key;
  bool get isCustom => !_defaultKeys.contains(key);
}

final _defaultKeys = {for (final r in DefaultRole.values) r.key};

/// Role untuk matriks: pemilik, role bawaan (urut enum), lalu role custom
/// urut nama.
Future<List<RoleSummary>> listRoles(
  LakunaStore store,
  CatalogScope scope,
) async {
  final stored = await storedRoles(store, tenantId: scope.tenantId);
  final members = await _members(store.session, scope);
  int count(String key) => members.where((m) => m.roleName == key).length;
  final custom =
      stored.values.where((r) => !_defaultKeys.contains(r.roleKey)).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return [
    for (final r in DefaultRole.values)
      RoleSummary(
        key: r.key,
        name: null,
        permissions: effectivePermissions(
          roleKey: r.key,
          isOwner: r == DefaultRole.owner,
          stored: stored[r.key]?.permissionKeys,
        ),
        memberCount: count(r.key),
      ),
    for (final r in custom)
      RoleSummary(
        key: r.roleKey,
        name: r.name,
        permissions: decodePermissions(r.permissionKeys),
        memberCount: count(r.roleKey),
      ),
  ];
}

Future<List<OutletMember>> _members(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) => OutletMember.db.find(
  session,
  where: (m) =>
      m.tenantId.equals(scope.tenantId) &
      m.outletId.equals(scope.outletId) &
      m.deletedAt.equals(null),
  transaction: transaction,
);

// --- Pemeriksaan --------------------------------------------------------------

Future<OutletStaff> _requireManager(
  LakunaStore store,
  CatalogScope scope,
  UuidValue staffId,
) async {
  final actor = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: staffId,
  );
  if (actor == null || !actor.permissions.contains(Permission.usersManage)) {
    throw const UsersActorNotPermitted(Permission.usersManage);
  }
  return actor;
}

void _requireWithin(OutletStaff actor, Set<Permission> touched) {
  if (grantIssue(
        actorIsOwner: actor.isOwner,
        actorPermissions: actor.permissions,
        granted: touched,
      ) !=
      null) {
    throw StaffBeyondPermissions();
  }
}

/// Izin efektif role [roleKey] yang boleh diberikan ke staf; `owner` dan
/// kunci yang tidak dikenal ditolak.
Future<Set<Permission>> _assignable(
  DatabaseSession session,
  CatalogScope scope,
  String roleKey, {
  Transaction? transaction,
}) async {
  if (roleKey == DefaultRole.owner.key) throw RoleNotFound();
  final row = await _storedRole(
    session,
    scope,
    roleKey,
    transaction: transaction,
  );
  if (row == null && !_defaultKeys.contains(roleKey)) throw RoleNotFound();
  return effectivePermissions(roleKey: roleKey, stored: row?.permissionKeys);
}

Future<StaffRole?> _storedRole(
  DatabaseSession session,
  CatalogScope scope,
  String roleKey, {
  Transaction? transaction,
}) => StaffRole.db.findFirstRow(
  session,
  where: (r) =>
      r.tenantId.equals(scope.tenantId) &
      r.roleKey.equals(roleKey) &
      r.deletedAt.equals(null),
  transaction: transaction,
);

String _cleanName(String name) {
  if (staffNameIssue(name) case final issue?) throw StaffNameInvalid(issue);
  return name.trim();
}

Future<void> _requireUniqueName(
  DatabaseSession session,
  CatalogScope scope,
  String name, {
  UuidValue? except,
  Transaction? transaction,
}) async {
  final all = await StaffMember.db.find(
    session,
    where: (s) => s.tenantId.equals(scope.tenantId) & s.deletedAt.equals(null),
    transaction: transaction,
  );
  final lower = name.toLowerCase();
  if (all.any((s) => s.id != except && s.name.toLowerCase() == lower)) {
    throw StaffNameTaken();
  }
}

// --- Staf ---------------------------------------------------------------------

/// Menambah staf PIN saja dengan role [roleKey] di cabang [scope].
Future<StaffMember> createStaff(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String name,
  required String roleKey,
  required String pinHash,
  bool active = true,
}) async {
  final clean = _cleanName(name);
  final actor = await _requireManager(store, scope, staffId);
  return store.write(actor: staffId, (w) async {
    _requireWithin(
      actor,
      await _assignable(w.session, scope, roleKey, transaction: w.transaction),
    );
    await _requireUniqueName(
      w.session,
      scope,
      clean,
      transaction: w.transaction,
    );
    final s = await w.stamp();
    final staff = await w.insert(
      StaffMember(
        tenantId: scope.tenantId,
        name: clean,
        pinHash: pinHash,
        isActive: active,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    await w.insert(
      OutletMember(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        staffMemberId: staff.id,
        roleName: roleKey,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    return staff;
  });
}

/// Staf [targetId] beserta keanggotaannya di cabang [scope] untuk diubah.
/// Pemilik ditolak; aktor bukan pemilik tidak boleh mengubah dirinya sendiri
/// atau staf yang izinnya melebihi miliknya.
Future<(StaffMember, OutletMember)> _target(
  SyncTx w,
  CatalogScope scope,
  OutletStaff actor,
  UuidValue targetId,
) async {
  final staff = await StaffMember.db.findFirstRow(
    w.session,
    where: (s) =>
        s.id.equals(targetId) &
        s.tenantId.equals(scope.tenantId) &
        s.deletedAt.equals(null),
    transaction: w.transaction,
  );
  final member = await OutletMember.db.findFirstRow(
    w.session,
    where: (m) =>
        m.tenantId.equals(scope.tenantId) &
        m.outletId.equals(scope.outletId) &
        m.staffMemberId.equals(targetId) &
        m.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (staff == null || member == null) throw StaffNotFound();
  if (staff.isOwner) throw StaffOwnerLocked();
  if (!actor.isOwner && targetId == actor.id) throw StaffSelfChange();
  _requireWithin(
    actor,
    await _assignable(
      w.session,
      scope,
      member.roleName,
      transaction: w.transaction,
    ).catchError((Object _) => const <Permission>{}),
  );
  return (staff, member);
}

/// Mengubah nama, role, dan status staf [targetId].
Future<void> updateStaff(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue targetId,
  required String name,
  required String roleKey,
  required bool active,
}) async {
  final clean = _cleanName(name);
  final actor = await _requireManager(store, scope, staffId);
  await store.write(actor: staffId, (w) async {
    final (staff, member) = await _target(w, scope, actor, targetId);
    _requireWithin(
      actor,
      await _assignable(w.session, scope, roleKey, transaction: w.transaction),
    );
    await _requireUniqueName(
      w.session,
      scope,
      clean,
      except: targetId,
      transaction: w.transaction,
    );
    final s = await w.stamp();
    if (staff.name != clean || staff.isActive != active) {
      await w.update(
        staff.copyWith(
          name: clean,
          isActive: active,
          version: staff.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    if (member.roleName != roleKey) {
      await w.update(
        member.copyWith(
          roleName: roleKey,
          version: member.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
  });
}

/// Reset PIN staf [targetId] tanpa PIN lama (`users:manage`).
Future<void> resetStaffPin(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue targetId,
  required String pinHash,
}) async {
  final actor = await _requireManager(store, scope, staffId);
  await store.write(actor: staffId, (w) async {
    final (staff, _) = await _target(w, scope, actor, targetId);
    await _setSecrets(w, staff, staffId, pinHash: pinHash);
  });
}

Future<void> _setSecrets(
  SyncTx w,
  StaffMember staff,
  UuidValue actor, {
  String? pinHash,
  String? passwordHash,
}) async {
  final s = await w.stamp();
  await w.update(
    staff.copyWith(
      pinHash: pinHash ?? staff.pinHash,
      passwordHash: passwordHash ?? staff.passwordHash,
      version: staff.version + 1,
      updatedAt: s.now,
      updatedBy: actor,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
}

Future<StaffMember> _self(
  LakunaStore store,
  CatalogScope scope,
  UuidValue id,
) async {
  final me = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: id,
  );
  if (me == null) throw StaffNotFound();
  return me.staff;
}

/// *Akun saya*: mengganti PIN sendiri. Pemanggil sudah memeriksa PIN saat
/// ini dan kolom ulangi.
Future<void> changeOwnPin(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String pinHash,
}) async {
  final me = await _self(store, scope, staffId);
  await store.write(
    actor: staffId,
    (w) => _setSecrets(w, me, staffId, pinHash: pinHash),
  );
}

/// *Akun saya*: mengganti kata sandi sendiri (hanya akun yang punya kata
/// sandi, yaitu pemilik). Pemanggil sudah memeriksa kata sandi saat ini.
Future<void> changeOwnPassword(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String passwordHash,
}) async {
  final me = await _self(store, scope, staffId);
  if (me.passwordHash?.isNotEmpty != true) throw StaffNoPassword();
  await store.write(
    actor: staffId,
    (w) => _setSecrets(w, me, staffId, passwordHash: passwordHash),
  );
}

// --- Role ---------------------------------------------------------------------

/// Menyimpan izin beberapa role sekaligus (satu transaksi). Role `owner`
/// ditolak; aktor bukan pemilik tidak boleh mengubah role-nya sendiri atau
/// menyentuh izin di luar miliknya.
Future<void> saveRoleMatrix(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required Map<String, Set<Permission>> changes,
}) async {
  final actor = await _requireManager(store, scope, staffId);
  await store.write(actor: staffId, (w) async {
    for (final MapEntry(key: key, value: permissions) in changes.entries) {
      if (key == DefaultRole.owner.key) throw StaffOwnerLocked();
      final row = await _storedRole(
        w.session,
        scope,
        key,
        transaction: w.transaction,
      );
      if (row == null && !_defaultKeys.contains(key)) throw RoleNotFound();
      if (!actor.isOwner && key == actor.roleKey) throw StaffSelfChange();
      final before = effectivePermissions(
        roleKey: key,
        stored: row?.permissionKeys,
      );
      _requireWithin(actor, {...before, ...permissions});
      final encoded = encodePermissions(permissions);
      final s = await w.stamp();
      if (row == null) {
        await w.insert(
          StaffRole(
            tenantId: scope.tenantId,
            roleKey: key,
            name: key,
            permissionKeys: encoded,
            createdAt: s.now,
            updatedAt: s.now,
            createdBy: staffId,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      } else if (row.permissionKeys != encoded) {
        await w.update(
          row.copyWith(
            permissionKeys: encoded,
            version: row.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      }
    }
  });
}

String _cleanRoleName(String name) {
  if (staffNameIssue(name) case final issue?) throw RoleNameInvalid(issue);
  return name.trim();
}

Future<void> _requireUniqueRoleName(
  DatabaseSession session,
  CatalogScope scope,
  String name, {
  String? except,
  Transaction? transaction,
}) async {
  final rows = await StaffRole.db.find(
    session,
    where: (r) => r.tenantId.equals(scope.tenantId) & r.deletedAt.equals(null),
    transaction: transaction,
  );
  final lower = name.toLowerCase();
  if (rows.any(
    (r) =>
        r.roleKey != except &&
        !_defaultKeys.contains(r.roleKey) &&
        r.name.toLowerCase() == lower,
  )) {
    throw RoleNameTaken();
  }
}

/// Membuat role custom; kunci dibuat dari nama ([roleKeyFor]).
Future<StaffRole> createCustomRole(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String name,
  required Set<Permission> permissions,
}) async {
  final clean = _cleanRoleName(name);
  final actor = await _requireManager(store, scope, staffId);
  _requireWithin(actor, permissions);
  return store.write(actor: staffId, (w) async {
    await _requireUniqueRoleName(
      w.session,
      scope,
      clean,
      transaction: w.transaction,
    );
    // Termasuk role yang sudah dihapus: indeks unik (tenant, kunci).
    final taken = {
      for (final r in await StaffRole.db.find(
        w.session,
        where: (r) => r.tenantId.equals(scope.tenantId),
        transaction: w.transaction,
      ))
        r.roleKey,
    };
    final s = await w.stamp();
    return w.insert(
      StaffRole(
        tenantId: scope.tenantId,
        roleKey: roleKeyFor(clean, taken),
        name: clean,
        permissionKeys: encodePermissions(permissions),
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

Future<StaffRole> _customRole(
  SyncTx w,
  CatalogScope scope,
  String roleKey,
) async {
  if (_defaultKeys.contains(roleKey)) throw RoleNotFound();
  final row = await _storedRole(
    w.session,
    scope,
    roleKey,
    transaction: w.transaction,
  );
  if (row == null) throw RoleNotFound();
  return row;
}

/// Mengganti nama role custom; kuncinya tetap.
Future<void> renameCustomRole(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String roleKey,
  required String name,
}) async {
  final clean = _cleanRoleName(name);
  final actor = await _requireManager(store, scope, staffId);
  await store.write(actor: staffId, (w) async {
    final row = await _customRole(w, scope, roleKey);
    _requireWithin(actor, decodePermissions(row.permissionKeys));
    await _requireUniqueRoleName(
      w.session,
      scope,
      clean,
      except: roleKey,
      transaction: w.transaction,
    );
    final s = await w.stamp();
    await w.update(
      row.copyWith(
        name: clean,
        version: row.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

/// Menghapus (soft delete) role custom yang tidak dipakai staf mana pun di
/// tenant ini.
Future<void> deleteCustomRole(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String roleKey,
}) async {
  final actor = await _requireManager(store, scope, staffId);
  await store.write(actor: staffId, (w) async {
    final row = await _customRole(w, scope, roleKey);
    _requireWithin(actor, decodePermissions(row.permissionKeys));
    final used = await OutletMember.db.findFirstRow(
      w.session,
      where: (m) =>
          m.tenantId.equals(scope.tenantId) &
          m.roleName.equals(roleKey) &
          m.deletedAt.equals(null),
      transaction: w.transaction,
    );
    if (used != null) throw RoleInUse();
    final s = await w.stamp();
    await w.update(
      row.copyWith(
        deletedAt: s.now,
        version: row.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}
