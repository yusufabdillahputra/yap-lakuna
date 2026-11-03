import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<QrisConfig> save(
    QrisStaticSettings settings, {
    QrisImageUpload? image,
  }) => saveQrisSettings(
    store,
    scope,
    staffId: ctx.owner.id,
    settings: settings,
    image: image,
  );

  test('belum diatur: nonaktif tanpa gambar', () async {
    final config = await loadQrisConfig(store, scope);
    expect(config.settings.enabled, isFalse);
    expect(config.media, isNull);
    expect(config.isUsable, isFalse);
  });

  test('simpan gambar + isian lalu muat ulang', () async {
    final bytes = pngBytes(1080, 1528);
    final saved = await save(
      const QrisStaticSettings(
        enabled: true,
        merchantName: ' WARUNG CONTOH ',
        nmid: 'id10234567890',
        terminalCode: 'A01',
        settlementNote: 'Rekening BCA 123-456-7890',
      ),
      image: QrisImageUpload(bytes: bytes, fileName: 'qris-warung.png'),
    );
    expect(saved.isUsable, isTrue);
    expect(saved.settings.nmid, 'ID10234567890');
    expect(saved.settings.merchantName, 'WARUNG CONTOH');
    final media = saved.media!;
    expect(media.kind, MediaKind.qrisSticker);
    expect(media.fileName, 'qris-warung.png');
    expect(media.mimeType, 'image/png');
    expect(media.sizeBytes, bytes.length);
    expect((media.width, media.height), (1080, 1528));
    expect(media.storageKey, '${media.sha256}.png');
    expect(media.outletId, ctx.outlet.id);
    expect(
      File('${store.mediaDirectory}/${media.storageKey}').readAsBytesSync(),
      bytes,
    );

    final loaded = await loadQrisConfig(store, scope);
    expect(loaded.settings.enabled, isTrue);
    expect(loaded.settings.mediaId, media.id);
    expect(loaded.settings.settlementNote, 'Rekening BCA 123-456-7890');
    expect(loaded.media!.id, media.id);
    expect(loaded.imageBytes, bytes);

    final row = await Setting.db.findFirstRow(
      store.session,
      where: (s) => s.key.equals(qrisStaticSettingKey),
    );
    expect(row!.scopeKey, settingScopeOutlet(ctx.outlet.id));
    expect(row.outletId, ctx.outlet.id);

    final outbox = (await SyncOutboxEntry.db.find(store.session))
        .map((e) => e.entity);
    expect(outbox, containsAll(['settings', 'media_files']));
  });

  test('simpan ulang memperbarui baris yang sama; gambar sama tidak '
      'disalin dua kali', () async {
    final bytes = pngBytes(1080, 1528);
    final first = await save(
      const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: bytes, fileName: 'a.png'),
    );
    final second = await save(
      first.settings.copyWith(merchantName: 'TOKO'),
      image: QrisImageUpload(bytes: bytes, fileName: 'b.png'),
    );
    expect(second.media!.id, first.media!.id);
    expect(await MediaFile.db.count(store.session), 1);
    expect(await Setting.db.count(store.session), 1);
    final row = (await Setting.db.find(store.session)).single;
    expect(row.version, 2);
    expect(Directory(store.mediaDirectory).listSync(), hasLength(1));

    // Tanpa gambar baru: gambar lama tetap dipakai.
    final third = await save(second.settings.copyWith(terminalCode: 'B02'));
    expect(third.media!.id, first.media!.id);
    expect(third.settings.terminalCode, 'B02');
  });

  test('aktif tanpa gambar dan isian salah ditolak', () async {
    await expectLater(
      save(const QrisStaticSettings(enabled: true)),
      throwsA(
        isA<QrisSettingsInvalid>().having((e) => e.errors, 'errors', {
          QrisSettingsError.imageMissing,
        }),
      ),
    );
    await expectLater(
      save(const QrisStaticSettings(nmid: 'ID-1')),
      throwsA(isA<QrisSettingsInvalid>()),
    );
    expect(await Setting.db.count(store.session), 0);
  });

  test('gambar bukan PNG/JPG/WebP ditolak tanpa menulis apa pun', () async {
    await expectLater(
      save(
        const QrisStaticSettings(enabled: true),
        image: QrisImageUpload(
          bytes: Uint8List.fromList('GIF89a......'.codeUnits),
          fileName: 'qris.gif',
        ),
      ),
      throwsA(
        isA<QrisImageInvalid>().having(
          (e) => e.error,
          'error',
          QrisImageError.unsupported,
        ),
      ),
    );
    expect(await MediaFile.db.count(store.session), 0);
    expect(Directory(store.mediaDirectory).existsSync(), isFalse);
  });

  test('pengaturan cabang lain tidak terbaca', () async {
    await save(
      const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: pngBytes(1080, 1528), fileName: 'a.png'),
    );
    final other = CatalogScope(
      tenantId: scope.tenantId,
      outletId: UuidValue.fromString(newId()),
      deviceId: scope.deviceId,
    );
    expect((await loadQrisConfig(store, other)).isUsable, isFalse);
  });

  test('stiker sama di cabang lain mendapat baris media sendiri', () async {
    final actor = ctx.owner.id;
    final outlet = await store.write(actor: actor, (w) async {
      final s = await w.stamp();
      return w.insert(
        Outlet(
          tenantId: ctx.tenant.id,
          code: 'CB2',
          name: 'Cabang Dua',
          timezone: 'Asia/Jakarta',
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
    final bytes = pngBytes(1080, 1528);
    final a = await save(
      const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: bytes, fileName: 'a.png'),
    );
    final other = CatalogScope(
      tenantId: scope.tenantId,
      outletId: outlet.id,
      deviceId: scope.deviceId,
    );
    final b = await saveQrisSettings(
      store,
      other,
      staffId: actor,
      settings: const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: bytes, fileName: 'b.png'),
    );
    expect(b.media!.id, isNot(a.media!.id));
    expect(b.media!.outletId, outlet.id);
    expect(b.isUsable, isTrue);
  });

  test('baris pengaturan rusak (bukan objek) ditimpa saat simpan', () async {
    await save(const QrisStaticSettings(merchantName: 'LAMA'));
    final row = await Setting.db.findFirstRow(
      store.session,
      where: (t) => t.key.equals(qrisStaticSettingKey),
    );
    await Setting.db.updateRow(store.session, row!.copyWith(valueJson: '[1]'));
    expect((await loadQrisConfig(store, scope)).settings.merchantName, '');
    final saved = await save(const QrisStaticSettings(merchantName: 'BARU'));
    expect(saved.settings.merchantName, 'BARU');
  });
}
