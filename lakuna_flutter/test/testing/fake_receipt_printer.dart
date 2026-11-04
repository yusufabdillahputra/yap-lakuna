import 'dart:async';
import 'dart:typed_data';

import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';

/// [ReceiptPrinter] palsu: mencatat cetakan dan PDF yang dibagikan.
class FakeReceiptPrinter implements ReceiptPrinter {
  FakeReceiptPrinter({this.supportsBluetooth = true});

  @override
  final bool supportsBluetooth;

  List<PrinterSelection> paired = const [];

  /// Galat untuk panggilan cetak/cari berikutnya, lalu dikosongkan.
  PrinterFailure? nextFailure;

  /// Lokasi PDF yang dikembalikan [sharePdf] (desktop); `null` = share sheet.
  String? sharePath = '/home/kasir/Dokumen/Lakuna/Struk/nota.pdf';

  /// Bila diisi, [print] menunggu sampai completer ini selesai.
  Completer<void>? hold;

  final prints = <(PrinterSelection, List<ReceiptLine>, ReceiptPaper)>[];
  final shares = <(List<ReceiptLine>, ReceiptPaper, String)>[];
  final documentPrints = <(Uint8List, String)>[];
  final documentShares = <(Uint8List, String)>[];

  void _fail() {
    final f = nextFailure;
    nextFailure = null;
    if (f != null) throw f;
  }

  @override
  Future<List<PrinterSelection>> bluetoothPrinters() async {
    _fail();
    return paired;
  }

  @override
  Future<void> print(
    PrinterSelection printer,
    List<ReceiptLine> lines,
    ReceiptPaper paper, {
    required String jobName,
  }) async {
    _fail();
    if (hold case final h?) await h.future;
    prints.add((printer, lines, paper));
  }

  @override
  Future<String?> sharePdf(
    List<ReceiptLine> lines,
    ReceiptPaper paper, {
    required String fileName,
  }) async {
    _fail();
    shares.add((lines, paper, fileName));
    return sharePath;
  }

  @override
  Future<void> printDocument(Uint8List pdf, {required String jobName}) async {
    _fail();
    documentPrints.add((pdf, jobName));
  }

  @override
  Future<String?> shareDocument(
    Uint8List pdf, {
    required String fileName,
  }) async {
    _fail();
    documentShares.add((pdf, fileName));
    return sharePath;
  }
}
