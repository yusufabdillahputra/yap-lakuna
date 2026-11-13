import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import 'receipt_printer.dart' show receiptPdfDirectory;

/// Tipe MIME berkas Excel (`.xlsx`).
const xlsxMimeType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/// Satu sel angka dengan format ribuan (`#,##0`), mis. nilai rupiah.
@immutable
class XlsxNumber {
  const XlsxNumber(this.value);

  final int value;
}

/// Membuat berkas `.xlsx` satu lembar bernama [sheetName] dari [rows]
/// (F1-11). Baris pertama dianggap judul kolom: tebal dan dibekukan.
/// Sel: `String`, `int`, [XlsxNumber], atau `null` (kosong). [widths]
/// = lebar kolom dalam karakter. [textColumns] = indeks kolom berformat
/// teks (`@`) agar isian baru seperti no. HP atau barcode tidak kehilangan
/// nol di depan saat diketik di Excel (F1-07g).
///
/// Ditulis sendiri di atas `archive` (Office Open XML minimal) karena paket
/// `excel` tidak cocok dengan `xml` 7 yang dipakai `pdf`.
Uint8List buildXlsx(
  String sheetName,
  List<List<Object?>> rows, {
  List<int> widths = const [],
  Set<int> textColumns = const {},
}) {
  final sheet = StringBuffer()
    ..write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
    ..write('<worksheet xmlns="$_main">')
    ..write(
      '<sheetViews><sheetView workbookViewId="0">'
      '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" '
      'state="frozen"/></sheetView></sheetViews>',
    );
  final colCount = [
    widths.length,
    for (final c in textColumns) c + 1,
  ].fold(0, (a, b) => a > b ? a : b);
  if (colCount > 0) {
    sheet.write('<cols>');
    for (var i = 0; i < colCount; i++) {
      final width = i < widths.length
          ? ' width="${widths[i]}" customWidth="1"'
          : '';
      final style = textColumns.contains(i) ? ' style="3"' : '';
      if (width.isEmpty && style.isEmpty) continue;
      sheet.write('<col min="${i + 1}" max="${i + 1}"$width$style/>');
    }
    sheet.write('</cols>');
  }
  sheet.write('<sheetData>');
  for (var r = 0; r < rows.length; r++) {
    sheet.write('<row r="${r + 1}">');
    final header = r == 0;
    for (var c = 0; c < rows[r].length; c++) {
      final ref = '${xlsxColumn(c)}${r + 1}';
      switch (rows[r][c]) {
        case null:
          break;
        case final XlsxNumber n:
          sheet.write('<c r="$ref" s="2"><v>${n.value}</v></c>');
        case final int n:
          sheet.write(
            '<c r="$ref"${header ? ' s="1"' : ''}><v>$n</v></c>',
          );
        case final Object value:
          final style = header
              ? ' s="1"'
              : textColumns.contains(c)
              ? ' s="3"'
              : '';
          sheet.write(
            '<c r="$ref" t="inlineStr"$style>'
            '<is><t xml:space="preserve">${_escape('$value')}</t></is></c>',
          );
      }
    }
    sheet.write('</row>');
  }
  sheet.write('</sheetData></worksheet>');

  final archive = Archive()
    ..addFile(ArchiveFile.string('[Content_Types].xml', _contentTypes))
    ..addFile(ArchiveFile.string('_rels/.rels', _rootRels))
    ..addFile(ArchiveFile.string('xl/workbook.xml', _workbook(sheetName)))
    ..addFile(ArchiveFile.string('xl/_rels/workbook.xml.rels', _workbookRels))
    ..addFile(ArchiveFile.string('xl/styles.xml', _styles))
    ..addFile(ArchiveFile.string('xl/worksheets/sheet1.xml', '$sheet'));
  return ZipEncoder().encodeBytes(archive);
}

/// Huruf kolom Excel untuk indeks [index] (0 → `A`, 26 → `AA`).
String xlsxColumn(int index) {
  var n = index + 1;
  var name = '';
  while (n > 0) {
    final r = (n - 1) % 26;
    name = String.fromCharCode(65 + r) + name;
    n = (n - 1) ~/ 26;
  }
  return name;
}

String _escape(String text) => text
    .replaceAll(RegExp('[\\x00-\\x08\\x0B\\x0C\\x0E-\\x1F]'), '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

const _main = 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
const _rel =
    'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
const _pkgRel = 'http://schemas.openxmlformats.org/package/2006/relationships';
const _xmlHead = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';

const _contentTypes =
    '$_xmlHead<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
    '<Default Extension="xml" ContentType="application/xml"/>'
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
    '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>'
    '</Types>';

const _rootRels =
    '$_xmlHead<Relationships xmlns="$_pkgRel">'
    '<Relationship Id="rId1" Type="$_rel/officeDocument" Target="xl/workbook.xml"/>'
    '</Relationships>';

String _workbook(String sheetName) {
  // Nama lembar Excel: maks 31 karakter, tanpa : \ / ? * [ ].
  final name = sheetName.replaceAll(RegExp(r'[:\\/?*\[\]]'), ' ');
  final short = name.length > 31 ? name.substring(0, 31) : name;
  return '$_xmlHead<workbook xmlns="$_main" xmlns:r="$_rel">'
      '<sheets><sheet name="${_escape(short)}" sheetId="1" r:id="rId1"/></sheets>'
      '</workbook>';
}

const _workbookRels =
    '$_xmlHead<Relationships xmlns="$_pkgRel">'
    '<Relationship Id="rId1" Type="$_rel/worksheet" Target="worksheets/sheet1.xml"/>'
    '<Relationship Id="rId2" Type="$_rel/styles" Target="styles.xml"/>'
    '</Relationships>';

/// Gaya: 0 biasa, 1 tebal (judul), 2 angka `#,##0`, 3 teks (`@`).
const _styles =
    '$_xmlHead<styleSheet xmlns="$_main">'
    '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font>'
    '<font><b/><sz val="11"/><name val="Calibri"/></font></fonts>'
    '<fills count="2"><fill><patternFill patternType="none"/></fill>'
    '<fill><patternFill patternType="gray125"/></fill></fills>'
    '<borders count="1"><border><left/><right/><top/><bottom/><diagonal/></border></borders>'
    '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>'
    '<cellXfs count="4">'
    '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>'
    '<xf numFmtId="0" fontId="1" fillId="0" borderId="0" xfId="0" applyFont="1"/>'
    '<xf numFmtId="3" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>'
    '<xf numFmtId="49" fontId="0" fillId="0" borderId="0" xfId="0" applyNumberFormat="1"/>'
    '</cellXfs>'
    '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>'
    '</styleSheet>';

/// Menyimpan atau membagikan berkas ekspor (F1-11).
abstract class SpreadsheetExporter {
  /// Berkas `.xlsx` atau `.pdf` (menurut ekstensi [fileName]).
  /// Android/iOS: share sheet (hasil `null`). Desktop: disimpan ke folder
  /// dokumen Lakuna yang sama dengan PDF struk (hasil = lokasi berkas).
  Future<String?> save(Uint8List bytes, {required String fileName});
}

class PlatformSpreadsheetExporter implements SpreadsheetExporter {
  const PlatformSpreadsheetExporter();

  bool get _mobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<String?> save(Uint8List bytes, {required String fileName}) async {
    if (_mobile) {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: fileName.endsWith('.pdf')
                  ? 'application/pdf'
                  : xlsxMimeType,
              name: fileName,
            ),
          ],
          fileNameOverrides: [fileName],
        ),
      );
      return null;
    }
    final dir = await receiptPdfDirectory();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
