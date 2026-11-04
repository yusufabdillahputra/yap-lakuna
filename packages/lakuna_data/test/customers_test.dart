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
  late CatalogProduct beras;

  CatalogVariant v(CatalogProduct p) => p.variants.single;
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
    // 2026-11-03 09.00 UTC = 16.00 WIB.
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
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

  Future<Customer> customer(
    String name, {
    String? phone,
    int limit = 2000000,
    String? group,
  }) => saveCustomer(
    store,
    scope,
    staffId: owner(),
    input: CustomerInput(
      name: name,
      phone: phone,
      newGroupName: group,
      creditLimit: Money(limit),
    ),
  );

  Future<CheckoutResult> sellOnCredit(
    Customer c, {
    int sak = 2,
    int down = 0,
    DateTime? dueOn,
    UuidValue? staffId,
  }) => checkoutSale(
    store,
    scope,
    staffId: staffId ?? owner(),
    lines: [SaleLineRequest(variantId: v(beras).id, quantity: Qty.units(sak))],
    payments: const [],
    credit: SaleCredit(
      customerId: c.id,
      downPayment: Money(down),
      dueOn: dueOn ?? DateTime.utc(2026, 11, 17),
    ),
  );

  group('grup pelanggan', () {
    test('simpan, nama unik, hapus ditolak bila dipakai', () async {
      final grosir = await saveCustomerGroup(
        store,
        scope,
        staffId: owner(),
        name: 'Grosir',
        termDays: 14,
      );
      expect(grosir.termDays, 14);
      await expectLater(
        saveCustomerGroup(
          store,
          scope,
          staffId: owner(),
          name: 'grosir ',
          termDays: 7,
        ),
        throwsA(isA<CustomerGroupNameTaken>()),
      );
      await expectLater(
        saveCustomerGroup(
          store,
          scope,
          staffId: owner(),
          name: 'Eceran',
          termDays: 400,
        ),
        throwsA(isA<CustomerGroupInvalid>()),
      );
      final ubah = await saveCustomerGroup(
        store,
        scope,
        staffId: owner(),
        id: grosir.id,
        name: 'Grosir besar',
        termDays: 21,
      );
      expect(ubah.name, 'Grosir besar');

      // Form pelanggan memakai grup yang ada tanpa membedakan huruf.
      await customer('Toko Bu Ani', group: 'GROSIR BESAR');
      final rows = await listCustomerGroups(store, scope);
      expect(rows.single.group.id, grosir.id);
      expect(rows.single.customerCount, 1);
      await expectLater(
        deleteCustomerGroup(store, scope, staffId: owner(), groupId: grosir.id),
        throwsA(isA<CustomerGroupInUse>()),
      );
      final kosong = await saveCustomerGroup(
        store,
        scope,
        staffId: owner(),
        name: 'Kosong',
        termDays: 0,
      );
      await deleteCustomerGroup(
        store,
        scope,
        staffId: owner(),
        groupId: kosong.id,
      );
      expect(await listCustomerGroups(store, scope), hasLength(1));
    });
  });

  group('pelanggan', () {
    test('simpan, HP dinormalisasi dan unik, ubah, hapus', () async {
      final ani = await customer('Toko Bu Ani', phone: '+62 813-2222-1010');
      expect(ani.phone, '081322221010');
      expect(ani.creditLimit, 2000000);
      await expectLater(
        customer('Ani Lain', phone: '0813 2222 1010'),
        throwsA(isA<CustomerPhoneTaken>()),
      );
      await expectLater(
        customer(' ', phone: '0812'),
        throwsA(
          isA<CustomerInvalid>().having((e) => e.issues, 'issues', {
            CustomerIssue.name,
            CustomerIssue.phone,
          }),
        ),
      );
      final ubah = await saveCustomer(
        store,
        scope,
        staffId: owner(),
        input: CustomerInput(
          id: ani.id,
          name: 'Toko Bu Ani',
          phone: '081322221010',
          address: 'Jl. Melati 12',
          creditLimit: const Money(3000000),
        ),
      );
      expect(ubah.address, 'Jl. Melati 12');
      expect(ubah.version, 2);

      final overview = await listCustomers(store, scope, now: now);
      expect(overview.rows.single.customer.name, 'Toko Bu Ani');
      expect(overview.rows.single.outstanding, Money.zero);
      await deleteCustomer(store, scope, staffId: owner(), customerId: ani.id);
      expect((await listCustomers(store, scope, now: now)).rows, isEmpty);
    });

    test('izin: kasir tidak boleh mengubah data pelanggan', () async {
      final kasir = await addStaff('Sari', 'cashier');
      await expectLater(
        saveCustomer(
          store,
          scope,
          staffId: kasir.id,
          input: const CustomerInput(name: 'X'),
        ),
        throwsA(
          isA<CustomerActorNotPermitted>().having(
            (e) => e.permission,
            'permission',
            Permission.customersManage,
          ),
        ),
      );
    });
  });

  group('kredit di kasir', () {
    test('DP tunai, piutang, jatuh tempo, limit', () async {
      await openSession();
      final ani = await customer('Toko Bu Ani', limit: 300000);
      final sale = await sellOnCredit(ani, down: 50000);
      expect(sale.sale.customerId, ani.id);
      expect(sale.sale.customerName, 'Toko Bu Ani');
      expect(sale.sale.dueOn, DateTime.utc(2026, 11, 17));
      expect(sale.sale.paidAmount, 50000);
      expect(sale.sale.status, SaleStatus.completed);
      expect(sale.payments.single.method, PaymentMethod.cash);
      expect(sale.payments.single.amount, 50000);

      final overview = await listCustomers(store, scope, now: now);
      expect(overview.rows.single.outstanding, const Money(150000));
      expect(overview.rows.single.remainingLimit, const Money(150000));
      expect(overview.totalOutstanding, const Money(150000));

      // Rekap sesi: DP masuk laci, bagian kredit tercatat.
      final session = (await findOpenCashSession(store, cashScope))!;
      final summary = await salesSummaryForSession(
        store,
        scope,
        sessionId: session.id,
      );
      expect(summary.cash, const Money(50000));
      expect(summary.credit, const Money(150000));

      // 150.000 + 200.000 > 300.000.
      await expectLater(
        sellOnCredit(ani),
        throwsA(
          isA<SaleCreditInvalid>().having(
            (e) => e.issue,
            'issue',
            CreditIssue.overLimit,
          ),
        ),
      );
      await expectLater(
        sellOnCredit(ani, sak: 1, dueOn: DateTime.utc(2026, 11, 2)),
        throwsA(isA<SaleCreditInvalid>()),
      );
      // Tanpa DP tetap boleh selama dalam limit.
      final kedua = await sellOnCredit(ani, sak: 1);
      expect(kedua.payments, isEmpty);
      expect(kedua.sale.paidAmount, 0);
    });

    test('limit 0 dan aktor tanpa debts:manage ditolak', () async {
      await openSession();
      final umum = await customer('Pak Darto', limit: 0);
      await expectLater(
        sellOnCredit(umum),
        throwsA(
          isA<SaleCreditInvalid>().having(
            (e) => e.issue,
            'issue',
            CreditIssue.noLimit,
          ),
        ),
      );
      final ani = await customer('Toko Bu Ani');
      final pelayan = await addStaff('Wawan', 'waiter');
      await expectLater(
        sellOnCredit(ani, staffId: pelayan.id),
        throwsA(isA<CustomerActorNotPermitted>()),
      );
    });
  });

  group('pembayaran piutang', () {
    late Customer ani;
    late CheckoutResult a;
    late CheckoutResult b;
    late CheckoutResult c;

    setUp(() async {
      await openSession();
      ani = await customer('Toko Bu Ani', phone: '081322221010');
      a = await sellOnCredit(ani, sak: 5, dueOn: DateTime.utc(2026, 11, 3));
      now = now.add(const Duration(minutes: 1));
      b = await sellOnCredit(ani, sak: 3);
      now = now.add(const Duration(minutes: 1));
      c = await sellOnCredit(ani, sak: 4);
      // Besok: nota a terlambat.
      now = DateTime.utc(2026, 11, 4, 9);
    });

    test('rincian: nota terlama dulu, terlambat', () async {
      final detail = await loadCustomerDetail(store, scope, ani.id, now: now);
      expect(detail.open.map((r) => r.sale.id), [
        a.sale.id,
        b.sale.id,
        c.sale.id,
      ]);
      expect(detail.open.first.overdue, isTrue);
      expect(detail.open[1].overdue, isFalse);
      expect(detail.row.outstanding, const Money(1200000));
      final overview = await listCustomers(store, scope, now: now);
      expect(overview.overdueCount, 1);
      expect(overview.rows.single.overdueCount, 1);
    });

    test('otomatis FIFO, tunai masuk laci, kuitansi', () async {
      final payment = await receiveDebtPayment(
        store,
        scope,
        staffId: owner(),
        request: DebtPaymentRequest(
          customerId: ani.id,
          amount: const Money(800000),
          method: PaymentMethod.cash,
          paidOn: DateTime.utc(2026, 11, 4),
        ),
      );
      expect(payment.number, 'BP-PST-K01-261104-0001');
      expect(payment.balanceAfter, 400000);
      expect(payment.cashSessionId, isNotNull);
      final movements = await listCashMovements(
        store,
        cashScope,
        payment.cashSessionId!,
      );
      expect(movements.single.direction, CashDirection.inflow);
      expect(movements.single.amount, 800000);
      expect(movements.single.source, debtPaymentCashSource);
      expect(movements.single.note, 'Pembayaran piutang ${payment.number}');

      final receipt = await loadDebtPaymentReceipt(store, scope, payment.id);
      expect(receipt.customer.name, 'Toko Bu Ani');
      expect(
        [
          for (final l in receipt.lines)
            (l.saleNumber, l.balanceBefore, l.amount),
        ],
        [
          (a.sale.number, const Money(500000), const Money(500000)),
          (b.sale.number, const Money(300000), const Money(300000)),
        ],
      );
      expect(receipt.staffName, 'Yusuf');

      final detail = await loadCustomerDetail(store, scope, ani.id, now: now);
      expect(detail.open.single.sale.id, c.sale.id);
      expect(detail.row.outstanding, const Money(400000));
      expect(detail.payments.single.id, payment.id);
    });

    test('manual, transfer tanpa laci, galat', () async {
      Future<DebtPayment> pay(
        int amount, {
        Map<UuidValue, Money>? manual,
        DateTime? paidOn,
        PaymentMethod method = PaymentMethod.transfer,
      }) => receiveDebtPayment(
        store,
        scope,
        staffId: owner(),
        request: DebtPaymentRequest(
          customerId: ani.id,
          amount: Money(amount),
          method: method,
          paidOn: paidOn ?? DateTime.utc(2026, 11, 4),
          allocations: manual,
        ),
      );

      final p = await pay(350000, manual: {c.sale.id: const Money(350000)});
      expect(p.cashSessionId, isNull);
      final detail = await loadCustomerDetail(store, scope, ani.id, now: now);
      expect(
        detail.open.firstWhere((r) => r.sale.id == c.sale.id).outstanding,
        const Money(50000),
      );

      await expectLater(
        pay(0),
        throwsA(
          isA<DebtPaymentInvalid>().having(
            (e) => e.issue,
            'issue',
            DebtPaymentIssue.amount,
          ),
        ),
      );
      await expectLater(
        pay(900000),
        throwsA(
          isA<DebtPaymentInvalid>().having(
            (e) => e.issue,
            'issue',
            DebtPaymentIssue.overOutstanding,
          ),
        ),
      );
      await expectLater(
        pay(100000, manual: {c.sale.id: const Money(100000)}),
        throwsA(
          isA<DebtPaymentInvalid>().having(
            (e) => e.issue,
            'issue',
            DebtPaymentIssue.allocationOverRemaining,
          ),
        ),
      );
      await expectLater(
        pay(1000, paidOn: DateTime.utc(2026, 11, 5)),
        throwsA(isA<DebtPaymentDateInvalid>()),
      );
      await expectLater(
        pay(1000, method: PaymentMethod.card),
        throwsA(isA<DebtPaymentMethodInvalid>()),
      );
      final gudang = await addStaff('Andi', 'stock_keeper');
      await expectLater(
        receiveDebtPayment(
          store,
          scope,
          staffId: gudang.id,
          request: DebtPaymentRequest(
            customerId: ani.id,
            amount: const Money(1000),
            method: PaymentMethod.transfer,
            paidOn: DateTime.utc(2026, 11, 4),
          ),
        ),
        throwsA(isA<CustomerActorNotPermitted>()),
      );
    });

    test('hapus pelanggan berpiutang ditolak', () async {
      await expectLater(
        deleteCustomer(store, scope, staffId: owner(), customerId: ani.id),
        throwsA(isA<CustomerHasDebt>()),
      );
    });

    test(
      'retur nota kredit memotong piutang; void ditolak setelah dibayar',
      () async {
        now = DateTime.utc(2026, 11, 3, 10);
        // Retur 1 sak nota b (sisa 300.000): seluruhnya memotong piutang.
        final retur = await returnSale(
          store,
          scope,
          staffId: owner(),
          saleId: b.sale.id,
          lines: [ReturnLine(saleItemId: b.items.single.id, quantity: Qty.one)],
          reason: SaleReturnReason.damaged,
          refundMethod: RefundMethod.cash,
          restock: true,
        );
        expect(retur.debtReduction, 100000);
        expect(retur.refundMethod, RefundMethod.debt);
        var detail = await loadCustomerDetail(store, scope, ani.id, now: now);
        expect(
          detail.open.firstWhere((r) => r.sale.id == b.sale.id).outstanding,
          const Money(200000),
        );
        final session = (await findOpenCashSession(store, cashScope))!;
        expect(
          await sessionCashRefunds(
            store.session,
            tenantId: ctx.tenant.id,
            sessionId: session.id,
          ),
          Money.zero,
        );

        // Bayar 150.000 ke nota b, lalu retur 2 sak (200.000): 50.000
        // memotong piutang, 150.000 uang kembali tunai.
        await receiveDebtPayment(
          store,
          scope,
          staffId: owner(),
          request: DebtPaymentRequest(
            customerId: ani.id,
            amount: const Money(150000),
            method: PaymentMethod.transfer,
            paidOn: DateTime.utc(2026, 11, 3),
            allocations: {b.sale.id: const Money(150000)},
          ),
        );
        final retur2 = await returnSale(
          store,
          scope,
          staffId: owner(),
          saleId: b.sale.id,
          lines: [
            ReturnLine(saleItemId: b.items.single.id, quantity: Qty.units(2)),
          ],
          reason: SaleReturnReason.damaged,
          refundMethod: RefundMethod.cash,
          restock: true,
        );
        expect(retur2.debtReduction, 50000);
        expect(retur2.refundMethod, RefundMethod.cash);
        expect(
          await sessionCashRefunds(
            store.session,
            tenantId: ctx.tenant.id,
            sessionId: session.id,
          ),
          const Money(150000),
        );
        detail = await loadCustomerDetail(store, scope, ani.id, now: now);
        expect(detail.open.map((r) => r.sale.id), isNot(contains(b.sale.id)));

        // Riwayat: nota c belum lunas; nota b sudah dibayar → tidak bisa void.
        final page = await listSalesHistory(store, scope, now: now);
        final rowC = page.rows.firstWhere((r) => r.sale.id == c.sale.id);
        expect(rowC.outstanding, const Money(400000));
        final saleC = await loadSaleDetail(store, scope, c.sale.id, now: now);
        expect(saleC.outstanding, const Money(400000));
        expect(saleC.customerName, 'Toko Bu Ani');
        expect(saleC.voidBlock, isNull);
        await receiveDebtPayment(
          store,
          scope,
          staffId: owner(),
          request: DebtPaymentRequest(
            customerId: ani.id,
            amount: const Money(1000),
            method: PaymentMethod.transfer,
            paidOn: DateTime.utc(2026, 11, 3),
            allocations: {c.sale.id: const Money(1000)},
          ),
        );
        final saleC2 = await loadSaleDetail(store, scope, c.sale.id, now: now);
        expect(saleC2.voidBlock, VoidBlock.debtPaid);
      },
    );
  });

  test('import: buat, perbarui per HP, grup baru', () async {
    final ani = await customer('Toko Bu Ani', phone: '081322221010');
    final parsed = customerImportRows([
      ['nama', 'hp', 'grup', 'limit'],
      ['Toko Bu Ani (baru)', '0813-2222-1010', '', ''],
      ['Kantin SD 2', '085711112020', 'Grosir', '1.000.000'],
    ]);
    final summary = await importCustomers(
      store,
      scope,
      staffId: owner(),
      rows: parsed.rows,
    );
    expect(summary.created, 1);
    expect(summary.updated, 1);
    final overview = await listCustomers(store, scope, now: now);
    final updated = overview.rows.firstWhere((r) => r.customer.id == ani.id);
    expect(updated.customer.name, 'Toko Bu Ani (baru)');
    // Kolom kosong mempertahankan data lama.
    expect(updated.customer.creditLimit, 2000000);
    final kantin = overview.rows.firstWhere(
      (r) => r.customer.name == 'Kantin SD 2',
    );
    expect(kantin.groupName, 'Grosir');
    expect(kantin.termDays, 14);
    expect(kantin.customer.creditLimit, 1000000);
  });
}
