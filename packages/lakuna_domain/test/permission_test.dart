import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  test('kunci izin unik, berformat resource:action, dan bisa dibaca balik', () {
    final keys = Permission.values.map((p) => p.key).toSet();
    expect(keys.length, Permission.values.length);
    expect(Permission.values.length, 21);
    for (final p in Permission.values) {
      expect(p.key, contains(':'));
      expect(Permission.fromKey(p.key), p);
    }
    expect(Permission.fromKey('tidak:ada'), isNull);
  });

  test('role bawaan', () {
    expect(DefaultRole.owner.permissions.length, Permission.values.length);
    expect(DefaultRole.manager.permissions, isNot(contains(Permission.usersManage)));
    expect(DefaultRole.manager.permissions, isNot(contains(Permission.backupManage)));
    expect(DefaultRole.cashier.permissions, contains(Permission.paymentsConfirm));
    expect(DefaultRole.cashier.permissions, isNot(contains(Permission.salesVoid)));
    expect(DefaultRole.waiter.permissions, {Permission.openBillsManage});
    expect(DefaultRole.stockKeeper.permissions,
        {Permission.purchasesManage, Permission.stockAdjust, Permission.suppliersManage});
    expect(DefaultRole.values.map((r) => r.key),
        ['owner', 'manager', 'cashier', 'waiter', 'stock_keeper']);
  });
}
