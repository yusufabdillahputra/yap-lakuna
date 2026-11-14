import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

/// Gambar gradasi + kotak-kotak (tidak rata, tidak berderau).
img.Image photo(int width, int height, {bool alpha = false}) {
  final image = img.Image(
    width: width,
    height: height,
    numChannels: alpha ? 4 : 3,
  );
  for (final p in image) {
    final x = p.x, y = p.y;
    p
      ..r = x * 255 ~/ width
      ..g = y * 255 ~/ height
      ..b = ((x ~/ 40 + y ~/ 40).isEven ? 200 : 60);
    if (alpha) p.a = x < width ~/ 2 ? 0 : 255;
  }
  return image;
}

void main() {
  test('foto besar dikecilkan ke sisi maksimum sebagai JPEG', () async {
    final big = Uint8List.fromList(
      img.encodeJpg(photo(3000, 2000), quality: 95),
    );
    final out = await shrinkPhoto(big, maxSide: 1024);
    final header = readImageHeader(out)!;
    expect(header.mimeType, 'image/jpeg');
    expect((header.width, header.height), (1024, 683));
    expect(out.length, lessThan(big.length));
  });

  test('foto tegak: sisi terpanjang = tinggi', () async {
    final big = Uint8List.fromList(img.encodeJpg(photo(1500, 3000)));
    final out = await shrinkPhoto(big, maxSide: 2000);
    final header = readImageHeader(out)!;
    expect((header.width, header.height), (1000, 2000));
  });

  test(
    'foto di atas batas sisi selalu dikecilkan walau PNG-nya kecil',
    () async {
      final big = Uint8List.fromList(img.encodePng(photo(3000, 2000)));
      final out = await shrinkPhoto(big, maxSide: 1024);
      expect(readImageHeader(out)!.width, 1024);
    },
  );

  test('PNG dengan piksel transparan tetap PNG', () async {
    final big = Uint8List.fromList(
      img.encodePng(photo(2048, 2048, alpha: true)),
    );
    final out = await shrinkPhoto(big, maxSide: 1024);
    final header = readImageHeader(out)!;
    expect(header.mimeType, 'image/png');
    expect((header.width, header.height), (1024, 1024));
    final decoded = img.decodePng(out)!;
    expect(decoded.getPixel(10, 10).a, 0);
    expect(decoded.getPixel(1000, 10).a, 255);
  });

  test('orientasi EXIF diterapkan ke piksel', () async {
    final source = photo(800, 400)..exif.imageIfd.orientation = 6;
    final jpg = Uint8List.fromList(img.encodeJpg(source));
    final out = await shrinkPhoto(jpg, maxSide: 600);
    final header = readImageHeader(out)!;
    // Diputar 90°: 400 × 800, lalu dikecilkan ke sisi 600.
    expect((header.width, header.height), (300, 600));
    expect(img.decodeJpg(out)!.exif.imageIfd.orientation ?? 1, 1);
  });

  test('foto kecil dalam batas disimpan apa adanya', () async {
    final small = Uint8List.fromList(img.encodeJpg(photo(600, 400)));
    expect(small.length, lessThan(512 * 1024));
    final out = await shrinkPhoto(small, maxSide: 1024);
    expect(out, same(small));
  });

  test('hasil yang tidak lebih kecil diganti berkas asli', () async {
    // JPEG kualitas rendah di dalam batas sisi tapi > keepBytes.
    final source = Uint8List.fromList(
      img.encodeJpg(photo(1000, 800), quality: 20),
    );
    final out = await shrinkPhoto(source, maxSide: 1024, keepBytes: 1);
    expect(out, same(source));
  });

  Matcher fails(PhotoShrinkError reason) => throwsA(
    isA<PhotoShrinkFailure>().having((e) => e.reason, 'reason', reason),
  );

  test('bukan gambar atau rusak → unreadable', () async {
    await expectLater(
      shrinkPhoto(Uint8List.fromList([1, 2, 3]), maxSide: 10),
      fails(PhotoShrinkError.unreadable),
    );
    final png = img.encodePng(photo(3000, 2000));
    final broken = Uint8List.fromList(png.sublist(0, 200));
    await expectLater(
      shrinkPhoto(broken, maxSide: 1024),
      fails(PhotoShrinkError.unreadable),
    );
  });

  test('header dengan piksel raksasa ditolak sebelum didekode', () async {
    // PNG kecil yang menyatakan 10.000 × 10.000 (100 MP).
    final huge = Uint8List.fromList(
      img.encodePng(img.Image(width: 10000, height: 10000)),
    );
    expect(huge.length, lessThan(2 * 1024 * 1024));
    await expectLater(
      shrinkPhoto(huge, maxSide: 1024),
      fails(PhotoShrinkError.tooManyPixels),
    );
  });

  test('gambar sangat tipis tidak jadi lebar 0', () async {
    final thin = Uint8List.fromList(img.encodePng(photo(1, 5000)));
    final out = await shrinkPhoto(thin, maxSide: 1024);
    final header = readImageHeader(out)!;
    expect((header.width, header.height), (1, 1024));
  });

  test('animasi: hanya bingkai pertama yang dipakai', () async {
    final anim = photo(1500, 1500);
    for (var i = 0; i < 4; i++) {
      anim.addFrame(photo(1500, 1500));
    }
    final apng = Uint8List.fromList(img.encodePng(anim));
    final out = await shrinkPhoto(apng, maxSide: 500);
    final decoded = img.decodeImage(out)!;
    expect(decoded.numFrames, 1);
    expect(decoded.width, 500);
  });

  test(
    'PNG transparan yang masih terlalu besar jadi JPEG berlatar putih',
    () async {
      final rnd = Random(3);
      final noisy = img.Image(width: 1600, height: 1200, numChannels: 4);
      for (final p in noisy) {
        p
          ..r = rnd.nextInt(256)
          ..g = rnd.nextInt(256)
          ..b = rnd.nextInt(256)
          ..a = p.x == 0 && p.y == 0 ? 0 : 255;
      }
      final source = Uint8List.fromList(img.encodePng(noisy));
      final out = await shrinkPhoto(
        source,
        maxSide: 1024,
        maxBytes: 1024 * 1024,
      );
      final header = readImageHeader(out)!;
      expect(header.mimeType, 'image/jpeg');
      final px = img.decodeJpg(out)!.getPixel(0, 0);
      expect(px.r, greaterThan(200));
    },
  );
}
