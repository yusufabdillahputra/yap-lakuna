import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart' show TenantStatus;
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../testing/app_harness.dart';
import '../testing/fake_dashboard_repository.dart';
import '../testing/fake_hosting_repository.dart';
import '../testing/fake_session_repository.dart';
import '../testing/fake_spreadsheet_exporter.dart';

void main() {
  const synced = SyncStatus(kind: SyncChipKind.synced);

  FakeHostingRepository hosted() => FakeHostingRepository(
    state: hostingState(active: true, serverUrl: 'https://toko.contoh.id'),
    status: synced,
  );

  FakeDashboardRepository dashboard({bool stale = true, int conflicts = 0}) {
    final now = DateTime.now().toUtc();
    return FakeDashboardRepository(now: now)
      ..status = TenantStatus(
        devices: [
          device('K01', pusatId, now.subtract(const Duration(minutes: 2))),
          device(
            'K02',
            pusatId,
            now.subtract(Duration(minutes: stale ? 180 : 3)),
          ),
          device('K03', timurId, now.subtract(const Duration(minutes: 1))),
        ],
        openConflicts: conflicts,
        serverTime: now,
      );
  }

  for (final size in const [Size(1280, 800), Size(390, 844)]) {
    testWidgets('${size.width.toInt()} px: kartu KPI, tabel per cabang dengan '
        'baris Total, Perlu perhatian', (tester) async {
      await pumpLakuna(
        tester,
        size: size,
        hosting: hosted(),
        dashboard: dashboard(conflicts: 2),
        initialLocation: Routes.dashboard,
      );
      expect(find.byKey(const ValueKey('dashboard-screen')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboard-kpi-sales')),
          matching: find.textContaining('36.000'),
        ),
        findsOneWidget,
      );
      expect(find.text('3 transaksi · 2 cabang'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboard-kpi-average')),
          matching: find.textContaining('12.000'),
        ),
        findsOneWidget,
      );
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('1 perangkat terakhir sync 3 jam lalu'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboard-kpi-conflicts')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      for (final key in ['row-$pusatId', 'row-$timurId', 'row-total']) {
        await tester.scrollUntilVisible(
          find.byKey(ValueKey('dashboard-$key')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(ValueKey('dashboard-$key')), findsOneWidget);
      }
      // Baris Pusat dan baris Total.
      expect(find.text('1 perangkat offline'), findsNWidgets(2));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('dashboard-attention')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('2 konflik sync menunggu tinjauan'),
        findsOneWidget,
      );
      expect(find.textContaining('Kasir K02'), findsOneWidget);
      expect(find.byKey(const ValueKey('dashboard-all-clear')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tanpa konflik dan perangkat tertinggal: Semua beres', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      hosting: hosted(),
      dashboard: dashboard(stale: false),
      initialLocation: Routes.dashboard,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('dashboard-all-clear')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Semua beres'), findsOneWidget);
    expect(find.text('Semua perangkat online'), findsOneWidget);
  });

  testWidgets('status perangkat offline: angka penjualan tetap tampil', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      hosting: hosted(),
      dashboard: dashboard()..status = null,
      initialLocation: Routes.dashboard,
    );
    expect(find.textContaining('36.000'), findsWidgets);
    expect(find.text('Status perangkat butuh internet'), findsWidgets);
    expect(find.byKey(const ValueKey('dashboard-all-clear')), findsNothing);
  });

  testWidgets('Unduh laporan menyimpan Excel semua cabang', (tester) async {
    final exporter = FakeSpreadsheetExporter();
    await pumpLakuna(
      tester,
      hosting: hosted(),
      dashboard: dashboard(),
      exporter: exporter,
      initialLocation: Routes.dashboard,
    );
    await tester.tap(find.byKey(const ValueKey('dashboard-download')));
    await tester.pumpAndSettle();
    expect(exporter.saved, hasLength(1));
    expect(exporter.saved.single.$1, startsWith('dashboard-semua-cabang-'));
    expect(exporter.saved.single.$1, endsWith('.xlsx'));
    expect(
      find.byKey(const ValueKey('dashboard-export-saved')),
      findsOneWidget,
    );
  });

  group('menu Dashboard semua cabang', () {
    testWidgets('tampil bila hosting aktif dan izin reports:view', (
      tester,
    ) async {
      await pumpLakuna(tester, hosting: hosted(), dashboard: dashboard());
      expect(find.byKey(const ValueKey('nav-dashboard')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-dashboard')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('dashboard-screen')), findsOneWidget);
    });

    testWidgets('tidak tampil sebelum hosting aktif; rutenya ke Beranda', (
      tester,
    ) async {
      await pumpLakuna(
        tester,
        hosting: FakeHostingRepository(),
        dashboard: dashboard(),
        initialLocation: Routes.dashboard,
      );
      expect(find.byKey(const ValueKey('nav-dashboard')), findsNothing);
      expect(find.byKey(const ValueKey('dashboard-screen')), findsNothing);
    });

    testWidgets('tidak tampil tanpa izin reports:view', (tester) async {
      await pumpLakuna(
        tester,
        hosting: hosted(),
        dashboard: dashboard(),
        session: FakeSessionRepository()
          ..current = sampleStaff(name: 'Rina', role: 'cashier'),
      );
      expect(find.byKey(const ValueKey('nav-dashboard')), findsNothing);
    });

    testWidgets('muncul begitu hosting aktif', (tester) async {
      final hosting = FakeHostingRepository();
      await pumpLakuna(tester, hosting: hosting, dashboard: dashboard());
      expect(find.byKey(const ValueKey('nav-dashboard')), findsNothing);
      hosting.status = synced;
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('nav-dashboard')), findsOneWidget);
    });
  });
}
