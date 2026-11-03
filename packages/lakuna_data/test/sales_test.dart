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
  late CatalogProduct minyak;
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

  setUp(() async {
    // 2026-11-03 09.00 UTC = 16.00 WIB.
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    minyak = await product(
      const ProductDraft(
        name: 'Minyak Goreng',
        baseUnit: 'botol',
        variants: [
          VariantDraft(
            name: '2 L',
            barcode: '8991',
            costPrice: Money(32500),
            sellPrice: Money(36000),
            openingStock: Qty(24000),
            units: [
              UnitDraft(
                name: 'Dus',
                factor: Qty(6000),
                barcode: '8992',
                sellPrice: Money(210000),
              ),
            ],
            tiers: [PriceTier(minQty: Qty(6000), price: Money(35000))],
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
    openingCash: const Money(200000),
  );

  Future<CheckoutResult> checkout(
    List<SaleLineRequest> lines, {
    SalePaymentRequest payment = const SalePaymentRequest.cash(Money(1000000)),
  }) => checkoutSale(
    store,
    scope,
    staffId: ctx.owner.id,
    lines: lines,
    payment: payment,
  );

  test('tanpa sesi kasir terbuka ditolak', () async {
    await expectLater(
      checkout([SaleLineRequest(variantId: v(minyak).id, quantity: Qty.one)]),
      throwsA(isA<CashSessionNotOpen>()),
    );
    expect(await Sale.db.count(store.session), 0);
  });

  test(
    'checkout tunai menulis nota, item, pembayaran, stok, dan outbox',
    () async {
      final session = await openSession();
      final result = await checkout([
        SaleLineRequest(variantId: v(minyak).id, quantity: Qty.units(2)),
        SaleLineRequest(variantId: v(jasa).id, quantity: Qty.one),
      ], payment: const SalePaymentRequest.cash(Money(100000)));

      final sale = result.sale;
      expect(sale.number, 'PST-K01-261103-0001');
      expect(sale.status, SaleStatus.completed);
      expect(sale.cashSessionId, session.id);
      expect(sale.staffId, ctx.owner.id);
      expect(sale.total, 74000);
      expect(sale.subtotal, 74000);
      expect(sale.tierDiscount, 0);
      expect(sale.paidAmount, 74000);
      expect(sale.changeAmount, 26000);
      expect(sale.itemCount, 2);
      expect(sale.soldAt, now);

      expect(result.items.map((i) => i.productName), [
        'Minyak Goreng',
        'Isi Pulsa',
      ]);
      final item = result.items.first;
      expect(item.variantName, '2 L');
      expect(item.unitName, 'botol');
      expect(item.factorMilli, 1000);
      expect(item.quantityMilli, 2000);
      expect(item.unitPrice, 36000);
      expect(item.lineTotal, 72000);
      expect(item.unitCost, 32500);
      expect(item.tracksStock, isTrue);
      expect(result.items.last.tracksStock, isFalse);

      expect(result.payment.method, PaymentMethod.cash);
      expect(result.payment.amount, 100000);
      expect(result.payment.changeAmount, 26000);
      expect(result.payment.status, PaymentStatus.paid);

      final moves = await StockMovement.db.find(
        store.session,
        where: (m) => m.sourceType.equals(StockSourceType.sale),
      );
      expect(moves, hasLength(1)); // jasa tidak melacak stok
      expect(moves.single.quantityMilli, -2000);
      expect(moves.single.sourceId, sale.id);
      expect(moves.single.unitCost, 32500);
      expect(
        await stockOnHand(store, scope, variantId: v(minyak).id),
        Qty.units(22),
      );

      final outbox = await SyncOutboxEntry.db.find(store.session);
      final entities = outbox.map((e) => e.entity).toList();
      expect(entities.where((e) => e == 'sales'), hasLength(1));
      expect(entities.where((e) => e == 'sale_items'), hasLength(2));
      expect(entities.where((e) => e == 'payments'), hasLength(1));
    },
  );

  test('harga grosir dan satuan konversi dihitung dari database', () async {
    await openSession();
    final dus = v(minyak).units.single;
    final result = await checkout([
      SaleLineRequest(variantId: v(minyak).id, quantity: Qty.units(6)),
      SaleLineRequest(
        variantId: v(minyak).id,
        productUnitId: dus.id,
        quantity: Qty.units(2),
      ),
    ]);
    final base = result.items.first;
    expect(base.listPrice, 36000);
    expect(base.unitPrice, 35000);
    expect(base.lineTotal, 210000);
    final box = result.items.last;
    expect(box.productUnitId, dus.id);
    expect(box.unitName, 'Dus');
    expect(box.factorMilli, 6000);
    expect(box.unitPrice, 210000);
    expect(box.lineTotal, 420000);
    expect(result.sale.subtotal, 636000);
    expect(result.sale.tierDiscount, 6000);
    expect(result.sale.total, 630000);
    // 6 + 2 dus × 6 = 18 botol keluar.
    expect(
      await stockOnHand(store, scope, variantId: v(minyak).id),
      Qty.units(6),
    );
  });

  test('stok yang jadi minus dilaporkan', () async {
    await openSession();
    final result = await checkout([
      SaleLineRequest(variantId: v(minyak).id, quantity: Qty.units(25)),
    ]);
    expect(result.negativeStock, hasLength(1));
    expect(result.negativeStock.single.name, 'Minyak Goreng 2 L');
    expect(result.negativeStock.single.onHand, Qty.units(-1));
  });

  test('kartu dan transfer: jumlah = total, referensi disimpan', () async {
    await openSession();
    final card = await checkout(
      [SaleLineRequest(variantId: v(jasa).id, quantity: Qty.one)],
      payment: const SalePaymentRequest(
        method: PaymentMethod.card,
        reference: ' 004512 ',
      ),
    );
    expect(card.payment.amount, 2000);
    expect(card.payment.changeAmount, 0);
    expect(card.payment.reference, '004512');
    expect(card.sale.changeAmount, 0);

    final transfer = await checkout([
      SaleLineRequest(variantId: v(jasa).id, quantity: Qty.one),
    ], payment: const SalePaymentRequest(method: PaymentMethod.transfer));
    expect(transfer.payment.reference, isNull);
    expect(transfer.sale.number, 'PST-K01-261103-0002');
  });

  test('input tidak sah ditolak tanpa menulis apa pun', () async {
    await openSession();
    final line = SaleLineRequest(variantId: v(jasa).id, quantity: Qty.one);
    await expectLater(checkout(const []), throwsA(isA<SaleEmpty>()));
    await expectLater(
      checkout([SaleLineRequest(variantId: v(jasa).id, quantity: Qty.zero)]),
      throwsA(isA<SaleQuantityInvalid>()),
    );
    await expectLater(
      checkout([line], payment: const SalePaymentRequest.cash(Money(1999))),
      throwsA(
        isA<SalePaymentShort>().having((e) => e.total, 'total', Money(2000)),
      ),
    );
    await expectLater(
      checkout(
        [line],
        payment: SalePaymentRequest(
          method: PaymentMethod.card,
          reference: 'x' * 41,
        ),
      ),
      throwsA(isA<SaleReferenceInvalid>()),
    );
    await expectLater(
      checkout([
        line,
      ], payment: const SalePaymentRequest(method: PaymentMethod.qrisStatic)),
      throwsA(isA<SalePaymentUnsupported>()),
    );
    expect(await Sale.db.count(store.session), 0);
  });

  test('produk nonaktif, terhapus, atau satuan asing ditolak', () async {
    await openSession();
    await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: jasa.toDraft().copyWithActive(false),
    );
    await expectLater(
      checkout([SaleLineRequest(variantId: v(jasa).id, quantity: Qty.one)]),
      throwsA(
        isA<SaleItemUnavailable>().having(
          (e) => e.variantId,
          'variantId',
          v(jasa).id,
        ),
      ),
    );
    await expectLater(
      checkout([
        SaleLineRequest(
          variantId: v(jasa).id,
          productUnitId: v(minyak).units.single.id,
          quantity: Qty.one,
        ),
      ]),
      throwsA(isA<SaleItemUnavailable>()),
    );
    await expectLater(
      checkout([
        SaleLineRequest(
          variantId: UuidValue.fromString(newId()),
          quantity: Qty.one,
        ),
      ]),
      throwsA(isA<SaleItemUnavailable>()),
    );
  });

  test('nomor nota urut per hari zona cabang', () async {
    await openSession();
    final line = SaleLineRequest(variantId: v(jasa).id, quantity: Qty.one);
    expect((await checkout([line])).sale.number, 'PST-K01-261103-0001');
    expect((await checkout([line])).sale.number, 'PST-K01-261103-0002');
    // 16.59 UTC = 23.59 WIB, masih tanggal 3.
    now = DateTime.utc(2026, 11, 3, 16, 59);
    expect((await checkout([line])).sale.number, 'PST-K01-261103-0003');
    // 17.00 UTC = 00.00 WIB tanggal 4.
    now = DateTime.utc(2026, 11, 3, 17);
    expect((await checkout([line])).sale.number, 'PST-K01-261104-0001');
  });

  test('sesi kasir: rekap laci memuat penjualan tunai bersih', () async {
    final session = await openSession();
    final line = SaleLineRequest(variantId: v(minyak).id, quantity: Qty.one);
    await checkout([
      line,
    ], payment: const SalePaymentRequest.cash(Money(50000)));
    await checkout([
      line,
    ], payment: const SalePaymentRequest(method: PaymentMethod.card));

    final summary = await salesSummaryForSession(
      store,
      scope,
      sessionId: session.id,
    );
    expect(summary.count, 2);
    expect(summary.total, const Money(72000));
    expect(summary.cash, const Money(36000));
    expect(summary.nonCash, const Money(36000));

    final drawer = await cashDrawerFor(store, cashScope, session);
    expect(drawer.cashSales, const Money(36000));
    expect(drawer.expectedCash, const Money(236000));
  });

  test('sesi tertutup menolak checkout', () async {
    final session = await openSession();
    await closeCashSession(
      store,
      cashScope,
      sessionId: session.id,
      staffId: ctx.owner.id,
      count: const CashCount(coins: Money(200000)),
    );
    await expectLater(
      checkout([SaleLineRequest(variantId: v(jasa).id, quantity: Qty.one)]),
      throwsA(isA<CashSessionNotOpen>()),
    );
  });
}

extension on ProductDraft {
  ProductDraft copyWithActive(bool active) => ProductDraft(
    id: id,
    name: name,
    category: category,
    kind: kind,
    baseUnit: baseUnit,
    sku: sku,
    brand: brand,
    isActive: active,
    isTaxable: isTaxable,
    variants: variants,
  );
}
