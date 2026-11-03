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
    [m1] = await createDiningTables(
      store,
      scope,
      staffId: staff(),
      drafts: const [DiningTableDraft(name: 'M1')],
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<OpenBill> bill({int kopiQty = 2, int nasiQty = 1}) async {
    var b = await openTableBill(
      store,
      scope,
      staffId: staff(),
      tableId: m1.id,
      guests: 3,
    );
    for (final (p, q) in [(kopi, kopiQty), (nasi, nasiQty)]) {
      if (q == 0) continue;
      b = await addBillItem(
        store,
        scope,
        staffId: staff(),
        billId: b.id,
        line: line(p, q),
      );
    }
    return b;
  }

  Future<OpenBill> split(OpenBill b, SplitMode? mode, [int guests = 3]) =>
      setBillSplit(
        store,
        scope,
        staffId: staff(),
        billId: b.id,
        mode: mode,
        guests: guests,
      );

  Future<OpenBill> assign(SaleItem item, String? guest) => assignPortion(
    store,
    scope,
    staffId: staff(),
    itemId: item.id,
    guest: guest,
  );

  Future<SplitPayResult> pay(
    OpenBill b, {
    String? guest,
    Money? amount,
    List<SalePaymentRequest> payments = const [
      SalePaymentRequest(method: PaymentMethod.card),
    ],
    bool pending = false,
  }) => paySplitPart(
    store,
    scope,
    staffId: staff(),
    billId: b.id,
    guest: guest,
    amount: amount,
    payments: payments,
    pending: pending,
  );

  Future<CashSession> openSession() => openCashSession(
    store,
    CashScope.of(ctx),
    staffId: staff(),
    openingCash: Money.zero,
  );

  SaleItem row(OpenBill b, CatalogProduct p, String? guest) => b.items
      .where((i) => i.productName == p.name && i.guestLabel == guest)
      .single;

  Matcher splitError(SplitError e) =>
      throwsA(isA<SplitInvalid>().having((x) => x.error, 'error', e));

  group('atur split', () {
    test('mode, tamu, pecah dan gabung porsi', () async {
      var b = await bill(kopiQty: 3);
      final subtotal = b.charges.subtotal;
      b = await split(b, SplitMode.item);
      expect(b.sale.splitMode, SplitMode.item);
      expect(b.sale.splitGuests, 3);
      expect(b.split!.parts.map((p) => p.label), ['A', 'B', 'C']);
      expect(b.split!.unassigned, hasLength(2));

      // Satu porsi kopi ke A, lalu satu lagi: baris A bertambah.
      b = await assign(row(b, kopi, null), 'A');
      expect(row(b, kopi, null).quantityMilli, 2000);
      expect(row(b, kopi, 'A').quantityMilli, 1000);
      expect(row(b, kopi, 'A').lineTotal, 24000);
      b = await assign(row(b, kopi, null), 'A');
      expect(row(b, kopi, 'A').quantityMilli, 2000);
      expect(row(b, kopi, 'A').lineTotal, 48000);
      // Porsi terakhir berpindah utuh; baris asal habis.
      b = await assign(row(b, kopi, null), 'C');
      expect(b.items.where((i) => i.productName == kopi.name), hasLength(2));
      expect(row(b, kopi, 'C').quantityMilli, 1000);
      expect(b.charges.subtotal, subtotal);
      expect(b.split!.part('A').items.single.quantityMilli, 2000);

      // Kembalikan porsi C ke belum dibagi.
      b = await assign(row(b, kopi, 'C'), null);
      expect(row(b, kopi, null).quantityMilli, 1000);

      // Kurangi tamu: porsi tamu yang hilang kembali.
      b = await assign(row(b, nasi, null), 'C');
      b = await split(b, SplitMode.item, 2);
      expect(row(b, nasi, null).quantityMilli, 1000);
      expect(b.split!.parts.map((p) => p.label), ['A', 'B']);
      expect(b.charges.subtotal, subtotal);

      // Batal split: semua porsi digabung kembali.
      b = await split(b, null);
      expect(b.sale.splitMode, isNull);
      expect(b.split, isNull);
      expect(row(b, kopi, null).quantityMilli, 3000);
      expect(b.items, hasLength(2));
    });

    test('modifier ikut disalin saat porsi dipecah', () async {
      await saveModifierGroup(
        store,
        scope,
        staffId: staff(),
        draft: const ModifierGroupDraft(
          name: 'Ukuran',
          minSelect: 1,
          maxSelect: 1,
          options: [
            ModifierOptionDraft(name: 'Besar', priceDelta: Money(4000)),
          ],
        ),
      );
      final [size] = await modifierGroupRows(store, scope);
      final kopiMod = await product(
        ProductDraft(
          id: kopi.id.uuid,
          name: kopi.name,
          baseUnit: 'gelas',
          variants: [
            VariantDraft(
              id: kopi.variants.single.id.uuid,
              costPrice: const Money(9000),
              sellPrice: const Money(24000),
            ),
          ],
          modifierGroupIds: [size.id.uuid],
        ),
      );
      var b = await openTableBill(
        store,
        scope,
        staffId: staff(),
        tableId: m1.id,
        guests: 2,
      );
      b = await addBillItem(
        store,
        scope,
        staffId: staff(),
        billId: b.id,
        line: line(kopiMod, 2),
        modifierIds: [size.options.single.id],
      );
      b = await split(b, SplitMode.item, 2);
      b = await assign(b.items.single, 'B');
      final moved = row(b, kopi, 'B');
      expect(moved.lineTotal, 28000);
      expect(moved.modifierDelta, 4000);
      expect(b.modifiersOf(moved).single.name, 'Besar');
      expect(b.modifiersOf(row(b, kopi, null)).single.name, 'Besar');
    });

    test('isian tidak sah', () async {
      final b = await bill();
      await expectLater(
        split(b, SplitMode.item, 1),
        splitError(SplitError.guests),
      );
      await expectLater(
        split(b, SplitMode.item, 9),
        splitError(SplitError.guests),
      );
      await expectLater(
        assign(b.items.first, 'A'),
        splitError(SplitError.mode),
      );
      final e = await split(b, SplitMode.equal);
      await expectLater(
        assign(e.items.first, 'A'),
        splitError(SplitError.mode),
      );
      final i = await split(e, SplitMode.item, 2);
      await expectLater(
        assign(i.items.first, 'C'),
        splitError(SplitError.guest),
      );
    });

    test('item baru tidak digabung ke porsi tamu', () async {
      var b = await bill(kopiQty: 1, nasiQty: 0);
      b = await split(b, SplitMode.item, 2);
      b = await assign(b.items.single, 'A');
      b = await addBillItem(
        store,
        scope,
        staffId: staff(),
        billId: b.id,
        line: line(kopi),
      );
      expect(row(b, kopi, 'A').quantityMilli, 1000);
      expect(row(b, kopi, null).quantityMilli, 1000);
    });
  });

  group('bayar bagian', () {
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

    test(
      'per item: tagihan proporsional, kunci, lunas di bagian terakhir',
      () async {
        var b = await bill();
        // 2 × 24.000 + 31.000 = 79.000; service 3.950; PB1 8.295.
        expect(b.charges.total, const Money(91245));
        b = await split(b, SplitMode.item, 2);
        await expectLater(
          pay(b, guest: 'A'),
          throwsA(isA<CashSessionNotOpen>()),
        );
        await openSession();
        await expectLater(
          pay(b, guest: 'A'),
          splitError(SplitError.unassigned),
        );
        b = await assign(row(b, kopi, null), 'A');
        b = await assign(row(b, kopi, null), 'B');
        b = await assign(row(b, nasi, null), 'B');
        expect(b.split!.part('A').due, const Money(27720));
        expect(b.split!.part('B').due, const Money(63525));

        final a = await pay(
          b,
          guest: 'A',
          payments: const [SalePaymentRequest.cash(Money(30000))],
        );
        expect(a.receipt, isNull);
        b = a.bill!;
        final paidA = b.payments.single;
        expect(paidA.guestLabel, 'A');
        expect(paidA.amount, 30000);
        expect(paidA.changeAmount, 2280);
        expect(b.split!.part('A').status, SplitPartStatus.paid);
        expect(b.split!.remaining, const Money(63525));
        expect(b.split!.locked, isTrue);

        // Terkunci selama ada pembayaran bagian.
        await expectLater(
          addBillItem(
            store,
            scope,
            staffId: staff(),
            billId: b.id,
            line: line(nasi),
          ),
          throwsA(isA<SplitLocked>()),
        );
        await expectLater(
          setBillItemQuantity(
            store,
            scope,
            staffId: staff(),
            itemId: b.items.first.id,
            quantity: Qty.zero,
          ),
          throwsA(isA<SplitLocked>()),
        );
        await expectLater(
          split(b, SplitMode.equal),
          throwsA(isA<SplitLocked>()),
        );
        await expectLater(
          assign(row(b, nasi, 'B'), 'A'),
          throwsA(isA<SplitLocked>()),
        );
        await expectLater(
          voidOpenBill(
            store,
            scope,
            staffId: staff(),
            billId: b.id,
            reason: 'salah',
          ),
          throwsA(isA<SplitLocked>()),
        );
        await expectLater(
          payOpenBill(
            store,
            scope,
            staffId: staff(),
            billId: b.id,
            payments: const [SalePaymentRequest.cash(Money(100000))],
          ),
          throwsA(isA<SplitLocked>()),
        );
        await expectLater(pay(b, guest: 'A'), splitError(SplitError.partPaid));

        final last = await pay(b, guest: 'B');
        expect(last.bill, isNull);
        final done = last.receipt!;
        expect(done.sale.status, SaleStatus.completed);
        expect(done.sale.number, startsWith('PST-K01-'));
        expect(done.sale.total, 91245);
        expect(done.sale.serviceAmount, 3950);
        expect(done.sale.taxAmount, 8295);
        expect(done.sale.paidAmount, 30000 + 63525);
        expect(done.sale.changeAmount, 2280);
        expect(done.payments.map((p) => (p.guestLabel, p.amount)), [
          ('A', 30000),
          ('B', 63525),
        ]);
        expect(done.items, hasLength(3));
        final level = await StockLevel.db.findFirstRow(
          store.session,
          where: (l) => l.variantId.equals(kopi.variants.single.id),
        );
        expect(level!.quantityMilli, 8000);
        await expectLater(
          loadOpenBill(store, scope, b.id),
          throwsA(isA<BillNotFound>()),
        );
      },
    );

    test('bagi rata + QRIS menunggu: batal, konfirmasi, lunas', () async {
      await saveFnbRates(
        store,
        scope,
        staffId: staff(),
        rates: const FnbRates(service: BasisPoints.zero, tax: BasisPoints.zero),
      );
      await saveQrisSettings(
        store,
        scope,
        staffId: staff(),
        settings: const QrisStaticSettings(enabled: true),
        image: QrisImageUpload(bytes: pngBytes(1080, 1528), fileName: 'q.png'),
      );
      await openSession();
      var b = await bill(kopiQty: 1);
      b = await split(b, SplitMode.equal);
      expect(
        [for (final p in b.split!.parts) p.due],
        [const Money(18334), const Money(18333), const Money(18333)],
      );
      const qris = [SalePaymentRequest(method: PaymentMethod.qrisStatic)];
      // Hanya QRIS yang boleh menunggu.
      await expectLater(
        pay(b, guest: 'A', pending: true),
        splitError(SplitError.pending),
      );
      b = (await pay(b, guest: 'A', payments: qris, pending: true)).bill!;
      final waiting = b.payments.single;
      expect(waiting.status, PaymentStatus.pending);
      expect(waiting.amount, 18334);
      expect(b.split!.part('A').status, SplitPartStatus.pending);
      expect(b.split!.pending, const Money(18334));

      b = await cancelSplitPayment(
        store,
        scope,
        staffId: staff(),
        paymentId: waiting.id,
      );
      expect(b.payments, isEmpty);
      expect(b.split!.locked, isFalse);

      b = (await pay(b, guest: 'A', payments: qris, pending: true)).bill!;
      b = (await pay(
        b,
        guest: 'B',
        payments: const [SalePaymentRequest.cash(Money(20000))],
      )).bill!;
      b = (await pay(
        b,
        guest: 'C',
        payments: const [
          SalePaymentRequest(method: PaymentMethod.qrisStatic, confirmed: true),
        ],
      )).bill!;
      expect(b.split!.remaining, Money.zero);
      // Bagian menunggu tidak bisa dibatalkan setelah dikonfirmasi.
      final done = await confirmSplitPayment(
        store,
        scope,
        staffId: staff(),
        paymentId: b.payments.firstWhere((p) => p.guestLabel == 'A').id,
      );
      final receipt = done.receipt!;
      expect(receipt.sale.status, SaleStatus.completed);
      final a = receipt.payments.firstWhere((p) => p.guestLabel == 'A');
      expect(a.status, PaymentStatus.paid);
      expect(a.confirmedBy, staff());
      expect(receipt.sale.paidAmount, 18334 + 20000 + 18333);
      expect(receipt.sale.changeAmount, 20000 - 18333);
    });

    test('nominal bebas: tamu berurutan sampai sisa habis', () async {
      await openSession();
      var b = await bill(kopiQty: 1, nasiQty: 0);
      // 24.000 + service 1.200 + PB1 2.520 = 27.720.
      b = await split(b, SplitMode.amount);
      expect(b.split!.parts.map((p) => p.label), ['A']);
      expect(b.split!.part('A').due, isNull);
      await expectLater(pay(b), splitError(SplitError.amount));
      await expectLater(
        pay(b, amount: const Money(30000)),
        splitError(SplitError.amount),
      );
      b = (await pay(b, amount: const Money(20000))).bill!;
      expect(b.payments.single.guestLabel, 'A');
      expect(b.split!.parts.map((p) => p.label), ['A', 'B']);
      expect(b.split!.remaining, const Money(7720));
      final done = await pay(b, amount: const Money(7720));
      expect(done.receipt!.payments.map((p) => p.guestLabel), ['A', 'B']);
    });

    test('sesi kasir tidak bisa ditutup selama split sebagian', () async {
      final session = await openSession();
      var b = await bill(kopiQty: 1, nasiQty: 0);
      b = await split(b, SplitMode.equal, 2);
      await pay(b, guest: 'A');
      await expectLater(
        closeCashSession(
          store,
          CashScope.of(ctx),
          sessionId: session.id,
          staffId: staff(),
          count: const CashCount(sheets: {}),
        ),
        throwsA(isA<CashSessionHasOpenSplit>()),
      );
    });
  });
}
