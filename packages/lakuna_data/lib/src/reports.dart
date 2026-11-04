import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession;

import 'customers.dart';
import 'expenses.dart';
import 'staff_access.dart';
import 'stock.dart';
import 'store.dart';

/// Staf tanpa `reports:view` (F1-16).
class ReportActorNotPermitted implements Exception {
  const ReportActorNotPermitted();

  @override
  String toString() => 'ReportActorNotPermitted';
}

/// Status nota yang dihitung di laporan (bukan void / open bill).
const reportSaleStatuses = {
  SaleStatus.completed,
  SaleStatus.partiallyReturned,
  SaleStatus.returned,
};

/// Data satu periode laporan beserta hasil hitungnya (F1-16). Angka laba
/// ([profit], [previousProfit]) hanya ada bila staf punya
/// `reports:view_profit`.
class ReportData {
  ReportData({
    required this.period,
    required this.range,
    required this.today,
    required this.outletName,
    required this.sales,
    required this.returns,
    required this.staffNames,
    required this.categoryOf,
    required this.unitOf,
    required this.overdue,
    required this.overdueCustomers,
    required this.profit,
    required this.previousProfit,
  });

  final ReportPeriod period;
  final DateRange range;

  /// Tanggal hari ini di cabang (UTC tengah malam).
  final DateTime today;
  final String outletName;
  final List<ReportSale> sales;
  final List<ReportReturn> returns;

  /// Kunci staf (uuid) → nama.
  final Map<String, String> staffNames;

  /// Kunci varian → nama kategori produk (null = tanpa kategori).
  final Map<String, String?> categoryOf;

  /// Kunci varian → nama satuan dasar.
  final Map<String, String> unitOf;

  /// Sisa piutang yang lewat jatuh tempo dan jumlah pelanggannya.
  final Money overdue;
  final int overdueCustomers;

  final ProfitAndLoss? profit;
  final ProfitAndLoss? previousProfit;

  bool get canViewProfit => profit != null;

  int get saleCount => sales.length;

  /// Penjualan bersih (tanpa PB1) sama dengan laba rugi.
  Money get netSales =>
      Money.sum(sales.map((s) => s.netContribution)) -
      Money.sum(returns.map((r) => r.netAmount));

  Money get averagePerSale =>
      saleCount == 0 ? Money.zero : Money(netSales.value ~/ saleCount);

  late final List<BreakdownRow> byProduct = salesByProduct(sales, returns);
  late final List<BreakdownRow> byCategory = salesByCategory(
    byProduct,
    categoryOf,
  );
  late final List<BreakdownRow> byStaff = salesByStaff(sales, returns);
  late final List<BreakdownRow> top = topProducts(byProduct);
  late final List<PaymentMixRow> payments = paymentMix(sales);
}

DateTime _startUtc(DateTime day, String? timezone) {
  final zone = setupTimezones.where((z) => z.id == timezone).firstOrNull;
  return zone == null
      ? DateTime(day.year, day.month, day.day).toUtc()
      : DateTime.utc(
          day.year,
          day.month,
          day.day,
        ).subtract(Duration(hours: zone.utcOffsetHours));
}

/// Rentang `[from, to)` UTC untuk tanggal lokal [range].
(DateTime, DateTime) _bounds(DateRange range, String? timezone) => (
  _startUtc(range.from, timezone),
  _startUtc(
    DateTime.utc(range.to.year, range.to.month, range.to.day + 1),
    timezone,
  ),
);

Iterable<Set<UuidValue>> _chunks(Iterable<UuidValue> ids) sync* {
  final list = ids.toSet().toList();
  for (var i = 0; i < list.length; i += 500) {
    yield list.skip(i).take(500).toSet();
  }
}

ReportPaymentMethod _method(PaymentMethod m) => switch (m) {
  PaymentMethod.cash => ReportPaymentMethod.cash,
  PaymentMethod.card => ReportPaymentMethod.card,
  PaymentMethod.transfer => ReportPaymentMethod.transfer,
  PaymentMethod.qrisStatic => ReportPaymentMethod.qris,
};

String _lineName(SaleItem i) =>
    i.variantName.isEmpty ? i.productName : '${i.productName} ${i.variantName}';

ReportSaleLine _line(SaleItem i, {required bool withCost}) => ReportSaleLine(
  key: i.id.uuid,
  variantKey: i.variantId.uuid,
  name: _lineName(i),
  quantityMilli: i.quantityMilli,
  factorMilli: i.factorMilli,
  lineTotal: Money(i.lineTotal),
  unitCost: withCost ? Money(i.unitCost) : Money.zero,
);

class _Facts {
  _Facts(this.sales, this.returns, this.variantIds, this.staffIds);

  final List<ReportSale> sales;
  final List<ReportReturn> returns;
  final Set<UuidValue> variantIds;
  final Set<UuidValue> staffIds;
}

Future<List<SaleItem>> _itemsOf(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<UuidValue> saleIds,
) async => [
  for (final ids in _chunks(saleIds))
    ...await SaleItem.db.find(
      session,
      where: (i) =>
          i.tenantId.equals(tenantId) &
          i.saleId.inSet(ids) &
          i.deletedAt.equals(null),
      orderBy: (i) => i.sortOrder,
    ),
];

Future<_Facts> _facts(
  DatabaseSession session,
  CatalogScope scope,
  DateRange range,
  String? timezone, {
  required bool withCost,
}) async {
  final (from, to) = _bounds(range, timezone);
  final sales = await Sale.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.status.inSet(reportSaleStatuses) &
        s.deletedAt.equals(null) &
        (s.soldAt >= from) &
        (s.soldAt < to),
  );
  final items = <UuidValue, List<SaleItem>>{};
  for (final i in await _itemsOf(session, scope.tenantId, {
    for (final s in sales) s.id,
  })) {
    items.putIfAbsent(i.saleId, () => []).add(i);
  }
  final payments = <UuidValue, List<Payment>>{};
  for (final ids in _chunks([for (final s in sales) s.id])) {
    for (final p in await Payment.db.find(
      session,
      where: (p) =>
          p.tenantId.equals(scope.tenantId) &
          p.saleId.inSet(ids) &
          p.status.equals(PaymentStatus.paid) &
          p.deletedAt.equals(null),
    )) {
      payments.putIfAbsent(p.saleId, () => []).add(p);
    }
  }

  final returnDocs = await SaleReturn.db.find(
    session,
    where: (r) =>
        r.tenantId.equals(scope.tenantId) &
        r.outletId.equals(scope.outletId) &
        r.deletedAt.equals(null) &
        (r.returnedAt >= from) &
        (r.returnedAt < to),
  );
  final returnItems = <UuidValue, List<SaleReturnItem>>{};
  for (final ids in _chunks([for (final r in returnDocs) r.id])) {
    for (final ri in await SaleReturnItem.db.find(
      session,
      where: (ri) =>
          ri.tenantId.equals(scope.tenantId) &
          ri.saleReturnId.inSet(ids) &
          ri.deletedAt.equals(null),
    )) {
      returnItems.putIfAbsent(ri.saleReturnId, () => []).add(ri);
    }
  }
  final saleById = {for (final s in sales) s.id: s};
  final missingSales = {
    for (final r in returnDocs)
      if (!saleById.containsKey(r.saleId)) r.saleId,
  };
  for (final ids in _chunks(missingSales)) {
    for (final s in await Sale.db.find(
      session,
      where: (s) => s.tenantId.equals(scope.tenantId) & s.id.inSet(ids),
    )) {
      saleById[s.id] = s;
    }
  }
  final itemById = {
    for (final list in items.values)
      for (final i in list) i.id: i,
  };
  for (final i in await _itemsOf(session, scope.tenantId, missingSales)) {
    itemById[i.id] = i;
  }

  final variantIds = <UuidValue>{};
  final staffIds = <UuidValue>{};
  final reportSales = <ReportSale>[];
  for (final s in sales) {
    final lines = items[s.id] ?? const <SaleItem>[];
    variantIds.addAll(lines.map((i) => i.variantId));
    staffIds.add(s.staffId);
    reportSales.add(
      ReportSale(
        staffKey: s.staffId.uuid,
        subtotal: Money(s.subtotal),
        tierDiscount: Money(s.tierDiscount),
        service: Money(s.serviceAmount),
        tax: Money(s.taxAmount),
        total: Money(s.total),
        credit: s.customerId != null && s.paidAmount < s.total,
        paidAtSale: Money(s.paidAmount),
        payments: [
          for (final p in payments[s.id] ?? const <Payment>[])
            ReportPayment(
              _method(p.method),
              Money(p.amount),
              Money(p.changeAmount),
            ),
        ],
        lines: [for (final i in lines) _line(i, withCost: withCost)],
      ),
    );
  }
  final reportReturns = <ReportReturn>[];
  for (final r in returnDocs) {
    final sale = saleById[r.saleId];
    if (sale == null) continue;
    staffIds.add(sale.staffId);
    final lines = <ReportReturnLine>[];
    for (final ri in returnItems[r.id] ?? const <SaleReturnItem>[]) {
      final item = itemById[ri.saleItemId];
      if (item == null) continue;
      variantIds.add(item.variantId);
      lines.add(
        ReportReturnLine(_line(item, withCost: withCost), ri.quantityMilli),
      );
    }
    reportReturns.add(
      ReportReturn(
        saleStaffKey: sale.staffId.uuid,
        amount: Money(r.amount),
        saleTax: Money(sale.taxAmount),
        saleTotal: Money(sale.total),
        restock: r.restock,
        lines: lines,
      ),
    );
  }
  return _Facts(reportSales, reportReturns, variantIds, staffIds);
}

Future<Money> _adjustmentValue(
  DatabaseSession session,
  CatalogScope scope,
  DateRange range,
  String? timezone,
) async {
  final (from, to) = _bounds(range, timezone);
  final docs = await StockAdjustment.db.find(
    session,
    where: (a) =>
        a.tenantId.equals(scope.tenantId) &
        a.outletId.equals(scope.outletId) &
        a.deletedAt.equals(null) &
        (a.adjustedAt >= from) &
        (a.adjustedAt < to),
  );
  return Money.sum(docs.map((d) => Money(d.totalValue)));
}

Future<ProfitAndLoss> _profit(
  LakunaStore store,
  CatalogScope scope,
  DateRange range,
  String? timezone,
  _Facts facts,
) async {
  final expenses = await listExpenses(store, scope, range);
  return ProfitAndLoss.compute(
    sales: facts.sales,
    returns: facts.returns,
    expenses: [
      for (final e in expenses)
        if (!e.voided) ExpenseLine(e.categoryName, Money(e.expense.amount)),
    ],
    stockAdjustment: await _adjustmentValue(
      store.session,
      scope,
      range,
      timezone,
    ),
  );
}

/// Laporan cabang ini untuk [period] (F1-16). Butuh `reports:view`; laba
/// hanya dihitung dengan `reports:view_profit`.
Future<ReportData> loadReport(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required ReportPeriod period,
  DateTime? now,
}) async {
  final staff = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: staffId,
  );
  final permissions = staff?.permissions ?? const <Permission>{};
  if (!permissions.contains(Permission.reportsView)) {
    throw const ReportActorNotPermitted();
  }
  final withProfit = permissions.contains(Permission.reportsViewProfit);
  final session = store.session;
  final outlet = await Outlet.db.findById(session, scope.outletId);
  final tenant = await Tenant.db.findById(session, scope.tenantId);
  final timezone = outlet?.timezone ?? tenant?.timezone;
  final today = await outletToday(
    session,
    scope,
    now ?? DateTime.now().toUtc(),
  );
  final range = period.range(today);
  final facts = await _facts(
    session,
    scope,
    range,
    timezone,
    withCost: withProfit,
  );

  ProfitAndLoss? profit;
  ProfitAndLoss? previous;
  if (withProfit) {
    profit = await _profit(store, scope, range, timezone, facts);
    final prevRange = period.previousRange(today);
    final prevFacts = await _facts(
      session,
      scope,
      prevRange,
      timezone,
      withCost: true,
    );
    previous = await _profit(store, scope, prevRange, timezone, prevFacts);
  }

  final staffNames = <String, String>{
    for (final ids in _chunks(facts.staffIds))
      for (final s in await StaffMember.db.find(
        session,
        where: (s) => s.tenantId.equals(scope.tenantId) & s.id.inSet(ids),
      ))
        s.id.uuid: s.name,
  };

  final categoryOf = <String, String?>{};
  final unitOf = <String, String>{};
  final variants = [
    for (final ids in _chunks(facts.variantIds))
      ...await ProductVariant.db.find(
        session,
        where: (v) => v.tenantId.equals(scope.tenantId) & v.id.inSet(ids),
      ),
  ];
  final products = {
    for (final ids in _chunks(variants.map((v) => v.productId)))
      for (final p in await Product.db.find(
        session,
        where: (p) => p.tenantId.equals(scope.tenantId) & p.id.inSet(ids),
      ))
        p.id: p,
  };
  final categories = {
    for (final ids in _chunks(
      products.values.map((p) => p.categoryId).nonNulls,
    ))
      for (final c in await ProductCategory.db.find(
        session,
        where: (c) => c.tenantId.equals(scope.tenantId) & c.id.inSet(ids),
      ))
        c.id: c.name,
  };
  final units = {
    for (final ids in _chunks(products.values.map((p) => p.baseUnitId)))
      for (final u in await MeasureUnit.db.find(
        session,
        where: (u) => u.tenantId.equals(scope.tenantId) & u.id.inSet(ids),
      ))
        u.id: u.name,
  };
  for (final v in variants) {
    final p = products[v.productId];
    if (p == null) continue;
    categoryOf[v.id.uuid] = categories[p.categoryId];
    if (units[p.baseUnitId] case final name?) unitOf[v.id.uuid] = name;
  }

  final (overdue, overdueCustomers) = await overdueReceivables(
    session,
    scope.tenantId,
    today,
  );

  return ReportData(
    period: period,
    range: range,
    today: today,
    outletName: outlet?.name ?? '',
    sales: facts.sales,
    returns: facts.returns,
    staffNames: staffNames,
    categoryOf: categoryOf,
    unitOf: unitOf,
    overdue: overdue,
    overdueCustomers: overdueCustomers,
    profit: profit,
    previousProfit: previous,
  );
}
