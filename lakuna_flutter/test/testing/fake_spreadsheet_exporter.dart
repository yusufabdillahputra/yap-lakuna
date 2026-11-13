import 'dart:typed_data';

import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';

/// [SpreadsheetExporter] palsu: mencatat berkas yang diekspor.
class FakeSpreadsheetExporter implements SpreadsheetExporter {
  final saved = <(String, Uint8List)>[];

  /// Lokasi yang dikembalikan (desktop); `null` = share sheet.
  String? path = '/home/kasir/Dokumen/Lakuna/riwayat.xlsx';

  /// Galat yang dilempar [save] berikutnya (sekali pakai).
  Object? error;

  @override
  Future<String?> save(Uint8List bytes, {required String fileName}) async {
    if (error case final e?) {
      error = null;
      throw e;
    }
    saved.add((fileName, bytes));
    return path;
  }
}
