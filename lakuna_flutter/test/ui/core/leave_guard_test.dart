import 'package:flutter/widgets.dart';
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

  group('canLeaveAll (F1-02b)', () {
    test('tanpa guard terpasang: boleh', () async {
      final guards = LeaveGuards();
      guards.of('belum-dipasang');
      expect(await guards.canLeaveAll(), isTrue);
    });

    test('halaman teratas ditanya lebih dulu, berhenti pada Batal', () async {
      final guards = LeaveGuards();
      final asked = <String>[];
      guards.of('bawah').check = () async {
        asked.add('bawah');
        return true;
      };
      guards.of('atas').check = () async {
        asked.add('atas');
        return false;
      };
      expect(await guards.canLeaveAll(), isFalse);
      expect(asked, ['atas']);
    });

    test('semua halaman yang dijaga ditanya bila semuanya boleh', () async {
      final guards = LeaveGuards();
      final asked = <String>[];
      for (final key in ['a', 'b', 'c']) {
        guards.of(key).check = () async {
          asked.add(key);
          return true;
        };
      }
      expect(await guards.canLeaveAll(), isTrue);
      expect(asked, ['c', 'b', 'a']);
    });

    test('guard halaman yang sudah ditutup dilewati', () async {
      final guards = LeaveGuards();
      final closed = guards.of('tutup')..check = () async => false;
      closed.check = null;
      guards.of('buka').check = () async => true;
      expect(await guards.canLeaveAll(), isTrue);
    });

    test('pertanyaan yang sedang tampil dipakai ulang', () async {
      final guards = LeaveGuards();
      var calls = 0;
      guards.of('a').check = () async {
        calls++;
        return true;
      };
      await Future.wait([guards.canLeaveAll(), guards.canLeaveAll()]);
      expect(calls, 1);
    });
  });

  group('isRouteClosing (F1-02e)', () {
    testWidgets('aktif → tidak; animasi keluar → ya', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      late BuildContext page;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Navigator(
            key: navigator,
            onGenerateRoute: (_) => PageRouteBuilder<void>(
              pageBuilder: (_, _, _) => const SizedBox(),
            ),
          ),
        ),
      );
      final outside = tester.element(find.byType(Navigator));
      expect(isRouteClosing(outside), isFalse);

      navigator.currentState!.push(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, _, _) {
            page = context;
            return const SizedBox();
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(isRouteClosing(page), isFalse);

      // Tertutup halaman lain: masih aktif, tetap bertanya.
      navigator.currentState!.push(
        PageRouteBuilder<void>(pageBuilder: (_, _, _) => const SizedBox()),
      );
      await tester.pumpAndSettle();
      expect(isRouteClosing(page), isFalse);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();

      navigator.currentState!.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(isRouteClosing(page), isTrue);
      // Halaman go_router yang dilepas tanpa animasi diuji di alur produk.
    });
  });
}
