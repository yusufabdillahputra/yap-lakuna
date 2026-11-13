import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-07c: harga grosir per grup pelanggan.
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CashScope cashScope;
  late DateTime now;
  late CustomerGroup reseller;
  late CatalogProduct beras;

  UuidValue owner() => ctx.owner.id;
  CatalogVariant v(CatalogProduct p) => p.variants.single;

  setUp(() async {
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    reseller = await saveCustomerGroup(
      store,
      scope,
      staffId: owner(),
      name: 'Reseller',
      termDays: 0,
    );
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: ProductDraft(
        name: 'Beras Premium 5 kg',
        baseUnit: 'sak',
        variants: [
          VariantDraft(
            costPrice: const Money(60000),
            sellPrice: const Money(100000),
            openingStock: const Qty(50000),
            tiers: [
              PriceTier(minQty: Qty.units(10), price: const Money(90000)),
              PriceTier(
                minQty: Qty.one,
                price: const Money(95000),
                groupId: reseller.id.uuid,
              ),
            ],
          ),
        ],
      ),
    );
    beras = (await loadProduct(store, scope, id))!;
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<Customer> customer(String name, {CustomerGroup? group}) =>
      saveCustomer(
        store,
        scope,
        staffId: owner(),
        input: CustomerInput(
          name: name,
          groupId: group?.id,
          creditLimit: const Money(5000000),
        ),
      );

  Future<void> openSession() => openCashSession(
    store,
    cashScope,
    staffId: owner(),
    openingCash: const Money(100000),
  );

  List<SaleLineRequest> sak(int n) => [
    SaleLineRequest(variantId: v(beras).id, quantity: Qty.units(n)),
  ];

  test('tingkat grup tersimpan dan dimuat kembali', () async {
    final tiers = v(beras).tiers;
    expect(tiers.map((t) => (t.minQty, t.groupId)), [
      (Qty.units(10), null),
      (Qty.one, reseller.id.uuid),
    ]);
    final rows = await ProductPriceTier.db.find(store.session);
    expect(rows.map((r) => r.customerGroupId).toSet(), {null, reseller.id});

    final list = await listProducts(store, scope);
    expect(list.single.variants.single.tiers.last.groupId, reseller.id.uuid);
  });

  test('checkout tunai: pelanggan grup dapat harga grup', () async {
    await openSession();
    final ani = await customer('Toko Ani', group: reseller);
    final sale = await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: sak(2),
      payments: const [SalePaymentRequest.cash(Money(500000))],
      customerId: ani.id,
    );
    expect(sale.sale.subtotal, 200000);
    expect(sale.sale.tierDiscount, 10000);
    expect(sale.sale.total, 190000);
    expect(sale.items.single.unitPrice, 95000);
  });

  test('tanpa pelanggan atau tanpa grup: hanya tingkat umum', () async {
    await openSession();
    final budi = await customer('Budi');
    final a = await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: sak(2),
      payments: const [SalePaymentRequest.cash(Money(500000))],
    );
    expect(a.sale.total, 200000);
    final b = await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: sak(10),
      payments: const [SalePaymentRequest.cash(Money(1000000))],
      customerId: budi.id,
    );
    expect(b.sale.total, 900000);
  });

  test('tingkat umum lebih murah tetap menang untuk pelanggan grup', () async {
    await openSession();
    final ani = await customer('Toko Ani', group: reseller);
    final sale = await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: sak(10),
      payments: const [SalePaymentRequest.cash(Money(1000000))],
      customerId: ani.id,
    );
    expect(sale.items.single.unitPrice, 90000);
  });

  test('kredit memakai grup pelanggan kredit', () async {
    await openSession();
    final ani = await customer('Toko Ani', group: reseller);
    final sale = await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: sak(2),
      payments: const [],
      credit: SaleCredit(
        customerId: ani.id,
        downPayment: Money.zero,
        dueOn: DateTime.utc(2026, 11, 17),
      ),
    );
    expect(sale.sale.total, 190000);
  });

  test('nota tersimpan memakai harga grup dan membawa grupnya', () async {
    final ani = await customer('Toko Ani', group: reseller);
    final parked = await parkSale(
      store,
      scope,
      staffId: owner(),
      lines: sak(2),
      customerId: ani.id,
    );
    expect(parked.total, 190000);
    final loaded = await loadParkedSale(store.session, scope, parked.id);
    expect(loaded.customerGroupId, reseller.id);
  });

  test('grup yang dipakai harga grosir tidak bisa dihapus', () async {
    await expectLater(
      deleteCustomerGroup(store, scope, staffId: owner(), groupId: reseller.id),
      throwsA(isA<CustomerGroupHasPrices>()),
    );
  });

  test('ubah grup tingkat tersimpan; grup tak dikenal ditolak', () async {
    final grosir = await saveCustomerGroup(
      store,
      scope,
      staffId: owner(),
      name: 'Grosir',
      termDays: 0,
    );
    ProductDraft draft(String groupId) => ProductDraft(
      id: beras.id.uuid,
      name: beras.name,
      baseUnit: 'sak',
      variants: [
        VariantDraft(
          id: v(beras).id.uuid,
          costPrice: const Money(60000),
          sellPrice: const Money(100000),
          tiers: [
            for (final t in v(beras).tiers)
              t.groupId == null
                  ? t
                  : PriceTier(
                      id: t.id,
                      minQty: t.minQty,
                      price: t.price,
                      groupId: groupId,
                    ),
          ],
        ),
      ],
    );
    await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: draft(grosir.id.uuid),
    );
    final again = (await loadProduct(store, scope, beras.id))!;
    expect(again.variants.single.tiers.last.groupId, grosir.id.uuid);
    expect(
      await ProductPriceTier.db.count(store.session),
      2,
      reason: 'baris lama diubah, bukan dibuat ulang',
    );

    await expectLater(
      saveProduct(
        store,
        scope,
        staffId: owner(),
        draft: draft('00000000-0000-4000-8000-000000000000'),
      ),
      throwsA(isA<PriceTierGroupNotFound>()),
    );
  });
}
