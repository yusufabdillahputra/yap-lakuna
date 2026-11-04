import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_reports_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_spreadsheet_exporter.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _choose(WidgetTester tester, Finder field, String label) async {
  await _tap(tester, field);
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  late FakeReportsRepository repo;
  late FakeSpreadsheetExporter exporter;

  Future<void> pump(
    WidgetTester tester,
    Size size, {
    FakeReportsRepository? reports,
    FakeSessionRepository? session,
  }) async {
    repo = reports ?? FakeReportsRepository();
    exporter = FakeSpreadsheetExporter();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.reports,
      reports: repo,
      exporter: exporter,
      session: session,
    );
  }

  testWidgets('1440 px: ringkasan, penjualan, terlaris, laba rugi, unduh', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    expect(find.text('Hari ini · Cabang Pusat'), findsOneWidget);
    expect(_key('reports-kpi-sales'), findsOneWidget);
    expect(find.text('Rp 87.000'), findsOneWidget);
    expect(find.text('3 transaksi'), findsOneWidget);
    expect(find.text('Rp 60.000'), findsOneWidget);
    expect(find.text('Rp 29.000'), findsOneWidget);
    expect(find.text('Rp 150.000'), findsOneWidget);
    expect(find.text('2 pelanggan'), findsOneWidget);
    // KPI berjajar satu baris.
    expect(
      tester.getTopLeft(_key('reports-kpi-sales')).dy,
      tester.getTopLeft(_key('reports-kpi-overdue')).dy,
    );
    expect(_key('reports-method-cash'), findsOneWidget);
    expect(find.text('75,2%'), findsOneWidget);
    expect(_key('reports-top-kopi'), findsOneWidget);
    expect(find.text('3 gelas'), findsOneWidget);

    // Tautan per kasir membuka tab Penjualan.
    await _tap(tester, _key('reports-link-sales-staff'));
    expect(_key('reports-sales-row-sari'), findsOneWidget);
    expect(find.text('Sari'), findsOneWidget);
    expect(find.text('Rp 77.000'), findsOneWidget);
    await _tap(tester, _key('reports-group-category'));
    expect(find.text('Tanpa kategori'), findsOneWidget);

    await _tap(tester, _key('reports-tab-top'));
    expect(_key('reports-top-table'), findsOneWidget);

    await _tap(tester, _key('reports-tab-profit'));
    expect(_key('reports-pl'), findsOneWidget);
    expect(find.text('Laba kotor · margin 69,0%'), findsOneWidget);
    expect(find.text('− Rp 27.000'), findsOneWidget);
    expect(find.text('Rp 32.000'), findsNWidgets(2));
    expect(find.text('+100,0% dibanding kemarin'), findsOneWidget);
    // Panel samping di kanan.
    expect(
      tester.getTopLeft(_key('reports-side-net-profit')).dx,
      greaterThan(tester.getTopRight(_key('reports-pl')).dx),
    );
    expect(_key('reports-note-0'), findsOneWidget);

    await _tap(tester, _key('reports-download-xlsx'));
    expect(_key('reports-export-saved'), findsOneWidget);
    expect(
      exporter.saved.single.$1,
      'laporan-laba-rugi-hari-ini-261104.xlsx',
    );
    await tester.runAsync(() async {
      await tester.tap(_key('reports-download-pdf'));
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await tester.pumpAndSettle();
    expect(exporter.saved.last.$1, 'laporan-laba-rugi-hari-ini-261104.pdf');
    expect(String.fromCharCodes(exporter.saved.last.$2.take(4)), '%PDF');
    expect(tester.takeException(), isNull);
  });

  testWidgets('periode bulan tanpa transaksi tampil nol', (tester) async {
    await pump(tester, const Size(1440, 900));
    await _choose(tester, _key('reports-period'), 'Oktober 2026');
    expect(repo.requests.last, const ReportPeriod.month(2026, 10));
    expect(find.text('0 transaksi'), findsOneWidget);
    expect(
      find.text('Belum ada penjualan pada periode ini.'),
      findsNWidgets(2),
    );
  });

  testWidgets('tanpa izin laba: kartu laba kotor dan tab laba rugi hilang', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(1440, 900),
      reports: FakeReportsRepository(canViewProfit: false),
    );
    expect(_key('reports-kpi-gross-profit'), findsNothing);
    expect(_key('reports-tab-profit'), findsNothing);
    expect(_key('reports-link-profit'), findsNothing);
  });

  testWidgets('tanpa izin laporan tampil galat muat', (tester) async {
    await pump(
      tester,
      const Size(1440, 900),
      reports: FakeReportsRepository(canView: false),
    );
    expect(_key('reports-error'), findsOneWidget);
  });

  for (final size in const [Size(800, 900), Size(360, 740)]) {
    testWidgets('${size.width.toInt()} px: tata letak sempit', (tester) async {
      await pump(tester, size);
      expect(_key('reports-kpi-sales'), findsOneWidget);
      await _tap(tester, _key('reports-tab-sales'));
      expect(_key('reports-sales-row-kopi'), findsOneWidget);
      await _tap(tester, _key('reports-tab-profit'));
      // Panel samping turun ke bawah laporan.
      expect(
        tester.getTopLeft(_key('reports-side-net-profit')).dy,
        greaterThan(tester.getBottomLeft(_key('reports-pl')).dy),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('kasir tanpa reports:view tidak melihat menu', (tester) async {
    await pump(
      tester,
      const Size(1440, 900),
      session: FakeSessionRepository()
        ..current = sampleStaff(name: 'Sari', role: 'cashier'),
    );
    expect(_key('reports-kpi-sales'), findsNothing);
  });
}
