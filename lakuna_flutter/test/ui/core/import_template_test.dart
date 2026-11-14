import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
import 'package:lakuna_flutter/ui/core/import_template.dart';

void main() {
  test(
    'templat .xlsx terbaca kembali oleh pembaca import (F1-07g, F1-07p)',
    () {
      for (final (kind, lang) in [
        for (final k in ImportTemplateKind.values)
          for (final l in ['id', 'en']) (k, l),
      ]) {
        final table = readTableFile(
          kind.fileNameFor(lang),
          kind.bytesFor(lang),
        );
        expect(table, kind.rowsFor(lang), reason: '${kind.name} $lang');
        final (valid, rejected) = switch (kind) {
          ImportTemplateKind.products => (
            productImportRows(table).rows.length,
            productImportRows(table).rejected.length,
          ),
          ImportTemplateKind.customers => (
            customerImportRows(table).rows.length,
            customerImportRows(table).rejected.length,
          ),
          ImportTemplateKind.suppliers => (
            supplierImportRows(table).rows.length,
            supplierImportRows(table).rejected.length,
          ),
        };
        // Baris contoh dilewati saat import (F1-07g).
        expect((valid, rejected), (0, 2), reason: '${kind.name} $lang');
      }
    },
  );

  test('nama berkas, lembar, dan isi menurut bahasa (F1-07p)', () {
    expect(
      ImportTemplateKind.products.fileNameFor('id'),
      'templat-import-produk.xlsx',
    );
    expect(
      ImportTemplateKind.products.fileNameFor('en'),
      'import-template-products.xlsx',
    );
    expect(
      ImportTemplateKind.customers.fileNameFor('en'),
      'import-template-customers.xlsx',
    );
    expect(
      ImportTemplateKind.suppliers.fileNameFor('en'),
      'import-template-suppliers.xlsx',
    );
    expect(ImportTemplateKind.suppliers.sheetNameFor('en'), 'Suppliers');
    expect(ImportTemplateKind.customers.sheetNameFor('id'), 'Pelanggan');
    expect(
      ImportTemplateKind.customers.rowsFor('en'),
      customerImportTemplateEn,
    );
    // Bahasa lain memakai templat Indonesia.
    expect(ImportTemplateKind.products.rowsFor('jv'), productImportTemplate);
  });

  test('templat EN: kolom Phone, SKU, Barcode berformat teks', () {
    String sheet(ImportTemplateKind kind) => utf8.decode(
      ZipDecoder()
              .decodeBytes(kind.bytesFor('en'))
              .findFile('xl/worksheets/sheet1.xml')!
              .content
          as List<int>,
    );
    final customers = sheet(ImportTemplateKind.customers);
    expect(customers, matches(RegExp(r'<col min="2" max="2"[^>]*style="3"')));
    expect(customers, contains('<c r="E2"><v>2000000</v></c>'));
    final suppliers = sheet(ImportTemplateKind.suppliers);
    expect(suppliers, matches(RegExp(r'<col min="3" max="3"[^>]*style="3"')));
    final products = sheet(ImportTemplateKind.products);
    for (final c in [5, 6]) {
      expect(products, matches(RegExp('<col min="$c" max="$c"[^>]*style="3"')));
    }
  });

  test(
    'HP/Telepon, SKU, Barcode berformat teks; angka contoh berupa angka',
    () {
      final xml = {
        for (final kind in ImportTemplateKind.values)
          kind: utf8.decode(
            ZipDecoder()
                    .decodeBytes(kind.bytesFor('id'))
                    .findFile('xl/worksheets/sheet1.xml')!
                    .content
                as List<int>,
          ),
      };
      final customers = xml[ImportTemplateKind.customers]!;
      expect(customers, matches(RegExp(r'<col min="2" max="2"[^>]*style="3"')));
      expect(customers, contains('<c r="E2"><v>2000000</v></c>'));
      final suppliers = xml[ImportTemplateKind.suppliers]!;
      expect(suppliers, matches(RegExp(r'<col min="3" max="3"[^>]*style="3"')));
      expect(suppliers, contains('<c r="C2" t="inlineStr" s="3">'));
      final products = xml[ImportTemplateKind.products]!;
      for (final c in [5, 6]) {
        expect(
          products,
          matches(RegExp('<col min="$c" max="$c"[^>]*style="3"')),
        );
      }
      expect(
        products,
        isNot(matches(RegExp(r'<col min="8" max="8"[^>]*style'))),
      );
      expect(products, contains('<c r="H2"><v>17500</v></c>'));
    },
  );
}
