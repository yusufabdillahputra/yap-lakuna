import 'dart:typed_data';

import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

List<int> _png(int w, int h) => [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // tanda tangan
  0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, // panjang + IHDR
  ..._be32(w), ..._be32(h), 8, 6, 0, 0, 0, //
  0, 0, 0, 0, // CRC (tidak diperiksa)
];

List<int> _jpeg(int w, int h) => [
  0xFF, 0xD8, // SOI
  0xFF, 0xE0, 0, 4, 0x4A, 0x46, // APP0 pendek
  0xFF, 0xC0, 0, 11, 8, ..._be16(h), ..._be16(w), 1, 1, 0x11, 0,
];

/// JPEG dengan segmen APP1 Exif berisi tag Orientation [orientation].
/// [bigEndian] = TIFF "MM", selain itu "II".
List<int> _jpegExif(
  int w,
  int h,
  int orientation, {
  bool bigEndian = true,
  bool long = false,
}) {
  List<int> u16(int v) => bigEndian ? _be16(v) : _le16(v);
  List<int> u32(int v) => bigEndian ? _be32(v) : _be32(v).reversed.toList();
  final tiff = [
    ...(bigEndian ? 'MM' : 'II').codeUnits, ...u16(42), ...u32(8),
    ...u16(2), // dua entri IFD0
    ...u16(0x010F), ...u16(2), ...u32(4), 65, 98, 0, 0, // Make
    ...u16(0x0112), ...u16(long ? 4 : 3), ...u32(1),
    ...(long ? u32(orientation) : [...u16(orientation), 0, 0]),
    ...u32(0), // IFD berikutnya
  ];
  final app1 = [...'Exif'.codeUnits, 0, 0, ...tiff];
  return [
    0xFF, 0xD8, // SOI
    0xFF, 0xE1, ..._be16(app1.length + 2), ...app1,
    0xFF, 0xC0, 0, 11, 8, ..._be16(h), ..._be16(w), 1, 1, 0x11, 0,
  ];
}

List<int> _webpVp8x(int w, int h) => [
  ...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits, //
  ...'VP8X'.codeUnits, 10, 0, 0, 0, 0, 0, 0, 0, //
  ..._le24(w - 1), ..._le24(h - 1),
];

List<int> _webpVp8l(int w, int h) {
  final bits = (w - 1) | ((h - 1) << 14);
  return [
    ...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits, //
    ...'VP8L'.codeUnits, 5, 0, 0, 0, 0x2F, //
    bits & 0xFF, (bits >> 8) & 0xFF, (bits >> 16) & 0xFF, (bits >> 24) & 0xFF,
  ];
}

List<int> _webpVp8(int w, int h) => [
  ...'RIFF'.codeUnits, 0, 0, 0, 0, ...'WEBP'.codeUnits, //
  ...'VP8 '.codeUnits, 10, 0, 0, 0, //
  0, 0, 0, 0x9D, 0x01, 0x2A, ..._le16(w), ..._le16(h),
];

List<int> _be32(int v) => [
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];
List<int> _be16(int v) => [(v >> 8) & 0xFF, v & 0xFF];
List<int> _le16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _le24(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF];

void main() {
  group('readImageHeader', () {
    test('PNG', () {
      final h = readImageHeader(_png(900, 1278))!;
      expect(h.format, ImageFormat.png);
      expect((h.width, h.height), (900, 1278));
      expect(h.mimeType, 'image/png');
      expect(h.extension, 'png');
    });

    test('JPEG melewati segmen APP lalu membaca SOF', () {
      final h = readImageHeader(_jpeg(1080, 1528))!;
      expect(h.format, ImageFormat.jpeg);
      expect((h.width, h.height), (1080, 1528));
      expect(h.extension, 'jpg');
    });

    test('JPEG dengan EXIF orientasi 5–8: lebar dan tinggi ditukar', () {
      // Foto ponsel vertikal disimpan mendatar + tag "putar 90°".
      for (final o in [5, 6, 7, 8]) {
        final h = readImageHeader(_jpegExif(4032, 3024, o))!;
        expect((h.width, h.height), (3024, 4032), reason: 'orientasi $o');
      }
      final le = readImageHeader(_jpegExif(4032, 3024, 6, bigEndian: false))!;
      expect((le.width, le.height), (3024, 4032));
      // Orientation bertipe LONG (jarang, tetapi sah).
      for (final big in [true, false]) {
        final l = readImageHeader(
          _jpegExif(4032, 3024, 8, bigEndian: big, long: true),
        )!;
        expect((l.width, l.height), (3024, 4032));
      }
      for (final o in [1, 2, 3, 4]) {
        final h = readImageHeader(_jpegExif(1080, 1528, o))!;
        expect((h.width, h.height), (1080, 1528), reason: 'orientasi $o');
      }
    });

    test('XMP APP1 sesudah Exif tidak mengubah orientasi', () {
      final b = _jpegExif(4032, 3024, 6);
      final xmp = 'http://ns.adobe.com/xap/1.0/\u0000<x/>'.codeUnits;
      final sof = b.indexOf(0xC0) - 1;
      b.insertAll(sof, [0xFF, 0xE1, ..._be16(xmp.length + 2), ...xmp]);
      final h = readImageHeader(b)!;
      expect((h.width, h.height), (3024, 4032));
    });

    test('EXIF rusak diabaikan, ukuran SOF tetap dipakai', () {
      final b = _jpegExif(1080, 1528, 6);
      // Rusak offset IFD0 (jauh di luar segmen).
      b[4 + 2 + 6 + 4] = 0x7F;
      final h = readImageHeader(b)!;
      expect((h.width, h.height), (1080, 1528));
    });

    test('jumlah entri IFD melewati segmen: tidak membaca ke luar segmen', () {
      final b = _jpegExif(4032, 3024, 6);
      // Jumlah entri IFD0 (setelah offset IFD) dibuat 0x0FFF: entri yang
      // masih di dalam segmen tetap dibaca, sisanya tidak.
      b[4 + 2 + 6 + 8] = 0x0F;
      b[4 + 2 + 6 + 9] = 0xFF;
      final h = readImageHeader(b)!;
      expect((h.width, h.height), (3024, 4032));
      // Tanpa tag Orientation di dalam segmen: ukuran SOF apa adanya.
      final c = _jpegExif(4032, 3024, 6);
      c[4 + 2 + 6 + 8] = 0x0F;
      c[4 + 2 + 6 + 9] = 0xFF;
      c[4 + 2 + 6 + 10 + 12] = 0x01; // tag 0x0112 → 0x0101
      c[4 + 2 + 6 + 10 + 13] = 0x01;
      final g = readImageHeader(c)!;
      expect((g.width, g.height), (4032, 3024));
    });

    test('offset IFD little-endian dengan bit tertinggi: EXIF diabaikan', () {
      final b = _jpegExif(4032, 3024, 6, bigEndian: false);
      b.setRange(4 + 2 + 6 + 4, 4 + 2 + 6 + 8, const [0xF0, 0xFF, 0xFF, 0xFF]);
      final h = readImageHeader(b)!;
      expect((h.width, h.height), (4032, 3024));
    });

    test('WebP VP8X, VP8L, VP8', () {
      expect(
        readImageHeader(_webpVp8x(1200, 1700)),
        isA<ImageHeader>()
            .having((h) => h.format, 'format', ImageFormat.webp)
            .having((h) => (h.width, h.height), 'size', (1200, 1700)),
      );
      final l = readImageHeader(_webpVp8l(640, 905))!;
      expect((l.width, l.height), (640, 905));
      final v = readImageHeader(_webpVp8(320, 480))!;
      expect((v.width, v.height), (320, 480));
      expect(v.mimeType, 'image/webp');
    });

    test('bukan gambar atau terpotong → null', () {
      expect(readImageHeader(const []), isNull);
      expect(readImageHeader('GIF89a......'.codeUnits), isNull);
      expect(readImageHeader(_png(10, 10).sublist(0, 20)), isNull);
      expect(readImageHeader(const [0xFF, 0xD8, 0xFF]), isNull);
    });
  });

  group('checkQrisImage', () {
    test('stiker vertikal ≥ 1000 px: tanpa peringatan', () {
      final c = checkQrisImage(_png(1080, 1528));
      expect(c.error, isNull);
      expect(c.warnings, isEmpty);
      expect(c.header!.width, 1080);
      expect(c.ratioLabel, '1 : 1,41');
    });

    test('kecil dan mendatar: dua peringatan, tetap boleh', () {
      final c = checkQrisImage(_png(900, 600));
      expect(c.error, isNull);
      expect(c.warnings, {
        QrisImageWarning.notPortrait,
        QrisImageWarning.lowResolution,
      });
    });

    test('format tidak didukung', () {
      expect(
        checkQrisImage('GIF89a......'.codeUnits).error,
        QrisImageError.unsupported,
      );
    });

    test('lebih dari 5 MB', () {
      final bytes = Uint8List(maxQrisImageBytes + 1)
        ..setAll(0, _png(1080, 1528));
      expect(checkQrisImage(bytes).error, QrisImageError.tooLarge);
      final ok = Uint8List(maxQrisImageBytes)..setAll(0, _png(1080, 1528));
      expect(checkQrisImage(ok).error, isNull);
    });
  });

  group('validateQrisSettings', () {
    test('isian sah', () {
      expect(
        validateQrisSettings(
          enabled: true,
          hasImage: true,
          merchantName: 'WARUNG CONTOH',
          nmid: 'id10234567890',
          terminalCode: 'A01',
          settlementNote: 'Rekening BCA 123-456-7890',
        ),
        isEmpty,
      );
    });

    test('aktif tanpa gambar dan isian terlalu panjang', () {
      expect(
        validateQrisSettings(
          enabled: true,
          hasImage: false,
          merchantName: 'x' * 61,
          nmid: 'ID-123',
          terminalCode: 'x' * 21,
          settlementNote: 'x' * 81,
        ),
        {
          QrisSettingsError.imageMissing,
          QrisSettingsError.merchantNameTooLong,
          QrisSettingsError.nmidInvalid,
          QrisSettingsError.terminalCodeTooLong,
          QrisSettingsError.settlementNoteTooLong,
        },
      );
    });

    test('nonaktif tanpa gambar boleh; NMID kosong boleh', () {
      expect(
        validateQrisSettings(
          enabled: false,
          hasImage: false,
          merchantName: '',
          nmid: ' ',
          terminalCode: '',
          settlementNote: '',
        ),
        isEmpty,
      );
    });
  });

  test('normalizeNmid: huruf besar tanpa spasi', () {
    expect(normalizeNmid(' id1023 '), 'ID1023');
  });
}
