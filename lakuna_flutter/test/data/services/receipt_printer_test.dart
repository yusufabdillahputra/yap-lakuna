import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_logo_raster.dart';
import 'package:lakuna_flutter/data/services/receipt_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';

import '../../testing/floor_seed.dart';

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

  group('logo struk (F1-06b)', () {
    test('PDF dengan logo lebih tinggi; logo rusak dilewati', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      const lines = [ReceiptLine('TOKO', align: ReceiptAlign.center)];
      // PNG 1×1: persegi, tinggi dibatasi 20 mm.
      final size = receiptPdfLogoSize(samplePng, ReceiptPaper.mm58)!;
      expect(size.height, closeTo(20 * PdfPageFormat.mm, 0.01));
      expect(size.width, closeTo(20 * PdfPageFormat.mm, 0.01));
      expect(
        receiptPdfLogoExtra(samplePng, ReceiptPaper.mm58),
        closeTo(22 * PdfPageFormat.mm, 0.01),
      );
      final pdf = await buildReceiptPdf(
        lines,
        ReceiptPaper.mm58,
        logo: samplePng,
      );
      expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
      expect(
        receiptPdfLogoExtra(Uint8List.fromList([1, 2]), ReceiptPaper.mm58),
        0,
      );
      final plain = await buildReceiptPdf(
        lines,
        ReceiptPaper.mm58,
        logo: Uint8List.fromList([1, 2]),
      );
      expect(String.fromCharCodes(plain.take(5)), '%PDF-');
      // Header PNG sah tetapi isinya rusak: dekode gagal saat menyimpan,
      // struk tetap jadi tanpa logo.
      final corrupt = Uint8List.fromList([
        ...samplePng.sublist(0, 33),
        0, 0, 0, 0, 0x49, 0x44, 0x41, 0x54, 1, 2, 3, //
      ]);
      expect(receiptPdfLogoExtra(corrupt, ReceiptPaper.mm58), greaterThan(0));
      final fallback = await buildReceiptPdf(
        lines,
        ReceiptPaper.mm58,
        logo: corrupt,
      );
      expect(String.fromCharCodes(fallback.take(5)), '%PDF-');
      expect(fallback.length, plain.length);
    });

    test('ukuran titik logo mengikuti batas kertas dan rasio', () {
      // Header PNG 1000×250 (lebar) → dibatasi lebar.
      final wide = Uint8List.fromList([
        ...samplePng.sublist(0, 16),
        0, 0, 0x03, 0xE8, 0, 0, 0, 0xFA, //
        ...samplePng.sublist(24),
      ]);
      expect(receiptLogoSize(wide, ReceiptPaper.mm58), (
        width: 256,
        height: 64,
      ));
      expect(receiptLogoSize(wide, ReceiptPaper.mm80), (
        width: 384,
        height: 96,
      ));
      expect(receiptLogoSize(samplePng, ReceiptPaper.mm58), (
        width: 1,
        height: 1,
      ));
      expect(receiptLogoSize(Uint8List(4), ReceiptPaper.mm58), isNull);
    });

    testWidgets('bitmap logo dari PNG; gambar rusak → null', (tester) async {
      final bitmap = await tester.runAsync(
        () => receiptLogoBitmap(samplePng, ReceiptPaper.mm58),
      );
      // Logo 1×1 di tengah bitmap selebar cetak 58 mm (384 titik).
      expect(bitmap!.width, 384);
      expect(bitmap.height, 1);
      final broken = await tester.runAsync(
        () => receiptLogoBitmap(
          Uint8List.fromList([...samplePng.sublist(0, 33), 0, 0, 0]),
          ReceiptPaper.mm58,
        ),
      );
      expect(broken, isNull);
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
