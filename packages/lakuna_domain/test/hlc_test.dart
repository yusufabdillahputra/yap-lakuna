import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('urutan teks sama dengan urutan logis', () {
    const a = Hlc(1700000000000, 9, 'dev-a');
    const b = Hlc(1700000000000, 10, 'dev-a');
    const c = Hlc(1700000000001, 0, 'dev-a');
    expect(a < b && b < c, isTrue);
    expect(a.toString().compareTo(b.toString()), lessThan(0));
    expect(b.toString().compareTo(c.toString()), lessThan(0));
    expect(a.toString(), '1700000000000-0009-dev-a');
  });

  test('bolak-balik lewat teks', () {
    const h = Hlc(42, 7, '0192f3a1-7c00-7000-8000-000000000001');
    expect(Hlc.parse(h.toString()), h);
    expect(Hlc.tryParse('rusak'), isNull);
    expect(Hlc.tryParse('1-2-'), isNull);
  });

  test('tick tetap naik walau jam mundur', () {
    const h = Hlc(1000, 0, 'a');
    final t = h.tick(900);
    expect(t > h, isTrue);
    expect(t, const Hlc(1000, 1, 'a'));
    expect(h.tick(2000), const Hlc(2000, 0, 'a'));
  });

  test('receive melewati stempel jarak jauh', () {
    const local = Hlc(1000, 2, 'a');
    const remote = Hlc(2000, 5, 'b');
    final merged = local.receive(remote, 1500);
    expect(merged > remote, isTrue);
    expect(merged, const Hlc(2000, 6, 'a'));
  });
}
