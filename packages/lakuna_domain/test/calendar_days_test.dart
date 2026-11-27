import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('calendarDaysAgo (F1-19e)', () {
    test('menurut tanggal cabang, bukan 24 jam', () {
      // 22.00 WIB 26 Nov = 15.00 UTC; 08.00 WIB 27 Nov = 01.00 UTC.
      final at = DateTime.utc(2026, 11, 26, 15);
      final now = DateTime.utc(2026, 11, 27, 1);
      expect(calendarDaysAgo(at, now, 'Asia/Jakarta'), 1);
      // Hari yang sama di WIB.
      expect(
        calendarDaysAgo(DateTime.utc(2026, 11, 27, 0, 30), now, 'Asia/Jakarta'),
        0,
      );
    });

    test('zona berbeda menggeser batas hari', () {
      // 16.30 UTC 26 Nov = 23.30 WIB 26 Nov tetapi 01.30 WIT 27 Nov.
      final at = DateTime.utc(2026, 11, 26, 16, 30);
      final now = DateTime.utc(2026, 11, 27, 2);
      expect(calendarDaysAgo(at, now, 'Asia/Jakarta'), 1);
      expect(calendarDaysAgo(at, now, 'Asia/Jayapura'), 0);
    });

    test('beberapa hari dan waktu di masa depan', () {
      final now = DateTime.utc(2026, 11, 27, 5);
      expect(
        calendarDaysAgo(DateTime.utc(2026, 11, 20, 5), now, 'Asia/Jakarta'),
        7,
      );
      expect(
        calendarDaysAgo(DateTime.utc(2026, 11, 29), now, 'Asia/Jakarta'),
        0,
      );
    });
  });
}
