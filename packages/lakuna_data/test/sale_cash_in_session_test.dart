import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

UuidValue _id() => UuidValue.fromString(newId());

void main() {
  final tenant = _id();
  final sale = _id();
  final open = _id();
  final closed = _id();

  Payment pay(
    int amount, {
    PaymentMethod method = PaymentMethod.cash,
    int change = 0,
    UuidValue? session,
    PaymentStatus status = PaymentStatus.paid,
  }) => Payment(
    tenantId: tenant,
    saleId: sale,
    method: method,
    amount: amount,
    changeAmount: change,
    status: status,
    paidAt: DateTime.utc(2026, 11, 14, 3),
    hlc: '',
    cashSessionId: session,
  );

  group('saleCashInSession (F1-03d)', () {
    test('tunai dikurangi kembalian, hanya di sesi ini', () {
      expect(
        saleCashInSession([
          pay(100000, change: 15000, session: open),
          pay(20000, session: closed),
          pay(30000, method: PaymentMethod.qrisStatic, session: open),
        ], open),
        const Money(85000),
      );
    });

    test('belum lunas atau terhapus tidak dihitung', () {
      expect(
        saleCashInSession([
          pay(50000, session: open, status: PaymentStatus.pending),
          pay(70000, session: open)..deletedAt = DateTime.utc(2026, 11, 14),
        ], open),
        Money.zero,
      );
    });

    test('pembayaran lama tanpa sesi ikut sesi notanya', () {
      final payments = [pay(40000)];
      expect(
        saleCashInSession(payments, open, saleSessionId: open),
        const Money(40000),
      );
      expect(
        saleCashInSession(payments, open, saleSessionId: closed),
        Money.zero,
      );
      expect(saleCashInSession(payments, open), Money.zero);
    });
  });
}
