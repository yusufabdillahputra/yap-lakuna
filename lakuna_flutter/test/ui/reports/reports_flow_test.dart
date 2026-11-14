import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_receipt_printer.dart';
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
    FakeReceiptPrinter? printer,
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
      receiptPrinter: printer,
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

  testWidgets('1440 px: stok, kas & sesi, piutang & hutang, retur', (
    tester,
  ) async {
    await pump(tester, const Size(1440, 900));
    await _tap(tester, _key('reports-tab-stock'));
    expect(_key('reports-kpi-stock-value'), findsOneWidget);
    expect(find.text('Rp 183.000'), findsNWidgets(2)); // KPI + total
    expect(_key('reports-stock-table-kopi'), findsOneWidget);
    expect(find.text('17 gelas'), findsOneWidget);
    expect(find.text('Rp 102.000'), findsOneWidget);
    expect(
      tester.getTopLeft(_key('reports-kpi-stock-value')).dy,
      tester.getTopLeft(_key('reports-kpi-stock-out')).dy,
    );

    await _tap(tester, _key('reports-tab-cash'));
    expect(find.text('Masih buka'), findsOneWidget);
    expect(find.text('1 masih buka'), findsOneWidget);
    expect(find.text('− Rp 5.000'), findsNWidgets(2)); // KPI + sesi Budi
    expect(_key('reports-cash-movements-out-expense'), findsOneWidget);
    expect(find.text('− Rp 25.000'), findsOneWidget);
    expect(find.text('+ Rp 5.000'), findsOneWidget);

    await _tap(tester, _key('reports-tab-debts'));
    expect(find.text('Posisi per 4 November 2026'), findsOneWidget);
    // KPI piutang + total umur piutang (F1-16c).
    expect(find.text('Rp 200.000'), findsNWidgets(2));
    expect(_key('reports-debt-aging-receivable-days31To60'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('reports-debt-aging-receivable-days31To60'),
        matching: find.text('Rp 150.000'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _key('reports-debt-aging-payable-total'),
        matching: find.text('Rp 120.000'),
      ),
      findsOneWidget,
    );
    expect(find.text('Lewat 31–60 hari'), findsNWidgets(2));
    expect(
      tester.getTopLeft(_key('reports-debt-aging-receivable')).dy,
      lessThan(tester.getTopLeft(_key('reports-debt-customers')).dy),
    );
    expect(find.text('Budi'), findsOneWidget);
    expect(find.text('CV Sumber'), findsOneWidget);
    expect(find.text('10/11/2026'), findsOneWidget);
    await _tap(tester, _key('reports-download-xlsx'));
    expect(exporter.saved.last.$1, 'laporan-piutang-hutang-261104.xlsx');

    await _tap(tester, _key('reports-tab-returns'));
    expect(find.text('RT-PST-K01-261104-0001'), findsOneWidget);
    expect(_key('reports-returns-reasons-wrongItem'), findsOneWidget);
    await _tap(tester, _key('reports-download-xlsx'));
    expect(exporter.saved.last.$1, 'laporan-retur-hari-ini-261104.xlsx');

    // Ganti periode: tab aktif dimuat ulang untuk bulan itu.
    await _choose(tester, _key('reports-period'), 'Oktober 2026');
    expect(find.text('Tidak ada retur pada periode ini.'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1280, 800), Size(360, 780)]) {
    testWidgets('${size.width.toInt()} px: cetak ulang rekap sesi (F1-03e)', (
      tester,
    ) async {
      final printer = FakeReceiptPrinter();
      await pump(tester, size, printer: printer);
      await _tap(tester, _key('reports-tab-cash'));
      // Sesi Sari masih buka: tidak bisa diketuk.
      expect(_key('reports-cash-sessions-0'), findsOneWidget);
      expect(_key('reports-cash-sessions-0-tap'), findsNothing);
      expect(_key('reports-cash-reprint-hint'), findsOneWidget);

      await _tap(tester, _key('reports-cash-sessions-1-tap'));
      expect(repo.recapRequests, [FakeReportsRepository.closedSessionId]);
      expect(_key('reports-recap-dialog'), findsOneWidget);
      expect(find.text('Rekap sesi 03/11/26 08.00'), findsOneWidget);
      expect(_key('reports-recap-paper'), findsOneWidget);
      expect(find.textContaining('REKAP SESI KASIR'), findsOneWidget);
      expect(find.textContaining('Dicetak ulang'), findsOneWidget);

      await _tap(tester, _key('reports-recap-print'));
      final printed = printer.prints.single.$2.map((l) => l.text).toList();
      expect(printed, contains('REKAP SESI KASIR'));
      expect(printed.any((l) => l.startsWith('Ditutup oleh')), isTrue);
      expect(printed.any((l) => l.startsWith('Dicetak ulang')), isTrue);

      await _tap(tester, _key('reports-recap-share'));
      expect(printer.shares.single.$3, 'rekap-sesi-261103-2100.pdf');
      expect(_key('reports-recap-pdf-saved'), findsOneWidget);

      await _tap(tester, _key('reports-recap-close'));
      expect(_key('reports-recap-dialog'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rekap sesi berubah setelah tutup: catatan di pratinjau', (
    tester,
  ) async {
    await pump(tester, const Size(1280, 800));
    repo.recapChanged = true;
    await _tap(tester, _key('reports-tab-cash'));
    await _tap(tester, _key('reports-cash-sessions-1-tap'));
    expect(
      find.textContaining('Rincian mengikuti data saat ini'),
      findsOneWidget,
    );
  });

  testWidgets('rekap sesi gagal dimuat: pesan galat', (tester) async {
    await pump(tester, const Size(1280, 800));
    repo.recapError = Exception('db');
    await _tap(tester, _key('reports-tab-cash'));
    await _tap(tester, _key('reports-cash-sessions-1-tap'));
    expect(_key('reports-recap-load-error'), findsOneWidget);
    expect(find.text('Rekap sesi tidak bisa dimuat.'), findsOneWidget);
    expect(_key('reports-recap-print'), findsNothing);
  });

  testWidgets('stok tanpa izin laba: nilai tidak tampil', (tester) async {
    await pump(
      tester,
      const Size(1440, 900),
      reports: FakeReportsRepository(canViewProfit: false),
    );
    await _tap(tester, _key('reports-tab-stock'));
    expect(_key('reports-kpi-stock-items'), findsOneWidget);
    expect(_key('reports-kpi-stock-value'), findsNothing);
    expect(find.text('Nilai akhir'), findsNothing);
    expect(find.text('17 gelas'), findsOneWidget);
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

  testWidgets('rentang tanggal bebas: pilih, galat, batal, terapkan (F1-16b)', (
    tester,
  ) async {
    // Font uji (Ahem) jauh lebih lebar dari DM Sans: kepala kalender Forui
    // ("November 2026" + tombol) meluap hanya di tes. Luapan selama kalender
    // terbuka diabaikan; galat lain tetap dilaporkan. Tata letak asli
    // diperiksa di uji manual.
    final onError = FlutterError.onError;
    var calendarOpen = false;
    FlutterError.onError = (details) {
      if (calendarOpen && details.exceptionAsString().contains('overflowed')) {
        return;
      }
      onError?.call(details);
    };
    addTearDown(() => FlutterError.onError = onError);
    await pump(tester, const Size(1440, 900));
    Future<void> pickRange() async {
      await _tap(tester, _key('reports-period'));
      final item = find.text('Rentang tanggal…').last;
      await tester.scrollUntilVisible(
        item,
        50,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(item);
      await tester.pumpAndSettle();
    }

    await pickRange();
    expect(_key('reports-range-dialog'), findsOneWidget);
    // Batal: periode tetap Hari ini.
    await _tap(tester, _key('reports-range-cancel'));
    expect(_key('reports-range-dialog'), findsNothing);
    expect(repo.requests.last, ReportPeriod.today);

    await pickRange();
    // Sampai sebelum Dari (awal 4 Nov): galat, Terapkan nonaktif.
    calendarOpen = true;
    await _tap(tester, _key('reports-range-to'));
    await tester.tap(
      find
          .descendant(of: find.byType(FCalendar), matching: find.text('2'))
          .first,
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Tanggal akhir tidak boleh sebelum tanggal awal.'),
      findsOneWidget,
    );
    await _tap(tester, _key('reports-range-apply'));
    expect(_key('reports-range-dialog'), findsOneWidget);
    // Dari 1 Nov: rentang 1–2 Nov.
    await _tap(tester, _key('reports-range-from'));
    await tester.tap(
      find
          .descendant(of: find.byType(FCalendar), matching: find.text('1'))
          .first,
    );
    await tester.pumpAndSettle();
    calendarOpen = false;
    expect(
      find.text('Tanggal akhir tidak boleh sebelum tanggal awal.'),
      findsNothing,
    );
    await _tap(tester, _key('reports-range-apply'));
    expect(_key('reports-range-dialog'), findsNothing);
    final range = ReportPeriod.custom(
      DateTime.utc(2026, 11, 1),
      DateTime.utc(2026, 11, 2),
    );
    expect(repo.requests.last, range);
    expect(find.textContaining('1–2 Nov 2026'), findsWidgets);
    FlutterError.onError = onError;
    expect(tester.takeException(), isNull);
  });

  testWidgets('360 px: rentang tanggal bebas tanpa luapan (F1-16b)', (
    tester,
  ) async {
    await pump(tester, const Size(360, 780));
    await _tap(tester, _key('reports-period'));
    await tester.tap(find.text('Rentang tanggal…').last);
    await tester.pumpAndSettle();
    expect(_key('reports-range-dialog'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _tap(tester, _key('reports-range-apply'));
    expect(
      repo.requests.last,
      ReportPeriod.custom(DateTime.utc(2026, 11, 4), DateTime.utc(2026, 11, 4)),
    );
    expect(find.textContaining('4 Nov 2026'), findsWidgets);
    expect(tester.takeException(), isNull);
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
      for (final tab in ['stock', 'cash', 'debts', 'returns']) {
        await _tap(tester, _key('reports-tab-$tab'));
        expect(_key('reports-extra-loading'), findsNothing);
        if (tab == 'debts') {
          await tester.scrollUntilVisible(
            _key('reports-debt-aging-payable-total'),
            200,
            scrollable: find.byType(Scrollable).first,
          );
          // Mode kartu: kolom tampil sebagai "label: nilai".
          expect(
            find.descendant(
              of: _key('reports-debt-aging-receivable-notDue'),
              matching: find.text('Nota terbuka: 1'),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: _key('reports-debt-aging-payable-days31To60'),
              matching: find.text('Rp 50.000'),
            ),
            findsOneWidget,
          );
        }
      }
      expect(find.textContaining('RT-PST-K01-261104-0001'), findsOneWidget);
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
