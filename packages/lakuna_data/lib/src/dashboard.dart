part of 'reports.dart';

/// Isi dashboard semua cabang 2.3 (F2-02 tahap 3): angka hari ini per
/// cabang dari fakta penjualan yang sama dengan Laporan.
class DashboardData {
  const DashboardData({
    required this.outlets,
    required this.outletNames,
    required this.top,
    required this.belowMinimum,
  });

  /// Cabang tenant, urut kode.
  final List<OutletDay> outlets;

  /// ID cabang (uuid) → nama.
  final Map<String, String> outletNames;

  /// Produk terlaris 7 hari terakhir, digabung dari semua cabang terpilih.
  final List<({String productId, String name, Qty sold})> top;

  /// ID cabang (uuid) → jumlah varian dengan stok ≤ minimum.
  final Map<String, int> belowMinimum;
}

/// Dashboard tenant [tenantId] pada [now]; [outletId] membatasi ke satu
/// cabang. "Hari ini" dan jam grafik mengikuti zona waktu masing-masing
/// cabang.
Future<DashboardData> loadDashboard(
  LakunaStore store, {
  required UuidValue tenantId,
  UuidValue? outletId,
  required DateTime now,
}) async {
  final session = store.session;
  final tenant = await Tenant.db.findById(session, tenantId);
  final outlets = [
    for (final o in await Outlet.db.find(
      session,
      where: (o) => o.tenantId.equals(tenantId) & o.deletedAt.equals(null),
      orderBy: (o) => o.code,
    ))
      if (outletId == null || o.id == outletId) o,
  ];
  final days = <OutletDay>[];
  final belowMinimum = <String, int>{};
  final variantQty = <String, int>{};
  for (final outlet in outlets) {
    final scope = CatalogScope(
      tenantId: tenantId,
      outletId: outlet.id,
      deviceId: store.deviceId,
    );
    final timezone = outlet.timezone ?? tenant?.timezone;
    final today = await outletToday(session, scope, now);
    final facts = await _facts(
      session,
      scope,
      DateRange(today, today),
      timezone,
      withCost: false,
    );
    final hourly = List<Money>.filled(24, Money.zero);
    for (var i = 0; i < facts.sales.length; i++) {
      final h = outletLocalTime(facts.saleTimes[i], timezone).hour;
      hourly[h] += facts.sales[i].netContribution;
    }
    for (var i = 0; i < facts.returns.length; i++) {
      final h = outletLocalTime(facts.returnTimes[i], timezone).hour;
      hourly[h] -= facts.returns[i].netAmount;
    }
    days.add(
      OutletDay(
        outletId: outlet.id.uuid,
        sales: Money.sum(hourly),
        transactions: facts.sales.length,
        hourly: hourly,
      ),
    );

    final week = await _facts(
      session,
      scope,
      DateRange(today.subtract(const Duration(days: 6)), today),
      timezone,
      withCost: false,
    );
    for (final row in salesByProduct(week.sales, week.returns)) {
      variantQty[row.key] = (variantQty[row.key] ?? 0) + row.quantity.milli;
    }
    belowMinimum[outlet.id.uuid] = (await belowMinimumStock(
      store,
      scope,
    )).length;
  }

  final variants = [
    for (final ids in _chunks(variantQty.keys.map(UuidValue.fromString)))
      ...await ProductVariant.db.find(
        session,
        where: (v) => v.tenantId.equals(tenantId) & v.id.inSet(ids),
      ),
  ];
  final products = {
    for (final ids in _chunks(variants.map((v) => v.productId)))
      for (final p in await Product.db.find(
        session,
        where: (p) => p.tenantId.equals(tenantId) & p.id.inSet(ids),
      ))
        p.id: p,
  };
  final lines = [
    for (final v in variants)
      if (products[v.productId] case final p?)
        (
          productId: p.id.uuid,
          name: p.name,
          qty: Qty(variantQty[v.id.uuid] ?? 0),
        ),
  ];

  return DashboardData(
    outlets: days,
    outletNames: {for (final o in outlets) o.id.uuid: o.name},
    top: topSellingProducts([
      for (final l in lines)
        if (l.qty.isPositive) l,
    ]),
    belowMinimum: belowMinimum,
  );
}
