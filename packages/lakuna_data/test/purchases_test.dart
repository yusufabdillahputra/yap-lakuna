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
    expect(
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
