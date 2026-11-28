import 'dart:convert';
import 'dart:math';

import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  final rfcSecret = ascii.encode('12345678901234567890');

  DateTime at(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

  group('totpCode (RFC 6238, SHA-1)', () {
    const vectors = {
      59: '94287082',
      1111111109: '07081804',
      1111111111: '14050471',
      1234567890: '89005924',
      2000000000: '69279037',
      20000000000: '65353130',
    };
    for (final MapEntry(key: t, value: code) in vectors.entries) {
      test('T=$t → $code', () {
        final step = totpStep(at(t));
        expect(totpCode(rfcSecret, step, digits: 8), code);
        expect(totpCode(rfcSecret, step), code.substring(2));
      });
    }

    test('langkah 30 detik', () {
      expect(totpStep(at(0)), 0);
      expect(totpStep(at(29)), 0);
      expect(totpStep(at(30)), 1);
    });
  });

  group('matchTotp', () {
    final now = at(1111111111);
    final step = totpStep(now);
    String codeAt(int s) => totpCode(rfcSecret, s);

    test('menerima langkah sekarang, −1, dan +1', () {
      expect(matchTotp(rfcSecret, codeAt(step), now), step);
      expect(matchTotp(rfcSecret, codeAt(step - 1), now), step - 1);
      expect(matchTotp(rfcSecret, codeAt(step + 1), now), step + 1);
    });

    test('menolak ±2 langkah', () {
      expect(matchTotp(rfcSecret, codeAt(step - 2), now), isNull);
      expect(matchTotp(rfcSecret, codeAt(step + 2), now), isNull);
    });

    test('menolak langkah yang sudah dipakai atau lebih lama', () {
      expect(
        matchTotp(rfcSecret, codeAt(step), now, lastUsedStep: step),
        isNull,
      );
      expect(
        matchTotp(rfcSecret, codeAt(step - 1), now, lastUsedStep: step - 1),
        isNull,
      );
      expect(
        matchTotp(rfcSecret, codeAt(step + 1), now, lastUsedStep: step),
        step + 1,
      );
    });

    test('abaikan spasi; tolak bukan 6 angka', () {
      final c = codeAt(step);
      expect(
        matchTotp(rfcSecret, '${c.substring(0, 3)} ${c.substring(3)}', now),
        step,
      );
      expect(matchTotp(rfcSecret, 'abcdef', now), isNull);
      expect(matchTotp(rfcSecret, c.substring(1), now), isNull);
    });
  });

  group('base32', () {
    test('bolak-balik 20 byte acak', () {
      final random = Random(7);
      for (var i = 0; i < 20; i++) {
        final bytes = List.generate(20, (_) => random.nextInt(256));
        expect(base32Decode(base32Encode(bytes)), bytes);
      }
    });

    test('vektor dikenal, huruf kecil dan spasi diabaikan', () {
      final expected = [...ascii.encode('Hello!'), 0xDE, 0xAD, 0xBE, 0xEF];
      expect(base32Decode('JBSWY3DPEHPK3PXP'), expected);
      expect(base32Decode('jbsw y3dp ehpk 3pxp'), expected);
      expect(base32Encode(expected), 'JBSWY3DPEHPK3PXP');
    });

    test('karakter tidak sah → null', () {
      expect(base32Decode('JBSW1'), isNull);
    });
  });

  test('otpauthUri', () {
    expect(
      otpauthUri(
        email: 'sari+toko@contoh.id',
        secretBase32: 'JBSWY3DPEHPK3PXP',
      ),
      'otpauth://totp/Lakuna:sari%2Btoko%40contoh.id?secret=JBSWY3DPEHPK3PXP'
      '&issuer=Lakuna&algorithm=SHA1&digits=6&period=30',
    );
  });

  group('kode cadangan', () {
    test('8 kode unik dengan pola xxxx-xxxx tanpa 0 O 1 I L', () {
      final codes = newBackupCodes(Random(1));
      expect(codes, hasLength(8));
      expect(codes.toSet(), hasLength(8));
      for (final c in codes) {
        expect(c, matches(RegExp(r'^[A-HJKMNP-Z2-9]{4}-[A-HJKMNP-Z2-9]{4}$')));
      }
    });

    test('normalizeBackupCode', () {
      expect(normalizeBackupCode(' abcd efgh '), 'ABCD-EFGH');
      expect(normalizeBackupCode('ABCD-EFGH'), 'ABCD-EFGH');
      expect(normalizeBackupCode('abcdefgh'), 'ABCD-EFGH');
      expect(normalizeBackupCode('abc'), 'ABC');
    });
  });

  test('newTotpSecret 20 byte', () {
    expect(newTotpSecret(Random(3)), hasLength(20));
  });
}
