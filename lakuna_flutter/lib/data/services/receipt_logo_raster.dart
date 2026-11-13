import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:lakuna_domain/lakuna_domain.dart';

/// Ukuran logo (titik) yang muat di [paper] dengan rasio asli; `null` bila
/// [bytes] bukan gambar yang dikenali.
({int width, int height})? receiptLogoSize(
  Uint8List bytes,
  ReceiptPaper paper,
) {
  final header = readImageHeader(bytes);
  if (header == null || header.width <= 0 || header.height <= 0) return null;
  final max = receiptLogoMaxDots(paper);
  final scale = [
    1.0,
    max.width / header.width,
    max.height / header.height,
  ].reduce((a, b) => a < b ? a : b);
  final width = (header.width * scale).round().clamp(1, max.width);
  final height = (header.height * scale).round().clamp(1, max.height);
  return (width: width, height: height);
}

/// Logo struk [bytes] sebagai bitmap hitam putih untuk ESC/POS (F1-06b).
/// Gambar yang tidak bisa didekode → `null` (struk dicetak tanpa logo).
Future<MonoBitmap?> receiptLogoBitmap(
  Uint8List bytes,
  ReceiptPaper paper,
) async {
  final size = receiptLogoSize(bytes, paper);
  if (size == null) return null;
  try {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: size.width,
      targetHeight: size.height,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final data = await image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    final width = image.width;
    final height = image.height;
    image.dispose();
    codec.dispose();
    if (data == null) return null;
    final rgba = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return monoBitmapFromRgba(rgba, width, height).centeredIn(
      receiptPrintDots(paper),
    );
  } on Object {
    return null;
  }
}
