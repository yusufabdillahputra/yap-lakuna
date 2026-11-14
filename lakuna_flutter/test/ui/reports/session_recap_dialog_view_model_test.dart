import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/reports/session_recap_dialog.dart';

import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_receipt_settings_repository.dart';
import '../../testing/fake_reports_repository.dart';

void main() {
  late FakeReportsRepository repo;
  late FakeReceiptSettingsRepository settings;
  late FakeReceiptPrinter printer;
  late SessionRecapDialogViewModel vm;
  const lines = [ReceiptLine('REKAP SESI KASIR')];
  const bt = PrinterSelection(
    kind: PrinterKind.bluetooth,
    name: 'RPP02N',
    address: '00:11',
  );
  final logo = Uint8List.fromList([1, 2, 3]);

  SessionRecapDialogViewModel build({
    UuidValue? sessionId,
    PrinterSelection? selected,
    bool withPrinter = true,
  }) {
    repo = FakeReportsRepository();
    settings = FakeReceiptSettingsRepository(
      config: ReceiptConfig(
        settings: ReceiptSettings(
          paper: ReceiptPaper.mm80,
          logoMediaId: UuidValue.fromString(
            '0195a0d6-0000-7000-8000-000000000001',
          ),
          showLogo: true,
        ),
        logoImage: logo,
      ),
      printer: selected,
    );
    printer = FakeReceiptPrinter();
    return vm = SessionRecapDialogViewModel(
      repository: repo,
      sessionId: sessionId ?? FakeReportsRepository.closedSessionId,
      receiptSettings: withPrinter ? settings : null,
      printer: withPrinter ? printer : null,
      timezone: 'Asia/Jakarta',
    );
  }

  tearDown(() => vm.dispose());

  test('muat rekap sesi tertutup, kertas, dan logo', () async {
    build();
    expect(vm.recap, isNull);
    await vm.load.execute();
    expect(repo.recapRequests, [FakeReportsRepository.closedSessionId]);
    final recap = vm.recap!;
    expect(recap.closerName, 'Sari');
    expect(recap.active.openedByName, 'Budi');
    expect(recap.closed.countedCash, 145000);
    expect(vm.deviceCode, 'K01');
    expect(vm.paper, ReceiptPaper.mm80);
    expect(vm.logo, logo);
    expect(vm.canPrint, isTrue);
    expect(vm.notClosed, isFalse);
    expect(vm.loadFailed, isFalse);
    // 14.00 UTC = 21.00 WIB.
    expect(vm.fileName, 'rekap-sesi-261103-2100');
  });

  test('sesi buka atau tidak ditemukan: notClosed', () async {
    build(sessionId: FakeReportsRepository.openSessionId);
    await vm.load.execute();
    expect(vm.recap, isNull);
    expect(vm.notClosed, isTrue);
    expect(vm.loadFailed, isTrue);
  });

  test('galat lain saat muat: loadFailed tanpa notClosed', () async {
    build();
    repo.recapError = Exception('db');
    await vm.load.execute();
    expect(vm.recap, isNull);
    expect(vm.notClosed, isFalse);
    expect(vm.loadFailed, isTrue);
  });

  test('tanpa layanan cetak: rekap tetap tampil, tidak bisa dicetak', () async {
    build(withPrinter: false);
    await vm.load.execute();
    expect(vm.recap, isNotNull);
    expect(vm.canPrint, isFalse);
    expect(vm.paper, ReceiptPaper.mm58);
  });

  test('cetak ke printer langsung lalu galat printer', () async {
    build(selected: bt);
    await vm.load.execute();
    await vm.print.execute(lines);
    expect(printer.prints.single.$1, bt);
    expect(printer.prints.single.$3, ReceiptPaper.mm80);
    expect(printer.logos.single, logo);
    expect(vm.printed, isTrue);
    expect(vm.printError, isFalse);

    printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
    await vm.print.execute(lines);
    expect(vm.printed, isFalse);
    expect(vm.printError, isTrue);
    expect(vm.printFailure, PrinterFailureReason.connect);
  });

  test('tanpa printer terpilih: dialog cetak sistem', () async {
    build();
    await vm.load.execute();
    await vm.print.execute(lines);
    expect(printer.prints.single.$1.kind, PrinterKind.system);
    expect(vm.printed, isFalse);
    expect(vm.printError, isFalse);
  });

  test('bagikan PDF: nama berkas dan lokasi, lalu galat', () async {
    build();
    await vm.load.execute();
    await vm.share.execute(lines);
    expect(printer.shares.single.$3, 'rekap-sesi-261103-2100.pdf');
    expect(vm.pdfPath, printer.sharePath);
    expect(vm.shareError, isFalse);

    printer.nextFailure = const PrinterFailure(PrinterFailureReason.write);
    await vm.share.execute(lines);
    expect(vm.pdfPath, isNull);
    expect(vm.shareError, isTrue);
  });
}
