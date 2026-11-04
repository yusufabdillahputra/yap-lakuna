import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('staffNameIssue', () {
    test('wajib dan maksimal 60 karakter', () {
      expect(staffNameIssue(''), StaffIssue.required);
      expect(staffNameIssue('   '), StaffIssue.required);
      expect(staffNameIssue('a' * 61), StaffIssue.tooLong);
      expect(staffNameIssue(' Sari '), isNull);
    });
  });

  group('validatePinPair', () {
    test('PIN 6 angka dan ulangi sama', () {
      expect(validatePinPair('123456', '123456'), isEmpty);
    });

    test('PIN bukan 6 angka', () {
      expect(validatePinPair('12345', '12345'), {
        CredentialField.secret: StaffIssue.invalidPin,
      });
      expect(
        validatePinPair('12a456', '12a456')[CredentialField.secret],
        StaffIssue.invalidPin,
      );
    });

    test('ulangi kosong atau beda', () {
      expect(validatePinPair('123456', ''), {
        CredentialField.retype: StaffIssue.required,
      });
      expect(validatePinPair('123456', '654321'), {
        CredentialField.retype: StaffIssue.pinMismatch,
      });
    });
  });

  group('validatePasswordPair', () {
    test('minimal 8 karakter dan ulangi sama', () {
      expect(validatePasswordPair('rahasia1', 'rahasia1'), isEmpty);
      expect(validatePasswordPair('pendek', 'pendek'), {
        CredentialField.secret: StaffIssue.passwordTooShort,
      });
      expect(validatePasswordPair('rahasia1', 'rahasia2'), {
        CredentialField.retype: StaffIssue.passwordMismatch,
      });
    });
  });

  group('roleKeyFor', () {
    test('snake_case ASCII dari nama', () {
      expect(roleKeyFor('Kasir Senior', const {}), 'kasir_senior');
      expect(roleKeyFor('  Barista / Bar  ', const {}), 'barista_bar');
    });

    test('bentrok role bawaan diberi awalan custom_', () {
      expect(roleKeyFor('Cashier', const {}), 'custom_cashier');
      expect(roleKeyFor('owner', const {}), 'custom_owner');
    });

    test('nama tanpa huruf/angka ASCII', () {
      expect(roleKeyFor('★★', const {}), 'custom');
    });

    test('kunci terpakai diberi akhiran', () {
      expect(roleKeyFor('Barista', {'barista'}), 'barista_2');
      expect(roleKeyFor('Barista', {'barista', 'barista_2'}), 'barista_3');
    });
  });

  group('encode/decodePermissions', () {
    test('urut sesuai enum, dipisah koma', () {
      expect(
        encodePermissions({Permission.reportsView, Permission.salesCreate}),
        'sales:create,reports:view',
      );
      expect(encodePermissions(const {}), '');
    });

    test('kunci tak dikenal dan spasi diabaikan', () {
      expect(decodePermissions(' sales:create , tamu:lihat,,reports:view'), {
        Permission.salesCreate,
        Permission.reportsView,
      });
      expect(decodePermissions(''), isEmpty);
    });
  });

  group('effectivePermissions', () {
    test('pemilik selalu semua izin', () {
      expect(
        effectivePermissions(roleKey: 'cashier', isOwner: true, stored: ''),
        Permission.values.toSet(),
      );
    });

    test('baris tersimpan menang atas bawaan', () {
      expect(effectivePermissions(roleKey: 'cashier', stored: 'reports:view'), {
        Permission.reportsView,
      });
    });

    test('tanpa baris: bawaan, role tak dikenal kosong', () {
      expect(
        effectivePermissions(roleKey: 'waiter'),
        DefaultRole.waiter.permissions,
      );
      expect(effectivePermissions(roleKey: 'barista'), isEmpty);
    });
  });

  group('grantIssue', () {
    final manager = DefaultRole.manager.permissions;

    test('pemilik boleh semuanya', () {
      expect(
        grantIssue(
          actorIsOwner: true,
          actorPermissions: const {},
          granted: Permission.values.toSet(),
        ),
        isNull,
      );
    });

    test('bukan pemilik tidak boleh memberi izin di luar miliknya', () {
      expect(
        grantIssue(
          actorIsOwner: false,
          actorPermissions: manager,
          granted: {Permission.salesCreate},
        ),
        isNull,
      );
      expect(
        grantIssue(
          actorIsOwner: false,
          actorPermissions: manager,
          granted: {Permission.salesCreate, Permission.backupManage},
        ),
        StaffIssue.beyondOwnPermissions,
      );
    });
  });
}
