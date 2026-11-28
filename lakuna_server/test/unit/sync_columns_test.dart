import 'dart:io';

import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_server/src/sync/apply_change.dart';
import 'package:test/test.dart';

/// Penerap push memetakan kolom Postgres ke kunci payload dengan
/// [dartNameOf]; tes ini memastikan setiap field model tabel sync memang
/// camelCase dari nama kolomnya.
void main() {
  test('nama field model tabel sync = camelCase nama kolom', () {
    final field = RegExp(r'^  (\w+): [^,\n]+(.*)$', multiLine: true);
    final column = RegExp(r'column=(\w+)');
    var checked = 0;
    for (final file in Directory('lib/src').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.spy.yaml')) continue;
      final text = file.readAsStringSync();
      final table = RegExp(r'^table: (\w+)$', multiLine: true).firstMatch(text);
      if (table == null || syncTableByName(table.group(1)!) == null) continue;
      final fields = text.split(RegExp(r'^indexes:', multiLine: true)).first;
      for (final m in field.allMatches(fields)) {
        final name = m.group(1)!;
        final col = column.firstMatch(m.group(2)!)?.group(1) ?? name;
        expect(dartNameOf(col), name, reason: '${file.path}: $name');
        checked++;
      }
    }
    expect(checked, greaterThan(500));
  });
}
