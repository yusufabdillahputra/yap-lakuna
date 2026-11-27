import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('normalizePhone', () {
    test('hanya digit, awalan +62/62 jadi 0', () {
      expect(normalizePhone('0813-2222-1010'), '081322221010');
      expect(normalizePhone('+62 813 2222 1010'), '081322221010');
      expect(normalizePhone('6281322221010'), '081322221010');
      expect(normalizePhone(' (0274) 512 345 '), '0274512345');
    });

    test('nol depan yang hilang (sel angka Excel) dikembalikan', () {
      expect(normalizePhone('81322221010'), '081322221010');
      expect(normalizePhone('8'), '08');
    });

    test('kosong tetap kosong', () {
      expect(normalizePhone('  '), '');
      expect(normalizePhone('-'), '');
    });
  });

  group('phoneSearchKeys / phoneMatchesQuery (F1-13d)', () {
    const phone = '081322221010';

    test('format apa pun cocok dengan HP tersimpan', () {
      for (final q in [
        '0813',
        '0813-2222',
        '0813 2222 1010',
        '+62 813 2222',
        '+62-813-2222-1010',
        '6281322221010',
        '(0813) 2222',
        '2222-1010',
        '8132',
      ]) {
        expect(phoneMatchesQuery(phone, q), isTrue, reason: q);
      }
    });

    test('bukan pola HP atau terlalu pendek: tidak dicocokkan', () {
      expect(phoneSearchKeys('Bu Ani 0813'), isEmpty);
      expect(phoneSearchKeys('PST-K01-2611'), isEmpty);
      expect(phoneSearchKeys('08'), isEmpty);
      expect(phoneSearchKeys('+62'), isEmpty);
      expect(phoneSearchKeys('  '), isEmpty);
      expect(phoneMatchesQuery(phone, '08'), isFalse);
      expect(phoneMatchesQuery(null, '0813'), isFalse);
    });

    test('62 di tengah tidak diubah menjadi 0', () {
      expect(phoneSearchKeys('6212'), ['6212']);
      expect(phoneMatchesQuery('081262123', '6212'), isTrue);
      expect(phoneMatchesQuery('081200012', '6212'), isFalse);
      // Awalan + selalu kode negara: hanya kunci lokal; sisa terlalu
      // pendek diabaikan.
      expect(phoneSearchKeys('+628'), isEmpty);
      expect(phoneSearchKeys('+62 8'), isEmpty);
      expect(phoneSearchKeys('+62 81'), ['081']);
      expect(phoneSearchKeys('6281322221010'), ['081322221010']);
      expect(phoneMatchesQuery('085762813999', '+62 813'), isFalse);
    });

    test('salinan WhatsApp: tanda arah dan tanda hubung Unicode', () {
      expect(phoneMatchesQuery(phone, '\u202A+62 813-2222-1010\u202C'), isTrue);
      expect(phoneMatchesQuery(phone, '0813\u20112222'), isTrue);
      expect(phoneMatchesQuery(phone, '0813\u00A02222'), isTrue);
    });

    test('garis miring sebagai pemisah (F1-13f)', () {
      expect(phoneMatchesQuery(phone, '0813/2222/1010'), isTrue);
      expect(phoneMatchesQuery(phone, '0813 / 2222'), isTrue);
      expect(phoneSearchKeys('021/5551234'), ['0215551234']);
      expect(phoneMatchesQuery('0215551234', '021/555'), isTrue);
      expect(phoneSearchKeys('+62/813/2222'), ['08132222']);
      expect(phoneMatchesQuery('085762813999', '+62/813'), isFalse);
      // Garis miring Unicode yang tersalin dari aplikasi lain.
      expect(phoneMatchesQuery(phone, '0813\u22152222'), isTrue);
      expect(phoneMatchesQuery(phone, '0813\uFF0F2222'), isTrue);
      // U+2044 fraction slash dan U+29F8 big solidus (F1-11j).
      expect(phoneMatchesQuery(phone, '0813\u20442222'), isTrue);
      expect(phoneMatchesQuery(phone, '0813\u29F82222'), isTrue);
      expect(phoneSearchKeys('021\u20445551234'), ['0215551234']);
      // Tetap bukan pola HP: berhuruf, digit kurang, pemisah lain.
      expect(phoneSearchKeys('0813/abc'), isEmpty);
      expect(phoneSearchKeys('08/'), isEmpty);
      expect(phoneSearchKeys('0813_2222'), isEmpty);
      expect(phoneSearchKeys('0813\\2222'), isEmpty);
    });

    test('tidak cocok', () {
      expect(phoneMatchesQuery(phone, '0857'), isFalse);
      expect(phoneMatchesQuery(phone, '+62 857'), isFalse);
    });
  });

  group('validateCustomer', () {
    test('nama wajib dan dibatasi', () {
      expect(validateCustomer(name: ' '), {CustomerIssue.name});
      expect(validateCustomer(name: 'a' * (CustomerLimits.name + 1)), {
        CustomerIssue.name,
      });
      expect(validateCustomer(name: 'Toko Bu Ani'), isEmpty);
    });

    test('HP 8–15 digit bila diisi', () {
      expect(validateCustomer(name: 'A', phone: '0812'), {CustomerIssue.phone});
      expect(validateCustomer(name: 'A', phone: '0812345678901234'), {
        CustomerIssue.phone,
      });
      expect(validateCustomer(name: 'A', phone: '+62 812-3456-78'), isEmpty);
      expect(validateCustomer(name: 'A', phone: ''), isEmpty);
    });

    test('limit tidak negatif, teks lain dibatasi', () {
      expect(validateCustomer(name: 'A', creditLimit: const Money(-1)), {
        CustomerIssue.creditLimit,
      });
      expect(
        validateCustomer(
          name: 'A',
          address: 'x' * (CustomerLimits.address + 1),
          note: 'y' * (CustomerLimits.note + 1),
          groupName: 'z' * (CustomerLimits.groupName + 1),
        ),
        {CustomerIssue.address, CustomerIssue.note, CustomerIssue.group},
      );
    });

    test('batas dihitung per karakter, bukan unit UTF-16', () {
      expect(validateCustomer(name: '😀' * CustomerLimits.name), isEmpty);
    });
  });

  group('validateCustomerGroup', () {
    test('nama wajib, tempo 0–365', () {
      expect(validateCustomerGroup(name: '', termDays: 14), {
        CustomerGroupIssue.name,
      });
      expect(validateCustomerGroup(name: 'Grosir', termDays: -1), {
        CustomerGroupIssue.termDays,
      });
      expect(validateCustomerGroup(name: 'Grosir', termDays: 366), {
        CustomerGroupIssue.termDays,
      });
      expect(validateCustomerGroup(name: 'Grosir', termDays: 0), isEmpty);
    });
  });
}
