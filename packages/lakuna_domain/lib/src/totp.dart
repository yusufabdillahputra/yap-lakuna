import 'dart:math';

import 'package:hashlib/hashlib.dart' show HMAConBlockHashBase, sha1;

/// Kode sekali pakai berbasis waktu (TOTP, RFC 6238) untuk login web pemilik
/// (F2-02 aturan 12): SHA-1, 6 digit, langkah 30 detik, rahasia 160 bit.

/// Panjang langkah TOTP dalam detik.
const totpPeriodSeconds = 30;

/// Jumlah digit kode TOTP.
const totpDigits = 6;

/// Panjang rahasia TOTP dalam byte (160 bit).
const totpSecretLength = 20;

/// Jumlah kode cadangan yang dibuat saat TOTP diaktifkan.
const backupCodeCount = 8;

/// Langkah TOTP untuk waktu [t] (detik epoch dibagi 30).
int totpStep(DateTime t) =>
    t.millisecondsSinceEpoch ~/ 1000 ~/ totpPeriodSeconds;

/// Kode TOTP untuk [secret] pada langkah [step] (RFC 4226 dynamic
/// truncation), nol di depan dipertahankan.
String totpCode(List<int> secret, int step, {int digits = totpDigits}) {
  final counter = List<int>.filled(8, 0);
  var v = step;
  for (var i = 7; i >= 0; i--) {
    counter[i] = v % 256;
    v = v ~/ 256;
  }
  final h = sha1.hmac.by(secret).convert(counter).bytes;
  final o = h[h.length - 1] & 0x0f;
  final bin =
      ((h[o] & 0x7f) * 0x1000000) +
      ((h[o + 1] & 0xff) * 0x10000) +
      ((h[o + 2] & 0xff) * 0x100) +
      (h[o + 3] & 0xff);
  var mod = 1;
  for (var i = 0; i < digits; i++) {
    mod *= 10;
  }
  return (bin % mod).toString().padLeft(digits, '0');
}

final _sixDigits = RegExp(r'^\d{6}$');

/// Langkah yang cocok dengan [code] di jendela `step-1..step+1` dari [now],
/// atau `null` bila salah atau langkahnya ≤ [lastUsedStep] (kode sudah
/// dipakai). Spasi di [code] diabaikan.
int? matchTotp(
  List<int> secret,
  String code,
  DateTime now, {
  int? lastUsedStep,
}) {
  final c = code.replaceAll(RegExp(r'\s'), '');
  if (!_sixDigits.hasMatch(c)) return null;
  final step = totpStep(now);
  for (final s in [step - 1, step, step + 1]) {
    if (lastUsedStep != null && s <= lastUsedStep) continue;
    if (_constantTimeEquals(totpCode(secret, s), c)) return s;
  }
  return null;
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}

const _base32Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

/// Base32 RFC 4648 tanpa padding.
String base32Encode(List<int> bytes) {
  final out = StringBuffer();
  var buffer = 0;
  var bits = 0;
  for (final b in bytes) {
    buffer = ((buffer << 8) | (b & 0xff)) & 0xffff;
    bits += 8;
    while (bits >= 5) {
      out.write(_base32Alphabet[(buffer >> (bits - 5)) & 31]);
      bits -= 5;
    }
  }
  if (bits > 0) out.write(_base32Alphabet[(buffer << (5 - bits)) & 31]);
  return out.toString();
}

/// Kebalikan [base32Encode]; huruf kecil, spasi, dan `=` diabaikan.
/// `null` bila ada karakter di luar alfabet base32.
List<int>? base32Decode(String s) {
  final clean = s.toUpperCase().replaceAll(RegExp(r'[\s=]'), '');
  final out = <int>[];
  var buffer = 0;
  var bits = 0;
  for (final ch in clean.split('')) {
    final v = _base32Alphabet.indexOf(ch);
    if (v < 0) return null;
    buffer = ((buffer << 5) | v) & 0xffff;
    bits += 5;
    if (bits >= 8) {
      out.add((buffer >> (bits - 8)) & 0xff);
      bits -= 8;
    }
  }
  return out;
}

/// URI `otpauth://` untuk QR aplikasi authenticator.
String otpauthUri({required String email, required String secretBase32}) =>
    'otpauth://totp/Lakuna:${Uri.encodeComponent(email)}'
    '?secret=$secretBase32&issuer=Lakuna&algorithm=SHA1'
    '&digits=$totpDigits&period=$totpPeriodSeconds';

/// Rahasia TOTP baru (160 bit). Pemanggil memberi `Random.secure()`.
List<int> newTotpSecret(Random random) =>
    List.generate(totpSecretLength, (_) => random.nextInt(256));

/// Huruf kode cadangan: tanpa `0 O 1 I L` agar tidak tertukar saat diketik.
const _backupAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

/// [backupCodeCount] kode cadangan unik berpola `XXXX-XXXX`. Pemanggil
/// memberi `Random.secure()`.
List<String> newBackupCodes(Random random) {
  final codes = <String>{};
  while (codes.length < backupCodeCount) {
    final chars = List.generate(
      8,
      (_) => _backupAlphabet[random.nextInt(_backupAlphabet.length)],
    ).join();
    codes.add('${chars.substring(0, 4)}-${chars.substring(4)}');
  }
  return codes.toList();
}

/// Bentuk baku kode cadangan ketikan pengguna: huruf besar, tanpa spasi,
/// tanda hubung di tengah bila panjangnya 8.
String normalizeBackupCode(String s) {
  final c = s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  return c.length == 8 ? '${c.substring(0, 4)}-${c.substring(4)}' : c;
}
