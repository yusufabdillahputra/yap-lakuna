import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

// Kas per sesi untuk bagian split bill (F1-10i).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope k01;
  late CatalogScope k02;
  late CashSession s01;
  late CashSession s02;
  late DateTime now;
  late CatalogProduct kopi;
  late DiningTable m1;

  UuidValue owner() => ctx.owner.id;
  CashScope cashScope(CatalogScope s) => CashScope(
    tenantId: s.tenantId,
    outletId: s.outletId,
    deviceId: s.deviceId,
  );

  setUp(() async {
    now = DateTime.utc(2026, 11, 14, 3);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    k01 = CatalogScope.of(ctx);
    final device = await store.write(actor: owner(), (w) async {
      final s = await w.stamp();
      return w.insert(
        Device(
          tenantId: ctx.tenant.id,
          outletId: ctx.outlet.id,
          code: 'K02',
          name: 'Perangkat K02',
          platform: DevicePlatform.android,
          createdBy: owner(),
          updatedBy: owner(),
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
    k02 = CatalogScope(
      tenantId: ctx.tenant.id,
      outletId: ctx.outlet.id,
      deviceId: device.id,
    );
    final id = await saveProduct(
      store,
      k01,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Kopi Susu Aren',
        baseUnit: 'gelas',
        variants: [
          VariantDraft(
            costPrice: Money(9000),
            sellPrice: Money(25000),
            openingStock: Qty(20000),
          ),
        ],
      ),
    );
    kopi = (await loadProduct(store, k01, id))!;
    [m1] = await createDiningTables(
      store,
      k01,
      staffId: owner(),
      drafts: const [DiningTableDraft(name: 'M1')],
    );
    s01 = await openCashSession(
      store,
      cashScope(k01),
      staffId: owner(),
      openingCash: Money.zero,
    );
    s02 = await openCashSession(
      store,
      cashScope(k02),
      staffId: owner(),
      openingCash: Money.zero,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<SessionSalesSummary> summary(CashSession s) =>
      salesSummaryForSession(store, k01, sessionId: s.id);

  /// Bill M1 4 × Rp25.000 = Rp100.000, dibagi rata dua tamu.
  Future<OpenBill> splitBill() async {
    var b = await openTableBill(
      store,
      k01,
      staffId: owner(),
      tableId: m1.id,
      guests: 2,
    );
    b = await addBillItem(
      store,
      k01,
      staffId: owner(),
      billId: b.id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.units(4),
      ),
    );
    return setBillSplit(
      store,
      k01,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.equal,
      guests: 2,
    );
  }

  Future<SplitPayResult> payCash(CatalogScope at, OpenBill b, String guest) =>
      paySplitPart(
        store,
        at,
        staffId: owner(),
        billId: b.id,
        guest: guest,
        payments: const [SalePaymentRequest.cash(Money(60000))],
      );

  Future<List<Payment>> paymentsOf(UuidValue saleId) => Payment.db.find(
    store.session,
    where: (p) => p.saleId.equals(saleId) & p.deletedAt.equals(null),
    orderBy: (p) => p.guestLabel,
  );

  test('Kasir retail dan bayar penuh open bill mencatat sesi', () async {
    final sale = await checkoutSale(
      store,
      k01,
      staffId: owner(),
      lines: [
        SaleLineRequest(variantId: kopi.variants.single.id, quantity: Qty.one),
      ],
      payments: const [SalePaymentRequest.cash(Money(30000))],
    );
    expect((await paymentsOf(sale.sale.id)).single.cashSessionId, s01.id);

    final b = await openTableBill(
      store,
      k02,
      staffId: owner(),
      tableId: m1.id,
      guests: 1,
    );
    await addBillItem(
      store,
      k02,
      staffId: owner(),
      billId: b.id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.one,
      ),
    );
    await payOpenBill(
      store,
      k02,
      staffId: owner(),
      billId: b.id,
      payments: const [SalePaymentRequest.cash(Money(30000))],
    );
    expect((await paymentsOf(b.id)).single.cashSessionId, s02.id);
  });

  test('tunai bagian A masuk rekap laci sebelum bill lunas', () async {
    final b = await splitBill();
    final due = b.split!.part('A').due!;
    await payCash(k01, b, 'A');
    final sum = await summary(s01);
    expect(sum.cash, due);
    expect(sum.count, 0);
    final drawer = await cashDrawerFor(store, cashScope(k01), s01);
    expect(drawer.expectedCash, due);
  });

  test('bagian di dua perangkat: tunai ke sesi penerima, nota ke sesi '
      'penutup', () async {
    var b = await splitBill();
    final a = b.split!.part('A').due!;
    b = (await payCash(k01, b, 'A')).bill!;
    final b2 = b.split!.part('B').due!;
    final done = await payCash(k02, b, 'B');
    expect(done.receipt!.sale.cashSessionId, s02.id);
    expect((await paymentsOf(b.id)).map((p) => p.cashSessionId), [
      s01.id,
      s02.id,
    ]);
    final one = await summary(s01);
    expect(one.cash, a);
    expect(one.count, 0);
    final two = await summary(s02);
    expect(two.cash, b2);
    expect(two.count, 1);
    expect(two.total, a + b2);
  });

  test('tutup sesi hanya ditolak di sesi penerima bagian', () async {
    final b = await splitBill();
    await payCash(k01, b, 'A');
    await expectLater(
      closeCashSession(
        store,
        cashScope(k01),
        sessionId: s01.id,
        staffId: owner(),
        count: const CashCount(sheets: {}),
      ),
      throwsA(isA<CashSessionHasOpenSplit>()),
    );
    final closed = await closeCashSession(
      store,
      cashScope(k02),
      sessionId: s02.id,
      staffId: owner(),
      count: const CashCount(sheets: {}),
    );
    expect(closed.status, CashSessionStatus.closed);
  });

  test('QRIS menunggu dihitung di sesi yang mengonfirmasi', () async {
    await saveQrisSettings(
      store,
      k01,
      staffId: owner(),
      settings: const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: pngBytes(1080, 1528), fileName: 'q.png'),
    );
    final b = await splitBill();
    final pending = (await paySplitPart(
      store,
      k01,
      staffId: owner(),
      billId: b.id,
      guest: 'A',
      payments: const [SalePaymentRequest(method: PaymentMethod.qrisStatic)],
      pending: true,
    )).bill!;
    final id = pending.payments.single.id;
    await confirmSplitPayment(store, k02, staffId: owner(), paymentId: id);
    final payment = await Payment.db.findById(store.session, id);
    expect(payment!.cashSessionId, s02.id);
    expect((await summary(s02)).nonCash, b.split!.part('A').due);
    expect((await summary(s01)).nonCash, Money.zero);
  });

  test('pembayaran lama tanpa sesi dihitung di sesi notanya', () async {
    final sale = await checkoutSale(
      store,
      k01,
      staffId: owner(),
      lines: [
        SaleLineRequest(variantId: kopi.variants.single.id, quantity: Qty.one),
      ],
      payments: const [SalePaymentRequest.cash(Money(30000))],
    );
    final payment = (await paymentsOf(sale.sale.id)).single;
    await Payment.db.updateRow(
      store.session,
      payment.copyWith(cashSessionId: null),
    );
    expect((await paymentsOf(sale.sale.id)).single.cashSessionId, isNull);
    expect((await summary(s01)).cash, const Money(25000));
  });

  test('batal nota dan batal bill ditolak bila bagian dibayar di sesi '
      'lain', () async {
    var b = await splitBill();
    b = (await payCash(k01, b, 'A')).bill!;
    await expectLater(
      voidOpenBill(
        store,
        k02,
        staffId: owner(),
        billId: b.id,
        reason: 'Tamu pergi',
      ),
      throwsA(isA<BillPaidInOtherSession>()),
    );
    await payCash(k02, b, 'B');
    await expectLater(
      voidSale(
        store,
        k02,
        staffId: owner(),
        approverId: owner(),
        saleId: b.id,
        reason: 'Salah input',
      ),
      throwsA(
        isA<SaleVoidInvalid>().having(
          (e) => e.block,
          'block',
          VoidBlock.session,
        ),
      ),
    );
  });
}
