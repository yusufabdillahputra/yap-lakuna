import 'dart:convert';

import 'package:lakuna_server/src/web_access/totp_cipher.dart';
import 'package:test/test.dart';

void main() {
  final secret = List.generate(20, (i) => i * 7 % 256);

  test('enkripsi lalu dekripsi = rahasia asal', () {
    final cipher = TotpCipher('kunci-server-rahasia');
    expect(cipher.decrypt(cipher.encrypt(secret)), secret);
  });

  test('dua enkripsi rahasia sama berbeda (nonce acak)', () {
    final cipher = TotpCipher('kunci-server-rahasia');
    expect(cipher.encrypt(secret), isNot(cipher.encrypt(secret)));
  });

  test('satu byte diubah → melempar', () {
    final cipher = TotpCipher('kunci-server-rahasia');
    final sealed = base64.decode(cipher.encrypt(secret));
    sealed[15] ^= 0x01;
    expect(() => cipher.decrypt(base64.encode(sealed)), throwsA(anything));
  });

  test('kata sandi lain → melempar', () {
    final sealed = TotpCipher('kunci-a').encrypt(secret);
    expect(() => TotpCipher('kunci-b').decrypt(sealed), throwsA(anything));
  });

  test('fromPasswords: kosong atau tidak ada → null', () {
    expect(TotpCipher.fromPasswords({}), isNull);
    expect(TotpCipher.fromPasswords({'totpEncryptionKey': '  '}), isNull);
    expect(TotpCipher.fromPasswords({'totpEncryptionKey': 'x'}), isNotNull);
  });
}
