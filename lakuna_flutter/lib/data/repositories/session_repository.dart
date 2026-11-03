import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

/// Staf yang tampil di layar login atau sedang bertugas. Tidak membawa hash
/// PIN/kata sandi.
@immutable
class StaffProfile {
  const StaffProfile({
    required this.id,
    required this.name,
    required this.roleKey,
    required this.isOwner,
    required this.hasPin,
    required this.permissions,
  });

  factory StaffProfile.fromOutletStaff(OutletStaff s) => StaffProfile(
    id: s.id,
    name: s.name,
    roleKey: s.roleKey,
    isOwner: s.isOwner,
    hasPin: s.hasPin,
    permissions: s.permissions,
  );

  final UuidValue id;
  final String name;
  final String roleKey;
  final bool isOwner;
  final bool hasPin;
  final Set<Permission> permissions;

  bool can(Permission permission) => permissions.contains(permission);
}

/// PIN salah; [remainingAttempts] percobaan lagi sebelum dikunci.
class WrongPin implements Exception {
  const WrongPin(this.remainingAttempts);

  final int remainingAttempts;

  @override
  String toString() => 'WrongPin(sisa $remainingAttempts)';
}

/// Terlalu banyak percobaan salah; coba lagi setelah [retryAfter].
class CredentialsLocked implements Exception {
  const CredentialsLocked(this.retryAfter);

  final Duration retryAfter;

  @override
  String toString() => 'CredentialsLocked(${retryAfter.inSeconds} detik)';
}

/// Email atau kata sandi pemilik salah.
class WrongCredentials implements Exception {
  const WrongCredentials();

  @override
  String toString() => 'WrongCredentials';
}

/// Staf tidak lagi aktif di cabang ini atau belum punya PIN.
class StaffUnavailable implements Exception {
  const StaffUnavailable();

  @override
  String toString() => 'StaffUnavailable';
}

/// Sesi staf yang sedang bertugas di perangkat ini (F1-02). Router
/// mendengarkan [current]: selama `null`, aplikasi menampilkan layar login.
abstract class SessionRepository extends ChangeNotifier {
  /// Staf yang sedang bertugas, atau `null` bila belum login.
  StaffProfile? get current;

  /// Staf aktif di cabang perangkat ini, pemilik dulu.
  Future<Result<List<StaffProfile>>> listStaff();

  /// Login dengan PIN 6 digit. Gagal dengan [WrongPin], [CredentialsLocked],
  /// atau [StaffUnavailable].
  Future<Result<StaffProfile>> loginWithPin(UuidValue staffId, String pin);

  /// Login pemilik dengan email dan kata sandi. Gagal dengan
  /// [WrongCredentials] atau [CredentialsLocked].
  Future<Result<StaffProfile>> loginWithPassword(String email, String password);

  /// Sisa kunci PIN staf [staffId], atau `null` bila tidak dikunci.
  Duration? pinRetryAfter(UuidValue staffId);

  /// Sisa kunci login pemilik dengan [email], atau `null`.
  Duration? passwordRetryAfter(String email);

  /// Memulai sesi pemilik tanpa PIN, tepat setelah setup toko (F1-01).
  void startOwnerSession(StoreContext context);

  /// Mengakhiri sesi (*Ganti kasir*).
  void logout();
}

/// Kunci [PinGuard] untuk PIN staf [staffId].
String pinGuardKey(UuidValue staffId) => 'pin:${staffId.uuid}';

/// Kunci [PinGuard] untuk login pemilik dengan [email].
String passwordGuardKey(String email) => 'email:${email.trim().toLowerCase()}';
