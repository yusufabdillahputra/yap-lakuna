import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:lakuna_server/src/sync/server_tables.dart';
import 'package:test/test.dart';

void main() {
  test('syncTables sama dengan tabel bisnis di Postgres', () {
    final business = {
      for (final t in Protocol().getTargetTableDefinitions())
        if (t.module == 'lakuna' && !serverOnlyTables.contains(t.name)) t.name,
    };
    final synced = syncTables.map((t) => t.name).toSet();
    expect(synced.difference(business), isEmpty, reason: 'tak ada di server');
    expect(business.difference(synced), isEmpty, reason: 'belum di syncTables');
    expect(synced.length, 46);
  });

  test('induk di syncTables sama dengan relasi FK di model', () {
    for (final t in Protocol().getTargetTableDefinitions()) {
      final sync = syncTableByName(t.name);
      if (sync == null) continue;
      final fkParents = {
        for (final fk in t.foreignKeys)
          if (fk.referenceTable != t.name) fk.referenceTable,
      };
      expect(sync.parents.toSet(), fkParents, reason: t.name);
      final selfFk = t.foreignKeys.where((fk) => fk.referenceTable == t.name);
      expect(sync.selfParentColumn != null, selfFk.isNotEmpty, reason: t.name);
    }
  });
}
