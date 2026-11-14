import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// JPEG kecil dengan Exif lokasi dan model ponsel, seperti foto kamera.
Uint8List _cameraJpeg({int orientation = 1}) {
  final image = img.Image(width: 64, height: 48);
  for (final p in image) {
    p
      ..r = (p.x * 4) % 256
      ..g = (p.y * 5) % 256
      ..b = 90;
  }
  image.exif.imageIfd
    ..make = 'MerekPonsel'
    ..model = 'PonselPemilik'
    ..orientation = orientation;
  image.exif.gpsIfd
    ..gpsLatitudeRef = 'S'
    ..gpsLatitude = 6.2;
  return img.encodeJpg(image, quality: 90);
}

bool _mentions(List<int> bytes, String text) =>
    latin1.decode(bytes).contains(text);

/// F1-07n: metadata dibuang dari gambar yang disimpan ke `media/`.
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

  Future<Uint8List> stored(MediaFile media) async =>
      (await readMediaFile(store, media))!;

  test('foto produk kecil: Exif lokasi dibuang, piksel sama', () async {
    final photo = _cameraJpeg();
    // Prasyarat: foto uji memang membawa metadata dan cukup kecil untuk
    // disimpan tanpa dikecilkan.
    expect(_mentions(photo, 'PonselPemilik'), isTrue);
    expect(photo.length, lessThan(photoKeepBytes));
    final id = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const ProductDraft(
        name: 'Kopi',
        baseUnit: 'pcs',
        variants: [VariantDraft(sellPrice: Money(2000))],
      ),
    );
    await setProductPhoto(
      store,
      scope,
      staffId: ctx.owner.id,
      productId: id,
      photo: ProductPhotoUpload(bytes: photo, fileName: 'kopi.jpg'),
    );
    final row = await Product.db.findById(store.session, id);
    final media = (await MediaFile.db.findById(
      store.session,
      row!.photoMediaId!,
    ))!;
    final bytes = await stored(media);
    for (final s in ['PonselPemilik', 'MerekPonsel']) {
      expect(_mentions(bytes, s), isFalse, reason: s);
    }
    final decoded = img.decodeJpg(bytes)!;
    expect(decoded.exif.gpsIfd.isEmpty, isTrue);
    final original = img.decodeJpg(photo)!;
    expect(decoded.getBytes(), original.getBytes());
    expect(media.sizeBytes, bytes.length);
    expect(media.sizeBytes, lessThan(photo.length));
    expect((media.width, media.height), (64, 48));
  });

  test('orientasi foto ponsel tetap dibawa', () async {
    final photo = _cameraJpeg(orientation: 6);
    final saved = await saveQrisSettings(
      store,
      scope,
      staffId: ctx.owner.id,
      settings: const QrisStaticSettings(
        enabled: true,
        merchantName: 'WARUNG CONTOH',
        nmid: 'ID10234567890',
      ),
      image: QrisImageUpload(bytes: photo, fileName: 'qris.jpg'),
    );
    final media = saved.media!;
    final bytes = await stored(media);
    expect(_mentions(bytes, 'PonselPemilik'), isFalse);
    // Orientasi masih terbaca (sama dengan cara Flutter/Skia membacanya):
    // sisi ditukar seperti saat ditampilkan.
    final header = readImageHeader(bytes)!;
    expect((header.width, header.height), (48, 64));
    expect((media.width, media.height), (48, 64));
  });
}
