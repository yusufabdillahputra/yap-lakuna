import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/ui/cashier/cashier_view_model.dart'
    show saleOptionsFor;
import 'package:lakuna_flutter/ui/dining/dining_view_model.dart';

import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_receipt_printer.dart';

void main() {
  late FakeDiningRepository repo;
  late DiningViewModel vm;

  setUp(() async {
    repo = FakeDiningRepository();
    vm = DiningViewModel(repository: repo, printer: FakeReceiptPrinter());
    await vm.load.execute();
  });

  DiningTable table(String name) => vm.tables.firstWhere((t) => t.name == name);

  CatalogProduct product(String name) =>
      vm.menuProducts.firstWhere((p) => p.name == name);

  Future<void> add(String name, {String? note}) => vm.addItem.execute((
    saleOptionsFor(product(name)).single,
    note,
  ));

  test('memuat meja per area dan hitungan terisi', () {
    expect(vm.mode, DiningMode.dineIn);
    expect(vm.areas.map((a) => a.name), ['Indoor', 'Teras']);
    expect(vm.visibleTables.map((t) => t.name), [
      'M1',
      'M2',
      'M3',
      'M4',
      'M5',
      'M6',
    ]);
    vm.setArea(vm.areas.last.id);
    expect(vm.visibleTables.map((t) => t.name), ['M5', 'M6']);
    expect(vm.occupiedCount, 0);
    expect(vm.tableState(table('M5')), TableState.empty);
  });

  test('buka meja, tambah menu, kirim, disajikan, minta bill', () async {
    expect(vm.tapTable(table('M4')), isFalse);
    await vm.openTable.execute((table('M4').id, 4));
    expect(vm.selectedBill?.label, 'M4');
    expect(vm.occupiedCount, 1);
    expect(vm.tableState(table('M4')), TableState.open);

    await add('Kopi Susu Aren');
    await add('Kopi Susu Aren');
    await add('Es Teh Manis', note: 'gula sedikit');
    final bill = vm.selectedBill!;
    expect(bill.items.map((i) => i.quantityMilli), [2000, 1000]);
    expect(bill.charges.subtotal, const Money(53000));
    expect(bill.pendingCount, 2);

    await vm.send.execute();
    expect(vm.lastTicket?.items, hasLength(2));
    expect(vm.selectedBill!.sentCount, 2);
    vm.clearTicket();
    expect(vm.lastTicket, isNull);

    await vm.markServed.execute(vm.selectedBill!.items.first.id);
    expect(vm.selectedBill!.servedCount, 1);

    await vm.requestBill.execute(true);
    expect(vm.tableState(table('M4')), TableState.billRequested);

    // Meja terisi: ketuk memilih bill yang ada.
    vm.clearSelection();
    expect(vm.selectedBill, isNull);
    expect(vm.tapTable(table('M4')), isTrue);
    expect(vm.selectedBill?.label, 'M4');
  });

  test('ubah jumlah item Baru; item terkirim terkunci', () async {
    await vm.openTable.execute((table('M1').id, 2));
    await add('Nasi Goreng Kampung');
    final item = vm.selectedBill!.items.single;
    await vm.setQuantity.execute((item.id, const Qty(3000)));
    expect(vm.selectedBill!.items.single.quantityMilli, 3000);
    await vm.send.execute();
    await vm.setQuantity.execute((item.id, Qty.zero));
    expect(vm.actionError, isA<BillItemLocked>());
    await vm.setQuantity.execute((item.id, Qty.zero));
    expect(vm.selectedBill!.items, hasLength(1));
  });

  test('pindah meja hanya ke meja kosong', () async {
    await vm.openTable.execute((table('M1').id, 2));
    await vm.openTable.execute((table('M2').id, 2));
    // M1 terisi, M2 bill ini sendiri.
    expect(vm.moveTargets.map((t) => t.name), ['M3', 'M4', 'M5', 'M6']);
    await vm.move.execute(table('M5').id);
    expect(vm.selectedBill?.label, 'M5');
    expect(vm.tableState(table('M2')), TableState.empty);
  });

  test('batalkan bill butuh alasan dan izin', () async {
    await vm.openTable.execute((table('M3').id, 2));
    await add('Kopi Susu Aren');
    await vm.voidBill.execute('  ');
    expect(vm.actionError, isA<BillInputInvalid>());
    await vm.voidBill.execute('Tamu batal');
    expect(vm.selectedBill, isNull);
    expect(vm.tableState(table('M3')), TableState.empty);
    expect(repo.voided.values, ['Tamu batal']);

    repo.permissions = {Permission.openBillsManage};
    await vm.load.execute();
    expect(vm.canVoid, isFalse);
    expect(vm.canPay, isFalse);
  });

  test('take away bernomor; kosong dipakai ulang lalu dihapus', () async {
    vm.setMode(DiningMode.takeAway);
    await vm.openTakeAway.execute('Budi');
    expect(vm.selectedBill?.label, 'TA-01');
    await vm.openTakeAway.execute(null);
    expect(vm.takeAways, hasLength(1));
    await add('Es Teh Manis');
    await vm.openTakeAway.execute(null);
    expect(vm.takeAways.map((b) => b.label), ['TA-01', 'TA-02']);
    await vm.deleteEmpty.execute(vm.selectedBill!.id);
    expect(vm.takeAways.map((b) => b.label), ['TA-01']);
    expect(vm.selectedBill, isNull);
  });

  test('menu: cari dan filter kategori', () {
    vm.setMenuQuery('kopi');
    expect(vm.menuProducts.map((p) => p.name), ['Kopi Susu Aren']);
    vm.setMenuQuery('');
    final makanan = vm.menuCategories.firstWhere((c) => c.name == 'Makanan');
    vm.setMenuCategory(makanan.id);
    expect(vm.menuProducts.map((p) => p.name), ['Nasi Goreng Kampung']);
  });

  test('cetak tiket memakai printer perangkat', () async {
    final printer = FakeReceiptPrinter();
    vm = DiningViewModel(repository: repo, printer: printer);
    await vm.load.execute();
    await vm.openTable.execute((table('M1').id, 2));
    await add('Kopi Susu Aren');
    await vm.send.execute();
    await vm.printTicket.execute(const [ReceiptLine('TIKET DAPUR')]);
    expect(printer.prints.single.$2.single.text, 'TIKET DAPUR');
  });

  test('tanpa izin open_bills:manage gagal dimuat', () async {
    repo.permissions = const {};
    final denied = DiningViewModel(
      repository: repo,
      printer: FakeReceiptPrinter(),
    );
    await denied.load.execute();
    expect(denied.loaded, isFalse);
    expect(denied.load.error, isTrue);
    expect(denied.loadError, isA<NotPermitted>());
  });
}
