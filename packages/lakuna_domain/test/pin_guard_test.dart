import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  late DateTime now;
  late PinGuard guard;

  setUp(() {
    now = DateTime.utc(2026, 11, 3, 8);
    guard = PinGuard(clock: () => now);
  });

  test('empat kali salah belum mengunci, sisa percobaan turun', () {
    expect(guard.remainingAttempts('a'), 5);
    for (var i = 1; i <= 4; i++) {
      guard.recordFailure('a');
      expect(guard.remainingAttempts('a'), 5 - i);
      expect(guard.retryAfter('a'), isNull);
    }
  });

  test('kegagalan ke-5 mengunci 60 detik dan mengatur ulang hitungan', () {
    for (var i = 0; i < 5; i++) {
      guard.recordFailure('a');
    }
    expect(guard.retryAfter('a'), const Duration(seconds: 60));
    expect(guard.remainingAttempts('a'), 5);
    now = now.add(const Duration(seconds: 45));
    expect(guard.retryAfter('a'), const Duration(seconds: 15));
    now = now.add(const Duration(seconds: 15));
    expect(guard.retryAfter('a'), isNull);
  });

  test('berhasil mengatur ulang kegagalan', () {
    guard
      ..recordFailure('a')
      ..recordFailure('a')
      ..recordSuccess('a');
    expect(guard.remainingAttempts('a'), 5);
  });

  test('kunci terpisah per staf', () {
    for (var i = 0; i < 5; i++) {
      guard.recordFailure('a');
    }
    expect(guard.retryAfter('a'), isNotNull);
    expect(guard.retryAfter('b'), isNull);
    expect(guard.remainingAttempts('b'), 5);
  });

  test('sisa kunci dibulatkan ke atas per detik', () {
    for (var i = 0; i < 5; i++) {
      guard.recordFailure('a');
    }
    now = now.add(const Duration(milliseconds: 59500));
    expect(guard.retryAfter('a'), const Duration(seconds: 1));
  });
}
