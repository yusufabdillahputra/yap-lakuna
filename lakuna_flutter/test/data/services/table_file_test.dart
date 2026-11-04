import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';

void main() {
  test('XLSX buatan Lakuna terbaca kembali', () {
    final bytes = buildXlsx('Pelanggan', [
      ['Nama', 'HP', 'Limit'],
      ['Toko Bu Ani', '0813-2222-1010', const XlsxNumber(2000000)],
      ['Pak Darto', null, 0],
    ]);
    expect(readTableFile('pelanggan.xlsx', bytes), [
      ['Nama', 'HP', 'Limit'],
      ['Toko Bu Ani', '0813-2222-1010', '2000000'],
      ['Pak Darto', '', '0'],
    ]);
  });

  test('XLSX dengan sharedStrings, sel kosong, dan angka desimal', () {
    const sheet =
        '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<sheetData>'
        '<row r="1"><c r="A1" t="s"><v>0</v></c><c r="C1" t="s"><v>1</v></c></row>'
        '<row r="2"><c r="A2" t="s"><v>2</v></c><c r="B2"><v>81322221010</v></c>'
        '<c r="C2"><v>1500000.0</v></c><c r="D2"><v>2.5</v></c></row>'
        '</sheetData></worksheet>';
    const strings =
        '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'
        '<si><t>Nama</t></si><si><t>Limit</t></si>'
        '<si><r><t>Toko </t></r><r><t>Bu Ani</t></r></si></sst>';
    final archive = Archive()
      ..addFile(ArchiveFile.string('xl/worksheets/sheet1.xml', sheet))
      ..addFile(ArchiveFile.string('xl/sharedStrings.xml', strings));
    final bytes = Uint8List.fromList(ZipEncoder().encode(archive));
    expect(readTableFile('data.xlsx', bytes), [
      ['Nama', '', 'Limit'],
      ['Toko Bu Ani', '81322221010', '1500000', '2,5'],
    ]);
  });

  test('CSV UTF-8 dengan titik koma', () {
    final bytes = Uint8List.fromList(utf8.encode('nama;hp\nAni;0812\n'));
    expect(readTableFile('a.csv', bytes), [
      ['nama', 'hp'],
      ['Ani', '0812'],
    ]);
  });

  test('XLSX rusak → TableFileUnreadable', () {
    expect(
      () => readTableFile('x.xlsx', Uint8List.fromList([1, 2, 3])),
      throwsA(isA<TableFileUnreadable>()),
    );
  });
}
