import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/spreadsheet_exporter.dart';

void main() {
  test('kolom Excel A, Z, AA, AZ', () {
    expect(xlsxColumn(0), 'A');
    expect(xlsxColumn(25), 'Z');
    expect(xlsxColumn(26), 'AA');
    expect(xlsxColumn(51), 'AZ');
  });

  test('xlsx berisi bagian wajib, judul tebal, teks di-escape, angka', () {
    final bytes = buildXlsx(
      'Riwayat 03/11',
      [
        ['Nota', 'Total'],
        ['PST-K01-261103-0001', const XlsxNumber(15000)],
        ['Kopi & <roti>', null],
      ],
      widths: [24, 12],
    );
    final zip = ZipDecoder().decodeBytes(bytes);
    String part(String name) =>
        utf8.decode(zip.findFile(name)!.content as List<int>);
    expect(
      zip.files.map((f) => f.name),
      containsAll([
        '[Content_Types].xml',
        '_rels/.rels',
        'xl/workbook.xml',
        'xl/_rels/workbook.xml.rels',
        'xl/styles.xml',
        'xl/worksheets/sheet1.xml',
      ]),
    );
    expect(part('xl/workbook.xml'), contains('name="Riwayat 03 11"'));
    final sheet = part('xl/worksheets/sheet1.xml');
    expect(sheet, contains('<c r="A1" t="inlineStr" s="1">'));
    expect(sheet, contains('<c r="B2" s="2"><v>15000</v></c>'));
    expect(sheet, contains('Kopi &amp; &lt;roti&gt;'));
    expect(sheet, isNot(contains('r="B3"')));
    expect(sheet, contains('<col min="1" max="1" width="24"'));
  });
}
