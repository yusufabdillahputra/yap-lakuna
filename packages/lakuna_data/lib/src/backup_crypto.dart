import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show Hmac, sha256;

import 'backup.dart' show BackupInvalid;

// Kunci backup dengan kata sandi (F1-19c). Isi zip dienkripsi AES-256
// (WinZip AE-1) oleh paket `archive`; kata sandi zip-nya adalah kunci
// turunan PBKDF2-HMAC-SHA256 dari kata sandi pengguna, dengan parameter di
// komentar zip yang tidak terenkripsi.

/// Iterasi PBKDF2 untuk backup baru.
const backupKdfIterations = 310000;

/// Batas iterasi yang diterima dari berkas: berkas rusak tidak boleh
/// membuat aplikasi macet berjam-jam.
const backupKdfMinIterations = 10000;
const backupKdfMaxIterations = 2000000;

const _saltLength = 16;
const _keyLength = 32;
const _prefix = 'lakuna-kunci';

/// PBKDF2-HMAC-SHA256 (RFC 8018) dengan `package:crypto`.
Uint8List pbkdf2Sha256(
  List<int> password,
  List<int> salt,
  int iterations,
  int length,
) {
  if (iterations < 1 || length < 1) throw ArgumentError('pbkdf2');
  final hmac = Hmac(sha256, password);
  final out = Uint8List(length);
  var offset = 0;
  for (var block = 1; offset < length; block++) {
    var u = hmac.convert([
      ...salt,
      (block >> 24) & 0xff,
      (block >> 16) & 0xff,
      (block >> 8) & 0xff,
      block & 0xff,
    ]).bytes;
    final t = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    final take = min(t.length, length - offset);
    out.setRange(offset, offset + take, t);
    offset += take;
  }
  return out;
}

/// Parameter kunci backup, ditulis di komentar zip:
/// `lakuna-kunci:1:pbkdf2-sha256:<iterasi>:<salt base64url>`.
class BackupLock {
  BackupLock({required this.salt, required this.iterations});

  /// Kunci baru dengan salt acak.
  factory BackupLock.create({int iterations = backupKdfIterations}) {
    if (iterations < backupKdfMinIterations ||
        iterations > backupKdfMaxIterations) {
      throw ArgumentError.value(iterations, 'iterations');
    }
    final random = Random.secure();
    return BackupLock(
      salt: Uint8List.fromList(
        List.generate(_saltLength, (_) => random.nextInt(256)),
      ),
      iterations: iterations,
    );
  }

  final Uint8List salt;
  final int iterations;

  String toComment() =>
      '$_prefix:1:pbkdf2-sha256:$iterations:'
      '${base64Url.encode(salt).replaceAll('=', '')}';

  /// `null` bila [comment] bukan kunci Lakuna (backup tanpa kata sandi).
  /// Kunci Lakuna yang rusak → [BackupInvalid].
  static BackupLock? parse(String comment) {
    if (!comment.startsWith('$_prefix:')) return null;
    const invalid = BackupInvalid('lock');
    final parts = comment.split(':');
    if (parts.length != 5 || parts[1] != '1' || parts[2] != 'pbkdf2-sha256') {
      throw invalid;
    }
    final iterations = int.tryParse(parts[3]);
    if (iterations == null ||
        iterations < backupKdfMinIterations ||
        iterations > backupKdfMaxIterations) {
      throw invalid;
    }
    final Uint8List salt;
    try {
      salt = base64Url.decode(base64Url.normalize(parts[4]));
    } on FormatException {
      throw invalid;
    }
    if (salt.length != _saltLength) throw invalid;
    return BackupLock(salt: salt, iterations: iterations);
  }

  /// Kata sandi zip dari kata sandi pengguna, dihitung di isolate lain
  /// agar UI tidak tersendat.
  Future<String> zipPassword(String password) {
    final salt = this.salt;
    final iterations = this.iterations;
    return Isolate.run(
      () => base64.encode(
        pbkdf2Sha256(utf8.encode(password), salt, iterations, _keyLength),
      ),
    );
  }
}

/// Token acak base64url (16 byte).
String randomToken() {
  final random = Random.secure();
  return base64Url
      .encode(List.generate(16, (_) => random.nextInt(256)))
      .replaceAll('=', '');
}

const _eocdLength = 22;

/// Komentar zip di [path] (`''` bila kosong), atau `null` bila berkas
/// tidak punya akhir direktori zip.
Future<String?> readZipComment(String path) async {
  final file = File(path);
  if (!file.existsSync()) return null;
  final raf = await file.open();
  try {
    final length = await raf.length();
    if (length < _eocdLength) return null;
    final tailLength = min(length, _eocdLength + 0xffff);
    await raf.setPosition(length - tailLength);
    final tail = await raf.read(tailLength);
    for (var i = tail.length - _eocdLength; i >= 0; i--) {
      if (tail[i] != 0x50 ||
          tail[i + 1] != 0x4b ||
          tail[i + 2] != 0x05 ||
          tail[i + 3] != 0x06) {
        continue;
      }
      final commentLength = tail[i + 20] | (tail[i + 21] << 8);
      if (i + _eocdLength + commentLength != tail.length) continue;
      return latin1.decode(tail.sublist(i + _eocdLength));
    }
    return null;
  } finally {
    await raf.close();
  }
}
