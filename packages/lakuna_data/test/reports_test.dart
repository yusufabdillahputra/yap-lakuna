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
  late CatalogProduct kopi;
  late CatalogProduct roti;
  late CatalogProduct jasa;

  UuidValue owner() => ctx.owner.id;
  CatalogVariant v(CatalogProduct p) => p.variants.single;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: owner(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

  Future<StaffMember> addStaff(String name, String role) {
    final actor = owner();
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
    // 2026-11-03 03.00 UTC = 10.00 WIB (kemarin dari hari laporan).
    now = DateTime.utc(2026, 11, 3, 3);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Bubuk',
        category: 'Minuman',
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
        baseUnit: 'bks',
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
    await ensureExpenseCategories(store, scope, staffId: owner());
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

  Future<CheckoutResult> sell(
    Map<CatalogProduct, int> lines, {
    SalePaymentRequest payment = const SalePaymentRequest.cash(Money(1000000)),
    UuidValue? staffId,
  }) => checkoutSale(
    store,
    scope,
    staffId: staffId ?? owner(),
    lines: [
      for (final e in lines.entries)
        SaleLineRequest(variantId: v(e.key).id, quantity: Qty(e.value)),
    ],
    payments: [payment],
  );

  Future<UuidValue> jenis(String name) async => (await listExpenseCategories(
    store,
    scope,
  )).firstWhere((r) => r.category.name == name).category.id;

  Future<Expense> spend(
    String description,
    String category,
    int amount,
  ) async => recordExpense(
    store,
    scope,
    staffId: owner(),
    request: ExpenseRequest(
      description: description,
      categoryId: await jenis(category),
      amount: Money(amount),
      funding: FundingSource.bank,
      spentOn: DateTime.utc(now.year, now.month, now.day),
    ),
  );

  Future<ReportData> report({
    ReportPeriod period = ReportPeriod.today,
    UuidValue? staffId,
  }) => loadReport(
    store,
    scope,
    staffId: staffId ?? owner(),
    period: period,
    now: now,
  );

  test('skenario lengkap cocok dengan hitungan manual', () async {
    // Kemarin: 1 kopi (pembanding periode lalu) + nota kredit jatuh tempo
    // hari itu.
    await sell({kopi: 1000});
    final budi = await saveCustomer(
      store,
      scope,
      staffId: owner(),
      input: const CustomerInput(name: 'Budi', creditLimit: Money(1000000)),
    );
    final credit = await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: [SaleLineRequest(variantId: v(roti).id, quantity: Qty.one)],
      payments: const [],
      credit: SaleCredit(
        customerId: budi.id,
        downPayment: const Money(5000),
        dueOn: DateTime.utc(2026, 11, 3),
      ),
    );
    expect(credit.sale.total, 15000);

    // Hari ini 2026-11-04 10.00 WIB.
    now = DateTime.utc(2026, 11, 4, 3);
    final sari = await addStaff('Sari', 'cashier');
    final a = await sell({kopi: 3000}, staffId: sari.id); // 30.000
    final b = await sell(
      {roti: 1000, jasa: 1000}, // 15.000 + 2.000
      payment: const SalePaymentRequest(
        method: PaymentMethod.card,
        reference: 'r1',
      ),
    );
    final c = await sell({kopi: 1000});
    await voidSale(
      store,
      scope,
      staffId: owner(),
      approverId: owner(),
      saleId: c.sale.id,
      reason: 'Salah input',
      now: now,
    );
    // Retur 1 kopi dari A (restock) dan roti dari B (rusak).
    await returnSale(
      store,
      scope,
      staffId: owner(),
      saleId: a.sale.id,
      lines: [ReturnLine(saleItemId: a.items.single.id, quantity: Qty.one)],
      reason: SaleReturnReason.wrongItem,
      refundMethod: RefundMethod.cash,
      restock: true,
    );
    final rotiItem = b.items.firstWhere((i) => i.variantId == v(roti).id);
    await returnSale(
      store,
      scope,
      staffId: owner(),
      saleId: b.sale.id,
      lines: [ReturnLine(saleItemId: rotiItem.id, quantity: Qty.one)],
      reason: SaleReturnReason.damaged,
      refundMethod: RefundMethod.cash,
      restock: false,
    );

    // F&B take away: PB1 10% (service hanya makan di tempat).
    await saveFnbRates(
      store,
      scope,
      staffId: owner(),
      rates: const FnbRates(service: BasisPoints(500), tax: BasisPoints(1000)),
    );
    final bill = await openTakeAway(store, scope, staffId: owner());
    await addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: bill.sale.id,
      line: SaleLineRequest(variantId: v(kopi).id, quantity: Qty.one),
    );
    final ta = await payOpenBill(
      store,
      scope,
      staffId: owner(),
      billId: bill.sale.id,
      payments: const [SalePaymentRequest.cash(Money(100000))],
    );
    // Bill lain masih terbuka: tidak dihitung.
    final open = await openTakeAway(store, scope, staffId: owner());
    await addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: open.sale.id,
      line: SaleLineRequest(variantId: v(roti).id, quantity: Qty.one),
    );

    await spend('Sewa', 'Sewa tempat', 50000);
    final batal = await spend('Dobel', 'Transport', 20000);
    await voidExpense(
      store,
      scope,
      staffId: owner(),
      expenseId: batal.id,
      reason: 'Dobel',
    );
    // Opname: kopi kurang 1 (nilai −6.000).
    final location = await defaultStockLocation(store, scope);
    final onHand = await stockOnHand(store, scope, variantId: v(kopi).id);
    await saveStockAdjustment(
      store,
      scope,
      staffId: owner(),
      locationId: location.id,
      reason: StockAdjustmentReason.lost,
      lines: [
        AdjustmentLine(variantId: v(kopi).id, physical: onHand - Qty.one),
      ],
    );

    final r = await report();
    final svc = ta.sale.serviceAmount;
    final pb1 = ta.sale.taxAmount;
    // Take away: tanpa service, PB1 10%.
    expect(svc, 0);
    expect(pb1, 1000);
    expect(r.saleCount, 3);
    expect(r.outletName, ctx.outlet.name);

    final pl = r.profit!;
    expect(pl.grossSales, const Money(30000 + 17000 + 10000));
    expect(pl.discount, Money.zero);
    expect(pl.service, Money(svc));
    expect(pl.returns, const Money(10000 + 15000));
    expect(pl.netSales, Money(57000 + svc - 25000));
    expect(r.netSales, pl.netSales);
    // HPP: kopi 3 × 6.000 + roti 9.000 + pulsa 0 + kopi TA 6.000 − retur
    // kopi restock 6.000.
    expect(pl.cogs, const Money(27000));
    expect(pl.missingCostCount, 1);
    expect(pl.expenses.single.name, 'Sewa tempat');
    expect(pl.totalExpenses, const Money(50000));
    expect(pl.stockAdjustment, const Money(-6000));
    expect(pl.taxCollected, Money(pb1));
    expect(pl.netProfit, Money(57000 + svc - 25000 - 27000 - 50000 - 6000));
    // Kemarin: 1 kopi + roti kredit, HPP 6.000 + 9.000.
    expect(r.previousProfit!.netSales, const Money(25000));
    expect(r.previousProfit!.grossProfit, const Money(10000));

    // Metode bayar: tunai 30.000 + TA, kartu 17.000.
    expect(r.payments.map((p) => (p.method, p.amount)), [
      (ReportPaymentMethod.cash, Money(30000 + ta.sale.total)),
      (ReportPaymentMethod.card, const Money(17000)),
    ]);

    // Per produk: kopi 3 − 1 + 1 = 3 pcs, 20.000 + 10.000.
    final kopiRow = r.byProduct.firstWhere((p) => p.key == v(kopi).id.uuid);
    expect(kopiRow.quantity, Qty.units(3));
    expect(kopiRow.value, const Money(30000));
    expect(r.unitOf[v(roti).id.uuid], 'bks');
    final rotiRow = r.byProduct.firstWhere((p) => p.key == v(roti).id.uuid);
    expect(rotiRow.quantity, Qty.zero);
    expect(r.top.map((t) => t.key), [v(kopi).id.uuid, v(jasa).id.uuid]);
    expect(r.categoryOf[v(kopi).id.uuid], 'Minuman');
    expect(r.byCategory.first.name, 'Minuman');

    // Per kasir: Sari 1 nota 30.000 − 10.000.
    final sariRow = r.byStaff.firstWhere((s) => s.key == sari.id.uuid);
    expect(sariRow.count, 1);
    expect(sariRow.value, const Money(20000));
    expect(r.staffNames[sari.id.uuid], 'Sari');
    expect(Money.sum(r.byStaff.map((s) => s.value)), r.netSales);

    // Piutang jatuh tempo: 15.000 − DP 5.000, 1 pelanggan.
    expect(r.overdue, const Money(10000));
    expect(r.overdueCustomers, 1);

    // 7 hari mencakup kemarin.
    final week = await report(period: ReportPeriod.last7Days);
    expect(week.saleCount, 5);
  });

  test('periode kosong = nol', () async {
    now = DateTime.utc(2026, 11, 4, 3);
    final r = await report(period: const ReportPeriod.month(2026, 1));
    expect(r.saleCount, 0);
    expect(r.netSales, Money.zero);
    expect(r.averagePerSale, Money.zero);
    expect(r.profit!.netProfit, Money.zero);
    expect(r.payments, isEmpty);
    expect(r.range.from, DateTime.utc(2026, 1));
  });

  test('izin: kasir ditolak, manajer melihat laba', () async {
    final kasir = await addStaff('Kasir', 'cashier');
    await expectLater(
      report(staffId: kasir.id),
      throwsA(isA<ReportActorNotPermitted>()),
    );
    final manajer = await addStaff('Manajer', 'manager');
    final r = await report(staffId: manajer.id);
    expect(r.canViewProfit, isTrue);
  });

  test(
    'tanpa reports:view_profit: laba kosong, harga pokok tidak terbawa',
    () async {
      now = DateTime.utc(2026, 11, 4, 3);
      await sell({kopi: 2000, roti: 1000});
      final r = await buildReport(
        store,
        scope,
        permissions: {Permission.reportsView},
        period: ReportPeriod.today,
        now: now,
      );
      expect(r.canViewProfit, isFalse);
      expect(r.profit, isNull);
      expect(r.previousProfit, isNull);
      expect(r.saleCount, 1);
      expect(r.netSales, const Money(35000));
      final costs = [
        for (final s in r.sales)
          for (final l in s.lines) l.unitCost,
      ];
      expect(costs, hasLength(2));
      expect(costs, everyElement(Money.zero));
      await expectLater(
        buildReport(
          store,
          scope,
          permissions: {Permission.reportsViewProfit},
          period: ReportPeriod.today,
          now: now,
        ),
        throwsA(isA<ReportActorNotPermitted>()),
      );
    },
  );

  test('retur hari ini atas nota kemarin', () async {
    final sari = await addStaff('Sari', 'cashier');
    final a = await sell({kopi: 2000}, staffId: sari.id); // kemarin 20.000
    now = DateTime.utc(2026, 11, 4, 3);
    await returnSale(
      store,
      scope,
      staffId: owner(),
      saleId: a.sale.id,
      lines: [ReturnLine(saleItemId: a.items.single.id, quantity: Qty.one)],
      reason: SaleReturnReason.wrongItem,
      refundMethod: RefundMethod.cash,
      restock: true,
    );
    final r = await report();
    // Nota kemarin tidak dihitung lagi; returnya mengurangi hari ini.
    expect(r.saleCount, 0);
    expect(r.returns, hasLength(1));
    final pl = r.profit!;
    expect(pl.grossSales, Money.zero);
    expect(pl.returns, const Money(10000));
    expect(pl.netSales, const Money(-10000));
    // Barang kembali ke stok: HPP berkurang 6.000.
    expect(pl.cogs, const Money(-6000));
    // Tercatat atas kasir penjual nota, tanpa menambah jumlah nota.
    final sariRow = r.byStaff.single;
    expect(sariRow.key, sari.id.uuid);
    expect(sariRow.count, 0);
    expect(sariRow.value, const Money(-10000));
    expect(r.staffNames[sari.id.uuid], 'Sari');
    final kopiRow = r.byProduct.single;
    expect(kopiRow.quantity, Qty.units(-1));
    expect(kopiRow.value, const Money(-10000));

    // Retur rusak (tanpa restock) tidak mengurangi HPP.
    await returnSale(
      store,
      scope,
      staffId: owner(),
      saleId: a.sale.id,
      lines: [ReturnLine(saleItemId: a.items.single.id, quantity: Qty.one)],
      reason: SaleReturnReason.damaged,
      refundMethod: RefundMethod.cash,
      restock: false,
    );
    final r2 = await report();
    expect(r2.profit!.returns, const Money(20000));
    expect(r2.profit!.cogs, const Money(-6000));
  });

  test('batas hari memakai zona waktu cabang', () async {
    // 23.30 WIB tanggal 3 = 16.30 UTC: masuk hari 3, bukan 4.
    now = DateTime.utc(2026, 11, 3, 16, 30);
    await sell({kopi: 1000});
    now = DateTime.utc(2026, 11, 3, 17, 30); // 00.30 WIB tanggal 4
    expect((await report()).saleCount, 0);
    await sell({kopi: 1000});
    expect((await report()).saleCount, 1);
  });
}
