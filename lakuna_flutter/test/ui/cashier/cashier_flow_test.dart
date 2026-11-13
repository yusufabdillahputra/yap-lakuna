import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cashier_repository.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/app_harness.dart';
import '../../testing/cashier_seed.dart';
import '../../testing/fake_cashier_repository.dart';
import '../../testing/fake_customers_repository.dart';
import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/qris_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(_key(key)).data!;

void main() {
  Future<FakeCashierRepository> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    bool sessionOpen = true,
    CashierQris? qris,
    Set<Permission>? permissions,
    FakeReceiptPrinter? printer,
    PrinterSelection? selected,
    ReceiptConfig receipt = const ReceiptConfig(settings: ReceiptSettings()),
    FakeSessionRepository? session,
    FakeCustomersRepository? customers,
  }) async {
    final repo = FakeCashierRepository(
      seed: cashierProducts(),
      sessionOpen: sessionOpen,
      qris: qris,
      permissions: permissions,
      printer: selected,
      receipt: receipt,
    );
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.cashier,
      cashier: repo,
      receiptPrinter: printer,
      session: session,
      customers: customers,
    );
    if (customers != null) repo.customerSource = () => customers.rows;
    return repo;
  }

  String productKey(FakeCashierRepository repo, String name) =>
      'cashier-product-'
      '${repo.catalog.products.firstWhere((p) => p.name == name).id.uuid}';

  Future<void> scan(WidgetTester tester, String code) async {
    await tester.enterText(_input('cashier-search'), code);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  testWidgets('desktop lebar tablet: scan, pilih satuan, bayar tunai', (
    tester,
  ) async {
    final repo = await pump(tester, size: const Size(1024, 768));
    expect(_key('cashier-empty-cart'), findsOneWidget);
    expect(find.text('Warung Contoh · Cabang Pusat'), findsOneWidget);

    await scan(tester, '8990001');
    expect(_text(tester, 'cashier-total'), 'Rp 72.500');
    // Kolom cari dikosongkan untuk scan berikutnya.
    expect(
      tester.widget<EditableText>(_input('cashier-search')).controller.text,
      isEmpty,
    );

    await scan(tester, '0000');
    expect(_key('cashier-scan-unknown'), findsOneWidget);

    // Minyak punya satuan Dus → dialog pilihan.
    await _tap(tester, productKey(repo, 'Minyak Goreng'));
    expect(find.text('2 L · Dus (6)'), findsOneWidget);
    await _tap(tester, 'cashier-option-1');
    expect(_text(tester, 'cashier-total'), 'Rp 282.500');
    // Kolom cari tetap fokus agar scanner berikutnya langsung masuk.
    expect(
      tester.widget<EditableText>(_input('cashier-search')).focusNode.hasFocus,
      isTrue,
    );

    await _tap(tester, 'cashier-pay');
    expect(_key('payment-cash'), findsOneWidget);
    expect(_text(tester, 'payment-short'), 'Kurang Rp 282.500');
    expect(find.text('Uang pas'), findsOneWidget);

    for (final k in ['3', '000', '0', '0']) {
      await _tap(tester, 'payment-key-$k');
    }
    expect(
      tester.widget<EditableText>(_input('payment-received')).controller.text,
      '300.000',
    );
    expect(_text(tester, 'payment-change'), 'Rp 17.500');

    await _tap(tester, 'payment-finish');
    expect(_key('success-title'), findsOneWidget);
    expect(_text(tester, 'success-change'), 'Rp 17.500');
    expect(find.text('Nota PST-K01-261103-0001'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('success-receipt'),
        matching: find.textContaining('PST-K01-261103-0001'),
      ),
      findsOneWidget,
    );
    final (lines, payments) = repo.checkouts.single;
    expect(lines, hasLength(2));
    expect(payments.single.amount?.value, 300000);

    await _tap(tester, 'success-new');
    expect(_key('cashier-empty-cart'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('desktop: ketik uang diterima, kembali ke pesanan', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    expect(_text(tester, 'cashier-total'), 'Rp 4.000');

    await _tap(tester, 'cashier-pay');
    await tester.enterText(_input('payment-received'), '5000');
    await tester.pumpAndSettle();
    expect(_text(tester, 'payment-change'), 'Rp 1.000');

    await _tap(tester, 'payment-back');
    expect(_text(tester, 'cashier-total'), 'Rp 4.000');

    // Masuk lagi: uang diterima mulai dari nol.
    await _tap(tester, 'cashier-pay');
    expect(_text(tester, 'payment-short'), 'Kurang Rp 4.000');
    await _tap(tester, 'payment-quick-0');
    expect(_text(tester, 'payment-change'), 'Rp 0');
    expect(repo.checkouts, isEmpty);
  }, variant: TargetPlatformVariant.only(TargetPlatform.windows));

  testWidgets('keranjang tetap saat pindah menu lalu kembali (F1-04c)', (
    tester,
  ) async {
    final repo = await pump(tester);
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    expect(_text(tester, 'cashier-total'), 'Rp 4.000');

    await _tap(tester, 'nav-home');
    expect(_key('cashier-total'), findsNothing);
    await _tap(tester, 'nav-cashier');
    expect(_text(tester, 'cashier-total'), 'Rp 4.000');
    expect(tester.takeException(), isNull);
  });

  testWidgets('bayar open bill tidak memakai keranjang retail (F1-04c)', (
    tester,
  ) async {
    final dining = FakeDiningRepository();
    final repo = FakeCashierRepository(seed: cashierProducts())
      ..dining = dining;
    await pumpLakuna(
      tester,
      initialLocation: Routes.cashier,
      cashier: repo,
      dining: dining,
    );
    final kopi = dining.catalog.products
        .firstWhere((p) => p.name == 'Kopi Susu Aren')
        .variants
        .single
        .id;
    final opened = await dining.openTable(dining.tables.first.id, 2);
    final bill = (opened as Ok<OpenBill>).value;
    await dining.addItem(
      bill.id,
      SaleLineRequest(variantId: kopi, quantity: Qty.one),
    );

    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    await tester.binding.handlePushRoute(Routes.cashierBill(bill.id.uuid));
    await tester.pumpAndSettle();
    // Tahap bayar bill: keranjang retail tidak ikut.
    expect(_key('cashier-total'), findsNothing);
    await _tap(tester, 'payment-back');
    await _tap(tester, 'nav-cashier');
    expect(_text(tester, 'cashier-total'), 'Rp 4.000');
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets(
      '${size.width.toInt()} px: open bill F&B dibayar kredit (F1-13b)',
      (tester) async {
        final dining = FakeDiningRepository();
        final ani = CustomerRow(
          customer: Customer(
            id: UuidValue.fromString(newId()),
            tenantId: UuidValue.fromString(newId()),
            name: 'Toko Bu Ani',
            creditLimit: 1000000,
            createdAt: DateTime.utc(2026, 11, 1),
            hlc: '',
          ),
          groupName: null,
          termDays: 14,
          outstanding: Money.zero,
          openCount: 0,
          overdueCount: 0,
        );
        final repo = FakeCashierRepository(seed: cashierProducts())
          ..dining = dining
          ..creditRows = [ani];
        await pumpLakuna(
          tester,
          size: size,
          initialLocation: Routes.cashier,
          cashier: repo,
          dining: dining,
        );
        final kopi = dining.catalog.products
            .firstWhere((p) => p.name == 'Kopi Susu Aren')
            .variants
            .single
            .id;
        final opened = await dining.openTable(dining.tables.first.id, 2);
        final bill = (opened as Ok<OpenBill>).value;
        await dining.addItem(
          bill.id,
          SaleLineRequest(variantId: kopi, quantity: Qty.one),
        );
        await tester.binding.handlePushRoute(Routes.cashierBill(bill.id.uuid));
        await tester.pumpAndSettle();
        await _tap(tester, 'payment-method-credit');
        expect(_key('credit-panel'), findsOneWidget);
        await _tap(tester, 'credit-customer-${ani.customer.id.uuid}');
        await _tap(tester, 'payment-finish');
        expect(_key('success-title'), findsOneWidget);
        expect(repo.credits.single.customerId, ani.customer.id);
        expect(repo.paidBills.single.$1, bill.id);
        expect(find.textContaining('Toko Bu Ani'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('kartu: no. approval, galat simpan ditampilkan', (tester) async {
    final repo = await pump(tester);
    await scan(tester, 'KOP');
    await _tap(tester, 'cashier-pay');
    await _tap(tester, 'payment-method-card');
    expect(_key('payment-noncash'), findsOneWidget);
    expect(find.text('Jumlah dibayar sama dengan total Rp 2.000.'), findsOne);

    await tester.enterText(_input('payment-reference'), 'x' * 41);
    await tester.pumpAndSettle();
    expect(find.text('Maksimal 40 karakter'), findsOneWidget);
    await _tap(tester, 'payment-finish');
    expect(repo.checkouts, isEmpty);

    await tester.enterText(_input('payment-reference'), '004512');
    await tester.pumpAndSettle();
    repo.nextError = SaleItemUnavailable(UuidValue.fromString(newId()));
    await _tap(tester, 'payment-finish');
    expect(_key('payment-error'), findsOneWidget);
    expect(
      find.text('Ada produk yang tidak tersedia lagi. Periksa pesanan.'),
      findsOneWidget,
    );

    await _tap(tester, 'payment-finish');
    expect(repo.checkouts.single.$2.single.reference, '004512');
    expect(_key('success-title'), findsOneWidget);
    expect(_key('success-change'), findsNothing);
  });

  testWidgets('ponsel: bilah bawah, sheet pesanan, stok minus', (
    tester,
  ) async {
    final repo = await pump(tester, size: const Size(360, 740));
    expect(_key('cashier-mobile-bar'), findsNothing);
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    expect(_key('cashier-mobile-bar'), findsOneWidget);
    expect(find.text('1 produk · 2 item'), findsOneWidget);

    await _tap(tester, 'cashier-view-order');
    expect(_text(tester, 'cashier-total'), 'Rp 4.000');
    await _tap(tester, 'cashier-line-0-inc');
    expect(_text(tester, 'cashier-total'), 'Rp 6.000');

    // Tombol bayar di sheet menutup sheet dan membuka tahap bayar.
    await _tap(tester, 'cashier-pay');
    expect(_key('payment-cash'), findsOneWidget);
    await _tap(tester, 'payment-method-transfer');
    await _tap(tester, 'payment-finish');
    expect(_key('success-title'), findsOneWidget);
    expect(find.text('Stok jadi minus'), findsOneWidget);
    expect(repo.checkouts.single.$2.single.method, PaymentMethod.transfer);
  });

  testWidgets('tablet Android: tanpa fokus otomatis (keyboard tidak muncul)', (
    tester,
  ) async {
    await pump(tester, size: const Size(1024, 768));
    expect(
      tester.widget<EditableText>(_input('cashier-search')).focusNode.hasFocus,
      isFalse,
    );
    await scan(tester, 'KOP');
    await _tap(tester, 'cashier-pay');
    expect(
      tester
          .widget<EditableText>(_input('payment-received'))
          .focusNode
          .hasFocus,
      isFalse,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));

  testWidgets('kolom cari dan saringan tetap selaras setelah kembali', (
    tester,
  ) async {
    final repo = await pump(tester);
    await tester.enterText(_input('cashier-search'), 'kopi');
    await tester.pumpAndSettle();
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    await _tap(tester, 'cashier-pay');
    await _tap(tester, 'payment-back');
    expect(
      tester.widget<EditableText>(_input('cashier-search')).controller.text,
      'kopi',
    );
    expect(_key(productKey(repo, 'Beras Premium')), findsNothing);
  });

  testWidgets('tombol kembali sistem: bayar → pesanan, berhasil → baru', (
    tester,
  ) async {
    final repo = await pump(tester);
    await scan(tester, 'KOP');
    await _tap(tester, 'cashier-pay');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_key('payment-cash'), findsNothing);
    expect(_text(tester, 'cashier-total'), 'Rp 2.000');

    await _tap(tester, 'cashier-pay');
    await _tap(tester, 'payment-quick-0');
    await _tap(tester, 'payment-finish');
    expect(_key('success-title'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(_key('cashier-empty-cart'), findsOneWidget);
    expect(repo.checkouts, hasLength(1));
  });

  testWidgets('tanpa sesi kasir: arahkan ke Sesi kasir', (tester) async {
    await pump(tester, sessionOpen: false);
    expect(_key('cashier-no-session'), findsOneWidget);
    await _tap(tester, 'cashier-open-session');
    expect(_key('cashier-no-session'), findsNothing);
    expect(find.byKey(const ValueKey('cash-open-card')), findsOneWidget);
  });

  group('struk (1.12)', () {
    const rpp = PrinterSelection(
      kind: PrinterKind.bluetooth,
      name: 'RPP02N',
      address: '66:22:B1:00:00:01',
    );

    Future<void> sellCard(WidgetTester tester) async {
      await scan(tester, 'KOP');
      await _tap(tester, 'cashier-pay');
      await _tap(tester, 'payment-method-card');
      await _tap(tester, 'payment-finish');
      expect(_key('success-title'), findsOneWidget);
    }

    testWidgets('printer Bluetooth: cetak, gagal, coba lagi, bagikan PDF', (
      tester,
    ) async {
      final printer = FakeReceiptPrinter();
      await pump(tester, printer: printer, selected: rpp);
      await sellCard(tester);
      expect(find.text('RPP02N · Bluetooth · 58 mm'), findsOneWidget);
      expect(printer.prints, isEmpty); // cetak otomatis mati
      expect(_key('receipt-auto-print-note'), findsOneWidget);

      printer.nextFailure = const PrinterFailure(
        PrinterFailureReason.bluetoothOff,
      );
      await _tap(tester, 'receipt-print');
      expect(
        find.text('Bluetooth mati. Nyalakan lalu coba lagi.'),
        findsOneWidget,
      );
      await _tap(tester, 'receipt-print-retry');
      expect(_key('receipt-printed'), findsOneWidget);
      final (target, lines, paper) = printer.prints.single;
      expect(target, rpp);
      expect(paper, ReceiptPaper.mm58);
      expect(lines.first.text, 'WARUNG CONTOH');
      expect(lines.last.text, 'Terima kasih, sampai jumpa lagi!');

      await _tap(tester, 'receipt-share');
      expect(printer.shares.single.$3, 'PST-K01-261103-0001.pdf');
      expect(_key('receipt-pdf-saved'), findsOneWidget);
    });

    testWidgets('tanpa printer: dialog sistem; cetak otomatis 80 mm sekali', (
      tester,
    ) async {
      final printer = FakeReceiptPrinter();
      await pump(
        tester,
        printer: printer,
        selected: const PrinterSelection(
          kind: PrinterKind.network,
          name: '10.0.0.9',
          address: '10.0.0.9:9100',
        ),
        receipt: const ReceiptConfig(
          settings: ReceiptSettings(
            paper: ReceiptPaper.mm80,
            footer: 'Sampai jumpa',
            autoPrint: true,
          ),
        ),
      );
      await sellCard(tester);
      expect(printer.prints, hasLength(1));
      expect(printer.prints.single.$3, ReceiptPaper.mm80);
      expect(printer.prints.single.$2.last.text, 'Sampai jumpa');
      expect(_key('receipt-printed'), findsOneWidget);
      expect(_key('receipt-auto-print-note'), findsNothing);
      await tester.pumpAndSettle();
      expect(printer.prints, hasLength(1));
    });

    testWidgets('ponsel: belum ada printer, tombol cetak membuka dialog', (
      tester,
    ) async {
      final printer = FakeReceiptPrinter();
      await pump(tester, size: const Size(390, 844), printer: printer);
      await sellCard(tester);
      expect(find.text('Belum ada printer'), findsOneWidget);
      await _tap(tester, 'receipt-print');
      expect(printer.prints.single.$1.kind, PrinterKind.system);
      expect(_key('receipt-printed'), findsNothing);
    });
  });

  testWidgets('QRIS statis tablet: perbesar, belum masuk, sudah terbayar', (
    tester,
  ) async {
    final repo = await pump(
      tester,
      size: const Size(1194, 834),
      qris: sampleQris(),
    );
    await scan(tester, 'KOP');
    await _tap(tester, 'cashier-pay');
    await _tap(tester, 'payment-method-qris');
    expect(_key('payment-qris'), findsOneWidget);
    expect(_text(tester, 'qris-amount'), 'Rp 2.000');
    expect(find.text('Menunggu konfirmasi kasir'), findsOneWidget);
    expect(find.text('WARUNG CONTOH · NMID ID10234567890 · A01'), findsOne);
    expect(
      find.text('Dana masuk ke: Rekening BCA 123-456-7890'),
      findsOneWidget,
    );
    expect(_key('payment-finish'), findsNothing);

    await _tap(tester, 'qris-enlarge');
    expect(_key('qris-fullscreen'), findsOneWidget);
    await _tap(tester, 'qris-fullscreen-close');
    expect(_key('qris-fullscreen'), findsNothing);

    await _tap(tester, 'qris-not-received');
    expect(_key('payment-cash'), findsOneWidget);
    expect(repo.checkouts, isEmpty);

    await _tap(tester, 'payment-method-qris');
    await _tap(tester, 'qris-confirm');
    expect(_key('success-title'), findsOneWidget);
    expect(find.text('QRIS statis Rp 2.000 · 10.44 · Sari'), findsOneWidget);
    expect(_key('success-change'), findsNothing);
    expect(
      find.descendant(
        of: _key('success-receipt'),
        matching: find.textContaining(RegExp(r'^QRIS statis +2\.000$')),
      ),
      findsOneWidget,
    );
    final payment = repo.checkouts.single.$2.single;
    expect(payment.method, PaymentMethod.qrisStatic);
    expect(payment.confirmed, isTrue);
  });

  testWidgets('QRIS tanpa izin konfirmasi: Sudah Terbayar mati', (
    tester,
  ) async {
    await pump(
      tester,
      qris: sampleQris(),
      permissions: {Permission.salesCreate},
    );
    await scan(tester, 'KOP');
    await _tap(tester, 'cashier-pay');
    await _tap(tester, 'payment-method-qris');
    expect(_key('qris-no-permission'), findsOneWidget);
    expect(
      tester.widget<FButton>(_key('qris-confirm')).onPress,
      isNull,
    );
  });

  testWidgets('QRIS nonaktif: pilihan QRIS tidak muncul', (tester) async {
    await pump(tester);
    await scan(tester, 'KOP');
    await _tap(tester, 'cashier-pay');
    expect(_key('payment-method-qris'), findsNothing);
    expect(_key('payment-method-split'), findsOneWidget);
  });

  testWidgets('ponsel QRIS: gambar layar penuh dan tombol di bawah', (
    tester,
  ) async {
    final repo = await pump(
      tester,
      size: const Size(360, 740),
      qris: sampleQris(),
    );
    await _tap(tester, productKey(repo, 'Kopi Sachet'));
    await _tap(tester, 'cashier-view-order');
    await _tap(tester, 'cashier-pay');
    await _tap(tester, 'payment-method-qris');
    expect(find.text('Ketuk gambar untuk layar penuh'), findsOneWidget);
    await _tap(tester, 'qris-image');
    expect(_key('qris-fullscreen'), findsOneWidget);
    await _tap(tester, 'qris-fullscreen-close');
    await _tap(tester, 'qris-confirm');
    expect(_key('success-title'), findsOneWidget);
  });

  testWidgets('split tunai + QRIS: konfirmasi di dialog, kembalian', (
    tester,
  ) async {
    final repo = await pump(tester, qris: sampleQris());
    for (var i = 0; i < 3; i++) {
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
    }
    await _tap(tester, 'cashier-pay');
    await _tap(tester, 'payment-method-split');
    expect(_key('payment-split'), findsOneWidget);
    expect(_text(tester, 'split-remaining'), 'Rp 6.000');
    expect(
      tester.widget<EditableText>(_input('split-amount')).controller.text,
      '6.000',
    );

    // QRIS 4.000 dulu, lalu tunai 5.000 (kembalian 3.000).
    await _tap(tester, 'split-method-qrisStatic');
    await tester.enterText(_input('split-amount'), '4000');
    await tester.pumpAndSettle();
    await _tap(tester, 'split-add');
    expect(find.text('Menunggu'), findsOneWidget);
    expect(_text(tester, 'split-remaining'), 'Rp 2.000');

    await _tap(tester, 'split-method-cash');
    await tester.enterText(_input('split-amount'), '5000');
    await tester.pumpAndSettle();
    await _tap(tester, 'split-add');
    expect(_text(tester, 'split-remaining'), 'Rp 0');
    expect(_text(tester, 'split-change'), 'Rp 3.000');
    expect(_key('split-pending-note'), findsOneWidget);
    expect(
      tester.widget<FButton>(_key('payment-finish')).onPress,
      isNull,
    );

    // Belum masuk menghapus bagian QRIS.
    await _tap(tester, 'split-part-0-confirm');
    expect(_key('qris-dialog'), findsOneWidget);
    await _tap(tester, 'qris-dialog-reject');
    expect(_key('split-part-1'), findsNothing);
    expect(_text(tester, 'split-remaining'), 'Rp 1.000');

    await _tap(tester, 'split-method-qrisStatic');
    await _tap(tester, 'split-add');
    await _tap(tester, 'split-part-1-confirm');
    await _tap(tester, 'qris-dialog-confirm');
    expect(find.text('Menunggu'), findsNothing);
    await _tap(tester, 'payment-finish');

    expect(_key('success-title'), findsOneWidget);
    expect(find.text('Split · 2 metode Rp 6.000 · 10.44 · Sari'), findsOne);
    expect(_text(tester, 'success-change'), 'Rp 0');
    final payments = repo.checkouts.single.$2;
    expect(payments.map((p) => (p.method, p.amount?.value)), [
      (PaymentMethod.cash, 5000),
      (PaymentMethod.qrisStatic, 1000),
    ]);
  });

  group('kredit / piutang (1.5b)', () {
    CustomerRow row(String name, {int limit = 0, int debt = 0}) => CustomerRow(
      customer: Customer(
        id: UuidValue.fromString(newId()),
        tenantId: UuidValue.fromString(newId()),
        name: name,
        phone: '081322221010',
        creditLimit: limit,
        createdAt: DateTime.utc(2026, 11, 1),
        hlc: '',
      ),
      groupName: 'Grosir',
      termDays: 14,
      outstanding: Money(debt),
      openCount: debt > 0 ? 1 : 0,
      overdueCount: 0,
    );

    for (final size in const [Size(1280, 800), Size(360, 740)]) {
      testWidgets('${size.width.toInt()} px: pilih pelanggan, DP, simpan', (
        tester,
      ) async {
        final repo = await pump(tester, size: size);
        final ani = row('Toko Bu Ani', limit: 2000000, debt: 100000);
        repo.creditRows = [row('Pak Darto'), ani];
        await _tap(tester, productKey(repo, 'Kopi Sachet'));
        if (size.width < 600) await _tap(tester, 'cashier-view-order');
        await _tap(tester, 'cashier-pay');
        await _tap(tester, 'payment-method-credit');
        expect(_key('credit-panel'), findsOneWidget);
        expect(
          tester.widget<FButton>(_key('payment-finish')).onPress,
          isNull,
        );
        await _tap(tester, 'credit-customer-${ani.customer.id.uuid}');
        expect(_key('credit-selected'), findsOneWidget);
        expect(_key('credit-summary'), findsOneWidget);
        await _tap(tester, 'payment-finish');
        expect(_key('success-title'), findsOneWidget);
        expect(repo.credits.single.customerId, ani.customer.id);
        expect(repo.credits.single.dueOn, DateTime.utc(2026, 11, 17));
        expect(find.textContaining('Toko Bu Ani'), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('tanpa debts:manage: pilihan kredit tidak ada', (
      tester,
    ) async {
      final repo = await pump(
        tester,
        permissions: {Permission.salesCreate, Permission.cashSessionOpen},
      );
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-pay');
      expect(_key('payment-method-credit'), findsNothing);
    });
  });

  group('diskon manual (1.4b)', () {
    Future<void> discount(
      WidgetTester tester, {
      required DiscountKind kind,
      required String value,
    }) async {
      expect(_key('discount-dialog'), findsOneWidget);
      if (kind == DiscountKind.amount) {
        await _tap(tester, 'discount-kind-amount');
      }
      await tester.enterText(_input('discount-value-${kind.name}'), value);
      await tester.pumpAndSettle();
    }

    for (final size in const [Size(1440, 900), Size(360, 740)]) {
      testWidgets('${size.width.toInt()} px: diskon baris dan nota, bayar', (
        tester,
      ) async {
        final repo = await pump(tester, size: size);
        final mobile = size.width < 600;
        await _tap(tester, productKey(repo, 'Kopi Sachet'));
        await _tap(tester, productKey(repo, 'Kopi Sachet'));
        if (mobile) await _tap(tester, 'cashier-view-order');
        expect(_text(tester, 'cashier-total'), 'Rp 4.000');

        // Diskon baris lewat tekan lama: Rp 1.000.
        await tester.longPress(_key('cashier-line-0-info'));
        await tester.pumpAndSettle();
        expect(find.text('Diskon baris'), findsOneWidget);
        await discount(tester, kind: DiscountKind.amount, value: '5000');
        await _tap(tester, 'discount-apply');
        expect(
          find.text('Diskon tidak boleh melebihi atau menghabiskan total.'),
          findsOneWidget,
        );
        await tester.enterText(_input('discount-value-amount'), '1000');
        await tester.pumpAndSettle();
        expect(_text(tester, 'discount-preview'), 'Potongan Rp 1.000');
        await _tap(tester, 'discount-apply');
        expect(_key('discount-dialog'), findsNothing);
        expect(_text(tester, 'cashier-line-0-discount'), 'Diskon · − Rp 1.000');
        expect(_text(tester, 'cashier-line-discounts'), '− Rp 1.000');
        expect(_text(tester, 'cashier-total'), 'Rp 3.000');

        // Diskon nota 10% dari Rp 3.000.
        await _tap(tester, 'cashier-discount');
        expect(find.text('Diskon nota'), findsOneWidget);
        expect(_key('discount-needs-pin'), findsNothing);
        await discount(tester, kind: DiscountKind.percent, value: '10');
        expect(_text(tester, 'discount-preview'), 'Potongan Rp 300');
        await _tap(tester, 'discount-apply');
        expect(_text(tester, 'cashier-bill-discount-amount'), '− Rp 300');
        expect(find.text('Diskon nota 10%'), findsOneWidget);
        expect(_text(tester, 'cashier-total'), 'Rp 2.700');

        await _tap(tester, 'cashier-pay');
        await _tap(tester, 'payment-quick-0');
        await _tap(tester, 'payment-finish');
        expect(_key('success-title'), findsOneWidget);
        final (lines, payments) = repo.checkouts.single;
        expect(lines.single.discount, ManualDiscount.amount(const Money(1000)));
        expect(payments.single.amount?.value, 2700);
        expect(repo.discounts.single, (
          ManualDiscount.percent(const BasisPoints(1000)),
          null,
        ));
      }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
    }

    testWidgets('hapus diskon nota', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-discount');
      expect(_key('discount-remove'), findsNothing);
      await discount(tester, kind: DiscountKind.amount, value: '500');
      await _tap(tester, 'discount-apply');
      expect(_text(tester, 'cashier-total'), 'Rp 1.500');
      await _tap(tester, 'cashier-bill-discount');
      await _tap(tester, 'discount-remove');
      expect(_key('cashier-bill-discount'), findsNothing);
      expect(_text(tester, 'cashier-total'), 'Rp 2.000');
    });

    testWidgets('kasir tanpa izin: PIN manajer, penyetuju di total', (
      tester,
    ) async {
      final session = FakeSessionRepository()
        ..current = sampleStaff(name: 'Sari', role: 'cashier');
      final repo = await pump(
        tester,
        size: const Size(360, 740),
        permissions: {Permission.salesCreate, Permission.cashSessionOpen},
        session: session,
      );
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-view-order');
      await _tap(tester, 'cashier-discount');
      expect(_key('discount-needs-pin'), findsOneWidget);
      await discount(tester, kind: DiscountKind.percent, value: '5');
      await _tap(tester, 'discount-apply');
      expect(_key('approval-dialog'), findsOneWidget);
      await tester.enterText(_input('approval-pin'), '123456');
      await tester.pumpAndSettle();
      await _tap(tester, 'approval-submit');
      expect(find.text('Diskon nota 5% · disetujui Yusuf'), findsOneWidget);
      expect(_text(tester, 'cashier-total'), 'Rp 1.900');
      expect(
        session.approvals.single,
        (session.staff.single.id, '123456', Permission.salesDiscount),
      );

      // Diskon berikutnya di keranjang yang sama tidak meminta PIN lagi.
      await _tap(tester, 'cashier-bill-discount');
      expect(_key('discount-needs-pin'), findsNothing);
      await _tap(tester, 'discount-remove');

      // Keranjang dikosongkan: persetujuan hangus.
      await _tap(tester, 'cashier-clear');
      Navigator.of(tester.element(_key('cashier-clear'))).pop();
      await tester.pumpAndSettle();
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-view-order');
      await _tap(tester, 'cashier-discount');
      expect(_key('discount-needs-pin'), findsOneWidget);
    });

    testWidgets('tanpa izin dan sakelar PIN mati: tombol diskon tidak ada', (
      tester,
    ) async {
      final repo = FakeCashierRepository(
        seed: cashierProducts(),
        permissions: {Permission.salesCreate, Permission.cashSessionOpen},
      )..salesRules = const SalesRules(discountNeedsPin: false);
      await pumpLakuna(tester, initialLocation: Routes.cashier, cashier: repo);
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      expect(_key('cashier-discount'), findsNothing);
      await tester.longPress(_key('cashier-line-0-info'));
      await tester.pumpAndSettle();
      expect(_key('discount-dialog'), findsNothing);
    });
  });

  group('pelanggan baru dari Kasir (F1-04f)', () {
    for (final size in const [Size(1280, 800), Size(360, 740)]) {
      testWidgets('${size.width.toInt()} px: dari pemilih, terpasang di nota', (
        tester,
      ) async {
        final customers = FakeCustomersRepository(seed: false);
        final repo = await pump(tester, size: size, customers: customers);
        await _tap(tester, productKey(repo, 'Kopi Sachet'));
        if (size.width < 600) await _tap(tester, 'cashier-view-order');

        await _tap(tester, 'cashier-customer');
        await tester.enterText(_input('customer-picker-search'), 'Siti Aminah');
        await tester.pumpAndSettle();
        await _tap(tester, 'customer-picker-new');
        expect(_key('customer-form'), findsOneWidget);
        // Kata pencarian menjadi nama.
        expect(
          tester
              .widget<EditableText>(_input('customer-form-name'))
              .controller
              .text,
          'Siti Aminah',
        );
        await tester.enterText(_input('customer-form-phone'), '081234567890');
        await _tap(tester, 'customer-form-save');
        expect(_key('customer-form'), findsNothing);
        expect(_key('customer-picker'), findsNothing);
        expect(_text(tester, 'cashier-customer-name'), 'Siti Aminah');
        expect(customers.customers.single.phone, '081234567890');
      }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
    }

    testWidgets('dari panel kredit: pelanggan baru langsung terpilih', (
      tester,
    ) async {
      final customers = FakeCustomersRepository(seed: false);
      final repo = await pump(tester, customers: customers);
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-pay');
      await _tap(tester, 'payment-method-credit');
      expect(_key('credit-no-customers'), findsOneWidget);
      await _tap(tester, 'credit-new-customer');
      await tester.enterText(_input('customer-form-name'), 'Warung Sari');
      await tester.enterText(_input('customer-form-limit'), '500000');
      await _tap(tester, 'customer-form-save');
      expect(_key('credit-selected'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('credit-selected'),
          matching: find.text('Warung Sari'),
        ),
        findsOneWidget,
      );
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

    testWidgets('tanpa customers:manage: tombol tidak tampil', (tester) async {
      final repo = await pump(
        tester,
        permissions: {Permission.salesCreate, Permission.debtsManage},
        customers: FakeCustomersRepository(seed: false),
      );
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-customer');
      expect(_key('customer-picker'), findsOneWidget);
      expect(_key('customer-picker-new'), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  });

  group('pelanggan & nota tersimpan (F1-04d)', () {
    CustomerRow row(String name, {int limit = 0, int overdue = 0}) =>
        CustomerRow(
          customer: Customer(
            id: UuidValue.fromString(newId()),
            tenantId: UuidValue.fromString(newId()),
            name: name,
            phone: '081322221010',
            creditLimit: limit,
            createdAt: DateTime.utc(2026, 11, 1),
            hlc: '',
          ),
          groupName: 'Grosir',
          termDays: 14,
          outstanding: Money.zero,
          openCount: overdue,
          overdueCount: overdue,
        );

    for (final size in const [Size(1280, 800), Size(360, 740)]) {
      testWidgets(
        '${size.width.toInt()} px: pilih pelanggan, simpan, lanjutkan, bayar',
        (tester) async {
          final repo = await pump(tester, size: size);
          final mobile = size.width < 600;
          final ani = row('Toko Bu Ani', limit: 850000);
          repo.creditRows = [row('Andi Pratama', overdue: 1), ani];

          await _tap(tester, productKey(repo, 'Kopi Sachet'));
          await _tap(tester, productKey(repo, 'Kopi Sachet'));
          if (mobile) await _tap(tester, 'cashier-view-order');
          expect(_text(tester, 'cashier-customer-name'), 'Pelanggan umum');

          // Pilih pelanggan: cari, sisa limit, lewat tempo.
          await _tap(tester, 'cashier-customer');
          expect(_key('customer-picker'), findsOneWidget);
          expect(find.text('Sisa limit Rp 850.000'), findsOneWidget);
          expect(find.text('Lewat tempo'), findsOneWidget);
          await tester.enterText(_input('customer-picker-search'), 'zzz');
          await tester.pumpAndSettle();
          expect(_key('customer-picker-no-match'), findsOneWidget);
          await tester.enterText(_input('customer-picker-search'), 'ani');
          await tester.pumpAndSettle();
          await _tap(tester, 'customer-picker-${ani.customer.id.uuid}');
          expect(_key('customer-picker'), findsNothing);
          expect(_text(tester, 'cashier-customer-name'), 'Toko Bu Ani');

          // Simpan nota atas nama pelanggan.
          await _tap(tester, 'cashier-park');
          expect(_key('park-customer'), findsOneWidget);
          expect(_key('park-note'), findsNothing);
          await _tap(tester, 'park-save');
          expect(_key('park-dialog'), findsNothing);
          expect(repo.parked, hasLength(1));
          expect(repo.parked.single.customerId, ani.customer.id);
          if (mobile) {
            // Keranjang kosong: sheet pesanan ditutup bersama bilah bawah.
            Navigator.of(tester.element(_key('cashier-park'))).pop();
            await tester.pumpAndSettle();
            expect(_key('cashier-mobile-bar'), findsNothing);
          } else {
            expect(_key('cashier-empty-cart'), findsOneWidget);
            expect(_text(tester, 'cashier-customer-name'), 'Pelanggan umum');
          }

          // Daftar nota tersimpan → lanjutkan → bayar menghapus nota.
          expect(
            find.descendant(
              of: _key('cashier-parked'),
              matching: find.text(mobile ? '1' : 'Nota tersimpan (1)'),
            ),
            findsOneWidget,
          );
          await _tap(tester, 'cashier-parked');
          expect(_key('parked-list'), findsOneWidget);
          expect(find.text('Toko Bu Ani'), findsOneWidget);
          expect(
            find.text('1 item · disimpan 08.12 oleh Sari'),
            findsOneWidget,
          );
          final id = repo.parked.single.id;
          await _tap(tester, 'parked-resume-${id.uuid}');
          expect(_key('parked-list'), findsNothing);
          if (mobile) await _tap(tester, 'cashier-view-order');
          expect(_text(tester, 'cashier-customer-name'), 'Toko Bu Ani');
          expect(_text(tester, 'cashier-total'), 'Rp 4.000');
          await _tap(tester, 'cashier-pay');
          await _tap(tester, 'payment-quick-0');
          await _tap(tester, 'payment-finish');
          expect(_key('success-title'), findsOneWidget);
          expect(repo.checkoutParked.single, id);
          expect(repo.checkoutCustomers.single, ani.customer.id);
          expect(repo.parked, isEmpty);
          expect(find.textContaining('Toko Bu Ani'), findsWidgets);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('catatan nota tanpa pelanggan, lanjutkan butuh keranjang '
        'kosong, hapus dengan konfirmasi', (tester) async {
      final repo = await pump(tester);
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-park');
      expect(_key('park-note'), findsOneWidget);
      await tester.enterText(_input('park-note'), 'x' * 41);
      await _tap(tester, 'park-save');
      expect(find.text('Catatan maksimal 40 karakter.'), findsOneWidget);
      expect(repo.parked, isEmpty);
      await tester.enterText(_input('park-note'), 'Meja depan');
      await _tap(tester, 'park-save');
      expect(repo.parked, hasLength(1));
      expect(_text(tester, 'cashier-customer-name'), 'Pelanggan umum');

      // Keranjang berisi: Lanjutkan mati dengan petunjuk.
      await _tap(tester, productKey(repo, 'Kopi Sachet'));
      await _tap(tester, 'cashier-parked');
      expect(find.text('Meja depan'), findsOneWidget);
      expect(_key('parked-cart-busy'), findsOneWidget);
      final id = repo.parked.single.id;
      expect(
        tester.widget<FButton>(_key('parked-resume-${id.uuid}')).onPress,
        isNull,
      );

      // Hapus: batal lalu konfirmasi.
      await _tap(tester, 'parked-delete-${id.uuid}');
      expect(_key('parked-confirm'), findsOneWidget);
      await _tap(tester, 'parked-confirm-delete');
      expect(repo.parked, isEmpty);
      expect(_key('parked-empty'), findsOneWidget);
      await _tap(tester, 'parked-close');
      expect(
        find.descendant(
          of: _key('cashier-parked'),
          matching: find.text('Nota tersimpan (0)'),
        ),
        findsOneWidget,
      );
      // Keranjang yang sedang dibuat tidak tersentuh.
      expect(_text(tester, 'cashier-total'), 'Rp 2.000');
    });

    testWidgets('diskon nota tersimpan: kasir tanpa izin diminta PIN saat '
        'Bayar', (tester) async {
      final session = FakeSessionRepository()
        ..current = sampleStaff(name: 'Sari', role: 'cashier');
      final repo = await pump(
        tester,
        permissions: {Permission.salesCreate, Permission.cashSessionOpen},
        session: session,
      );
      final kopi = repo.catalog.products.firstWhere(
        (p) => p.name == 'Kopi Sachet',
      );
      await repo.park(
        lines: [
          SaleLineRequest(
            variantId: kopi.variants.single.id,
            quantity: Qty.one,
          ),
        ],
        discount: const ManualDiscount.percent(BasisPoints(500)),
      );
      await _tap(tester, 'cashier-parked');
      await _tap(tester, 'parked-resume-${repo.parked.single.id.uuid}');
      expect(_text(tester, 'cashier-total'), 'Rp 1.900');

      // Batal PIN: tetap di pesanan.
      await _tap(tester, 'cashier-pay');
      expect(_key('approval-dialog'), findsOneWidget);
      Navigator.of(tester.element(_key('approval-dialog'))).pop();
      await tester.pumpAndSettle();
      expect(_key('payment-received'), findsNothing);

      await _tap(tester, 'cashier-pay');
      await tester.enterText(_input('approval-pin'), '123456');
      await tester.pumpAndSettle();
      await _tap(tester, 'approval-submit');
      expect(_key('payment-received'), findsOneWidget);
      await _tap(tester, 'payment-quick-0');
      await _tap(tester, 'payment-finish');
      expect(_key('success-title'), findsOneWidget);
      expect(repo.parked, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pelanggan dihapus dari nota dengan ×', (tester) async {
      final repo = await pump(tester);
      final ani = row('Toko Bu Ani');
      repo.creditRows = [ani];
      await _tap(tester, 'cashier-customer');
      await _tap(tester, 'customer-picker-${ani.customer.id.uuid}');
      expect(_text(tester, 'cashier-customer-name'), 'Toko Bu Ani');
      await _tap(tester, 'cashier-customer-clear');
      expect(_text(tester, 'cashier-customer-name'), 'Pelanggan umum');
      expect(_key('cashier-customer-clear'), findsNothing);
    });

    testWidgets('daftar pelanggan gagal dimuat: coba lagi', (tester) async {
      final repo = await pump(tester);
      repo.creditRows = [row('Toko Bu Ani')];
      repo.nextError = Exception('db');
      await _tap(tester, 'cashier-customer');
      expect(_key('customer-picker-error'), findsOneWidget);
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();
      expect(_key('customer-picker-error'), findsNothing);
      expect(find.text('Toko Bu Ani'), findsOneWidget);
    });
  });
}
