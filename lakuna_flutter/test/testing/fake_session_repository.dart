import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// Profil staf contoh untuk tes.
StaffProfile sampleStaff({
  String name = 'Yusuf',
  String role = 'owner',
  bool hasPin = true,
}) {
  final isOwner = role == DefaultRole.owner.key;
  return StaffProfile(
    id: UuidValue.fromString(newId()),
    name: name,
    roleKey: role,
    isOwner: isOwner,
    hasPin: hasPin,
    permissions: permissionsForRole(role, isOwner: isOwner),
  );
}

/// Repositori sesi palsu: setiap staf memakai [pin] yang sama, pemilik
/// memakai [email] + [password]. Kunci memakai [PinGuard] dengan jam tes.
class FakeSessionRepository extends SessionRepository {
  FakeSessionRepository({
    List<StaffProfile>? staff,
    this.current,
    this.pin = '123456',
    this.email = 'yusuf@contoh.id',
    this.password = 'rahasia123',
    PinGuard? guard,
  }) : staff = staff ?? [sampleStaff()],
       guard = guard ?? PinGuard();

  List<StaffProfile> staff;
  final String pin;
  final String email;
  final String password;
  final PinGuard guard;
  final pinAttempts = <String>[];
  var listCalls = 0;

  @override
  StaffProfile? current;

  @override
  Future<Result<List<StaffProfile>>> listStaff() async {
    listCalls++;
    return Result.ok(List.of(staff));
  }

  @override
  Future<Result<StaffProfile>> loginWithPin(UuidValue staffId, String pin) =>
      _attempt(pinGuardKey(staffId), () {
        pinAttempts.add(pin);
        final s = staff.where((s) => s.id == staffId).firstOrNull;
        if (s == null || !s.hasPin) throw const StaffUnavailable();
        return pin == this.pin ? s : null;
      }, (left) => WrongPin(left));

  @override
  Future<Result<StaffProfile>> loginWithPassword(
    String email,
    String password,
  ) => _attempt(passwordGuardKey(email), () {
    if (email.trim().toLowerCase() != this.email || password != this.password) {
      return null;
    }
    return staff.firstWhere((s) => s.isOwner);
  }, (_) => const WrongCredentials());

  Future<Result<StaffProfile>> _attempt(
    String key,
    StaffProfile? Function() check,
    Exception Function(int remaining) wrong,
  ) async {
    if (guard.retryAfter(key) case final wait?) {
      return Result.error(CredentialsLocked(wait));
    }
    final StaffProfile? s;
    try {
      s = check();
    } on Exception catch (e) {
      return Result.error(e);
    }
    if (s != null) {
      guard.recordSuccess(key);
      current = s;
      notifyListeners();
      return Result.ok(s);
    }
    guard.recordFailure(key);
    if (guard.retryAfter(key) case final wait?) {
      return Result.error(CredentialsLocked(wait));
    }
    return Result.error(wrong(guard.remainingAttempts(key)));
  }

  /// Percobaan persetujuan (staf, PIN, izin), untuk tes.
  final approvals = <(UuidValue, String, Permission)>[];

  @override
  Future<Result<StaffProfile>> verifyApprover(
    UuidValue staffId,
    String pin,
    Permission permission,
  ) async {
    approvals.add((staffId, pin, permission));
    final key = pinGuardKey(staffId);
    if (guard.retryAfter(key) case final wait?) {
      return Result.error(CredentialsLocked(wait));
    }
    final s = staff.where((s) => s.id == staffId).firstOrNull;
    if (s == null || !s.hasPin) return const Result.error(StaffUnavailable());
    if (pin != this.pin) {
      guard.recordFailure(key);
      if (guard.retryAfter(key) case final wait?) {
        return Result.error(CredentialsLocked(wait));
      }
      return Result.error(WrongPin(guard.remainingAttempts(key)));
    }
    guard.recordSuccess(key);
    if (!s.can(permission)) return Result.error(NotPermitted(permission));
    grantApproval(staffId, permission);
    return Result.ok(s);
  }

  @override
  Duration? pinRetryAfter(UuidValue staffId) =>
      guard.retryAfter(pinGuardKey(staffId));

  @override
  Duration? passwordRetryAfter(String email) =>
      guard.retryAfter(passwordGuardKey(email));

  @override
  void startOwnerSession(StoreContext context) {
    current = staff.firstWhere((s) => s.isOwner);
    notifyListeners();
  }

  @override
  void logout() {
    clearApprovals();
    current = null;
    notifyListeners();
  }
}

/// Staf contoh dengan izin tertentu (role kustom, mewakili F1-17).
StaffProfile staffWithPermissions(
  Set<Permission> permissions, {
  String name = 'Sari',
}) => StaffProfile(
  id: UuidValue.fromString(newId()),
  name: name,
  roleKey: 'custom',
  isOwner: false,
  hasPin: true,
  permissions: permissions,
);
