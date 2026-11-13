import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-10f: pelanggan di open bill + harga grup.
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CustomerGroup reseller;
  late CatalogProduct beras;
  late DiningTable m1;
  late DiningTable m2;

  UuidValue owner() => ctx.owner.id;
  CatalogVariant v(CatalogProduct p) => p.variants.single;

  setUp(() async {
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
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
    [m1, m2] = await createDiningTables(
      store,
      scope,
      staffId: owner(),
      drafts: const [
        DiningTableDraft(name: 'M1', canMerge: true),
        DiningTableDraft(name: 'M2', canMerge: true),
      ],
    );
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

  Future<OpenBill> open(DiningTable t) =>
      openTableBill(store, scope, staffId: owner(), tableId: t.id, guests: 2);

  Future<OpenBill> add(OpenBill b, int sak) => addBillItem(
    store,
    scope,
    staffId: owner(),
    billId: b.id,
    line: SaleLineRequest(variantId: v(beras).id, quantity: Qty.units(sak)),
  );

  Future<OpenBill> setCustomer(OpenBill b, Customer? c) => setOpenBillCustomer(
    store,
    scope,
    staffId: owner(),
    billId: b.id,
    customerId: c?.id,
  );

  test('pelanggan grup: semua item (termasuk di dapur) dan item baru '
      'memakai harga grup; hapus → harga umum', () async {
    final ani = await customer('Toko Ani', group: reseller);
    var b = await add(await open(m1), 2);
    await sendToKitchen(store, scope, staffId: owner(), billId: b.id);
    b = await setCustomer(b, ani);
    expect(b.sale.customerId, ani.id);
    expect(b.sale.customerName, 'Toko Ani');
    expect(b.customer?.name, 'Toko Ani');
    expect(b.customer?.groupName, 'Reseller');
    expect(b.items.single.unitPrice, 95000);
    expect(b.items.single.kitchenStatus, KitchenStatus.sent);
    expect(b.charges.subtotal, const Money(190000));

    b = await add(b, 1);
    expect(b.items.last.unitPrice, 95000);

    b = await setCustomer(b, null);
    expect(b.sale.customerId, isNull);
    expect(b.sale.customerName, isNull);
    expect(b.customer, isNull);
    expect(b.items.map((i) => i.unitPrice), [100000, 100000]);
  });

  test('nama pemesan yang sudah ada tidak ditimpa', () async {
    final ani = await customer('Toko Ani', group: reseller);
    var b = await openTakeAway(
      store,
      scope,
      staffId: owner(),
      customerName: 'Bu Ani (teras)',
    );
    b = await setCustomer(b, ani);
    expect(b.sale.customerName, 'Bu Ani (teras)');
    b = await setCustomer(b, null);
    expect(b.sale.customerName, 'Bu Ani (teras)');
  });

  test('pelanggan tanpa grup: tingkat umum tetap berlaku', () async {
    final budi = await customer('Budi');
    var b = await add(await open(m1), 10);
    b = await setCustomer(b, budi);
    expect(b.items.single.unitPrice, 90000);
  });

  test('ditolak saat split; pelanggan terhapus ditolak', () async {
    final ani = await customer('Toko Ani', group: reseller);
    var b = await add(await open(m1), 2);
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.equal,
      guests: 2,
    );
    await expectLater(setCustomer(b, ani), throwsA(isA<BillCustomerBlocked>()));
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: null,
    );
    await deleteCustomer(store, scope, staffId: owner(), customerId: ani.id);
    await expectLater(setCustomer(b, ani), throwsA(isA<CustomerNotFound>()));
  });

  test('gabung meja: pelanggan berbeda ditolak; satu pelanggan → harga grup '
      'untuk semua item', () async {
    final ani = await customer('Toko Ani', group: reseller);
    final budi = await customer('Budi');
    var a = await add(await open(m1), 1);
    var b = await add(await open(m2), 2);
    a = await setCustomer(a, ani);
    b = await setCustomer(b, budi);
    await expectLater(
      mergeOpenBills(
        store,
        scope,
        staffId: owner(),
        targetBillId: a.id,
        sourceBillId: b.id,
      ),
      throwsA(
        isA<BillMergeBlocked>().having(
          (e) => e.reason,
          'reason',
          BillMergeReason.customer,
        ),
      ),
    );
    b = await setCustomer(b, null);
    final merged = await mergeOpenBills(
      store,
      scope,
      staffId: owner(),
      targetBillId: b.id,
      sourceBillId: a.id,
    );
    expect(merged.sale.customerId, ani.id);
    expect(merged.items.map((i) => i.unitPrice), [95000, 95000]);
  });

  test('bayar kredit atas nama pelanggan lain ditolak; pelanggan bill '
      'boleh', () async {
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: const Money(100000),
    );
    final ani = await customer('Toko Ani', group: reseller);
    final budi = await customer('Budi');
    var b = await add(await open(m1), 2);
    b = await setCustomer(b, ani);
    SaleCredit credit(Customer c) => SaleCredit(
      customerId: c.id,
      downPayment: Money.zero,
      dueOn: DateTime.utc(2026, 11, 17),
    );
    await expectLater(
      payOpenBill(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        payments: const [],
        credit: credit(budi),
      ),
      throwsA(isA<BillCustomerMismatch>()),
    );
    final paid = await payOpenBill(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      payments: const [],
      credit: credit(ani),
    );
    expect(paid.sale.customerId, ani.id);
    expect(paid.sale.total, 190000);
  });

  test('tunai: pelanggan bill tercatat di nota', () async {
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: const Money(100000),
    );
    final ani = await customer('Toko Ani', group: reseller);
    var b = await add(await open(m1), 1);
    b = await setCustomer(b, ani);
    final paid = await payOpenBill(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      payments: const [SalePaymentRequest.cash(Money(100000))],
    );
    expect(paid.sale.customerId, ani.id);
    expect(paid.sale.total, 95000);
  });

  test('perubahan tercatat di outbox sinkronisasi', () async {
    final ani = await customer('Toko Ani', group: reseller);
    final b = await add(await open(m1), 1);
    final before = (await SyncOutboxEntry.db.find(store.session)).length;
    await setCustomer(b, ani);
    final entries = (await SyncOutboxEntry.db.find(store.session)).skip(before);
    expect(
      entries.map((e) => e.entity).toSet(),
      containsAll(['sales', 'sale_items']),
    );
  });

  Future<void> setSellPrice(int price) async {
    final row = await ProductVariant.db.findById(store.session, v(beras).id);
    await ProductVariant.db.updateRow(
      store.session,
      row!.copyWith(sellPrice: price),
    );
  }

  test('harga beku: pelanggan tanpa perubahan grup tidak menghitung ulang '
      'harga setelah harga menu naik', () async {
    final budi = await customer('Budi');
    final ani = await customer('Toko Ani', group: reseller);
    var b = await add(await open(m1), 2);
    await setSellPrice(110000);
    b = await setCustomer(b, budi);
    expect(b.items.single.unitPrice, 100000);
    b = await setCustomer(b, null);
    expect(b.items.single.unitPrice, 100000);
    // Grup berubah: dihitung ulang dengan aturan harga saat ini.
    b = await setCustomer(b, ani);
    expect(b.items.single.unitPrice, 95000);
  });

  test('produk nonaktif setelah dikirim ke dapur: harga beku dipakai, bill '
      'tidak terkunci', () async {
    final ani = await customer('Toko Ani', group: reseller);
    var b = await add(await open(m1), 2);
    await sendToKitchen(store, scope, staffId: owner(), billId: b.id);
    final product = await Product.db.findById(store.session, beras.id);
    await Product.db.updateRow(
      store.session,
      product!.copyWith(isActive: false),
    );
    b = await setCustomer(b, ani);
    expect(b.sale.customerId, ani.id);
    expect(b.items.single.unitPrice, 100000);
    b = await setCustomer(b, null);
    expect(b.sale.customerId, isNull);
  });

  test('pelanggan bill terhapus dianggap tanpa pelanggan: kredit pelanggan '
      'lain dan gabung boleh', () async {
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: const Money(100000),
    );
    final ani = await customer('Toko Ani', group: reseller);
    final budi = await customer('Budi');
    var a = await add(await open(m1), 1);
    a = await setCustomer(a, ani);
    var b = await add(await open(m2), 1);
    b = await setCustomer(b, budi);
    await deleteCustomer(store, scope, staffId: owner(), customerId: ani.id);
    final merged = await mergeOpenBills(
      store,
      scope,
      staffId: owner(),
      targetBillId: a.id,
      sourceBillId: b.id,
    );
    expect(merged.sale.customerId, budi.id);
    expect(merged.customer?.name, 'Budi');
    // Grup tidak berubah (keduanya tanpa grup yang masih ada): harga beku
    // tiap item dipertahankan.
    expect(merged.items.map((i) => i.unitPrice), [95000, 100000]);
    final paid = await payOpenBill(
      store,
      scope,
      staffId: owner(),
      billId: merged.id,
      payments: const [],
      credit: SaleCredit(
        customerId: budi.id,
        downPayment: Money.zero,
        dueOn: DateTime.utc(2026, 11, 17),
      ),
    );
    expect(paid.sale.customerId, budi.id);
  });

  test('gabung: tujuan berpelanggan, sumber tanpa → hanya item sumber '
      'dihitung ulang', () async {
    final ani = await customer('Toko Ani', group: reseller);
    var a = await add(await open(m1), 1);
    a = await setCustomer(a, ani);
    final b = await add(await open(m2), 1);
    await setSellPrice(110000);
    final merged = await mergeOpenBills(
      store,
      scope,
      staffId: owner(),
      targetBillId: a.id,
      sourceBillId: b.id,
    );
    expect(merged.sale.customerId, ani.id);
    expect(merged.items.map((i) => i.unitPrice), [95000, 95000]);
  });

  test('nama pelanggan panjang dipotong ke batas nama pemesan', () async {
    final long = await customer('Koperasi ${'Sejahtera ' * 6}'.trim());
    final b = await setCustomer(await add(await open(m1), 1), long);
    expect(b.sale.customerName, hasLength(FnbLimits.customerName));
    expect(long.name.startsWith(b.sale.customerName!), isTrue);
  });

  test('diskon nota rupiah yang menghabiskan total setelah harga grup '
      'ditolak', () async {
    final ani = await customer('Toko Ani', group: reseller);
    var b = await add(await open(m1), 1);
    b = await setBillDiscount(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      discount: const ManualDiscount.amount(Money(96000)),
    );
    await expectLater(setCustomer(b, ani), throwsA(isA<DiscountTooLarge>()));
    final after = await loadOpenBill(store, scope, b.id);
    expect(after.sale.customerId, isNull);
    expect(after.items.single.unitPrice, 100000);
  });
}
