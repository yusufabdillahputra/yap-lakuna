import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';
import 'testing/fake_media_transport.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late FakeMediaTransport server;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
    server = FakeMediaTransport(ctx.tenant.id);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<MediaFile> addMedia(
    List<int> content, {
    bool local = true,
    UuidValue? id,
  }) async {
    final bytes = Uint8List.fromList(content);
    final hash = sha256.convert(bytes).toString();
    final key = '$hash.png';
    if (local) {
      final file = File('${store.mediaDirectory}/$key');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
    final media = await store.write(actor: ctx.owner.id, (w) async {
      final s = await w.stamp();
      return w.insert(
        MediaFile(
          id: id,
          tenantId: ctx.tenant.id,
          kind: MediaKind.productPhoto,
          fileName: 'foto.png',
          mimeType: 'image/png',
          sizeBytes: bytes.length,
          sha256: hash,
          width: 1,
          height: 1,
          storageKey: key,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: s.actor,
          updatedBy: s.actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
    return media;
  }

  void pushed(MediaFile m) => server.rows[m.id] = m;

  test(
    'unggah berkas lokal sekali; hash sama tidak diunggah dua kali',
    () async {
      final a = await addMedia([1, 2, 3]);
      final twin = await addMedia([1, 2, 3]);
      pushed(a);
      pushed(twin);
      await uploadPendingMedia(store, server);
      expect(server.uploads, ['${ctx.tenant.id.uuid}/${a.storageKey}']);
      // Siklus berikutnya tidak memeriksa ulang yang sudah terunggah.
      final calls = server.calls;
      await uploadPendingMedia(store, server);
      expect(server.calls, calls);
    },
  );

  String path(MediaFile m) => '${ctx.tenant.id.uuid}/${m.storageKey}';

  test('baris media belum di-push tidak menahan berkas sesudahnya; '
      'dicoba lagi siklus berikutnya', () async {
    final a = await addMedia([4, 5]);
    final b = await addMedia([6, 7]);
    pushed(b);
    await uploadPendingMedia(store, server);
    expect(server.uploads, [path(b)]);
    pushed(a);
    await uploadPendingMedia(store, server);
    expect(server.uploads, [path(b), path(a)]);
    // Tuntas: tidak ada yang dicoba lagi.
    final calls = server.calls;
    await uploadPendingMedia(store, server);
    expect(server.calls, calls);
  });

  test('berkas lokal dengan ID lebih kecil dari baris tarikan (jam perangkat '
      'lain lebih cepat) tetap diunggah', () async {
    // Baris dari perangkat lain dengan jam 1 jam lebih cepat.
    final ahead = await addMedia(
      [3, 3],
      local: false,
      id: _uuidV7At(DateTime.now().add(const Duration(hours: 1))),
    );
    pushed(ahead);
    await uploadPendingMedia(store, server);
    final local = await addMedia([4, 4]);
    expect(local.id.uuid.compareTo(ahead.id.uuid), lessThan(0));
    pushed(local);
    await uploadPendingMedia(store, server);
    expect(server.uploads, [path(local)]);
  });

  test('unggahan macet dihentikan batas waktu, dicoba lagi', () async {
    final a = await addMedia([2, 2]);
    pushed(a);
    server.stall = true;
    await uploadPendingMedia(
      store,
      server,
      transferTimeout: const Duration(milliseconds: 50),
    );
    expect(server.uploads, isEmpty);
    server.stall = false;
    await uploadPendingMedia(store, server);
    expect(server.uploads, [path(a)]);
  });

  test('offline saat unggah: tidak melempar, dicoba lagi', () async {
    final a = await addMedia([8]);
    pushed(a);
    server.offline = true;
    await uploadPendingMedia(store, server);
    server.offline = false;
    await uploadPendingMedia(store, server);
    expect(server.uploads, hasLength(1));
  });

  test('media dari perangkat lain diunduh saat dibutuhkan', () async {
    final bytes = Uint8List.fromList([9, 9, 9]);
    final remote = await addMedia(bytes, local: false);
    pushed(remote);
    server.files['${ctx.tenant.id.uuid}/${remote.storageKey}'] = bytes;
    expect(await readMediaFile(store, remote), isNull);
    store.fetchMedia = (m) => ensureMediaLocal(store, server, m);
    expect(await readMediaFile(store, remote), bytes);
    // Tersimpan di folder media: tidak diunduh lagi.
    server.offline = true;
    expect(await readMediaFile(store, remote), bytes);
  });

  test('unduhan rusak (sha256 beda) dibuang: placeholder', () async {
    final remote = await addMedia([5, 5], local: false);
    pushed(remote);
    server.files['${ctx.tenant.id.uuid}/${remote.storageKey}'] =
        Uint8List.fromList([5, 5]);
    server.corrupt = Uint8List.fromList([0, 0]);
    expect(await ensureMediaLocal(store, server, remote), isNull);
    expect(
      File('${store.mediaDirectory}/${remote.storageKey}').existsSync(),
      isFalse,
    );
  });

  test('unduhan macet dihentikan batas waktu: placeholder', () async {
    final remote = await addMedia([6, 6], local: false);
    pushed(remote);
    server.files[path(remote)] = Uint8List.fromList([6, 6]);
    server.stall = true;
    expect(
      await ensureMediaLocal(
        store,
        server,
        remote,
        transferTimeout: const Duration(milliseconds: 50),
      ),
      isNull,
    );
  });

  test('layar tidak menunggu unduhan lama: placeholder dulu', () async {
    final remote = await addMedia([8, 8], local: false);
    store.fetchMedia = (_) => Completer<Uint8List?>().future;
    final watch = Stopwatch()..start();
    expect(
      await readMediaFile(
        store,
        remote,
        wait: const Duration(milliseconds: 50),
      ),
      isNull,
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  group('MediaFetcher', () {
    test('permintaan bersamaan untuk gambar sama: satu unduhan', () async {
      final bytes = Uint8List.fromList([1, 1, 1]);
      final remote = await addMedia(bytes, local: false);
      pushed(remote);
      server.files[path(remote)] = bytes;
      final fetcher = MediaFetcher(store, server);
      final results = await Future.wait([
        fetcher.fetch(remote),
        fetcher.fetch(remote),
        fetcher.fetch(remote),
      ]);
      expect(results, everyElement(bytes));
      expect(server.downloadUrls, 1);
    });

    test('gagal: tidak diminta lagi sebelum jeda habis', () async {
      var now = DateTime.utc(2026, 11, 28, 8);
      final remote = await addMedia([2, 3], local: false);
      pushed(remote);
      final fetcher = MediaFetcher(
        store,
        server,
        retryAfter: const Duration(minutes: 2),
        clock: () => now,
      );
      expect(await fetcher.fetch(remote), isNull);
      expect(await fetcher.fetch(remote), isNull);
      expect(server.downloadUrls, 1);
      now = now.add(const Duration(minutes: 3));
      server.files[path(remote)] = Uint8List.fromList([2, 3]);
      expect(await fetcher.fetch(remote), [2, 3]);
      expect(server.downloadUrls, 2);
    });

    test('daftar besar: paling banyak 3 unduhan bersamaan', () async {
      final media = [
        for (var i = 0; i < 8; i++) await addMedia([40 + i], local: false),
      ];
      for (final m in media) {
        pushed(m);
        server.files[path(m)] = Uint8List.fromList([40 + media.indexOf(m)]);
      }
      server.stall = true;
      final fetcher = MediaFetcher(store, server);
      for (final m in media) {
        unawaited(fetcher.fetch(m));
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(server.downloadUrls, 3);
    });
  });

  test('belum diunggah perangkat asal atau offline: placeholder', () async {
    final remote = await addMedia([7, 7], local: false);
    pushed(remote);
    expect(await ensureMediaLocal(store, server, remote), isNull);
    server.offline = true;
    expect(await ensureMediaLocal(store, server, remote), isNull);
  });
}

/// UUID v7 dengan cap waktu [at] (48 bit pertama).
UuidValue _uuidV7At(DateTime at) {
  final hex = at.millisecondsSinceEpoch.toRadixString(16).padLeft(12, '0');
  return UuidValue.fromString(
    '${hex.substring(0, 8)}-${hex.substring(8)}-7000-8000-000000000001',
  );
}
