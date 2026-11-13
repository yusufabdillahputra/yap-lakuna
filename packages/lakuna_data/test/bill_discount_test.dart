import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

// Diskon nota di open bill F&B (F1-04e).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CatalogProduct kopi;
  late DiningTable m1;

  UuidValue owner() => ctx.owner.id;

  Future<StaffMember> addStaff(String name, String role) =>
      store.write(actor: owner(), (w) async {
        final s = await w.stamp();
        final staff = await w.insert(
          StaffMember(
            tenantId: ctx.tenant.id,
            name: name,
            pinHash: r'$argon2id$x',
            isActive: true,
            createdBy: owner(),
            updatedBy: owner(),
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
            createdBy: owner(),
            updatedBy: owner(),
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        return staff;
      });

  setUp(() async {
    now = DateTime.utc(2026, 11, 13, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Kopi Susu Aren',
        baseUnit: 'gelas',
        variants: [
          VariantDraft(
            costPrice: Money(9000),
            sellPrice: Money(25000),
            openingStock: Qty(20000),
          ),
        ],
      ),
    );
    kopi = (await loadProduct(store, scope, id))!;
    [m1] = await createDiningTables(
      store,
      scope,
      staffId: owner(),
      drafts: const [DiningTableDraft(name: 'M1')],
    );
    await saveFnbRates(
      store,
      scope,
      staffId: owner(),
      rates: const FnbRates(service: BasisPoints(500), tax: BasisPoints(1000)),
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

  Future<OpenBill> bill([int qty = 4]) async {
    final b = await openTableBill(
      store,
      scope,
      staffId: owner(),
      tableId: m1.id,
      guests: 2,
    );
    return addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.units(qty),
      ),
    );
  }

  Future<OpenBill> discount(
    OpenBill b,
    ManualDiscount? d, {
    UuidValue? staffId,
    UuidValue? approverId,
  }) => setBillDiscount(
    store,
    scope,
    staffId: staffId ?? owner(),
    billId: b.id,
    discount: d,
    approverId: approverId,
  );

  test(
    'diskon persen: service dan PB1 dari dasar, dibayar dan dicatat',
    () async {
      var b = await bill();
      b = await discount(b, const ManualDiscount.percent(BasisPoints(1000)));
      // 100.000 − 10.000 = 90.000; service 4.500; PB1 9.450.
      expect(b.discount, const ManualDiscount.percent(BasisPoints(1000)));
      expect(b.charges.discount, const Money(10000));
      expect(b.charges.total, const Money(103950));

      // Persen mengikuti item: 5 gelas → potongan 12.500.
      b = await setBillItemQuantity(
        store,
        scope,
        staffId: owner(),
        itemId: b.items.single.id,
        quantity: Qty.units(5),
      );
      expect(b.charges.discount, const Money(12500));

      final paid = await payOpenBill(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        payments: [SalePaymentRequest.cash(b.charges.total)],
      );
      expect(paid.sale.discountAmount, 12500);
      expect(paid.sale.discountBp, 1000);
      expect(paid.sale.discountApprovedBy, isNull);
      expect(paid.sale.total, b.charges.total.value);
      expect(paid.sale.serviceAmount, b.charges.service.value);
    },
  );

  test('rupiah, hapus diskon, dan total habis ditolak', () async {
    var b = await bill(1);
    await expectLater(
      discount(b, const ManualDiscount.amount(Money(30000))),
      throwsA(isA<DiscountTooLarge>()),
    );
    await expectLater(
      discount(b, const ManualDiscount.percent(BasisPoints.full)),
      throwsA(isA<DiscountTooLarge>()),
    );
    b = await discount(b, const ManualDiscount.amount(Money(5000)));
    expect(b.discount, const ManualDiscount.amount(Money(5000)));
    expect(b.charges.discount, const Money(5000));
    b = await discount(b, null);
    expect(b.discount, isNull);
    expect(b.charges.discount, Money.zero);
    expect(b.sale.discountApprovedBy, isNull);
  });

  test('izin: kasir butuh penyetuju, sakelar mati menolak', () async {
    final sari = await addStaff('Sari', 'cashier');
    final dimas = await addStaff('Dimas', 'cashier');
    final rina = await addStaff('Rina', 'manager');
    var b = await bill();
    const d = ManualDiscount.percent(BasisPoints(500));
    await expectLater(
      discount(b, d, staffId: sari.id),
      throwsA(isA<DiscountNotPermitted>()),
    );
    await expectLater(
      discount(b, d, staffId: sari.id, approverId: dimas.id),
      throwsA(isA<ApproverNotPermitted>()),
    );
    b = await discount(b, d, staffId: sari.id, approverId: rina.id);
    expect(b.sale.discountApprovedBy, rina.id);
    expect(b.discountApprovedByName, 'Rina');
    final paid = await payOpenBill(
      store,
      scope,
      staffId: sari.id,
      billId: b.id,
      payments: [SalePaymentRequest.cash(b.charges.total)],
    );
    expect(paid.sale.discountApprovedBy, rina.id);

    await saveSalesRules(
      store,
      scope,
      staffId: owner(),
      rules: const SalesRules(discountNeedsPin: false),
    );
    final b2 = await bill();
    await expectLater(
      discount(b2, d, staffId: sari.id, approverId: rina.id),
      throwsA(isA<DiscountNotPermitted>()),
    );
  });

  test('item berkurang sampai total habis: bayar ditolak', () async {
    var b = await bill(2);
    b = await discount(b, const ManualDiscount.amount(Money(40000)));
    b = await setBillItemQuantity(
      store,
      scope,
      staffId: owner(),
      itemId: b.items.single.id,
      quantity: Qty.units(1),
    );
    expect(b.charges.discount, const Money(25000));
    expect(b.charges.total, Money.zero);
    await expectLater(
      payOpenBill(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        payments: const [SalePaymentRequest.cash(Money(1000))],
      ),
      throwsA(isA<DiscountTooLarge>()),
    );
  });

  test(
    'split rata membagi total setelah diskon; terkunci setelah bayar',
    () async {
      var b = await bill();
      b = await discount(b, const ManualDiscount.amount(Money(10000)));
      b = await setBillSplit(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        mode: SplitMode.equal,
        guests: 2,
      );
      final total = b.charges.total;
      expect(total, const Money(103950));
      final first = await paySplitPart(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        guest: 'A',
        payments: const [SalePaymentRequest(method: PaymentMethod.card)],
      );
      expect(first.bill!.payments.single.amount, 51975);
      await expectLater(
        discount(first.bill!, null),
        throwsA(isA<SplitLocked>()),
      );
      final done = await paySplitPart(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        guest: 'B',
        payments: const [SalePaymentRequest(method: PaymentMethod.card)],
      );
      expect(done.receipt!.sale.discountAmount, 10000);
      expect(done.receipt!.sale.total, 103950);
    },
  );
}
