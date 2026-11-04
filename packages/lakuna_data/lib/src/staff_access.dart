import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import 'store.dart';

/// Staf yang boleh bekerja di satu cabang beserta role-nya (F1-02).
class OutletStaff {
  OutletStaff({required this.staff, required this.roleKey, StaffRole? role})
    : roleName = role?.name,
      permissions = effectivePermissions(
        roleKey: roleKey,
        isOwner: staff.isOwner,
        stored: role?.permissionKeys,
      );

  /// Baris staf, termasuk hash PIN/kata sandi untuk diverifikasi.
  final StaffMember staff;

  /// Kunci role di `outlet_members.role_name` (mis. `cashier`).
  final String roleKey;

  UuidValue get id => staff.id;
  String get name => staff.name;
  bool get isOwner => staff.isOwner;
  bool get hasPin => staff.pinHash != null && staff.pinHash!.isNotEmpty;

  /// Nama role tersimpan (role custom, atau bawaan yang izinnya pernah
  /// diubah), `null` bila role bawaan belum pernah disimpan.
  final String? roleName;

  /// Izin efektif: pemilik semua izin, lalu baris `roles`, lalu bawaan.
  final Set<Permission> permissions;
}

/// Baris `roles` aktif milik [tenantId] per kunci (F1-17).
Future<Map<String, StaffRole>> storedRoles(
  LakunaStore store, {
  required UuidValue tenantId,
}) async {
  final rows = await StaffRole.db.find(
    store.session,
    where: (r) => r.tenantId.equals(tenantId) & r.deletedAt.equals(null),
  );
  return {for (final r in rows) r.roleKey: r};
}

/// Staf aktif yang punya keanggotaan aktif di [outletId]: pemilik dulu,
/// lalu urut nama.
Future<List<OutletStaff>> listOutletStaff(
  LakunaStore store, {
  required UuidValue tenantId,
  required UuidValue outletId,
}) async {
  final session = store.session;
  final members = await OutletMember.db.find(
    session,
    where: (m) =>
        m.tenantId.equals(tenantId) &
        m.outletId.equals(outletId) &
        m.deletedAt.equals(null),
  );
  if (members.isEmpty) return const [];
  final roles = {for (final m in members) m.staffMemberId: m.roleName};
  final staff = await StaffMember.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(tenantId) &
        s.id.inSet(roles.keys.toSet()) &
        s.isActive.equals(true) &
        s.deletedAt.equals(null),
  );
  final stored = await storedRoles(store, tenantId: tenantId);
  final result = [
    for (final s in staff)
      OutletStaff(staff: s, roleKey: roles[s.id]!, role: stored[roles[s.id]!]),
  ];
  result.sort((a, b) {
    if (a.isOwner != b.isOwner) return a.isOwner ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return result;
}

/// Staf [staffId] bila masih aktif di [outletId], selain itu `null`.
Future<OutletStaff?> findStaffById(
  LakunaStore store, {
  required UuidValue tenantId,
  required UuidValue outletId,
  required UuidValue staffId,
}) async {
  final staff = await StaffMember.db.findFirstRow(
    store.session,
    where: (s) =>
        s.id.equals(staffId) &
        s.tenantId.equals(tenantId) &
        s.isActive.equals(true) &
        s.deletedAt.equals(null),
  );
  if (staff == null) return null;
  return _withRole(store, staff, outletId);
}

/// Pemilik aktif dengan [email] (dipangkas, huruf kecil), atau `null`.
/// Pemilik boleh masuk di cabang mana pun; role-nya diambil dari
/// keanggotaan cabang bila ada, selain itu `owner`.
Future<OutletStaff?> findOwnerByEmail(
  LakunaStore store, {
  required UuidValue tenantId,
  required UuidValue outletId,
  required String email,
}) async {
  final normalized = email.trim().toLowerCase();
  if (normalized.isEmpty) return null;
  final owner = await StaffMember.db.findFirstRow(
    store.session,
    where: (s) =>
        s.tenantId.equals(tenantId) &
        s.email.equals(normalized) &
        s.isOwner.equals(true) &
        s.isActive.equals(true) &
        s.deletedAt.equals(null),
  );
  if (owner == null) return null;
  return await _withRole(store, owner, outletId) ??
      OutletStaff(staff: owner, roleKey: DefaultRole.owner.key);
}

Future<OutletStaff?> _withRole(
  LakunaStore store,
  StaffMember staff,
  UuidValue outletId,
) async {
  final member = await OutletMember.db.findFirstRow(
    store.session,
    where: (m) =>
        m.tenantId.equals(staff.tenantId) &
        m.staffMemberId.equals(staff.id) &
        m.outletId.equals(outletId) &
        m.deletedAt.equals(null),
  );
  if (member == null) return null;
  final role = await StaffRole.db.findFirstRow(
    store.session,
    where: (r) =>
        r.tenantId.equals(staff.tenantId) &
        r.roleKey.equals(member.roleName) &
        r.deletedAt.equals(null),
  );
  return OutletStaff(staff: staff, roleKey: member.roleName, role: role);
}
