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
