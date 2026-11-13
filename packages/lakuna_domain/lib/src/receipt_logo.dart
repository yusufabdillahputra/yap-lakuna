/// Logo di struk (F1-06b): pemeriksaan berkas dan bitmap hitam putih untuk
/// printer thermal (`GS v 0`).
library;

import 'dart:typed_data';

import 'image_header.dart';
import 'receipt.dart';

/// Ukuran maksimal berkas logo struk.
const maxReceiptLogoBytes = 1024 * 1024;

enum ReceiptLogoError { unsupported, tooLarge }

/// `null` bila [bytes] PNG/JPG sampai [maxReceiptLogoBytes].
ReceiptLogoError? checkReceiptLogo(List<int> bytes) {
  final header = readImageHeader(bytes);
  if (header == null ||
      (header.format != ImageFormat.png && header.format != ImageFormat.jpeg)) {
    return ReceiptLogoError.unsupported;
  }
  if (bytes.length > maxReceiptLogoBytes) return ReceiptLogoError.tooLarge;
  return null;
}

/// Ukuran maksimal logo dalam titik printer (203 dpi): kira-kira dua pertiga
/// lebar cetak 58 mm (384 titik) / 80 mm (576 titik), tinggi ±2 cm.
({int width, int height}) receiptLogoMaxDots(ReceiptPaper paper) =>
    switch (paper) {
      ReceiptPaper.mm58 => (width: 256, height: 160),
      ReceiptPaper.mm80 => (width: 384, height: 160),
    };

/// Lebar cetak printer thermal 203 dpi dalam titik: 384 (58 mm) / 576
/// (80 mm).
int receiptPrintDots(ReceiptPaper paper) => switch (paper) {
  ReceiptPaper.mm58 => 384,
  ReceiptPaper.mm80 => 576,
};

/// Bitmap 1 bit per titik, baris demi baris, bit teratas = titik paling
/// kiri, 1 = hitam (format data `GS v 0`).
class MonoBitmap {
  MonoBitmap(this.width, this.height, this.bits)
    : assert(bits.length == ((width + 7) >> 3) * height);

  final int width;
  final int height;
  final Uint8List bits;

  int get bytesPerRow => (width + 7) >> 3;

  bool isBlack(int x, int y) =>
      bits[y * bytesPerRow + (x >> 3)] & (0x80 >> (x & 7)) != 0;

  /// Bitmap selebar [totalWidth] dengan gambar ini di tengah (sisi kiri dan
  /// kanan putih), agar logo tetap di tengah pada printer yang mengabaikan
  /// `ESC a` untuk gambar raster. Bitmap ini sendiri bila sudah selebar
  /// atau lebih lebar.
  MonoBitmap centeredIn(int totalWidth) {
    if (totalWidth <= width) return this;
    final left = (totalWidth - width) >> 1;
    final stride = (totalWidth + 7) >> 3;
    final out = Uint8List(stride * height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (!isBlack(x, y)) continue;
        final nx = x + left;
        out[y * stride + (nx >> 3)] |= 0x80 >> (nx & 7);
      }
    }
    return MonoBitmap(totalWidth, height, out);
  }
}

/// Mengubah piksel RGBA [width]×[height] ke [MonoBitmap]: piksel
/// transparan dianggap putih, ambang luminans 50 %, dengan dithering
/// Floyd–Steinberg bila [dither].
MonoBitmap monoBitmapFromRgba(
  Uint8List rgba,
  int width,
  int height, {
  bool dither = true,
}) {
  if (width <= 0 || height <= 0 || rgba.length != width * height * 4) {
    throw ArgumentError('RGBA ${rgba.length} byte bukan $width×$height');
  }
  // Luminans 0..255 setelah dikomposit di atas putih (dikali 1000 agar
  // galat dithering tetap bilangan bulat).
  final lum = Int32List(width * height);
  for (var i = 0; i < width * height; i++) {
    final r = rgba[i * 4], g = rgba[i * 4 + 1], b = rgba[i * 4 + 2];
    final a = rgba[i * 4 + 3];
    final y = (299 * r + 587 * g + 114 * b) ~/ 1000;
    lum[i] = (y * a + 255 * (255 - a)) * 1000 ~/ 255;
  }
  final stride = (width + 7) >> 3;
  final bits = Uint8List(stride * height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = y * width + x;
      final old = lum[i];
      final black = old < 128000;
      if (black) bits[y * stride + (x >> 3)] |= 0x80 >> (x & 7);
      if (!dither) continue;
      final err = old - (black ? 0 : 255000);
      void spread(int dx, int dy, int weight) {
        final nx = x + dx, ny = y + dy;
        if (nx < 0 || nx >= width || ny >= height) return;
        lum[ny * width + nx] += err * weight ~/ 16;
      }

      spread(1, 0, 7);
      spread(-1, 1, 3);
      spread(0, 1, 5);
      spread(1, 1, 1);
    }
  }
  return MonoBitmap(width, height, bits);
}
