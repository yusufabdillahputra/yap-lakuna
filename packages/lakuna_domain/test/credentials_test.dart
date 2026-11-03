import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('parameter bawaan: Argon2id OWASP (m=19456, t=2, p=1)', () {
    const hasher = CredentialHasher();
    final hash = hasher.hash('rahasia123');
    expect(hash, startsWith(r'$argon2id$v=19$m=19456,t=2,p=1$'));
    expect(hasher.verify('rahasia123', hash), isTrue);
  });

  group('dengan parameter ringan untuk tes', () {
    const hasher = CredentialHasher.forTesting();

    test('verifikasi benar dan salah', () {
      final hash = hasher.hash('123456');
      expect(hash, isNot(contains('123456')));
      expect(hasher.verify('123456', hash), isTrue);
      expect(hasher.verify('654321', hash), isFalse);
    });

    test('salt acak: dua hash teks sama berbeda', () {
      expect(hasher.hash('123456'), isNot(hasher.hash('123456')));
    });

    test('hash rusak atau bukan Argon2 dianggap salah', () {
      expect(hasher.verify('123456', 'bukan-hash'), isFalse);
      expect(hasher.verify('123456', ''), isFalse);
    });
  });
}
