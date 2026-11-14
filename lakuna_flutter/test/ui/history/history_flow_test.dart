import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Money;
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_history_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

void main() {
  late FakeHistoryRepository history;
  late FakeReceiptPrinter printer;
  late FakeSessionRepository session;
  late CheckoutResult kopi;
  late CheckoutResult roti;

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
    String location = Routes.history,
  }) async {
    history = FakeHistoryRepository(
      canVoid: role == 'owner',
      canReturn: role == 'owner',
    );
    kopi = history.addSale([('Kopi Susu', 2000, 18000)]);
    roti = history.addSale([
      ('Roti Bakar', 1000, 25000),
    ], method: PaymentMethod.qrisStatic);
    printer = FakeReceiptPrinter();
    session = FakeSessionRepository()
      ..current = sampleStaff(name: 'Sari', role: role);
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: location,
      history: history,
      receiptPrinter: printer,
      session: session,
    );
  }

  testWidgets('desktop: daftar + panel, retur sebagian, cetak ulang', (
    tester,
  ) async {
    await pump(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Riwayat transaksi'), findsWidgets);
    expect(
      find.text('Hari ini · 2 transaksi · Rp 61.000'),
      findsOneWidget,
    );
    expect(_key('history-table'), findsOneWidget);
    expect(_key('history-pick'), findsOneWidget);

    await _tap(tester, 'history-row-${kopi.sale.id.uuid}');
    expect(_key('history-detail-${kopi.sale.id.uuid}'), findsOneWidget);
    final item = kopi.items.single.id.uuid;
    await _tap(tester, 'history-return-plus-$item');
    await _tap(tester, 'history-reason-wrongItem');
    expect(find.text('Proses retur · Rp 18.000'), findsOneWidget);
    await _tap(tester, 'history-refund-transfer');
    await _tap(tester, 'history-return-submit');
    expect(history.returns.single.amount, 18000);
    expect(history.returns.single.restock, isTrue);
    expect(find.text('Retur sebagian'), findsWidgets);
    expect(find.text('RT-PST-K01-261103-0001'), findsOneWidget);
    // Nota yang sudah diretur tidak bisa di-void.
    expect(
      find.text('Nota ini sudah void atau diretur.'),
      findsOneWidget,
    );

    await _tap(tester, 'history-reprint');
    expect(_key('history-reprint-dialog'), findsOneWidget);
    expect(find.textContaining('CETAK ULANG'), findsOneWidget);
    await _tap(tester, 'history-reprint-print');
    expect(printer.prints, hasLength(1));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('kasir tanpa izin void: persetujuan PIN manajer lalu void', (
    tester,
  ) async {
    await pump(tester, role: 'cashier');
    await _tap(tester, 'history-row-${roti.sale.id.uuid}');
    // Tanpa sales:return form retur tidak tampil.
    expect(_key('history-return-form'), findsNothing);
    await _tap(tester, 'history-void');
    expect(_key('approval-dialog'), findsOneWidget);
    await tester.enterText(_input('approval-pin'), '123456');
    await _tap(tester, 'approval-submit');
    await _tap(tester, 'history-void-confirm');
    expect(
      find.text('Alasan wajib diisi (maks. 120 karakter).'),
      findsOneWidget,
    );
    await tester.enterText(_input('history-void-reason'), 'Salah input');
    await _tap(tester, 'history-void-confirm');
    expect(history.voids.single.$3, session.staff.single.id);
    expect(_key('history-voided-info'), findsOneWidget);
    expect(find.text('Void'), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('filter status memuat ulang daftar', (tester) async {
    await pump(tester);
    await tester.tap(_key('history-filter-status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Void').last);
    await tester.pumpAndSettle();
    expect(history.filters.last.status, HistoryStatus.voided);
    expect(_key('history-empty'), findsOneWidget);
    await _tap(tester, 'history-range-week');
    expect(history.filters.last.range, HistoryRange.week);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('cari nota: hasil, batas, tidak cocok, pill tanggal (F1-11b)', (
    tester,
  ) async {
    await pump(tester);
    history.truncateSearch = true;
    await tester.enterText(_input('history-search'), '0002');
    await tester.pumpAndSettle();
    expect(history.filters.last.query, '0002');
    expect(
      find.text('Hasil pencarian · 1 transaksi · Rp 25.000'),
      findsOneWidget,
    );
    expect(_key('history-row-${roti.sale.id.uuid}'), findsOneWidget);
    expect(_key('history-row-${kopi.sale.id.uuid}'), findsNothing);
    expect(_key('history-search-truncated'), findsOneWidget);

    await tester.enterText(_input('history-search'), 'tidak-ada');
    await tester.pumpAndSettle();
    expect(_key('history-search-empty'), findsOneWidget);
    expect(
      find.text('Tidak ada nota yang cocok dengan pencarian.'),
      findsOneWidget,
    );

    await _tap(tester, 'history-range-week');
    expect(history.filters.last.query, '');
    expect(history.filters.last.range, HistoryRange.week);
    final field = tester.widget<EditableText>(_input('history-search'));
    expect(field.controller.text, isEmpty);
    expect(find.text('7 hari · 2 transaksi · Rp 61.000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('360 px: kolom cari dan hasil tanpa luapan (F1-11b)', (
    tester,
  ) async {
    await pump(tester, size: const Size(360, 780));
    expect(_key('history-search'), findsOneWidget);
    history.truncateSearch = true;
    await tester.enterText(_input('history-search'), 'PST-K01');
    await tester.pumpAndSettle();
    expect(_key('history-search-truncated'), findsOneWidget);
    expect(
      find.text('Hasil pencarian · 2 transaksi · Rp 61.000'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('rentang tanggal bebas: batal lalu terapkan (F1-11c)', (
    tester,
  ) async {
    await pump(tester);
    await _tap(tester, 'history-range-custom');
    expect(_key('history-range-dialog'), findsOneWidget);
    await _tap(tester, 'history-range-cancel');
    expect(history.filters.last.range, HistoryRange.today);

    await _tap(tester, 'history-range-custom');
    await _tap(tester, 'history-range-apply');
    expect(_key('history-range-dialog'), findsNothing);
    final f = history.filters.last;
    expect(f.range, HistoryRange.custom);
    expect(f.days!.from, f.days!.to);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ekspor Excel dari kepala layar', (tester) async {
    await pump(tester);
    await _tap(tester, 'history-export');
    expect(_key('history-export-saved'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  for (final size in const [Size(360, 740), Size(820, 1180)]) {
    testWidgets('${size.width.toInt()} px: kartu/tabel lalu halaman rincian', (
      tester,
    ) async {
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(_key('history-pick'), findsNothing);
      await _tap(tester, 'history-row-${kopi.sale.id.uuid}');
      expect(_key('history-detail-page'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _tap(tester, 'history-return-all');
      await _tap(tester, 'history-return-submit');
      expect(history.returns.single.amount, 36000);
      await _tap(tester, 'history-detail-back');
      expect(_key('history-detail-page'), findsNothing);
      // Daftar dimuat ulang setelah kembali.
      expect(find.text('Diretur'), findsWidgets);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets(
      '${size.width.toInt()} px: nota kredit Belum lunas, retur potong piutang',
      (tester) async {
        await pump(tester, size: size);
        final credit = history.addSale(
          [('Beras 5 kg', 2000, 50000)],
          customerName: 'Toko Bu Ani',
          paidAmount: 20000,
          dueOn: DateTime.utc(2026, 11, 17),
        );
        await pumpLakuna(
          tester,
          size: size,
          initialLocation: Routes.history,
          history: history,
          receiptPrinter: printer,
          session: session,
        );
        expect(find.text('Belum lunas'), findsWidgets);
        await _tap(tester, 'history-row-${credit.sale.id.uuid}');
        expect(find.text('Toko Bu Ani'), findsWidgets);
        expect(find.textContaining('Kredit'), findsWidgets);
        final item = credit.items.single.id.uuid;
        await _tap(tester, 'history-return-plus-$item');
        expect(_key('history-return-debt'), findsOneWidget);
        expect(_key('history-refund-transfer'), findsNothing);
        await _tap(tester, 'history-return-submit');
        expect(history.returns.single.refundMethod, RefundMethod.debt);
        expect(history.outstanding[credit.sale.id], const Money(30000));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
