/// Format gambar yang didukung untuk unggahan (stiker QRIS, foto produk).
enum ImageFormat {
  png('image/png', 'png'),
  jpeg('image/jpeg', 'jpg'),
  webp('image/webp', 'webp');

  const ImageFormat(this.mimeType, this.extension);

  final String mimeType;
  final String extension;
}

/// Format dan ukuran gambar dari header-nya.
class ImageHeader {
  const ImageHeader(this.format, this.width, this.height);

  final ImageFormat format;
  final int width;
  final int height;

  String get mimeType => format.mimeType;
  String get extension => format.extension;
}

/// Membaca format dan ukuran PNG, JPEG, atau WebP dari [bytes] tanpa
/// mendekode gambar. `null` bila bukan salah satunya atau terpotong.
ImageHeader? readImageHeader(List<int> bytes) {
  try {
    if (_startsWith(bytes, const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A])) {
      return _png(bytes);
    }
    if (_startsWith(bytes, const [0xFF, 0xD8])) return _jpeg(bytes);
    if (_ascii(bytes, 0, 4) == 'RIFF' && _ascii(bytes, 8, 4) == 'WEBP') {
      return _webp(bytes);
    }
  } on RangeError {
    return null;
  }
  return null;
}

ImageHeader? _png(List<int> b) {
  if (_ascii(b, 12, 4) != 'IHDR') return null;
  return _sized(ImageFormat.png, _be32(b, 16), _be32(b, 20));
}

ImageHeader? _jpeg(List<int> b) {
  var i = 2;
  while (i + 3 < b.length) {
    if (b[i] != 0xFF) return null;
    final marker = b[i + 1];
    if (marker == 0xFF) {
      i++; // bantalan
      continue;
    }
    if (marker == 0xD8 ||
        marker == 0x01 ||
        (marker >= 0xD0 && marker <= 0xD7)) {
      i += 2;
      continue;
    }
    final length = _be16(b, i + 2);
    // SOF0–SOF15 kecuali DHT (C4), JPG (C8), DAC (CC).
    if (marker >= 0xC0 &&
        marker <= 0xCF &&
        marker != 0xC4 &&
        marker != 0xC8 &&
        marker != 0xCC) {
      return _sized(ImageFormat.jpeg, _be16(b, i + 7), _be16(b, i + 5));
    }
    if (marker == 0xD9 || marker == 0xDA) return null;
    i += 2 + length;
  }
  return null;
}

ImageHeader? _webp(List<int> b) {
  final chunk = _ascii(b, 12, 4);
  switch (chunk) {
    case 'VP8X':
      return _sized(ImageFormat.webp, _le24(b, 24) + 1, _le24(b, 27) + 1);
    case 'VP8L':
      if (b[20] != 0x2F) return null;
      final bits = b[21] | (b[22] << 8) | (b[23] << 16) | (b[24] << 24);
      return _sized(
        ImageFormat.webp,
        (bits & 0x3FFF) + 1,
        ((bits >> 14) & 0x3FFF) + 1,
      );
    case 'VP8 ':
      if (b[23] != 0x9D || b[24] != 0x01 || b[25] != 0x2A) return null;
      return _sized(
        ImageFormat.webp,
        _le16(b, 26) & 0x3FFF,
        _le16(b, 28) & 0x3FFF,
      );
  }
  return null;
}

ImageHeader? _sized(ImageFormat f, int w, int h) =>
    w > 0 && h > 0 ? ImageHeader(f, w, h) : null;

bool _startsWith(List<int> b, List<int> prefix) {
  if (b.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (b[i] != prefix[i]) return false;
  }
  return true;
}

String _ascii(List<int> b, int start, int length) {
  if (b.length < start + length) return '';
  return String.fromCharCodes(b.sublist(start, start + length));
}

int _be32(List<int> b, int i) =>
    (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3];
int _be16(List<int> b, int i) => (b[i] << 8) | b[i + 1];
int _le16(List<int> b, int i) => b[i] | (b[i + 1] << 8);
int _le24(List<int> b, int i) => b[i] | (b[i + 1] << 8) | (b[i + 2] << 16);
