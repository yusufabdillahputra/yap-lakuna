import 'dart:convert';

import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

List<int> _svg(String s) => utf8.encode(s);

void main() {
  group('floorWorldSize', () {
    test('lebar 800, tinggi mengikuti rasio gambar', () {
      expect(floorWorldSize(1600, 1200), (width: 800, height: 600));
      expect(floorWorldSize(1200, 1700), (width: 800, height: 1133));
    });
    test('tinggi dibatasi 200–2000', () {
      expect(floorWorldSize(4000, 200), (width: 800, height: 200));
      expect(floorWorldSize(400, 4000), (width: 800, height: 2000));
    });
    test('tanpa gambar atau ukuran tidak sah: 800 × 560', () {
      expect(floorWorldSize(null, null), (width: 800, height: 560));
      expect(floorWorldSize(0, 100), (width: 800, height: 560));
    });
  });

  group('TablePreset', () {
    test('lima palet dengan kursi dan ukuran kelipatan 20 bila bisa', () {
      expect(TablePreset.all.map((p) => (p.shape, p.seats, p.width, p.height)), [
        (FloorShape.round, 2, 60, 60),
        (FloorShape.square, 4, 80, 80),
        (FloorShape.long, 6, 140, 80),
        (FloorShape.long, 8, 180, 80),
        (FloorShape.bar, 1, 40, 40),
      ]);
    });
  });

  group('nextTableName', () {
    test('M<n> terkecil yang belum dipakai (abaikan huruf besar/kecil)', () {
      expect(nextTableName(const []), 'M1');
      expect(nextTableName(const ['M1', 'm2', 'M4', 'Teras 3']), 'M3');
      expect(nextTableName(const ['M1', 'M2', 'M3']), 'M4');
    });
  });

  group('snapTo', () {
    test('kelipatan terdekat, tidak negatif', () {
      expect(snapTo(109, 20), 100);
      expect(snapTo(110, 20), 120);
      expect(snapTo(-7, 20), 0);
      expect(snapTo(57, 0), 57);
    });
  });

  group('validateFloorTable', () {
    test('ukuran 20–600, posisi 0–5000, kursi 1–99', () {
      expect(
        validateFloorTable(seats: 4, width: 80, height: 80, x: 0, y: 5000),
        isNull,
      );
      expect(
        validateFloorTable(seats: 0, width: 80, height: 80),
        FloorTableError.seats,
      );
      expect(
        validateFloorTable(seats: 4, width: 19, height: 80),
        FloorTableError.size,
      );
      expect(
        validateFloorTable(seats: 4, width: 80, height: 601),
        FloorTableError.size,
      );
      expect(
        validateFloorTable(seats: 4, width: 80, height: 80, x: -1, y: 0),
        FloorTableError.position,
      );
      expect(
        validateFloorTable(seats: 4, width: 80, height: 80, x: 10),
        FloorTableError.position,
        reason: 'x dan y harus sama-sama ada atau sama-sama kosong',
      );
    });
  });

  group('readFloorImageHeader', () {
    test('PNG tetap terbaca', () {
      final png = [
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
        0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, //
        0, 0, 0x04, 0xB0, 0, 0, 0x03, 0x84, 8, 6, 0, 0, 0,
      ];
      final h = readFloorImageHeader(png)!;
      expect((h.format, h.width, h.height), (ImageFormat.png, 1200, 900));
    });
    test('SVG: viewBox dipakai lebih dulu', () {
      final h = readFloorImageHeader(
        _svg(
          '<?xml version="1.0"?>\n<!-- denah -->\n'
          '<svg xmlns="http://www.w3.org/2000/svg" width="100%" '
          'viewBox="0 0 1200.5 840"><rect/></svg>',
        ),
      )!;
      expect((h.format, h.width, h.height), (ImageFormat.svg, 1201, 840));
      expect(h.mimeType, 'image/svg+xml');
      expect(h.extension, 'svg');
    });
    test('SVG: width/height (px) bila tanpa viewBox', () {
      final h = readFloorImageHeader(
        _svg("<svg width='640px' height='480' xmlns='x'></svg>"),
      )!;
      expect((h.width, h.height), (640, 480));
    });
    test('SVG tanpa ukuran: 800 × 560', () {
      final h = readFloorImageHeader(_svg('<svg xmlns="x"><g/></svg>'))!;
      expect((h.format, h.width, h.height), (ImageFormat.svg, 800, 560));
    });
    test('bukan gambar: null; readImageHeader tetap menolak SVG', () {
      expect(readFloorImageHeader(_svg('<html><svg></svg></html>')), isNull);
      expect(readFloorImageHeader(_svg('halo')), isNull);
      expect(readImageHeader(_svg('<svg width="10" height="10"/>')), isNull);
    });
  });
}
