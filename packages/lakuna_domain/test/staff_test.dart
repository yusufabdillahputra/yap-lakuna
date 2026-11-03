import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('permissionsForRole', () {
    test('role bawaan memakai izin DefaultRole', () {
      expect(permissionsForRole('cashier'), DefaultRole.cashier.permissions);
      expect(permissionsForRole('owner'), Permission.values.toSet());
    });

    test('kunci tak dikenal tidak mendapat izin', () {
      expect(permissionsForRole('tamu'), isEmpty);
      expect(permissionsForRole(''), isEmpty);
    });

    test('pemilik selalu mendapat semua izin', () {
      expect(
        permissionsForRole('waiter', isOwner: true),
        Permission.values.toSet(),
      );
    });
  });

  group('staffInitials', () {
    test('dua kata pertama', () {
      expect(staffInitials('Sari Dewi Lestari'), 'SD');
    });

    test('satu kata memakai dua huruf pertama', () {
      expect(staffInitials('yusuf'), 'YU');
      expect(staffInitials('A'), 'A');
    });

    test('spasi berlebih dan nama kosong', () {
      expect(staffInitials('  budi   santoso '), 'BS');
      expect(staffInitials('   '), '?');
    });
  });
}
