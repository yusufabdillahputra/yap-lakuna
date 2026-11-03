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
}
