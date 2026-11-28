import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

Uint8List _bytes(int n, int v) => Uint8List.fromList(List.filled(n, v));

void main() {
  group('MemoryMediaBlobs (F2-02 aturan 8)', () {
    test('LRU: kunci terlama dibuang saat melebihi batas', () async {
      final blobs = MemoryMediaBlobs(maxBytes: 10);
      await blobs.write('a', _bytes(4, 1));
      await blobs.write('b', _bytes(4, 2));
      await blobs.write('c', _bytes(4, 3));
      expect(await blobs.exists('a'), isFalse);
      expect(await blobs.read('b'), _bytes(4, 2));
      expect(await blobs.read('c'), _bytes(4, 3));
    });

    test('read menjadikan kunci paling baru', () async {
      final blobs = MemoryMediaBlobs(maxBytes: 10);
      await blobs.write('a', _bytes(4, 1));
      await blobs.write('b', _bytes(4, 2));
      await blobs.read('a');
      await blobs.write('c', _bytes(4, 3));
      expect(await blobs.exists('a'), isTrue);
      expect(await blobs.exists('b'), isFalse);
    });

    test('tersemat tidak dibuang sampai unpin', () async {
      final blobs = MemoryMediaBlobs(maxBytes: 10);
      await blobs.write('p', _bytes(8, 9), pinned: true);
      await blobs.write('a', _bytes(8, 1));
      expect(await blobs.exists('p'), isTrue);
      expect(blobs.pinnedCount, 1);
      await blobs.unpin('p');
      expect(blobs.pinnedCount, 0);
      await blobs.write('b', _bytes(4, 2));
      expect(await blobs.exists('p'), isFalse);
      expect(blobs.localPath('b'), isNull);
    });
  });

  group('FileMediaBlobs', () {
    late Directory dir;
    setUp(() async => dir = await Directory.systemTemp.createTemp('blobs_'));
    tearDown(() => dir.delete(recursive: true));

    test('tulis lalu baca, path lokal ada', () async {
      final blobs = FileMediaBlobs('${dir.path}/media');
      expect(await blobs.exists('x.png'), isFalse);
      expect(blobs.localPath('x.png'), isNull);
      await blobs.write('x.png', _bytes(3, 7), pinned: true);
      expect(await blobs.read('x.png'), _bytes(3, 7));
      expect(File(blobs.localPath('x.png')!).existsSync(), isTrue);
      expect(blobs.pinnedCount, 0);
    });
  });

  test('store dengan media memori: simpan + baca tanpa folder', () async {
    final dir = await Directory.systemTemp.createTemp('lakuna_test_');
    addTearDown(() => dir.delete(recursive: true));
    final store = await LakunaStore.open(
      '${dir.path}/lakuna.sqlite',
      media: MemoryMediaBlobs(),
    );
    addTearDown(store.close);
    final ctx = await setupTestStore(store);
    final bytes = pngBytes(20, 30);
    final saved = await saveQrisSettings(
      store,
      CatalogScope.of(ctx),
      staffId: ctx.owner.id,
      settings: const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: bytes, fileName: 'q.png'),
    );
    final media = saved.media!;
    expect(await readMediaFile(store, media), bytes);
    expect(store.media.pinnedCount, 1);
    expect(Directory('${dir.path}/media').existsSync(), isFalse);
    expect(media.kind, MediaKind.qrisSticker);
  });
}
