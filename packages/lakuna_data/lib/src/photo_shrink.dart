import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:lakuna_domain/lakuna_domain.dart';

/// Berkas di bawah ukuran ini yang sisinya sudah dalam batas disimpan apa
/// adanya (F1-07l).
const photoKeepBytes = 512 * 1024;

/// Batas piksel sebelum didekode (±50 MP, mis. 8.192 × 6.144): berkas
/// kecil bisa menyatakan ukuran raksasa dan menghabiskan memori ponsel.
const photoMaxPixels = 50 * 1000 * 1000;

/// Hasil [shrinkPhoto] yang gagal.
enum PhotoShrinkError {
  /// Bukan gambar atau tidak bisa didekode.
  unreadable,

  /// Lebih dari [photoMaxPixels].
  tooManyPixels,
}

class PhotoShrinkFailure implements Exception {
  const PhotoShrinkFailure(this.reason);

  final PhotoShrinkError reason;

  @override
  String toString() => 'PhotoShrinkFailure(${reason.name})';
}

/// Mengecilkan foto [bytes] (PNG/JPG/WebP) agar sisi terpanjangnya paling
/// banyak [maxSide] (F1-07l).
///
/// - Foto dalam batas sisi dan ≤ [keepBytes] dikembalikan apa adanya.
/// - Orientasi EXIF diterapkan ke piksel; hasil tidak membawa EXIF.
/// - Hasil JPEG [quality], atau PNG bila ada piksel transparan. PNG yang
///   masih lebih dari [maxBytes] diratakan ke latar putih lalu jadi JPEG.
/// - Bila sisi asli sudah dalam batas dan hasil tidak lebih kecil, berkas
///   asli yang dikembalikan.
/// - Animasi: hanya bingkai pertama.
///
/// Gagal dengan [PhotoShrinkFailure]. Dekode dan enkode berjalan di isolate
/// terpisah.
Future<Uint8List> shrinkPhoto(
  Uint8List bytes, {
  required int maxSide,
  int? maxBytes,
  int keepBytes = photoKeepBytes,
  int quality = 85,
}) async {
  final header = readImageHeader(bytes);
  if (header == null) {
    throw const PhotoShrinkFailure(PhotoShrinkError.unreadable);
  }
  if (header.width * header.height > photoMaxPixels) {
    throw const PhotoShrinkFailure(PhotoShrinkError.tooManyPixels);
  }
  final fits = math.max(header.width, header.height) <= maxSide;
  if (fits && bytes.length <= keepBytes) return bytes;
  final out = await Isolate.run(
    () =>
        _shrink(bytes, maxSide: maxSide, maxBytes: maxBytes, quality: quality),
  );
  if (out == null) {
    throw const PhotoShrinkFailure(PhotoShrinkError.unreadable);
  }
  return fits && out.length >= bytes.length ? bytes : out;
}

Uint8List? _shrink(
  Uint8List bytes, {
  required int maxSide,
  required int? maxBytes,
  required int quality,
}) {
  try {
    final decoded = img.decodeImage(bytes, frame: 0);
    if (decoded == null) return null;
    final orientation = decoded.exif.imageIfd.orientation ?? 1;
    // Lebar/tinggi setelah orientasi EXIF (90°/270° menukar sisi).
    final swap = orientation >= 5 && orientation <= 8;
    final width = swap ? decoded.height : decoded.width;
    final height = swap ? decoded.width : decoded.height;
    final longest = math.max(width, height);
    img.Image image;
    if (longest > maxSide) {
      final scale = maxSide / longest;
      // copyResize ikut menerapkan orientasi EXIF.
      image = img.copyResize(
        decoded,
        width: math.max(1, (width * scale).round()),
        height: math.max(1, (height * scale).round()),
        interpolation: img.Interpolation.average,
      );
    } else if (orientation != 1) {
      image = img.bakeOrientation(decoded);
    } else {
      image = decoded;
    }
    image.exif = img.ExifData();
    if (_hasTransparency(image)) {
      final png = img.encodePng(image, level: 6);
      if (maxBytes == null || png.length <= maxBytes) return png;
      image = _onWhite(image);
    }
    return img.encodeJpg(image, quality: quality);
  } on Object {
    return null;
  }
}

/// Gambar transparan diratakan ke latar putih (untuk JPEG).
img.Image _onWhite(img.Image image) {
  final out = img.Image(width: image.width, height: image.height);
  img.fill(out, color: img.ColorRgb8(255, 255, 255));
  return img.compositeImage(out, image);
}

bool _hasTransparency(img.Image image) {
  if (!image.hasAlpha) return false;
  final max = image.maxChannelValue;
  for (final p in image) {
    if (p.a < max) return true;
  }
  return false;
}
