import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

// Tarif beku saat split bill dibayar (F1-10h).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CatalogProduct kopi;
  late DiningTable m1;

  UuidValue owner() => ctx.owner.id;

  setUp(() async {
    now = DateTime.utc(2026, 11, 13, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
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
    kopi = (await loadProduct(store, scope, id))!;
    [m1] = await createDiningTables(
      store,
      scope,
      staffId: owner(),
      drafts: const [DiningTableDraft(name: 'M1')],
    );
    await saveFnbRates(
      store,
      scope,
      staffId: owner(),
      rates: const FnbRates(service: BasisPoints(500), tax: BasisPoints(1000)),
    );
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: Money.zero,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<OpenBill> bill([int qty = 4]) async {
    final b = await openTableBill(
      store,
      scope,
      staffId: owner(),
      tableId: m1.id,
      guests: 2,
    );
    return addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.units(qty),
      ),
    );
  }

  Future<OpenBill> split(OpenBill b) => setBillSplit(
    store,
    scope,
    staffId: owner(),
    billId: b.id,
    mode: SplitMode.equal,
    guests: 2,
  );

  Future<SplitPayResult> pay(OpenBill b, String guest, {bool qris = false}) =>
      paySplitPart(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        guest: guest,
        payments: [
          qris
              ? const SalePaymentRequest(method: PaymentMethod.qrisStatic)
              : const SalePaymentRequest(method: PaymentMethod.card),
        ],
        pending: qris,
      );

  Future<void> changeRates() async {
    await saveFnbRates(
      store,
      scope,
      staffId: owner(),
      rates: const FnbRates(
        service: BasisPoints(1000),
        tax: BasisPoints(1100),
        taxInclusive: true,
      ),
    );
    await saveSalesRules(
      store,
      scope,
      staffId: owner(),
      rules: const SalesRules(rounding: TotalRounding.nearest500),
    );
  }

  test('bill tanpa pembayaran mengikuti tarif terkini', () async {
    var b = await bill();
    expect(b.sale.roundingStep, 0);
    // 100.000 + service 5.000 + PB1 10.500.
    expect(b.charges.total, const Money(115500));
    await changeRates();
    b = await loadOpenBill(store, scope, b.id);
    expect(b.rates.service, const BasisPoints(1000));
    expect(b.charges.total, isNot(const Money(115500)));
  });

  test('bagian pertama membekukan tarif sampai nota lunas', () async {
    var b = await split(await bill());
    expect(b.charges.total, const Money(115500));
    b = (await pay(b, 'A')).bill!;
    expect(b.sale.roundingStep, TotalRounding.none.step);
    expect(b.sale.serviceBp, 500);
    expect(b.sale.taxBp, 1000);
    expect(b.sale.taxInclusive, isFalse);

    await changeRates();
    b = await loadOpenBill(store, scope, b.id);
    expect(b.rates.service, const BasisPoints(500));
    expect(b.rates.tax, const BasisPoints(1000));
    expect(b.rates.taxInclusive, isFalse);
    expect(b.rates.rounding, TotalRounding.none);
    expect(b.charges.total, const Money(115500));
    expect(b.split!.part('B').due, const Money(57750));

    // Bill lain memakai tarif baru.
    final other = await addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: (await openTakeAway(store, scope, staffId: owner())).id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.units(1),
      ),
    );
    expect(other.rates.service, const BasisPoints(1000));
    expect(other.rates.rounding, TotalRounding.nearest500);

    final done = (await pay(b, 'B')).receipt!;
    expect(done.sale.total, 115500);
    expect(done.sale.serviceBp, 500);
    expect(done.sale.serviceAmount, 5000);
    expect(done.sale.taxBp, 1000);
    expect(done.sale.taxAmount, 10500);
    expect(done.sale.taxInclusive, isFalse);
    expect(done.sale.roundingStep, 1);
    expect(done.sale.roundingAmount, 0);
  });

  test('QRIS menunggu membekukan; batal satu-satunya melepas', () async {
    await saveQrisSettings(
      store,
      scope,
      staffId: owner(),
      settings: const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: pngBytes(1080, 1528), fileName: 'q.png'),
    );
    var b = await split(await bill());
    b = (await pay(b, 'A', qris: true)).bill!;
    expect(b.sale.roundingStep, 1);
    await changeRates();
    b = await loadOpenBill(store, scope, b.id);
    expect(b.charges.total, const Money(115500));

    b = await cancelSplitPayment(
      store,
      scope,
      staffId: owner(),
      paymentId: b.payments.single.id,
    );
    expect(b.sale.roundingStep, 0);
    expect(b.rates.service, const BasisPoints(1000));
    expect(b.rates.rounding, TotalRounding.nearest500);

    // Bayar lagi: tarif baru yang dibekukan.
    b = (await pay(b, 'A', qris: true)).bill!;
    expect(b.sale.roundingStep, 500);
    expect(b.sale.serviceBp, 1000);
    expect(b.sale.taxInclusive, isTrue);
    final total = b.charges.total;
    await saveFnbRates(store, scope, staffId: owner(), rates: const FnbRates());
    final confirmed = await confirmSplitPayment(
      store,
      scope,
      staffId: owner(),
      paymentId: b.payments.single.id,
    );
    expect(confirmed.bill!.charges.total, total);
    final done = (await pay(confirmed.bill!, 'B')).receipt!;
    expect(done.sale.total, total.value);
    expect(done.sale.roundingStep, 500);
  });

  test('nota lunas tanpa split mencatat kelipatan pembulatan', () async {
    await saveSalesRules(
      store,
      scope,
      staffId: owner(),
      rules: const SalesRules(rounding: TotalRounding.nearest100),
    );
    final b = await bill(1);
    final paid = await payOpenBill(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      payments: [SalePaymentRequest.cash(b.charges.total)],
    );
    expect(paid.sale.roundingStep, 100);
  });
}
