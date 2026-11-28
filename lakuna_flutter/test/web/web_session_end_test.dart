import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/config/app_platform.dart';
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart';
import 'package:lakuna_flutter/data/services/web_session_store.dart';

import '../testing/app_harness.dart';
import '../testing/fake_hosting_repository.dart';

void main() {
  const web = AppPlatform(isWeb: true);
  const expired = SyncStatus(
    kind: SyncChipKind.attention,
    pending: 3,
    error: 'expired',
  );

  testWidgets('Fokus review 1: token ditolak saat 3 perubahan belum '
      'terkirim → layar Sesi berakhir menyebut 3, database belum dihapus '
      'sebelum Keluar sekarang', (tester) async {
    final hosting = FakeHostingRepository(
      state: hostingState(active: true, serverUrl: 'https://toko.contoh.id'),
    )..unsent = 3;
    var signedOut = 0;
    await pumpLakuna(
      tester,
      platform: web,
      hosting: hosting,
      signOut: () async => signedOut++,
      webSessions: MemoryWebSessionStore(delete: (_) async {}),
    );
    expect(find.byKey(const ValueKey('web-session-ended')), findsNothing);
    hosting.status = expired;
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-session-ended')), findsOneWidget);
    expect(
      find.text('3 perubahan belum terkirim akan hilang dari browser ini.'),
      findsOneWidget,
    );
    expect(signedOut, 0);
    await tester.tap(find.byKey(const ValueKey('web-session-ended-signout')));
    await tester.pumpAndSettle();
    expect(signedOut, 1);
  });

  testWidgets('sesi dicabut tanpa perubahan tertunda: Masuk lagi', (
    tester,
  ) async {
    final hosting = FakeHostingRepository(
      state: hostingState(active: true, serverUrl: 'https://toko.contoh.id'),
    );
    var signedOut = 0;
    await pumpLakuna(
      tester,
      platform: web,
      hosting: hosting,
      signOut: () async => signedOut++,
    );
    hosting.status = const SyncStatus(
      kind: SyncChipKind.attention,
      error: 'revoked',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-session-ended')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('web-session-ended-unsent')),
      findsNothing,
    );
    expect(find.text('Masuk lagi'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('web-session-ended-signout')));
    await tester.pumpAndSettle();
    expect(signedOut, 1);
  });

  testWidgets('peringatan tutup tab aktif selama ada perubahan tertunda', (
    tester,
  ) async {
    final sessions = MemoryWebSessionStore(delete: (_) async {});
    final hosting = FakeHostingRepository(
      state: hostingState(active: true, serverUrl: 'https://toko.contoh.id'),
    );
    await pumpLakuna(
      tester,
      platform: web,
      hosting: hosting,
      webSessions: sessions,
    );
    expect(sessions.unsentGuard, isFalse);
    hosting.status = const SyncStatus(
      kind: SyncChipKind.syncing,
      pending: 2,
      unsent: 2,
    );
    await tester.pump();
    expect(sessions.unsentGuard, isTrue);
    hosting.status = const SyncStatus(kind: SyncChipKind.synced);
    await tester.pump();
    expect(sessions.unsentGuard, isFalse);
    // Baris gambar sudah terkirim, berkasnya belum (review I1).
    hosting.status = const SyncStatus(kind: SyncChipKind.synced, unsent: 1);
    await tester.pump();
    expect(sessions.unsentGuard, isTrue);
  });

  group('menu Keluar di web', () {
    testWidgets('sync dulu; sisa 2 perubahan → konfirmasi; Batal tidak '
        'keluar, Keluar sekarang mencabut token lalu keluar', (tester) async {
      final hosting = FakeHostingRepository(
        state: hostingState(active: true, serverUrl: 'https://toko.contoh.id'),
      )..unsentAfterSync = 2;
      var signedOut = 0;
      await pumpLakuna(
        tester,
        platform: web,
        hosting: hosting,
        signOut: () async => signedOut++,
      );
      await tester.tap(find.byKey(const ValueKey('web-logout')));
      await tester.pumpAndSettle();
      expect(hosting.calls, contains('unsent:sync'));
      expect(find.byKey(const ValueKey('web-logout-confirm')), findsOneWidget);
      expect(
        find.text('2 perubahan belum terkirim akan hilang dari browser ini.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('web-logout-cancel')));
      await tester.pumpAndSettle();
      expect(signedOut, 0);
      expect(hosting.logoutWebCalls, 0);

      await tester.tap(find.byKey(const ValueKey('web-logout')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('web-logout-now')));
      await tester.pumpAndSettle();
      expect(hosting.logoutWebCalls, 1);
      expect(signedOut, 1);
    });

    testWidgets('semua terkirim: langsung keluar tanpa konfirmasi', (
      tester,
    ) async {
      final hosting = FakeHostingRepository(
        state: hostingState(active: true, serverUrl: 'https://toko.contoh.id'),
      );
      var signedOut = 0;
      await pumpLakuna(
        tester,
        platform: web,
        hosting: hosting,
        signOut: () async => signedOut++,
      );
      await tester.tap(find.byKey(const ValueKey('web-logout')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('web-logout-confirm')), findsNothing);
      expect(hosting.logoutWebCalls, 1);
      expect(signedOut, 1);
    });

    testWidgets('Keluar ditekan dua kali saat server lambat: keluar sekali '
        '(review I2)', (tester) async {
      final hosting = FakeHostingRepository(
        state: hostingState(active: true, serverUrl: 'https://toko.contoh.id'),
      )..logoutGate = Completer<void>();
      var signedOut = 0;
      await pumpLakuna(
        tester,
        platform: web,
        hosting: hosting,
        signOut: () async => signedOut++,
      );
      await tester.tap(find.byKey(const ValueKey('web-logout')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('web-logout')));
      await tester.pump();
      hosting.logoutGate!.complete();
      await tester.pumpAndSettle();
      expect(hosting.logoutWebCalls, 1);
      expect(signedOut, 1);
    });

    testWidgets('tidak ada di aplikasi perangkat', (tester) async {
      await pumpLakuna(tester, hosting: FakeHostingRepository());
      expect(find.byKey(const ValueKey('web-logout')), findsNothing);
    });
  });
}
