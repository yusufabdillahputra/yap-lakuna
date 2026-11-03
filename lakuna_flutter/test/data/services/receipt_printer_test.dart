import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_pdf.dart';
import 'package:path_provider/path_provider.dart';
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

  test('halaman PDF selalu sedikit lebih tinggi dari isi agar baris '
      'terakhir tidak terbuang karena pembulatan', () {
    for (final paper in ReceiptPaper.values) {
      for (var n = 1; n <= 120; n++) {
        final f = receiptPageFormat(paper, n);
        expect(
          f.availableHeight - n * receiptLineHeightPt(paper),
          greaterThanOrEqualTo(1),
          reason: '${paper.name} $n baris',
        );
      }
    }
  });

  group('Bluetooth (Android)', () {
    const rpp = PrinterSelection(
      kind: PrinterKind.bluetooth,
      name: 'RPP02N',
      address: '66:22:B1:00:00:01',
    );
    const lines = [ReceiptLine('TOKO')];

    test(
      'meminta izin dulu sebelum memeriksa Bluetooth atau mencari',
      () async {
        final bt = _FakeBluetooth();
        final printer = PlatformReceiptPrinter(
          bluetooth: bt,
          bluetoothSupported: true,
        );
        final found = await printer.bluetoothPrinters();
        expect(found.single.address, rpp.address);
        expect(bt.calls.first, 'permission');
      },
    );

    test(
      'izin ditolak → PrinterFailure.permission, bukan "Bluetooth mati"',
      () async {
        final bt = _FakeBluetooth(permission: false);
        final printer = PlatformReceiptPrinter(
          bluetooth: bt,
          bluetoothSupported: true,
        );
        for (final action in [
          printer.bluetoothPrinters,
          () => printer.print(rpp, lines, ReceiptPaper.mm58, jobName: 't'),
        ]) {
          await expectLater(
            action(),
            throwsA(
              isA<PrinterFailure>().having(
                (e) => e.reason,
                'reason',
                PrinterFailureReason.permission,
              ),
            ),
          );
        }
        expect(bt.calls, everyElement('permission'));
      },
    );

    test('byte dikirim sebagai List<int> biasa (plugin Android menolak '
        'Uint8List/byte[])', () async {
      final bt = _FakeBluetooth();
      final printer = PlatformReceiptPrinter(
        bluetooth: bt,
        bluetoothSupported: true,
      );
      await printer.print(rpp, lines, ReceiptPaper.mm58, jobName: 't');
      expect(bt.calls, ['permission', 'enabled', 'connect', 'write']);
      expect(bt.written, isNot(isA<Uint8List>()));
      expect(bt.written, encodeEscPos(lines));
    });
  });

  group('receiptPdfDirectory', () {
    test('memakai folder Dokumen bila ada', () async {
      final dir = await receiptPdfDirectory(
        documents: () async => Directory('/home/u/Documents'),
        fallback: () async => Directory('/data/app'),
      );
      expect(dir.path, '/home/u/Documents/Lakuna/Struk');
    });

    test('folder Dokumen tidak dikenal (tanpa xdg-user-dir) → folder '
        'data aplikasi', () async {
      final dir = await receiptPdfDirectory(
        documents: () async =>
            throw MissingPlatformDirectoryException('no documents'),
        fallback: () async => Directory('/data/app'),
      );
      expect(dir.path, '/data/app/Struk');
    });
  });
}

class _FakeBluetooth implements BluetoothThermal {
  _FakeBluetooth({this.permission = true});

  bool permission;
  final calls = <String>[];
  List<int>? written;

  @override
  Future<bool> requestPermission() async {
    calls.add('permission');
    return permission;
  }

  @override
  Future<bool> enabled() async {
    calls.add('enabled');
    return true;
  }

  @override
  Future<List<(String, String)>> paired() async {
    calls.add('paired');
    return [('RPP02N', '66:22:B1:00:00:01')];
  }

  @override
  Future<bool> connected() async => false;

  @override
  Future<void> disconnect() async {}

  @override
  Future<bool> connect(String mac) async {
    calls.add('connect');
    return true;
  }

  @override
  Future<bool> write(List<int> bytes) async {
    calls.add('write');
    written = bytes;
    return true;
  }
}
