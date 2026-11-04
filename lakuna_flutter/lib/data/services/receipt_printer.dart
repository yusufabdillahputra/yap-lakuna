import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';

import 'receipt_pdf.dart';

enum PrinterFailureReason {
  /// Bluetooth perangkat mati.
  bluetoothOff,

  /// Izin Bluetooth (Android 12+) ditolak.
  permission,

  /// Printer tidak bisa dihubungi (mati, di luar jangkauan, alamat salah).
  connect,

  /// Terhubung tetapi pengiriman data gagal.
  write,

  /// Printer tidak menjawab dalam batas waktu.
  timeout,

  /// Jenis printer tidak didukung di platform ini.
  unsupported,
}

/// Cetak gagal. Nota tetap tersimpan; kasir bisa mencoba lagi.
class PrinterFailure implements Exception {
  const PrinterFailure(this.reason);

  final PrinterFailureReason reason;

  @override
  String toString() => 'PrinterFailure(${reason.name})';
}

/// Mencetak dan membagikan struk (F1-06).
abstract class ReceiptPrinter {
  /// Printer Bluetooth bisa dipakai di perangkat ini (Android).
  bool get supportsBluetooth;

  /// Printer Bluetooth yang sudah dipasangkan di pengaturan perangkat.
  Future<List<PrinterSelection>> bluetoothPrinters();

  /// Mencetak [lines] ke [printer]: byte ESC/POS untuk printer langsung,
  /// PDF ke dialog cetak untuk [PrinterKind.system]. Gagal dengan
  /// [PrinterFailure].
  Future<void> print(
    PrinterSelection printer,
    List<ReceiptLine> lines,
    ReceiptPaper paper, {
    required String jobName,
  });

  /// PDF struk: share sheet di Android/iOS (hasil `null`), atau disimpan ke
  /// folder Dokumen di desktop (hasil = lokasi berkas).
  Future<String?> sharePdf(
    List<ReceiptLine> lines,
    ReceiptPaper paper, {
    required String fileName,
  });

  /// Dokumen PDF utuh (mis. kuitansi A5) ke dialog cetak sistem.
  Future<void> printDocument(Uint8List pdf, {required String jobName});

  /// Dokumen PDF utuh: share sheet di Android/iOS (hasil `null`), atau
  /// disimpan ke folder Dokumen di desktop (hasil = lokasi berkas).
  Future<String?> shareDocument(Uint8List pdf, {required String fileName});
}

/// Batas waktu sambung dan kirim ke printer jaringan.
const networkPrinterTimeout = Duration(seconds: 5);

/// Mengirim [bytes] ke printer ESC/POS jaringan [host]:[port] (raw TCP).
Future<void> sendToNetworkPrinter(
  String host,
  int port,
  List<int> bytes, {
  Duration timeout = networkPrinterTimeout,
}) async {
  final Socket socket;
  try {
    socket = await Socket.connect(host, port, timeout: timeout);
  } on SocketException {
    throw const PrinterFailure(PrinterFailureReason.connect);
  }
  // Galat soket juga muncul di `done`; tangkap agar tidak jadi galat liar.
  unawaited(socket.done.catchError((Object _) => socket));
  try {
    socket.add(bytes);
    await socket.flush().timeout(timeout);
    await socket.close().timeout(timeout);
  } on TimeoutException {
    throw const PrinterFailure(PrinterFailureReason.timeout);
  } on SocketException {
    throw const PrinterFailure(PrinterFailureReason.write);
  } finally {
    socket.destroy();
  }
}

/// Folder PDF struk di desktop: `Dokumen/Lakuna/Struk`, atau
/// `<data aplikasi>/Struk` bila folder Dokumen tidak dikenal (mis. Linux
/// tanpa `xdg-user-dir`).
Future<Directory> receiptPdfDirectory({
  Future<Directory> Function() documents = getApplicationDocumentsDirectory,
  Future<Directory> Function() fallback = getApplicationSupportDirectory,
}) async {
  try {
    final docs = await documents();
    return Directory(p.join(docs.path, 'Lakuna', 'Struk'));
  } on MissingPlatformDirectoryException {
    final base = await fallback();
    return Directory(p.join(base.path, 'Struk'));
  }
}

/// Lapisan tipis di atas `print_bluetooth_thermal` agar alurnya bisa diuji.
abstract class BluetoothThermal {
  /// Memeriksa dan, di Android 12+, meminta izin BLUETOOTH_CONNECT/SCAN.
  /// Plugin menolak semua panggilan lain sampai izin diberikan.
  Future<bool> requestPermission();
  Future<bool> enabled();

  /// Printer yang sudah dipasangkan: (nama, MAC).
  Future<List<(String, String)>> paired();
  Future<bool> connected();
  Future<void> disconnect();
  Future<bool> connect(String mac);

  /// [bytes] harus `List<int>` biasa: plugin Android membaca argumen
  /// sebagai `List<Int>`, sedangkan `Uint8List` tiba sebagai `byte[]`.
  Future<bool> write(List<int> bytes);
}

class PluginBluetoothThermal implements BluetoothThermal {
  const PluginBluetoothThermal();

  @override
  Future<bool> requestPermission() =>
      PrintBluetoothThermal.isPermissionBluetoothGranted;

  @override
  Future<bool> enabled() => PrintBluetoothThermal.bluetoothEnabled;

  @override
  Future<List<(String, String)>> paired() async => [
    for (final d in await PrintBluetoothThermal.pairedBluetooths)
      (d.name, d.macAdress),
  ];

  @override
  Future<bool> connected() => PrintBluetoothThermal.connectionStatus;

  @override
  Future<void> disconnect() => PrintBluetoothThermal.disconnect;

  @override
  Future<bool> connect(String mac) =>
      PrintBluetoothThermal.connect(macPrinterAddress: mac);

  @override
  Future<bool> write(List<int> bytes) => PrintBluetoothThermal.writeBytes(
    bytes is Uint8List ? List<int>.of(bytes) : bytes,
  );
}

/// [ReceiptPrinter] nyata: Bluetooth (`print_bluetooth_thermal`), soket
/// TCP, dan `printing` untuk dialog cetak / share sheet.
class PlatformReceiptPrinter implements ReceiptPrinter {
  PlatformReceiptPrinter({
    BluetoothThermal bluetooth = const PluginBluetoothThermal(),
    bool? bluetoothSupported,
  }) : _bt = bluetooth,
       _btSupported = bluetoothSupported ?? (!kIsWeb && Platform.isAndroid);

  final BluetoothThermal _bt;
  final bool _btSupported;
  String? _connectedMac;

  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  bool get supportsBluetooth => _btSupported;

  /// Izin dulu (memunculkan dialog izin), baru status Bluetooth.
  Future<void> _ready() async {
    if (!await _bt.requestPermission()) {
      throw const PrinterFailure(PrinterFailureReason.permission);
    }
    if (!await _bt.enabled()) {
      throw const PrinterFailure(PrinterFailureReason.bluetoothOff);
    }
  }

  @override
  Future<List<PrinterSelection>> bluetoothPrinters() async {
    if (!supportsBluetooth) return const [];
    await _ready();
    return [
      for (final (name, mac) in await _bt.paired())
        PrinterSelection(kind: PrinterKind.bluetooth, name: name, address: mac),
    ];
  }

  @override
  Future<void> print(
    PrinterSelection printer,
    List<ReceiptLine> lines,
    ReceiptPaper paper, {
    required String jobName,
  }) async {
    switch (printer.kind) {
      case PrinterKind.system:
        final pdf = await buildReceiptPdf(lines, paper);
        await Printing.layoutPdf(
          name: jobName,
          format: receiptPageFormat(paper, lines.length),
          onLayout: (_) async => pdf,
        );
      case PrinterKind.network:
        final address = parseNetworkAddress(printer.address);
        if (address == null) {
          throw const PrinterFailure(PrinterFailureReason.connect);
        }
        await sendToNetworkPrinter(address.$1, address.$2, encodeEscPos(lines));
      case PrinterKind.bluetooth:
        await _bluetooth(printer.address, encodeEscPos(lines));
    }
  }

  Future<void> _bluetooth(String mac, Uint8List bytes) async {
    if (!supportsBluetooth) {
      throw const PrinterFailure(PrinterFailureReason.unsupported);
    }
    await _ready();
    final connected = await _bt.connected();
    if (connected && _connectedMac != mac) {
      await _bt.disconnect();
    }
    if (!connected || _connectedMac != mac) {
      _connectedMac = null;
      final ok = await _bt
          .connect(mac)
          .timeout(networkPrinterTimeout * 2, onTimeout: () => false);
      if (!ok) throw const PrinterFailure(PrinterFailureReason.connect);
      _connectedMac = mac;
    }
    if (!await _bt.write(List<int>.of(bytes))) {
      _connectedMac = null;
      throw const PrinterFailure(PrinterFailureReason.write);
    }
  }

  @override
  Future<String?> sharePdf(
    List<ReceiptLine> lines,
    ReceiptPaper paper, {
    required String fileName,
  }) async {
    return shareDocument(
      await buildReceiptPdf(lines, paper),
      fileName: fileName,
    );
  }

  @override
  Future<void> printDocument(Uint8List pdf, {required String jobName}) =>
      Printing.layoutPdf(
        name: jobName,
        format: PdfPageFormat.a5,
        onLayout: (_) async => pdf,
      );

  @override
  Future<String?> shareDocument(
    Uint8List pdf, {
    required String fileName,
  }) async {
    if (_mobile) {
      await Printing.sharePdf(bytes: pdf, filename: fileName);
      return null;
    }
    final dir = await receiptPdfDirectory();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(pdf, flush: true);
    return file.path;
  }
}
