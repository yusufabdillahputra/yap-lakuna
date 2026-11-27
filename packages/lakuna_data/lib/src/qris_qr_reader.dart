import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:zxing2/qrcode.dart';

import 'photo_shrink.dart' show photoMaxPixels;

/// Sisi terpanjang gambar yang dibaca dekoder. Foto/berkas lebih besar
/// diperkecil dulu agar cepat di ponsel; QR stiker tetap cukup tajam.
const qrisQrDecodeMaxSide = 1600;

/// Baca kode QR di gambar stiker QRIS (PNG/JPEG/WebP) secara offline
/// (F1-18g). Berat: panggil lewat `Isolate.run` dari UI.
QrisQrRead readQrisFromImage(Uint8List bytes) =>
    QrisQrRead.fromText(decodeQrText(bytes));

/// Teks QR pertama di gambar, atau `null` bila gambar tidak terbaca atau
/// tidak ada QR.
String? decodeQrText(Uint8List bytes) {
  // Berkas kecil bisa menyatakan ukuran raksasa: tolak sebelum didekode.
  final header = readImageHeader(bytes);
  if (header != null && header.width * header.height > photoMaxPixels) {
    return null;
  }
  img.Image? image;
  try {
    image = img.decodeImage(bytes);
  } on Object {
    return null;
  }
  if (image == null) return null;
  image = img.bakeOrientation(image);
  final longest = image.width > image.height ? image.width : image.height;
  if (longest > qrisQrDecodeMaxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: qrisQrDecodeMaxSide)
        : img.copyResize(image, height: qrisQrDecodeMaxSide);
  }
  final source = RGBLuminanceSource(
    image.width,
    image.height,
    _argbOverWhite(image),
  );
  final hints = DecodeHints()..put(DecodeHintType.tryHarder);
  for (final binarizer in [HybridBinarizer.new, GlobalHistogramBinarizer.new]) {
    try {
      return QRCodeReader()
          .decode(BinaryBitmap(binarizer(source)), hints: hints)
          .text;
    } on Object {
      // ReaderException = tidak ada QR; galat lain dari gambar aneh juga
      // berarti tidak terbaca, bukan kerusakan aplikasi.
      continue;
    }
  }
  return null;
}

/// Piksel ARGB untuk dekoder dari format apa pun (1/16-bit, palet,
/// abu-abu), alfa dicampur di atas putih: latar transparan ber-RGB 0
/// tidak boleh terbaca hitam.
Int32List _argbOverWhite(img.Image image) {
  final rgba = image
      .convert(format: img.Format.uint8, numChannels: 4)
      .getBytes(order: img.ChannelOrder.rgba);
  final count = image.width * image.height;
  final pixels = Int32List(count);
  for (var i = 0; i < count; i++) {
    final o = i * 4;
    final a = rgba[o + 3];
    int mix(int c) => (c * a + 255 * (255 - a)) ~/ 255;
    pixels[i] =
        0xFF000000 |
        mix(rgba[o]) << 16 |
        mix(rgba[o + 1]) << 8 |
        mix(rgba[o + 2]);
  }
  return pixels;
}
