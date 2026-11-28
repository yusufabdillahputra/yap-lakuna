import 'dart:math';

import 'package:lakuna_domain/lakuna_domain.dart'
    show base32Encode, newBackupCodes, newTotpSecret, otpauthUri;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart'
    show AuthenticationInfoAuthUserId;
import 'package:serverpod_auth_idp_server/providers/email.dart'
    show EmailAccount;

import '../generated/protocol.dart';
import '../sync/device_auth.dart' show authenticateDevice;
import 'owner_totp_check.dart';

/// Verifikasi 2 langkah akun pemilik untuk login web (F2-02 aturan 12–14),
/// diatur dari kartu *Versi hosting* di aplikasi perangkat.
class TotpEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// `true` bila TOTP akun ini sudah dikonfirmasi.
  Future<bool> status(Session session) async {
    final row = await OwnerTotp.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(_user(session)),
    );
    return row?.confirmedAt != null;
  }

  /// Rahasia baru yang belum berlaku sampai [confirm]. Menimpa rahasia lama
  /// yang belum dikonfirmasi; ditolak bila TOTP sudah aktif.
  ///
  /// [deviceToken] = token perangkat toko milik akun ini: kata sandi saja
  /// tidak cukup untuk mengaktifkan verifikasi 2 langkah, karena siapa pun
  /// yang mengaktifkannya bisa membuka toko di web (review C1).
  Future<TotpEnrollment> begin(Session session, String deviceToken) async {
    final user = await _owner(session, deviceToken);
    final cipher = requireTotpCipher(session);
    final secret = newTotpSecret(Random.secure());
    final secretBase32 = base32Encode(secret);
    final now = DateTime.now().toUtc();
    await session.db.transaction((tx) async {
      final row = await OwnerTotp.db.findFirstRow(
        session,
        where: (t) => t.authUserId.equals(user),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (row?.confirmedAt != null) {
        throw WebAccessException(failure: WebAccessFailure.totpAlreadyEnabled);
      }
      final fresh = OwnerTotp(
        authUserId: user,
        secretEncrypted: cipher.encrypt(secret),
        createdAt: now,
        updatedAt: now,
      );
      if (row == null) {
        await OwnerTotp.db.insertRow(session, fresh, transaction: tx);
      } else {
        await OwnerTotp.db.updateRow(
          session,
          fresh.copyWith(id: row.id, createdAt: row.createdAt),
          transaction: tx,
        );
      }
    });
    final account = await EmailAccount.db.findFirstRow(
      session,
      where: (a) => a.authUserId.equals(user),
    );
    return TotpEnrollment(
      secretBase32: secretBase32,
      otpauthUri: otpauthUri(
        email: account?.email ?? 'pemilik',
        secretBase32: secretBase32,
      ),
    );
  }

  /// Mengonfirmasi rahasia dari [begin] dengan satu kode; membalas 8 kode
  /// cadangan (ditampilkan sekali, server menyimpan hash-nya).
  Future<List<String>> confirm(
    Session session,
    String deviceToken,
    String code,
  ) async {
    final user = await _owner(session, deviceToken);
    final cipher = requireTotpCipher(session);
    final codes = newBackupCodes(Random.secure());
    await withOwnerSecondFactor<void>(
      session,
      user,
      code,
      cipher: cipher,
      confirming: true,
      onVerified: (tx) async {
        await OwnerBackupCode.db.deleteWhere(
          session,
          where: (b) => b.authUserId.equals(user),
          transaction: tx,
        );
        await OwnerBackupCode.db.insert(session, [
          for (final c in codes)
            OwnerBackupCode(
              authUserId: user,
              codeHash: cipher.backupCodeHash(c),
            ),
        ], transaction: tx);
      },
    );
    return codes;
  }

  /// Mematikan TOTP dengan kode authenticator atau kode cadangan (aturan
  /// 14); rahasia dan kode cadangan dihapus.
  Future<void> disable(
    Session session,
    String deviceToken,
    String code,
  ) async {
    final user = await _owner(session, deviceToken);
    await withOwnerSecondFactor<void>(
      session,
      user,
      code,
      cipher: requireTotpCipher(session),
      onVerified: (tx) async {
        await OwnerTotp.db.deleteWhere(
          session,
          where: (t) => t.authUserId.equals(user),
          transaction: tx,
        );
        await OwnerBackupCode.db.deleteWhere(
          session,
          where: (b) => b.authUserId.equals(user),
          transaction: tx,
        );
      },
    );
  }

  UuidValue _user(Session session) => session.authenticated!.authUserId;

  /// Akun login yang tercatat sebagai pemilik tenant perangkat
  /// [deviceToken]. Token salah atau kedaluwarsa melempar
  /// [SyncAuthException] dari [authenticateDevice].
  Future<UuidValue> _owner(Session session, String deviceToken) async {
    final user = _user(session);
    final auth = await authenticateDevice(session, deviceToken);
    final owned = await TenantOwner.db.count(
      session,
      where: (o) =>
          o.authUserId.equals(user) & o.tenantId.equals(auth.tenantId),
    );
    if (owned == 0) {
      throw WebAccessException(failure: WebAccessFailure.notOwner);
    }
    return user;
  }
}
