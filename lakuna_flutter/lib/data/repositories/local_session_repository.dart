import 'dart:isolate';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [SessionRepository] yang memverifikasi hash Argon2id di database
/// perangkat. Sesi dan [PinGuard] hanya di memori.
class LocalSessionRepository extends SessionRepository {
  LocalSessionRepository(
    this._store, {
    required this._stores,
    this._hasher = const CredentialHasher(),
    PinGuard? guard,
  }) : _guard = guard ?? PinGuard();

  final LakunaStore _store;
  final StoreRepository _stores;
  final CredentialHasher _hasher;
  final PinGuard _guard;
  StaffProfile? _current;

  @override
  StaffProfile? get current => _current;

  @override
  Future<Result<List<StaffProfile>>> listStaff() async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.ok([]);
    try {
      final staff = await listOutletStaff(
        _store,
        tenantId: ctx.tenant.id,
        outletId: ctx.outlet.id,
      );
      return Result.ok(staff.map(StaffProfile.fromOutletStaff).toList());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<StaffProfile>> loginWithPin(
    UuidValue staffId,
    String pin,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StaffUnavailable());
    final key = 'pin:${staffId.uuid}';
    if (_guard.retryAfter(key) case final wait?) {
      return Result.error(CredentialsLocked(wait));
    }
    try {
      final staff = await findStaffById(
        _store,
        tenantId: ctx.tenant.id,
        outletId: ctx.outlet.id,
        staffId: staffId,
      );
      final hash = staff?.staff.pinHash;
      if (staff == null || hash == null || hash.isEmpty) {
        return const Result.error(StaffUnavailable());
      }
      if (await _verify(pin, hash)) return _signIn(key, staff);
      _guard.recordFailure(key);
      if (_guard.retryAfter(key) case final wait?) {
        return Result.error(CredentialsLocked(wait));
      }
      return Result.error(WrongPin(_guard.remainingAttempts(key)));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<StaffProfile>> loginWithPassword(
    String email,
    String password,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(WrongCredentials());
    final key = 'email:${email.trim().toLowerCase()}';
    if (_guard.retryAfter(key) case final wait?) {
      return Result.error(CredentialsLocked(wait));
    }
    try {
      final owner = await findOwnerByEmail(
        _store,
        tenantId: ctx.tenant.id,
        outletId: ctx.outlet.id,
        email: email,
      );
      final hash = owner?.staff.passwordHash;
      if (owner != null &&
          hash != null &&
          hash.isNotEmpty &&
          await _verify(password, hash)) {
        return _signIn(key, owner);
      }
      // Email tidak dikenal diperlakukan sama dengan kata sandi salah agar
      // tidak membocorkan email yang terdaftar.
      _guard.recordFailure(key);
      if (_guard.retryAfter(key) case final wait?) {
        return Result.error(CredentialsLocked(wait));
      }
      return const Result.error(WrongCredentials());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  void startOwnerSession(StoreContext context) {
    final owner = context.owner;
    _current = StaffProfile(
      id: owner.id,
      name: owner.name,
      roleKey: DefaultRole.owner.key,
      isOwner: true,
      hasPin: owner.pinHash != null,
      permissions: permissionsForRole(DefaultRole.owner.key, isOwner: true),
    );
    notifyListeners();
  }

  @override
  void logout() {
    if (_current == null) return;
    _current = null;
    notifyListeners();
  }

  Result<StaffProfile> _signIn(String key, OutletStaff staff) {
    _guard.recordSuccess(key);
    final profile = StaffProfile.fromOutletStaff(staff);
    _current = profile;
    notifyListeners();
    return Result.ok(profile);
  }

  /// Argon2id sengaja lambat; verifikasi di isolate agar UI tetap halus.
  Future<bool> _verify(String secret, String hash) {
    final hasher = _hasher;
    return Isolate.run(() => hasher.verify(secret, hash));
  }
}
