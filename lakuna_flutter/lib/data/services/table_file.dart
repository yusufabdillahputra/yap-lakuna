import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show parseCsv;
import 'package:xml/xml.dart';

/// Berkas tabel (CSV/XLSX) yang dipilih pengguna.
class PickedTableFile {
  const PickedTableFile({required this.name, required this.size, this.bytes});

  final String name;
  final int size;

  /// `null` bila melebihi batas (tidak dibaca).
  final Uint8List? bytes;
}

/// Berkas tidak bisa dibaca sebagai tabel (rusak atau format lain).
class TableFileUnreadable implements Exception {
  const TableFileUnreadable();

  @override
  String toString() => 'TableFileUnreadable';
}

/// Memilih satu berkas `.csv` atau `.xlsx` (import pelanggan F1-13).
abstract class TableFilePicker {
  const TableFilePicker();

  /// `null` bila dibatalkan.
  Future<PickedTableFile?> pickTable({required int maxBytes});
}

class FileSelectorTablePicker extends TableFilePicker {
  const FileSelectorTablePicker();

  static const _types = XTypeGroup(
    label: 'CSV, Excel',
    extensions: ['csv', 'xlsx'],
    mimeTypes: [
      'text/csv',
      'text/comma-separated-values',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ],
    uniformTypeIdentifiers: [
      'public.comma-separated-values-text',
      'org.openxmlformats.spreadsheetml.sheet',
    ],
  );

  @override
  Future<PickedTableFile?> pickTable({required int maxBytes}) async {
    final file = await openFile(acceptedTypeGroups: const [_types]);
    if (file == null) return null;
    final size = await file.length();
    return PickedTableFile(
      name: file.name,
      size: size,
      bytes: size > maxBytes ? null : await file.readAsBytes(),
    );
  }
}

/// Isi berkas [name] sebagai baris sel teks: `.xlsx` (lembar pertama) atau
/// CSV (UTF-8, pemisah `,`/`;`). Gagal dengan [TableFileUnreadable].
List<List<String>> readTableFile(String name, Uint8List bytes) {
  final xlsx =
      name.toLowerCase().endsWith('.xlsx') ||
      (bytes.length > 1 && bytes[0] == 0x50 && bytes[1] == 0x4B);
  try {
    if (xlsx) return readXlsx(bytes);
    return parseCsv(utf8.decode(bytes, allowMalformed: true));
  } on TableFileUnreadable {
    rethrow;
  } on Exception {
    throw const TableFileUnreadable();
  } on ArgumentError {
    throw const TableFileUnreadable();
  }
}

/// Lembar pertama `.xlsx` sebagai teks. Sel angka bulat ditulis tanpa
/// desimal (`2000000`, bukan `2000000.0`); sel kosong di tengah diisi `''`.
List<List<String>> readXlsx(Uint8List bytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Object {
    throw const TableFileUnreadable();
  }
  String? text(String path) {
    final f = archive.findFile(path);
    if (f == null) return null;
    return utf8.decode(f.content, allowMalformed: true);
  }

  final sheetPath = _firstSheetPath(text) ?? 'xl/worksheets/sheet1.xml';
  final sheetXml = text(sheetPath);
  if (sheetXml == null) throw const TableFileUnreadable();
  final shared = <String>[];
  if (text('xl/sharedStrings.xml') case final s?) {
    for (final si in XmlDocument.parse(s).findAllElements('si')) {
      shared.add(si.findAllElements('t').map((t) => t.innerText).join());
    }
  }
  final rows = <List<String>>[];
  for (final row in XmlDocument.parse(sheetXml).findAllElements('row')) {
    final cells = <String>[];
    for (final c in row.findElements('c')) {
      final ref = c.getAttribute('r');
      final col = ref == null ? cells.length : _columnIndex(ref);
      while (cells.length < col) {
        cells.add('');
      }
      final type = c.getAttribute('t');
      final v = c.getElement('v')?.innerText ?? '';
      final value = switch (type) {
        's' => _shared(shared, v),
        'inlineStr' => c.findAllElements('t').map((t) => t.innerText).join(),
        'str' || 'e' => v,
        'b' => v == '1' ? 'TRUE' : 'FALSE',
        _ => _number(v),
      };
      if (col < cells.length) {
        cells[col] = value;
      } else {
        cells.add(value);
      }
    }
    rows.add(cells);
  }
  return rows;
}

String _shared(List<String> shared, String v) {
  final i = int.tryParse(v);
  return i != null && i >= 0 && i < shared.length ? shared[i] : '';
}

String _number(String v) {
  final n = num.tryParse(v);
  if (n == null) return v;
  if (n == n.roundToDouble() && n.abs() < 1e15) return n.round().toString();
  // Pecahan memakai koma desimal (format Indonesia) agar `2.375` dari sel
  // angka tidak terbaca sebagai 2.375 ribu oleh pengurai import.
  if (!v.contains(RegExp('[eE]'))) return v.replaceAll('.', ',');
  return v;
}

/// Kolom `A` → 0, `AA` → 26 dari referensi sel `AA12`.
int _columnIndex(String ref) {
  var n = 0;
  for (final unit in ref.codeUnits) {
    if (unit < 65 || unit > 90) break;
    n = n * 26 + (unit - 64);
  }
  return n - 1;
}

/// Lokasi lembar pertama dari `workbook.xml` + relasinya.
String? _firstSheetPath(String? Function(String path) text) {
  final workbook = text('xl/workbook.xml');
  final rels = text('xl/_rels/workbook.xml.rels');
  if (workbook == null || rels == null) return null;
  final sheet = XmlDocument.parse(workbook)
      .findAllElements('sheet')
      .firstOrNull;
  final id = sheet?.attributes
      .where((a) => a.name.local == 'id')
      .firstOrNull
      ?.value;
  if (id == null) return null;
  for (final r in XmlDocument.parse(rels).findAllElements('Relationship')) {
    if (r.getAttribute('Id') != id) continue;
    final target = r.getAttribute('Target');
    if (target == null) return null;
    if (target.startsWith('/')) return target.substring(1);
    return 'xl/$target';
  }
  return null;
}
