/// Rahasia versi hosting (F2-01): token perangkat, kode aktivasi, dan kode
/// pasang. Server hanya menyimpan [secretHash]-nya.
library;

import 'dart:convert';
import 'dart:math';

import 'package:hashlib/hashlib.dart' show sha256;

final _random = Random.secure();

/// Token perangkat baru: 256 bit acak, base64url tanpa padding (43 huruf).
String newDeviceToken() {
  final bytes = List<int>.generate(32, (_) => _random.nextInt(256));
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// SHA-256 hex dari [secret]. Token 256 bit tidak perlu hash lambat.
String secretHash(String secret) => sha256.string(secret).hex();

/// Huruf kode pendek tanpa yang mudah tertukar (0/O, 1/I/L).
const shortCodeAlphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

/// Kode acak sepanjang [length] dari [shortCodeAlphabet].
String newShortCode(int length) => String.fromCharCodes(
  List.generate(
    length,
    (_) =>
        shortCodeAlphabet.codeUnitAt(_random.nextInt(shortCodeAlphabet.length)),
  ),
);

/// Kode yang diketik pengguna: huruf besar, tanpa spasi dan strip.
String normalizeShortCode(String typed) =>
    typed.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
