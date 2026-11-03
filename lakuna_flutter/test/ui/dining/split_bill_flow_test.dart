import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_cashier_repository.dart';
import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/qris_seed.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(_key(key)).data!;

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

void main() {
  late FakeDiningRepository dining;
  late FakeCashierRepository cashier;

  Future<void> pump(WidgetTester tester, {required Size size}) async {
    dining = FakeDiningRepository();
    cashier = FakeCashierRepository(qris: sampleQris())..dining = dining;
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.tables,
      dining: dining,
      cashier: cashier,
      receiptPrinter: FakeReceiptPrinter(),
      session: FakeSessionRepository()..current = sampleStaff(),
    );
  }

  /// Buka meja [table] untuk 2 tamu dengan Kopi Susu Aren (27.720 setelah
  /// service & PB1) dan Nasi Goreng Kampung (33.495).
  Future<void> openBill(WidgetTester tester, String table) async {
    await _tap(tester, 'dining-table-$table');
    await tester.enterText(_input('dining-guests'), '2');
    await _tap(tester, 'dining-guests-open');
    await _tap(tester, 'dining-add-menu');
    await _tap(tester, 'dining-menu-Kopi Susu Aren');
    await _tap(tester, 'dining-menu-Nasi Goreng Kampung');
    await _tap(tester, 'dining-menu-done');
  }

  testWidgets(
    'tablet: per item, bayar tunai tamu A, QRIS menunggu tamu B, konfirmasi',
    (tester) async {
      await pump(tester, size: const Size(1280, 800));
      await openBill(tester, 'M4');

      await _tap(tester, 'dining-split');
      expect(find.text('Split bill · Meja M4 · 2 tamu'), findsOneWidget);
      await _tap(tester, 'split-mode-item');
      expect(_key('split-unassigned'), findsOneWidget);
      // Porsi belum dibagi: bayar mati.
      expect(tester.widget<FButton>(_key('split-pay-A')).onPress, isNull);

      await _tap(tester, 'split-chip-Kopi Susu Aren---A');
      await _tap(tester, 'split-chip-Nasi Goreng Kampung---B');
      expect(_key('split-unassigned'), findsNothing);
      expect(_text(tester, 'split-due-A'), 'Rp 27.720');
      expect(_text(tester, 'split-due-B'), 'Rp 33.495');

      await _tap(tester, 'split-pay-A');
      expect(find.text('Pembayaran · Total Rp 27.720'), findsOneWidget);
      expect(find.text('Meja M4 · Bagian tamu A'), findsOneWidget);
      expect(_key('payment-part-due'), findsOneWidget);
      expect(find.bySemanticsLabel('Kembali ke split'), findsOneWidget);
      await _tap(tester, 'payment-quick-0');
      await _tap(tester, 'payment-finish');

      // Belum lunas: kembali ke layar split, bill terkunci.
      expect(_text(tester, 'split-status-A'), 'Lunas · Tunai');
      expect(_key('split-locked'), findsOneWidget);
      expect(_text(tester, 'split-remaining'), 'Rp 33.495');

      await _tap(tester, 'split-pay-B');
      await _tap(tester, 'payment-method-qris');
      await _tap(tester, 'qris-wait');
      expect(_text(tester, 'split-status-B'), 'QRIS statis · menunggu');
      expect(cashier.paidParts.map((p) => (p.$2, p.$5)), [
        ('A', false),
        ('B', true),
      ]);

      // Panel bill di layar Meja: status split dan lanjutkan split.
      await _tap(tester, 'split-back');
      expect(_text(tester, 'dining-split-status'), contains('1 dari 2'));
      expect(find.text('Lanjutkan split · Rp 33.495'), findsOneWidget);
      // Item terkunci; batal bill tetap bisa (bagian lunas dikembalikan).
      expect(tester.widget<FButton>(_key('dining-add-menu')).onPress, isNull);
      expect(_key('dining-void'), findsOneWidget);
      expect(find.text('Tamu A'), findsWidgets);
      await _tap(tester, 'dining-pay');

      // Bagian terakhir dikonfirmasi di layar split: langsung ke struk.
      await _tap(tester, 'split-confirm-B');
      expect(_key('success-title'), findsOneWidget);
      expect(
        find.descendant(
          of: _key('success-receipt'),
          matching: find.textContaining('Tamu B - QRIS'),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(find.text('Kembali ke meja').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kembali ke meja').last);
      await tester.pumpAndSettle();
      expect(
        find.text('Pelayan: Dimas · 0 dari 6 meja terisi'),
        findsOneWidget,
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );

  testWidgets(
    'ponsel 360 px: rata, tamu terakhir lunas → struk per tamu',
    (tester) async {
      await pump(tester, size: const Size(360, 740));
      expect(tester.takeException(), isNull);
      await openBill(tester, 'M2');
      // Aksi tambahan ikut digulir bersama item di ponsel.
      await tester.dragUntilVisible(
        _key('dining-split'),
        _key('dining-bill-title'),
        const Offset(0, -200),
      );
      await _tap(tester, 'dining-split');
      await _tap(tester, 'split-mode-equal');
      expect(tester.takeException(), isNull);
      // 61.215 dibagi 2: tamu A 30.608, tamu B sisanya.
      expect(_text(tester, 'split-due-A'), 'Rp 30.608');
      expect(_text(tester, 'split-due-B'), 'Rp 30.607');

      for (final guest in ['A', 'B']) {
        await _tap(tester, 'split-pay-$guest');
        await _tap(tester, 'payment-method-card');
        await _tap(tester, 'payment-finish');
      }
      expect(_key('success-title'), findsOneWidget);
      // Struk thermal memakai ASCII: "·" dicetak "-".
      final receipt = _key('success-receipt');
      expect(
        find.descendant(
          of: receipt,
          matching: find.textContaining('Tamu A - Kartu'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: receipt,
          matching: find.textContaining('Tamu B - Kartu'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Kembali ke meja').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kembali ke meja').last);
      await tester.pumpAndSettle();
      expect(_key('dining-mode-take-away'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
}
