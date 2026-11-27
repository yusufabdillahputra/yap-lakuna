import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('canConfirmQrisDirectly (F1-05h)', () {
    final cashier = DefaultRole.cashier.permissions;
    final manager = DefaultRole.manager.permissions;
    final waiter = DefaultRole.waiter.permissions;

    test('sakelar hidup: cukup payments:confirm', () {
      expect(canConfirmQrisDirectly(cashier, cashierWithoutPin: true), isTrue);
      expect(canConfirmQrisDirectly(manager, cashierWithoutPin: true), isTrue);
      expect(canConfirmQrisDirectly(waiter, cashierWithoutPin: true), isFalse);
    });

    test('sakelar mati: butuh settings:manage juga', () {
      expect(
        canConfirmQrisDirectly(cashier, cashierWithoutPin: false),
        isFalse,
      );
      expect(canConfirmQrisDirectly(manager, cashierWithoutPin: false), isTrue);
      expect(
        canConfirmQrisDirectly(
          DefaultRole.owner.permissions,
          cashierWithoutPin: false,
        ),
        isTrue,
      );
    });

    test('settings:manage tanpa payments:confirm tidak cukup', () {
      expect(
        canConfirmQrisDirectly({
          Permission.settingsManage,
        }, cashierWithoutPin: false),
        isFalse,
      );
    });
  });
}
