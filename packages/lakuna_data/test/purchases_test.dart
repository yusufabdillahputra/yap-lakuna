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
  late CatalogProduct gula;
  late StockLocation gudang;

  CatalogVariant v(CatalogProduct p) => p.variants.single;
  CatalogUnit dus() => v(minyak).units.single;
  final today = DateTime(2026, 11, 3);

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: draft,
    );
    return (await loadProduct(store, scope, id))!;
  }

  Future<StockLevel?> level(CatalogProduct p) => StockLevel.db.findFirstRow(
    store.session,
    where: (l) =>
        l.stockLocationId.equals(gudang.id) & l.variantId.equals(v(p).id),
  );

  setUp(() async {
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    minyak = await product(
      const ProductDraft(
        name: 'Minyak Goreng 2 L',
        baseUnit: 'btl',
        variants: [
          VariantDraft(
            sku: 'MYK-2L',
            costPrice: Money(30000),
            sellPrice: Money(36000),
            openingStock: Qty(10000),
            units: [UnitDraft(name: 'dus', factor: Qty(6000))],
          ),
        ],
      ),
    );
    gula = await product(
      const ProductDraft(
        name: 'Gula Pasir 1 kg',
        baseUnit: 'kg',
        variants: [
          VariantDraft(costPrice: Money(14800), sellPrice: Money(17500)),
        ],
      ),
    );
    gudang = await defaultStockLocation(store, scope);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  /// 4 dus minyak × 185.000 + 10 kg gula × 14.500, ongkir 4.000.
  PurchaseRequest request({
    UuidValue? id,
    String? supplier = 'CV Sumber Pangan',
    Money paid = Money.zero,
    FundingSource? funding,
    DateTime? dueOn,
    int dusMilli = 4000,
  }) => PurchaseRequest(
    id: id,
    newSupplierName: supplier,
    invoiceNo: 'SP/XI/0457',
    purchasedOn: today,
    locationId: gudang.id,
    lines: [
      PurchaseLineRequest(
        variantId: v(minyak).id,
        productUnitId: dus().id,
        quantity: Qty(dusMilli),
        unitPrice: const Money(185000),
      ),
      PurchaseLineRequest(
        variantId: v(gula).id,
        quantity: Qty.units(10),
        unitPrice: const Money(14500),
      ),
    ],
    shipping: const Money(4000),
    paid: paid,
    funding: funding,
    dueOn: dueOn,
  );

  test('draf: nomor PB, tanpa stok; ubah lalu hapus', () async {
    expect(
      await previewPurchaseNumber(store, scope, now: now),
      'PB-PST-K01-261103-0001',
    );
    final draft = await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(),
    );
    expect(draft.number, 'PB-PST-K01-261103-0001');
    expect(draft.status, PurchaseStatus.draft);
    expect(draft.total, 740000 + 145000 + 4000);
    expect((await level(minyak))!.quantityMilli, 10000);
    expect(await level(gula), isNull);

    final rows = await listPurchases(store, scope);
    expect(rows.single.isDraft, isTrue);
    expect(rows.single.debt, Money.zero);
    expect(rows.single.supplierName, 'CV Sumber Pangan');

    final edited = await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(id: draft.id, dusMilli: 2000),
    );
    expect(edited.number, draft.number);
    final detail = await loadPurchaseDetail(store, scope, draft.id);
    expect(detail.items, hasLength(2));
    expect(detail.items.first.quantityMilli, 2000);
    expect(detail.items.first.unitName, 'dus');
    expect(detail.items.first.factorMilli, 6000);

    await deletePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      purchaseId: draft.id,
    );
    expect(await listPurchases(store, scope), isEmpty);
    await expectLater(
      () => loadPurchaseDetail(store, scope, draft.id),
      throwsA(isA<PurchaseNotFound>()),
    );
  });

  test('terima: stok, HPP rata-rata, cost price, hutang', () async {
    await expectLater(
      receivePurchase(store, scope, staffId: ctx.owner.id, request: request()),
      throwsA(
        isA<PurchaseInvalid>().having(
          (e) => e.issues.map((i) => i.field),
          'fields',
          [PurchaseField.dueOn],
        ),
      ),
    );
    final p = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(
        paid: const Money(500000),
        funding: FundingSource.storeCash,
        dueOn: DateTime(2026, 11, 16),
      ),
    );
    expect(p.status, PurchaseStatus.received);
    expect(p.receivedAt, isNotNull);
    expect(p.dueOn, DateTime.utc(2026, 11, 16));

    // Minyak: 740.000 + ongkir 3.345 → 743.345 / 24 btl = 30.973.
    final detail = await loadPurchaseDetail(store, scope, p.id);
    final item = detail.items.first;
    expect(item.landedUnitCost, 30973);
    expect(item.avgCostBefore, 30000);
    // (30.000 × 10 + 30.973 × 24) / 34 = 30.686,8 → 30.687.
    expect(item.avgCostAfter, 30687);
    // Harga jual saat diterima, dasar saran harga (tidak berubah walau
    // harga jual diterapkan belakangan).
    expect(item.sellPriceBefore, 36000);
    final stock = (await level(minyak))!;
    expect(stock.quantityMilli, 34000);
    expect(stock.avgCost, 30687);
    expect((await level(gula))!.quantityMilli, 10000);
    expect(detail.items.last.avgCostBefore, isNull);
    final fresh = (await loadProduct(store, scope, minyak.id))!;
    expect(v(fresh).costPrice, const Money(30973));

    expect(detail.debt, const Money(889000 - 500000));
    expect(detail.sellPrices[v(minyak).id], const Money(36000));
    expect(detail.baseUnits[v(minyak).id], 'btl');
    expect(detail.staffName, 'Yusuf');
    expect(detail.deviceCode, 'K01');

    // Sudah diterima: tidak bisa diubah atau dihapus.
    await expectLater(
      savePurchaseDraft(
        store,
        scope,
        staffId: ctx.owner.id,
        request: request(id: p.id),
      ),
      throwsA(isA<PurchaseNotEditable>()),
    );
    await expectLater(
      deletePurchaseDraft(
        store,
        scope,
        staffId: ctx.owner.id,
        purchaseId: p.id,
      ),
      throwsA(isA<PurchaseNotEditable>()),
    );

    // Kartu stok menampilkan nomor PB dan staf.
    final card = await stockCard(store, scope, variantId: v(minyak).id);
    expect(card.entries.last.documentNumber, p.number);
    expect(card.entries.last.staffName, 'Yusuf');
  });

  test('terima draf mempertahankan nomor; lunas tanpa supplier', () async {
    final draft = await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(supplier: null),
    );
    final p = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(
        id: draft.id,
        supplier: null,
        paid: const Money(889000),
        funding: FundingSource.bank,
      ),
    );
    expect(p.id, draft.id);
    expect(p.number, draft.number);
    expect(p.supplierId, isNull);
    final rows = await listPurchases(store, scope);
    expect(rows.single.debt, Money.zero);
    expect(rows.single.isDraft, isFalse);
  });

  test('bayar dari laci butuh sesi terbuka dan menulis kas keluar', () async {
    final req = request(
      paid: const Money(889000),
      funding: FundingSource.drawer,
    );
    await expectLater(
      receivePurchase(store, scope, staffId: ctx.owner.id, request: req),
      throwsA(isA<CashSessionNotOpen>()),
    );
    expect(await listPurchases(store, scope), isEmpty);
    final session = await openCashSession(
      store,
      cashScope,
      staffId: ctx.owner.id,
      openingCash: const Money(1000000),
    );
    final p = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: req,
    );
    expect(p.cashSessionId, session.id);
    final moves = await listCashMovements(store, cashScope, session.id);
    expect(moves.single.direction, CashDirection.outflow);
    expect(moves.single.amount, 889000);
    expect(moves.single.note, p.number);
    expect(moves.single.source, purchaseCashSource);
  });

  test('supplier baru dipakai ulang tanpa beda huruf besar/kecil', () async {
    await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(),
    );
    await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(supplier: 'cv sumber pangan '),
    );
    final suppliers = await listSuppliers(store, scope);
    expect(suppliers.map((s) => s.name), ['CV Sumber Pangan']);
  });

  test(
    'supplier terakhir per barang dari pembelian diterima (F1-08d)',
    () async {
      final first = await receivePurchase(
        store,
        scope,
        staffId: ctx.owner.id,
        request: request(
          paid: const Money(889000),
          funding: FundingSource.bank,
        ),
      );
      now = now.add(const Duration(days: 1));
      final second = await receivePurchase(
        store,
        scope,
        staffId: ctx.owner.id,
        request: PurchaseRequest(
          newSupplierName: 'Toko Gula Jaya',
          purchasedOn: today,
          locationId: gudang.id,
          lines: [
            PurchaseLineRequest(
              variantId: v(gula).id,
              quantity: Qty.units(5),
              unitPrice: const Money(14000),
            ),
          ],
          paid: const Money(70000),
          funding: FundingSource.bank,
        ),
      );
      // Draf lebih baru tidak dihitung.
      now = now.add(const Duration(days: 1));
      await savePurchaseDraft(
        store,
        scope,
        staffId: ctx.owner.id,
        request: request(supplier: 'CV Draf'),
      );

      var last = await lastSuppliersOf(store, scope, [
        v(minyak).id,
        v(gula).id,
      ]);
      expect(last[v(minyak).id]?.supplierId, first.supplierId);
      expect(last[v(minyak).id]?.at, first.receivedAt);
      expect(last[v(gula).id]?.supplierId, second.supplierId);
      expect(await lastSuppliersOf(store, scope, const []), isEmpty);

      // Supplier terhapus diabaikan: kembali ke pembelian sebelumnya.
      await deleteSupplier(
        store,
        scope,
        staffId: ctx.owner.id,
        supplierId: second.supplierId!,
      );
      last = await lastSuppliersOf(store, scope, [v(gula).id]);
      expect(last[v(gula).id]?.supplierId, first.supplierId);
    },
  );

  test(
    'supplier terakhir mengabaikan baris yang diretur penuh (F1-08m)',
    () async {
      final first = await receivePurchase(
        store,
        scope,
        staffId: ctx.owner.id,
        request: request(dueOn: DateTime(2026, 11, 16)),
      );
      now = now.add(const Duration(days: 1));
      final second = await receivePurchase(
        store,
        scope,
        staffId: ctx.owner.id,
        request: PurchaseRequest(
          newSupplierName: 'Toko Gula Jaya',
          purchasedOn: today,
          locationId: gudang.id,
          lines: [
            PurchaseLineRequest(
              variantId: v(gula).id,
              quantity: Qty.units(5),
              unitPrice: const Money(14000),
            ),
          ],
          dueOn: DateTime(2026, 11, 16),
        ),
      );
      final gulaItem = (await loadPurchaseDetail(
        store,
        scope,
        second.id,
      )).items.single;
      Future<void> retur(Purchase p, UuidValue itemId, Qty qty) =>
          returnPurchase(
            store,
            scope,
            staffId: ctx.owner.id,
            purchaseId: p.id,
            lines: [PurchaseReturnLine(purchaseItemId: itemId, quantity: qty)],
          );

      // Retur sebagian: pembelian tetap yang terakhir.
      await retur(second, gulaItem.id, Qty.units(2));
      var last = await lastSuppliersOf(store, scope, [v(gula).id]);
      expect(last[v(gula).id]?.supplierId, second.supplierId);

      // Sisanya ikut diretur: kembali ke pembelian sebelumnya.
      await retur(second, gulaItem.id, Qty.units(3));
      last = await lastSuppliersOf(store, scope, [v(gula).id]);
      expect(last[v(gula).id]?.supplierId, first.supplierId);
      expect(last[v(gula).id]?.at, first.receivedAt);

      // Satu-satunya pembelian minyak diretur penuh: tanpa riwayat.
      final minyakItem = (await loadPurchaseDetail(
        store,
        scope,
        first.id,
      )).items.firstWhere((i) => i.variantId == v(minyak).id);
      await retur(first, minyakItem.id, Qty.units(4));
      last = await lastSuppliersOf(store, scope, [v(minyak).id, v(gula).id]);
      expect(last.containsKey(v(minyak).id), isFalse);
      expect(last[v(gula).id]?.supplierId, first.supplierId);
    },
  );

  test('baris lain barang yang sama belum diretur: pembelian tetap dihitung (F1-08m)', () async {
    final p = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        newSupplierName: 'CV Minyak',
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(minyak).id,
            productUnitId: dus().id,
            quantity: Qty.one,
            unitPrice: const Money(186000),
          ),
          PurchaseLineRequest(
            variantId: v(minyak).id,
            quantity: Qty.units(2),
            unitPrice: const Money(31500),
          ),
        ],
        dueOn: DateTime(2026, 11, 16),
      ),
    );
    final dusItem = (await loadPurchaseDetail(
      store,
      scope,
      p.id,
    )).items.firstWhere((i) => i.productUnitId == dus().id);
    await returnPurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      purchaseId: p.id,
      lines: [
        PurchaseReturnLine(purchaseItemId: dusItem.id, quantity: Qty.one),
      ],
    );
    final last = await lastSuppliersOf(store, scope, [v(minyak).id]);
    expect(last[v(minyak).id]?.supplierId, p.supplierId);
  });

  test('harga beli terakhir per satuan dasar (F1-08e)', () async {
    expect(await lastPurchasePricesOf(store, scope, const []), isEmpty);
    expect(await lastPurchasePricesOf(store, scope, [v(gula).id]), isEmpty);
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(paid: const Money(889000), funding: FundingSource.bank),
    );
    // Pembelian lebih baru tanpa supplier: ikut dihitung.
    now = now.add(const Duration(days: 1));
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(gula).id,
            quantity: Qty.units(5),
            unitPrice: const Money(14000),
          ),
          PurchaseLineRequest(
            variantId: v(minyak).id,
            productUnitId: dus().id,
            quantity: Qty.one,
            unitPrice: const Money(186000),
          ),
          PurchaseLineRequest(
            variantId: v(minyak).id,
            quantity: Qty.units(2),
            unitPrice: const Money(31500),
          ),
        ],
        paid: const Money(319000),
        funding: FundingSource.bank,
      ),
    );
    // Draf lebih baru tidak dihitung.
    now = now.add(const Duration(days: 1));
    await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(supplier: 'CV Draf'),
    );

    var prices = await lastPurchasePricesOf(store, scope, [
      v(minyak).id,
      v(gula).id,
    ]);
    expect(prices[v(gula).id], const Money(14000));
    // Varian muncul dua kali: baris terakhir (per botol) dipakai.
    expect(prices[v(minyak).id], const Money(31500));

    // Pembelian terbaru hanya per dus: Rp 185.000 / 6 = 30.833.
    now = now.add(const Duration(days: 1));
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(paid: const Money(889000), funding: FundingSource.bank),
    );
    prices = await lastPurchasePricesOf(store, scope, [v(minyak).id]);
    expect(prices[v(minyak).id], const Money(30833));

    // Baris bonus Rp 0 di pembelian terbaru dilewati: harga sebelumnya.
    now = now.add(const Duration(days: 1));
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(minyak).id,
            quantity: Qty.one,
            unitPrice: Money.zero,
          ),
        ],
      ),
    );
    prices = await lastPurchasePricesOf(store, scope, [v(minyak).id]);
    expect(prices[v(minyak).id], const Money(30833));
    expect(prices.containsKey(v(gula).id), isFalse);
  });

  test('harga beli terakhir dari supplier tertentu (F1-12g)', () async {
    PurchaseRequest gulaFrom(String? supplier, int price) => PurchaseRequest(
      newSupplierName: supplier,
      purchasedOn: today,
      locationId: gudang.id,
      lines: [
        PurchaseLineRequest(
          variantId: v(gula).id,
          quantity: Qty.units(5),
          unitPrice: Money(price),
        ),
      ],
      paid: Money(price * 5),
      funding: FundingSource.bank,
    );
    final a = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: gulaFrom('CV Sumber Pangan', 14500),
    );
    now = now.add(const Duration(days: 1));
    final b = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: gulaFrom('Toko Makmur', 15200),
    );
    // Pembelian terbaru tanpa supplier.
    now = now.add(const Duration(days: 1));
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: gulaFrom(null, 15000),
    );
    final sumber = a.supplierId!;
    final makmur = b.supplierId!;
    expect(sumber, isNot(makmur));

    Future<Map<UuidValue, Money>> of(UuidValue? supplier) =>
        lastPurchasePricesOf(store, scope, [
          v(gula).id,
          v(minyak).id,
        ], supplierId: supplier);
    expect(await of(null), {v(gula).id: const Money(15000)});
    expect(await of(sumber), {v(gula).id: const Money(14500)});
    expect(await of(makmur), {v(gula).id: const Money(15200)});

    // Draf dari supplier itu tidak dihitung.
    now = now.add(const Duration(days: 1));
    await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        supplierId: sumber,
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(gula).id,
            quantity: Qty.one,
            unitPrice: const Money(99000),
          ),
        ],
      ),
    );
    expect(await of(sumber), {v(gula).id: const Money(14500)});

    // Supplier tanpa riwayat barang ini: kosong (form memakai harga semua
    // supplier).
    final other = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        newSupplierName: 'UD Lain',
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(minyak).id,
            quantity: Qty.units(2),
            unitPrice: const Money(31000),
          ),
        ],
        paid: const Money(62000),
        funding: FundingSource.bank,
      ),
    );
    expect(await of(other.supplierId), {v(minyak).id: const Money(31000)});
  });

  test('harga beli terakhir per satuan konversi (F1-12h)', () async {
    Future<Map<UuidValue, Map<UuidValue, Money>>> of({UuidValue? supplier}) =>
        lastPurchaseUnitPricesOf(store, scope, [
          v(minyak).id,
          v(gula).id,
        ], supplierId: supplier);
    expect(await lastPurchaseUnitPricesOf(store, scope, const []), isEmpty);
    expect(await of(), isEmpty);
    // Dus Rp 185.000 dari CV Sumber Pangan; gula hanya satuan dasar.
    final first = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(paid: const Money(889000), funding: FundingSource.bank),
    );
    expect(await of(), {
      v(minyak).id: {dus().id: const Money(185000)},
    });

    // Pembelian lebih baru: dus Rp 183.000 (tanpa supplier), lalu botol.
    // Harga dus tetap apa adanya, bukan botol × isi.
    now = now.add(const Duration(days: 1));
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(minyak).id,
            productUnitId: dus().id,
            quantity: Qty.one,
            unitPrice: const Money(183000),
          ),
          PurchaseLineRequest(
            variantId: v(minyak).id,
            quantity: Qty.units(2),
            unitPrice: const Money(31500),
          ),
        ],
        paid: const Money(246000),
        funding: FundingSource.bank,
      ),
    );
    // Baris bonus dus Rp 0 dan draf yang lebih baru dilewati.
    now = now.add(const Duration(days: 1));
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(minyak).id,
            productUnitId: dus().id,
            quantity: Qty.one,
            unitPrice: Money.zero,
          ),
        ],
      ),
    );
    await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        newSupplierName: 'CV Draf',
        purchasedOn: today.add(const Duration(days: 30)),
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(minyak).id,
            productUnitId: dus().id,
            quantity: Qty.one,
            unitPrice: const Money(199000),
          ),
        ],
      ),
    );
    expect(await of(), {
      v(minyak).id: {dus().id: const Money(183000)},
    });
    // Supplier tertentu: hanya pembelian darinya.
    expect(await of(supplier: first.supplierId), {
      v(minyak).id: {dus().id: const Money(185000)},
    });

    // Isi dus diubah jadi 12 setelah pembelian: harga dus lama tidak
    // dipakai lagi (harga per satuan dasar tetap dari baris itu).
    final row = await ProductUnit.db.findById(store.session, dus().id);
    await ProductUnit.db.updateRow(
      store.session,
      row!.copyWith(factorMilli: 12000),
    );
    expect(await of(), isEmpty);
    final both = await lastPurchasePriceSetOf(store, scope, [v(minyak).id]);
    expect(both.perBase, {v(minyak).id: const Money(31500)});
    expect(both.perUnit, isEmpty);
  });

  test('draf pembelian yang memuat barang stok minimum (F1-08g)', () async {
    expect(await restockDraftsOf(store, scope, gudang.id, const []), isEmpty);
    expect(
      await restockDraftsOf(store, scope, gudang.id, [v(gula).id]),
      isEmpty,
    );
    // Draf berisi minyak + gula.
    final both = await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(),
    );
    // Draf lebih baru berisi gula saja.
    now = now.add(const Duration(hours: 1));
    final gulaOnly = await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        purchasedOn: today,
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(gula).id,
            quantity: Qty.units(3),
            unitPrice: const Money(14500),
          ),
        ],
      ),
    );
    // Pembelian diterima dan draf terhapus tidak dihitung.
    await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(paid: const Money(889000), funding: FundingSource.bank),
    );
    final gone = await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(),
    );
    await deletePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      purchaseId: gone.id,
    );

    // Draf ke lokasi lain tidak ikut: barang itu memang belum dipesan untuk
    // lokasi ini.
    final rak = await createStockLocation(
      store,
      scope,
      staffId: ctx.owner.id,
      name: 'Rak Belakang',
    );
    expect(await restockDraftsOf(store, scope, rak.id, [v(gula).id]), isEmpty);

    var drafts = await restockDraftsOf(store, scope, gudang.id, [
      v(minyak).id,
      v(gula).id,
    ]);
    // Paling banyak barang yang sama dulu, lalu yang lebih baru.
    expect([for (final d in drafts) d.purchaseId], [both.id, gulaOnly.id]);
    expect(drafts.first.number, both.number);
    expect(drafts.first.matched, 2);
    expect(drafts.first.variantIds, {v(minyak).id, v(gula).id});
    expect(drafts.last.variantIds, {v(gula).id});
    // Jumlah per draf dalam satuan dasar: 4 dus isi 6 = 24 (F1-08l).
    expect(drafts.first.quantities, {
      v(minyak).id: Qty.units(24),
      v(gula).id: Qty.units(10),
    });
    expect(drafts.last.quantities, {v(gula).id: Qty.units(3)});
    drafts = await restockDraftsOf(store, scope, gudang.id, [v(gula).id]);
    // Sama banyak: draf yang lebih baru dulu.
    expect([for (final d in drafts) d.purchaseId], [gulaOnly.id, both.id]);
    expect(
      await restockDraftsOf(store, scope, gudang.id, [v(minyak).id]),
      hasLength(1),
    );

    // Dua baris barang yang sama (dus dan satuan dasar) dijumlah dalam
    // satuan dasar: 1 dus isi 6 + 3 = 9 (F1-08l).
    await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: PurchaseRequest(
        purchasedOn: today,
        locationId: rak.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(minyak).id,
            productUnitId: dus().id,
            quantity: Qty.one,
            unitPrice: const Money(185000),
          ),
          PurchaseLineRequest(
            variantId: v(minyak).id,
            quantity: Qty.units(3),
            unitPrice: const Money(31000),
          ),
        ],
      ),
    );
    final mixed = await restockDraftsOf(store, scope, rak.id, [v(minyak).id]);
    expect(mixed.single.quantities, {v(minyak).id: Qty.units(9)});
  });

  group('retur pembelian', () {
    late Purchase p;
    late PurchaseDetail d;

    setUp(() async {
      p = await receivePurchase(
        store,
        scope,
        staffId: ctx.owner.id,
        request: request(
          paid: const Money(700000),
          funding: FundingSource.storeCash,
          dueOn: DateTime(2026, 11, 16),
        ),
      );
      d = await loadPurchaseDetail(store, scope, p.id);
    });

    test('mengurangi stok dan hutang, lalu kelebihan ke laci', () async {
      final minyakItem = d.items.first;
      // Hutang 189.000. Retur 1 dus = 743.345 / 4 = 185.836.
      final first = await returnPurchase(
        store,
        scope,
        staffId: ctx.owner.id,
        purchaseId: p.id,
        lines: [
          PurchaseReturnLine(purchaseItemId: minyakItem.id, quantity: Qty.one),
        ],
      );
      expect(first.number, 'RB-PST-K01-261103-0001');
      expect(first.amount, 185836);
      expect(first.debtReduction, 185836);
      expect(first.refundAmount, 0);
      expect((await level(minyak))!.quantityMilli, 34000 - 6000);
      // 6 btl keluar pada HPP mendarat 30.973, bukan rata-rata:
      // (30.687 × 34 − 30.973 × 6) / 28 = 30.625,7 → 30.626.
      expect((await level(minyak))!.avgCost, 30626);

      d = await loadPurchaseDetail(store, scope, p.id);
      expect(d.debt, const Money(189000 - 185836));
      expect(d.remainingMilli(d.items.first), 3000);

      // Retur kedua melebihi sisa hutang: wajib pilih sumber uang kembali.
      final lines = [
        PurchaseReturnLine(purchaseItemId: minyakItem.id, quantity: Qty.one),
      ];
      await expectLater(
        returnPurchase(
          store,
          scope,
          staffId: ctx.owner.id,
          purchaseId: p.id,
          lines: lines,
        ),
        throwsA(
          isA<PurchaseReturnInvalid>().having(
            (e) => e.error,
            'error',
            PurchaseReturnError.refundSource,
          ),
        ),
      );
      await expectLater(
        returnPurchase(
          store,
          scope,
          staffId: ctx.owner.id,
          purchaseId: p.id,
          lines: lines,
          refundSource: FundingSource.drawer,
        ),
        throwsA(isA<CashSessionNotOpen>()),
      );
      final session = await openCashSession(
        store,
        cashScope,
        staffId: ctx.owner.id,
        openingCash: const Money(100000),
      );
      final second = await returnPurchase(
        store,
        scope,
        staffId: ctx.owner.id,
        purchaseId: p.id,
        lines: lines,
        refundSource: FundingSource.drawer,
      );
      expect(second.debtReduction, 3164);
      expect(second.refundAmount, 185836 - 3164);
      final moves = await listCashMovements(store, cashScope, session.id);
      expect(moves.single.direction, CashDirection.inflow);
      expect(moves.single.amount, 185836 - 3164);
      d = await loadPurchaseDetail(store, scope, p.id);
      expect(d.debt, Money.zero);
      expect(d.returns, hasLength(2));

      final rows = await listPurchaseReturns(store, scope, query: 'sumber');
      expect(rows.map((r) => r.purchaseReturn.number), [
        second.number,
        first.number,
      ]);
      expect(rows.first.purchaseNumber, p.number);

      final card = await stockCard(store, scope, variantId: v(minyak).id);
      expect(card.entries.last.documentNumber, second.number);
    });

    test('batas sisa dan stok di lokasi', () async {
      final item = d.items.first;
      await expectLater(
        returnPurchase(
          store,
          scope,
          staffId: ctx.owner.id,
          purchaseId: p.id,
          lines: [
            PurchaseReturnLine(purchaseItemId: item.id, quantity: Qty.units(5)),
          ],
        ),
        throwsA(
          isA<PurchaseReturnInvalid>().having(
            (e) => e.error,
            'error',
            PurchaseReturnError.quantity,
          ),
        ),
      );
      // Sisa stok gula hanya 2 kg dari 10 kg yang dibeli.
      await store.write(actor: ctx.owner.id, (w) async {
        await recordStockMovement(
          w,
          scope,
          locationId: gudang.id,
          variantId: v(gula).id,
          quantity: Qty.units(-8),
          unitCost: const Money(14500),
          sourceType: StockSourceType.adjustment,
        );
      });
      await expectLater(
        returnPurchase(
          store,
          scope,
          staffId: ctx.owner.id,
          purchaseId: p.id,
          lines: [
            PurchaseReturnLine(
              purchaseItemId: d.items.last.id,
              quantity: Qty.units(3),
            ),
          ],
        ),
        throwsA(
          isA<PurchaseReturnInvalid>().having(
            (e) => e.error,
            'error',
            PurchaseReturnError.stock,
          ),
        ),
      );
      await expectLater(
        returnPurchase(
          store,
          scope,
          staffId: ctx.owner.id,
          purchaseId: p.id,
          lines: const [],
        ),
        throwsA(isA<PurchaseReturnInvalid>()),
      );
    });
  });

  test('cari pembelian dan terapkan harga jual', () async {
    final a = await receivePurchase(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(
        paid: const Money(889000),
        funding: FundingSource.storeCash,
      ),
    );
    await savePurchaseDraft(
      store,
      scope,
      staffId: ctx.owner.id,
      request: request(supplier: 'UD Makmur'),
    );
    expect(await listPurchases(store, scope), hasLength(2));
    expect(
      (await listPurchases(
        store,
        scope,
        query: 'sp/xi',
      )).map((r) => r.purchase.id),
      hasLength(2),
    );
    expect(
      (await listPurchases(store, scope, query: 'makmur')).single.supplierName,
      'UD Makmur',
    );
    expect(
      (await listPurchases(store, scope, query: a.number)).single.purchase.id,
      a.id,
    );

    await applySellPrices(
      store,
      scope,
      staffId: ctx.owner.id,
      prices: {v(minyak).id: const Money(37200)},
    );
    final fresh = (await loadProduct(store, scope, minyak.id))!;
    expect(v(fresh).sellPrice, const Money(37200));
  });

  test('aktor wajib staf cabang dengan izin yang cukup', () async {
    final actor = ctx.owner.id;
    Future<StaffMember> addStaff(String name, String role) =>
        store.write(actor: actor, (w) async {
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
    final gudang = await addStaff('Andi', 'stock_keeper');
    final kasir = await addStaff('Sari', 'cashier');
    Matcher denied(Permission p) => throwsA(
      isA<PurchaseActorNotPermitted>().having((e) => e.permission, 'p', p),
    );

    await expectLater(
      savePurchaseDraft(store, scope, staffId: kasir.id, request: request()),
      denied(Permission.purchasesManage),
    );
    // Staf gudang boleh menerima barang, tetapi tidak memakai uang laci
    // dan tidak mengubah harga jual.
    await expectLater(
      receivePurchase(
        store,
        scope,
        staffId: gudang.id,
        request: request(
          paid: const Money(889000),
          funding: FundingSource.drawer,
        ),
      ),
      denied(Permission.cashMovementsCreate),
    );
    final p = await receivePurchase(
      store,
      scope,
      staffId: gudang.id,
      request: request(
        paid: const Money(889000),
        funding: FundingSource.storeCash,
      ),
    );
    expect(p.staffId, gudang.id);
    await expectLater(
      applySellPrices(
        store,
        scope,
        staffId: gudang.id,
        prices: {v(minyak).id: const Money(37200)},
      ),
      denied(Permission.productsManage),
    );
  });
}
