import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/core/theme/theme.dart';
import 'package:lakuna_flutter/ui/hosting/hosting_section.dart';
import 'package:lakuna_flutter/ui/hosting/sync_status_chip.dart';
import 'package:material_ui/material_ui.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_hosting_repository.dart';
import '../../testing/fake_store_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

Future<void> _enter(WidgetTester tester, String key, String text) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(of: _key(key).last, matching: find.byType(EditableText)),
    text,
  );
  await tester.pumpAndSettle();
}

const _hostingRoute = '${Routes.settings}?bagian=hosting';

/// Toko contoh di zona WIB, agar jam sync terbaca 14.32 untuk 07.32 UTC.
FakeStoreRepository _jakarta() =>
    FakeStoreRepository(current: sampleStoreContext(timezone: 'Asia/Jakarta'));

List<UploadGroupProgress> _progress(int sales) => [
  (group: UploadGroup.store, acked: 12, total: 12),
  (group: UploadGroup.catalog, acked: 1240, total: 1240),
  (group: UploadGroup.sales, acked: sales, total: 15002),
];

void main() {
  for (final size in [const Size(1280, 800), const Size(360, 740)]) {
    final w = size.width.toInt();

    testWidgets(
      'aktivasi 2.1: server, login pemilik, unggah, selesai ($w px)',
      (
        tester,
      ) async {
        final hosting = FakeHostingRepository(
          lakunaServerUrl: 'https://sync.lakuna.id',
        );
        await pumpLakuna(
          tester,
          size: size,
          initialLocation: _hostingRoute,
          hosting: hosting,
        );
        expect(_key('hosting-section'), findsOneWidget);
        expect(find.text('Belum aktif'), findsOneWidget);

        await _tap(tester, 'hosting-activate');
        expect(_key('hosting-activation'), findsOneWidget);
        // Server Lakuna dipilih bawaan bila build membawanya.
        expect(_key('hosting-server-lakuna'), findsOneWidget);
        expect(_key('hosting-server-url'), findsNothing);
        await _tap(tester, 'hosting-server-own');
        await _enter(
          tester,
          'hosting-server-url',
          'https://sync.tokocontoh.id',
        );
        await _enter(tester, 'hosting-activation-code', 'KODE2345');
        await _tap(tester, 'hosting-check');
        expect(hosting.checkedUrl, 'https://sync.tokocontoh.id');
        expect(find.text('Server Lakuna 0.166.0 siap.'), findsOneWidget);
        await _tap(tester, 'hosting-next');

        expect(find.textContaining('Login pemilik'), findsWidgets);
        await _enter(tester, 'hosting-email', 'pemilik@contoh.id');
        await _enter(tester, 'hosting-password', 'rahasia123');
        await _tap(tester, 'hosting-signin');
        expect(hosting.calls, contains('login:pemilik@contoh.id'));
        expect(find.text('Masuk sebagai pemilik@contoh.id.'), findsOneWidget);

        hosting.progress = _progress(8410);
        await _tap(tester, 'hosting-activate-now');
        expect(hosting.activatedWith, 'https://sync.tokocontoh.id|KODE2345');
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(_key('hosting-upload-progress'), findsOneWidget);
        expect(find.text('8.410 / 15.002'), findsOneWidget);
        expect(find.text('1.240 / 1.240'), findsOneWidget);

        await _tap(tester, 'hosting-upload-pause');
        expect(hosting.calls, contains('paused:true'));
        expect(find.text('Lanjutkan unggahan'), findsOneWidget);
        await _tap(tester, 'hosting-upload-pause');
        expect(hosting.calls, contains('paused:false'));

        // Siklus yang menuntaskan unggah awal: progres kosong (data).
        hosting.progress = const [];
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        expect(_key('hosting-done'), findsOneWidget);
        await _tap(tester, 'hosting-finish');
        expect(
          find.text('Aktif · server sync.tokocontoh.id'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('server protokol lama ditolak ($w px)', (tester) async {
      final hosting = FakeHostingRepository()
        ..checkError = const HostingServerTooOld('0.163.0');
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: _hostingRoute,
        hosting: hosting,
      );
      await _tap(tester, 'hosting-activate');
      // Tanpa LAKUNA_HOSTING_URL hanya *Server sendiri*.
      expect(_key('hosting-server-lakuna'), findsNothing);
      await _enter(tester, 'hosting-server-url', 'https://lama.contoh.id');
      await _enter(tester, 'hosting-activation-code', 'KODE2345');
      await _tap(tester, 'hosting-check');
      expect(_key('hosting-check-error'), findsOneWidget);
      expect(
        find.text('Server perlu diperbarui (versi 0.163.0).'),
        findsOneWidget,
      );
      expect(_key('hosting-next'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('daftar akun pemilik: kata sandi diketik ulang ($w px)', (
      tester,
    ) async {
      final hosting = FakeHostingRepository();
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: _hostingRoute,
        hosting: hosting,
      );
      await _tap(tester, 'hosting-activate');
      await _enter(tester, 'hosting-server-url', 'https://sync.contoh.id');
      await _enter(tester, 'hosting-activation-code', 'KODE2345');
      await _tap(tester, 'hosting-check');
      await _tap(tester, 'hosting-next');
      await _tap(tester, 'hosting-owner-register');
      await _enter(tester, 'hosting-email', 'baru@contoh.id');
      await _tap(tester, 'hosting-send-code');
      expect(find.text('Kode dikirim ke baru@contoh.id.'), findsOneWidget);
      await _enter(tester, 'hosting-verification-code', '123456');
      await _enter(tester, 'hosting-password', 'rahasia123');
      await _enter(tester, 'hosting-password-repeat', 'rahasia124');
      expect(find.text('Kata sandi tidak sama.'), findsOneWidget);
      await _enter(tester, 'hosting-password-repeat', 'rahasia123');
      expect(_key('hosting-password-issue'), findsNothing);
      await _tap(tester, 'hosting-create-account');
      expect(
        hosting.calls,
        containsAllInOrder(['verify:123456', 'finish:token-daftar']),
      );
      expect(find.text('Masuk sebagai baru@contoh.id.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('kartu aktif: sync sekarang, jeda, kode pasang ($w px)', (
      tester,
    ) async {
      final hosting =
          FakeHostingRepository(
              state: hostingState(
                active: true,
                serverUrl: 'https://sync.tokocontoh.id/',
                lastSyncAt: DateTime.utc(2026, 11, 28, 7, 32),
                pending: 35,
              ),
            )
            ..pairing = (
              code: 'ABCD2345',
              shareText: 'https://sync.tokocontoh.id#ABCD2345',
              expiresAt: DateTime.now().toUtc().add(
                const Duration(minutes: 15),
              ),
            );
      await pumpLakuna(
        tester,
        size: size,
        store: _jakarta(),
        initialLocation: _hostingRoute,
        hosting: hosting,
      );
      expect(
        find.text('Aktif · server sync.tokocontoh.id'),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(_key('hosting-summary')).data,
        'Sync terakhir 28/11 14.32 · 35 perubahan menunggu',
      );
      await _tap(tester, 'hosting-sync-now');
      expect(hosting.syncNowCalls, 1);

      await _tap(tester, 'hosting-pause');
      expect(_key('hosting-paused'), findsOneWidget);
      expect(find.text('Lanjutkan sync'), findsOneWidget);

      await _tap(tester, 'hosting-pairing');
      expect(_key('hosting-pairing-dialog'), findsOneWidget);
      expect(find.text('ABCD 2345'), findsOneWidget);
      expect(find.text('https://sync.tokocontoh.id#ABCD2345'), findsOneWidget);
      expect(_key('hosting-pairing-expires'), findsOneWidget);
      await _tap(tester, 'hosting-pairing-close');
      expect(_key('hosting-pairing-dialog'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('galat jam perangkat tampil di kartu ($w px)', (tester) async {
      final hosting = FakeHostingRepository(
        state: hostingState(
          active: true,
          serverUrl: 'https://sync.tokocontoh.id/',
          pending: 3,
          lastError: 'clock',
        ),
      );
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: _hostingRoute,
        hosting: hosting,
      );
      expect(_key('hosting-error'), findsOneWidget);
      expect(find.textContaining('Jam perangkat tidak sesuai'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('kode pasang kedaluwarsa', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        supportedLocales: const [Locale('id'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...FLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        builder: (context, child) =>
            FTheme(data: lakunaLightTheme(touch: false), child: child!),
        home: Builder(
          builder: (context) => FScaffold(
            child: Center(
              child: FButton(
                key: const ValueKey('open'),
                onPress: () => showPairingCode(
                  context,
                  (
                    code: 'ABCD2345',
                    shareText: 'https://sync.contoh.id#ABCD2345',
                    expiresAt: DateTime.utc(2026, 11, 28, 8, 15),
                  ),
                  clock: () => DateTime.utc(2026, 11, 28, 8, 16),
                ),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      ),
    );
    await _tap(tester, 'open');
    expect(_key('hosting-pairing-expired'), findsOneWidget);
    expect(_key('hosting-pairing-expires'), findsNothing);
  });

  group('chip status', () {
    final at = DateTime.utc(2026, 11, 28, 7, 32);
    final cases = <(SyncStatus, String)>[
      (SyncStatus.local, 'Offline · data di perangkat ini'),
      (
        SyncStatus(kind: SyncChipKind.synced, lastSyncAt: at),
        'Tersinkron · 14.32',
      ),
      (
        const SyncStatus(kind: SyncChipKind.syncing, pending: 120),
        'Menyinkronkan… (120)',
      ),
      (
        const SyncStatus(kind: SyncChipKind.waiting, pending: 35),
        'Menunggu jaringan (35)',
      ),
      (
        const SyncStatus(kind: SyncChipKind.attention, conflicts: 2),
        'Perlu perhatian',
      ),
      (
        const SyncStatus(kind: SyncChipKind.attention, error: 'clock'),
        'Jam perangkat tidak sesuai',
      ),
      (
        const SyncStatus(kind: SyncChipKind.paused, pending: 4),
        'Sync dijeda (4)',
      ),
    ];
    for (final (status, text) in cases) {
      testWidgets('${status.kind.name}: $text', (tester) async {
        final hosting = FakeHostingRepository(status: status);
        await pumpLakuna(tester, store: _jakarta(), hosting: hosting);
        // Beranda juga punya judul *Perlu perhatian*: cari di dalam chip.
        final chip = status.kind == SyncChipKind.local
            ? find.byType(SyncStatusChip)
            : _key('sync-chip-${status.kind.name}');
        expect(
          find.descendant(of: chip, matching: find.text(text)),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('mobile: ikon saja, teks untuk pembaca layar', (tester) async {
      final hosting = FakeHostingRepository(
        status: const SyncStatus(kind: SyncChipKind.waiting, pending: 35),
      );
      final semantics = tester.ensureSemantics();
      await pumpLakuna(tester, size: const Size(360, 740), hosting: hosting);
      expect(find.text('Menunggu jaringan (35)'), findsNothing);
      expect(
        find.bySemanticsLabel(RegExp(r'Menunggu jaringan \(35\)')),
        findsWidgets,
      );
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });

    testWidgets('Perlu perhatian membuka kartu Versi hosting', (tester) async {
      final hosting = FakeHostingRepository(
        state: hostingState(
          active: true,
          serverUrl: 'https://sync.tokocontoh.id/',
          lastError: 'invalidToken',
        ),
        status: const SyncStatus(
          kind: SyncChipKind.attention,
          error: 'invalidToken',
        ),
      );
      await pumpLakuna(tester, hosting: hosting);
      await _tap(tester, 'sync-chip');
      expect(_key('hosting-section'), findsOneWidget);
      expect(find.textContaining('menolak token'), findsOneWidget);
    });

    testWidgets('chip berganti saat status berubah', (tester) async {
      final hosting = FakeHostingRepository(
        status: const SyncStatus(kind: SyncChipKind.syncing, pending: 2),
      );
      await pumpLakuna(tester, store: _jakarta(), hosting: hosting);
      expect(find.text('Menyinkronkan… (2)'), findsOneWidget);
      hosting.status = SyncStatus(
        kind: SyncChipKind.synced,
        lastSyncAt: DateTime.utc(2026, 11, 28, 7, 40),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tersinkron · 14.40'), findsOneWidget);
      expect(syncChipText, isNotNull);
    });
  });

  group('gabung', () {
    final outlets = [
      PairingOutlet(
        id: UuidValue.fromString('01900000-0000-7000-8000-000000000010'),
        code: 'PST',
        name: 'Pusat',
      ),
      PairingOutlet(
        id: UuidValue.fromString('01900000-0000-7000-8000-000000000011'),
        code: 'CB2',
        name: 'Cabang Dua',
      ),
    ];

    for (final size in [const Size(1280, 800), const Size(360, 740)]) {
      final w = size.width.toInt();
      testWidgets('kode lengkap mengisi alamat, pilih cabang, gabung ($w px)', (
        tester,
      ) async {
        final hosting = FakeHostingRepository()
          ..outlets = outlets
          ..sales = 0;
        var restarted = 0;
        await pumpLakuna(
          tester,
          size: size,
          // Toko belum ada: onboarding.
          store: FakeStoreRepository(),
          hosting: hosting,
          restart: () async => restarted++,
        );
        await _tap(tester, 'onboarding-join');
        expect(_key('join-hosting'), findsOneWidget);
        await _enter(
          tester,
          'join-server-0',
          'https://sync.tokocontoh.id#abcd-2345',
        );
        // Kode dari kode lengkap masuk ke isian kode.
        final code = tester.widget<EditableText>(
          find.descendant(
            of: _key('join-code-1'),
            matching: find.byType(EditableText),
          ),
        );
        expect(code.controller.text, 'ABCD2345');
        await _tap(tester, 'join-check');
        expect(
          hosting.calls,
          contains('outlets:https://sync.tokocontoh.id|ABCD2345'),
        );
        expect(_key('join-sales-warning'), findsNothing);
        await _tap(tester, 'join-outlet-CB2');
        await _enter(tester, 'join-device-code', 'k?');
        expect(_key('join-device-code-invalid'), findsOneWidget);
        await _enter(tester, 'join-device-code', 'k02');
        await _enter(tester, 'join-device-name', 'Kasir 2');
        await _tap(tester, 'join-submit');
        expect(hosting.joined?.deviceCode, 'K02');
        expect(hosting.joined?.code, 'ABCD2345');
        expect(restarted, 1);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('kode lengkap diketik huruf demi huruf: isian alamat tetap', (
      tester,
    ) async {
      final hosting = FakeHostingRepository()..outlets = outlets;
      await pumpLakuna(
        tester,
        initialLocation: _hostingRoute,
        hosting: hosting,
      );
      await _tap(tester, 'hosting-join');
      // Setiap ketikan setelah `#` tetap di isian alamat yang sama (tidak
      // dibuat ulang, jadi fokus tidak hilang); kode ikut terisi.
      for (final typed in [
        'https://sync.tokocontoh.id#',
        'https://sync.tokocontoh.id#AB',
        'https://sync.tokocontoh.id#ABCD2345',
      ]) {
        await _enter(tester, 'join-server-0', typed);
      }
      final code = tester.widget<EditableText>(
        find.descendant(
          of: find.byWidgetPredicate(
            (w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith('join-code-'),
          ),
          matching: find.byType(EditableText),
        ),
      );
      expect(code.controller.text, 'ABCD2345');
      await _tap(tester, 'join-check');
      expect(
        hosting.calls,
        contains('outlets:https://sync.tokocontoh.id|ABCD2345'),
      );
    });

    testWidgets('peringatan bila database lokal berisi penjualan', (
      tester,
    ) async {
      final hosting = FakeHostingRepository()
        ..outlets = outlets
        ..sales = 42;
      await pumpLakuna(
        tester,
        initialLocation: _hostingRoute,
        hosting: hosting,
      );
      await _tap(tester, 'hosting-join');
      await _enter(tester, 'join-server-0', 'https://sync.tokocontoh.id');
      await _enter(tester, 'join-code-0', 'ABCD2345');
      await _tap(tester, 'join-check');
      expect(_key('join-sales-warning'), findsOneWidget);
      expect(find.textContaining('42 penjualan'), findsOneWidget);
    });
  });
}
