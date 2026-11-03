import 'dart:typed_data';

import 'receipt.dart';

const _esc = 0x1B;
const _gs = 0x1D;
const _lf = 0x0A;

// Huruf beraksen umum (Latin-1 + Latin Extended-A) → huruf dasar.
const _accented =
    'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģ'
    'ĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĹĺĻļĽľĿŀŁłÑñŃńŅņŇňÒÓÔÕÖØòóôõöøŌōŎŏŐő'
    'ŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž';
const _plain =
    'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdEEEEeeeeEeEeEeEeEeGgGgGgGg'
    'HhHhIIIIiiiiIiIiIiIiIiJjKkLlLlLlLlLlNnNnNnNnOOOOOOooooooOoOoOo'
    'RrRrRrSsSsSsSsTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz';

const _symbols = {
  '×': 'x',
  '·': '-',
  '–': '-',
  '—': '-',
  '‘': "'",
  '’': "'",
  '“': '"',
  '”': '"',
  ' ': ' ', // spasi tak terputus
  'ß': 'ss',
  'Æ': 'AE',
  'æ': 'ae',
};

/// Teks [text] untuk printer thermal: hanya ASCII cetak (0x20–0x7E).
/// Huruf beraksen → huruf dasar, beberapa simbol → padanan ASCII, sisanya
/// `?`.
String receiptAscii(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    if (rune >= 0x20 && rune <= 0x7E) {
      out.writeCharCode(rune);
      continue;
    }
    // Tanda aksen terurai (NFD) ikut huruf sebelumnya, tidak makan kolom.
    if (rune >= 0x0300 && rune <= 0x036F) continue;
    final ch = String.fromCharCode(rune);
    final i = _accented.indexOf(ch);
    if (i >= 0) {
      out.write(_plain[i]);
    } else {
      out.write(_symbols[ch] ?? '?');
    }
  }
  return out.toString();
}

/// Byte ESC/POS untuk [lines]: `ESC @`, per baris `ESC a` (rata) + `ESC E`
/// (tebal) + teks ASCII + `LF`, lalu `ESC d 3` dan, bila [cut], `GS V 66 0`
/// (potong sebagian setelah umpan).
Uint8List encodeEscPos(List<ReceiptLine> lines, {bool cut = true}) {
  final b = BytesBuilder(copy: false)..add([_esc, 0x40]);
  void style(ReceiptAlign align, bool bold) => b
    ..add([_esc, 0x61, align.index])
    ..add([_esc, 0x45, bold ? 1 : 0]);
  for (final line in lines) {
    style(line.align, line.bold);
    b
      ..add(receiptAscii(line.text).codeUnits)
      ..addByte(_lf);
  }
  style(ReceiptAlign.left, false);
  b.add([_esc, 0x64, 3]);
  if (cut) b.add([_gs, 0x56, 66, 0]);
  return b.takeBytes();
}
