import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
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
      'ganti periode: data lama disembunyikan, jawaban usang diabaikan',
      () async {
        final vm = ReportsViewModel(repository: repo);
        await vm.load.execute();
        const oct = ReportPeriod.month(2026, 10);
        const sep = ReportPeriod.month(2026, 9);
        final octHold = repo.holds[oct] = Completer<void>();
        final sepHold = repo.holds[sep] = Completer<void>();

        final octLoad = vm.setPeriod(oct);
        // Angka hari ini tidak boleh tampil (atau diunduh) di bawah Oktober.
        expect(vm.period, oct);
        expect(vm.data, isNull);
        expect(vm.loading, isTrue);

        final sepLoad = vm.setPeriod(sep);
        sepHold.complete();
        await sepLoad;
        expect(vm.data!.period, sep);
        expect(vm.loading, isFalse);

        // Jawaban Oktober datang belakangan: diabaikan.
        octHold.complete();
        await octLoad;
        expect(vm.period, sep);
        expect(vm.data!.period, sep);
      },
    );

    test('tab lanjutan dimuat saat dibuka dan saat periode berganti', () async {
      final vm = ReportsViewModel(repository: repo);
      await vm.load.execute();
      expect(repo.extraRequests, isEmpty);
      expect(vm.tabs.skip(4), [
        ReportTab.stock,
        ReportTab.cash,
        ReportTab.debts,
        ReportTab.returns,
      ]);
      expect(vm.ready, isTrue);

      vm.setTab(ReportTab.stock);
      expect(vm.stock, isNull);
      expect(vm.ready, isFalse);
      await pumpEventQueue();
      expect(vm.stock!.totalValue, const Money(183000));
      expect(vm.ready, isTrue);
      expect(repo.extraRequests, ['stock:ReportPeriod.today']);

      await vm.setPeriod(const ReportPeriod.month(2026, 10));
      expect(vm.stock!.rows, isEmpty);
      expect(repo.extraRequests.last, 'stock:ReportPeriod.month(2026, 10)');

      // Piutang tidak tergantung periode: tidak dimuat ulang saat ganti
      // periode kembali ke tab yang sama.
      vm.setTab(ReportTab.debts);
      await pumpEventQueue();
      expect(vm.debts!.receivable, const Money(200000));
      vm.setTab(ReportTab.cash);
      await pumpEventQueue();
      expect(vm.cash!.sessions, isEmpty);
      vm.setTab(ReportTab.returns);
      await pumpEventQueue();
      expect(vm.returns!.lines, isEmpty);
      expect(vm.stock, isNull);

      expect(
        vm.exportFileName(ReportFormat.xlsx),
        'laporan-retur-2026-10-261104.xlsx',
      );
      vm.setTab(ReportTab.debts);
      expect(
        vm.exportFileName(ReportFormat.pdf),
        'laporan-piutang-hutang-261104.pdf',
      );
      // Ganti periode di tab Piutang & hutang tidak memuat ulang tab itu.
      final before = repo.extraRequests.length;
      await vm.setPeriod(ReportPeriod.today);
      expect(repo.extraRequests.length, before);
      expect(vm.debts, isNotNull);
    });

    test('tab lanjutan: jawaban usang diabaikan', () async {
      final vm = ReportsViewModel(repository: repo);
      await vm.load.execute();
      vm.setTab(ReportTab.stock);
      await pumpEventQueue();
      const oct = ReportPeriod.month(2026, 10);
      final hold = repo.holds[oct] = Completer<void>();
      // Muatan Oktober (utama ditahan) dan stok Oktober berjalan; lalu
      // kembali ke hari ini sebelum Oktober selesai.
      final octLoad = vm.setPeriod(oct);
      await vm.setPeriod(ReportPeriod.today);
      hold.complete();
      await octLoad;
      expect(vm.period, ReportPeriod.today);
      // Stok Oktober (kosong) datang terakhir tetapi diabaikan.
      expect(vm.stock!.rows, isNotEmpty);
      expect(repo.extraRequests.last, 'stock:ReportPeriod.today');
    });

    test('tab lanjutan: galat izin tampil di tab itu', () async {
      final vm = ReportsViewModel(repository: repo);
      await vm.load.execute();
      repo.canView = false;
      vm.setTab(ReportTab.returns);
      await pumpEventQueue();
      expect(vm.extraError, isA<NotPermitted>());
      expect(vm.returns, isNull);
      vm.setTab(ReportTab.summary);
      expect(vm.extraError, isNull);
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
        '1–4 Oktober 2026',
      );
      expect(
        previousPeriodLabel(id, ReportPeriod.thisMonth, DateTime.utc(2026, 11)),
        '1 Oktober 2026',
      );
      expect(
        previousPeriodLabel(id, const ReportPeriod.month(2026, 10), today),
        'September 2026',
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
      // Satuan dasar per kategori bisa campur (pcs + kg): qty tidak dijumlah.
      expect(cat.rows.first.cells[1], '–');
    });

    test('tabel ekspor tab lanjutan', () async {
      final data = ((await repo.load(ReportPeriod.today)) as Ok).value;
      final stock =
          ((await repo.loadStock(ReportPeriod.today)) as Ok<StockReport>).value;
      final t = reportTable(
        id,
        data,
        ReportTab.stock,
        SalesGroup.product,
        stock: stock,
      );
      expect(t.title, 'Stok · Hari ini');
      expect(t.headers.last, 'Nilai akhir');
      expect(t.rows.first.cells.take(5), [
        'Kopi Susu',
        '20 gelas',
        '1 gelas',
        '4 gelas',
        '17 gelas',
      ]);
      expect((t.rows.last.cells.last! as XlsxNumber).value, 183000);
      expect(t.notes.first, 'Nilai stok: Rp 183.000');
      expect(reportRightAligned(t), [false, true, true, true, true, true]);

      final cash =
          ((await repo.loadCash(ReportPeriod.today)) as Ok<CashReport>).value;
      final c = reportTable(
        id,
        data,
        ReportTab.cash,
        SalesGroup.product,
        cash: cash,
      );
      // Sesi masih buka: Dihitung dan Selisih kosong (+ catatan), agar
      // kolom angka tetap rata kanan di PDF.
      expect(c.rows.first.cells[4], isNull);
      expect(c.rows.first.cells[5], isNull);
      expect(
        c.notes,
        contains('Dihitung dan selisih kosong = sesi masih buka.'),
      );
      expect(reportRightAligned(c).skip(2), everyElement(isTrue));
      expect((c.rows[1].cells[5]! as XlsxNumber).value, -5000);
      expect(c.notes, contains('Pengeluaran (2×): − Rp 25.000'));
      expect(c.notes, contains('Kas masuk manual (1×): + Rp 5.000'));

      final debts = ((await repo.loadDebts()) as Ok<DebtReport>).value;
      final d = reportTable(
        id,
        data,
        ReportTab.debts,
        SalesGroup.product,
        debts: debts,
      );
      expect(d.title, 'Piutang & hutang · Posisi per 4 November 2026');
      expect(d.rows.map((r) => r.cells.first), [
        'Piutang per pelanggan',
        'Budi',
        'Rina',
        'Total',
        'Hutang per supplier',
        'CV Sumber',
        'Total',
      ]);
      expect((d.rows[3].cells[4]! as XlsxNumber).value, 200000);
      expect(d.rows[5].cells[3], '10/11/2026');
      expect(
        returnRefundLabel(
          id,
          ReturnReportLine(
            returnedAt: DateTime.utc(2026, 11, 4),
            number: 'R',
            saleNumber: 'S',
            staffName: 'Sari',
            reason: SaleReturnReason.other,
            restock: false,
            refundMethod: RefundMethod.cash,
            amount: const Money(20000),
            debtReduction: const Money(5000),
          ),
        ),
        'Tunai dari laci + potong piutang',
      );

      final returns = ((await repo.loadReturns(
        ReportPeriod.today,
      )) as Ok<ReturnsReport>).value;
      final r = reportTable(
        id,
        data,
        ReportTab.returns,
        SalesGroup.product,
        returns: returns,
      );
      expect(r.rows.first.cells.take(7), [
        '04/11/26 11.05',
        'RT-PST-K01-261104-0001',
        'PST-K01-261104-0001',
        'Sari',
        'Salah ambil',
        'Ya',
        'Tunai dari laci',
      ]);
      expect(r.notes.single, 'Salah ambil (1×): Rp 18.000');
      expect(reportXlsx(r).length, greaterThan(100));
    });

    test('dokumen: nama lembar, perataan, dan lebar kolom', () async {
      expect(
        reportSheetName('Penjualan per kategori · September 2026'),
        'Penjualan per kategori',
      );
      expect(
        reportSheetName('Laba rugi · Oktober 2026'),
        'Laba rugi · Oktober 2026',
      );
      expect(reportSheetName('a/b'), 'a b');
      final data = ((await repo.load(ReportPeriod.today)) as Ok).value;
      final top = reportTable(id, data, ReportTab.top, SalesGroup.product);
      // Peringkat sempit, nama produk lebar, qty dan nilai rata kanan.
      expect(top.flex, [1, 5, 2, 2]);
      expect(reportRightAligned(top), [false, false, true, true]);
      final sales = reportTable(id, data, ReportTab.sales, SalesGroup.product);
      expect(reportRightAligned(sales), [false, true, true, true]);
    });
  });
}
