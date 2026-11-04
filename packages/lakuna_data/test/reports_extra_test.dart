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

  final all = Permission.values.toSet();
  const viewOnly = {Permission.reportsView};
  UuidValue owner() => ctx.owner.id;
  CatalogVariant v(CatalogProduct p) => p.variants.single;
  CashScope cash() => CashScope.of(ctx);

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: owner(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

  setUp(() async {
    // Kemarin 2026-11-03 10.00 WIB: produk dan stok awal.
    now = DateTime.utc(2026, 11, 3, 3);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Bubuk',
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
            minStock: Qty(12000),
            openingStock: Qty(10000),
          ),
        ],
      ),
    );
    await product(
      const ProductDraft(
        name: 'Isi Pulsa',
        kind: ProductKind.service,
        baseUnit: 'kali',
        variants: [VariantDraft(sellPrice: Money(2000))],
      ),
    );
    await ensureExpenseCategories(store, scope, staffId: owner());
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<CheckoutResult> sell(Map<CatalogProduct, int> lines) => checkoutSale(
    store,
    scope,
    staffId: owner(),
    lines: [
      for (final e in lines.entries)
        SaleLineRequest(variantId: v(e.key).id, quantity: Qty(e.value)),
    ],
    payments: const [SalePaymentRequest.cash(Money(1000000))],
  );

  Future<CashSession> open(int amount) => openCashSession(
    store,
    cash(),
    staffId: owner(),
    openingCash: Money(amount),
  );

  test('stok: awal, masuk, keluar, akhir, nilai, menipis, habis', () async {
    await open(100000);
    now = DateTime.utc(2026, 11, 4, 3);
    final a = await sell({kopi: 3000});
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

    final r = await loadStockReport(
      store,
      scope,
      permissions: all,
      period: ReportPeriod.today,
      now: now,
    );
    expect(r.variantCount, 2);
    expect(r.lowCount, 1); // roti 10 ≤ min 12
    expect(r.outCount, 0);
    expect(r.totalValue, const Money(18 * 6000 + 10 * 9000));
    expect(
      r.rows.map(
        (x) => (x.name, x.opening, x.inflow, x.outflow, x.closing, x.value),
      ),
      [
        (
          'Kopi Bubuk',
          Qty.units(20),
          Qty.units(1),
          Qty.units(3),
          Qty.units(18),
          const Money(108000),
        ),
        (
          'Roti Tawar',
          Qty.units(10),
          Qty.zero,
          Qty.zero,
          Qty.units(10),
          const Money(90000),
        ),
      ],
    );
    expect(r.unitOf[v(roti).id.uuid], 'bks');

    // 7 hari terakhir mencakup stok awal kemarin.
    final yesterday = await loadStockReport(
      store,
      scope,
      permissions: all,
      period: ReportPeriod.last7Days,
      now: now,
    );
    final kopiWeek = yesterday.rows.firstWhere((x) => x.name == 'Kopi Bubuk');
    expect(kopiWeek.opening, Qty.zero);
    expect(kopiWeek.inflow, Qty.units(21));

    // Tanpa izin laba: tanpa nilai, urut nama.
    final plain = await loadStockReport(
      store,
      scope,
      permissions: viewOnly,
      period: ReportPeriod.today,
      now: now,
    );
    expect(plain.totalValue, isNull);
    expect(plain.rows.map((x) => x.value), everyElement(isNull));
    await expectLater(
      loadStockReport(
        store,
        scope,
        permissions: const {},
        period: ReportPeriod.today,
        now: now,
      ),
      throwsA(isA<ReportActorNotPermitted>()),
    );
  });

  test('stok: beberapa lokasi, nilai kartu = jumlah nilai baris', () async {
    await open(100000);
    final gudang = await createStockLocation(
      store,
      scope,
      staffId: owner(),
      name: 'Gudang',
    );
    final supplier = await saveSupplier(
      store,
      scope,
      staffId: owner(),
      input: const SupplierInput(name: 'CV Sumber', termDays: 7),
    );
    now = DateTime.utc(2026, 11, 4, 3);
    // 10 kopi @9.000 masuk Gudang; lokasi bawaan tetap 20 @6.000.
    await receivePurchase(
      store,
      scope,
      staffId: owner(),
      request: PurchaseRequest(
        supplierId: supplier.id,
        purchasedOn: DateTime.utc(2026, 11, 4),
        locationId: gudang.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(kopi).id,
            quantity: Qty.units(10),
            unitPrice: const Money(9000),
          ),
        ],
        paid: const Money(90000),
        funding: FundingSource.bank,
      ),
    );
    final r = await loadStockReport(
      store,
      scope,
      permissions: all,
      period: ReportPeriod.today,
      now: now,
    );
    final row = r.rows.firstWhere((x) => x.name == 'Kopi Bubuk');
    expect(row.opening, Qty.units(20));
    expect(row.inflow, Qty.units(10));
    expect(row.closing, Qty.units(30));
    expect(row.value, const Money(20 * 6000 + 10 * 9000));
    expect(r.totalValue, Money.sum(r.rows.map((x) => x.value!)));
    // Minimum dibanding stok lokasi bawaan, seperti layar Stok.
    expect(r.lowCount, 1);

    // Bulan lalu: semua pergerakan sesudah periode, jadi kosong.
    final october = await loadStockReport(
      store,
      scope,
      permissions: all,
      period: const ReportPeriod.month(2026, 10),
      now: now,
    );
    expect(october.rows, isEmpty);
  });

  test('kas: bayar pembelian keluar, refund retur pembelian masuk', () async {
    final session = await open(100000);
    final supplier = await saveSupplier(
      store,
      scope,
      staffId: owner(),
      input: const SupplierInput(name: 'CV Sumber', termDays: 7),
    );
    now = DateTime.utc(2026, 11, 4, 3);
    final location = await defaultStockLocation(store, scope);
    final purchase = await receivePurchase(
      store,
      scope,
      staffId: owner(),
      request: PurchaseRequest(
        supplierId: supplier.id,
        purchasedOn: DateTime.utc(2026, 11, 4),
        locationId: location.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(kopi).id,
            quantity: Qty.units(2),
            unitPrice: const Money(6000),
          ),
        ],
        paid: const Money(12000),
        funding: FundingSource.drawer,
      ),
    );
    final detail = await loadPurchaseDetail(store, scope, purchase.id);
    await returnPurchase(
      store,
      scope,
      staffId: owner(),
      purchaseId: purchase.id,
      lines: [
        PurchaseReturnLine(
          purchaseItemId: detail.items.single.id,
          quantity: Qty.one,
        ),
      ],
      refundSource: FundingSource.drawer,
    );
    final r = await loadCashReport(
      store,
      scope,
      permissions: viewOnly,
      period: ReportPeriod.today,
      now: now,
    );
    expect(r.outflows.map((g) => (g.key, g.total)), [
      (CashSourceKind.purchase, const Money(12000)),
    ]);
    expect(r.inflows.map((g) => (g.key, g.total)), [
      (CashSourceKind.purchaseRefund, const Money(6000)),
    ]);
    // Sesi kemarin masih buka: seharusnya ikut gerakan hari ini.
    expect(r.sessions.single.expected, const Money(100000 - 12000 + 6000));
    expect(session.status, CashSessionStatus.opened);
  });

  test('tanpa reports:view semua tab ditolak', () async {
    now = DateTime.utc(2026, 11, 4, 3);
    final denied = throwsA(isA<ReportActorNotPermitted>());
    await expectLater(
      loadCashReport(
        store,
        scope,
        permissions: const {Permission.reportsViewProfit},
        period: ReportPeriod.today,
        now: now,
      ),
      denied,
    );
    await expectLater(
      loadDebtReport(store, scope, permissions: const {}, now: now),
      denied,
    );
    await expectLater(
      loadReturnsReport(
        store,
        scope,
        permissions: const {},
        period: ReportPeriod.today,
        now: now,
      ),
      denied,
    );
  });

  test('kas & sesi: sesi tutup dan buka, gerakan kas per sumber', () async {
    final kemarin = await open(100000);
    await sell({kopi: 1000}); // tunai 10.000
    await closeCashSession(
      store,
      cash(),
      sessionId: kemarin.id,
      staffId: owner(),
      count: const CashCount(sheets: {100000: 1, 5000: 1}),
      note: 'Kurang 5.000',
    );

    now = DateTime.utc(2026, 11, 4, 3);
    final hariIni = await open(50000);
    await recordCashMovement(
      store,
      cash(),
      sessionId: hariIni.id,
      staffId: owner(),
      direction: CashDirection.outflow,
      amount: const Money(15000),
      note: 'Es batu',
    );
    await recordCashMovement(
      store,
      cash(),
      sessionId: hariIni.id,
      staffId: owner(),
      direction: CashDirection.inflow,
      amount: const Money(5000),
      note: 'Tambah receh',
    );
    final category = (await listExpenseCategories(store, scope)).first;
    await recordExpense(
      store,
      scope,
      staffId: owner(),
      request: ExpenseRequest(
        description: 'Plastik',
        categoryId: category.category.id,
        amount: const Money(20000),
        funding: FundingSource.drawer,
        spentOn: DateTime.utc(2026, 11, 4),
      ),
    );

    final today = await loadCashReport(
      store,
      scope,
      permissions: viewOnly,
      period: ReportPeriod.today,
      now: now,
    );
    final s = today.sessions.single;
    expect(s.isOpen, isTrue);
    expect(s.staffName, 'Yusuf');
    expect(s.opening, const Money(50000));
    expect(s.expected, const Money(50000 - 15000 + 5000 - 20000));
    expect(s.openedAt, DateTime.utc(2026, 11, 4, 10));
    expect(today.openCount, 1);
    expect(today.totalDifference, Money.zero);
    expect(today.outflows.map((g) => (g.key, g.count, g.total)), [
      (CashSourceKind.expense, 1, const Money(20000)),
      (CashSourceKind.manualOut, 1, const Money(15000)),
    ]);
    expect(today.inflows.single.key, CashSourceKind.manualIn);
    expect(today.inflow, const Money(5000));
    expect(today.outflow, const Money(35000));

    final week = await loadCashReport(
      store,
      scope,
      permissions: viewOnly,
      period: ReportPeriod.last7Days,
      now: now,
    );
    expect(week.sessions, hasLength(2));
    // Terbaru dulu; kemarin seharusnya 110.000, dihitung 105.000.
    final closed = week.sessions.last;
    expect(closed.isOpen, isFalse);
    expect(closed.expected, const Money(110000));
    expect(closed.counted, const Money(105000));
    expect(closed.difference, const Money(-5000));
    expect(week.totalDifference, const Money(-5000));
  });

  test('kas & sesi: sesi kemarin yang belum ditutup tampil hari ini', () async {
    await open(100000); // kemarin
    now = DateTime.utc(2026, 11, 4, 3);
    final today = await loadCashReport(
      store,
      scope,
      permissions: viewOnly,
      period: ReportPeriod.today,
      now: now,
    );
    expect(today.sessions.single.isOpen, isTrue);
    expect(today.sessions.single.openedAt, DateTime.utc(2026, 11, 3, 10));
    // Bulan lalu: sesi belum dibuka.
    final october = await loadCashReport(
      store,
      scope,
      permissions: viewOnly,
      period: const ReportPeriod.month(2026, 10),
      now: now,
    );
    expect(october.sessions, isEmpty);
  });

  test('piutang & hutang: posisi hari ini', () async {
    await open(100000);
    final budi = await saveCustomer(
      store,
      scope,
      staffId: owner(),
      input: const CustomerInput(name: 'Budi', creditLimit: Money(1000000)),
    );
    await checkoutSale(
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
    final supplier = await saveSupplier(
      store,
      scope,
      staffId: owner(),
      input: const SupplierInput(name: 'CV Sumber', termDays: 7),
    );
    final location = await defaultStockLocation(store, scope);
    await receivePurchase(
      store,
      scope,
      staffId: owner(),
      request: PurchaseRequest(
        supplierId: supplier.id,
        purchasedOn: DateTime.utc(2026, 10, 20),
        locationId: location.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(kopi).id,
            quantity: Qty.units(2),
            unitPrice: const Money(6000),
          ),
        ],
        paid: Money.zero,
        dueOn: DateTime.utc(2026, 11, 1),
      ),
    );
    now = DateTime.utc(2026, 11, 4, 3);

    final r = await loadDebtReport(
      store,
      scope,
      permissions: viewOnly,
      now: now,
    );
    expect(r.today, DateTime.utc(2026, 11, 4));
    expect(r.customers.single.customer.name, 'Budi');
    expect(r.receivable, const Money(10000));
    expect(r.overdue, const Money(10000));
    expect(r.overdueCustomers, 1);
    expect(r.suppliers.single.supplier.name, 'CV Sumber');
    expect(r.payable, const Money(12000));
    expect(r.overduePurchases, 1);
  });

  test('retur: daftar, alasan, kembali ke stok', () async {
    await open(100000);
    now = DateTime.utc(2026, 11, 4, 3);
    final a = await sell({kopi: 2000});
    for (final (reason, restock) in [
      (SaleReturnReason.wrongItem, true),
      (SaleReturnReason.damaged, false),
    ]) {
      now = now.add(const Duration(minutes: 5));
      await returnSale(
        store,
        scope,
        staffId: owner(),
        saleId: a.sale.id,
        lines: [ReturnLine(saleItemId: a.items.single.id, quantity: Qty.one)],
        reason: reason,
        refundMethod: RefundMethod.cash,
        restock: restock,
      );
    }
    final r = await loadReturnsReport(
      store,
      scope,
      permissions: viewOnly,
      period: ReportPeriod.today,
      now: now,
    );
    expect(r.lines.map((l) => (l.reason, l.restock)), [
      (SaleReturnReason.damaged, false),
      (SaleReturnReason.wrongItem, true),
    ]);
    expect(r.lines.first.saleNumber, a.sale.number);
    expect(r.lines.first.staffName, 'Yusuf');
    expect(r.lines.first.number, isNotEmpty);
    expect(r.total, const Money(20000));
    expect(r.restockCount, 1);
    expect(r.damagedCount, 1);
    expect(r.byReason, hasLength(2));
    final empty = await loadReturnsReport(
      store,
      scope,
      permissions: viewOnly,
      period: const ReportPeriod.month(2026, 10),
      now: now,
    );
    expect(empty.lines, isEmpty);
  });
}
