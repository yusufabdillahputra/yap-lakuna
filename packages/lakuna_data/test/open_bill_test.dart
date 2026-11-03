import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CatalogProduct kopi;
  late CatalogProduct nasi;
  late DiningTable m1;
  late DiningTable m2;

  UuidValue staff() => ctx.owner.id;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: staff(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

  SaleLineRequest line(CatalogProduct p, [int qty = 1]) => SaleLineRequest(
    variantId: p.variants.single.id,
    quantity: Qty(qty * 1000),
  );

  setUp(() async {
    // 2026-11-03 09.00 UTC = 16.00 WIB.
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Susu Aren',
        baseUnit: 'gelas',
        variants: [
          VariantDraft(
            costPrice: Money(9000),
            sellPrice: Money(24000),
            openingStock: Qty(10000),
          ),
        ],
      ),
    );
    nasi = await product(
      const ProductDraft(
        name: 'Nasi Goreng',
        kind: ProductKind.service,
        baseUnit: 'porsi',
        variants: [VariantDraft(sellPrice: Money(31000))],
      ),
    );
    [m1, m2] = await createDiningTables(
      store,
      scope,
      staffId: staff(),
      drafts: const [
        DiningTableDraft(name: 'M1'),
        DiningTableDraft(name: 'M2', seats: 2),
      ],
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<OpenBill> open(DiningTable t, [int guests = 2]) => openTableBill(
    store,
    scope,
    staffId: staff(),
    tableId: t.id,
    guests: guests,
  );

  Future<OpenBill> add(OpenBill bill, SaleLineRequest l, {String? note}) =>
      addBillItem(
        store,
        scope,
        staffId: staff(),
        billId: bill.id,
        line: l,
        note: note,
      );

  Future<KitchenSendResult> send(OpenBill bill) =>
      sendToKitchen(store, scope, staffId: staff(), billId: bill.id);

  group('buka bill', () {
    test('nomor OB, satu bill per meja, tamu 1..99', () async {
      final bill = await open(m1, 4);
      expect(bill.sale.number, 'OB-PST-K01-261103-0001');
      expect(bill.sale.billNumber, bill.sale.number);
      expect(bill.sale.status, SaleStatus.open);
      expect(bill.sale.orderType, OrderType.dineIn);
      expect(bill.sale.guestCount, 4);
      expect(bill.sale.openedBy, staff());
      expect(bill.label, 'M1');
      expect(bill.openedByName, 'Yusuf');

      // Meja yang sama → bill yang sama.
      final again = await open(m1, 3);
      expect(again.id, bill.id);
      expect(again.sale.guestCount, 4);

      final other = await open(m2);
      expect(other.sale.number, 'OB-PST-K01-261103-0002');
      await expectLater(open(m2, 0), throwsA(isA<BillInputInvalid>()));
      await expectLater(open(m2, 100), throwsA(isA<BillInputInvalid>()));

      final overview = await diningOverview(store, scope);
      expect(overview.occupiedTables, 2);
      expect(overview.billForTable(m1.id)?.id, bill.id);
    });
  });

  group('item', () {
    test('gabung hanya bila Baru dan catatan sama; harga beku', () async {
      var bill = await open(m1);
      bill = await add(bill, line(kopi));
      bill = await add(bill, line(kopi));
      bill = await add(bill, line(kopi), note: 'gula dipisah');
      expect(bill.items, hasLength(2));
      expect(bill.items.first.quantityMilli, 2000);
      expect(bill.items.first.lineTotal, 48000);
      expect(bill.items.first.kitchenStatus, KitchenStatus.pending);
      expect(bill.items.last.note, 'gula dipisah');
      expect(bill.sale.itemCount, 2);
      expect(bill.sale.total, 72000);

      await send(bill);
      bill = await add(bill, line(kopi));
      // Sudah dikirim → baris baru.
      expect(bill.items, hasLength(3));
      expect(bill.items.last.kitchenStatus, KitchenStatus.pending);

      // Harga berubah setelah item masuk: item lama tetap.
      await saveProduct(
        store,
        scope,
        staffId: staff(),
        draft: ProductDraft(
          id: kopi.id.uuid,
          name: 'Kopi Susu Aren',
          baseUnit: 'gelas',
          variants: [
            VariantDraft(
              id: kopi.variants.single.id.uuid,
              costPrice: const Money(9000),
              sellPrice: const Money(26000),
            ),
          ],
        ),
      );
      bill = await loadOpenBill(store, scope, bill.id);
      expect(bill.items.first.unitPrice, 24000);
    });

    test('ubah jumlah dan hapus hanya untuk item Baru', () async {
      var bill = await add(await open(m1), line(kopi, 2));
      bill = await add(bill, line(nasi));
      final kopiItem = bill.items.first;
      bill = await setBillItemQuantity(
        store,
        scope,
        staffId: staff(),
        itemId: kopiItem.id,
        quantity: const Qty(3000),
      );
      expect(bill.items.first.quantityMilli, 3000);
      expect(bill.sale.total, 3 * 24000 + 31000);

      bill = await setBillItemQuantity(
        store,
        scope,
        staffId: staff(),
        itemId: kopiItem.id,
        quantity: Qty.zero,
      );
      expect(bill.items.map((i) => i.productName), ['Nasi Goreng']);

      await send(bill);
      await expectLater(
        setBillItemQuantity(
          store,
          scope,
          staffId: staff(),
          itemId: bill.items.single.id,
          quantity: const Qty(2000),
        ),
        throwsA(isA<BillItemLocked>()),
      );
    });

    test('catatan maks 120; produk nonaktif ditolak', () async {
      final bill = await open(m1);
      await expectLater(
        add(bill, line(kopi), note: 'x' * 121),
        throwsA(isA<BillInputInvalid>()),
      );
      await expectLater(
        add(
          bill,
          SaleLineRequest(
            variantId: UuidValue.fromString(newId()),
            quantity: Qty.one,
          ),
        ),
        throwsA(isA<SaleItemUnavailable>()),
      );
    });
  });

  group('dapur', () {
    test('tiket K-nnnn harian, item Baru → Di dapur → Disajikan', () async {
      var bill = await add(await open(m1), line(kopi, 2), note: 'es');
      bill = await add(bill, line(nasi));
      final first = await send(bill);
      expect(first.ticket.number, 1);
      expect(kitchenTicketLabel(first.ticket.number), 'K-0001');
      expect(first.items, hasLength(2));
      expect(first.staffName, 'Yusuf');
      expect(
        first.bill.items.map((i) => i.kitchenStatus),
        everyElement(KitchenStatus.sent),
      );
      expect(first.items.first.kitchenTicketId, first.ticket.id);

      await expectLater(send(first.bill), throwsA(isA<NothingToSend>()));

      bill = await add(first.bill, line(kopi));
      final second = await send(bill);
      expect(second.ticket.number, 2);
      expect(second.items, hasLength(1));

      bill = await markItemServed(
        store,
        scope,
        staffId: staff(),
        itemId: second.items.single.id,
      );
      expect(bill.items.last.kitchenStatus, KitchenStatus.served);
      await expectLater(
        markItemServed(
          store,
          scope,
          staffId: staff(),
          itemId: second.items.single.id,
        ),
        throwsA(isA<BillItemLocked>()),
      );

      // Hari berikutnya (tanggal WIB) mulai dari 1 lagi.
      now = DateTime.utc(2026, 11, 3, 17, 30); // 00.30 WIB 4 Nov
      final next = await send(await add(await open(m2), line(kopi)));
      expect(next.ticket.number, 1);
    });
  });

  group('take away', () {
    test('nomor harian, nama, take away kosong dipakai ulang', () async {
      final ta1 = await openTakeAway(
        store,
        scope,
        staffId: staff(),
        customerName: ' Budi ',
      );
      expect(ta1.sale.orderType, OrderType.takeAway);
      expect(ta1.sale.queueNumber, 1);
      expect(ta1.label, 'TA-01');
      expect(ta1.sale.customerName, 'Budi');
      expect(ta1.takeAwayStatus, TakeAwayState.empty);

      // Masih kosong → dipakai ulang, nama diperbarui.
      final again = await openTakeAway(
        store,
        scope,
        staffId: staff(),
        customerName: 'Rani',
      );
      expect(again.id, ta1.id);
      expect(again.sale.customerName, 'Rani');

      // Dipakai ulang tanpa nama: nama pemesan lama dihapus.
      final anon = await openTakeAway(store, scope, staffId: staff());
      expect(anon.id, ta1.id);
      expect(anon.sale.customerName, isNull);
      // Emoji dihitung per karakter, sama dengan kolom isian.
      final emoji = await openTakeAway(
        store,
        scope,
        staffId: staff(),
        customerName: '😀' * FnbLimits.customerName,
      );
      expect(emoji.sale.customerName, '😀' * FnbLimits.customerName);

      await add(again, line(kopi));
      final ta2 = await openTakeAway(store, scope, staffId: staff());
      expect(ta2.sale.queueNumber, 2);
      expect(ta2.sale.customerName, isNull);

      await expectLater(
        openTakeAway(store, scope, staffId: staff(), customerName: 'x' * 41),
        throwsA(isA<BillInputInvalid>()),
      );

      // Hapus bill kosong; bill berisi ditolak.
      await deleteEmptyBill(store, scope, staffId: staff(), billId: ta2.id);
      await expectLater(
        deleteEmptyBill(store, scope, staffId: staff(), billId: ta1.id),
        throwsA(isA<BillNotEmpty>()),
      );
      final overview = await diningOverview(store, scope);
      expect(overview.takeAways.map((b) => b.label), ['TA-01']);
      expect(overview.takeAways.single.takeAwayStatus, TakeAwayState.pending);

      // Nomor tidak dipakai ulang setelah dihapus.
      final ta3 = await openTakeAway(store, scope, staffId: staff());
      expect(ta3.sale.queueNumber, 3);
    });
  });

  group('aksi bill', () {
    test('minta bill, pindah meja, batal dengan alasan', () async {
      var bill = await add(await open(m1), line(kopi));
      bill = await setBillRequested(
        store,
        scope,
        staffId: staff(),
        billId: bill.id,
        requested: true,
      );
      expect(bill.billRequested, isTrue);
      bill = await setBillRequested(
        store,
        scope,
        staffId: staff(),
        billId: bill.id,
        requested: false,
      );
      expect(bill.billRequested, isFalse);

      bill = await moveBillToTable(
        store,
        scope,
        staffId: staff(),
        billId: bill.id,
        tableId: m2.id,
      );
      expect(bill.label, 'M2');
      await open(m1);
      await expectLater(
        moveBillToTable(
          store,
          scope,
          staffId: staff(),
          billId: bill.id,
          tableId: m1.id,
        ),
        throwsA(isA<TableOccupied>()),
      );

      await expectLater(
        voidOpenBill(
          store,
          scope,
          staffId: staff(),
          billId: bill.id,
          reason: '  ',
        ),
        throwsA(isA<BillInputInvalid>()),
      );
      await voidOpenBill(
        store,
        scope,
        staffId: staff(),
        billId: bill.id,
        reason: 'Tamu batal',
      );
      final voided = await Sale.db.findById(store.session, bill.id);
      expect(voided!.status, SaleStatus.voided);
      expect(voided.voidReason, 'Tamu batal');
      expect(voided.voidedBy, staff());
      await expectLater(
        loadOpenBill(store, scope, bill.id),
        throwsA(isA<BillNotFound>()),
      );
      // Stok tidak bergerak.
      expect(
        await StockMovement.db.count(
          store.session,
          where: (m) => m.sourceType.equals(StockSourceType.sale),
        ),
        0,
      );
    });
  });

  group('tutup & bayar', () {
    setUp(() async {
      await saveFnbRates(
        store,
        scope,
        staffId: staff(),
        rates: const FnbRates(
          service: BasisPoints(500),
          tax: BasisPoints(1000),
        ),
      );
    });

    test('butuh sesi kasir dan item', () async {
      final bill = await open(m1);
      await expectLater(
        payOpenBill(
          store,
          scope,
          staffId: staff(),
          billId: bill.id,
          payments: const [SalePaymentRequest.cash(Money(100000))],
        ),
        throwsA(isA<CashSessionNotOpen>()),
      );
      await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: staff(),
        openingCash: Money.zero,
      );
      await expectLater(
        payOpenBill(
          store,
          scope,
          staffId: staff(),
          billId: bill.id,
          payments: const [SalePaymentRequest.cash(Money(100000))],
        ),
        throwsA(isA<SaleEmpty>()),
      );
    });

    test('nomor nota, service & PB1 dibekukan, stok sekali', () async {
      final session = await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: staff(),
        openingCash: Money.zero,
      );
      var bill = await add(await open(m1), line(kopi, 2));
      bill = await add(bill, line(nasi));
      await send(bill);
      bill = await loadOpenBill(store, scope, bill.id);
      // 48.000 + 31.000 = 79.000; service 3.950; PB1 8.295.
      expect(bill.charges.service, const Money(3950));
      expect(bill.charges.tax, const Money(8295));
      expect(bill.charges.total, const Money(91245));

      await expectLater(
        payOpenBill(
          store,
          scope,
          staffId: staff(),
          billId: bill.id,
          payments: const [SalePaymentRequest.cash(Money(90000))],
        ),
        throwsA(isA<SalePaymentShort>()),
      );

      final result = await payOpenBill(
        store,
        scope,
        staffId: staff(),
        billId: bill.id,
        payments: const [SalePaymentRequest.cash(Money(100000))],
      );
      final sale = result.sale;
      expect(sale.number, 'PST-K01-261103-0001');
      expect(sale.billNumber, 'OB-PST-K01-261103-0001');
      expect(sale.status, SaleStatus.completed);
      expect(sale.cashSessionId, session.id);
      expect(sale.total, 91245);
      expect(sale.serviceAmount, 3950);
      expect(sale.taxAmount, 8295);
      expect(sale.serviceBp, 500);
      expect(sale.taxBp, 1000);
      expect(sale.changeAmount, 100000 - 91245);
      expect(result.items.first.unitCost, 9000);

      // Stok kopi turun 2 (nasi = jasa, tidak dilacak).
      final level = await StockLevel.db.findFirstRow(
        store.session,
        where: (l) => l.variantId.equals(kopi.variants.single.id),
      );
      expect(level!.quantityMilli, 8000);
      expect(
        await StockMovement.db.count(
          store.session,
          where: (m) => m.sourceType.equals(StockSourceType.sale),
        ),
        1,
      );

      // Meja kosong lagi; bill tidak bisa dibayar dua kali.
      final overview = await diningOverview(store, scope);
      expect(overview.billForTable(m1.id), isNull);
      await expectLater(
        payOpenBill(
          store,
          scope,
          staffId: staff(),
          billId: bill.id,
          payments: const [SalePaymentRequest.cash(Money(100000))],
        ),
        throwsA(isA<BillNotFound>()),
      );

      // Rekap sesi kasir ikut menghitung bill.
      final summary = await salesSummaryForSession(
        store,
        scope,
        sessionId: session.id,
      );
      expect(summary.count, 1);
      expect(summary.total, const Money(91245));
      expect(summary.cash, const Money(91245));
    });

    test('take away tanpa service', () async {
      await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: staff(),
        openingCash: Money.zero,
      );
      final ta = await addBillItem(
        store,
        scope,
        staffId: staff(),
        billId: (await openTakeAway(store, scope, staffId: staff())).id,
        line: line(kopi),
      );
      expect(ta.charges.service, Money.zero);
      expect(ta.charges.tax, const Money(2400));
      final result = await payOpenBill(
        store,
        scope,
        staffId: staff(),
        billId: ta.id,
        payments: const [SalePaymentRequest(method: PaymentMethod.card)],
      );
      expect(result.sale.total, 26400);
      expect(result.payments.single.amount, 26400);
    });
  });
}
