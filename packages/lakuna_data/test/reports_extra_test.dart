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

  group('loadClosedSessionRecap (F1-03e)', () {
    Future<CashSession> closedYesterday() async {
      final kemarin = await open(100000);
      await sell({kopi: 1000}); // tunai 10.000
      await recordCashMovement(
        store,
        cash(),
        sessionId: kemarin.id,
        staffId: owner(),
        direction: CashDirection.outflow,
        amount: const Money(15000),
        note: 'Es batu',
      );
      return closeCashSession(
        store,
        cash(),
        sessionId: kemarin.id,
        staffId: owner(),
        count: const CashCount(sheets: {50000: 1, 20000: 2}),
        note: 'Kurang 5.000',
      );
    }

    test('isi rekap sesi tertutup dan id baris laporan', () async {
      final closed = await closedYesterday();
      now = DateTime.utc(2026, 11, 4, 3);
      final week = await loadCashReport(
        store,
        scope,
        permissions: viewOnly,
        period: ReportPeriod.last7Days,
        now: now,
      );
      expect(week.sessions.single.id, closed.id);

      final r = await loadClosedSessionRecap(
        store,
        scope,
        permissions: viewOnly,
        sessionId: closed.id,
      );
      expect(r.session.id, closed.id);
      expect(r.session.expectedCash, 100000 + 10000 - 15000);
      expect(r.session.difference, -5000);
      expect(r.movements.map((m) => m.note), ['Es batu']);
      expect(r.sales.count, 1);
      expect(r.sales.cash, const Money(10000));
      expect(r.drawer.expectedCash, const Money(95000));
      expect(r.openedByName, 'Yusuf');
      expect(r.closedByName, 'Yusuf');
      expect(r.deviceCode, 'K01');
      expect(r.changedSinceClose, isFalse);
    });

    test('rincian berubah setelah tutup ditandai', () async {
      final closed = await closedYesterday();
      // Gerakan kas sesi itu terhapus (mis. dari sinkronisasi): rincian
      // saat ini tidak lagi sama dengan seharusnya yang tersimpan.
      final m = (await listCashMovements(store, cash(), closed.id)).single;
      await CashMovement.db.updateRow(
        store.session,
        m.copyWith(deletedAt: now),
      );
      final r = await loadClosedSessionRecap(
        store,
        scope,
        permissions: viewOnly,
        sessionId: closed.id,
      );
      expect(r.drawer.expectedCash, const Money(110000));
      expect(r.session.expectedCash, 95000);
      expect(r.changedSinceClose, isTrue);
    });

    test('sesi buka, cabang lain, atau tanpa izin ditolak', () async {
      final closed = await closedYesterday();
      final terbuka = await open(50000);
      await expectLater(
        loadClosedSessionRecap(
          store,
          scope,
          permissions: viewOnly,
          sessionId: terbuka.id,
        ),
        throwsA(isA<CashSessionNotClosed>()),
      );
      final other = CatalogScope(
        tenantId: scope.tenantId,
        outletId: UuidValue.fromString(newId()),
        deviceId: scope.deviceId,
      );
      await expectLater(
        loadClosedSessionRecap(
          store,
          other,
          permissions: viewOnly,
          sessionId: closed.id,
        ),
        throwsA(isA<CashSessionNotClosed>()),
      );
      await expectLater(
        loadClosedSessionRecap(
          store,
          scope,
          permissions: const {Permission.reportsViewProfit},
          sessionId: closed.id,
        ),
        throwsA(isA<ReportActorNotPermitted>()),
      );
    });
  });

  group('rekap sesi dari layar Sesi kasir (F1-03f)', () {
    const closer = {Permission.cashSessionClose};
    late UuidValue otherDeviceId;
    CashScope otherDevice() => CashScope(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      deviceId: otherDeviceId,
    );

    setUp(() async {
      final other = await store.write(actor: owner(), (w) async {
        final s = await w.stamp();
        return w.insert(
          Device(
            tenantId: ctx.tenant.id,
            outletId: ctx.outlet.id,
            code: 'K02',
            name: 'Perangkat K02',
            platform: DevicePlatform.android,
            createdBy: owner(),
            updatedBy: owner(),
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      });
      otherDeviceId = other.id;
    });

    Future<CashSession> openClose(
      CashScope at,
      int opening, {
      required DateTime openAt,
      required DateTime closeAt,
    }) async {
      now = openAt;
      final s = await openCashSession(
        store,
        at,
        staffId: owner(),
        openingCash: Money(opening),
      );
      now = closeAt;
      return closeCashSession(
        store,
        at,
        sessionId: s.id,
        staffId: owner(),
        count: CashCount(sheets: {opening: 1}),
      );
    }

    test('5 sesi tertutup terakhir perangkat ini, terbaru dulu', () async {
      final sessions = <CashSession>[];
      for (var d = 0; d < 6; d++) {
        sessions.add(
          await openClose(
            cash(),
            50000,
            openAt: DateTime.utc(2026, 11, 4 + d, 1),
            closeAt: DateTime.utc(2026, 11, 4 + d, 14),
          ),
        );
      }
      await openClose(
        otherDevice(),
        20000,
        openAt: DateTime.utc(2026, 11, 10, 2),
        closeAt: DateTime.utc(2026, 11, 10, 15),
      );
      now = DateTime.utc(2026, 11, 11, 1);
      await openCashSession(
        store,
        cash(),
        staffId: owner(),
        openingCash: const Money(10000),
      );

      final list = await listRecentClosedSessions(
        store,
        scope,
        permissions: closer,
      );
      expect(list.map((l) => l.id), sessions.reversed.take(5).map((s) => s.id));
      final first = list.first;
      // Waktu lokal cabang (WIB).
      expect(first.openedAt, DateTime.utc(2026, 11, 9, 8));
      expect(first.closedAt, DateTime.utc(2026, 11, 9, 21));
      expect(first.staffName, 'Yusuf');
      expect(first.counted, const Money(50000));
      expect(first.difference, Money.zero);
      expect(first.isOpen, isFalse);

      expect(
        await listRecentClosedSessions(store, scope, permissions: viewOnly),
        hasLength(5),
      );
      await expectLater(
        listRecentClosedSessions(
          store,
          scope,
          permissions: const {Permission.cashSessionOpen},
        ),
        throwsA(isA<ReportActorNotPermitted>()),
      );
    });

    test('cash_session:close: rekap perangkat sendiri saja', () async {
      final mine = await openClose(
        cash(),
        50000,
        openAt: DateTime.utc(2026, 11, 4, 1),
        closeAt: DateTime.utc(2026, 11, 4, 14),
      );
      final theirs = await openClose(
        otherDevice(),
        20000,
        openAt: DateTime.utc(2026, 11, 4, 2),
        closeAt: DateTime.utc(2026, 11, 4, 15),
      );
      final r = await loadClosedSessionRecap(
        store,
        scope,
        permissions: closer,
        sessionId: mine.id,
      );
      expect(r.session.id, mine.id);
      await expectLater(
        loadClosedSessionRecap(
          store,
          scope,
          permissions: closer,
          sessionId: theirs.id,
        ),
        throwsA(isA<ReportActorNotPermitted>()),
      );
      // Sesi perangkat lain yang masih buka: tetap ditolak karena izin,
      // bukan karena status.
      now = DateTime.utc(2026, 11, 5, 2);
      final openElsewhere = await openCashSession(
        store,
        otherDevice(),
        staffId: owner(),
        openingCash: const Money(10000),
      );
      await expectLater(
        loadClosedSessionRecap(
          store,
          scope,
          permissions: closer,
          sessionId: openElsewhere.id,
        ),
        throwsA(isA<ReportActorNotPermitted>()),
      );
      // Dengan reports:view, sesi perangkat lain tetap boleh (F1-03e).
      final other = await loadClosedSessionRecap(
        store,
        scope,
        permissions: viewOnly,
        sessionId: theirs.id,
      );
      expect(other.session.id, theirs.id);
    });
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
    // Umur (F1-16c): jatuh tempo 3 Nov = lewat 1 hari; 1 Nov = 3 hari.
    expect(r.receivableAging.amountOf(AgingBucket.days1To30), r.receivable);
    expect(r.receivableAging.countOf(AgingBucket.days1To30), 1);
    expect(r.payableAging.amountOf(AgingBucket.days1To30), r.payable);
    expect(r.payableAging.count, 1);
  });

  test('piutang & hutang: umur per kelompok (F1-16c)', () async {
    // Nota dibuat Juni agar jatuh tempo lama tetap sah.
    now = DateTime.utc(2026, 6, 20, 3);
    await open(100000);
    final budi = await saveCustomer(
      store,
      scope,
      staffId: owner(),
      input: const CustomerInput(name: 'Budi', creditLimit: Money(1000000)),
    );
    Future<void> credit(DateTime dueOn) => checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: [SaleLineRequest(variantId: v(roti).id, quantity: Qty.one)],
      payments: const [],
      credit: SaleCredit(
        customerId: budi.id,
        downPayment: Money.zero,
        dueOn: dueOn,
      ),
    );
    await credit(DateTime.utc(2026, 11, 10)); // belum jatuh tempo
    await credit(DateTime.utc(2026, 9, 20)); // lewat 45 hari
    await credit(DateTime.utc(2026, 7, 1)); // lewat 126 hari
    // Pelanggan terhapus yang masih berpiutang (mis. hasil sinkronisasi)
    // tidak dihitung di daftar, kartu, maupun umur.
    final ani = await saveCustomer(
      store,
      scope,
      staffId: owner(),
      input: const CustomerInput(name: 'Ani', creditLimit: Money(1000000)),
    );
    await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: [SaleLineRequest(variantId: v(roti).id, quantity: Qty.one)],
      payments: const [],
      credit: SaleCredit(
        customerId: ani.id,
        downPayment: Money.zero,
        dueOn: DateTime.utc(2026, 7, 1),
      ),
    );
    await store.write(actor: owner(), (w) async {
      final c = (await Customer.db.findById(w.session, ani.id))!;
      final st = await w.stamp();
      await w.update(
        c.copyWith(
          deletedAt: st.now,
          version: c.version + 1,
          updatedAt: st.now,
          hlc: st.hlc.toString(),
        ),
        st,
      );
    });
    final supplier = await saveSupplier(
      store,
      scope,
      staffId: owner(),
      input: const SupplierInput(name: 'CV Sumber', termDays: 7),
    );
    final location = await defaultStockLocation(store, scope);
    Future<void> buy(DateTime? dueOn) => receivePurchase(
      store,
      scope,
      staffId: owner(),
      request: PurchaseRequest(
        supplierId: supplier.id,
        purchasedOn: DateTime.utc(2026, 7, 1),
        locationId: location.id,
        lines: [
          PurchaseLineRequest(
            variantId: v(kopi).id,
            quantity: Qty.units(1),
            unitPrice: const Money(6000),
          ),
        ],
        paid: Money.zero,
        dueOn: dueOn,
      ),
    );
    await buy(DateTime.utc(2026, 8, 20)); // lewat 76 hari
    await buy(DateTime.utc(2026, 8, 25)); // lewat 71 hari
    now = DateTime.utc(2026, 11, 4, 3);

    final r = await loadDebtReport(
      store,
      scope,
      permissions: viewOnly,
      now: now,
    );
    final rec = r.receivableAging;
    expect(rec.amountOf(AgingBucket.notDue), const Money(15000));
    expect(rec.amountOf(AgingBucket.days1To30), Money.zero);
    expect(rec.amountOf(AgingBucket.days31To60), const Money(15000));
    expect(rec.amountOf(AgingBucket.days61To90), Money.zero);
    expect(rec.amountOf(AgingBucket.over90), const Money(15000));
    expect(rec.count, 3);
    expect(rec.total, r.receivable);
    expect(r.customers.map((c) => c.customer.name), ['Budi']);
    expect(r.overdue, const Money(30000));
    expect(r.overdue, rec.overdue);
    expect(r.overdueCustomers, 1);
    final pay = r.payableAging;
    expect(pay.amountOf(AgingBucket.days61To90), const Money(12000));
    expect(pay.countOf(AgingBucket.days61To90), 2);
    expect(pay.total, r.payable);
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

  group('shift di Kas & sesi (F1-03g)', () {
    Future<Shift> shift(String name, int start, int end) => saveShift(
      store,
      scope,
      staffId: owner(),
      name: name,
      startMinute: start,
      endMinute: end,
    );

    Future<CashSession> openWith(UuidValue? shiftId, int amount) =>
        openCashSession(
          store,
          cash(),
          staffId: owner(),
          openingCash: Money(amount),
          shiftId: shiftId,
        );

    Future<CashSession> close(CashSession s, Map<int, int> sheets) =>
        closeCashSession(
          store,
          cash(),
          sessionId: s.id,
          staffId: owner(),
          count: CashCount(sheets: sheets),
          note: 'Hitung',
        );

    test('baris sesi membawa shift, ringkasan per shift', () async {
      final pagi = await shift('Pagi', 7 * 60, 15 * 60);
      final malam = await shift('Malam', 22 * 60, 6 * 60);

      now = DateTime.utc(2026, 11, 2, 1);
      final a = await openWith(pagi.id, 100000);
      await sell({kopi: 1000}); // 10.000
      await close(a, {100000: 1, 5000: 1}); // kurang 5.000

      now = DateTime.utc(2026, 11, 2, 15);
      final b = await openWith(malam.id, 50000);
      await sell({kopi: 2000}); // 20.000
      await close(b, {50000: 1, 20000: 1, 1000: 1}); // lebih 1.000

      now = DateTime.utc(2026, 11, 3, 1);
      final c = await openWith(pagi.id, 0);
      await sell({roti: 1000}); // 15.000
      await close(c, {10000: 1, 5000: 1});

      now = DateTime.utc(2026, 11, 3, 5);
      await openWith(null, 0);
      await sell({kopi: 1000});

      // Ganti nama ikut tampil di sesi lama.
      await saveShift(
        store,
        scope,
        staffId: owner(),
        id: pagi.id,
        name: 'Pagi awal',
        startMinute: 7 * 60,
        endMinute: 15 * 60,
      );

      final week = await loadCashReport(
        store,
        scope,
        permissions: viewOnly,
        period: ReportPeriod.last7Days,
        now: now,
      );
      expect([for (final s in week.sessions) s.shift?.name], [
        null,
        'Pagi awal',
        'Malam',
        'Pagi awal',
      ]);
      expect(
        [
          for (final g in week.shifts)
            (g.shift?.name, g.sessions, g.sales, g.difference),
        ],
        [
          ('Pagi awal', 2, const Money(25000), const Money(-5000)),
          ('Malam', 1, const Money(20000), const Money(1000)),
          (null, 1, const Money(10000), Money.zero),
        ],
      );

      final recent = await listRecentClosedSessions(
        store,
        scope,
        permissions: all,
      );
      expect([for (final s in recent) s.shift?.name], [
        'Pagi awal',
        'Malam',
        'Pagi awal',
      ]);
      final recap = await loadClosedSessionRecap(
        store,
        scope,
        permissions: all,
        sessionId: b.id,
      );
      expect(recap.shift?.id, malam.id);
    });

    test('tanpa sesi bershift, ringkasan per shift kosong', () async {
      await shift('Pagi', 7 * 60, 15 * 60);
      final a = await openWith(null, 10000);
      await close(a, {10000: 1});
      final r = await loadCashReport(
        store,
        scope,
        permissions: viewOnly,
        period: ReportPeriod.today,
        now: now,
      );
      expect(r.sessions.single.shift, isNull);
      expect(r.shifts, isEmpty);
      final recap = await loadClosedSessionRecap(
        store,
        scope,
        permissions: all,
        sessionId: a.id,
      );
      expect(recap.shift, isNull);
    });
  });
}
