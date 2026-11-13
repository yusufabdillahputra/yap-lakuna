import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

// Batal pembayaran piutang & hutang (F1-13c).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CashScope cashScope;
  late DateTime now;
  late CatalogProduct beras;
  late StockLocation gudang;

  UuidValue owner() => ctx.owner.id;

  Future<StaffMember> addStaff(String name, String role) {
    final actor = ctx.owner.id;
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
    // 2026-11-04 03.00 UTC = 10.00 WIB.
    now = DateTime.utc(2026, 11, 4, 3);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Beras Premium 5 kg',
        baseUnit: 'sak',
        variants: [
          VariantDraft(
            costPrice: Money(60000),
            sellPrice: Money(100000),
            openingStock: Qty(50000),
          ),
        ],
      ),
    );
    beras = (await loadProduct(store, scope, id))!;
    gudang = await defaultStockLocation(store, scope);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<CashSession> openSession() => openCashSession(
    store,
    cashScope,
    staffId: owner(),
    openingCash: const Money(100000),
  );

  Future<List<CashMovement>> movements() async {
    final s = (await findOpenCashSession(store, cashScope))!;
    return listCashMovements(store, cashScope, s.id);
  }

  Future<DebtPayment> voidIt(
    DebtPayment p, {
    String reason = 'Salah nominal',
    UuidValue? staffId,
  }) => voidDebtPayment(
    store,
    scope,
    staffId: staffId ?? owner(),
    paymentId: p.id,
    reason: reason,
  );

  group('piutang pelanggan', () {
    late Customer ani;
    late CheckoutResult a;
    late CheckoutResult b;

    setUp(() async {
      await openSession();
      ani = await saveCustomer(
        store,
        scope,
        staffId: owner(),
        input: const CustomerInput(
          name: 'Toko Bu Ani',
          creditLimit: Money(2000000),
        ),
      );
      Future<CheckoutResult> sell(int sak) => checkoutSale(
        store,
        scope,
        staffId: owner(),
        lines: [
          SaleLineRequest(
            variantId: beras.variants.single.id,
            quantity: Qty.units(sak),
          ),
        ],
        payments: const [],
        credit: SaleCredit(
          customerId: ani.id,
          downPayment: Money.zero,
          dueOn: DateTime.utc(2026, 11, 17),
        ),
      );
      a = await sell(5);
      now = now.add(const Duration(minutes: 1));
      b = await sell(3);
      now = now.add(const Duration(minutes: 1));
    });

    Future<DebtPayment> receive(int amount, PaymentMethod method) =>
        receiveDebtPayment(
          store,
          scope,
          staffId: owner(),
          request: DebtPaymentRequest(
            customerId: ani.id,
            amount: Money(amount),
            method: method,
            paidOn: DateTime.utc(2026, 11, 4),
          ),
        );

    test('tunai: alokasi hilang, sisa nota kembali, kas keluar', () async {
      final p = await receive(600000, PaymentMethod.cash);
      var detail = await loadCustomerDetail(store, scope, ani.id, now: now);
      expect(detail.row.outstanding, const Money(200000));

      now = now.add(const Duration(minutes: 5));
      final voided = await voidIt(p, reason: '  Salah pelanggan  ');
      expect(voided.voidedAt, now);
      expect(voided.voidedBy, owner());
      expect(voided.voidReason, 'Salah pelanggan');
      expect(voided.voidCashMovementId, isNotNull);
      expect(voided.version, p.version + 1);

      detail = await loadCustomerDetail(store, scope, ani.id, now: now);
      expect(detail.row.outstanding, const Money(800000));
      expect(detail.open.map((r) => r.sale.id), [a.sale.id, b.sale.id]);
      expect(detail.open.first.outstanding, const Money(500000));
      // Pembayaran batal tetap di riwayat.
      expect(detail.payments.single.voidedAt, isNotNull);

      final cash = await movements();
      expect(cash.map((m) => (m.direction, m.amount, m.source)), [
        (CashDirection.inflow, 600000, debtPaymentCashSource),
        (CashDirection.outflow, 600000, debtPaymentVoidCashSource),
      ]);
      expect(cash.last.id, voided.voidCashMovementId);
      expect(cash.last.note, 'Batal ${p.number}');
      final drawer = await cashDrawerFor(
        store,
        cashScope,
        (await findOpenCashSession(store, cashScope))!,
      );
      expect(drawer.expectedCash, const Money(100000));

      // Kuitansi tetap bisa dibuka lengkap dengan rinciannya.
      final receipt = await loadDebtPaymentReceipt(store, scope, p.id);
      expect(receipt.payment.voidedAt, isNotNull);
      expect(receipt.lines.length, 2);

      // Nota yang tadinya dibayar bisa di-void lagi.
      final sale = await loadSaleDetail(store, scope, a.sale.id, now: now);
      expect(sale.voidBlock, isNull);
    });

    test('transfer: tanpa gerakan kas dan tanpa sesi', () async {
      final p = await receive(100000, PaymentMethod.transfer);
      final s = (await findOpenCashSession(store, cashScope))!;
      await closeCashSession(
        store,
        cashScope,
        staffId: owner(),
        sessionId: s.id,
        count: const CashCount(sheets: {100000: 1}),
      );
      final voided = await voidIt(p);
      expect(voided.voidCashMovementId, isNull);
      final detail = await loadCustomerDetail(store, scope, ani.id, now: now);
      expect(detail.row.outstanding, const Money(800000));
    });

    test('tunai laci tanpa sesi terbuka ditolak', () async {
      final p = await receive(100000, PaymentMethod.cash);
      final s = (await findOpenCashSession(store, cashScope))!;
      await closeCashSession(
        store,
        cashScope,
        staffId: owner(),
        sessionId: s.id,
        count: const CashCount(sheets: {100000: 2}),
      );
      await expectLater(voidIt(p), throwsA(isA<CashSessionNotOpen>()));
      final again = await DebtPayment.db.findById(store.session, p.id);
      expect(again!.voidedAt, isNull);
    });

    test('dua kali, alasan, izin, cabang lain ditolak', () async {
      final p = await receive(100000, PaymentMethod.cash);
      await expectLater(
        voidIt(p, reason: '   '),
        throwsA(isA<DebtPaymentVoidReasonInvalid>()),
      );
      await expectLater(
        voidIt(p, reason: 'x' * 201),
        throwsA(isA<DebtPaymentVoidReasonInvalid>()),
      );
      final gudang = await addStaff('Andi', 'stock_keeper');
      await expectLater(
        voidIt(p, staffId: gudang.id),
        throwsA(isA<CustomerActorNotPermitted>()),
      );
      final other = CatalogScope(
        tenantId: scope.tenantId,
        outletId: UuidValue.fromString(newId()),
        deviceId: scope.deviceId,
      );
      await expectLater(
        voidDebtPayment(
          store,
          other,
          staffId: owner(),
          paymentId: p.id,
          reason: 'x',
        ),
        throwsA(isA<Exception>()),
      );
      await voidIt(p);
      await expectLater(voidIt(p), throwsA(isA<DebtPaymentAlreadyVoided>()));
      await expectLater(
        voidDebtPayment(
          store,
          scope,
          staffId: owner(),
          paymentId: UuidValue.fromString(newId()),
          reason: 'x',
        ),
        throwsA(isA<DebtPaymentNotFound>()),
      );
    });

    test('pembayaran, alokasi, dan kas masuk outbox', () async {
      final p = await receive(100000, PaymentMethod.cash);
      Future<Map<String, int>> counts() async {
        final rows = await SyncOutboxEntry.db.find(store.session);
        return {
          for (final t in const [
            'debt_payments',
            'debt_payment_allocations',
            'cash_movements',
          ])
            t: rows.where((r) => r.entity == t).length,
        };
      }

      final before = await counts();
      await voidIt(p);
      final after = await counts();
      expect(after['debt_payments'], before['debt_payments']! + 1);
      expect(
        after['debt_payment_allocations'],
        before['debt_payment_allocations']! + 1,
      );
      expect(after['cash_movements'], before['cash_movements']! + 1);
    });

    test('laporan kas: batal bayar piutang', () async {
      final p = await receive(100000, PaymentMethod.cash);
      await voidIt(p);
      final r = await loadCashReport(
        store,
        scope,
        permissions: const {Permission.reportsView},
        period: ReportPeriod.today,
        now: now,
      );
      expect(r.outflows.map((g) => (g.key, g.total)), [
        (CashSourceKind.debtPaymentVoid, const Money(100000)),
      ]);
    });
  });

  group('hutang supplier', () {
    late Supplier s;
    late Purchase p1;

    setUp(() async {
      s = await saveSupplier(
        store,
        scope,
        staffId: owner(),
        input: const SupplierInput(name: 'CV Sumber Pangan', termDays: 14),
      );
      p1 = await receivePurchase(
        store,
        scope,
        staffId: owner(),
        request: PurchaseRequest(
          supplierId: s.id,
          purchasedOn: DateTime(2026, 11, 4),
          locationId: gudang.id,
          lines: [
            PurchaseLineRequest(
              variantId: beras.variants.single.id,
              quantity: Qty.units(10),
              unitPrice: const Money(60000),
            ),
          ],
          paid: Money.zero,
          dueOn: DateTime.utc(2026, 11, 18),
        ),
      );
    });

    Future<DebtPayment> pay(int amount, FundingSource funding) =>
        paySupplierDebt(
          store,
          scope,
          staffId: owner(),
          request: SupplierPaymentRequest(
            supplierId: s.id,
            amount: Money(amount),
            funding: funding,
            paidOn: DateTime.utc(2026, 11, 4),
          ),
        );

    test('dari laci: kas masuk kembali, hutang kembali', () async {
      await openSession();
      final p = await pay(50000, FundingSource.drawer);
      var detail = await loadSupplierDetail(store, scope, s.id, now: now);
      expect(detail.open.single.outstanding, const Money(550000));
      final voided = await voidIt(p, reason: 'Salah nominal');
      expect(voided.voidCashMovementId, isNotNull);
      detail = await loadSupplierDetail(store, scope, s.id, now: now);
      expect(detail.open.single.purchase.id, p1.id);
      expect(detail.open.single.outstanding, const Money(600000));
      expect(detail.payments.single.voidedAt, isNotNull);
      final cash = await movements();
      expect(cash.map((m) => (m.direction, m.amount, m.source)), [
        (CashDirection.outflow, 50000, supplierPaymentCashSource),
        (CashDirection.inflow, 50000, supplierPaymentVoidCashSource),
      ]);
      final pd = await loadPurchaseDetail(store, scope, p1.id);
      expect(pd.debtPaid, Money.zero);

      final r = await loadCashReport(
        store,
        scope,
        permissions: const {Permission.reportsView},
        period: ReportPeriod.today,
        now: now,
      );
      expect(r.inflows.map((g) => (g.key, g.total)), [
        (CashSourceKind.supplierPaymentVoid, const Money(50000)),
      ]);
    });

    test('dari bank: tanpa kas; izin supplier', () async {
      final p = await pay(600000, FundingSource.bank);
      final pelayan = await addStaff('Rina', 'waiter');
      await expectLater(
        voidIt(p, staffId: pelayan.id),
        throwsA(isA<SupplierActorNotPermitted>()),
      );
      final voided = await voidIt(p);
      expect(voided.voidCashMovementId, isNull);
      final detail = await loadSupplierDetail(store, scope, s.id, now: now);
      expect(detail.open.single.outstanding, const Money(600000));
    });
  });
}
