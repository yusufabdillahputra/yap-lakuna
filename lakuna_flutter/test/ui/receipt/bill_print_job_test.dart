import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_pdf.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/receipt/bill_print_job.dart';

import '../../testing/fake_receipt_printer.dart';

void main() {
  const a = [ReceiptLine('TAGIHAN TAMU A'), ReceiptLine('TOTAL 10.000')];
  const b = [ReceiptLine('TAGIHAN TAMU B')];
  const c = [ReceiptLine('TAGIHAN TAMU C'), ReceiptLine('x'), ReceiptLine('y')];
  final logo = Uint8List.fromList([1, 2, 3]);

  late FakeReceiptPrinter printer;
  late List<(List<List<ReceiptLine>>, ReceiptPaper, Uint8List?)> built;
  PrinterSelection? selection;

  BillPrintJob job() => BillPrintJob(
    printer: printer,
    selection: () => selection,
    paper: () => ReceiptPaper.mm80,
    logo: () => logo,
    jobName: () => 'tagihan-B-0001-semua',
    buildPdf: (bills, paper, logo) async {
      built.add((bills, paper, logo));
      return Uint8List.fromList([0x25, 0x50, 0x44, 0x46]);
    },
  );

  setUp(() {
    printer = FakeReceiptPrinter();
    built = [];
    selection = const PrinterSelection(
      kind: PrinterKind.network,
      name: 'Kasir',
      address: '192.168.1.50:9100',
    );
  });

  group('cetak semua tagihan (F1-10r)', () {
    test('printer langsung: satu job per tagihan, berurutan', () async {
      final j = job();
      await j.printBills.execute([a, b, c]);
      expect(printer.prints.map((p) => p.$2), [a, b, c]);
      expect(printer.prints.every((p) => p.$3 == ReceiptPaper.mm80), isTrue);
      expect(printer.logos, [logo, logo, logo]);
      expect(printer.documentPrints, isEmpty);
      expect(j.printed, isTrue);
      expect(j.printError, isFalse);
    });

    test(
      'printer langsung: gagal di job kedua, berhenti dan tercatat',
      () async {
        printer.printFailures[1] = const PrinterFailure(
          PrinterFailureReason.write,
        );
        final j = job();
        await j.printBills.execute([a, b, c]);
        expect(printer.prints.map((p) => p.$2), [a]);
        expect(j.printError, isTrue);
        expect(j.printFailure, PrinterFailureReason.write);
        expect(j.printed, isFalse);
      },
    );

    test('dialog cetak sistem: satu PDF banyak halaman, sekali', () async {
      selection = null;
      final j = job();
      await j.printBills.execute([a, b, c]);
      expect(printer.prints, isEmpty);
      expect(built.single.$1, [a, b, c]);
      expect(built.single.$3, logo);
      final (_, name) = printer.documentPrints.single;
      expect(name, 'tagihan-B-0001-semua');
      // Halaman awal dialog = struk terpanjang.
      expect(
        printer.documentFormats.single.height,
        greaterThanOrEqualTo(
          receiptPageFormat(ReceiptPaper.mm80, c.length).height,
        ),
      );
      expect(j.printed, isFalse);
      expect(j.printError, isFalse);
    });

    test('bagikan: satu PDF bernama …-semua.pdf', () async {
      final j = job();
      await j.shareBills.execute([a, b]);
      expect(built.single.$1, [a, b]);
      final (_, file) = printer.documentShares.single;
      expect(file, 'tagihan-B-0001-semua.pdf');
      expect(j.pdfPath, printer.sharePath);
      expect(printer.shares, isEmpty);
    });

    test('bagikan gagal tercatat', () async {
      printer.nextFailure = const PrinterFailure(PrinterFailureReason.write);
      final j = job();
      await j.shareBills.execute([a, b]);
      expect(j.shareError, isTrue);
      expect(j.pdfPath, isNull);
    });

    test('satu tagihan tetap lewat jalur lama', () async {
      final j = job();
      await j.printBills.execute([a]);
      await j.shareBills.execute([a]);
      expect(printer.prints.single.$2, a);
      expect(printer.shares.single.$1, a);
      expect(printer.shares.single.$3, 'tagihan-B-0001-semua.pdf');
      expect(built, isEmpty);
    });

    test(
      'dialog ditutup di tengah cetak: sisa tagihan tidak dikirim',
      () async {
        printer.hold = Completer<void>();
        final j = job();
        final run = j.printBills.execute([a, b, c]);
        await Future<void>.delayed(Duration.zero);
        j.reset();
        printer.hold!.complete();
        await run;
        expect(printer.prints.map((p) => p.$2), [a]);
        expect(j.printed, isFalse);
        expect(j.running, isFalse);
      },
    );

    test('galat bukan Exception (mis. font PDF) tetap tercatat', () async {
      selection = null;
      final j = BillPrintJob(
        printer: printer,
        selection: () => selection,
        paper: () => ReceiptPaper.mm58,
        logo: () => null,
        jobName: () => 'x',
        buildPdf: (_, _, _) async => throw StateError('font'),
      );
      await j.printBills.execute([a, b]);
      expect(j.printError, isTrue);
      await j.shareBills.execute([a, b]);
      expect(j.shareError, isTrue);
    });

    test('hasil dari dialog lama tidak tampil setelah reset', () async {
      printer.printFailures[0] = const PrinterFailure(
        PrinterFailureReason.connect,
      );
      final j = job();
      final hold = j.printBills.execute([a, b]);
      j.reset();
      await hold;
      expect(j.printError, isFalse);
      expect(j.running, isFalse);
    });
  });
}
