import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('parseShiftTime', () {
    test('menerima jam saja, titik, titik dua, dan empat digit', () {
      expect(parseShiftTime('7'), 7 * 60);
      expect(parseShiftTime('07'), 7 * 60);
      expect(parseShiftTime('07.00'), 7 * 60);
      expect(parseShiftTime('7:30'), 7 * 60 + 30);
      expect(parseShiftTime(' 22.15 '), 22 * 60 + 15);
      expect(parseShiftTime('0730'), 7 * 60 + 30);
      expect(parseShiftTime('730'), 7 * 60 + 30);
      expect(parseShiftTime('0'), 0);
      expect(parseShiftTime('23.59'), 23 * 60 + 59);
    });

    test('menolak jam/menit di luar batas dan teks lain', () {
      for (final s in [
        '',
        ' ',
        '24',
        '24.00',
        '7.60',
        '7.5',
        'pagi',
        '-1',
        '7..00',
        '7.00.00',
        '12345',
        '7:',
        ':30',
      ]) {
        expect(parseShiftTime(s), isNull, reason: s);
      }
    });
  });

  test('formatShiftTime dan shiftRangeLabel memakai titik dua digit', () {
    expect(formatShiftTime(0), '00.00');
    expect(formatShiftTime(7 * 60 + 5), '07.05');
    expect(formatShiftTime(23 * 60 + 59), '23.59');
    expect(shiftRangeLabel(22 * 60, 6 * 60), '22.00–06.00');
  });

  group('validateShift', () {
    test('isian sah tanpa galat', () {
      expect(validateShift(name: 'Pagi', start: 420, end: 900), isEmpty);
      expect(validateShift(name: 'Malam', start: 1320, end: 360), isEmpty);
    });

    test('nama kosong atau terlalu panjang', () {
      expect(validateShift(name: '  ', start: 0, end: 60), {ShiftIssue.name});
      expect(
        validateShift(
          name: 'x' * (ShiftLimits.name + 1),
          start: 0,
          end: 60,
        ),
        {ShiftIssue.name},
      );
      expect(
        validateShift(name: 'x' * ShiftLimits.name, start: 0, end: 60),
        isEmpty,
      );
    });

    test('jam kosong/di luar batas dan jam sama', () {
      expect(validateShift(name: 'A', start: null, end: null), {
        ShiftIssue.start,
        ShiftIssue.end,
      });
      expect(validateShift(name: 'A', start: -1, end: 1440), {
        ShiftIssue.start,
        ShiftIssue.end,
      });
      expect(validateShift(name: 'A', start: 1439, end: 0), isEmpty);
      expect(validateShift(name: 'A', start: 480, end: 480), {
        ShiftIssue.sameTime,
      });
    });
  });

  group('shiftContains', () {
    test('shift siang: mulai termasuk, selesai tidak', () {
      expect(shiftContains(420, 900, 420), isTrue);
      expect(shiftContains(420, 900, 899), isTrue);
      expect(shiftContains(420, 900, 900), isFalse);
      expect(shiftContains(420, 900, 419), isFalse);
    });

    test('shift lewat tengah malam', () {
      expect(shiftContains(1320, 360, 1320), isTrue);
      expect(shiftContains(1320, 360, 1439), isTrue);
      expect(shiftContains(1320, 360, 0), isTrue);
      expect(shiftContains(1320, 360, 359), isTrue);
      expect(shiftContains(1320, 360, 360), isFalse);
      expect(shiftContains(1320, 360, 720), isFalse);
    });
  });

  test('currentShiftIndex memilih shift berjalan, jam mulai paling awal', () {
    final shifts = [(start: 900, end: 1320), (start: 420, end: 960)];
    expect(currentShiftIndex(shifts, 600), 1);
    // 15.30 di kedua shift: jam mulai paling awal (07.00) menang.
    expect(currentShiftIndex(shifts, 930), 1);
    expect(currentShiftIndex(shifts, 1000), 0);
    expect(currentShiftIndex(shifts, 1400), isNull);
    expect(currentShiftIndex(const [], 600), isNull);
  });
}
