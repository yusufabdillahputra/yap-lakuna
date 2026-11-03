import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/ui/dining/split_bill_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_dining_repository.dart';

void main() {
  late FakeDiningRepository dining;
  late OpenBill bill;

  SaleLineRequest line(String name, int qty) => SaleLineRequest(
    variantId: dining.catalog.products
        .firstWhere((p) => p.name == name)
        .variants
        .single
        .id,
    quantity: Qty.units(qty),
  );

  Future<T> ok<T>(Future<Result<T>> f) async => switch (await f) {
    Ok(:final value) => value,
    Error(:final error) => throw error,
  };

  setUp(() async {
    dining = FakeDiningRepository();
    bill = await ok(dining.openTable(dining.tables.first.id, 3));
    bill = await ok(dining.addItem(bill.id, line('Kopi Susu Aren', 2)));
    bill = await ok(dining.addItem(bill.id, line('Nasi Goreng Kampung', 1)));
  });

  Future<SplitBillViewModel> loaded() async {
    final vm = SplitBillViewModel(repository: dining, billId: bill.id);
    await vm.load.execute();
    return vm;
  }

  test('muat, pilih mode dengan jumlah tamu bill, bagi porsi', () async {
    final vm = await loaded();
    expect(vm.mode, isNull);
    expect(vm.guests, 3);
    expect(vm.canPay, isTrue);

    await vm.setMode.execute(SplitMode.item);
    expect(vm.mode, SplitMode.item);
    expect(vm.split!.parts.map((p) => p.label), ['A', 'B', 'C']);
    expect(vm.unassigned, hasLength(2));
    expect(vm.canPayPart(vm.split!.part('A')), isFalse);

    final kopi = vm.unassigned.first;
    await vm.assign.execute((kopi.id, 'A'));
    await vm.assign.execute((vm.unassigned.first.id, 'B'));
    await vm.assign.execute((vm.unassigned.first.id, 'B'));
    expect(vm.unassigned, isEmpty);
    expect(vm.canPayPart(vm.split!.part('A')), isTrue);
    // Tamu C tanpa porsi tidak bisa membayar.
    expect(vm.canPayPart(vm.split!.part('C')), isFalse);

    await vm.setGuests.execute(2);
    expect(vm.guests, 2);
    expect(vm.split!.parts, hasLength(2));
  });

  test('batas jumlah tamu dan batal split', () async {
    final vm = await loaded();
    await vm.setMode.execute(SplitMode.equal);
    expect(vm.canAddGuest, isTrue);
    await vm.setGuests.execute(8);
    expect(vm.canAddGuest, isFalse);
    await vm.setGuests.execute(2);
    expect(vm.canRemoveGuest, isFalse);
    await vm.setMode.execute(null);
    expect(vm.split, isNull);
  });

  test(
    'terkunci setelah bayar; galat tampil; konfirmasi menyelesaikan',
    () async {
      final vm = await loaded();
      await vm.setMode.execute(SplitMode.equal);
      dining.payPart(
        bill.id,
        guest: 'A',
        requests: const [SalePaymentRequest(method: PaymentMethod.qrisStatic)],
        pending: true,
      );
      await vm.load.execute();
      expect(vm.locked, isTrue);
      expect(vm.split!.part('A').status, SplitPartStatus.pending);
      await vm.setGuests.execute(4);
      expect(vm.error, isA<SplitLocked>());
      vm.clearError();
      expect(vm.error, isNull);

      for (final g in ['B', 'C']) {
        dining.payPart(
          bill.id,
          guest: g,
          requests: const [SalePaymentRequest(method: PaymentMethod.card)],
        );
      }
      await vm.load.execute();
      expect(vm.split!.remaining, Money.zero);
      await vm.confirm.execute(vm.split!.part('A').payments.single.id);
      expect(vm.completed, isNotNull);
      expect(vm.completed!.sale.status, SaleStatus.completed);
    },
  );

  test('batalkan bagian menunggu membuka kunci', () async {
    final vm = await loaded();
    await vm.setMode.execute(SplitMode.equal);
    dining.payPart(
      bill.id,
      guest: 'B',
      requests: const [SalePaymentRequest(method: PaymentMethod.qrisStatic)],
      pending: true,
    );
    await vm.load.execute();
    await vm.cancel.execute(vm.split!.part('B').payments.single.id);
    expect(vm.locked, isFalse);
    expect(vm.split!.part('B').status, SplitPartStatus.unpaid);
  });

  test('nominal bebas: nominal ≤ sisa', () async {
    final vm = await loaded();
    await vm.setMode.execute(SplitMode.amount);
    expect(vm.canPayAmount, isFalse);
    vm.setAmount(const Money(20000));
    expect(vm.canPayAmount, isTrue);
    vm.setAmount(vm.split!.remaining + const Money(1));
    expect(vm.canPayAmount, isFalse);
  });

  test('tanpa izin bayar / konfirmasi', () async {
    dining.permissions = {Permission.openBillsManage};
    final vm = await loaded();
    expect(vm.canPay, isFalse);
    expect(vm.canConfirm, isFalse);
  });
}
