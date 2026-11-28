import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Kueri dashboard semua cabang 2.3 (F2-02 tugas 13).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope pusat;
  late CatalogScope timur;
  late DateTime now;
  late CatalogProduct kopi;
  late CatalogProduct pulsa;

  UuidValue owner() => ctx.owner.id;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, pusat, staffId: owner(), draft: draft);
    return (await loadProduct(store, pusat, id))!;
  }

  Future<Outlet> addOutlet(UuidValue tenantId, String code, String tz) {
    final actor = owner();
    return store.write(actor: actor, (w) async {
      final s = await w.stamp();
      final outlet = await w.insert(
        Outlet(
          tenantId: tenantId,
          code: code,
          name: code,
          timezone: tz,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      await w.insert(
        StockLocation(
          tenantId: tenantId,
          outletId: outlet.id,
          name: defaultStockLocationName,
          isDefault: true,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      return outlet;
    });
  }

  Future<CheckoutResult> sell(
    CatalogScope scope,
    CatalogProduct p,
    int milli,
  ) => checkoutSale(
    store,
    scope,
    staffId: owner(),
    lines: [
      SaleLineRequest(variantId: p.variants.single.id, quantity: Qty(milli)),
    ],
    payments: [const SalePaymentRequest.cash(Money(1000000))],
  );

  Future<Money> reportSales(CatalogScope scope) async => (await buildReport(
    store,
    scope,
    permissions: {Permission.reportsView},
    period: ReportPeriod.today,
    now: now,
  )).netSales;

  setUp(() async {
    // 14.30Z = 21.30 WIB tanggal 3 = 23.30 WIT tanggal 3.
    now = DateTime.utc(2026, 11, 3, 14, 30);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    pusat = CatalogScope.of(ctx);
    final outlet = await addOutlet(ctx.tenant.id, 'TMR', 'Asia/Jayapura');
    timur = CatalogScope(
      tenantId: ctx.tenant.id,
      outletId: outlet.id,
      deviceId: pusat.deviceId,
    );
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Bubuk',
        baseUnit: 'pcs',
        variants: [
          VariantDraft(
            sellPrice: Money(10000),
            openingStock: Qty(20000),
            minStock: Qty(50000),
          ),
        ],
      ),
    );
    pulsa = await product(
      const ProductDraft(
        name: 'Isi Pulsa',
        kind: ProductKind.service,
        baseUnit: 'kali',
        variants: [VariantDraft(sellPrice: Money(2000))],
      ),
    );
    for (final o in [ctx.outlet.id, outlet.id]) {
      await openCashSession(
        store,
        CashScope(
          tenantId: ctx.tenant.id,
          outletId: o,
          deviceId: ctx.device.id,
        ),
        staffId: owner(),
        openingCash: const Money(100000),
      );
    }
    // Cabang timur: kemarin (23.30 WIT). Pusat: hari ini (21.30 WIB).
    await sell(timur, pulsa, 1000);
    await sell(pusat, kopi, 1000);
    // 16.30Z = 23.30 WIB tanggal 3 = 01.30 WIT tanggal 4.
    now = DateTime.utc(2026, 11, 3, 16, 30);
    final a = await sell(pusat, kopi, 2000);
    final b = await sell(pusat, kopi, 1000);
    await voidSale(
      store,
      pusat,
      staffId: owner(),
      approverId: owner(),
      saleId: b.sale.id,
      reason: 'Salah input',
      now: now,
    );
    await returnSale(
      store,
      pusat,
      staffId: owner(),
      saleId: a.sale.id,
      lines: [ReturnLine(saleItemId: a.items.single.id, quantity: Qty.one)],
      reason: SaleReturnReason.wrongItem,
      refundMethod: RefundMethod.cash,
      restock: true,
    );
    await sell(timur, pulsa, 3000);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('penjualan dan nota hari ini per cabang = Laporan cabang itu', () async {
    final d = await loadDashboard(store, tenantId: ctx.tenant.id, now: now);
    final byId = {for (final o in d.outlets) o.outletId: o};
    expect(byId.keys, {ctx.outlet.id.uuid, timur.outletId.uuid});
    final p = byId[ctx.outlet.id.uuid]!;
    final t = byId[timur.outletId.uuid]!;
    expect(p.sales, await reportSales(pusat));
    expect(p.sales, const Money(20000));
    expect(p.transactions, 2);
    expect(t.sales, await reportSales(timur));
    expect(t.sales, const Money(6000));
    expect(t.transactions, 1);
    // Jam dinding cabang: 01.30 WIT, 21.30 + 23.30 WIB (retur di 23.xx).
    expect(t.hourly[1], const Money(6000));
    expect(p.hourly[21], const Money(10000));
    expect(p.hourly[23], const Money(10000));
  });

  test(
    'outletId membatasi satu cabang; cabang tenant lain tidak ikut',
    () async {
      final other = await Tenant.db.insertRow(
        store.session,
        Tenant(name: 'Toko lain', hlc: '0000000000000-0000-test'),
      );
      await addOutlet(other.id, 'LAIN', 'Asia/Jakarta');
      final all = await loadDashboard(store, tenantId: ctx.tenant.id, now: now);
      expect(all.outlets, hasLength(2));
      final one = await loadDashboard(
        store,
        tenantId: ctx.tenant.id,
        outletId: timur.outletId,
        now: now,
      );
      expect(one.outlets.map((o) => o.outletId), [timur.outletId.uuid]);
      expect(one.top.map((t) => t.name), ['Isi Pulsa']);
    },
  );

  test('terlaris 7 hari digabung dari semua cabang', () async {
    final d = await loadDashboard(store, tenantId: ctx.tenant.id, now: now);
    expect(d.top.map((t) => (t.name, t.sold)), [
      ('Isi Pulsa', const Qty(4000)),
      ('Kopi Bubuk', const Qty(2000)),
    ]);
  });

  test('stok di bawah minimum dihitung per cabang', () async {
    final d = await loadDashboard(store, tenantId: ctx.tenant.id, now: now);
    expect(d.belowMinimum[ctx.outlet.id.uuid], 1);
    expect(
      d.belowMinimum[timur.outletId.uuid],
      (await belowMinimumStock(store, timur)).length,
    );
  });
}
