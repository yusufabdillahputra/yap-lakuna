import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Data akun staf yang bertugas untuk *Akun saya* (1.25b).
@immutable
class MyAccount {
  const MyAccount({
    required this.name,
    required this.roleKey,
    this.roleName,
    this.email,
    required this.hasPin,
    required this.hasPassword,
  });

  final String name;
  final String roleKey;
  final String? roleName;
  final String? email;
  final bool hasPin;
  final bool hasPassword;
}

/// PIN atau kata sandi saat ini salah (*Akun saya*), dibungkus dari
/// `WrongPin` / `WrongCredentials` sesi.
class WrongCurrentSecret implements Exception {
  const WrongCurrentSecret({this.remainingAttempts});

  /// Sisa percobaan PIN sebelum dikunci, bila diketahui.
  final int? remainingAttempts;

  @override
  String toString() => 'WrongCurrentSecret($remainingAttempts)';
}

/// Pengguna & role (F1-17). Semua aksi selain *Akun saya* butuh
/// `users:manage`, dicek di sini dan di `lakuna_data`.
abstract class UsersRepository {
  /// Staf cabang ini (aktif dan nonaktif), pemilik dulu.
  Future<Result<List<StaffAccount>>> accounts();

  /// Kolom matriks: pemilik, role bawaan, role custom.
  Future<Result<List<RoleSummary>>> roles();

  /// Sisa kunci PIN staf [staffId], `null` bila tidak dikunci.
  Duration? pinLockedFor(UuidValue staffId);

  /// Membuka kunci PIN staf [staffId].
  Future<Result<void>> unlockPin(UuidValue staffId);

  Future<Result<void>> createStaff({
    required String name,
    required String roleKey,
    required String pin,
    required bool active,
  });

  Future<Result<void>> updateStaff({
    required UuidValue id,
    required String name,
    required String roleKey,
    required bool active,
  });

  /// Reset PIN staf tanpa PIN lama; kuncinya ikut dibuka.
  Future<Result<void>> resetPin(UuidValue id, String pin);

  /// Menyimpan izin role yang berubah (kunci role → izin baru).
  Future<Result<void>> saveMatrix(Map<String, Set<Permission>> changes);

  /// Membuat role custom tanpa izin; hasilnya kunci role baru.
  Future<Result<String>> createRole(String name);

  Future<Result<void>> renameRole(String key, String name);

  Future<Result<void>> deleteRole(String key);

  /// Akun staf yang bertugas (tanpa izin khusus).
  Future<Result<MyAccount>> myAccount();

  /// Mengganti PIN sendiri; [current] diperiksa dengan kunci login. Gagal
  /// dengan [WrongCurrentSecret] atau `CredentialsLocked`.
  Future<Result<void>> changeMyPin({
    required String current,
    required String pin,
  });

  /// Mengganti kata sandi sendiri (akun yang punya kata sandi).
  Future<Result<void>> changeMyPassword({
    required String current,
    required String password,
  });
}
