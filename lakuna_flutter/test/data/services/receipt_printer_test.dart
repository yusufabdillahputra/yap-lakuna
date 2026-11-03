import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';

void main() {
  test('sendToNetworkPrinter mengirim byte utuh lalu menutup soket', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final received = Completer<List<int>>();
    server.listen((socket) async {
      final bytes = <int>[];
      await socket.forEach(bytes.addAll);
      received.complete(bytes);
    });
    await sendToNetworkPrinter('127.0.0.1', server.port, [1, 2, 3, 0x1B, 0x40]);
    expect(await received.future, [1, 2, 3, 0x1B, 0x40]);
    await server.close();
  });

  test('printer jaringan mati → PrinterFailure.connect', () async {
    // Ambil port bebas lalu tutup: tidak ada yang mendengar.
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();
    await expectLater(
      sendToNetworkPrinter('127.0.0.1', port, [1]),
      throwsA(
        isA<PrinterFailure>().having(
          (e) => e.reason,
          'reason',
          PrinterFailureReason.connect,
        ),
      ),
    );
  });

  test(
    'PDF struk: font DM Mono dibundel, lebar gulungan sesuai kertas',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const lines = [
        ReceiptLine('WARUNG CONTOH', align: ReceiptAlign.center, bold: true),
        ReceiptLine('TOTAL                    180.000'),
      ];
      final pdf = await buildReceiptPdf(lines, ReceiptPaper.mm58);
      expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
      final f58 = receiptPageFormat(ReceiptPaper.mm58, 2);
      expect(f58.width, closeTo(58 * PdfPageFormat.mm, 0.01));
      expect(f58.availableWidth, closeTo(48 * PdfPageFormat.mm, 0.01));
      final f80 = receiptPageFormat(ReceiptPaper.mm80, 10);
      expect(f80.availableWidth, closeTo(72 * PdfPageFormat.mm, 0.01));
      expect(f80.height, greaterThan(f58.height));
    },
  );
}
