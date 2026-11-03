import 'dart:convert';

import 'package:hashlib/hashlib.dart';
import 'package:hashlib/random.dart' show randomBytes;

/// Hash kata sandi dan PIN dengan Argon2id (string PHC). Teks asli tidak
/// pernah disimpan. Parameter bawaan mengikuti rekomendasi OWASP:
/// memori 19 MiB, 2 iterasi, paralelisme 1, salt acak 16 byte.
class CredentialHasher {
  const CredentialHasher() : _security = _owasp;

  /// Parameter ringan, hanya untuk tes.
  const CredentialHasher.forTesting() : _security = _light;

  static const _owasp = Argon2Security('lakuna', m: 19456, t: 2, p: 1);
  static const _light = Argon2Security('lakuna-test', m: 256, t: 1, p: 1);

  final Argon2Security _security;

  /// Hash baru dengan salt acak.
  String hash(String secret) => argon2id(
    utf8.encode(secret),
    randomBytes(16),
    hashLength: 32,
    security: _security,
  ).encoded();

  /// `true` bila [secret] cocok dengan [encoded]. Hash rusak = `false`.
  bool verify(String secret, String encoded) {
    if (!encoded.startsWith(r'$argon2id$')) return false;
    try {
      return argon2Verify(encoded, utf8.encode(secret));
    } on Object {
      return false;
    }
  }
}
