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
  late CatalogProduct teh;
  late CatalogProduct kopi;

  UuidValue owner() => ctx.owner.id;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: owner(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

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

  SaleLineRequest line(
    CatalogProduct p, [
    int qty = 1,
    ManualDiscount? discount,
  ]) => SaleLineRequest(
    variantId: p.variants.single.id,
    quantity: Qty(qty * 1000),
    discount: discount,
  );

  setUp(() async {
    now = DateTime.utc(2026, 11, 4, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    teh = await product(
      const ProductDraft(
        name: 'Teh Botol',
        baseUnit: 'botol',
        variants: [
          VariantDraft(
            costPrice: Money(3000),
            sellPrice: Money(4150),
            openingStock: Qty(10000),
          ),
        ],
      ),
    );
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Sachet',
        baseUnit: 'sachet',
        variants: [
          VariantDraft(
            costPrice: Money(1500),
            sellPrice: Money(2000),
            openingStock: Qty(10000),
          ),
        ],
      ),
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

  Future<CheckoutResult> sell({
    UuidValue? staffId,
    List<SaleLineRequest>? lines,
    ManualDiscount? discount,
    UuidValue? approverId,
    Money pay = const Money(100000),
  }) => checkoutSale(
    store,
    scope,
    staffId: staffId ?? owner(),
    lines:
        lines ??
        [line(teh, 2, const ManualDiscount.percent(BasisPoints(1000)))],
    payments: [SalePaymentRequest.cash(pay)],
    discount: discount,
    discountApproverId: approverId,
  );

  group('checkout dengan diskon manual', () {
    test('diskon baris 10% + diskon nota Rp 470', () async {
      // 4.150 × 2 = 8.300; diskon 10% = 830 → 7.470; nota − 470 = 7.000.
      final r = await sell(
        lines: [line(teh, 2, const ManualDiscount.percent(BasisPoints(1000)))],
        discount: const ManualDiscount.amount(Money(470)),
      );
      final item = r.items.single;
      expect(item.discountAmount, 830);
      expect(item.discountBp, 1000);
      expect(item.lineTotal, 7470);
      expect(r.sale.subtotal, 8300);
      expect(r.sale.lineDiscountAmount, 830);
      expect(r.sale.discountAmount, 470);
      expect(r.sale.discountBp, 0);
      expect(r.sale.discountApprovedBy, isNull);
      expect(r.sale.total, 7000);
      expect(r.sale.changeAmount, 93000);
    });

    test('diskon nota persen dihitung sebelum pembulatan', () async {
      await saveSalesRules(
        store,
        scope,
        staffId: owner(),
        rules: const SalesRules(rounding: TotalRounding.nearest500),
      );
      // 4.150 + 2.000 = 6.150; 5% = 308 (307,5 naik) → 5.842 → 6.000.
      final r = await sell(
        lines: [line(teh), line(kopi)],
        discount: const ManualDiscount.percent(BasisPoints(500)),
      );
      expect(r.sale.discountAmount, 308);
      expect(r.sale.discountBp, 500);
      expect(r.sale.roundingAmount, 158);
      expect(r.sale.total, 6000);
    });

    test('diskon terlalu besar ditolak tanpa menulis nota', () async {
      final before = await Sale.db.count(store.session);
      await expectLater(
        sell(
          lines: [line(kopi)],
          discount: const ManualDiscount.amount(Money(2500)),
        ),
        throwsA(isA<DiscountTooLarge>()),
      );
      await expectLater(
        sell(
          lines: [line(kopi)],
          discount: const ManualDiscount.percent(BasisPoints.full),
        ),
        throwsA(isA<DiscountTooLarge>()),
      );
      await expectLater(
        sell(lines: [line(kopi, 1, const ManualDiscount.amount(Money(2500)))]),
        throwsA(isA<DiscountTooLarge>()),
      );
      // Baris 100% boleh selama nota masih bernilai.
      final ok = await sell(
        lines: [
          line(kopi, 1, const ManualDiscount.percent(BasisPoints.full)),
          line(teh),
        ],
      );
      expect(ok.sale.total, 4150);
      expect(await Sale.db.count(store.session), before + 1);
    });
  });

  group('batas dan dasar diskon', () {
    test('total yang dibulatkan jadi nol ditolak', () async {
      await saveSalesRules(
        store,
        scope,
        staffId: owner(),
        rules: const SalesRules(rounding: TotalRounding.nearest500),
      );
      // 2.000 − 1.800 = 200 → dibulatkan ke 0.
      await expectLater(
        sell(
          lines: [line(kopi)],
          discount: const ManualDiscount.amount(Money(1800)),
        ),
        throwsA(isA<DiscountTooLarge>()),
      );
    });

    test('dasar diskon baris adalah total setelah harga grosir', () async {
      final grosir = await product(
        const ProductDraft(
          name: 'Gula',
          baseUnit: 'kg',
          variants: [
            VariantDraft(
              costPrice: Money(12000),
              sellPrice: Money(15000),
              openingStock: Qty(20000),
              tiers: [PriceTier(minQty: Qty(5000), price: Money(14000))],
            ),
          ],
        ),
      );
      // 5 × 14.000 = 70.000 (grosir); 10% = 7.000 → 63.000.
      final r = await sell(
        lines: [
          line(grosir, 5, const ManualDiscount.percent(BasisPoints(1000))),
        ],
      );
      expect(r.sale.subtotal, 75000);
      expect(r.items.single.discountAmount, 7000);
      expect(r.items.single.lineTotal, 63000);
      expect(r.sale.total, 63000);
    });
  });

  group('izin diskon', () {
    test('kasir butuh penyetuju ber-sales:discount', () async {
      final sari = await addStaff('Sari', 'cashier');
      final dimas = await addStaff('Dimas', 'cashier');
      final rina = await addStaff('Rina', 'manager');
      await expectLater(
        sell(staffId: sari.id),
        throwsA(isA<DiscountNotPermitted>()),
      );
      await expectLater(
        sell(staffId: sari.id, approverId: dimas.id),
        throwsA(isA<ApproverNotPermitted>()),
      );
      final r = await sell(staffId: sari.id, approverId: rina.id);
      expect(r.sale.discountApprovedBy, rina.id);
      // Tanpa diskon, kasir tidak butuh penyetuju.
      final plain = await sell(staffId: sari.id, lines: [line(teh)]);
      expect(plain.sale.discountApprovedBy, isNull);
    });

    test('sakelar PIN mati: hanya staf berizin', () async {
      await saveSalesRules(
        store,
        scope,
        staffId: owner(),
        rules: const SalesRules(discountNeedsPin: false),
      );
      final sari = await addStaff('Sari', 'cashier');
      final rina = await addStaff('Rina', 'manager');
      await expectLater(
        sell(staffId: sari.id, approverId: rina.id),
        throwsA(isA<DiscountNotPermitted>()),
      );
      final byRina = await sell(staffId: rina.id);
      expect(byRina.sale.lineDiscountAmount, 830);
    });
  });

  test('retur nota berdiskon: nilai dibagi dari total nota', () async {
    final r = await sell(
      lines: [line(teh, 2)],
      discount: const ManualDiscount.amount(Money(300)),
    );
    // 8.300 − 300 = 8.000; satu botol = 4.000.
    final detail = await loadSaleDetail(store, scope, r.sale.id);
    final item = detail.items.single;
    expect(detail.returnValue(item, 1000), const Money(4000));
  });

  test('laba rugi: diskon manual masuk ke Diskon', () async {
    await sell(
      lines: [line(teh, 2, const ManualDiscount.percent(BasisPoints(1000)))],
      discount: const ManualDiscount.amount(Money(470)),
    );
    final report = await loadReport(
      store,
      scope,
      staffId: owner(),
      period: ReportPeriod.today,
      now: now,
    );
    final pl = report.profit!;
    expect(pl.grossSales, const Money(8300));
    expect(pl.discount, const Money(1300));
    expect(pl.netSales, const Money(7000));
  });
}
