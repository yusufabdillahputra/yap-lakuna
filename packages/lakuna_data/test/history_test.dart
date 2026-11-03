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
  late CashScope cashScope;
  late DateTime now;
  late CatalogProduct kopi;
  late CatalogProduct roti;
  late CatalogProduct jasa;

  CatalogVariant v(CatalogProduct p) => p.variants.single;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: draft,
    );
    return (await loadProduct(store, scope, id))!;
  }

  Future<StaffMember> addStaff(String name, String role) {
    final actor = ctx.owner.id;
    return store.write(actor: actor, (w) async {
      final s = await w.stamp();
      final staff = await w.insert(
        StaffMember(
          tenantId: ctx.tenant.id,
          name: name,
          pinHash: r'$argon2id$x',
          isActive: true,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      await w.insert(
        OutletMember(
          tenantId: ctx.tenant.id,
          outletId: ctx.outlet.id,
          staffMemberId: staff.id,
          roleName: role,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      return staff;
    });
  }

  setUp(() async {
    // 2026-11-03 09.00 UTC = 16.00 WIB.
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Bubuk',
        baseUnit: 'pcs',
        variants: [
          VariantDraft(
            costPrice: Money(6000),
            sellPrice: Money(10000),
            openingStock: Qty(20000),
          ),
        ],
      ),
    );
    roti = await product(
      const ProductDraft(
        name: 'Roti Tawar',
        baseUnit: 'pcs',
        variants: [
          VariantDraft(
            costPrice: Money(9000),
            sellPrice: Money(15000),
            openingStock: Qty(10000),
          ),
        ],
      ),
    );
    jasa = await product(
      const ProductDraft(
        name: 'Isi Pulsa',
        kind: ProductKind.service,
        baseUnit: 'kali',
        variants: [VariantDraft(sellPrice: Money(2000))],
      ),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<CashSession> openSession() => openCashSession(
    store,
    cashScope,
    staffId: ctx.owner.id,
    openingCash: const Money(100000),
  );

  Future<CheckoutResult> sell(
    Map<CatalogProduct, int> lines, {
    SalePaymentRequest payment = const SalePaymentRequest.cash(Money(1000000)),
  }) => checkoutSale(
    store,
    scope,
    staffId: ctx.owner.id,
    lines: [
      for (final e in lines.entries)
        SaleLineRequest(variantId: v(e.key).id, quantity: Qty(e.value)),
    ],
    payments: [payment],
  );

  SaleItem itemOf(CheckoutResult r, CatalogProduct p) =>
      r.items.firstWhere((i) => i.variantId == v(p).id);

  Future<Qty> stock(CatalogProduct p) =>
      stockOnHand(store, scope, variantId: v(p).id);

  group('daftar riwayat', () {
    test('filter tanggal, status, metode, staf; ringkasan bersih', () async {
      await openSession();
      final a = await sell({kopi: 2000});
      final b = await sell(
        {roti: 1000},
        payment: const SalePaymentRequest(
          method: PaymentMethod.card,
          reference: 'ref-1',
        ),
      );
      now = now.add(const Duration(minutes: 5));
      final page = await listSalesHistory(store, scope, now: now);
      expect(page.rows.map((r) => r.sale.id), [b.sale.id, a.sale.id]);
      expect(page.count, 2);
      expect(page.total, const Money(35000));
      expect(page.rows.first.methods, [PaymentMethod.card]);
      expect(page.rows.first.staffName, isNotEmpty);

      final card = await listSalesHistory(
        store,
        scope,
        now: now,
        filter: const HistoryFilter(method: PaymentMethod.card),
      );
      expect(card.rows.map((r) => r.sale.id), [b.sale.id]);

      final yesterday = await listSalesHistory(
        store,
        scope,
        now: now,
        filter: const HistoryFilter(range: HistoryRange.yesterday),
      );
      expect(yesterday.rows, isEmpty);
      // Besok: tidak lagi "hari ini", masih "7 hari".
      final tomorrow = now.add(const Duration(days: 1));
      expect(
        (await listSalesHistory(store, scope, now: tomorrow)).rows,
        isEmpty,
      );
      expect(
        (await listSalesHistory(
          store,
          scope,
          now: tomorrow,
          filter: const HistoryFilter(range: HistoryRange.week),
        )).rows,
        hasLength(2),
      );

      final other = await addStaff('Sari', 'cashier');
      final byOther = await listSalesHistory(
        store,
        scope,
        now: now,
        filter: HistoryFilter(staffId: other.id),
      );
      expect(byOther.rows, isEmpty);
    });

    test('bill terbuka tidak tampil', () async {
      await openSession();
      await openTakeAway(store, scope, staffId: ctx.owner.id);
      expect((await listSalesHistory(store, scope, now: now)).rows, isEmpty);
    });
  });

  group('retur', () {
    test(
      'sebagian lalu sisa: nomor RT, nilai, stok, status, kas sesi',
      () async {
        final session = await openSession();
        final sale = await sell({kopi: 3000, roti: 1000}); // 30.000 + 15.000
        final kopiItem = itemOf(sale, kopi);
        expect(await stock(kopi), const Qty(17000));

        final first = await returnSale(
          store,
          scope,
          staffId: ctx.owner.id,
          saleId: sale.sale.id,
          lines: [ReturnLine(saleItemId: kopiItem.id, quantity: Qty.one)],
          reason: SaleReturnReason.wrongItem,
          refundMethod: RefundMethod.cash,
          restock: true,
        );
        expect(first.number, 'RT-PST-K01-261103-0001');
        expect(first.amount, 10000);
        expect(first.cashSessionId, session.id);
        expect(await stock(kopi), const Qty(18000));

        var detail = await loadSaleDetail(store, scope, sale.sale.id, now: now);
        expect(detail.sale.status, SaleStatus.partiallyReturned);
        expect(detail.remainingMilli(kopiItem), 2000);
        expect(detail.returnedTotal, const Money(10000));
        expect(detail.net, const Money(35000));
        expect(detail.voidBlock, VoidBlock.returned);

        // Sisa semua, barang rusak tanpa restok, uang via transfer.
        final second = await returnSale(
          store,
          scope,
          staffId: ctx.owner.id,
          saleId: sale.sale.id,
          lines: [
            ReturnLine(saleItemId: kopiItem.id, quantity: const Qty(2000)),
            ReturnLine(saleItemId: itemOf(sale, roti).id, quantity: Qty.one),
          ],
          reason: SaleReturnReason.damaged,
          refundMethod: RefundMethod.transfer,
          restock: false,
        );
        expect(second.number, 'RT-PST-K01-261103-0002');
        expect(second.amount, 35000);
        expect(await stock(kopi), const Qty(18000));
        detail = await loadSaleDetail(store, scope, sale.sale.id, now: now);
        expect(detail.sale.status, SaleStatus.returned);
        expect(detail.net, Money.zero);
        expect(detail.canReturn, isFalse);

        // Rekap laci: retur tunai saja yang mengurangi.
        final drawer = await cashDrawerFor(store, cashScope, session);
        expect(drawer.cashSales, const Money(45000));
        expect(drawer.cashRefunds, const Money(10000));
        expect(drawer.expectedCash, const Money(135000));
        final summary = await salesSummaryForSession(
          store,
          scope,
          sessionId: session.id,
        );
        expect(summary.count, 1);

        final history = await listSalesHistory(
          store,
          scope,
          now: now,
          filter: const HistoryFilter(status: HistoryStatus.returned),
        );
        expect(history.rows.single.returned, const Money(45000));
        expect(history.total, Money.zero);
      },
    );

    test('nilai retur ikut service/PB1 (bagian proporsional)', () async {
      await openSession();
      final sale = await sell({kopi: 1000, roti: 1000});
      // Ubah total untuk meniru nota F&B dengan service & PB1 (25.000 →
      // 28.875): bagian baris 11.550 + 17.325.
      await store.write(actor: ctx.owner.id, (w) async {
        final s = await w.stamp();
        await w.update(
          sale.sale.copyWith(total: 28875, hlc: s.hlc.toString()),
          s,
        );
      });
      final detail = await loadSaleDetail(store, scope, sale.sale.id, now: now);
      expect(detail.returnValue(itemOf(sale, kopi), 1000), const Money(11550));
      expect(detail.returnValue(itemOf(sale, roti), 1000), const Money(17325));
    });

    test(
      'ditolak: melebihi sisa, kosong, catatan Lainnya, tunai tanpa sesi',
      () async {
        final session = await openSession();
        final sale = await sell({kopi: 1000, jasa: 1000});
        final item = itemOf(sale, kopi);
        Future<SaleReturn> attempt({
          int milli = 1000,
          SaleReturnReason reason = SaleReturnReason.wrongItem,
          String? note,
          RefundMethod method = RefundMethod.cash,
        }) => returnSale(
          store,
          scope,
          staffId: ctx.owner.id,
          saleId: sale.sale.id,
          lines: [ReturnLine(saleItemId: item.id, quantity: Qty(milli))],
          reason: reason,
          note: note,
          refundMethod: method,
          restock: true,
        );

        await expectLater(
          attempt(milli: 2000),
          throwsA(
            isA<ReturnInvalid>().having(
              (e) => e.error,
              'error',
              ReturnError.quantity,
            ),
          ),
        );
        await expectLater(
          attempt(milli: 0),
          throwsA(
            isA<ReturnInvalid>().having(
              (e) => e.error,
              'error',
              ReturnError.empty,
            ),
          ),
        );
        await expectLater(
          attempt(reason: SaleReturnReason.other),
          throwsA(
            isA<ReturnInvalid>().having(
              (e) => e.error,
              'error',
              ReturnError.note,
            ),
          ),
        );
        await expectLater(
          attempt(method: RefundMethod.debt),
          throwsA(
            isA<ReturnInvalid>().having(
              (e) => e.error,
              'error',
              ReturnError.refundMethod,
            ),
          ),
        );
        await closeCashSession(
          store,
          cashScope,
          sessionId: session.id,
          staffId: ctx.owner.id,
          count: const CashCount(sheets: {100000: 1, 10000: 1}),
          note: 'selisih tes',
        );
        await expectLater(attempt(), throwsA(isA<CashSessionNotOpen>()));
        // Transfer tetap bisa tanpa sesi; jasa tanpa stok tidak menulis stok.
        final ok = await returnSale(
          store,
          scope,
          staffId: ctx.owner.id,
          saleId: sale.sale.id,
          lines: [
            ReturnLine(saleItemId: itemOf(sale, jasa).id, quantity: Qty.one),
          ],
          reason: SaleReturnReason.other,
          note: 'Nomor salah',
          refundMethod: RefundMethod.transfer,
          restock: true,
        );
        expect(ok.cashSessionId, isNull);
        expect(
          await StockMovement.db.count(
            store.session,
            where: (m) => m.sourceType.equals(StockSourceType.saleReturn),
          ),
          0,
        );
      },
    );
  });

  group('void', () {
    test('membalik stok, status void, rekap sesi tanpa nota', () async {
      final session = await openSession();
      final sale = await sell({kopi: 2000});
      expect(await stock(kopi), const Qty(18000));
      final approver = await addStaff('Rina', 'manager');
      final voided = await voidSale(
        store,
        scope,
        staffId: ctx.owner.id,
        approverId: approver.id,
        saleId: sale.sale.id,
        reason: 'Salah input',
      );
      expect(voided.status, SaleStatus.voided);
      expect(voided.voidedBy, approver.id);
      expect(voided.voidReason, 'Salah input');
      expect(await stock(kopi), const Qty(20000));
      final drawer = await cashDrawerFor(store, cashScope, session);
      expect(drawer.cashSales, Money.zero);
      final detail = await loadSaleDetail(store, scope, sale.sale.id, now: now);
      expect(detail.voidedByName, 'Rina');
      expect(detail.net, Money.zero);
      expect(detail.canReturn, isFalse);
      expect(detail.voidBlock, VoidBlock.status);
      await expectLater(
        returnSale(
          store,
          scope,
          staffId: ctx.owner.id,
          saleId: sale.sale.id,
          lines: [
            ReturnLine(saleItemId: itemOf(sale, kopi).id, quantity: Qty.one),
          ],
          reason: SaleReturnReason.wrongItem,
          refundMethod: RefundMethod.cash,
          restock: true,
        ),
        throwsA(
          isA<ReturnInvalid>().having(
            (e) => e.error,
            'error',
            ReturnError.status,
          ),
        ),
      );
    });

    test(
      'ditolak: penyetuju tanpa izin, alasan kosong, kemarin, sesi tutup',
      () async {
        final session = await openSession();
        final sale = await sell({kopi: 1000});
        final cashier = await addStaff('Sari', 'cashier');
        Future<Sale> attempt({UuidValue? approver, String reason = 'Batal'}) =>
            voidSale(
              store,
              scope,
              staffId: cashier.id,
              approverId: approver ?? ctx.owner.id,
              saleId: sale.sale.id,
              reason: reason,
            );
        await expectLater(
          attempt(approver: cashier.id),
          throwsA(isA<ApproverNotPermitted>()),
        );
        await expectLater(
          attempt(reason: '  '),
          throwsA(isA<SaleVoidInvalid>()),
        );
        // Besok (17.00 WIB + 1 hari).
        now = now.add(const Duration(days: 1));
        await expectLater(
          attempt(),
          throwsA(
            isA<SaleVoidInvalid>().having(
              (e) => e.block,
              'block',
              VoidBlock.notToday,
            ),
          ),
        );
        now = now.subtract(const Duration(days: 1));
        await closeCashSession(
          store,
          cashScope,
          sessionId: session.id,
          staffId: ctx.owner.id,
          count: const CashCount(sheets: {100000: 1, 10000: 1}),
          note: 'selisih tes',
        );
        await expectLater(
          attempt(),
          throwsA(
            isA<SaleVoidInvalid>().having(
              (e) => e.block,
              'block',
              VoidBlock.session,
            ),
          ),
        );
        final detail = await loadSaleDetail(
          store,
          scope,
          sale.sale.id,
          now: now,
        );
        expect(detail.voidBlock, VoidBlock.session);
      },
    );

    test('Batalkan bill: penyetuju dicatat dan izinnya diperiksa', () async {
      final bill = await openTakeAway(store, scope, staffId: ctx.owner.id);
      final cashier = await addStaff('Sari', 'cashier');
      final manager = await addStaff('Rina', 'manager');
      await expectLater(
        voidOpenBill(
          store,
          scope,
          staffId: cashier.id,
          approverId: cashier.id,
          billId: bill.sale.id,
          reason: 'Tamu batal',
        ),
        throwsA(isA<ApproverNotPermitted>()),
      );
      await voidOpenBill(
        store,
        scope,
        staffId: cashier.id,
        approverId: manager.id,
        billId: bill.sale.id,
        reason: 'Tamu batal',
      );
      final sale = await Sale.db.findById(store.session, bill.sale.id);
      expect(sale!.status, SaleStatus.voided);
      expect(sale.voidedBy, manager.id);
      expect(sale.updatedBy, cashier.id);
    });
  });
}
