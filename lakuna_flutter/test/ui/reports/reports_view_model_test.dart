import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/reports_repository.dart';
import 'package:lakuna_flutter/data/services/report_document.dart';
import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations_en.dart';
import 'package:lakuna_flutter/l10n/gen/app_localizations_id.dart';
import 'package:lakuna_flutter/ui/reports/report_labels.dart';
import 'package:lakuna_flutter/ui/reports/reports_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_reports_repository.dart';
import '../../testing/fake_spreadsheet_exporter.dart';

void main() {
  late FakeReportsRepository repo;
  final id = AppLocalizationsId();

  setUp(() => repo = FakeReportsRepository());

  group('ReportsViewModel', () {
    test('memuat hari ini, angka ringkasan, ganti periode', () async {
      final vm = ReportsViewModel(repository: repo);
      await vm.load.execute();
      final data = vm.data!;
      expect(repo.requests, [ReportPeriod.today]);
      expect(data.netSales, const Money(87000));
      expect(data.saleCount, 3);
      expect(data.averagePerSale, const Money(29000));
      expect(data.profit!.grossProfit, const Money(60000));
      expect(data.profit!.netProfit, const Money(32000));
      expect(vm.tabs, ReportTab.values);
      expect(vm.periods, hasLength(15));

      await vm.setPeriod(const ReportPeriod.month(2026, 10));
      expect(repo.requests.last, const ReportPeriod.month(2026, 10));
      expect(vm.data!.saleCount, 0);
    });

    test(
      'tanpa izin laba: tab Laba rugi hilang dan kembali ke ringkasan',
      () async {
        final vm = ReportsViewModel(repository: repo);
        await vm.load.execute();
        vm.setTab(ReportTab.profit);
        expect(vm.tab, ReportTab.profit);
        repo.canViewProfit = false;
        await vm.load.execute();
        expect(vm.tabs, isNot(contains(ReportTab.profit)));
        expect(vm.tab, ReportTab.summary);
        vm.setTab(ReportTab.profit);
        expect(vm.tab, ReportTab.summary);
      },
    );

    test('galat muat tampil', () async {
      repo.canView = false;
      final vm = ReportsViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.error, isA<NotPermitted>());
      expect(vm.data, isNull);
    });

    test('nama berkas ekspor per tab, kelompok, periode', () async {
      final exporter = FakeSpreadsheetExporter();
      final vm = ReportsViewModel(repository: repo, exporter: exporter);
      await vm.load.execute();
      expect(
        vm.exportFileName(ReportFormat.xlsx),
        'laporan-ringkasan-hari-ini-261104.xlsx',
      );
      vm
        ..setTab(ReportTab.sales)
        ..setGroup(SalesGroup.staff);
      expect(
        vm.exportFileName(ReportFormat.pdf),
        'laporan-penjualan-kasir-hari-ini-261104.pdf',
      );
      await vm.setPeriod(const ReportPeriod.month(2026, 10));
      vm.setTab(ReportTab.profit);
      await vm.export.execute((Uint8List.fromList([1]), ReportFormat.pdf));
      expect(exporter.saved.single.$1, 'laporan-laba-rugi-2026-10-261104.pdf');
      expect(vm.exportPath, exporter.path);
    });
  });

  group('label dan tabel ekspor', () {
    test('persen dan periode', () {
      expect(percentLabel(id, 2570), '25,7%');
      expect(percentLabel(AppLocalizationsEn(), 2570), '25.7%');
      expect(percentLabel(id, 800, signed: true), '+8,0%');
      expect(percentLabel(id, null), '–');
      expect(
        reportPeriodLabel(id, const ReportPeriod.month(2026, 10)),
        'Oktober 2026',
      );
      final today = DateTime.utc(2026, 11, 4);
      expect(
        previousPeriodLabel(id, ReportPeriod.thisMonth, today),
        'Oktober 2026',
      );
      expect(previousPeriodLabel(id, ReportPeriod.today, today), 'kemarin');
    });

    test('laba rugi: urutan baris dan nilai bertanda', () async {
      final data = ((await repo.load(ReportPeriod.today)) as Ok).value;
      final t = reportTable(id, data, ReportTab.profit, SalesGroup.product);
      expect(t.title, 'Laba rugi · Hari ini');
      expect(t.rows.map((r) => r.cells.first), [
        'Penjualan kotor',
        'Diskon',
        'Retur penjualan',
        'Penjualan bersih',
        'Harga pokok penjualan (HPP)',
        'Laba kotor · margin 69,0%',
        'Sewa tempat',
        'Listrik & air',
        'Total beban operasional',
        'Penyesuaian stok (selisih, rusak, hilang)',
        'Laba bersih',
      ]);
      int value(int i) => (t.rows[i].cells[1]! as XlsxNumber).value;
      expect(value(0), 107000);
      expect(value(1), -2000);
      expect(value(3), 87000);
      expect(value(4), -27000);
      expect(value(8), -25000);
      expect(value(9), -3000);
      expect(value(10), 32000);
      expect(t.notes.first, contains('1 produk'));
      final xlsx = reportXlsx(t);
      expect(xlsx.length, greaterThan(100));
    });

    test('penjualan per kasir dan kategori', () async {
      final data = ((await repo.load(ReportPeriod.today)) as Ok).value;
      final staff = reportTable(id, data, ReportTab.sales, SalesGroup.staff);
      expect(staff.rows.map((r) => r.cells.take(2).toList()), [
        ['Sari', 2],
        ['Budi', 1],
        ['Total', 3],
      ]);
      final cat = reportTable(id, data, ReportTab.sales, SalesGroup.category);
      expect(cat.rows.map((r) => r.cells.first), [
        'Minuman',
        'Tanpa kategori',
        'Total',
      ]);
      expect(cat.rows.first.cells[1], '5');
    });
  });
}
