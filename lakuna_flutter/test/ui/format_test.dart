import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/core/format.dart';

void main() {
  test('formatClock memakai zona cabang', () {
    final t = DateTime.utc(2026, 11, 3, 0, 58);
    expect(formatClock(t, 'Asia/Jakarta'), '07.58');
    expect(formatClock(t, 'Asia/Makassar'), '08.58');
    expect(formatClock(t, 'Asia/Jayapura'), '09.58');
  });

  test('formatDayClock memuat tanggal di zona cabang', () {
    final t = DateTime.utc(2026, 11, 2, 18, 5);
    expect(formatDayClock(t, 'Asia/Jakarta'), '03/11 01.05');
    expect(formatDayClock(t, 'Asia/Makassar'), '03/11 02.05');
    expect(formatDayMonth(t, 'Asia/Jakarta'), '03/11');
  });

  test('RupiahInputFormatter mengelompokkan ribuan', () {
    const f = RupiahInputFormatter();
    TextEditingValue fmt(String s) =>
        f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: s));
    expect(fmt('200000').text, '200.000');
    expect(fmt('1.5000').text, '15.000');
    expect(fmt('007').text, '7');
    expect(fmt('0').text, '0');
    expect(fmt('abc').text, '');
    expect(fmt('9' * 20).text.replaceAll('.', '').length, 15);
  });

  test('SignedRupiahInputFormatter menerima minus di depan', () {
    const f = SignedRupiahInputFormatter();
    String fmt(String s) => f
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: s))
        .text;
    expect(fmt('4000'), '4.000');
    expect(fmt('-3000'), '-3.000');
    expect(fmt('-'), '-');
    expect(fmt('3-000'), '3.000');
    expect(fmt('--5'), '-5');
    expect(fmt('9' * 12).replaceAll('.', '').length, 9);
    expect(parseSignedRupiah('-3.000'), const Money(-3000));
    expect(parseSignedRupiah('4.000'), const Money(4000));
    expect(parseSignedRupiah(''), Money.zero);
    expect(parseSignedRupiah('-'), Money.zero);
  });

  test('QtyInputFormatter menolak input tidak sah', () {
    const f = QtyInputFormatter();
    const old = TextEditingValue(text: '12');
    String fmt(String s) =>
        f.formatEditUpdate(old, TextEditingValue(text: s)).text;
    expect(fmt('12,5'), '12,5');
    expect(fmt('12,125'), '12,125');
    expect(fmt('12,1255'), '12');
    expect(fmt('1,2,3'), '12');
    expect(fmt('12a'), '12');
    expect(fmt('-1'), '12');
    expect(fmt(''), '');
    expect(
      const QtyInputFormatter(
        decimal: '.',
      ).formatEditUpdate(old, const TextEditingValue(text: '0.25')).text,
      '0.25',
    );
  });

  test('setiap ketikan yang lolos QtyInputFormatter bisa dibaca', () {
    // Ketikan setengah jadi tidak boleh diam-diam tersimpan sebagai nol.
    const f = QtyInputFormatter();
    final samples = {
      '12,': Qty.units(12),
      ',5': const Qty(500),
      '0,': Qty.zero,
      '7': Qty.units(7),
      '1250,125': const Qty(1250125),
    };
    for (final MapEntry(key: text, value: qty) in samples.entries) {
      final out = f.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: text),
      );
      expect(out.text, text);
      expect(Qty.tryParse(text, group: ''), qty, reason: text);
    }
  });
}
