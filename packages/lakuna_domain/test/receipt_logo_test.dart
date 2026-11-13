import 'dart:typed_data';

import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

/// RGBA [width]×[height] berisi satu warna.
Uint8List _fill(int width, int height, int r, int g, int b, [int a = 255]) {
  final out = Uint8List(width * height * 4);
  for (var i = 0; i < width * height; i++) {
    out
      ..[i * 4] = r
      ..[i * 4 + 1] = g
      ..[i * 4 + 2] = b
      ..[i * 4 + 3] = a;
  }
  return out;
}

int _black(MonoBitmap m) {
  var n = 0;
  for (var y = 0; y < m.height; y++) {
    for (var x = 0; x < m.width; x++) {
      if (m.isBlack(x, y)) n++;
    }
  }
  return n;
}

void main() {
  group('checkReceiptLogo', () {
    // PNG 1×1 minimal (header saja cukup untuk readImageHeader).
    final png = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
      0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, //
      0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, //
    ]);

    test('PNG kecil diterima; bukan gambar ditolak; > 1 MB ditolak', () {
      expect(checkReceiptLogo(png), isNull);
      expect(checkReceiptLogo([1, 2, 3]), ReceiptLogoError.unsupported);
      final big = Uint8List(maxReceiptLogoBytes + 1)..setAll(0, png);
      expect(checkReceiptLogo(big), ReceiptLogoError.tooLarge);
    });
  });

  test('batas titik logo per lebar kertas', () {
    expect(receiptLogoMaxDots(ReceiptPaper.mm58), (width: 256, height: 160));
    expect(receiptLogoMaxDots(ReceiptPaper.mm80), (width: 384, height: 160));
    expect(receiptPrintDots(ReceiptPaper.mm58), 384);
    expect(receiptPrintDots(ReceiptPaper.mm80), 576);
  });

  test('centeredIn: logo ditaruh di tengah bitmap selebar cetak (printer '
      'yang mengabaikan ESC a untuk gambar tetap rata tengah)', () {
    final logo = monoBitmapFromRgba(_fill(4, 2, 0, 0, 0), 4, 2);
    final wide = logo.centeredIn(16);
    expect(wide.width, 16);
    expect(wide.height, 2);
    expect(wide.bits, [0x03, 0xC0, 0x03, 0xC0]);
    for (var y = 0; y < 2; y++) {
      for (var x = 0; x < 16; x++) {
        expect(wide.isBlack(x, y), x >= 6 && x < 10, reason: '$x,$y');
      }
    }
    // Sudah selebar atau lebih lebar → bitmap yang sama.
    expect(identical(logo.centeredIn(4), logo), isTrue);
    expect(identical(logo.centeredIn(2), logo), isTrue);
  });

  group('monoBitmapFromRgba', () {
    test('hitam → bit 1, putih dan transparan → bit 0', () {
      final black = monoBitmapFromRgba(_fill(10, 2, 0, 0, 0), 10, 2);
      expect(black.bytesPerRow, 2);
      // 10 titik: byte kedua hanya 2 bit teratas, sisanya 0 (padding).
      expect(black.bits, [0xFF, 0xC0, 0xFF, 0xC0]);
      final white = monoBitmapFromRgba(_fill(10, 2, 255, 255, 255), 10, 2);
      expect(_black(white), 0);
      final clear = monoBitmapFromRgba(_fill(10, 2, 0, 0, 0, 0), 10, 2);
      expect(_black(clear), 0);
    });

    test(
      'abu-abu 50 % didithering ± separuh hitam; tanpa dithering ambang',
      () {
        final grey = _fill(16, 16, 128, 128, 128);
        final dithered = monoBitmapFromRgba(grey, 16, 16);
        expect(_black(dithered), inInclusiveRange(100, 156));
        final dark = monoBitmapFromRgba(
          _fill(4, 1, 100, 100, 100),
          4,
          1,
          dither: false,
        );
        expect(_black(dark), 4);
        final light = monoBitmapFromRgba(
          _fill(4, 1, 160, 160, 160),
          4,
          1,
          dither: false,
        );
        expect(_black(light), 0);
      },
    );

    test('ukuran RGBA tidak cocok → ArgumentError', () {
      expect(() => monoBitmapFromRgba(Uint8List(3), 1, 1), throwsArgumentError);
    });
  });

  test('encodeEscPos dengan logo: ESC @, rata tengah, GS v 0, lalu teks', () {
    final logo = monoBitmapFromRgba(_fill(8, 2, 0, 0, 0), 8, 2);
    final bytes = encodeEscPos(
      const [ReceiptLine('A')],
      cut: false,
      logo: logo,
    );
    expect(bytes.sublist(0, 16), [
      0x1B, 0x40, // ESC @
      0x1B, 0x61, 1, // ESC a 1
      0x1D, 0x76, 0x30, 0, 1, 0, 2, 0, // GS v 0 m xL xH yL yH
      0xFF, 0xFF, // data 2 baris
      0x1B, // gaya baris pertama
    ]);
    expect(bytes, containsAllInOrder([0x41, 0x0A]));
  });
}
