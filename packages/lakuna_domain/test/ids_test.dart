import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('ID baru adalah UUIDv7 dan urut naik', () {
    final a = newId();
    final b = newId();
    expect(a[14], '7');
    expect(a.compareTo(b), lessThan(0));
  });

  test('stableId: UUIDv5 tetap per tenant + kunci', () {
    final a = stableId('t1', 'cashier');
    expect(a[14], '5');
    expect(stableId('t1', 'cashier'), a);
    expect(stableId('t2', 'cashier'), isNot(a));
    expect(stableId('t1', 'waiter'), isNot(a));
  });
}
