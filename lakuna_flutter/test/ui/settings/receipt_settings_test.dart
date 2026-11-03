import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_receipt_settings_repository.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

Finder _previewLine(Pattern text) => find.descendant(
  of: _key('receipt-preview'),
  matching: find.textContaining(text),
);

void main() {
  const rpp = PrinterSelection(
    kind: PrinterKind.bluetooth,
    name: 'RPP02N',
    address: '66:22:B1:00:00:01',
  );

  Future<(FakeReceiptSettingsRepository, FakeReceiptPrinter)> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 900),
    bool bluetooth = true,
  }) async {
    final repo = FakeReceiptSettingsRepository(
      config: const ReceiptConfig(
        settings: ReceiptSettings(),
        defaultHeader: 'Jl. Melati No. 12',
      ),
    );
    final printer = FakeReceiptPrinter(supportsBluetooth: bluetooth)
      ..paired = [rpp];
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: Routes.settings,
      receiptSettings: repo,
      receiptPrinter: printer,
    );
    await _tap(tester, 'settings-section-receipt');
    expect(_key('receipt-settings'), findsOneWidget);
    return (repo, printer);
  }

  testWidgets('struk cabang: pratinjau ikut isian, simpan 80 mm', (
    tester,
  ) async {
    final (repo, _) = await pump(tester);
    expect(_previewLine('Jl. Melati No. 12'), findsOneWidget);
    expect(_previewLine('Terima kasih, sampai jumpa lagi!'), findsOneWidget);
    expect(_previewLine('-' * 32), findsWidgets);

    await _tap(tester, 'receipt-paper-mm80');
    expect(_previewLine('-' * 48), findsWidgets);
    await tester.enterText(
      _input('receipt-footer-1'),
      'Sampai jumpa\nIG @warung',
    );
    await tester.pumpAndSettle();
    expect(_previewLine('IG @warung'), findsOneWidget);
    await tester.ensureVisible(_key('receipt-auto-print'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cetak otomatis setelah bayar'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<FSwitch>(_key('receipt-auto-print')).value,
      isTrue,
    );

    await tester.enterText(_input('receipt-header-1'), 'x' * 49);
    await tester.pumpAndSettle();
    await _tap(tester, 'receipt-settings-save');
    expect(find.text('Maks 48 karakter per baris'), findsOneWidget);
    expect(repo.saves, isEmpty);

    await tester.enterText(_input('receipt-header-1'), 'Jl. Mawar 3');
    await tester.pumpAndSettle();
    await _tap(tester, 'receipt-settings-save');
    expect(_key('receipt-settings-saved'), findsOneWidget);
    final saved = repo.saves.single;
    expect(saved.paper, ReceiptPaper.mm80);
    expect(saved.header, 'Jl. Mawar 3');
    expect(saved.footer, 'Sampai jumpa\nIG @warung');
    expect(saved.autoPrint, isTrue);
  });

  testWidgets('printer Bluetooth: cari, pilih, tes cetak, lupakan', (
    tester,
  ) async {
    final (repo, printer) = await pump(tester);
    expect(find.text('Belum ada printer'), findsOneWidget);
    await _tap(tester, 'printer-search');
    expect(find.text('66:22:B1:00:00:01'), findsOneWidget);
    await tester.tap(
      find.descendant(of: _key('printer-bt-0'), matching: find.text('Pilih')),
    );
    await tester.pumpAndSettle();
    expect(repo.printer, rpp);
    expect(find.text('RPP02N · Bluetooth · 58 mm'), findsOneWidget);

    await _tap(tester, 'printer-test');
    expect(_key('printer-test-sent'), findsOneWidget);
    expect(printer.prints.single.$1, rpp);
    expect(printer.prints.single.$2.first.text, 'WARUNG CONTOH');

    await _tap(tester, 'printer-forget');
    expect(repo.printer, isNull);
    expect(find.text('Belum ada printer'), findsOneWidget);
  });

  testWidgets('ponsel tanpa Bluetooth: printer jaringan', (tester) async {
    final (repo, printer) = await pump(
      tester,
      size: const Size(390, 844),
      bluetooth: false,
    );
    expect(_key('printer-kind-bluetooth'), findsNothing);
    expect(_key('printer-bt-unsupported'), findsOneWidget);
    await tester.enterText(_input('printer-address-1'), 'printer lan');
    await tester.pumpAndSettle();
    await _tap(tester, 'printer-use-address');
    expect(
      find.text('Alamat tidak sah. Contoh 192.168.1.50 atau 192.168.1.50:9100'),
      findsOneWidget,
    );
    await tester.enterText(_input('printer-address-1'), '192.168.1.50');
    await tester.pumpAndSettle();
    await _tap(tester, 'printer-use-address');
    expect(repo.printer!.address, '192.168.1.50:9100');

    printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
    await _tap(tester, 'printer-test');
    expect(
      find.text(
        'Printer tidak bisa dihubungi. Pastikan menyala dan dalam jangkauan.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('kasir tanpa settings:manage tidak melihat Struk & printer', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      initialLocation: Routes.settings,
      session: FakeSessionRepository()..current = sampleStaff(role: 'cashier'),
    );
    expect(_key('settings-section-receipt'), findsNothing);
  });
}
