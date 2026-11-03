import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('ID baru adalah UUIDv7 dan urut naik', () {
    final a = newId();
    final b = newId();
    expect(a[14], '7');
    expect(a.compareTo(b), lessThan(0));
  });
}
