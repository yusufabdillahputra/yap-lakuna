import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Kredit untuk bagian terakhir split bill (F1-13h).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CatalogProduct kopi;
  late CatalogProduct nasi;
  late DiningTable m1;

  UuidValue owner() => ctx.owner.id;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: owner(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

  SaleLineRequest line(CatalogProduct p, [int qty = 1]) => SaleLineRequest(
    variantId: p.variants.single.id,
    quantity: Qty(qty * 1000),
  );

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

  Future<Customer> customer(String name, {int limit = 2000000}) => saveCustomer(
    store,
    scope,
    staffId: owner(),
    input: CustomerInput(name: name, creditLimit: Money(limit)),
  );

  setUp(() async {
    // 2026-11-03 09.00 UTC = 16.00 WIB.
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    await saveFnbRates(
      store,
      scope,
      staffId: owner(),
      rates: const FnbRates(service: BasisPoints.zero, tax: BasisPoints.zero),
    );
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Susu Aren',
        baseUnit: 'gelas',
        variants: [
          VariantDraft(
            costPrice: Money(9000),
            sellPrice: Money(24000),
            openingStock: Qty(10000),
          ),
        ],
      ),
    );
    nasi = await product(
      const ProductDraft(
        name: 'Nasi Goreng',
        kind: ProductKind.service,
        baseUnit: 'porsi',
        variants: [VariantDraft(sellPrice: Money(31000))],
      ),
    );
    [m1] = await createDiningTables(
      store,
      scope,
      staffId: owner(),
      drafts: const [DiningTableDraft(name: 'M1')],
    );
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: Money.zero,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  /// Kopi 1 × 24.000 + nasi 1 × 31.000 = 55.000.
  Future<OpenBill> bill() async {
    var b = await openTableBill(
      store,
      scope,
      staffId: owner(),
      tableId: m1.id,
      guests: 2,
    );
    for (final p in [kopi, nasi]) {
      b = await addBillItem(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        line: line(p),
      );
    }
    return b;
  }

  Future<OpenBill> split(OpenBill b, SplitMode mode, [int guests = 2]) =>
      setBillSplit(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        mode: mode,
        guests: guests,
      );

  Future<SplitPayResult> pay(
    OpenBill b, {
    String? guest,
    Money? amount,
    List<SalePaymentRequest> payments = const [
      SalePaymentRequest(method: PaymentMethod.card),
    ],
    SaleCredit? credit,
    UuidValue? staffId,
    bool pending = false,
  }) => paySplitPart(
    store,
    scope,
    staffId: staffId ?? owner(),
    billId: b.id,
    guest: guest,
    amount: amount,
    payments: payments,
    credit: credit,
    pending: pending,
  );

  SaleCredit credit(Customer c, {int down = 0}) => SaleCredit(
    customerId: c.id,
    downPayment: Money(down),
    dueOn: DateTime.utc(2026, 11, 17),
  );

  Matcher splitError(SplitError e) =>
      throwsA(isA<SplitInvalid>().having((x) => x.error, 'error', e));

  Future<Money> outstanding(Customer c) async => (await listCustomers(
    store,
    scope,
    now: now,
  )).rows.singleWhere((r) => r.customer.id == c.id).outstanding;

  test('bagi rata: bagian terakhir jadi nota kredit dengan DP', () async {
    final ani = await customer('Bu Ani');
    var b = await split(await bill(), SplitMode.equal);
    expect(
      [for (final p in b.split!.parts) p.due],
      [const Money(27500), const Money(27500)],
    );
    // Tamu B belum bayar: kredit A ditolak.
    await expectLater(
      pay(b, guest: 'A', payments: const [], credit: credit(ani)),
      splitError(SplitError.creditNotLast),
    );
    b = (await pay(b, guest: 'A')).bill!;
    final done = await pay(
      b,
      guest: 'B',
      payments: const [],
      credit: credit(ani, down: 7500),
    );
    final sale = done.receipt!.sale;
    expect(sale.status, SaleStatus.completed);
    expect(sale.number, isNotEmpty);
    expect(sale.customerId, ani.id);
    expect(sale.customerName, 'Bu Ani');
    expect(sale.dueOn, DateTime.utc(2026, 11, 17));
    expect(sale.total, 55000);
    // Bagian A (kartu) + DP bagian B.
    expect(sale.paidAmount, 35000);
    expect(
      [
        for (final p in done.receipt!.payments)
          (p.guestLabel, p.method, p.amount),
      ],
      [('A', PaymentMethod.card, 27500), ('B', PaymentMethod.cash, 7500)],
    );
    expect(await outstanding(ani), const Money(20000));
    final stock = await stockOnHand(
      store,
      scope,
      variantId: kopi.variants.single.id,
    );
    expect(stock, const Qty(9000));
  });

  test('per item dan tanpa DP: piutang = tagihan bagian', () async {
    final ani = await customer('Bu Ani');
    var b = await split(await bill(), SplitMode.item);
    for (final (p, g) in [(kopi, 'A'), (nasi, 'B')]) {
      b = await assignPortion(
        store,
        scope,
        staffId: owner(),
        itemId: b.items.where((i) => i.productName == p.name).single.id,
        guest: g,
      );
    }
    b = (await pay(b, guest: 'B')).bill!;
    final done = await pay(
      b,
      guest: 'A',
      payments: const [],
      credit: credit(ani),
    );
    expect(done.receipt!.sale.paidAmount, 31000);
    expect(done.receipt!.payments.map((p) => p.guestLabel), ['B']);
    expect(await outstanding(ani), const Money(24000));
  });

  test('nominal bebas: hanya sebesar sisa tagihan', () async {
    final ani = await customer('Bu Ani');
    var b = await split(await bill(), SplitMode.amount);
    b = (await pay(b, amount: const Money(20000))).bill!;
    await expectLater(
      pay(
        b,
        amount: const Money(10000),
        payments: const [],
        credit: credit(ani),
      ),
      splitError(SplitError.creditNotLast),
    );
    final done = await pay(
      b,
      amount: const Money(35000),
      payments: const [],
      credit: credit(ani, down: 5000),
    );
    expect(done.receipt!.sale.paidAmount, 25000);
    expect(await outstanding(ani), const Money(30000));
  });

  test('QRIS menunggu di bagian lain: kredit ditolak', () async {
    await saveQrisSettings(
      store,
      scope,
      staffId: owner(),
      settings: const QrisStaticSettings(enabled: true),
      image: QrisImageUpload(bytes: pngBytes(1080, 1528), fileName: 'q.png'),
    );
    final ani = await customer('Bu Ani');
    var b = await split(await bill(), SplitMode.equal);
    b = (await pay(
      b,
      guest: 'A',
      payments: const [SalePaymentRequest(method: PaymentMethod.qrisStatic)],
      pending: true,
    )).bill!;
    await expectLater(
      pay(b, guest: 'B', payments: const [], credit: credit(ani)),
      splitError(SplitError.creditNotLast),
    );
  });

  test('limit dihitung dari tagihan bagian; penolakan lain', () async {
    // Limit 20.000: bagian 27.500 − DP 7.500 = 20.000 boleh.
    final ani = await customer('Bu Ani', limit: 20000);
    var b = await split(await bill(), SplitMode.equal);
    b = (await pay(b, guest: 'A')).bill!;
    await expectLater(
      pay(b, guest: 'B', payments: const [], credit: credit(ani)),
      throwsA(
        isA<SaleCreditInvalid>().having(
          (e) => e.issue,
          'issue',
          CreditIssue.overLimit,
        ),
      ),
    );
    await expectLater(
      pay(
        b,
        guest: 'B',
        payments: const [SalePaymentRequest(method: PaymentMethod.card)],
        credit: credit(ani),
      ),
      throwsA(isA<SalePaymentInvalid>()),
    );
    final pelayan = await addStaff('Wawan', 'waiter');
    await expectLater(
      pay(
        b,
        guest: 'B',
        payments: const [],
        credit: credit(ani, down: 7500),
        staffId: pelayan.id,
      ),
      throwsA(isA<CustomerActorNotPermitted>()),
    );
    // Bill tetap terbuka setelah semua penolakan.
    final done = await pay(
      b,
      guest: 'B',
      payments: const [],
      credit: credit(ani, down: 7500),
    );
    expect(done.receipt!.sale.paidAmount, 35000);
  });

  test('pelanggan bill harus sama dengan pelanggan kredit', () async {
    final ani = await customer('Bu Ani');
    final budi = await customer('Pak Budi');
    var b = await bill();
    b = await setOpenBillCustomer(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      customerId: ani.id,
    );
    b = await split(b, SplitMode.equal);
    b = (await pay(b, guest: 'A')).bill!;
    await expectLater(
      pay(b, guest: 'B', payments: const [], credit: credit(budi)),
      throwsA(isA<BillCustomerMismatch>()),
    );
    final done = await pay(
      b,
      guest: 'B',
      payments: const [],
      credit: credit(ani),
    );
    expect(done.receipt!.sale.customerId, ani.id);
  });

  test('DP dibanding tagihan bagian, bukan total bill', () async {
    final ani = await customer('Bu Ani');
    var b = await split(await bill(), SplitMode.equal);
    b = (await pay(b, guest: 'A')).bill!;
    // DP 30.000 < total 55.000 tapi ≥ bagian 27.500.
    await expectLater(
      pay(b, guest: 'B', payments: const [], credit: credit(ani, down: 30000)),
      throwsA(
        isA<SaleCreditInvalid>().having(
          (e) => e.issue,
          'issue',
          CreditIssue.downPayment,
        ),
      ),
    );
  });

  test('kembalian bagian lain tidak ikut paid_amount', () async {
    final ani = await customer('Bu Ani');
    var b = await split(await bill(), SplitMode.equal);
    b = (await pay(
      b,
      guest: 'A',
      payments: const [
        SalePaymentRequest(method: PaymentMethod.cash, amount: Money(50000)),
      ],
    )).bill!;
    final done = await pay(
      b,
      guest: 'B',
      payments: const [],
      credit: credit(ani, down: 2500),
    );
    final sale = done.receipt!.sale;
    expect(sale.paidAmount, 27500 + 2500);
    expect(sale.changeAmount, 22500);
    expect(await outstanding(ani), const Money(25000));
  });
}
