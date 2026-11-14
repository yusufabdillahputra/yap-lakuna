import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/repository_errors.dart';
import 'package:lakuna_flutter/ui/cashier/cashier_view_model.dart'
    show saleOptionsFor;
import 'package:lakuna_flutter/ui/dining/dining_view_model.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';

import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/modifier_seed.dart';

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

  Future<void> add(String name, {String? note}) => vm.addItem.execute(
    BillItemInput(saleOptionsFor(product(name)).single, note: note),
  );

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

  test('gabung meja (F1-10d): hanya meja Boleh digabung, item dan tamu '
      'pindah, meja sumber kosong', () async {
    repo.allowMerge(['M1', 'M2', 'M4']);
    await vm.load.execute();
    await vm.openTable.execute((table('M3').id, 2));
    final m3 = vm.selectedBill!;
    expect(vm.canMergeInto(m3), isFalse);
    await vm.openTable.execute((table('M2').id, 3));
    await add('Kopi Susu Aren');
    await vm.openTable.execute((table('M1').id, 2));
    await add('Nasi Goreng Kampung');
    final m1 = vm.selectedBill!;
    expect(vm.canMergeInto(m1), isTrue);
    // M3 tidak boleh digabung, M4 kosong.
    expect(vm.mergeSources(m1).map((b) => b.label), ['M2']);
    // Bill berdiskon nota tidak ditawarkan.
    repo
      ..allowMerge(['M3'])
      ..discountNeedsPin = false;
    await vm.load.execute();
    vm.select(vm.billFor(table('M3'))!);
    await add('Es Teh Manis');
    await vm.setDiscount.execute((
      discount: const ManualDiscount.amount(Money(1000)),
      approverId: null,
    ));
    expect(vm.billFor(table('M3'))!.discount, isNotNull);
    expect(vm.mergeSources(m1).map((b) => b.label), ['M2']);
    vm.select(vm.billFor(table('M1'))!);

    await vm.merge.execute(vm.billFor(table('M2'))!.id);
    expect(vm.actionError, isNull);
    expect(vm.selectedBill?.id, m1.id);
    expect(vm.selectedBill!.items, hasLength(2));
    expect(vm.selectedBill!.sale.guestCount, 5);
    expect(vm.tableState(table('M2')), TableState.empty);
    expect(vm.mergeSources(m1), isEmpty);
  });

  test('gabung meja ditolak → pesan galat, bill tetap', () async {
    repo.allowMerge(['M1', 'M2']);
    await vm.load.execute();
    await vm.openTable.execute((table('M2').id, 2));
    final m2 = vm.selectedBill!;
    await vm.openTable.execute((table('M1').id, 2));
    repo.nextError = const BillMergeBlocked(BillMergeReason.discount);
    await vm.merge.execute(m2.id);
    expect(
      vm.actionError,
      isA<BillMergeBlocked>().having(
        (e) => e.reason,
        'reason',
        BillMergeReason.discount,
      ),
    );
    expect(vm.billFor(table('M2'))?.id, m2.id);
  });

  test('batalkan bill butuh alasan dan izin', () async {
    await vm.openTable.execute((table('M3').id, 2));
    await add('Kopi Susu Aren');
    await vm.voidBill.execute((reason: '  ', approverId: null));
    expect(vm.actionError, isA<BillInputInvalid>());
    await vm.voidBill.execute((reason: 'Tamu batal', approverId: null));
    expect(vm.selectedBill, isNull);
    expect(vm.tableState(table('M3')), TableState.empty);
    expect(repo.voided.values, ['Tamu batal']);

    repo.permissions = {Permission.openBillsManage};
    await vm.load.execute();
    expect(vm.canVoid, isFalse);
    expect(vm.canPay, isFalse);
  });

  group('diskon nota bill (F1-04e)', () {
    test('staf berizin menerapkan dan menghapus diskon persen', () async {
      expect(vm.canOfferDiscount, isTrue);
      expect(vm.discountNeedsApproval, isFalse);
      await vm.openTable.execute((table('M1').id, 2));
      await add('Kopi Susu Aren');
      await add('Nasi Goreng Kampung');
      // 53.000 − 10% = 47.700; service 5% 2.385; PB1 10% 5.009 (dibulatkan).
      await vm.setDiscount.execute((
        discount: const ManualDiscount.percent(BasisPoints(1000)),
        approverId: null,
      ));
      final bill = vm.selectedBill!;
      expect(bill.discount, const ManualDiscount.percent(BasisPoints(1000)));
      expect(bill.charges.discount, const Money(5300));
      expect(bill.charges.service, const Money(2385));
      expect(vm.discountBlocksPay, isFalse);

      await vm.setDiscount.execute((discount: null, approverId: null));
      expect(vm.selectedBill!.discount, isNull);
      expect(vm.selectedBill!.charges.discount, Money.zero);
    });

    test('staf tanpa izin butuh penyetuju; sakelar mati = tidak ada', () async {
      repo.permissions = {Permission.openBillsManage, Permission.salesCreate};
      await vm.load.execute();
      expect(vm.canOfferDiscount, isTrue);
      expect(vm.discountNeedsApproval, isTrue);
      await vm.openTable.execute((table('M2').id, 2));
      await add('Kopi Susu Aren');
      const d = ManualDiscount.amount(Money(4000));
      await vm.setDiscount.execute((discount: d, approverId: null));
      expect(vm.actionError, isA<NotPermitted>());
      final rina = UuidValue.fromString('00000000-0000-4000-8000-0000000000aa');
      await vm.setDiscount.execute((discount: d, approverId: rina));
      expect(vm.actionError, isNull);
      expect(vm.selectedBill!.discountApprovedByName, 'Rina');

      repo.discountNeedsPin = false;
      await vm.load.execute();
      expect(vm.canOfferDiscount, isFalse);
    });

    test('pratinjau menolak diskon yang menghabiskan total', () async {
      await vm.openTable.execute((table('M3').id, 2));
      await add('Kopi Susu Aren');
      expect(
        vm.billDiscountIssue(const ManualDiscount.amount(Money(30000))),
        DiscountIssue.tooLarge,
      );
      expect(
        vm.billDiscountIssue(const ManualDiscount.amount(Money(24000))),
        DiscountIssue.tooLarge,
      );
      expect(
        vm.billDiscountIssue(const ManualDiscount.amount(Money(20000))),
        isNull,
      );
      expect(
        vm.billDiscountIssue(const ManualDiscount.percent(BasisPoints(0))),
        DiscountIssue.invalid,
      );
    });

    test('total habis setelah item berkurang memblokir bayar', () async {
      await vm.openTable.execute((table('M4').id, 2));
      await add('Kopi Susu Aren');
      await add('Nasi Goreng Kampung');
      await vm.setDiscount.execute((
        discount: const ManualDiscount.amount(Money(24000)),
        approverId: null,
      ));
      expect(vm.discountBlocksPay, isFalse);
      final nasi = vm.selectedBill!.items.last;
      await vm.setQuantity.execute((nasi.id, Qty.zero));
      expect(vm.selectedBill!.charges.total, Money.zero);
      expect(vm.discountBlocksPay, isTrue);

      // Diskon tetap bisa dihapus meski bill kosong.
      final kopi = vm.selectedBill!.items.single;
      await vm.setQuantity.execute((kopi.id, Qty.zero));
      await vm.setDiscount.execute((discount: null, approverId: null));
      expect(vm.selectedBill!.discount, isNull);
      expect(vm.discountBlocksPay, isFalse);
    });
  });

  group('diskon baris bill (F1-04g)', () {
    test('terapkan, ubah jumlah, dan hapus diskon baris', () async {
      await vm.openTable.execute((table('M1').id, 2));
      await add('Kopi Susu Aren');
      var kopi = vm.selectedBill!.items.single;
      await vm.setItemDiscount.execute((
        itemId: kopi.id,
        discount: const ManualDiscount.percent(BasisPoints(1000)),
        approverId: null,
      ));
      expect(vm.actionError, isNull);
      kopi = vm.selectedBill!.items.single;
      expect(
        billItemDiscountOf(kopi),
        const ManualDiscount.percent(BasisPoints(1000)),
      );
      expect(kopi.discountAmount, 2400);
      expect(kopi.lineTotal, 21600);
      expect(vm.selectedBill!.charges.subtotal, const Money(21600));

      // Menu sama menjadi baris baru tanpa diskon.
      await add('Kopi Susu Aren');
      expect(vm.selectedBill!.items, hasLength(2));
      expect(vm.selectedBill!.items.last.discountAmount, 0);

      await vm.setItemDiscount.execute((
        itemId: kopi.id,
        discount: null,
        approverId: null,
      ));
      expect(vm.selectedBill!.items.first.discountAmount, 0);
      expect(vm.selectedBill!.items.first.lineTotal, 24000);
    });

    test('staf tanpa izin butuh penyetuju', () async {
      repo.permissions = {Permission.openBillsManage, Permission.salesCreate};
      await vm.load.execute();
      expect(vm.canOfferDiscount, isTrue);
      expect(vm.discountNeedsApproval, isTrue);
      await vm.openTable.execute((table('M2').id, 2));
      await add('Kopi Susu Aren');
      final kopi = vm.selectedBill!.items.single;
      const d = ManualDiscount.amount(Money(4000));
      await vm.setItemDiscount.execute((
        itemId: kopi.id,
        discount: d,
        approverId: null,
      ));
      expect(vm.actionError, isA<NotPermitted>());
      final rina = UuidValue.fromString('00000000-0000-4000-8000-0000000000aa');
      await vm.setItemDiscount.execute((
        itemId: kopi.id,
        discount: d,
        approverId: rina,
      ));
      expect(vm.actionError, isNull);
      expect(repo.itemDiscountApprovers[kopi.id], rina);
      expect(vm.selectedBill!.items.single.discountAmount, 4000);
    });

    test('pratinjau: batas baris dan total bill', () async {
      await vm.openTable.execute((table('M3').id, 2));
      await add('Kopi Susu Aren');
      final kopi = vm.selectedBill!.items.single;
      expect(
        vm.itemDiscountIssue(kopi, const ManualDiscount.amount(Money(30000))),
        DiscountIssue.tooLarge,
      );
      // Satu-satunya item gratis menghabiskan total bill.
      expect(
        vm.itemDiscountIssue(kopi, const ManualDiscount.amount(Money(24000))),
        DiscountIssue.tooLarge,
      );
      expect(
        vm.itemDiscountIssue(kopi, const ManualDiscount.amount(Money(20000))),
        isNull,
      );
      await add('Nasi Goreng Kampung');
      expect(
        vm.itemDiscountIssue(
          vm.selectedBill!.items.first,
          const ManualDiscount.percent(BasisPoints.full),
        ),
        isNull,
      );
      expect(
        vm.itemDiscountIssue(
          kopi,
          const ManualDiscount.percent(BasisPoints(0)),
        ),
        DiscountIssue.invalid,
      );
    });

    test('rupiah dipangkas saat jumlah berkurang: bayar diblokir', () async {
      await vm.openTable.execute((table('M4').id, 2));
      await add('Kopi Susu Aren');
      var kopi = vm.selectedBill!.items.single;
      await vm.setQuantity.execute((kopi.id, Qty.units(2)));
      await vm.setItemDiscount.execute((
        itemId: kopi.id,
        discount: const ManualDiscount.amount(Money(30000)),
        approverId: null,
      ));
      expect(vm.discountBlocksPay, isFalse);
      await vm.setQuantity.execute((kopi.id, Qty.units(1)));
      kopi = vm.selectedBill!.items.single;
      expect(kopi.discountAmount, 24000);
      expect(kopi.lineTotal, 0);
      expect(vm.discountBlocksPay, isTrue);
    });
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

  group('printer dapur (F1-10e)', () {
    const counter = PrinterSelection(
      kind: PrinterKind.network,
      name: 'Kasir',
      address: '10.0.0.2:9100',
    );
    const kitchen = KitchenPrinter(
      printer: PrinterSelection(
        kind: PrinterKind.network,
        name: 'Dapur',
        address: '10.0.0.9:9100',
      ),
      paper: ReceiptPaper.mm80,
    );
    const lines = [ReceiptLine('TIKET DAPUR')];
    late FakeReceiptPrinter printer;

    Future<void> sendOne() async {
      await vm.openTable.execute((table('M1').id, 2));
      await add('Kopi Susu Aren');
      await vm.send.execute();
    }

    setUp(() async {
      printer = FakeReceiptPrinter();
      repo.printer = counter;
    });

    test(
      'tanpa printer dapur: tidak cetak otomatis, tiket ke printer struk',
      () async {
        vm = DiningViewModel(repository: repo, printer: printer);
        await vm.load.execute();
        await sendOne();
        expect(vm.ticketToKitchen, isFalse);
        expect(vm.shouldAutoPrintTicket, isFalse);
        await vm.autoPrintTicket(lines);
        expect(printer.prints, isEmpty);
        expect(vm.ticketPaper, ReceiptPaper.mm58);
        await vm.printTicket.execute(lines);
        expect(printer.prints.single.$1, counter);
      },
    );

    test('printer dapur: cetak otomatis sekali dengan kertas dapur', () async {
      repo.kitchenPrinter = kitchen;
      vm = DiningViewModel(repository: repo, printer: printer);
      await vm.load.execute();
      expect(vm.shouldAutoPrintTicket, isFalse); // belum ada tiket
      await sendOne();
      expect(vm.ticketToKitchen, isTrue);
      expect(vm.ticketPaper, ReceiptPaper.mm80);
      expect(vm.shouldAutoPrintTicket, isTrue);
      await vm.autoPrintTicket(lines);
      await vm.autoPrintTicket(lines);
      expect(printer.prints.single, (
        kitchen.printer,
        lines,
        ReceiptPaper.mm80,
      ));
      expect(vm.ticketPrinted, isTrue);
      expect(vm.shouldAutoPrintTicket, isFalse);

      // Tiket berikutnya dicetak otomatis lagi.
      vm.clearTicket();
      await add('Kopi Susu Aren');
      await vm.send.execute();
      expect(vm.shouldAutoPrintTicket, isTrue);
    });

    test(
      'tiket berikutnya menunggu cetak sebelumnya, status tidak tertukar',
      () async {
        repo.kitchenPrinter = kitchen;
        vm = DiningViewModel(repository: repo, printer: printer);
        await vm.load.execute();
        await sendOne();
        final hold = printer.hold = Completer<void>();
        final first = vm.autoPrintTicket(const [ReceiptLine('A')]);
        await pumpEventQueue();
        expect(vm.printTicket.running, isTrue);
        // Modal A ditutup selagi printer lambat, lalu tiket B dikirim.
        vm.clearTicket();
        await add('Kopi Susu Aren');
        await vm.send.execute();
        final second = vm.autoPrintTicket(const [ReceiptLine('B')]);
        await pumpEventQueue();
        expect(vm.ticketPrinted, isFalse);
        printer.hold = null;
        hold.complete();
        await first;
        await second;
        expect(printer.prints.map((p) => p.$2.single.text), ['A', 'B']);
        expect(vm.ticketPrinted, isTrue);
      },
    );

    test(
      'cetak dapur gagal: alasan tampil, cetak ulang ke printer dapur',
      () async {
        repo.kitchenPrinter = kitchen;
        vm = DiningViewModel(repository: repo, printer: printer);
        await vm.load.execute();
        await sendOne();
        printer.nextFailure = const PrinterFailure(
          PrinterFailureReason.connect,
        );
        await vm.autoPrintTicket(lines);
        expect(vm.printFailure, PrinterFailureReason.connect);
        expect(vm.ticketPrinted, isFalse);
        // Item tetap tercatat di dapur.
        expect(vm.selectedBill!.sentCount, 1);
        await vm.printTicket.execute(lines);
        expect(printer.prints.single.$1, kitchen.printer);
        expect(vm.printFailure, isNull);
        expect(vm.ticketPrinted, isTrue);
      },
    );
  });

  group('pelanggan bill (F1-10f)', () {
    final karyawan = UuidValue.fromString(
      '0192f3a1-7c00-7000-8000-00000000aa01',
    );
    CustomerRow row(String name, {UuidValue? group, String? phone}) =>
        CustomerRow(
          customer: Customer(
            id: UuidValue.fromString(newId()),
            tenantId: UuidValue.fromString(newId()),
            name: name,
            phone: phone,
            customerGroupId: group,
            creditLimit: 0,
            createdAt: DateTime.utc(2026, 11, 1),
            hlc: '',
          ),
          groupName: group == null ? null : 'Karyawan',
          termDays: 14,
          outstanding: Money.zero,
          openCount: 0,
          overdueCount: 0,
        );
    late CustomerRow ani;
    late CustomerRow budi;

    setUp(() async {
      repo = FakeDiningRepository(
        menu: [
          ProductDraft(
            name: 'Kopi Susu Aren',
            category: 'Minuman',
            baseUnit: 'gelas',
            variants: [
              VariantDraft(
                sellPrice: const Money(24000),
                tiers: [
                  PriceTier(
                    minQty: Qty.one,
                    price: const Money(20000),
                    groupId: karyawan.uuid,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      ani = row('Ani', group: karyawan, phone: '0812');
      budi = row('Budi');
      repo.customerRows = [ani, budi];
      vm = DiningViewModel(repository: repo, printer: FakeReceiptPrinter());
      await vm.load.execute();
      await vm.openTable.execute((table('M1').id, 2));
      await add('Kopi Susu Aren');
    });

    test('pilih pelanggan grup: harga grup, nama, hapus kembali', () async {
      await vm.customers.execute();
      expect(vm.customerCandidates.map((r) => r.customer.name), [
        'Ani',
        'Budi',
      ]);
      vm.setCustomerQuery('0812');
      expect(vm.customerCandidates.single, ani);
      expect(vm.canSetCustomer(vm.selectedBill!), isTrue);

      await vm.setCustomer.execute(ani.customer.id);
      expect(vm.selectedBill!.customer?.name, 'Ani');
      expect(vm.selectedBill!.items.single.unitPrice, 20000);
      expect(vm.customerQuery, isEmpty);
      // Item baru memakai harga grup.
      await add('Kopi Susu Aren');
      expect(vm.selectedBill!.items.single.unitPrice, 20000);

      await vm.setCustomer.execute(null);
      expect(vm.selectedBill!.customer, isNull);
      expect(vm.selectedBill!.items.single.unitPrice, 24000);
    });

    test('ditolak saat split: galat tampil', () async {
      final b = vm.selectedBill!;
      repo.sales[repo.sales.indexWhere((s) => s.id == b.id)] = b.sale.copyWith(
        splitMode: SplitMode.equal,
      );
      await vm.load.execute();
      vm.tapTable(table('M1'));
      expect(vm.canSetCustomer(vm.selectedBill!), isFalse);
      await vm.setCustomer.execute(ani.customer.id);
      expect(vm.actionError, isA<BillCustomerBlocked>());
    });

    test('gabung meja tidak menawarkan bill pelanggan lain', () async {
      repo.allowMerge(['M1', 'M2']);
      await vm.load.execute();
      vm.tapTable(table('M1'));
      await vm.setCustomer.execute(ani.customer.id);
      vm.clearSelection();
      await vm.openTable.execute((table('M2').id, 2));
      await add('Kopi Susu Aren');
      await vm.setCustomer.execute(budi.customer.id);
      vm.clearSelection();
      vm.tapTable(table('M1'));
      expect(vm.mergeSources(vm.selectedBill!), isEmpty);
    });
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

  test(
    'modifier: harga + tambahan, gabung set sama, pilihan tidak sah',
    () async {
      final groups = seedModifierGroups();
      repo.attachModifiers('Kopi Susu Aren', groups);
      await vm.load.execute();
      final kopi = product('Kopi Susu Aren');
      expect(vm.modifierGroupsOf(kopi).map((g) => g.name), [
        'Ukuran',
        'Topping',
      ]);
      expect(vm.modifierGroupsOf(product('Es Teh Manis')), isEmpty);

      await vm.openTable.execute((table('M1').id, 2));
      final besar = groups.first.options.last.id;
      final boba = groups.last.options.first.id;
      final keju = groups.last.options.last.id;
      final option = saleOptionsFor(kopi).single;
      await vm.addItem.execute(
        BillItemInput(
          option,
          note: 'less ice',
          quantity: Qty.units(2),
          modifierIds: [besar, boba],
        ),
      );
      var bill = vm.selectedBill!;
      final item = bill.items.single;
      expect(item.lineTotal, 66000);
      expect(item.note, 'less ice');
      expect(bill.modifiersOf(item).map((m) => m.name), ['Besar', 'Boba']);

      await vm.addItem.execute(
        BillItemInput(option, note: 'less ice', modifierIds: [boba, besar]),
      );
      bill = vm.selectedBill!;
      expect(bill.items.single.quantityMilli, 3000);

      await vm.addItem.execute(BillItemInput(option, modifierIds: [boba]));
      expect(vm.actionError, isA<ModifierSelectionInvalid>());
      await vm.addItem.execute(
        BillItemInput(option, modifierIds: [besar, keju]),
      );
      expect(
        (vm.actionError! as ModifierSelectionInvalid).error,
        ModifierSelectionError.unavailable,
      );
      expect(vm.selectedBill!.items, hasLength(1));
    },
  );

  group('menu tanpa tiket dapur (F1-10g)', () {
    setUp(() async {
      repo = FakeDiningRepository(
        menu: const [
          ProductDraft(
            name: 'Nasi Goreng',
            baseUnit: 'porsi',
            kind: ProductKind.service,
            variants: [VariantDraft(sellPrice: Money(31000))],
          ),
          ProductDraft(
            name: 'Air Mineral',
            baseUnit: 'botol',
            kind: ProductKind.service,
            sendToKitchen: false,
            allowNote: false,
            variants: [VariantDraft(sellPrice: Money(5000))],
          ),
        ],
      );
      vm = DiningViewModel(repository: repo, printer: FakeReceiptPrinter());
      await vm.load.execute();
      await vm.openTable.execute((table('M1').id, 2));
    });

    test('hanya non-dapur: tanpa tiket, item disajikan, pesan hilang '
        'setelah aksi lain', () async {
      await add('Air Mineral', note: 'dingin');
      expect(vm.selectedBill!.items.single.note, isNull);
      await vm.send.execute();
      expect(vm.send.completed, isTrue);
      expect(vm.lastTicket, isNull);
      expect(vm.servedWithoutTicket, 1);
      expect(vm.shouldAutoPrintTicket, isFalse);
      expect(vm.selectedBill!.servedCount, 1);
      await add('Nasi Goreng');
      expect(vm.servedWithoutTicket, 0);
    });

    test('campuran: tiket hanya item dapur', () async {
      await add('Nasi Goreng', note: 'pedas');
      await add('Air Mineral');
      await vm.send.execute();
      expect(vm.lastTicket?.items.map((i) => i.productName), ['Nasi Goreng']);
      expect(vm.servedWithoutTicket, 1);
      expect(vm.selectedBill!.sentCount, 1);
      expect(vm.selectedBill!.servedCount, 1);
    });
  });
}
