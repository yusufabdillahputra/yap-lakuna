import 'dart:isolate';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart'
    as data
    show createStaff, updateStaff;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'session_repository.dart';
import 'store_repository.dart';
import 'users_repository.dart';

/// [UsersRepository] di atas database perangkat. Hash Argon2id dihitung di
/// isolate agar UI tetap halus.
class LocalUsersRepository extends UsersRepository {
  LocalUsersRepository(
    this._store, {
    required this._stores,
    required this._session,
    this._hasher = const CredentialHasher(),
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final CredentialHasher _hasher;

  @override
  Future<Result<List<StaffAccount>>> accounts() =>
      _manage((scope, _) => listStaffAccounts(_store, scope));

  @override
  Future<Result<List<RoleSummary>>> roles() =>
      _manage((scope, _) => listRoles(_store, scope));

  @override
  Duration? pinLockedFor(UuidValue staffId) => _session.pinRetryAfter(staffId);

  @override
  Future<Result<void>> unlockPin(UuidValue staffId) =>
      _manage((scope, staff) async {
        // Aturan yang sama dengan reset PIN: pemilik, diri sendiri, dan staf
        // berizin lebih tidak boleh dibuka kuncinya oleh selain pemilik, agar
        // batas salah PIN tidak bisa diakali.
        await requireStaffManageable(
          _store,
          scope,
          staffId: staff.id,
          targetId: staffId,
        );
        _session.unlockPin(staffId);
      });

  @override
  Future<Result<void>> createStaff({
    required String name,
    required String roleKey,
    required String pin,
    required bool active,
  }) => _manage((scope, staff) async {
    await data.createStaff(
      _store,
      scope,
      staffId: staff.id,
      name: name,
      roleKey: roleKey,
      pinHash: await _hash(pin),
      active: active,
    );
  });

  @override
  Future<Result<void>> updateStaff({
    required UuidValue id,
    required String name,
    required String roleKey,
    required bool active,
  }) => _manage((scope, staff) async {
    await data.updateStaff(
      _store,
      scope,
      staffId: staff.id,
      targetId: id,
      name: name,
      roleKey: roleKey,
      active: active,
    );
    await _session.refreshCurrent();
  });

  @override
  Future<Result<void>> resetPin(UuidValue id, String pin) =>
      _manage((scope, staff) async {
        await resetStaffPin(
          _store,
          scope,
          staffId: staff.id,
          targetId: id,
          pinHash: await _hash(pin),
        );
        _session.unlockPin(id);
      });

  @override
  Future<Result<void>> saveMatrix(Map<String, Set<Permission>> changes) =>
      _manage((scope, staff) async {
        await saveRoleMatrix(
          _store,
          scope,
          staffId: staff.id,
          changes: changes,
        );
        await _session.refreshCurrent();
      });

  @override
  Future<Result<String>> createRole(String name) =>
      _manage((scope, staff) async {
        final role = await createCustomRole(
          _store,
          scope,
          staffId: staff.id,
          name: name,
          permissions: const {},
        );
        return role.roleKey;
      });

  @override
  Future<Result<void>> renameRole(String key, String name) =>
      _manage((scope, staff) async {
        await renameCustomRole(
          _store,
          scope,
          staffId: staff.id,
          roleKey: key,
          name: name,
        );
        await _session.refreshCurrent();
      });

  @override
  Future<Result<void>> deleteRole(String key) => _manage(
    (scope, staff) =>
        deleteCustomRole(_store, scope, staffId: staff.id, roleKey: key),
  );

  @override
  Future<Result<MyAccount>> myAccount() => _self((scope, me) async {
    final staff = await findStaffById(
      _store,
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      staffId: me.id,
    );
    final row = staff?.staff;
    return MyAccount(
      name: row?.name ?? me.name,
      roleKey: me.roleKey,
      roleName: me.roleName,
      email: row?.email,
      hasPin: row?.pinHash?.isNotEmpty ?? me.hasPin,
      hasPassword: row?.passwordHash?.isNotEmpty ?? false,
    );
  });

  @override
  Future<Result<void>> changeMyPin({
    required String current,
    required String pin,
  }) => _self((scope, me) async {
    _unwrap(await _session.verifyCurrentPin(current));
    await changeOwnPin(
      _store,
      scope,
      staffId: me.id,
      pinHash: await _hash(pin),
    );
    _session.unlockPin(me.id);
  });

  @override
  Future<Result<void>> changeMyPassword({
    required String current,
    required String password,
  }) => _self((scope, me) async {
    _unwrap(await _session.verifyCurrentPassword(current));
    await changeOwnPassword(
      _store,
      scope,
      staffId: me.id,
      passwordHash: await _hash(password),
    );
  });

  /// Melempar galat verifikasi sesi sebagai [WrongCurrentSecret] (PIN/kata
  /// sandi salah) atau apa adanya (mis. `CredentialsLocked`).
  void _unwrap(Result<void> verified) {
    if (verified case Error(:final error)) {
      throw switch (error) {
        WrongPin(:final remainingAttempts) => WrongCurrentSecret(
          remainingAttempts: remainingAttempts,
        ),
        WrongCredentials() => const WrongCurrentSecret(),
        _ => error,
      };
    }
  }

  Future<String> _hash(String secret) {
    final hasher = _hasher;
    return Isolate.run(() => hasher.hash(secret));
  }

  Future<Result<T>> _self<T>(
    Future<T> Function(CatalogScope scope, StaffProfile me) body,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final me = _session.current;
    if (me == null) return const Result.error(StaffUnavailable());
    try {
      return Result.ok(await body(CatalogScope.of(ctx), me));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<T>> _manage<T>(
    Future<T> Function(CatalogScope scope, StaffProfile staff) body,
  ) async {
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.usersManage)) {
      return const Result.error(NotPermitted(Permission.usersManage));
    }
    return _self(body);
  }
}
