import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/users_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

final _tenant = UuidValue.fromString('0192f3a1-7c00-7000-8000-0000000000aa');

/// Akun staf contoh.
StaffAccount sampleAccount(
  String name, {
  String role = 'cashier',
  String? roleName,
  bool active = true,
  String? email,
  bool password = false,
  bool pin = true,
  UuidValue? id,
}) {
  final isOwner = role == DefaultRole.owner.key;
  return StaffAccount(
    staff: StaffMember(
      id: id ?? UuidValue.fromString(newId()),
      tenantId: _tenant,
      name: name,
      email: email,
      pinHash: pin ? r'$argon2id$pin' : null,
      passwordHash: password ? r'$argon2id$pw' : null,
      isOwner: isOwner,
      isActive: active,
      hlc: '0',
    ),
    roleKey: role,
    roleName: roleName,
    permissions: permissionsForRole(role, isOwner: isOwner),
  );
}

/// Repositori pengguna palsu di memori: pemilik Yusuf (email + PIN), Rina
/// manajer, Sari kasir, Dimas pelayan nonaktif.
class FakeUsersRepository extends UsersRepository {
  FakeUsersRepository({
    List<StaffAccount>? accounts,
    this.pin = '123456',
    this.password = 'rahasia123',
  }) : list =
           accounts ??
           [
             sampleAccount(
               'Yusuf',
               role: 'owner',
               email: 'yusuf@contoh.id',
               password: true,
             ),
             sampleAccount('Rina', role: 'manager'),
             sampleAccount('Sari'),
             sampleAccount('Dimas', role: 'waiter', active: false),
           ];

  List<StaffAccount> list;
  final String pin;
  final String password;

  /// Role tersimpan (kunci → (nama, izin)); role bawaan tanpa baris memakai
  /// izin bawaan.
  final stored = <String, (String, Set<Permission>)>{};
  final locked = <UuidValue, Duration>{};
  final calls = <String>[];
  Exception? failNext;

  /// Staf yang bertugas untuk *Akun saya* (bawaan: pemilik).
  StaffAccount get me => list.first;

  Future<Result<T>> _run<T>(String call, T Function() body) async {
    calls.add(call);
    if (failNext case final e?) {
      failNext = null;
      return Result.error(e);
    }
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  static final _defaults = {for (final r in DefaultRole.values) r.key};

  Set<Permission> _permissions(String key) => effectivePermissions(
    roleKey: key,
    isOwner: key == DefaultRole.owner.key,
    stored: stored[key] == null ? null : encodePermissions(stored[key]!.$2),
  );

  StaffAccount _with(
    StaffAccount a, {
    String? name,
    String? roleKey,
    bool? active,
  }) {
    final key = roleKey ?? a.roleKey;
    return StaffAccount(
      staff: a.staff.copyWith(
        name: name ?? a.name,
        isActive: active ?? a.isActive,
      ),
      roleKey: key,
      roleName: _defaults.contains(key) ? null : stored[key]?.$1,
      permissions: _permissions(key),
    );
  }

  @override
  Future<Result<List<StaffAccount>>> accounts() =>
      _run('accounts', () => [for (final a in list) _with(a)]);

  @override
  Future<Result<List<RoleSummary>>> roles() => _run('roles', () {
    int count(String key) => list.where((a) => a.roleKey == key).length;
    final custom = stored.keys.where((k) => !_defaults.contains(k)).toList()
      ..sort();
    return [
      for (final r in DefaultRole.values)
        RoleSummary(
          key: r.key,
          name: null,
          permissions: _permissions(r.key),
          memberCount: count(r.key),
        ),
      for (final k in custom)
        RoleSummary(
          key: k,
          name: stored[k]!.$1,
          permissions: stored[k]!.$2,
          memberCount: count(k),
        ),
    ];
  });

  @override
  Duration? pinLockedFor(UuidValue staffId) => locked[staffId];

  @override
  Future<Result<void>> unlockPin(UuidValue staffId) =>
      _run('unlock', () => locked.remove(staffId));

  void _requireRole(String key) {
    if (key == DefaultRole.owner.key ||
        (!_defaults.contains(key) && !stored.containsKey(key))) {
      throw RoleNotFound();
    }
  }

  void _requireName(String name, {UuidValue? except}) {
    if (staffNameIssue(name) case final issue?) throw StaffNameInvalid(issue);
    if (list.any(
      (a) =>
          a.id != except && a.name.toLowerCase() == name.trim().toLowerCase(),
    )) {
      throw StaffNameTaken();
    }
  }

  @override
  Future<Result<void>> createStaff({
    required String name,
    required String roleKey,
    required String pin,
    required bool active,
  }) => _run('create:${name.trim()}:$roleKey:$pin:$active', () {
    _requireName(name);
    _requireRole(roleKey);
    list = [
      ...list,
      _with(sampleAccount(name.trim(), role: roleKey, active: active)),
    ];
  });

  @override
  Future<Result<void>> updateStaff({
    required UuidValue id,
    required String name,
    required String roleKey,
    required bool active,
  }) => _run('update:${name.trim()}:$roleKey:$active', () {
    final a = list.firstWhere((a) => a.id == id);
    if (a.isOwner) throw StaffOwnerLocked();
    _requireName(name, except: id);
    _requireRole(roleKey);
    list = [
      for (final x in list)
        x.id == id
            ? _with(x, name: name.trim(), roleKey: roleKey, active: active)
            : x,
    ];
  });

  @override
  Future<Result<void>> resetPin(UuidValue id, String pin) =>
      _run('reset:$pin', () => locked.remove(id));

  @override
  Future<Result<void>> saveMatrix(Map<String, Set<Permission>> changes) =>
      _run('matrix:${changes.keys.join(',')}', () {
        for (final MapEntry(:key, :value) in changes.entries) {
          if (key == DefaultRole.owner.key) throw StaffOwnerLocked();
          _requireRole(key);
          stored[key] = (stored[key]?.$1 ?? key, value);
        }
      });

  @override
  Future<Result<String>> createRole(String name) => _run('role:$name', () {
    if (staffNameIssue(name) case final issue?) throw RoleNameInvalid(issue);
    if (stored.values.any((r) => r.$1.toLowerCase() == name.toLowerCase())) {
      throw RoleNameTaken();
    }
    final key = roleKeyFor(name, stored.keys.toSet());
    stored[key] = (name.trim(), const {});
    return key;
  });

  @override
  Future<Result<void>> renameRole(String key, String name) =>
      _run('rename:$key:$name', () {
        final row = stored[key];
        if (row == null || _defaults.contains(key)) throw RoleNotFound();
        stored[key] = (name.trim(), row.$2);
      });

  @override
  Future<Result<void>> deleteRole(String key) => _run('delete:$key', () {
    if (list.any((a) => a.roleKey == key)) throw RoleInUse();
    stored.remove(key);
  });

  @override
  Future<Result<MyAccount>> myAccount() => _run(
    'me',
    () => MyAccount(
      name: me.name,
      roleKey: me.roleKey,
      roleName: me.roleName,
      email: me.email,
      hasPin: me.hasPin,
      hasPassword: me.hasPassword,
    ),
  );

  @override
  Future<Result<void>> changeMyPin({
    required String current,
    required String pin,
  }) => _run('my-pin:$pin', () {
    if (current != this.pin) {
      throw const WrongCurrentSecret(remainingAttempts: 4);
    }
  });

  @override
  Future<Result<void>> changeMyPassword({
    required String current,
    required String password,
  }) => _run('my-password:$password', () {
    if (current != this.password) throw const WrongCurrentSecret();
  });
}
