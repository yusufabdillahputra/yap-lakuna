import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/cashier_seed.dart';
import '../../testing/fake_cashier_repository.dart';

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
  }) async {
    final repo = FakeCashierRepository(
      seed: cashierProducts(),
      sessionOpen: sessionOpen,
    );
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.cashier,
      cashier: repo,
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
        matching: find.text('PST-K01-261103-0001'),
      ),
      findsOneWidget,
    );
    final (lines, payment) = repo.checkouts.single;
    expect(lines, hasLength(2));
    expect(payment.received?.value, 300000);

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
    expect(repo.checkouts.single.$2.reference, '004512');
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
    expect(repo.checkouts.single.$2.method, PaymentMethod.transfer);
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
}
