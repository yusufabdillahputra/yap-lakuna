import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;

  setUp(() async {
    (store, dir) = await openTempStore();
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test(
    'preferensi lokal bisa disimpan, ditimpa, dan tidak masuk outbox',
    () async {
      final prefs = LocalPreferences(store.session);
      expect(await prefs.get('theme_mode'), isNull);
      await prefs.set('theme_mode', 'dark');
      await prefs.set('theme_mode', 'light');
      expect(await prefs.get('theme_mode'), 'light');
      expect(await LocalPreference.db.count(store.session), 1);
      expect(await SyncOutboxEntry.db.count(store.session), 0);
    },
  );

  test('preferensi lokal bisa dihapus (F1-08o)', () async {
    final prefs = LocalPreferences(store.session);
    await prefs.remove('tidak_ada');
    await prefs.set('a', '1');
    await prefs.set('b', '2');
    await prefs.remove('a');
    expect(await prefs.get('a'), isNull);
    expect(await prefs.get('b'), '2');
    expect(await SyncOutboxEntry.db.count(store.session), 0);
  });
}
