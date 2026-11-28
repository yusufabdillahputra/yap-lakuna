import 'dart:convert';
import 'dart:typed_data';

import 'package:cipherlib/cipherlib.dart' show AES;
import 'package:cipherlib/random.dart' show randomBytes;
import 'package:cipherlib/hashlib.dart' show HMAConBlockHashBase, sha256;
import 'package:serverpod/serverpod.dart';

/// Kunci kata sandi server untuk mengenkripsi rahasia TOTP pemilik
/// (`SERVERPOD_PASSWORD_totpEncryptionKey`, `.env` `TOTP_ENCRYPTION_KEY`).
const totpEncryptionKeyName = 'totpEncryptionKey';

/// Enkripsi rahasia TOTP di database (F2-02 aturan 13): kunci =
/// SHA-256(kata sandi), AES-256-GCM, nonce 12 byte acak, hasil
/// `base64(nonce ‖ ciphertext ‖ tag)`.
class TotpCipher {
  TotpCipher(String password)
    : _key = sha256.convert(utf8.encode(password)).bytes;

  final Uint8List _key;

  /// `null` bila [totpEncryptionKeyName] kosong atau tidak diisi.
  static TotpCipher? fromPasswords(Map<String, String?> passwords) {
    final value = passwords[totpEncryptionKeyName]?.trim() ?? '';
    return value.isEmpty ? null : TotpCipher(value);
  }

  /// [fromPasswords] dari kata sandi server sesi ini.
  static TotpCipher? fromSession(Session session) =>
      fromPasswords(session.passwords);

  String encrypt(List<int> secret) {
    final nonce = randomBytes(12);
    final sealed = AES(_key).gcm(nonce).encrypt(secret);
    return base64.encode([...nonce, ...sealed]);
  }

  /// Hash kode cadangan (HMAC-SHA256 berkunci kata sandi server), agar
  /// kode 40 bit tidak bisa ditebak dari salinan database saja.
  String backupCodeHash(String normalizedCode) =>
      sha256.hmac.by(_key).convert(utf8.encode(normalizedCode)).hex();

  /// Melempar bila teks diubah atau kunci berbeda.
  List<int> decrypt(String sealed) {
    final bytes = base64.decode(sealed);
    if (bytes.length < 12 + 16) throw StateError('Rahasia TOTP rusak');
    return AES(_key).gcm(bytes.sublist(0, 12)).decrypt(bytes.sublist(12));
  }
}
