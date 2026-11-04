import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-04d: pelanggan di nota non-kredit dan nota tersimpan (parkir).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CatalogProduct minyak;
  late Customer budi;

  CatalogVariant v(CatalogProduct p) => p.variants.single;
  UuidValue owner() => ctx.owner.id;

  setUp(() async {
    // 2026-11-03 01.12 UTC = 08.12 WIB.
    now = DateTime.utc(2026, 11, 3, 1, 12);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Minyak Goreng',
        baseUnit: 'botol',
        variants: [
          VariantDraft(
            name: '2 L',
            costPrice: Money(32500),
            sellPrice: Money(36000),
            openingStock: Qty(24000),
            units: [
              UnitDraft(
                name: 'Dus',
                factor: Qty(6000),
                sellPrice: Money(210000),
              ),
            ],
          ),
        ],
      ),
    );
    minyak = (await loadProduct(store, scope, id))!;
    budi = await saveCustomer(
      store,
      scope,
      staffId: owner(),
      input: const CustomerInput(name: 'Pak Budi', phone: '081322221010'),
    );
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: const Money(100000),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  List<SaleLineRequest> lines() => [
    SaleLineRequest(variantId: v(minyak).id, quantity: Qty.units(2)),
    SaleLineRequest(
      variantId: v(minyak).id,
      productUnitId: v(minyak).units.single.id,
      quantity: Qty.one,
      discount: const ManualDiscount.amount(Money(10000)),
    ),
  ];

  Future<Qty> stock() => stockOnHand(store, scope, variantId: v(minyak).id);

  group('pelanggan di nota non-kredit', () {
    test('tersimpan di nota tunai tanpa menjadi piutang', () async {
      final result = await checkoutSale(
        store,
        scope,
        staffId: owner(),
        lines: lines().take(1).toList(),
        payments: const [SalePaymentRequest.cash(Money(100000))],
        customerId: budi.id,
      );
      expect(result.sale.customerId, budi.id);
      expect(result.sale.customerName, 'Pak Budi');
      expect(result.sale.paidAmount, result.sale.total);
      expect(result.sale.dueOn, isNull);
      expect(
        await customerOutstanding(store.session, scope.tenantId, budi.id),
        Money.zero,
      );
    });

    test('pelanggan yang dihapus atau tidak dikenal ditolak', () async {
      await expectLater(
        checkoutSale(
          store,
          scope,
          staffId: owner(),
          lines: lines().take(1).toList(),
          payments: const [SalePaymentRequest.cash(Money(100000))],
          customerId: UuidValue.fromString(newId()),
        ),
        throwsA(isA<CustomerNotFound>()),
      );
      expect(await stock(), Qty.units(24));
    });
  });

  group('nota tersimpan', () {
    Future<Sale> park({
      UuidValue? customerId,
      String? note,
      UuidValue? replaceId,
      ManualDiscount? discount,
    }) => parkSale(
      store,
      scope,
      staffId: owner(),
      lines: lines(),
      discount: discount,
      customerId: customerId,
      note: note,
      replaceId: replaceId,
    );

    test('disimpan open retail tanpa gerak stok dan pembayaran', () async {
      final sale = await park(
        customerId: budi.id,
        discount: const ManualDiscount.percent(BasisPoints(500)),
      );
      expect(sale.status, SaleStatus.open);
      expect(sale.orderType, OrderType.retail);
      expect(sale.number, startsWith('OB-PST-K01-261103-'));
      expect(sale.billNumber, sale.number);
      expect(sale.customerId, budi.id);
      expect(sale.customerName, 'Pak Budi');
      expect(sale.cashSessionId, isNull);
      // 2 × 36.000 + (210.000 − 10.000) = 272.000; diskon 5% = 13.600.
      expect(sale.lineDiscountAmount, 10000);
      expect(sale.discountBp, 500);
      expect(sale.discountAmount, 13600);
      expect(sale.total, 258400);
      expect(sale.itemCount, 2);
      expect(await stock(), Qty.units(24));
      expect(await Payment.db.count(store.session), 0);
      // Bukan open bill F&B.
      final dining = await diningOverview(store, scope);
      expect(dining.bills, isEmpty);
    });

    test('daftar dan muat ulang baris', () async {
      await park(note: 'Meja depan');
      now = now.add(const Duration(minutes: 30));
      final second = await park(customerId: budi.id);
      final rows = await listParkedSales(store.session, scope);
      expect(rows.map((r) => r.title), ['Pak Budi', 'Meja depan']);
      expect(rows.first.staffName, ctx.owner.name);
      expect(rows.first.itemCount, 2);
      expect(rows.first.total, const Money(272000));
      expect(rows.first.savedAt, now);

      final loaded = await loadParkedSale(store.session, scope, second.id);
      expect(loaded.customerId, budi.id);
      expect(loaded.customerName, 'Pak Budi');
      expect(loaded.note, isNull);
      expect(loaded.discount, isNull);
      expect(
        loaded.lines
            .map((l) => (l.productUnitId, l.quantity, l.discount))
            .toList(),
        [
          (null, Qty.units(2), null),
          (
            v(minyak).units.single.id,
            Qty.one,
            const ManualDiscount.amount(Money(10000)),
          ),
        ],
      );
    });

    test('simpan ulang menggantikan nota lama', () async {
      final first = await park(note: 'A');
      final again = await park(note: 'B', replaceId: first.id);
      final rows = await listParkedSales(store.session, scope);
      expect(rows.map((r) => r.id), [again.id]);
      expect(rows.single.title, 'B');
    });

    test('checkout dari nota tersimpan menghapusnya sekali', () async {
      final parked = await park(customerId: budi.id);
      final result = await checkoutSale(
        store,
        scope,
        staffId: owner(),
        lines: lines(),
        payments: const [SalePaymentRequest.cash(Money(300000))],
        customerId: budi.id,
        parkedSaleId: parked.id,
      );
      expect(result.sale.status, SaleStatus.completed);
      expect(await listParkedSales(store.session, scope), isEmpty);
      expect(await stock(), Qty.units(16));
      // Nota tersimpan yang sudah dibayar tidak bisa dibayar lagi.
      await expectLater(
        checkoutSale(
          store,
          scope,
          staffId: owner(),
          lines: lines(),
          payments: const [SalePaymentRequest.cash(Money(300000))],
          parkedSaleId: parked.id,
        ),
        throwsA(isA<ParkedSaleNotFound>()),
      );
      expect(await stock(), Qty.units(16));
    });

    test('hapus nota tersimpan', () async {
      final parked = await park();
      await deleteParkedSale(store, scope, staffId: owner(), id: parked.id);
      expect(await listParkedSales(store.session, scope), isEmpty);
      await expectLater(
        loadParkedSale(store.session, scope, parked.id),
        throwsA(isA<ParkedSaleNotFound>()),
      );
      // Barisnya ikut terhapus (tidak tersinkron sebagai baris yatim).
      final items = await SaleItem.db.find(
        store.session,
        where: (i) => i.saleId.equals(parked.id),
      );
      expect(items, isNotEmpty);
      expect(items.every((i) => i.deletedAt != null), isTrue);
    });

    test('keranjang kosong dan open bill F&B ditolak', () async {
      await expectLater(
        parkSale(store, scope, staffId: owner(), lines: const []),
        throwsA(isA<SaleEmpty>()),
      );
      final bill = await openTakeAway(store, scope, staffId: owner());
      await expectLater(
        loadParkedSale(store.session, scope, bill.sale.id),
        throwsA(isA<ParkedSaleNotFound>()),
      );
    });
  });
}
