import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/dining/split_bill_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_receipt_printer.dart';

void main() {
  late FakeDiningRepository dining;
  late FakeReceiptPrinter printer;
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
    printer = FakeReceiptPrinter();
    bill = await ok(dining.openTable(dining.tables.first.id, 3));
    bill = await ok(dining.addItem(bill.id, line('Kopi Susu Aren', 2)));
    bill = await ok(dining.addItem(bill.id, line('Nasi Goreng Kampung', 1)));
  });

  Future<SplitBillViewModel> loaded() async {
    final vm = SplitBillViewModel(
      repository: dining,
      printer: printer,
      billId: bill.id,
    );
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
      await vm.confirm.execute((
        paymentId: vm.split!.part('A').payments.single.id,
        approverId: null,
      ));
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

  group('tagihan per tamu (F1-10m)', () {
    const line = [ReceiptLine('TAGIHAN TAMU A')];

    test('canPrintPart: mode, porsi tanpa tamu, pembayaran, nol', () async {
      dining.permissions = {Permission.openBillsManage};
      final vm = await loaded();
      // Tanpa izin bayar tetap boleh mencetak.
      expect(vm.canPay, isFalse);
      dining.permissions = null;
      await vm.load.execute();

      await vm.setMode.execute(SplitMode.item);
      expect(vm.canPrintPart(vm.split!.part('A')), isFalse);
      await vm.assign.execute((vm.unassigned.first.id, 'A'));
      await vm.assign.execute((vm.unassigned.first.id, 'A'));
      await vm.assign.execute((vm.unassigned.first.id, 'B'));
      expect(vm.canPrintPart(vm.split!.part('A')), isTrue);
      // Tamu C tanpa porsi: tagihan nol.
      expect(vm.canPrintPart(vm.split!.part('C')), isFalse);

      await vm.setMode.execute(SplitMode.amount);
      expect(vm.canPrintPart(vm.split!.parts.first), isFalse);

      await vm.setMode.execute(SplitMode.equal);
      expect(vm.canPrintPart(vm.split!.part('C')), isTrue);
      dining.payPart(
        bill.id,
        guest: 'A',
        requests: const [SalePaymentRequest(method: PaymentMethod.card)],
      );
      await vm.load.execute();
      expect(vm.canPrintPart(vm.split!.part('A')), isFalse);
      expect(vm.canPrintPart(vm.split!.part('B')), isTrue);
    });

    test('cetak ke printer struk dengan kertas dan nama job', () async {
      dining
        ..printer = const PrinterSelection(
          kind: PrinterKind.bluetooth,
          name: 'RPP02N',
          address: '00:11',
        )
        ..receipt = const ReceiptConfig(
          settings: ReceiptSettings(paper: ReceiptPaper.mm80),
        );
      final vm = await loaded();
      expect(vm.paper, ReceiptPaper.mm80);
      vm.partPrint.reset();
      await vm.partPrint.printBill.execute(line);
      expect(printer.prints.single.$1.name, 'RPP02N');
      expect(printer.prints.single.$3, ReceiptPaper.mm80);
      expect(vm.partPrint.printed, isTrue);

      vm.openPartPrint('B');
      await vm.partPrint.shareBill.execute(line);
      expect(
        printer.shares.single.$3,
        'tagihan-${bill.sale.billNumber ?? bill.sale.number}-B.pdf',
      );
      expect(vm.partPrint.pdfPath, isNotNull);
    });

    test('galat printer tercatat; hasil dialog lama diabaikan', () async {
      final vm = await loaded();
      printer.nextFailure = const PrinterFailure(
        PrinterFailureReason.connect,
      );
      vm.partPrint.reset();
      await vm.partPrint.printBill.execute(line);
      expect(vm.partPrint.printError, isTrue);
      expect(
        vm.partPrint.printFailure,
        PrinterFailureReason.connect,
      );

      vm.partPrint.reset();
      expect(vm.partPrint.printError, isFalse);
      printer.hold = Completer<void>();
      final slow = vm.partPrint.printBill.execute(line);
      vm.partPrint.reset();
      printer.hold!.complete();
      await slow;
      expect(vm.partPrint.printed, isFalse);
    });
  });
}
