import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/ui/core/format.dart';

void main() {
  test('formatClock memakai zona cabang', () {
    final t = DateTime.utc(2026, 11, 3, 0, 58);
    expect(formatClock(t, 'Asia/Jakarta'), '07.58');
    expect(formatClock(t, 'Asia/Makassar'), '08.58');
    expect(formatClock(t, 'Asia/Jayapura'), '09.58');
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
}
