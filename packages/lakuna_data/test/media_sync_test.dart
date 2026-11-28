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

  Future<MediaFile> addMedia(List<int> content, {bool local = true}) async {
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
      server.offline = true;
      await uploadPendingMedia(store, server);
    },
  );

  test(
    'baris media belum di-push: berhenti, dicoba siklus berikutnya',
    () async {
      final a = await addMedia([4, 5]);
      final b = await addMedia([6, 7]);
      pushed(a);
      await uploadPendingMedia(store, server);
      expect(server.uploads, hasLength(1));
      pushed(b);
      await uploadPendingMedia(store, server);
      expect(server.uploads, hasLength(2));
    },
  );

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

  test('belum diunggah perangkat asal atau offline: placeholder', () async {
    final remote = await addMedia([7, 7], local: false);
    pushed(remote);
    expect(await ensureMediaLocal(store, server, remote), isNull);
    server.offline = true;
    expect(await ensureMediaLocal(store, server, remote), isNull);
  });
}
