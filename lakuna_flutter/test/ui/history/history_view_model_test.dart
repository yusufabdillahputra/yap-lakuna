import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/history/history_view_model.dart';

import '../../testing/fake_history_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_spreadsheet_exporter.dart';

void main() {
  late FakeHistoryRepository repo;
  late FakeReceiptPrinter printer;
  late FakeSpreadsheetExporter exporter;
  late HistoryViewModel vm;

  setUp(() {
    repo = FakeHistoryRepository();
    printer = FakeReceiptPrinter();
    exporter = FakeSpreadsheetExporter();
  });

  HistoryViewModel create({CheckoutResult? initial}) => vm = HistoryViewModel(
    repository: repo,
    printer: printer,
    exporter: exporter,
    initialSale: initial?.sale.id,
  );

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('muat daftar terbaru dulu, filter memuat ulang', () async {
    final a = repo.addSale([('Kopi', 2000, 10000)]);
    final b = repo.addSale([
      ('Roti', 1000, 15000),
    ], method: PaymentMethod.qrisStatic);
    create();
    await vm.load.execute();
    expect(vm.page!.rows.map((r) => r.sale.id), [b.sale.id, a.sale.id]);
    vm.setFilter(vm.filter.copyWith(method: () => PaymentMethod.qrisStatic));
    await settle();
    expect(vm.page!.rows.single.sale.id, b.sale.id);
    expect(repo.filters.last.method, PaymentMethod.qrisStatic);
  });

  test('pilih nota memuat rincian; nota awal dimuat bersama daftar', () async {
    final a = repo.addSale([('Kopi', 2000, 10000)]);
    create(initial: a);
    await vm.load.execute();
    expect(vm.detail!.sale.id, a.sale.id);
    expect(vm.voidable, isTrue);
    expect(vm.returnable, isTrue);
  });

  test('retur: langkah, batas sisa, nilai, alasan mengatur restok', () async {
    final a = repo.addSale([('Kopi', 3000, 10000), ('Roti', 1500, 10000)]);
    create(initial: a);
    await vm.load.execute();
    final kopi = vm.detail!.items[0];
    final roti = vm.detail!.items[1];
    expect(vm.restock, isFalse); // Barang rusak bawaan.
    vm.setReason(SaleReturnReason.wrongItem);
    expect(vm.restock, isTrue);
    vm.setRestock(false);
    expect(vm.restock, isFalse);

    vm.stepReturn(kopi, 1);
    vm.stepReturn(kopi, 1);
    expect(vm.returnQty(kopi), 2000);
    vm.stepReturn(roti, 1);
    vm.stepReturn(roti, 1); // Sisa 0,5 diambil utuh.
    expect(vm.returnQty(roti), 1500);
    vm.stepReturn(roti, -1);
    expect(vm.returnQty(roti), 1000);
    vm.setReturnQty(kopi, 9000);
    expect(vm.returnQty(kopi), 3000);
    expect(vm.returnTotal, const Money(40000));

    vm.setRefundMethod(RefundMethod.transfer);
    await vm.submitReturn.execute();
    expect(vm.submitReturn.completed, isTrue);
    expect(repo.returns.single.amount, 40000);
    expect(repo.returns.single.restock, isFalse);
    expect(repo.returns.single.refundMethod, RefundMethod.transfer);
    // Form dikosongkan; rincian dan daftar dimuat ulang.
    expect(vm.returnQty(kopi), 0);
    expect(vm.detail!.sale.status, SaleStatus.partiallyReturned);
    expect(vm.page!.rows.single.returned, const Money(40000));
    expect(vm.voidable, isFalse);

    vm.returnAll();
    expect(vm.returnQty(vm.detail!.items[1]), 500);
    expect(vm.returnTotal, const Money(5000));
  });

  test('retur Lainnya tanpa catatan ditolak; tunai bawaan ikut sesi', () async {
    final a = repo.addSale([('Kopi', 1000, 10000)]);
    repo.hasOpenSession = false;
    create(initial: a);
    await vm.load.execute();
    expect(vm.refundMethod, RefundMethod.transfer);
    expect(vm.cashRefundAvailable, isFalse);
    vm.returnAll();
    vm.setReason(SaleReturnReason.other);
    await vm.submitReturn.execute();
    expect(vm.returnError, isA<ReturnInvalid>());
    vm.setNote('Tamu berubah pikiran');
    expect(vm.returnError, isNull);
    await vm.submitReturn.execute();
    expect(vm.detail!.sale.status, SaleStatus.returned);
    expect(vm.returnable, isFalse);
  });

  test('void dengan penyetuju memuat ulang rincian', () async {
    final a = repo.addSale([('Kopi', 1000, 10000)]);
    final approver = repo.staff.first.id;
    create(initial: a);
    await vm.load.execute();
    await vm.voidSale.execute((reason: 'Salah input', approverId: approver));
    expect(repo.voids.single.$3, approver);
    expect(vm.detail!.sale.status, SaleStatus.voided);
    expect(vm.detail!.net, Money.zero);
    expect(vm.voidable, isFalse);
  });

  test('cetak ulang dan PDF memakai nomor nota', () async {
    final a = repo.addSale([('Kopi', 1000, 10000)]);
    create(initial: a);
    await vm.load.execute();
    const lines = [ReceiptLine('X')];
    await vm.printReceipt.execute(lines);
    expect(printer.prints.single.$2, lines);
    await vm.shareReceipt.execute(lines);
    expect(printer.shares.single.$3, '${a.sale.number}.pdf');
    expect(vm.pdfPath, printer.sharePath);
    expect(vm.exportPath, isNull);
    printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
    await vm.printReceipt.execute(lines);
    expect(vm.printFailure, PrinterFailureReason.connect);
  });

  test('ekspor menyimpan berkas dengan nama rentang', () async {
    repo.addSale([('Kopi', 1000, 10000)]);
    create();
    await vm.load.execute();
    vm.setFilter(vm.filter.copyWith(range: HistoryRange.week));
    await settle();
    await vm.export.execute(Uint8List.fromList([1, 2, 3]));
    expect(
      exporter.saved.single.$1,
      matches(RegExp(r'^riwayat-7-hari-\d{6}\.xlsx$')),
    );
    expect(vm.exportPath, exporter.path);
    expect(vm.pdfPath, isNull);
  });

  test('generasi form naik setelah retur dan saat ganti nota', () async {
    final a = repo.addSale([('Kopi', 3000, 10000)]);
    final b = repo.addSale([('Roti', 1000, 10000)]);
    create(initial: a);
    await vm.load.execute();
    final first = vm.formGeneration;
    vm.stepReturn(vm.detail!.items.single, 1);
    vm.setNote('Pecah');
    vm.setRefundMethod(RefundMethod.transfer);
    await vm.submitReturn.execute();
    expect(vm.note, '');
    expect(vm.formGeneration, greaterThan(first));
    final afterReturn = vm.formGeneration;
    vm.select(b.sale.id);
    expect(vm.formGeneration, greaterThan(afterReturn));
  });
}
