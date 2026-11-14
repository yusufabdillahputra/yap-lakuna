import 'dart:convert';
import 'dart:typed_data';

import 'package:hashlib/hashlib.dart' show crc32;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

// --- Pembuat berkas uji ------------------------------------------------------

List<int> _ascii(String s) => latin1.encode(s);

List<int> _be16(int v) => [(v >> 8) & 0xFF, v & 0xFF];
List<int> _be32(int v) => [
  (v >> 24) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 8) & 0xFF,
  v & 0xFF,
];
List<int> _le32(int v) => [
  v & 0xFF,
  (v >> 8) & 0xFF,
  (v >> 16) & 0xFF,
  (v >> 24) & 0xFF,
];
List<int> _le24(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF];

/// TIFF big-endian: Orientation (bila ada) + tag GPS palsu + teks model.
List<int> _tiff({int? orientation, bool little = false}) {
  final entries = <List<int>>[];
  List<int> u16(int v) => little ? [v & 0xFF, (v >> 8) & 0xFF] : _be16(v);
  List<int> u32(int v) => little ? _le32(v) : _be32(v);
  if (orientation != null) {
    entries.add([
      ...u16(0x0112),
      ...u16(3),
      ...u32(1),
      ...u16(orientation),
      0,
      0,
    ]);
  }
  // GPSInfo (0x8825) menunjuk ke offset palsu; isinya teks "GPS-RUMAH".
  entries.add([...u16(0x8825), ...u16(4), ...u32(1), ...u32(64)]);
  return [
    ...(little ? _ascii('II') : _ascii('MM')),
    ...u16(42),
    ...u32(8),
    ...u16(entries.length),
    for (final e in entries) ...e,
    ...u32(0),
    ..._ascii('GPS-RUMAH -6.2,106.8 Model HP Pemilik'),
  ];
}

List<int> _seg(int marker, List<int> payload) => [
  0xFF,
  marker,
  ..._be16(payload.length + 2),
  ...payload,
];

final _app0 = _seg(0xE0, [..._ascii('JFIF\u0000'), 1, 1, 0, 0, 1, 0, 1, 0, 0]);
final _icc = _seg(0xE2, [..._ascii('ICC_PROFILE\u0000'), 1, 1, 9, 9, 9]);
final _dqt = _seg(0xDB, [0, for (var i = 0; i < 64; i++) 1]);
// SOF0: 8 bit, tinggi 10, lebar 20, 1 komponen.
final _sof = _seg(0xC0, [8, ..._be16(10), ..._be16(20), 1, 1, 0x11, 0]);
final _dht = _seg(0xC4, [0, 1, for (var i = 0; i < 15; i++) 0, 0]);
final _sos = _seg(0xDA, [1, 1, 0, 0, 63, 0]);
// Data scan dengan byte isian (FF 00) dan penanda restart (FF D0).
const _scan = [0x12, 0xFF, 0x00, 0x34, 0xFF, 0xD0, 0x56, 0xE1];
const _eoi = [0xFF, 0xD9];

List<int> _jpeg({int? orientation, bool little = false}) => [
  0xFF, 0xD8, //
  ..._app0,
  ..._seg(0xE1, [
    ..._ascii('Exif\u0000\u0000'),
    ..._tiff(orientation: orientation, little: little),
  ]),
  ..._seg(0xE1, [
    ..._ascii('http://ns.adobe.com/xap/1.0/\u0000'),
    ..._ascii('<x:xmpmeta>exif:GPSLatitude</x:xmpmeta>'),
  ]),
  ..._icc,
  ..._seg(0xE2, [..._ascii('MPF\u0000'), ..._ascii('MM'), 0, 42]),
  ..._seg(0xED, _ascii('Photoshop 3.0\u00008BIM IPTC Kota Rumah')),
  ..._seg(0xFE, _ascii('Difoto di rumah')),
  ..._dqt,
  ..._sof,
  ..._dht,
  ..._sos,
  ..._scan,
  ..._eoi,
  // Gambar kedua (peta kedalaman) dengan Exif GPS setelah EOI.
  0xFF, 0xD8,
  ..._seg(0xE1, [..._ascii('Exif\u0000\u0000'), ..._tiff()]),
  ..._eoi,
];

List<int> _clean({List<int> exif = const []}) => [
  0xFF, 0xD8, //
  ..._app0,
  ...exif,
  ..._icc,
  ..._dqt,
  ..._sof,
  ..._dht,
  ..._sos,
  ..._scan,
  ..._eoi,
];

List<int> _chunk(String type, List<int> data) {
  final body = [..._ascii(type), ...data];
  return [
    ..._be32(data.length),
    ...body,
    ..._be32(crc32.convert(body).number()),
  ];
}

const _pngSig = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
final _ihdr = _chunk('IHDR', [..._be32(20), ..._be32(10), 8, 6, 0, 0, 0]);
final _iccp = _chunk('iCCP', [..._ascii('icc\u0000'), 0, 1, 2, 3]);
final _idat = _chunk('IDAT', [1, 2, 3, 4, 5]);
final _iend = _chunk('IEND', const []);

List<int> _riff(List<List<int>> chunks, {List<int> trailing = const []}) {
  final body = [..._ascii('WEBP'), for (final c in chunks) ...c];
  return [..._ascii('RIFF'), ..._le32(body.length), ...body, ...trailing];
}

List<int> _wchunk(String type, List<int> data) => [
  ..._ascii(type),
  ..._le32(data.length),
  ...data,
  if (data.length.isOdd) 0,
];

List<int> _vp8x(int flags) =>
    _wchunk('VP8X', [flags, 0, 0, 0, ..._le24(19), ..._le24(9)]);
final _wIccp = _wchunk('ICCP', [9, 8, 7]);
final _vp8 = _wchunk('VP8 ', [1, 2, 3, 4, 5, 6]);

Uint8List _b(List<int> bytes) => Uint8List.fromList(bytes);

bool _contains(List<int> haystack, String needle) =>
    latin1.decode(haystack).contains(needle);

void main() {
  group('JPEG', () {
    test('Exif, XMP, IPTC, komentar, MPF, dan data setelah EOI dibuang', () {
      final out = stripImageMetadata(_b(_jpeg()));
      expect(out, _clean());
      for (final s in ['GPS', 'xmpmeta', 'Rumah', 'rumah', 'MPF', 'Model']) {
        expect(_contains(out, s), isFalse, reason: s);
      }
      final header = readImageHeader(out)!;
      expect((header.width, header.height), (20, 10));
    });

    test('orientasi selain 1 dipertahankan dengan Exif minimal', () {
      for (final little in [false, true]) {
        final input = _b(_jpeg(orientation: 6, little: little));
        final before = readImageHeader(input)!;
        expect((before.width, before.height), (10, 20));
        final out = stripImageMetadata(input);
        final after = readImageHeader(out)!;
        expect((after.width, after.height), (10, 20));
        expect(_contains(out, 'GPS'), isFalse);
        expect(
          out,
          _clean(
            exif: _seg(0xE1, [
              ..._ascii('Exif\u0000\u0000'),
              ..._ascii('MM'),
              ..._be16(42),
              ..._be32(8),
              ..._be16(1),
              ..._be16(0x0112),
              ..._be16(3),
              ..._be32(1),
              ..._be16(6),
              0,
              0,
              ..._be32(0),
            ]),
          ),
        );
      }
    });

    test('orientasi 1 tidak menyisakan Exif', () {
      expect(stripImageMetadata(_b(_jpeg(orientation: 1))), _clean());
    });

    test('APPn lain (C2PA/JUMBF, telemetri GPS) dibuang; Adobe tetap', () {
      final adobe = _seg(0xEE, [..._ascii('Adobe'), 0, 100, 0, 0, 0, 0, 1]);
      final input = [
        0xFF, 0xD8, //
        ..._app0,
        ..._seg(0xEB, _ascii('JP\u0000\u0000jumb c2pa stds.exif GPS')),
        ..._seg(0xE6, _ascii('GoPro GPMF GPS5')),
        ..._seg(0xE2, _ascii('FPXR\u0000GPS')),
        ...adobe,
        ..._dqt,
        ..._sof,
        ..._seg(0xE3, _ascii('vendor GPS')),
        ..._dht,
        ..._sos,
        ..._scan,
        ..._eoi,
      ];
      final out = stripImageMetadata(_b(input));
      expect(_contains(out, 'GPS'), isFalse);
      expect(out, [
        0xFF, 0xD8, //
        ..._app0,
        ...adobe,
        ..._dqt,
        ..._sof,
        ..._dht,
        ..._sos,
        ..._scan,
        ..._eoi,
      ]);
    });

    test('Exif setelah SOF tidak dipakai untuk orientasi', () {
      // Exif pertama tanpa Orientation; Exif kedua (setelah SOF, diabaikan
      // dekoder) menyatakan 6.
      final input = [
        0xFF, 0xD8, //
        ..._app0,
        ..._seg(0xE1, [..._ascii('Exif\u0000\u0000'), ..._tiff()]),
        ..._dqt,
        ..._sof,
        ..._seg(0xE1, [
          ..._ascii('Exif\u0000\u0000'),
          ..._tiff(orientation: 6),
        ]),
        ..._dht,
        ..._sos,
        ..._scan,
        ..._eoi,
      ];
      final before = readImageHeader(_b(input))!;
      final out = stripImageMetadata(_b(input));
      final after = readImageHeader(out)!;
      expect((after.width, after.height), (before.width, before.height));
      expect((after.width, after.height), (20, 10));
      expect(_contains(out, 'Exif'), isFalse);
    });

    test('isian FF FF dan restart di data scan tetap', () {
      final scan = [0x11, 0xFF, 0xFF, 0x00, 0x22, 0xFF, 0xD7, 0x33];
      final input = [
        0xFF,
        0xD8,
        ..._app0,
        ..._sof,
        ..._dht,
        ..._sos,
        ...scan,
        ..._eoi,
      ];
      expect(stripImageMetadata(_b(input)), input);
    });

    test('JPEG progresif (beberapa scan) tetap utuh', () {
      final progressive = [
        0xFF, 0xD8, //
        ..._app0,
        ..._seg(0xFE, _ascii('komentar')),
        ..._sof,
        ..._dht,
        ..._sos,
        ..._scan,
        ..._dht,
        ..._sos,
        0x77, 0xFF, 0x00, 0x88, //
        ..._eoi,
      ];
      final out = stripImageMetadata(_b(progressive));
      expect(out, [
        0xFF, 0xD8, //
        ..._app0,
        ..._sof,
        ..._dht,
        ..._sos,
        ..._scan,
        ..._dht,
        ..._sos,
        0x77, 0xFF, 0x00, 0x88, //
        ..._eoi,
      ]);
    });

    test('JPEG bersih tidak berubah', () {
      final clean = _b(_clean());
      expect(stripImageMetadata(clean), clean);
    });

    test('JPEG terpotong dikembalikan apa adanya', () {
      final cut = _b(_jpeg().sublist(0, 40));
      expect(stripImageMetadata(cut), cut);
      final noEoi = _b(_clean().sublist(0, _clean().length - 2));
      expect(stripImageMetadata(noEoi), noEoi);
    });
  });

  group('PNG', () {
    test('teks, eXIf, tIME, dan data setelah IEND dibuang', () {
      final input = [
        ..._pngSig,
        ..._ihdr,
        ..._chunk('tEXt', _ascii('Location\u0000GPS-RUMAH')),
        ..._chunk('eXIf', _tiff()),
        ..._iccp,
        ..._chunk(
          'iTXt',
          _ascii('XML:com.adobe.xmp\u0000\u0000\u0000\u0000\u0000xmpmeta'),
        ),
        ..._chunk('zTXt', [..._ascii('Author\u0000'), 0, 1, 2]),
        ..._idat,
        ..._chunk('tIME', [7, 234, 11, 14, 9, 0, 0]),
        ..._iend,
        ..._ascii('sisa GPS'),
      ];
      final out = stripImageMetadata(_b(input));
      expect(out, [..._pngSig, ..._ihdr, ..._iccp, ..._idat, ..._iend]);
    });

    test('orientasi eXIf dipertahankan dengan CRC sah', () {
      final input = [
        ..._pngSig,
        ..._ihdr,
        ..._chunk('eXIf', _tiff(orientation: 8)),
        ..._idat,
        ..._iend,
      ];
      final out = stripImageMetadata(_b(input));
      expect(_contains(out, 'GPS'), isFalse);
      expect(out, [
        ..._pngSig,
        ..._ihdr,
        ..._chunk('eXIf', [
          ..._ascii('MM'),
          ..._be16(42),
          ..._be32(8),
          ..._be16(1),
          ..._be16(0x0112),
          ..._be16(3),
          ..._be32(1),
          ..._be16(8),
          0,
          0,
          ..._be32(0),
        ]),
        ..._idat,
        ..._iend,
      ]);
    });

    test('chunk privat dan C2PA dibuang, chunk warna/animasi tetap', () {
      final srgb = _chunk('sRGB', [0]);
      final actl = _chunk('acTL', [..._be32(1), ..._be32(0)]);
      final input = [
        ..._pngSig,
        ..._ihdr,
        ...srgb,
        ...actl,
        ..._chunk('caBX', _ascii('c2pa GPS')),
        ..._chunk('prVt', _ascii('GPS')),
        ..._idat,
        ..._iend,
      ];
      expect(stripImageMetadata(_b(input)), [
        ..._pngSig,
        ..._ihdr,
        ...srgb,
        ...actl,
        ..._idat,
        ..._iend,
      ]);
    });

    test('PNG tanpa IEND dikembalikan apa adanya', () {
      final cut = _b([
        ..._pngSig,
        ..._ihdr,
        ..._chunk('tEXt', _ascii('a\u0000b')),
      ]);
      expect(stripImageMetadata(cut), cut);
    });
  });

  group('WebP', () {
    test('EXIF dan XMP dibuang, bit VP8X dan ukuran RIFF benar', () {
      final input = _riff([
        _vp8x(0x20 | 0x08 | 0x04),
        _wIccp,
        _vp8,
        _wchunk('EXIF', [..._ascii('Exif\u0000\u0000'), ..._tiff()]),
        _wchunk('XMP ', _ascii('<x:xmpmeta>GPS</x:xmpmeta>!')),
      ], trailing: _ascii('GPS sisa'));
      final out = stripImageMetadata(_b(input));
      expect(out, _riff([_vp8x(0x20), _wIccp, _vp8]));
      final header = readImageHeader(out)!;
      expect((header.width, header.height), (20, 10));
    });

    test('orientasi EXIF dipertahankan', () {
      final input = _riff([
        _vp8x(0x08),
        _vp8,
        _wchunk('EXIF', _tiff(orientation: 3, little: true)),
      ]);
      final out = stripImageMetadata(_b(input));
      expect(_contains(out, 'GPS'), isFalse);
      expect(
        out,
        _riff([
          _vp8x(0x08),
          _vp8,
          _wchunk('EXIF', [
            ..._ascii('MM'),
            ..._be16(42),
            ..._be32(8),
            ..._be16(1),
            ..._be16(0x0112),
            ..._be16(3),
            ..._be32(1),
            ..._be16(3),
            0,
            0,
            ..._be32(0),
          ]),
        ]),
      );
    });

    test('chunk C2PA dan tak dikenal dibuang; animasi tetap', () {
      final anim = _wchunk('ANIM', [0, 0, 0, 0, 0, 0]);
      final input = _riff([
        _vp8x(0x02),
        anim,
        _wchunk('C2PA', _ascii('GPS')),
        _wchunk('ZZZZ', _ascii('GPS!')),
        _vp8,
      ]);
      expect(stripImageMetadata(_b(input)), _riff([_vp8x(0x02), anim, _vp8]));
    });

    test('chunk ganjil tanpa bantalan di akhir diberi bantalan', () {
      final odd = [..._ascii('VP8L'), ..._le32(5), 0x2F, 1, 2, 3, 4];
      final input = _riff([
        _vp8x(0x08),
        _wchunk('EXIF', _tiff(orientation: 6)),
        odd,
      ]);
      final out = stripImageMetadata(_b(input));
      expect(out.length.isEven, isTrue);
      expect(_contains(out, 'GPS'), isFalse);
      // Exif minimal ditambahkan setelah chunk ganjil yang sudah dibantali.
      final exifAt = latin1.decode(out).indexOf('EXIF');
      expect(exifAt.isEven, isTrue);
      expect(exifAt, 12 + 18 + odd.length + 1);
    });

    test('WebP sederhana tanpa VP8X tidak berubah', () {
      final simple = _b(_riff([_vp8]));
      expect(stripImageMetadata(simple), simple);
    });
  });

  test('berkas acak atau terpotong tidak pernah melempar galat', () {
    final samples = [
      _jpeg(orientation: 6),
      [..._pngSig, ..._ihdr, ..._chunk('tEXt', _ascii('a\u0000b')), ..._iend],
      _riff([_vp8x(0x08), _vp8, _wchunk('EXIF', _tiff(orientation: 3))]),
    ];
    for (final sample in samples) {
      for (var cut = 1; cut < sample.length; cut++) {
        final input = _b(sample.sublist(0, cut));
        expect(() => stripImageMetadata(input), returnsNormally);
      }
      for (var at = 2; at < sample.length; at += 3) {
        final input = _b(sample)..[at] ^= 0xA5;
        expect(() => stripImageMetadata(input), returnsNormally);
      }
    }
  });

  test('bukan gambar dikembalikan apa adanya', () {
    final svg = _b(_ascii('<svg xmlns="http://www.w3.org/2000/svg"/>'));
    expect(stripImageMetadata(svg), svg);
  });
}
