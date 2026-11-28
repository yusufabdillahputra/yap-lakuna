import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Perubahan yang hilang bila database web dihapus (F2-02 aturan 7–8,
/// review I1/I3): semua entri outbox yang belum diterima server + gambar
/// yang belum terunggah.
void main() {
  late LakunaStore store;
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_test_');
    store = await LakunaStore.open(
      '${dir.path}/lakuna.sqlite',
      media: MemoryMediaBlobs(),
    );
    await setupTestStore(store);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<void> setAll(OutboxStatus status, {String? lastError}) async {
    final all = await SyncOutboxEntry.db.find(store.session);
    await SyncOutboxEntry.db.update(store.session, [
      for (final e in all) e.copyWith(status: status, lastError: lastError),
    ]);
  }

  test('entri pending, sent, dan conflict dihitung; acked tidak', () async {
    final total = await SyncOutboxEntry.db.count(store.session);
    expect(total, greaterThan(0));
    expect(await countUnsentChanges(store), total);
    await setAll(OutboxStatus.conflict, lastError: 'dependency');
    expect(await countUnsentChanges(store), total);
    await setAll(OutboxStatus.acked);
    expect(await countUnsentChanges(store), 0);
  });

  test('gambar yang belum terunggah ikut dihitung', () async {
    await setAll(OutboxStatus.acked);
    await store.media.write('a.jpg', Uint8List(4), pinned: true);
    expect(await countUnsentChanges(store), 1);
    await store.media.unpin('a.jpg');
    expect(await countUnsentChanges(store), 0);
  });
}
