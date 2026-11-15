import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/ui/core/leave_guard.dart';

void main() {
  test('guard baru tetap disimpan walau halaman lain dibangun lebih dulu '
      'memasang check (F1-08k)', () async {
    final guards = LeaveGuards();
    // Dua halaman bertumpuk dibangun dalam satu frame: halaman atas (A)
    // meminta guard lebih dulu, lalu halaman bawah (B), sebelum A sempat
    // memasang `check`.
    final a = guards.of('a');
    guards.of('b');
    a.check = () async => false;
    expect(await guards.canLeave('a'), isFalse);
    expect(identical(guards.of('a'), a), isTrue);
  });

  test('guard halaman yang sudah ditutup dibuang', () async {
    final guards = LeaveGuards();
    final a = guards.of('a')..check = () async => false;
    a.check = null;
    guards.of('b');
    expect(await guards.canLeave('a'), isTrue);
    expect(identical(guards.of('a'), a), isFalse);
  });

  test(
    'halaman yang dibuka lagi dengan pageKey sama mendapat guard baru',
    () async {
      final guards = LeaveGuards();
      final first = guards.of('stok')..check = () async => false;
      first.check = null;
      // Halaman Stok dibuka lagi (pageKey tetap) bersama halaman lain dalam
      // satu frame, sebelum Stok sempat memasang `check`.
      final again = guards.of('stok');
      expect(identical(again, first), isFalse);
      guards.of('pembelian');
      again.check = () async => false;
      expect(await guards.canLeave('stok'), isFalse);
    },
  );

  test('pertanyaan yang sedang tampil dipakai ulang', () async {
    var calls = 0;
    final guard = LeaveGuard()
      ..check = () async {
        calls++;
        return true;
      };
    await Future.wait([guard.canLeave(), guard.canLeave()]);
    expect(calls, 1);
  });
}
