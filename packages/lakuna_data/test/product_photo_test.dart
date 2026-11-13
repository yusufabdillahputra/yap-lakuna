import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-07f: foto produk.
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late UuidValue kopiId;

  UuidValue owner() => ctx.owner.id;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    kopiId = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Kopi Sachet',
        baseUnit: 'sachet',
        variants: [VariantDraft(sellPrice: Money(2000))],
      ),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<void> setPhoto(Uint8List bytes, {UuidValue? id, CatalogScope? s}) =>
      setProductPhoto(
        store,
        s ?? scope,
        staffId: owner(),
        productId: id ?? kopiId,
        photo: ProductPhotoUpload(bytes: bytes, fileName: 'kopi.png'),
      );

  test('simpan foto: baris media, versi naik, outbox, photoPath', () async {
    final before = await SyncOutboxEntry.db.count(store.session);
    await setPhoto(pngBytes(400, 300));
    // Baris media + baris produk.
    expect(await SyncOutboxEntry.db.count(store.session), before + 2);
    final row = await Product.db.findById(store.session, kopiId);
    expect(row!.version, 2);
    final media = await MediaFile.db.findById(store.session, row.photoMediaId!);
    expect(media!.kind, MediaKind.productPhoto);
    expect(media.outletId, isNull);
    expect(media.width, 400);

    final kopi = (await loadProduct(store, scope, kopiId))!;
    expect(kopi.photoMediaId, media.id);
    expect(kopi.photoPath, endsWith(media.storageKey));
    expect(File(kopi.photoPath!).existsSync(), isTrue);
    expect((await listProducts(store, scope)).single.photoPath, kopi.photoPath);
  });

  test('ganti foto, lalu simpan produk tidak menghapus foto', () async {
    await setPhoto(pngBytes(400, 300));
    await setPhoto(pngBytes(200, 200, fill: 7));
    var kopi = (await loadProduct(store, scope, kopiId))!;
    final media = await MediaFile.db.findById(
      store.session,
      kopi.photoMediaId!,
    );
    expect(media!.width, 200);

    await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: () {
        final d = kopi.toDraft();
        return ProductDraft(
          id: d.id,
          name: 'Kopi Sachet Susu',
          baseUnit: d.baseUnit,
          variants: d.variants,
        );
      }(),
    );
    kopi = (await loadProduct(store, scope, kopiId))!;
    expect(kopi.name, 'Kopi Sachet Susu');
    expect(kopi.photoMediaId, media.id);
  });

  test('hapus foto', () async {
    await setPhoto(pngBytes(400, 300));
    await clearProductPhoto(store, scope, staffId: owner(), productId: kopiId);
    final kopi = (await loadProduct(store, scope, kopiId))!;
    expect(kopi.photoMediaId, isNull);
    expect(kopi.photoPath, isNull);
    // Hapus lagi: tidak ada perubahan, tidak galat.
    final version = (await Product.db.findById(store.session, kopiId))!.version;
    await clearProductPhoto(store, scope, staffId: owner(), productId: kopiId);
    expect(
      (await Product.db.findById(store.session, kopiId))!.version,
      version,
    );
  });

  test('bukan gambar atau terlalu besar ditolak tanpa menulis', () async {
    final before = await SyncOutboxEntry.db.count(store.session);
    await expectLater(
      setPhoto(Uint8List.fromList(List.filled(64, 1))),
      throwsA(
        isA<ProductPhotoInvalid>().having(
          (e) => e.reason,
          'reason',
          ProductPhotoError.unsupported,
        ),
      ),
    );
    final big = Uint8List(ProductLimits.photoMaxBytes + 1)
      ..setAll(0, pngBytes(10, 10));
    await expectLater(
      setPhoto(big),
      throwsA(
        isA<ProductPhotoInvalid>().having(
          (e) => e.reason,
          'reason',
          ProductPhotoError.tooLarge,
        ),
      ),
    );
    expect(await SyncOutboxEntry.db.count(store.session), before);
  });

  test('produk tenant lain atau diarsipkan tidak bisa diberi foto', () async {
    final other = await store.session.db.insertRow(
      Tenant(name: 'Toko Lain', hlc: 'x'),
    );
    final otherScope = CatalogScope(
      tenantId: other.id,
      outletId: ctx.outlet.id,
      deviceId: store.deviceId,
    );
    await expectLater(
      setPhoto(pngBytes(10, 10), s: otherScope),
      throwsA(isA<ProductNotFound>()),
    );
    await archiveProduct(store, scope, staffId: owner(), productId: kopiId);
    await expectLater(
      setPhoto(pngBytes(10, 10)),
      throwsA(isA<ProductNotFound>()),
    );
  });

  test('berkas foto belum ada di perangkat → photoPath null', () async {
    await setPhoto(pngBytes(400, 300));
    final kopi = (await loadProduct(store, scope, kopiId))!;
    File(kopi.photoPath!).deleteSync();
    final again = (await loadProduct(store, scope, kopiId))!;
    expect(again.photoMediaId, kopi.photoMediaId);
    expect(again.photoPath, isNull);
  });
}
