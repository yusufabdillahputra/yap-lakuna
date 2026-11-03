import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'repository_errors.dart';

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
  /// Masa berlaku persetujuan manajer setelah PIN-nya diperiksa: cukup untuk
  /// mengisi alasan void.
  static const approvalTtl = Duration(minutes: 2);

  /// Jam untuk masa berlaku persetujuan (bisa diganti di tes).
  @visibleForTesting
  DateTime Function() approvalClock = DateTime.now;

  final _approvals = <(UuidValue, Permission), DateTime>{};

  /// Mencatat persetujuan [staffId] untuk [permission]; dipanggil
  /// [verifyApprover] setelah PIN dan izin benar.
  @protected
  void grantApproval(UuidValue staffId, Permission permission) =>
      _approvals[(staffId, permission)] = approvalClock().add(approvalTtl);

  /// Apakah [staffId] baru saja menyetujui [permission] dengan PIN-nya dan
  /// persetujuan itu belum dipakai atau kedaluwarsa. Repositori memeriksa ini
  /// sebelum menerima `approverId`, agar id staf saja tidak cukup.
  bool hasApproval(UuidValue staffId, Permission permission) {
    final until = _approvals[(staffId, permission)];
    if (until == null) return false;
    if (approvalClock().isAfter(until)) {
      _approvals.remove((staffId, permission));
      return false;
    }
    return true;
  }

  /// Menghabiskan persetujuan setelah aksinya berhasil (sekali pakai).
  void consumeApproval(UuidValue staffId, Permission permission) =>
      _approvals.remove((staffId, permission));

  /// Menghapus semua persetujuan (mis. saat ganti kasir).
  @protected
  void clearApprovals() => _approvals.clear();

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

  /// Persetujuan manajer (F1-11): memeriksa PIN staf [staffId] dengan kunci
  /// yang sama dengan login, lalu izin [permission]-nya. Sesi yang berjalan
  /// tidak berubah. Berhasil mencatat persetujuan sekali pakai (lihat
  /// [hasApproval]). Gagal dengan [WrongPin], [CredentialsLocked],
  /// [StaffUnavailable], atau [NotPermitted].
  Future<Result<StaffProfile>> verifyApprover(
    UuidValue staffId,
    String pin,
    Permission permission,
  );

  /// Memulai sesi pemilik tanpa PIN, tepat setelah setup toko (F1-01).
  void startOwnerSession(StoreContext context);

  /// Mengakhiri sesi (*Ganti kasir*).
  void logout();
}

/// Kunci [PinGuard] untuk PIN staf [staffId].
String pinGuardKey(UuidValue staffId) => 'pin:${staffId.uuid}';

/// Kunci [PinGuard] untuk login pemilik dengan [email].
String passwordGuardKey(String email) => 'email:${email.trim().toLowerCase()}';
