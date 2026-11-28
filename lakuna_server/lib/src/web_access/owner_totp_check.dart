import 'package:lakuna_domain/lakuna_domain.dart'
    show matchTotp, normalizeBackupCode;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'totp_cipher.dart';

/// Kode salah berturut-turut sebelum login web dikunci (aturan 13).
const maxSecondFactorAttempts = 5;

/// Lama kunci setelah [maxSecondFactorAttempts] kode salah.
const secondFactorLockout = Duration(minutes: 15);

/// Kunci enkripsi TOTP server, atau [WebAccessException] `totpKeyMissing`.
TotpCipher requireTotpCipher(Session session) =>
    TotpCipher.fromSession(session) ??
    (throw WebAccessException(failure: WebAccessFailure.totpKeyMissing));

/// Memeriksa faktor kedua akun [authUserId] lalu menjalankan [onVerified]
/// dalam transaksi yang sama (F2-02 aturan 13–14).
///
/// Baris `owner_totp` dikunci `FOR UPDATE`, jadi dua permintaan dengan kode
/// sama berurutan dan hanya satu yang lolos. Kode 6 digit dicocokkan dengan
/// TOTP (langkah ≤ `last_used_step` ditolak); selain itu, bila TOTP sudah
/// aktif, dicocokkan dengan kode cadangan yang belum dipakai.
///
/// [confirming] = mengonfirmasi rahasia baru: hanya TOTP, rahasia harus
/// belum dikonfirmasi, dan `confirmed_at` diisi saat cocok.
///
/// Kode salah menaikkan hitungan; ke-[maxSecondFactorAttempts] mengunci
/// [secondFactorLockout]. Hitungan disimpan (transaksi selesai) sebelum
/// [WebAccessException] dilempar.
Future<T> withOwnerSecondFactor<T>(
  Session session,
  UuidValue authUserId,
  String code, {
  required TotpCipher cipher,
  required Future<T> Function(Transaction tx) onVerified,
  bool confirming = false,
  DateTime? now,
}) async {
  final at = (now ?? DateTime.now()).toUtc();
  final outcome = await session.db.transaction<(T?, WebAccessException?)>((
    tx,
  ) async {
    final row = await OwnerTotp.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (row == null) {
      return (
        null,
        WebAccessException(failure: WebAccessFailure.totpNotEnabled),
      );
    }
    final confirmed = row.confirmedAt != null;
    if (confirming && confirmed) {
      return (
        null,
        WebAccessException(failure: WebAccessFailure.totpAlreadyEnabled),
      );
    }
    if (!confirming && !confirmed) {
      return (
        null,
        WebAccessException(failure: WebAccessFailure.totpNotEnabled),
      );
    }
    final lockedUntil = row.lockedUntil;
    if (lockedUntil != null && lockedUntil.isAfter(at)) {
      return (
        null,
        WebAccessException(
          failure: WebAccessFailure.locked,
          lockedUntil: lockedUntil,
        ),
      );
    }

    final step = matchTotp(
      cipher.decrypt(row.secretEncrypted),
      code,
      at,
      lastUsedStep: row.lastUsedStep,
    );
    var verified = step != null;
    if (!verified && !confirming) {
      final hash = cipher.backupCodeHash(normalizeBackupCode(code));
      final backup = await OwnerBackupCode.db.findFirstRow(
        session,
        where: (b) =>
            b.authUserId.equals(authUserId) &
            b.codeHash.equals(hash) &
            b.usedAt.equals(null),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (backup != null) {
        await OwnerBackupCode.db.updateRow(
          session,
          backup.copyWith(usedAt: at),
          transaction: tx,
        );
        verified = true;
      }
    }

    if (!verified) {
      final attempts = row.failedAttempts + 1;
      final lock = attempts >= maxSecondFactorAttempts;
      final until = at.add(secondFactorLockout);
      await OwnerTotp.db.updateRow(
        session,
        row.copyWith(
          failedAttempts: lock ? 0 : attempts,
          lockedUntil: lock ? until : row.lockedUntil,
          updatedAt: at,
        ),
        transaction: tx,
      );
      return (
        null,
        lock
            ? WebAccessException(
                failure: WebAccessFailure.locked,
                lockedUntil: until,
              )
            : WebAccessException(failure: WebAccessFailure.totpInvalid),
      );
    }

    await OwnerTotp.db.updateRow(
      session,
      row.copyWith(
        failedAttempts: 0,
        lastUsedStep: step ?? row.lastUsedStep,
        confirmedAt: confirming ? at : row.confirmedAt,
        updatedAt: at,
      ),
      transaction: tx,
    );
    return (await onVerified(tx), null);
  });
  final (result, failure) = outcome;
  if (failure != null) throw failure;
  return result as T;
}
