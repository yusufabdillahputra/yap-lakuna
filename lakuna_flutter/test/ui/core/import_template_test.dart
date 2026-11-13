import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
import 'package:lakuna_flutter/ui/core/import_template.dart';

void main() {
  test('templat .xlsx terbaca kembali oleh pembaca import (F1-07g)', () {
    for (final kind in ImportTemplateKind.values) {
      final table = readTableFile(kind.fileName, kind.bytes);
      expect(table, kind.rows, reason: kind.name);
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
      expect((valid, rejected), (2, 0), reason: kind.name);
    }
  });
}
