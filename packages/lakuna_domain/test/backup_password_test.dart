import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('backupPasswordProblem (F1-19c)', () {
    test('kosong dan kurang dari 8 karakter terlalu pendek', () {
      expect(backupPasswordProblem('', ''), BackupPasswordProblem.tooShort);
      expect(
        backupPasswordProblem('1234567', '1234567'),
        BackupPasswordProblem.tooShort,
      );
    });

    test('8 sampai 128 karakter dan ulangi sama: sah', () {
      expect(backupPasswordProblem('rahasia1', 'rahasia1'), isNull);
      final max = 'a' * backupPasswordMaxLength;
      expect(backupPasswordProblem(max, max), isNull);
    });

    test('lebih dari 128 karakter terlalu panjang', () {
      final long = 'a' * (backupPasswordMaxLength + 1);
      expect(backupPasswordProblem(long, long), BackupPasswordProblem.tooLong);
    });

    test('dihitung per karakter: emoji satu karakter', () {
      // 7 emoji = 14 unit UTF-16 tetapi 7 karakter.
      const seven = '🔒🔒🔒🔒🔒🔒🔒';
      expect(
        backupPasswordProblem(seven, seven),
        BackupPasswordProblem.tooShort,
      );
      const eight = '🔒🔒🔒🔒🔒🔒🔒🔒';
      expect(backupPasswordProblem(eight, eight), isNull);
    });

    test('ulangi tidak sama persis (spasi dan huruf dihitung)', () {
      expect(
        backupPasswordProblem('rahasia123', 'Rahasia123'),
        BackupPasswordProblem.mismatch,
      );
      expect(
        backupPasswordProblem('rahasia123', 'rahasia123 '),
        BackupPasswordProblem.mismatch,
      );
    });
  });
}
