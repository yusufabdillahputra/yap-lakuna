import 'dart:typed_data';

import 'package:hashlib/hashlib.dart' show crc32;

import 'image_header.dart';

/// Membuang metadata (lokasi GPS, waktu, model ponsel, XMP, IPTC, komentar,
/// gambar tambahan setelah akhir gambar) dari PNG, JPEG, atau WebP tanpa
/// mendekode piksel (F1-07n).
///
/// Orientasi selain 1 dipertahankan lewat Exif minimal yang hanya berisi
/// tag Orientation. Berkas lain (mis. SVG) dan berkas yang strukturnya
/// tidak bisa diurai sampai akhir dikembalikan apa adanya.
Uint8List stripImageMetadata(Uint8List bytes) {
  try {
    final header = readImageHeader(bytes);
    final out = switch (header?.format) {
      ImageFormat.jpeg => _jpeg(bytes),
      ImageFormat.png => _png(bytes),
      ImageFormat.webp => _webp(bytes),
      _ => null,
    };
    return out ?? bytes;
  } on Error {
    // RangeError dari berkas terpotong/aneh: simpan apa adanya.
    return bytes;
  }
}

/// Data TIFF (big-endian) yang hanya berisi tag Orientation [value].
List<int> _minimalTiff(int value) => [
  0x4D, 0x4D, 0x00, 0x2A, 0x00, 0x00, 0x00, 0x08, // header, IFD0 di 8
  0x00, 0x01, // satu entri
  0x01, 0x12, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01, // Orientation, SHORT, 1
  0x00, value, 0x00, 0x00, //
  0x00, 0x00, 0x00, 0x00, // tanpa IFD berikutnya
];

const _exifPrefix = [0x45, 0x78, 0x69, 0x66, 0x00, 0x00]; // "Exif\0\0"

bool _hasPrefix(List<int> b, int at, List<int> prefix, int end) {
  if (at + prefix.length > end) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (b[at + i] != prefix[i]) return false;
  }
  return true;
}

bool _hasAscii(List<int> b, int at, String text, int end) =>
    _hasPrefix(b, at, text.codeUnits, end);

int _be16(List<int> b, int i) => (b[i] << 8) | b[i + 1];
int _be32(List<int> b, int i) =>
    (b[i] << 24) | (b[i + 1] << 16) | (b[i + 2] << 8) | b[i + 3];
int _le32(List<int> b, int i) =>
    b[i] | (b[i + 1] << 8) | (b[i + 2] << 16) | (b[i + 3] << 24);

List<int> _u32be(int v) => [
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];
List<int> _u32le(int v) => [
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 24) & 0xFF,
];

// --- JPEG ---------------------------------------------------------------

Uint8List? _jpeg(Uint8List b) {
  final out = BytesBuilder(copy: false)..add(const [0xFF, 0xD8]);
  var i = 2;
  // Orientasi dibaca seperti [readImageHeader]: Exif sah pertama sebelum
  // SOF. Exif minimal ditaruh di tempat segmen asalnya.
  int? orientation;
  var exifSlot = -1;
  var sawFrame = false;
  final kept = <List<int>>[];
  while (true) {
    if (i + 1 >= b.length || b[i] != 0xFF) return null;
    final marker = b[i + 1];
    if (marker == 0xFF) {
      i++; // bantalan
      continue;
    }
    if (marker == 0xD9) {
      kept.add(const [0xFF, 0xD9]);
      break; // EOI: data sesudahnya (gambar kedua, dll.) dibuang.
    }
    if (marker == 0x01 ||
        marker == 0xD8 ||
        (marker >= 0xD0 && marker <= 0xD7)) {
      kept.add([0xFF, marker]);
      i += 2;
      continue;
    }
    final length = _be16(b, i + 2);
    final end = i + 2 + length;
    if (length < 2 || end > b.length) return null;
    final body = i + 4;
    if (_isFrame(marker)) sawFrame = true;
    if (marker == 0xE1 &&
        !sawFrame &&
        orientation == null &&
        _hasPrefix(b, body, _exifPrefix, end)) {
      final o = tiffOrientation(b, body + 6, end);
      if (o != null) {
        orientation = o;
        exifSlot = kept.length;
      }
    }
    // Daftar izin: semua APPn dan komentar dibuang (Exif, XMP, IPTC, MPF,
    // C2PA/JUMBF, telemetri GPS kamera, dll.) kecuali JFIF, profil warna
    // ICC, dan penanda warna Adobe.
    final keep = switch (marker) {
      0xE0 => true,
      0xE2 => _hasAscii(b, body, 'ICC_PROFILE\u0000', end),
      0xEE => _hasAscii(b, body, 'Adobe', end),
      0xFE => false,
      >= 0xE1 && <= 0xEF => false,
      _ => true,
    };
    if (keep) kept.add(Uint8List.sublistView(b, i, end));
    i = end;
    if (marker == 0xDA) {
      // Data scan: sampai penanda berikutnya selain isian (FF 00),
      // restart (FF D0–D7), dan bantalan (FF FF).
      final start = i;
      while (true) {
        if (i + 1 >= b.length) return null;
        if (b[i] == 0xFF) {
          final next = b[i + 1];
          if (next != 0x00 && next != 0xFF && (next < 0xD0 || next > 0xD7)) {
            break;
          }
          i += next == 0xFF ? 1 : 2;
          continue;
        }
        i++;
      }
      kept.add(Uint8List.sublistView(b, start, i));
    }
  }
  final o = orientation;
  if (o != null && o != 1 && exifSlot >= 0) {
    final payload = [..._exifPrefix, ..._minimalTiff(o)];
    kept.insert(exifSlot, [
      0xFF,
      0xE1,
      ...[((payload.length + 2) >> 8) & 0xFF, (payload.length + 2) & 0xFF],
      ...payload,
    ]);
  }
  for (final part in kept) {
    out.add(part);
  }
  return out.takeBytes();
}

/// SOF0–SOF15 kecuali DHT (C4), JPG (C8), DAC (CC).
bool _isFrame(int m) =>
    m >= 0xC0 && m <= 0xCF && m != 0xC4 && m != 0xC8 && m != 0xCC;

// --- PNG ----------------------------------------------------------------

/// Chunk yang disimpan: chunk kritis, warna, transparansi, ukuran piksel,
/// dan animasi APNG. Selain itu (teks, eXIf, waktu, C2PA, chunk privat)
/// dibuang.
const _pngKeep = {
  'IHDR', 'PLTE', 'IDAT', 'IEND', //
  'iCCP', 'sRGB', 'gAMA', 'cHRM', 'cICP', 'mDCV', 'cLLI', 'sBIT', //
  'tRNS', 'bKGD', 'hIST', 'sPLT', 'pHYs', //
  'acTL', 'fcTL', 'fdAT',
};

Uint8List? _png(Uint8List b) {
  final out = BytesBuilder(copy: false)..add(Uint8List.sublistView(b, 0, 8));
  var i = 8;
  while (true) {
    if (i + 12 > b.length) return null;
    final length = _be32(b, i);
    final end = i + 12 + length;
    if (length < 0 || end > b.length) return null;
    final type = String.fromCharCodes(b, i + 4, i + 8);
    if (type == 'eXIf') {
      final o = tiffOrientation(b, i + 8, i + 8 + length);
      if (o != null && o != 1) out.add(_pngChunk('eXIf', _minimalTiff(o)));
    } else if (_pngKeep.contains(type)) {
      out.add(Uint8List.sublistView(b, i, end));
    }
    i = end;
    if (type == 'IEND') return out.takeBytes();
  }
}

List<int> _pngChunk(String type, List<int> data) {
  final body = [...type.codeUnits, ...data];
  return [
    ..._u32be(data.length),
    ...body,
    ..._u32be(crc32.convert(body).number()),
  ];
}

// --- WebP ---------------------------------------------------------------

/// Chunk WebP yang disimpan; EXIF, XMP, C2PA, dan chunk lain dibuang.
const _webpKeep = {'VP8X', 'ICCP', 'ANIM', 'ANMF', 'ALPH', 'VP8 ', 'VP8L'};

Uint8List? _webp(Uint8List b) {
  final riffEnd = 8 + _le32(b, 4);
  if (riffEnd > b.length || riffEnd < 12) return null;
  final chunks = <List<int>>[];
  var i = 12;
  int? orientation;
  var vp8x = -1;
  var removed = false;
  while (i < riffEnd) {
    if (i + 8 > riffEnd) return null;
    final type = String.fromCharCodes(b, i, i + 4);
    final size = _le32(b, i + 4);
    final end = i + 8 + size + (size.isOdd ? 1 : 0);
    if (size < 0 || i + 8 + size > riffEnd) return null;
    final chunkEnd = end > riffEnd ? riffEnd : end;
    if (type == 'EXIF') {
      // Isi TIFF; sebagian penulis menambah awalan "Exif\0\0".
      var tiff = i + 8;
      if (_hasPrefix(b, tiff, _exifPrefix, i + 8 + size)) tiff += 6;
      orientation ??= tiffOrientation(b, tiff, i + 8 + size);
      removed = true;
    } else if (!_webpKeep.contains(type)) {
      removed = true;
    } else {
      if (type == 'VP8X') vp8x = chunks.length;
      final chunk = Uint8List.sublistView(b, i, chunkEnd);
      // Bantalan yang hilang di akhir berkas ditambahkan agar chunk
      // berikutnya tetap sejajar.
      if (chunk.length.isOdd) {
        chunks.add([...chunk, 0]);
        removed = true;
      } else {
        chunks.add(chunk);
      }
    }
    i = chunkEnd;
  }
  final keepExif = orientation != null && orientation != 1;
  if (vp8x >= 0) {
    final flags = Uint8List.fromList(chunks[vp8x]);
    // Bit 3 = EXIF, bit 2 = XMP.
    flags[8] = (flags[8] & ~0x0C) | (keepExif ? 0x08 : 0);
    if (flags[8] != chunks[vp8x][8]) removed = true;
    chunks[vp8x] = flags;
  }
  if (keepExif && vp8x >= 0) {
    final data = _minimalTiff(orientation);
    chunks.add([
      ...'EXIF'.codeUnits,
      ..._u32le(data.length),
      ...data,
      if (data.length.isOdd) 0,
    ]);
  }
  if (!removed && riffEnd == b.length) return b;
  final body = BytesBuilder(copy: false)..add('WEBP'.codeUnits);
  for (final c in chunks) {
    body.add(c);
  }
  final payload = body.takeBytes();
  return (BytesBuilder(copy: false)
        ..add('RIFF'.codeUnits)
        ..add(_u32le(payload.length))
        ..add(payload))
      .takeBytes();
}
