import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/data/services/web_session_store.dart';

void main() {
  late List<String> deleted;
  late MemoryWebSessionStore store;

  setUp(() {
    deleted = [];
    store = MemoryWebSessionStore(delete: (name) async => deleted.add(name));
  });

  test('database gabung tertunda bertahan saat stale dibersihkan', () async {
    await store.setPendingDatabase('lakuna-a.sqlite');
    await store.purgeStale();
    expect(store.pendingDatabase, 'lakuna-a.sqlite');
    expect(deleted, isEmpty);
  });

  test('gabung selesai: tertunda menjadi sesi aktif', () async {
    await store.setPendingDatabase('lakuna-a.sqlite');
    await store.setActiveDatabase('lakuna-a.sqlite');
    expect(store.pendingDatabase, isNull);
    expect(store.activeDatabase, 'lakuna-a.sqlite');
  });

  test('tertunda diganti atau dibatalkan: yang lama dihapus', () async {
    await store.setPendingDatabase('lakuna-a.sqlite');
    await store.setPendingDatabase('lakuna-b.sqlite');
    await store.setPendingDatabase(null);
    await store.purgeStale();
    expect(deleted, ['lakuna-a.sqlite', 'lakuna-b.sqlite']);
    expect(store.pendingDatabase, isNull);
  });

  test('klaim tab: masalah yang diatur tes dibalas', () async {
    expect(await store.claim(), isNull);
    final blocked = MemoryWebSessionStore(
      delete: (_) async {},
      problem: WebStartProblem.otherTab,
    );
    expect(await blocked.claim(), WebStartProblem.otherTab);
  });
}
