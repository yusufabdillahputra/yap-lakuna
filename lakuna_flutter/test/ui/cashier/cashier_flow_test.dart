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

import '../../testing/app_harness.dart';
import '../../testing/cashier_seed.dart';
import '../../testing/fake_cashier_repository.dart';
import '../../testing/fake_receipt_printer.dart';
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
    );
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
}
