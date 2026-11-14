import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart'
    show
        BillItemLocked,
        CustomerRow,
        KitchenPrinter,
        PrinterKind,
        PrinterSelection;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_cashier_repository.dart';
import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/modifier_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  // Panel bill memakai ListView yang dibangun malas: di ponsel aksi
  // tambahan di bawah item belum dibangun sampai digulir.
  final panel = find.ancestor(
    of: _key('dining-customer-row'),
    matching: find.byType(Scrollable),
  );
  if (_key(key).evaluate().isEmpty && panel.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(_key(key), 120, scrollable: panel.first);
  }
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
  late FakeSessionRepository session;

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
    bool modifiers = false,
    List<String> mergeable = const [],
    KitchenPrinter? kitchenPrinter,
    KitchenPrinter Function(UuidValue Function(String) category)? barPrinter,
    List<CustomerRow> customers = const [],
    List<String> plainMenus = const [],
    bool discountNeedsPin = true,
  }) async {
    dining = FakeDiningRepository(
      permissions: role == 'owner'
          ? null
          : permissionsForRole(role, isOwner: false),
    )..allowMerge(mergeable);
    dining
      ..discountNeedsPin = discountNeedsPin
      ..kitchenPrinter = kitchenPrinter
      ..customerRows = customers;
    if (barPrinter != null) {
      dining.barPrinter = barPrinter(
        (name) =>
            dining.catalog.categories.firstWhere((c) => c.name == name).id,
      );
    }
    if (modifiers) {
      dining.attachModifiers('Kopi Susu Aren', seedModifierGroups());
    }
    // Menu tanpa tiket dapur dan catatan bebas (F1-10g).
    for (final name in plainMenus) {
      await dining.setMenuFlags(name, sendToKitchen: false, allowNote: false);
    }
    cashier = FakeCashierRepository()..dining = dining;
    printer = FakeReceiptPrinter();
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.tables,
      dining: dining,
      cashier: cashier,
      receiptPrinter: printer,
      session: session = FakeSessionRepository()
        ..current = sampleStaff(name: 'Dimas', role: role),
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

  for (final (size, platform) in const [
    (Size(1280, 800), TargetPlatform.linux),
    (Size(360, 740), TargetPlatform.android),
  ]) {
    testWidgets('gabung meja ${size.width.toInt()} px (F1-10d)', (
      tester,
    ) async {
      await pump(tester, size: size, mergeable: ['M1', 'M2']);
      Future<void> backToTables() async {
        if (size.width >= 600) return;
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }

      await _tap(tester, 'dining-table-M2');
      await _tap(tester, 'dining-guests-open');
      await addMenu(tester, ['Kopi Susu Aren']);
      await backToTables();
      await _tap(tester, 'dining-table-M3');
      await _tap(tester, 'dining-guests-open');
      // M3 tidak *Boleh digabung*: aksi tidak ada.
      expect(_key('dining-merge'), findsNothing);
      await backToTables();
      await _tap(tester, 'dining-table-M1');
      await _tap(tester, 'dining-guests-open');
      await addMenu(tester, ['Es Teh Manis']);

      await _tap(tester, 'dining-merge');
      expect(_key('dining-merge-dialog'), findsOneWidget);
      expect(_key('dining-merge-from-M3'), findsNothing);
      await _tap(tester, 'dining-merge-from-M2');
      expect(dining.merges, hasLength(1));
      expect(_key('dining-merge-dialog'), findsNothing);
      if (size.width >= 600) {
        expect(find.text('Meja M1 · Open bill'), findsOneWidget);
      }
      expect(find.text('Kopi Susu Aren'), findsWidgets);
      expect(find.text('Es Teh Manis'), findsWidgets);

      // Tidak ada lagi meja yang bisa digabung.
      await _tap(tester, 'dining-merge');
      expect(
        find.textContaining('Belum ada meja lain yang bisa digabung'),
        findsOneWidget,
      );
      await _tapText(tester, 'Batal');
      await backToTables();
      expect(
        find.text('Pelayan: Dimas · 2 dari 6 meja terisi'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(platform));
  }

  for (final (size, platform) in const [
    (Size(1280, 800), TargetPlatform.linux),
    (Size(360, 740), TargetPlatform.android),
  ]) {
    testWidgets('menu tanpa tiket dapur & catatan ${size.width.toInt()} px '
        '(F1-10g)', (tester) async {
      await pump(tester, size: size, plainMenus: ['Es Teh Manis']);
      await _tap(tester, 'dining-table-M1');
      await _tap(tester, 'dining-guests-open');
      await _tap(tester, 'dining-add-menu');
      await tester.enterText(
        find.descendant(
          of: find.byKey(const ValueKey('dining-menu-note-0')),
          matching: find.byType(EditableText),
        ),
        'tanpa es',
      );
      await _tap(tester, 'dining-menu-Es Teh Manis');
      // Catatan tetap untuk menu berikutnya.
      expect(_key('dining-menu-note-kept'), findsOneWidget);
      await tester.enterText(_input('dining-menu-search'), 'Kopi Susu');
      await tester.pumpAndSettle();
      await _tap(tester, 'dining-menu-Kopi Susu Aren');
      expect(_key('dining-menu-note-kept'), findsNothing);
      await tester.enterText(_input('dining-menu-search'), '');
      await tester.pumpAndSettle();
      await _tap(tester, 'dining-menu-done');
      final items = dining.bill(dining.sales.single.id).items;
      expect(items.map((i) => i.note), [null, 'tanpa es']);

      await _tap(tester, 'dining-send');
      expect(_key('dining-ticket'), findsOneWidget);
      expect(_key('dining-ticket-served-only'), findsOneWidget);
      await _tapText(tester, 'Tutup');

      if (size.width < 600) {
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
      }
      await _tap(tester, 'dining-table-M2');
      await _tap(tester, 'dining-guests-open');
      await addMenu(tester, ['Es Teh Manis']);
      await _tap(tester, 'dining-send');
      expect(_key('dining-ticket'), findsNothing);
      expect(_key('dining-served-only'), findsOneWidget);
      expect(find.text('Disajikan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant.only(platform));
  }

  testWidgets('pelayan: batalkan bill lewat persetujuan manajer, bayar mati', (
    tester,
  ) async {
    await pump(tester, role: 'waiter');
    await _tap(tester, 'dining-table-M3');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Es Teh Manis']);
    expect(
      find.text('Pembayaran oleh kasir (butuh izin penjualan).'),
      findsOneWidget,
    );
    await _tap(tester, 'dining-void');
    expect(_key('approval-dialog'), findsOneWidget);
    await tester.enterText(_input('approval-pin'), '000000');
    await _tap(tester, 'approval-submit');
    expect(find.text('PIN salah. Sisa 4 percobaan.'), findsOneWidget);
    // Kolom PIN dikosongkan setelah PIN ditolak.
    expect(
      tester.widget<EditableText>(_input('approval-pin')).controller.text,
      isEmpty,
    );
    await tester.enterText(_input('approval-pin'), '123456');
    await _tap(tester, 'approval-submit');
    expect(_key('approval-dialog'), findsNothing);
    await tester.enterText(_input('dining-void-reason'), 'Tamu pergi');
    await _tap(tester, 'dining-void-confirm');
    final owner = session.staff.single;
    expect(dining.voided.values, ['Tamu pergi']);
    expect(dining.voidApprovers.values, [owner.id]);
    expect(session.current!.name, 'Dimas');
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('diskon nota bill 1280 px: terapkan, bayar, hapus', (
    tester,
  ) async {
    await pump(tester);
    await _tap(tester, 'dining-table-M4');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Kopi Susu Aren']);
    expect(find.text('Rp 27.720'), findsWidgets);

    await _tap(tester, 'dining-discount');
    expect(_key('discount-dialog'), findsOneWidget);
    expect(
      find.text('Untuk seluruh bill. Service dan PB1 dihitung setelah diskon.'),
      findsOneWidget,
    );
    // Staf berizin: tanpa catatan PIN.
    expect(_key('discount-needs-pin'), findsNothing);
    await tester.enterText(_input('discount-value-percent'), '10');
    await tester.pumpAndSettle();
    expect(_key('discount-preview'), findsOneWidget);
    await _tap(tester, 'discount-apply');
    expect(_key('discount-dialog'), findsNothing);

    // 24.000 − 2.400 = 21.600; service 1.080; PB1 2.268.
    final totals = _key('dining-bill-totals');
    expect(
      find.descendant(of: totals, matching: find.text('Diskon nota 10%')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: totals, matching: find.text('− Rp 2.400')),
      findsOneWidget,
    );
    expect(find.text('Rp 24.948'), findsWidgets);

    await _tap(tester, 'dining-pay');
    expect(find.text('Pembayaran · Total Rp 24.948'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('payment-bill-discount'),
        matching: find.text('Diskon nota 10%'),
      ),
      findsOneWidget,
    );
    await _tap(tester, 'payment-back');

    // Ketuk baris diskon untuk mengubah; *Hapus diskon* mengembalikan total.
    await _tap(tester, 'dining-bill-discount');
    await _tap(tester, 'discount-remove');
    expect(_key('dining-bill-discount'), findsNothing);
    expect(find.text('Rp 27.720'), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('diskon nota 360 px: pelayan lewat PIN manajer', (tester) async {
    await pump(tester, size: const Size(360, 740), role: 'waiter');
    await _tap(tester, 'dining-table-M3');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Kopi Susu Aren', 'Nasi Goreng Kampung']);

    // Ponsel: tombol ada di bawah daftar item yang digulir.
    await tester.scrollUntilVisible(
      _key('dining-discount'),
      200,
      scrollable: find
          .ancestor(
            of: _key('dining-bill-title'),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await _tap(tester, 'dining-discount');
    expect(_key('discount-needs-pin'), findsOneWidget);
    await _tap(tester, 'discount-kind-amount');
    // Melebihi subtotal ditolak di dialog.
    await tester.enterText(_input('discount-value-amount'), '60000');
    await _tap(tester, 'discount-apply');
    expect(
      find.text('Diskon tidak boleh melebihi atau menghabiskan total.'),
      findsOneWidget,
    );
    await tester.enterText(_input('discount-value-amount'), '5000');
    await _tap(tester, 'discount-apply');
    expect(_key('approval-dialog'), findsOneWidget);
    await tester.enterText(_input('approval-pin'), '123456');
    await _tap(tester, 'approval-submit');
    expect(_key('approval-dialog'), findsNothing);

    expect(
      find.descendant(
        of: _key('dining-bill-totals'),
        matching: find.text('Diskon nota · disetujui Rina'),
      ),
      findsOneWidget,
    );
    expect(dining.discountApprovers.values, [session.staff.single.id]);
    expect(session.current!.name, 'Dimas');
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('diskon baris 1280 px: persen, bayar, hapus', (tester) async {
    await pump(tester);
    await _tap(tester, 'dining-table-M4');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Kopi Susu Aren']);
    final id = dining.items.single.id.uuid;
    // Tetap bisa didiskon setelah dikirim ke dapur.
    await _tap(tester, 'dining-send');
    await _tap(tester, 'dining-ticket-close');
    expect(_key('dining-item-served-$id'), findsOneWidget);
    await _tap(tester, 'dining-item-discount-$id');
    expect(_key('discount-dialog'), findsOneWidget);
    expect(find.text('Diskon baris'), findsOneWidget);
    expect(_key('discount-needs-pin'), findsNothing);
    await tester.enterText(_input('discount-value-percent'), '10');
    await tester.pumpAndSettle();
    await _tap(tester, 'discount-apply');
    expect(_key('discount-dialog'), findsNothing);

    expect(
      tester.widget<Text>(_key('dining-item-discount-line-$id')).data,
      'Diskon 10% · − Rp 2.400',
    );
    expect(find.text('Rp 21.600'), findsWidgets);
    // 21.600 + service 1.080 + PB1 2.268.
    expect(find.text('Rp 24.948'), findsWidgets);
    await _tap(tester, 'dining-pay');
    expect(find.text('Pembayaran · Total Rp 24.948'), findsOneWidget);
    await _tap(tester, 'payment-back');

    await _tap(tester, 'dining-item-discount-$id');
    await _tap(tester, 'discount-remove');
    expect(_key('dining-item-discount-line-$id'), findsNothing);
    expect(find.text('Rp 27.720'), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('diskon baris 360 px: pelayan lewat PIN manajer', (tester) async {
    await pump(tester, size: const Size(360, 740), role: 'waiter');
    await _tap(tester, 'dining-table-M3');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Kopi Susu Aren']);
    expect(tester.takeException(), isNull);
    final id = dining.items.single.id.uuid;
    await _tap(tester, 'dining-item-discount-$id');
    expect(_key('discount-needs-pin'), findsOneWidget);
    await _tap(tester, 'discount-kind-amount');
    await tester.enterText(_input('discount-value-amount'), '30000');
    await _tap(tester, 'discount-apply');
    expect(
      find.text('Diskon tidak boleh melebihi atau menghabiskan total.'),
      findsOneWidget,
    );
    await tester.enterText(_input('discount-value-amount'), '5000');
    await _tap(tester, 'discount-apply');
    expect(_key('approval-dialog'), findsOneWidget);
    await tester.enterText(_input('approval-pin'), '123456');
    await _tap(tester, 'approval-submit');
    expect(_key('approval-dialog'), findsNothing);
    expect(
      tester.widget<Text>(_key('dining-item-discount-line-$id')).data,
      'Diskon · − Rp 5.000',
    );
    expect(dining.itemDiscountApprovers.values, [session.staff.single.id]);
    expect(session.current!.name, 'Dimas');
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('diskon baris: tanpa izin dan sakelar mati tidak tampil', (
    tester,
  ) async {
    await pump(tester, role: 'waiter', discountNeedsPin: false);
    await _tap(tester, 'dining-table-M2');
    await _tap(tester, 'dining-guests-open');
    await addMenu(tester, ['Kopi Susu Aren']);
    final id = dining.items.single.id.uuid;
    expect(_key('dining-item-discount-$id'), findsNothing);
    expect(_key('dining-discount'), findsNothing);
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

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('printer dapur ${size.width.toInt()} px: tiket otomatis, '
        'gagal lalu cetak ulang (F1-10e)', (tester) async {
      const kitchen = KitchenPrinter(
        printer: PrinterSelection(
          kind: PrinterKind.network,
          name: 'Dapur',
          address: '10.0.0.9:9100',
        ),
        paper: ReceiptPaper.mm80,
      );
      await pump(tester, size: size, kitchenPrinter: kitchen);
      if (size.width < 600) {
        await _tapText(tester, 'Teras');
        await _tap(tester, 'dining-table-M5');
      } else {
        await _tap(tester, 'dining-table-M1');
      }
      await _tap(tester, 'dining-guests-open');
      await addMenu(tester, ['Kopi Susu Aren']);
      final hold = printer.hold = Completer<void>();
      await _tap(tester, 'dining-send');
      expect(_key('dining-ticket'), findsOneWidget);
      // Printer dapur lambat: status mencetak, tombol nonaktif.
      expect(_key('dining-ticket-printing-kitchen'), findsOneWidget);
      expect(
        tester.widget<FButton>(_key('dining-ticket-print')).onPress,
        isNull,
      );
      printer.hold = null;
      hold.complete();
      await tester.pumpAndSettle();
      final (target, lines, paper) = printer.prints.single;
      expect(target, kitchen.printer);
      expect(paper, ReceiptPaper.mm80);
      expect(lines.first.text, contains('TIKET DAPUR'));
      expect(lines.every((l) => l.text.length <= 48), isTrue);
      expect(find.text('Tiket dicetak di printer dapur.'), findsOneWidget);
      expect(find.text('Cetak ulang'), findsOneWidget);
      await _tap(tester, 'dining-ticket-close');

      // Kirim berikutnya: printer dapur mati, item tetap di dapur.
      printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
      await addMenu(tester, ['Kopi Susu Aren']);
      await _tap(tester, 'dining-send');
      expect(_key('dining-ticket-print-failed'), findsOneWidget);
      expect(printer.prints, hasLength(1));
      await _tap(tester, 'dining-ticket-print');
      expect(printer.prints, hasLength(2));
      expect(find.text('Tiket dicetak di printer dapur.'), findsOneWidget);
      await _tap(tester, 'dining-ticket-close');
      expect(_key('dining-ticket'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('printer bar ${size.width.toInt()} px: minuman ke bar, '
        'makanan ke dapur, galat bar lalu cetak ulang (F1-10j)', (
      tester,
    ) async {
      const kitchen = KitchenPrinter(
        printer: PrinterSelection(
          kind: PrinterKind.network,
          name: 'Dapur',
          address: '10.0.0.9:9100',
        ),
      );
      const barLan = PrinterSelection(
        kind: PrinterKind.network,
        name: 'Bar',
        address: '10.0.0.7:9100',
      );
      await pump(
        tester,
        size: size,
        kitchenPrinter: kitchen,
        barPrinter: (category) => KitchenPrinter(
          printer: barLan,
          paper: ReceiptPaper.mm80,
          categoryIds: {category('Minuman')},
        ),
      );
      if (size.width < 600) {
        await _tapText(tester, 'Teras');
        await _tap(tester, 'dining-table-M5');
      } else {
        await _tap(tester, 'dining-table-M1');
      }
      await _tap(tester, 'dining-guests-open');
      await addMenu(tester, ['Kopi Susu Aren', 'Nasi Goreng Kampung']);
      await _tap(tester, 'dining-send');
      expect(_key('dining-ticket-kitchen'), findsOneWidget);
      expect(_key('dining-ticket-bar'), findsOneWidget);
      expect(find.text('Tiket dicetak di printer bar.'), findsOneWidget);
      expect(find.text('Tiket dicetak di printer dapur.'), findsOneWidget);
      final byAddress = {
        for (final p in printer.prints)
          p.$1.address: p.$2.map((l) => l.text).join('\n'),
      };
      expect(
        byAddress.keys,
        unorderedEquals(['10.0.0.9:9100', '10.0.0.7:9100']),
      );
      expect(byAddress['10.0.0.7:9100'], contains('TIKET BAR'));
      expect(byAddress['10.0.0.7:9100'], contains('Kopi Susu Aren'));
      expect(byAddress['10.0.0.7:9100'], isNot(contains('Nasi Goreng')));
      expect(byAddress['10.0.0.9:9100'], contains('TIKET DAPUR'));
      expect(byAddress['10.0.0.9:9100'], contains('Nasi Goreng'));
      expect(byAddress['10.0.0.9:9100'], isNot(contains('Kopi Susu')));
      expect(
        printer.prints.firstWhere((p) => p.$1 == barLan).$3,
        ReceiptPaper.mm80,
      );
      await _tap(tester, 'dining-ticket-close');

      // Hanya minuman, printer bar mati: dapur tidak dicetak, cetak ulang
      // bar.
      printer.prints.clear();
      printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
      await addMenu(tester, ['Es Teh Manis']);
      await _tap(tester, 'dining-send');
      expect(_key('dining-ticket-kitchen'), findsNothing);
      expect(_key('dining-ticket-print'), findsNothing);
      expect(_key('dining-ticket-bar-print-failed'), findsOneWidget);
      expect(printer.prints, isEmpty);
      await _tap(tester, 'dining-ticket-bar-reprint');
      expect(printer.prints.single.$1, barLan);
      expect(find.text('Tiket dicetak di printer bar.'), findsOneWidget);
      await _tap(tester, 'dining-ticket-close');
      expect(_key('dining-ticket'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('pelanggan bill ${size.width.toInt()} px: pilih, cari, '
        'hapus (F1-10f)', (tester) async {
      CustomerRow row(String name, {String? group, String? phone}) =>
          CustomerRow(
            customer: Customer(
              id: UuidValue.fromString(newId()),
              tenantId: UuidValue.fromString(newId()),
              name: name,
              phone: phone,
              creditLimit: 0,
              createdAt: DateTime.utc(2026, 11, 1),
              hlc: '',
            ),
            groupName: group,
            termDays: 14,
            outstanding: Money.zero,
            openCount: 0,
            overdueCount: 0,
          );
      await pump(
        tester,
        size: size,
        customers: [
          row('Ani', group: 'Karyawan', phone: '081234'),
          row('Budi'),
        ],
      );
      if (size.width < 600) {
        await _tapText(tester, 'Teras');
        await _tap(tester, 'dining-table-M5');
      } else {
        await _tap(tester, 'dining-table-M1');
      }
      await _tap(tester, 'dining-guests-open');
      expect(find.text('Pelanggan umum'), findsOneWidget);
      expect(find.text('Pilih pelanggan'), findsOneWidget);
      await _tap(tester, 'dining-customer');
      expect(_key('dining-customer-dialog'), findsOneWidget);
      expect(_key('dining-customer-option-Budi'), findsOneWidget);
      await tester.enterText(_input('dining-customer-search'), '0812');
      await tester.pumpAndSettle();
      expect(_key('dining-customer-option-Budi'), findsNothing);
      await _tap(tester, 'dining-customer-option-Ani');
      expect(_key('dining-customer-dialog'), findsNothing);
      expect(find.text('Pelanggan: Ani · Karyawan'), findsOneWidget);
      expect(dining.customerSets, hasLength(1));

      await _tap(tester, 'dining-customer-clear');
      expect(find.text('Pelanggan: Ani · Karyawan'), findsNothing);
      expect(dining.customerSets.last.$2, isNull);
      expect(tester.takeException(), isNull);
    });
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

  testWidgets('modifier 1.8: pilih, total, bill, tiket, struk', (tester) async {
    await pump(tester, modifiers: true);
    await _tap(tester, 'dining-table-M1');
    await _tap(tester, 'dining-guests-open');

    await _tap(tester, 'dining-add-menu');
    await tester.enterText(_input('dining-menu-note-0'), 'less ice');
    await tester.pumpAndSettle();
    await _tap(tester, 'dining-menu-Kopi Susu Aren');
    expect(_key('modifier-sheet'), findsOneWidget);
    expect(find.text('Wajib · pilih 1'), findsOneWidget);
    expect(find.text('Opsional · maks 2'), findsOneWidget);
    // Reguler bawaan sudah terpilih → tombol aktif dengan harga dasar.
    expect(find.text('Tambah ke bill · Rp 24.000'), findsOneWidget);

    await _tap(tester, 'modifier-sheet-option-Besar');
    await _tap(tester, 'modifier-sheet-option-Boba');
    await _tap(tester, 'modifier-sheet-option-Keju'); // habis: diabaikan
    await _tap(tester, 'modifier-sheet-more');
    expect(find.text('Tambah ke bill · Rp 66.000'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('modifier-sheet-note'),
        matching: find.text('less ice'),
      ),
      findsOneWidget,
    );
    await _tap(tester, 'modifier-sheet-add');
    expect(_key('modifier-sheet'), findsNothing);
    expect(_key('dining-menu-added'), findsOneWidget);

    // Menu tanpa modifier langsung masuk bill.
    await _tap(tester, 'dining-menu-Es Teh Manis');
    expect(_key('modifier-sheet'), findsNothing);
    await _tap(tester, 'dining-menu-done');

    expect(_key('dining-item-Kopi Susu Aren + Besar, Boba'), findsOneWidget);
    expect(find.text('+ Besar, Boba'), findsOneWidget);
    expect(find.text('* less ice'), findsOneWidget);
    final kopi = dining.items.firstWhere(
      (i) => i.productName == 'Kopi Susu Aren',
    );
    expect(kopi.lineTotal, 66000);

    await _tap(tester, 'dining-send');
    await _tap(tester, 'dining-ticket-print');
    final ticket = printer.prints.single.$2.map((l) => l.text).toList();
    final at = ticket.indexWhere((l) => l.contains('Kopi Susu Aren'));
    expect(ticket.sublist(at + 1, at + 4), [
      '  + Besar',
      '  + Boba',
      '  * less ice',
    ]);
    await _tap(tester, 'dining-ticket-close');

    await _tap(tester, 'dining-pay');
    expect(
      find.descendant(
        of: _key('payment-bill-summary'),
        matching: find.textContaining('Kopi Susu Aren + Besar, Boba'),
      ),
      findsOneWidget,
    );
    await _tap(tester, 'payment-quick-0');
    await _tap(tester, 'payment-finish');
    final receipt = _key('success-receipt');
    expect(
      find.descendant(
        of: receipt,
        matching: find.textContaining('+ Besar 4.000'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: receipt, matching: find.textContaining('2 x 33.000')),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('modifier 1.8 di ponsel 360 px', (tester) async {
    await pump(tester, size: const Size(360, 740), modifiers: true);
    await _tap(tester, 'dining-table-M1');
    await _tap(tester, 'dining-guests-open');
    await _tap(tester, 'dining-add-menu');
    await _tap(tester, 'dining-menu-Kopi Susu Aren');
    expect(_key('modifier-sheet-option-Pudding'), findsNothing);
    expect(_key('modifier-sheet-add'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('modifier 1.8 menu tanpa catatan bebas: tanpa isian catatan '
      '(F1-10g)', (tester) async {
    await pump(
      tester,
      size: const Size(360, 740),
      modifiers: true,
      plainMenus: ['Kopi Susu Aren'],
    );
    await _tap(tester, 'dining-table-M1');
    await _tap(tester, 'dining-guests-open');
    await _tap(tester, 'dining-add-menu');
    await tester.enterText(_input('dining-menu-note-0'), 'less ice');
    await tester.pumpAndSettle();
    await _tap(tester, 'dining-menu-Kopi Susu Aren');
    expect(_key('modifier-sheet'), findsOneWidget);
    expect(_key('modifier-sheet-note'), findsNothing);
    await _tap(tester, 'modifier-sheet-add');
    expect(dining.bill(dining.sales.single.id).items.single.note, isNull);
    expect(_key('dining-menu-note-kept'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
