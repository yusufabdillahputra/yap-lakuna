import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('receiptAscii', () {
    test('huruf beraksen → huruf dasar, simbol umum → padanan ASCII', () {
      expect(receiptAscii('Café Ñandú'), 'Cafe Nandu');
      expect(
        receiptAscii('2 × 70.000 · Sari – “ok” ‘ya’'),
        '2 x 70.000 - Sari - "ok" \'ya\'',
      );
    });

    test('karakter lain di luar ASCII cetak → ?', () {
      expect(receiptAscii('Kopi ☕ 日本'), 'Kopi ? ??');
      expect(receiptAscii('a\tb'), 'a?b');
    });
  });

  group('encodeEscPos', () {
    const esc = 0x1B;
    const gs = 0x1D;
    const lf = 0x0A;

    test('golden: init, rata, tebal, teks, umpan, potong', () {
      final bytes = encodeEscPos(const [
        ReceiptLine('TOKO', align: ReceiptAlign.center, bold: true),
        ReceiptLine('A  1'),
        ReceiptLine('9', align: ReceiptAlign.right),
      ]);
      expect(bytes, [
        esc, 0x40, // ESC @
        esc, 0x61, 1, esc, 0x45, 1, 0x54, 0x4F, 0x4B, 0x4F, lf, //
        esc, 0x61, 0, esc, 0x45, 0, 0x41, 0x20, 0x20, 0x31, lf, //
        esc, 0x61, 2, esc, 0x45, 0, 0x39, lf, //
        esc, 0x61, 0, esc, 0x45, 0, // kembali ke bawaan
        esc, 0x64, 3, // ESC d 3
        gs, 0x56, 66, 0, // GS V 66 0
      ]);
    });

    test('tanpa potong: hanya umpan', () {
      final bytes = encodeEscPos(const [ReceiptLine('x')], cut: false);
      expect(bytes.sublist(bytes.length - 3), [esc, 0x64, 3]);
    });

    test('teks non-ASCII diganti sebelum dikirim', () {
      final bytes = encodeEscPos(const [ReceiptLine('é')], cut: false);
      expect(bytes, contains(0x65));
      expect(bytes.every((b) => b < 0x80), isTrue);
    });
  });
}
