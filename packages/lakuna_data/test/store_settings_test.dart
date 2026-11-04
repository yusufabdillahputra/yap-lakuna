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
  late CatalogProduct teh;
  late CatalogProduct jasa;

  UuidValue owner() => ctx.owner.id;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: owner(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

  SaleLineRequest line(CatalogProduct p, [int qty = 1]) => SaleLineRequest(
    variantId: p.variants.single.id,
    quantity: Qty(qty * 1000),
  );

  setUp(() async {
    now = DateTime.utc(2026, 11, 4, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    teh = await product(
      const ProductDraft(
        name: 'Teh Botol',
        baseUnit: 'botol',
        variants: [
          VariantDraft(
            costPrice: Money(3000),
            sellPrice: Money(4150),
            openingStock: Qty(2000),
          ),
        ],
      ),
    );
    jasa = await product(
      const ProductDraft(
        name: 'Nasi Goreng',
        kind: ProductKind.service,
        baseUnit: 'porsi',
        variants: [VariantDraft(sellPrice: Money(30050))],
      ),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<void> openSession() => openCashSession(
    store,
    CashScope.of(ctx),
    staffId: owner(),
    openingCash: const Money(100000),
  );

  Future<SalesRules> rules(SalesRules r) =>
      saveSalesRules(store, scope, staffId: owner(), rules: r);

  group('aturan penjualan & stok', () {
    test('bawaan, simpan, muat, outbox hanya bila berubah', () async {
      expect(await loadSalesRules(store.session, scope), const SalesRules());
      final before = await SyncOutboxEntry.db.count(store.session);
      final saved = await rules(
        const SalesRules(
          allowNegativeStock: false,
          rounding: TotalRounding.nearest100,
        ),
      );
      expect(saved.rounding, TotalRounding.nearest100);
      expect(await loadSalesRules(store.session, scope), saved);
      expect(await SyncOutboxEntry.db.count(store.session) - before, 1);
      await rules(saved);
      expect(await SyncOutboxEntry.db.count(store.session) - before, 1);
    });

    test('pembulatan Rp 100: total, selisih, dan bayar pas', () async {
      await rules(const SalesRules(rounding: TotalRounding.nearest100));
      await openSession();
      // 4.150 × 2 = 8.300 (tepat); + 30.050 = 38.350 → 38.400.
      final r = await checkoutSale(
        store,
        scope,
        staffId: owner(),
        lines: [line(teh, 2), line(jasa)],
        payments: const [SalePaymentRequest.cash(Money(38400))],
      );
      expect(r.sale.subtotal, 38350);
      expect(r.sale.roundingAmount, 50);
      expect(r.sale.total, 38400);
      expect(r.sale.changeAmount, 0);
    });

    test('pembulatan Rp 500 ke bawah untuk nota non-tunai', () async {
      await rules(const SalesRules(rounding: TotalRounding.nearest500));
      await openSession();
      // 4.150 → 4.000.
      final r = await checkoutSale(
        store,
        scope,
        staffId: owner(),
        lines: [line(teh)],
        payments: const [
          SalePaymentRequest(method: PaymentMethod.card, amount: Money(4000)),
        ],
      );
      expect(r.sale.roundingAmount, -150);
      expect(r.sale.total, 4000);
    });

    test('stok minus dimatikan: nota ditolak tanpa menulis apa pun', () async {
      await rules(const SalesRules(allowNegativeStock: false));
      await openSession();
      final before = await Sale.db.count(store.session);
      await expectLater(
        checkoutSale(
          store,
          scope,
          staffId: owner(),
          lines: [line(teh, 3), line(jasa)],
          payments: const [SalePaymentRequest.cash(Money(100000))],
        ),
        throwsA(
          isA<SaleStockShort>().having(
            (e) => e.items.single.name,
            'nama',
            'Teh Botol',
          ),
        ),
      );
      expect(await Sale.db.count(store.session), before);
      expect(
        await stockOnHand(store, scope, variantId: teh.variants.single.id),
        Qty.units(2),
      );
      // Stok pas (habis jadi 0) tetap boleh; jasa tidak berstok.
      final ok = await checkoutSale(
        store,
        scope,
        staffId: owner(),
        lines: [line(teh, 2), line(jasa)],
        payments: const [SalePaymentRequest.cash(Money(100000))],
      );
      expect(ok.negativeStock, isEmpty);
    });

    test(
      'stok minus diizinkan (bawaan): nota tersimpan + peringatan',
      () async {
        await openSession();
        final r = await checkoutSale(
          store,
          scope,
          staffId: owner(),
          lines: [line(teh, 3)],
          payments: const [SalePaymentRequest.cash(Money(100000))],
        );
        expect(r.negativeStock.single.onHand, Qty.units(-1));
      },
    );
  });

  group('bill F&B', () {
    late DiningTable m1;

    setUp(() async {
      [m1] = await createDiningTables(
        store,
        scope,
        staffId: owner(),
        drafts: const [DiningTableDraft(name: 'M1')],
      );
    });

    Future<OpenBill> bill(List<SaleLineRequest> lines) async {
      var b = await openTableBill(
        store,
        scope,
        staffId: owner(),
        tableId: m1.id,
        guests: 2,
      );
      for (final l in lines) {
        b = await addBillItem(
          store,
          scope,
          staffId: owner(),
          billId: b.id,
          line: l,
        );
      }
      return b;
    }

    test('pajak termasuk harga + pembulatan dibekukan di nota', () async {
      await saveFnbRates(
        store,
        scope,
        staffId: owner(),
        rates: const FnbRates(
          service: BasisPoints(500),
          tax: BasisPoints(1000),
          taxInclusive: true,
        ),
      );
      expect((await loadFnbRates(store.session, scope)).taxInclusive, isTrue);
      await rules(const SalesRules(rounding: TotalRounding.nearest500));
      await openSession();
      // 30.050 + service 1.503 = 31.553; PB1 termasuk 2.868; → 31.500.
      final b = await bill([line(jasa)]);
      expect(b.charges.taxInclusive, isTrue);
      expect(b.charges.tax, const Money(2868));
      expect(b.charges.rounding, const Money(-53));
      expect(b.charges.total, const Money(31500));
      final r = await payOpenBill(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        payments: const [SalePaymentRequest.cash(Money(31500))],
      );
      expect(r.sale.taxInclusive, isTrue);
      expect(r.sale.taxAmount, 2868);
      expect(r.sale.roundingAmount, -53);
      expect(r.sale.total, 31500);
    });

    test('stok minus dimatikan: item melebihi stok ditolak', () async {
      await rules(const SalesRules(allowNegativeStock: false));
      final b = await bill([line(teh, 2)]);
      await expectLater(
        addBillItem(
          store,
          scope,
          staffId: owner(),
          billId: b.id,
          line: line(teh),
        ),
        throwsA(isA<SaleStockShort>()),
      );
      // Menaikkan jumlah baris juga dicek; menurunkan tetap boleh.
      final item = b.items.single;
      await expectLater(
        setBillItemQuantity(
          store,
          scope,
          staffId: owner(),
          itemId: item.id,
          quantity: Qty.units(3),
        ),
        throwsA(isA<SaleStockShort>()),
      );
      final lower = await setBillItemQuantity(
        store,
        scope,
        staffId: owner(),
        itemId: item.id,
        quantity: Qty.units(1),
      );
      expect(lower.items.single.quantityMilli, 1000);
    });
  });

  group('profil toko dan cabang', () {
    test('ubah nama usaha', () async {
      final t = await saveStoreProfile(
        store,
        scope,
        staffId: owner(),
        name: '  Toko Bu Ani ',
      );
      expect(t.name, 'Toko Bu Ani');
      expect((await loadStoreContext(store))!.tenant.name, 'Toko Bu Ani');
      await expectLater(
        saveStoreProfile(store, scope, staffId: owner(), name: ' '),
        throwsA(
          isA<StoreProfileInvalid>().having(
            (e) => e.name,
            'name',
            ProfileIssue.required,
          ),
        ),
      );
    });

    test('ubah cabang: alamat dan telepon jadi header struk bawaan', () async {
      final o = await saveOutletProfile(
        store,
        scope,
        staffId: owner(),
        name: 'Cabang Melati',
        address: ' Jl. Melati 1 ',
        phone: '0812-3456',
      );
      expect(o.name, 'Cabang Melati');
      expect(o.address, 'Jl. Melati 1');
      expect(o.code, 'PST');
      expect((await loadStoreContext(store))!.outlet.name, 'Cabang Melati');
      final receipt = await loadReceiptConfig(store, scope);
      expect(receipt.defaultHeader, 'Jl. Melati 1\n0812-3456');

      final cleared = await saveOutletProfile(
        store,
        scope,
        staffId: owner(),
        name: 'Cabang Melati',
        address: '',
        phone: '',
      );
      expect(cleared.address, isNull);
      expect(cleared.phone, isNull);

      await expectLater(
        saveOutletProfile(
          store,
          scope,
          staffId: owner(),
          name: 'X',
          address: '',
          phone: 'abc',
        ),
        throwsA(
          isA<StoreProfileInvalid>().having(
            (e) => e.outlet[OutletProfileField.phone],
            'phone',
            ProfileIssue.invalidPhone,
          ),
        ),
      );
    });
  });
}
