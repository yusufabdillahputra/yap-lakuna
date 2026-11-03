import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show BillItemLocked;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_cashier_repository.dart';
import '../../testing/fake_dining_repository.dart';
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

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).last);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

void main() {
  late FakeDiningRepository dining;
  late FakeCashierRepository cashier;
  late FakeReceiptPrinter printer;

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
  }) async {
    dining = FakeDiningRepository(
      permissions: role == 'owner'
          ? null
          : permissionsForRole(role, isOwner: false),
    );
    cashier = FakeCashierRepository()..dining = dining;
    printer = FakeReceiptPrinter();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.tables,
      dining: dining,
      cashier: cashier,
      receiptPrinter: printer,
      session: FakeSessionRepository()..current = sampleStaff(role: role),
    );
  }

  Future<void> addMenu(WidgetTester tester, List<String> names) async {
    await _tap(tester, 'dining-add-menu');
    for (final n in names) {
      await _tap(tester, 'dining-menu-$n');
    }
    expect(_key('dining-menu-added'), findsOneWidget);
    await _tap(tester, 'dining-menu-done');
  }

  testWidgets('tablet lebar: buka meja, menu, dapur, disajikan, bayar', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Pelayan: Dimas · 0 dari 6 meja terisi'), findsOneWidget);
    expect(_key('dining-select-hint'), findsOneWidget);

    await _tap(tester, 'dining-table-M4');
    expect(_key('dining-guests-dialog'), findsOneWidget);
    // Bawaan = kursi meja (4); 0 ditolak.
    await tester.enterText(_input('dining-guests'), '0');
    await _tap(tester, 'dining-guests-open');
    expect(find.text('Isi 1–99 tamu.'), findsOneWidget);
    await tester.enterText(_input('dining-guests'), '3');
    await _tap(tester, 'dining-guests-open');
    expect(find.text('Meja M4 · Open bill'), findsOneWidget);
    expect(_key('dining-bill-empty'), findsOneWidget);

    await addMenu(tester, ['Kopi Susu Aren']);
    expect(find.text('Kirim ke dapur (1 item baru)'), findsOneWidget);
    expect(find.text('Rp 27.720'), findsWidgets);
    expect(find.text('Service 5% (dine in)'), findsOneWidget);
    expect(find.text('PB1 10%'), findsOneWidget);

    await _tap(tester, 'dining-send');
    expect(_key('dining-ticket'), findsOneWidget);
    expect(find.textContaining('K-0012'), findsOneWidget);
    expect(find.textContaining('TIKET DAPUR'), findsOneWidget);
    await _tap(tester, 'dining-ticket-print');
    expect(printer.prints.single.$2.first.text, contains('TIKET DAPUR'));
    await _tap(tester, 'dining-ticket-close');
    expect(_key('dining-ticket'), findsNothing);
    expect(find.text('Di dapur'), findsOneWidget);

    await _tapText(tester, 'Tandai disajikan');
    expect(find.text('Disajikan'), findsOneWidget);

    await _tap(tester, 'dining-request-bill');
    expect(find.text('Batal minta bill'), findsOneWidget);

    await _tap(tester, 'dining-pay');
    expect(find.text('Pembayaran · Total Rp 27.720'), findsOneWidget);
    expect(find.text('Meja M4 · 1 item'), findsOneWidget);
    // Rincian bill (hanya baca) agar kasir bisa menjelaskan service & PB1.
    final summary = _key('payment-bill-summary');
    expect(
      find.descendant(of: summary, matching: find.text('Service 5% (dine in)')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.text('PB1 10%')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summary, matching: find.textContaining('Kopi')),
      findsOneWidget,
    );
    await _tap(tester, 'payment-quick-0');
    await _tap(tester, 'payment-finish');
    expect(_key('success-title'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('success-receipt'),
        matching: find.textContaining('PB1 10%'),
      ),
      findsOneWidget,
    );
    expect(cashier.paidBills, hasLength(1));

    await _tapText(tester, 'Kembali ke meja');
    expect(find.text('Pelayan: Dimas · 0 dari 6 meja terisi'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('kembali dari tahap bayar: bill tetap terbuka dan terpilih', (
    tester,
  ) async {
    await pump(tester);
    await _tap(tester, 'dining-table-M1');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Es Teh Manis']);
    await _tap(tester, 'dining-pay');
    await _tap(tester, 'payment-back');
    expect(find.text('Meja M1 · Open bill'), findsOneWidget);
    expect(cashier.paidBills, isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('pindah meja dan batalkan bill dengan alasan', (tester) async {
    await pump(tester);
    await _tap(tester, 'dining-table-M2');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Nasi Goreng Kampung']);

    await _tap(tester, 'dining-move');
    expect(_key('dining-move-to-M2'), findsNothing);
    await _tap(tester, 'dining-move-to-M6');
    expect(find.text('Meja M6 · Open bill'), findsOneWidget);

    await _tap(tester, 'dining-void');
    await _tap(tester, 'dining-void-confirm');
    expect(find.text('Alasan wajib diisi, maks 120 karakter.'), findsOneWidget);
    await tester.enterText(_input('dining-void-reason'), 'Tamu batal pesan');
    await _tap(tester, 'dining-void-confirm');
    expect(dining.voided.values, ['Tamu batal pesan']);
    expect(_key('dining-select-hint'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('pelayan: tanpa tombol batal, bayar mati', (tester) async {
    await pump(tester, role: 'waiter');
    await _tap(tester, 'dining-table-M3');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Es Teh Manis']);
    expect(_key('dining-void'), findsNothing);
    expect(
      find.text('Pembayaran oleh kasir (butuh izin penjualan).'),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  for (final size in const [Size(360, 740), Size(820, 1180)]) {
    testWidgets('take away ${size.width.toInt()} px: nomor, hapus kosong', (
      tester,
    ) async {
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      await _tap(tester, 'dining-mode-take-away');
      expect(_key('dining-take-away-none'), findsOneWidget);

      await _tap(tester, 'dining-take-away-new');
      await tester.enterText(_input('dining-customer-name'), 'Budi');
      await _tap(tester, 'dining-take-away-create');
      expect(find.text('TA-01 · Take away'), findsOneWidget);
      // Layar sempit: bill menggantikan daftar, dengan tombol kembali.
      expect(_key('dining-bill-back'), findsOneWidget);
      await addMenu(tester, ['Kopi Susu Aren', 'Es Teh Manis']);
      expect(find.text('Service 5% (dine in)'), findsNothing);
      expect(find.text('Kirim ke dapur (2 item baru)'), findsOneWidget);
      expect(_key('dining-request-bill'), findsNothing);
      expect(tester.takeException(), isNull);

      await _tap(tester, 'dining-bill-back');
      expect(find.text('TA-01 · Budi'), findsOneWidget);
      expect(find.text('Baru'), findsOneWidget);

      await _tap(tester, 'dining-take-away-new');
      await _tap(tester, 'dining-take-away-create');
      await _tap(tester, 'dining-bill-back');
      await _tap(tester, 'dining-delete-empty-TA-02');
      expect(_key('dining-take-away-TA-02'), findsNothing);
      expect(_key('dining-take-away-TA-01'), findsOneWidget);

      await _tap(tester, 'dining-mode-dine-in');
      expect(_key('dining-table-M1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }

  testWidgets('kirim ke dapur di ponsel lalu tombol kembali sistem', (
    tester,
  ) async {
    await pump(tester, size: const Size(360, 740));
    // Teras hanya berisi M5 dan M6.
    await _tapText(tester, 'Teras');
    expect(_key('dining-table-M1'), findsNothing);
    await _tap(tester, 'dining-table-M5');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Kopi Susu Aren']);
    await _tap(tester, 'dining-send');
    expect(_key('dining-ticket'), findsOneWidget);
    await _tap(tester, 'dining-ticket-close');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_key('dining-table-M5'), findsOneWidget);
    expect(find.text('Rp 27.720'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('bill kosong lewat tautan: galat, bukan keranjang retail', (
    tester,
  ) async {
    await pump(tester);
    await _tap(tester, 'dining-table-M1');
    await _tap(tester, 'dining-guests-open');
    final id = dining.sales.single.id;
    await tester.binding.handlePushRoute(Routes.cashierBill(id.uuid));
    await tester.pumpAndSettle();
    expect(_key('cashier-bill-error'), findsOneWidget);
    await _tap(tester, 'cashier-bill-back');
    expect(find.text('Meja M1 · Open bill'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('tanpa sesi kasir: bisa kembali ke bill di meja', (
    tester,
  ) async {
    await pump(tester);
    cashier.sessionOpen = false;
    await _tap(tester, 'dining-table-M2');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Es Teh Manis']);
    await _tap(tester, 'dining-pay');
    expect(_key('cashier-no-session'), findsOneWidget);
    await _tap(tester, 'cashier-no-session-bill-back');
    expect(find.text('Meja M2 · Open bill'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('galat panel lama tidak ikut ke lembar menu', (tester) async {
    await pump(tester);
    await _tap(tester, 'dining-table-M3');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Es Teh Manis']);
    await _tap(tester, 'dining-send');
    await _tap(tester, 'dining-ticket-close');
    // Galat aksi apa pun di panel bill.
    dining.nextError = BillItemLocked();
    await _tap(tester, 'dining-request-bill');
    expect(_key('dining-bill-error'), findsOneWidget);
    await _tap(tester, 'dining-add-menu');
    expect(_key('dining-menu'), findsOneWidget);
    expect(_key('dining-menu-error'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  test('kasir palsu tertaut ke meja', () {
    final d = FakeDiningRepository();
    expect(FakeCashierRepository(dining: d).dining, same(d));
    expect(Permission.openBillsManage.key, 'open_bills:manage');
    expect(UuidValue.fromString(d.tables.first.id.uuid), d.tables.first.id);
  });
}
