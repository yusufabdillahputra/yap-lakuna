/// Format gambar yang didukung untuk unggahan (stiker QRIS, foto produk,
/// denah meja).
enum ImageFormat {
  png('image/png', 'png'),
  jpeg('image/jpeg', 'jpg'),
  webp('image/webp', 'webp'),

  /// Hanya untuk gambar denah ([readFloorImageHeader]); stiker QRIS
  /// ([readImageHeader]) tidak menerima SVG.
  svg('image/svg+xml', 'svg');

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
  var orientation = 1;
  var exifRead = false;
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
      final w = _be16(b, i + 7);
      final h = _be16(b, i + 5);
      // Orientasi 5–8 = diputar 90°/270° saat ditampilkan (foto ponsel).
      return orientation >= 5 && orientation <= 8
          ? _sized(ImageFormat.jpeg, h, w)
          : _sized(ImageFormat.jpeg, w, h);
    }
    // Segmen Exif pertama yang sah menang (sama dengan dekoder Skia).
    if (marker == 0xE1 && !exifRead) {
      final o = _exifOrientation(b, i + 4, length - 2);
      if (o != null) {
        orientation = o;
        exifRead = true;
      }
    }
    if (marker == 0xD9 || marker == 0xDA) return null;
    i += 2 + length;
  }
  return null;
}

/// Tag Orientation (0x0112) dari IFD0 segmen APP1 Exif yang dimulai di
/// [start] sepanjang [length]; `null` bila bukan Exif atau rusak.
int? _exifOrientation(List<int> b, int start, int length) {
  final end = start + length;
  if (length < 14 || end > b.length) return null;
  if (_ascii(b, start, 6) != 'Exif\u0000\u0000') return null;
  final tiff = start + 6;
  final big = switch (_ascii(b, tiff, 2)) {
    'MM' => true,
    'II' => false,
    _ => null,
  };
  if (big == null) return null;
  int u16(int at) => big ? _be16(b, at) : _le16(b, at);
  int u32(int at) => big
      ? _be32(b, at)
      : b[at] | (b[at + 1] << 8) | (b[at + 2] << 16) | (b[at + 3] << 24);
  if (u16(tiff + 2) != 42) return null;
  final ifd = tiff + u32(tiff + 4);
  if (ifd < tiff + 8 || ifd + 2 > end) return null;
  final count = u16(ifd);
  for (var n = 0; n < count; n++) {
    final entry = ifd + 2 + n * 12;
    if (entry + 12 > end) return null;
    if (u16(entry) == 0x0112) {
      // SHORT (3) biasanya; sebagian penulis memakai LONG (4).
      final value = switch (u16(entry + 2)) {
        3 => u16(entry + 8),
        4 => u32(entry + 8),
        _ => 0,
      };
      return value >= 1 && value <= 8 ? value : null;
    }
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
