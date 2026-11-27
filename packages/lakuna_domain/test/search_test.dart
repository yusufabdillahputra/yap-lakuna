import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('searchHighlights (F1-11k)', () {
    test('satu kata tanpa beda huruf', () {
      expect(searchHighlights('Kopi Bubuk', 'KOPI'), [(0, 4)]);
      expect(searchHighlights('Es Kopi Susu', 'kopi'), [(3, 7)]);
    });

    test('beberapa kata, urut menurut posisi', () {
      expect(searchHighlights('Teh Botol Melati', 'melati teh'), [
        (0, 3),
        (10, 16),
      ]);
    });

    test('spasi di nama diabaikan, rentang memuat spasinya', () {
      expect(searchHighlights('Beras Premium 5 kg', '5kg'), [(14, 18)]);
      expect(searchHighlights('Kopi Susu', 'kopisusu'), [(0, 9)]);
      expect(searchHighlights('Gula 5kg', '5 kg'), [(5, 8)]);
    });

    test('semua kemunculan; bertumpuk dan bersebelahan digabung', () {
      expect(searchHighlights('Roti Tawar Roti', 'roti'), [(0, 4), (11, 15)]);
      expect(searchHighlights('Kopi Kopi', 'opi kop'), [(0, 4), (5, 9)]);
      expect(searchHighlights('Kopikopi', 'kopi'), [(0, 8)]);
      expect(searchHighlights('Banana', 'ana'), [(1, 6)]);
    });

    test('tidak cocok atau kata kunci kosong', () {
      expect(searchHighlights('Kopi Bubuk', 'teh'), isEmpty);
      expect(searchHighlights('Kopi Bubuk', '   '), isEmpty);
      expect(searchHighlights('', 'kopi'), isEmpty);
    });

    test('huruf non-ASCII dan karakter khusus literal', () {
      expect(searchHighlights('KOPI ÉSPRESSO', 'éspresso'), [(5, 13)]);
      expect(searchHighlights('Diskon 10%', '10%'), [(7, 10)]);
      expect(searchHighlights('Diskon 10', '1_'), isEmpty);
      // Huruf kecil yang lebih panjang (İ → i̇) tidak menggeser indeks.
      expect(searchHighlights('İzmir Kopi', 'kopi'), [(6, 10)]);
      // Karakter di luar BMP (pasangan surrogate) dilipat utuh.
      expect(searchHighlights('Kue \u{10400}', '\u{10428}'), [(4, 6)]);
    });
  });
}
