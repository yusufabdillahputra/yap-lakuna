import 'dart:isolate';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'repository_errors.dart';
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

  /// Percobaan yang sedang berjalan per kunci [PinGuard]. Percobaan untuk
  /// kunci yang sama diantrekan agar pemeriksaan kunci dan pencatatan gagal
  /// tidak bisa disalip percobaan lain (mis. dialog persetujuan manajer).
  final _pending = <String, Future<void>>{};

  /// Hash tiruan untuk email tak dikenal, agar waktu responsnya setara dengan
  /// email terdaftar.
  Future<String>? _dummyHash;

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
  Duration? pinRetryAfter(UuidValue staffId) =>
      _guard.retryAfter(pinGuardKey(staffId));

  @override
  Duration? passwordRetryAfter(String email) =>
      _guard.retryAfter(passwordGuardKey(email));

  @override
  Future<Result<StaffProfile>> loginWithPin(UuidValue staffId, String pin) =>
      _serialized(
        pinGuardKey(staffId),
        () => _checkPin(staffId, pin, (key, staff) => _signIn(key, staff)),
      );

  @override
  Future<Result<StaffProfile>> verifyApprover(
    UuidValue staffId,
    String pin,
    Permission permission,
  ) => _serialized(
    pinGuardKey(staffId),
    () => _checkPin(staffId, pin, (key, staff) {
      _guard.recordSuccess(key);
      if (!staff.permissions.contains(permission)) {
        return Result.error(NotPermitted(permission));
      }
      return Result.ok(StaffProfile.fromOutletStaff(staff));
    }),
  );

  /// Memeriksa PIN [staffId] dengan [PinGuard]; PIN benar → [onMatch].
  Future<Result<StaffProfile>> _checkPin(
    UuidValue staffId,
    String pin,
    Result<StaffProfile> Function(String key, OutletStaff staff) onMatch,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StaffUnavailable());
    final key = pinGuardKey(staffId);
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
      if (await _verify(pin, hash)) return onMatch(key, staff);
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
  ) => _serialized(
    passwordGuardKey(email),
    () => _loginWithPassword(email, password),
  );

  Future<Result<StaffProfile>> _loginWithPassword(
    String email,
    String password,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(WrongCredentials());
    final key = passwordGuardKey(email);
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
      if (owner == null || hash == null || hash.isEmpty) {
        // Tetap menjalankan Argon2id agar waktu respons tidak membocorkan
        // email mana yang terdaftar.
        await _verify(password, await (_dummyHash ??= _hashDummy()));
      } else if (await _verify(password, hash)) {
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
      hasPin: owner.pinHash?.isNotEmpty ?? false,
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

  /// Menjalankan [body] setelah percobaan sebelumnya untuk [key] selesai.
  Future<T> _serialized<T>(String key, Future<T> Function() body) {
    final previous = _pending[key] ?? Future<void>.value();
    final result = previous.then((_) => body());
    final done = result.then<void>((_) {}, onError: (Object _) {});
    _pending[key] = done;
    done.whenComplete(() {
      if (identical(_pending[key], done)) _pending.remove(key);
    });
    return result;
  }

  Future<String> _hashDummy() {
    final hasher = _hasher;
    return Isolate.run(() => hasher.hash('lakuna-email-tidak-dikenal'));
  }

  /// Argon2id sengaja lambat; verifikasi di isolate agar UI tetap halus.
  Future<bool> _verify(String secret, String hash) {
    final hasher = _hasher;
    return Isolate.run(() => hasher.verify(secret, hash));
  }
}
