part of 'reports.dart';

// Tab laporan lanjutan (F1-16 v0.21.0): Stok, Kas & sesi, Piutang & hutang,
// Retur. Dimuat saat tab dibuka; izin sama dengan [buildReport].

/// Zona waktu, hari ini, dan izin laba untuk satu muatan tab.
class _Context {
  const _Context(this.timezone, this.today, this.withProfit);

  final String? timezone;
  final DateTime today;
  final bool withProfit;
}

Future<_Context> _context(
  LakunaStore store,
  CatalogScope scope,
  Set<Permission> permissions,
  DateTime? now,
) async {
  if (!permissions.contains(Permission.reportsView)) {
    throw const ReportActorNotPermitted();
  }
  final session = store.session;
  final outlet = await Outlet.db.findById(session, scope.outletId);
  final tenant = await Tenant.db.findById(session, scope.tenantId);
  return _Context(
    outlet?.timezone ?? tenant?.timezone,
    await outletToday(session, scope, now ?? DateTime.now().toUtc()),
    permissions.contains(Permission.reportsViewProfit),
  );
}

Future<Map<UuidValue, String>> _staffNames(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<UuidValue> ids,
) async => {
  for (final chunk in _chunks(ids))
    for (final s in await StaffMember.db.find(
      session,
      where: (s) => s.tenantId.equals(tenantId) & s.id.inSet(chunk),
    ))
      s.id: s.name,
};

// --- Stok -------------------------------------------------------------------

/// Tab Stok: kartu stok ringkas periode semua lokasi cabang ini.
class StockReport {
  const StockReport({
    required this.rows,
    required this.unitOf,
    required this.variantCount,
    required this.lowCount,
    required this.outCount,
    this.totalValue,
  });

  /// Varian barang yang punya stok atau pergerakan pada periode.
  final List<StockMovementRow> rows;

  /// Satuan dasar per kunci varian.
  final Map<String, String> unitOf;

  /// Jumlah varian barang.
  final int variantCount;

  /// 0 < stok ≤ minimum (minimum > 0).
  final int lowCount;

  /// Stok ≤ 0.
  final int outCount;

  /// Nilai stok saat ini; `null` tanpa `reports:view_profit`.
  final Money? totalValue;
}

Future<StockReport> loadStockReport(
  LakunaStore store,
  CatalogScope scope, {
  required Set<Permission> permissions,
  required ReportPeriod period,
  DateTime? now,
}) async {
  final ctx = await _context(store, scope, permissions, now);
  final session = store.session;
  final products = {
    for (final p in await Product.db.find(
      session,
      where: (p) =>
          p.tenantId.equals(scope.tenantId) &
          p.deletedAt.equals(null) &
          p.type.equals(ProductType.goods),
    ))
      p.id: p,
  };
  final variants = [
    for (final ids in _chunks(products.keys))
      ...await ProductVariant.db.find(
        session,
        where: (v) =>
            v.tenantId.equals(scope.tenantId) &
            v.deletedAt.equals(null) &
            v.productId.inSet(ids),
      ),
  ];
  final locations = await StockLocation.db.find(
    session,
    where: (l) =>
        l.tenantId.equals(scope.tenantId) &
        l.outletId.equals(scope.outletId) &
        l.deletedAt.equals(null),
  );
  final locationIds = {for (final l in locations) l.id};
  final levels = locationIds.isEmpty
      ? const <StockLevel>[]
      : await StockLevel.db.find(
          session,
          where: (l) => l.stockLocationId.inSet(locationIds),
        );
  final units = {
    for (final u in await MeasureUnit.db.find(
      session,
      where: (u) => u.tenantId.equals(scope.tenantId),
    ))
      u.id: u.name,
  };

  final variantById = {for (final v in variants) v.id: v};
  final levelsOf = <UuidValue, List<StockLevel>>{};
  for (final l in levels) {
    if (variantById.containsKey(l.variantId)) {
      levelsOf.putIfAbsent(l.variantId, () => []).add(l);
    }
  }
  // Lokasi bawaan seperti `defaultStockLocation`: `isDefault`, atau yang
  // tertua.
  final defaultId =
      (locations.where((l) => l.isDefault).firstOrNull ??
              (locations.toList()
                    ..sort((a, b) => a.createdAt.compareTo(b.createdAt)))
                  .firstOrNull)
          ?.id;

  final names = <String, String>{};
  final unitOf = <String, String>{};
  final current = <String, int>{};
  final valueNow = <String, Money>{};
  final fallback = <String, Money>{};
  var totalValue = Money.zero;
  var low = 0;
  var out = 0;
  for (final v in variants) {
    final p = products[v.productId]!;
    final key = v.id.uuid;
    names[key] = v.name.isEmpty ? p.name : '${p.name} ${v.name}';
    if (units[p.baseUnitId] case final unit?) unitOf[key] = unit;
    final own = levelsOf[v.id] ?? const <StockLevel>[];
    Money costAt(StockLevel? l) => adjustmentUnitCost(
      avgCost: Money(l?.avgCost ?? 0),
      costPrice: Money(v.costPrice),
    );
    var qty = 0;
    var value = Money.zero;
    for (final l in own) {
      qty += l.quantityMilli;
      value += costAt(l).timesMilli(l.quantityMilli);
    }
    current[key] = qty;
    valueNow[key] = value;
    final atDefault = own
        .where((l) => l.stockLocationId == defaultId)
        .firstOrNull;
    fallback[key] = costAt(atDefault);
    totalValue += value;
    // Sama dengan layar Stok (1.18): minimum berlaku di lokasi bawaan.
    final here = atDefault?.quantityMilli ?? 0;
    if (here <= 0) {
      out++;
    } else if (v.minStockMilli > 0 && here <= v.minStockMilli) {
      low++;
    }
  }

  final (start, end) = _bounds(period.range(ctx.today), ctx.timezone);
  // Hanya pergerakan sejak awal periode; awal dihitung mundur dari stok
  // saat ini.
  final moves = [
    for (final ids in _chunks(variants.map((v) => v.id)))
      for (final m in await StockMovement.db.find(
        session,
        where: (m) =>
            m.tenantId.equals(scope.tenantId) &
            m.outletId.equals(scope.outletId) &
            m.deletedAt.equals(null) &
            m.variantId.inSet(ids) &
            (m.occurredAt >= start),
      ))
        StockMove(
          key: m.variantId.uuid,
          quantityMilli: m.quantityMilli,
          at: m.occurredAt,
        ),
  ];
  return StockReport(
    rows: stockMovementRows(
      moves: moves,
      start: start,
      end: end,
      names: names,
      current: current,
      valueOf: ctx.withProfit
          ? (key, qty) => stockValueOf(
              value: valueNow[key]!,
              current: Qty(current[key]!),
              qty: qty,
              fallback: fallback[key]!,
            )
          : null,
    ),
    unitOf: unitOf,
    variantCount: variants.length,
    lowCount: low,
    outCount: out,
    totalValue: ctx.withProfit ? totalValue : null,
  );
}

// --- Kas & sesi -------------------------------------------------------------

/// Satu sesi kasir di tab Kas & sesi.
class CashSessionLine {
  const CashSessionLine({
    required this.id,
    required this.openedAt,
    required this.staffName,
    required this.opening,
    required this.expected,
    this.closedAt,
    this.counted,
    this.difference,
    this.shift,
  });

  /// Id sesi, untuk cetak ulang rekap (F1-03e).
  final UuidValue id;

  /// Waktu lokal cabang.
  final DateTime openedAt;
  final DateTime? closedAt;
  final String staffName;
  final Money opening;

  /// Seharusnya di laci (sesi terbuka: saat ini).
  final Money expected;

  /// `null` selama sesi masih buka.
  final Money? counted;
  final Money? difference;

  /// Shift yang dipilih saat buka (F1-03g); nama terkini, termasuk shift
  /// yang sudah dihapus.
  final Shift? shift;

  bool get isOpen => counted == null;
}

/// Ringkasan sesi satu shift di tab Kas & sesi (F1-03g); [shift] `null` =
/// sesi tanpa shift.
class ShiftSummary {
  const ShiftSummary({
    required this.shift,
    required this.sessions,
    required this.sales,
    required this.difference,
  });

  final Shift? shift;

  /// Jumlah sesi pada periode.
  final int sessions;

  /// Σ penjualan nota lunas sesi-sesi itu.
  final Money sales;

  /// Σ selisih sesi yang sudah ditutup.
  final Money difference;
}

/// Ringkasan per shift dari [lines] beserta penjualan tiap sesi; kosong bila
/// tidak ada sesi bershift. Urut jam mulai lalu nama, *Tanpa shift* akhir.
List<ShiftSummary> _shiftSummaries(
  List<CashSessionLine> lines,
  Map<UuidValue, Money> salesBySession,
) {
  if (lines.every((l) => l.shift == null)) return const [];
  final groups = <UuidValue?, List<CashSessionLine>>{};
  for (final l in lines) {
    (groups[l.shift?.id] ??= []).add(l);
  }
  final keys = groups.keys.toList()
    ..sort((a, b) {
      if (a == null || b == null) return a == null ? (b == null ? 0 : 1) : -1;
      final x = groups[a]!.first.shift!;
      final y = groups[b]!.first.shift!;
      final byStart = x.startMinute.compareTo(y.startMinute);
      return byStart != 0
          ? byStart
          : x.name.toLowerCase().compareTo(y.name.toLowerCase());
    });
  return [
    for (final k in keys)
      ShiftSummary(
        shift: groups[k]!.first.shift,
        sessions: groups[k]!.length,
        sales: Money.sum(
          groups[k]!.map((l) => salesBySession[l.id] ?? Money.zero),
        ),
        difference: Money.sum(
          groups[k]!.map((l) => l.difference ?? Money.zero),
        ),
      ),
  ];
}

/// Sesi tidak ditemukan di cabang ini atau belum ditutup (F1-03e).
class CashSessionNotClosed implements Exception {
  const CashSessionNotClosed();

  @override
  String toString() => 'CashSessionNotClosed';
}

/// Isi rekap sesi kasir yang sudah ditutup, untuk cetak ulang dari tab
/// Kas & sesi (F1-03e). Rincian dimuat dari data saat ini; angka penutup
/// (seharusnya, dihitung, selisih, pecahan, catatan) dari [session].
class ClosedSessionRecap {
  const ClosedSessionRecap({
    required this.session,
    required this.movements,
    required this.sales,
    required this.drawer,
    required this.openedByName,
    required this.closedByName,
    required this.deviceCode,
    this.shift,
  });

  final CashSession session;

  /// Shift sesi (F1-03g), atau `null`.
  final Shift? shift;

  /// Gerakan kas sesi ini, urut waktu catat.
  final List<CashMovement> movements;
  final SessionSalesSummary sales;
  final CashDrawer drawer;
  final String openedByName;
  final String closedByName;

  /// Kode perangkat tempat sesi dibuka.
  final String deviceCode;

  /// Rincian kas laci saat ini tidak lagi sama dengan *Seharusnya di laci*
  /// yang tersimpan saat tutup (data sesi berubah sesudahnya).
  bool get changedSinceClose =>
      drawer.expectedCash != Money(session.expectedCash ?? 0);
}

/// Sesi tertutup terakhir perangkat `scope.deviceId` untuk kartu *Sesi
/// sebelumnya* di layar Sesi kasir (F1-03f), terbaru dulu. Butuh
/// `cash_session:close` atau `reports:view`.
Future<List<CashSessionLine>> listRecentClosedSessions(
  LakunaStore store,
  CatalogScope scope, {
  required Set<Permission> permissions,
  int limit = 5,
}) async {
  if (!permissions.contains(Permission.reportsView) &&
      !permissions.contains(Permission.cashSessionClose)) {
    throw const ReportActorNotPermitted();
  }
  final session = store.session;
  final sessions = await CashSession.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.deviceId.equals(scope.deviceId) &
        s.deletedAt.equals(null) &
        s.closedAt.notEquals(null),
    orderByList: (s) => [s.closedAt.desc(), s.id.desc()],
    limit: limit,
  );
  if (sessions.isEmpty) return const [];
  final outlet = await Outlet.db.findById(session, scope.outletId);
  final tenant = await Tenant.db.findById(session, scope.tenantId);
  final timezone = outlet?.timezone ?? tenant?.timezone;
  final names = await _staffNames(
    session,
    scope.tenantId,
    sessions.map((s) => s.openedBy),
  );
  final shifts = await shiftsById(session, scope, [
    for (final s in sessions) ?s.shiftId,
  ]);
  return [
    for (final s in sessions)
      CashSessionLine(
        id: s.id,
        openedAt: outletLocalTime(s.openedAt, timezone),
        closedAt: outletLocalTime(s.closedAt!, timezone),
        staffName: names[s.openedBy] ?? '',
        opening: Money(s.openingCash),
        expected: Money(s.expectedCash ?? 0),
        counted: Money(s.countedCash ?? 0),
        difference: Money(s.difference ?? 0),
        shift: shifts[s.shiftId],
      ),
  ];
}

/// Rekap sesi tertutup [sessionId] di cabang [scope] (F1-03e).
/// `reports:view` memuat sesi perangkat mana pun di cabang;
/// `cash_session:close` hanya sesi yang dibuka di perangkat
/// `scope.deviceId` (F1-03f). Tanpa izin itu: [ReportActorNotPermitted];
/// sesi yang tidak ada di cabang ini atau masih buka ditolak dengan
/// [CashSessionNotClosed].
Future<ClosedSessionRecap> loadClosedSessionRecap(
  LakunaStore store,
  CatalogScope scope, {
  required Set<Permission> permissions,
  required UuidValue sessionId,
}) async {
  final anyDevice = permissions.contains(Permission.reportsView);
  // Kasir penutup sesi boleh mencetak ulang rekap perangkatnya (F1-03f).
  if (!anyDevice && !permissions.contains(Permission.cashSessionClose)) {
    throw const ReportActorNotPermitted();
  }
  final session = store.session;
  final s = await CashSession.db.findFirstRow(
    session,
    where: (t) =>
        t.id.equals(sessionId) &
        t.tenantId.equals(scope.tenantId) &
        t.outletId.equals(scope.outletId) &
        t.deletedAt.equals(null),
  );
  // Perangkat dicek dulu agar status sesi perangkat lain tidak terbaca.
  if (s != null && !anyDevice && s.deviceId != scope.deviceId) {
    throw const ReportActorNotPermitted();
  }
  if (s == null || s.status != CashSessionStatus.closed) {
    throw const CashSessionNotClosed();
  }
  final cashScope = CashScope(
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    deviceId: s.deviceId,
  );
  final movements = await listCashMovements(store, cashScope, s.id);
  final sales = await sessionSalesSummary(
    session,
    tenantId: scope.tenantId,
    sessionId: s.id,
  );
  final drawer = cashDrawerOf(
    s,
    movements,
    cashSales: sales.cash,
    cashRefunds: await sessionCashRefunds(
      session,
      tenantId: scope.tenantId,
      sessionId: s.id,
    ),
  );
  final names = await _staffNames(session, scope.tenantId, [
    s.openedBy,
    ?s.closedBy,
  ]);
  final device = await Device.db.findFirstRow(
    session,
    where: (d) => d.id.equals(s.deviceId) & d.tenantId.equals(scope.tenantId),
  );
  return ClosedSessionRecap(
    session: s,
    movements: movements,
    sales: sales,
    drawer: drawer,
    openedByName: names[s.openedBy] ?? '',
    closedByName: s.closedBy == null ? '' : names[s.closedBy] ?? '',
    deviceCode: device?.code ?? '',
    shift: switch (s.shiftId) {
      final id? => (await shiftsById(session, scope, [id]))[id],
      null => null,
    },
  );
}

/// Sumber gerakan kas di luar penjualan, menurut kolom `source`.
enum CashSourceKind {
  manualIn,
  manualOut,
  expense,
  expenseVoid,
  supplierPayment,
  purchase,

  /// Uang kembali dari retur pembelian (masuk).
  purchaseRefund,
  debtPayment,

  /// Batal terima piutang tunai (keluar, F1-13c).
  debtPaymentVoid,

  /// Batal bayar hutang dari laci (masuk, F1-13c).
  supplierPaymentVoid,
  other,
}

CashSourceKind _cashKind(CashMovement m) => switch (m.source) {
  'manual' =>
    m.direction == CashDirection.inflow
        ? CashSourceKind.manualIn
        : CashSourceKind.manualOut,
  expenseCashSource => CashSourceKind.expense,
  expenseVoidCashSource => CashSourceKind.expenseVoid,
  supplierPaymentCashSource => CashSourceKind.supplierPayment,
  purchaseCashSource =>
    m.direction == CashDirection.inflow
        ? CashSourceKind.purchaseRefund
        : CashSourceKind.purchase,
  debtPaymentCashSource => CashSourceKind.debtPayment,
  debtPaymentVoidCashSource => CashSourceKind.debtPaymentVoid,
  supplierPaymentVoidCashSource => CashSourceKind.supplierPaymentVoid,
  _ => CashSourceKind.other,
};

/// Tab Kas & sesi.
class CashReport {
  const CashReport({
    required this.sessions,
    required this.inflows,
    required this.outflows,
    this.shifts = const [],
  });

  /// Sesi yang aktif pada periode (dibuka sebelum akhir periode, belum
  /// ditutup atau ditutup sesudah awal periode), terbaru dulu.
  final List<CashSessionLine> sessions;

  /// Kas masuk lain per sumber.
  final List<GroupTotal<CashSourceKind>> inflows;

  /// Kas keluar per sumber.
  final List<GroupTotal<CashSourceKind>> outflows;

  /// Ringkasan per shift (F1-03g); kosong bila tidak ada sesi bershift.
  final List<ShiftSummary> shifts;

  int get openCount => sessions.where((s) => s.isOpen).length;

  /// Σ selisih sesi yang sudah ditutup.
  Money get totalDifference =>
      Money.sum(sessions.map((s) => s.difference ?? Money.zero));

  Money get inflow => Money.sum(inflows.map((g) => g.total));
  Money get outflow => Money.sum(outflows.map((g) => g.total));
}

Future<CashReport> loadCashReport(
  LakunaStore store,
  CatalogScope scope, {
  required Set<Permission> permissions,
  required ReportPeriod period,
  DateTime? now,
}) async {
  final ctx = await _context(store, scope, permissions, now);
  final session = store.session;
  final (start, end) = _bounds(period.range(ctx.today), ctx.timezone);
  final sessions = await CashSession.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.deletedAt.equals(null) &
        (s.openedAt < end) &
        (s.closedAt.equals(null) | (s.closedAt >= start)),
    orderByList: (s) => [s.openedAt, s.id],
  );
  final names = await _staffNames(
    session,
    scope.tenantId,
    sessions.map((s) => s.openedBy),
  );
  final shifts = await shiftsById(session, scope, [
    for (final s in sessions) ?s.shiftId,
  ]);
  final salesBySession = <UuidValue, Money>{};
  final lines = <CashSessionLine>[];
  for (final s in sessions.reversed) {
    // Penjualan per sesi hanya untuk ringkasan per shift.
    if (shifts.isNotEmpty) {
      salesBySession[s.id] = (await sessionSalesSummary(
        session,
        tenantId: scope.tenantId,
        sessionId: s.id,
      )).total;
    }
    final closed = s.status == CashSessionStatus.closed;
    final expected = closed
        ? Money(s.expectedCash ?? 0)
        : (await cashDrawerFor(
            store,
            CashScope(
              tenantId: scope.tenantId,
              outletId: scope.outletId,
              deviceId: s.deviceId,
            ),
            s,
          )).expectedCash;
    lines.add(
      CashSessionLine(
        id: s.id,
        openedAt: outletLocalTime(s.openedAt, ctx.timezone),
        closedAt: s.closedAt == null
            ? null
            : outletLocalTime(s.closedAt!, ctx.timezone),
        staffName: names[s.openedBy] ?? '',
        opening: Money(s.openingCash),
        expected: expected,
        counted: closed ? Money(s.countedCash ?? 0) : null,
        difference: closed ? Money(s.difference ?? 0) : null,
        shift: shifts[s.shiftId],
      ),
    );
  }
  final movements = await CashMovement.db.find(
    session,
    where: (m) =>
        m.tenantId.equals(scope.tenantId) &
        m.outletId.equals(scope.outletId) &
        m.deletedAt.equals(null) &
        (m.createdAt >= start) &
        (m.createdAt < end),
  );
  return CashReport(
    sessions: lines,
    inflows: groupTotals([
      for (final m in movements)
        if (m.direction == CashDirection.inflow)
          (_cashKind(m), Money(m.amount)),
    ]),
    outflows: groupTotals([
      for (final m in movements)
        if (m.direction == CashDirection.outflow)
          (_cashKind(m), Money(m.amount)),
    ]),
    shifts: _shiftSummaries(lines, salesBySession),
  );
}

// --- Piutang & hutang -------------------------------------------------------

/// Tab Piutang & hutang: posisi hari ini.
class DebtReport {
  const DebtReport({
    required this.today,
    required this.customers,
    required this.suppliers,
    required this.overdue,
    required this.overdueCustomers,
    required this.overduePurchases,
    this.receivableAging = Aging.empty,
    this.payableAging = Aging.empty,
  });

  final DateTime today;

  /// Pelanggan dengan sisa piutang, sisa terbesar dulu.
  final List<CustomerRow> customers;

  /// Supplier dengan sisa hutang, sisa terbesar dulu.
  final List<SupplierRow> suppliers;

  /// Sisa piutang lewat jatuh tempo dan jumlah pelanggannya.
  final Money overdue;
  final int overdueCustomers;

  /// Nota beli lewat jatuh tempo.
  final int overduePurchases;

  /// Umur piutang pelanggan di [customers] per nota (F1-16c).
  final Aging receivableAging;

  /// Umur hutang supplier di [suppliers] per nota beli (F1-16c).
  final Aging payableAging;

  Money get receivable => Money.sum(customers.map((c) => c.outstanding));
  Money get payable => Money.sum(suppliers.map((s) => s.debt));
}

Future<DebtReport> loadDebtReport(
  LakunaStore store,
  CatalogScope scope, {
  required Set<Permission> permissions,
  DateTime? now,
}) async {
  final ctx = await _context(store, scope, permissions, now);
  // Satu pembacaan per sisi: daftar, kartu jatuh tempo, dan umur memakai
  // data yang sama sehingga totalnya selalu cocok (F1-16c).
  final (overview: customers, open: receivables) =
      await customersWithReceivables(store, scope, now: now);
  final (overview: suppliers, open: payables) = await suppliersWithPayables(
    store,
    scope,
    now: now,
  );
  final owing = [
    for (final c in customers.rows)
      if (c.outstanding > Money.zero) c,
  ]..sort((a, b) => b.outstanding.compareTo(a.outstanding));
  final owed = [
    for (final s in suppliers.rows)
      if (s.debt > Money.zero) s,
  ]..sort((a, b) => b.debt.compareTo(a.debt));
  final receivableAging = Aging.of([
    for (final c in owing)
      for (final r in receivables[c.customer.id] ?? const <ReceivableSale>[])
        (dueOn: r.sale.dueOn, outstanding: r.outstanding),
  ], ctx.today);
  return DebtReport(
    today: ctx.today,
    customers: owing,
    suppliers: owed,
    receivableAging: receivableAging,
    payableAging: Aging.of([
      for (final s in owed)
        for (final p in payables[s.supplier.id] ?? const <PayablePurchase>[])
          (dueOn: p.purchase.dueOn, outstanding: p.outstanding),
    ], ctx.today),
    overdue: receivableAging.overdue,
    overdueCustomers: owing.where((c) => c.overdueCount > 0).length,
    overduePurchases: suppliers.overdueCount,
  );
}

// --- Retur ------------------------------------------------------------------

/// Satu retur penjualan di tab Retur.
class ReturnReportLine {
  const ReturnReportLine({
    required this.returnedAt,
    required this.number,
    required this.saleNumber,
    required this.staffName,
    required this.reason,
    required this.restock,
    required this.refundMethod,
    required this.amount,
    this.debtReduction = Money.zero,
  });

  /// Waktu lokal cabang.
  final DateTime returnedAt;
  final String number;
  final String saleNumber;
  final String staffName;
  final SaleReturnReason reason;
  final bool restock;
  final RefundMethod refundMethod;
  final Money amount;

  /// Bagian [amount] yang memotong piutang nota kredit (sisanya lewat
  /// [refundMethod]).
  final Money debtReduction;
}

/// Tab Retur.
class ReturnsReport {
  const ReturnsReport(this.lines);

  /// Terbaru dulu.
  final List<ReturnReportLine> lines;

  Money get total => Money.sum(lines.map((l) => l.amount));
  int get restockCount => lines.where((l) => l.restock).length;
  int get damagedCount => lines
      .where(
        (l) =>
            l.reason == SaleReturnReason.damaged ||
            l.reason == SaleReturnReason.expired,
      )
      .length;

  List<GroupTotal<SaleReturnReason>> get byReason =>
      groupTotals([for (final l in lines) (l.reason, l.amount)]);
}

Future<ReturnsReport> loadReturnsReport(
  LakunaStore store,
  CatalogScope scope, {
  required Set<Permission> permissions,
  required ReportPeriod period,
  DateTime? now,
}) async {
  final ctx = await _context(store, scope, permissions, now);
  final session = store.session;
  final (start, end) = _bounds(period.range(ctx.today), ctx.timezone);
  final returns = await SaleReturn.db.find(
    session,
    where: (r) =>
        r.tenantId.equals(scope.tenantId) &
        r.outletId.equals(scope.outletId) &
        r.deletedAt.equals(null) &
        (r.returnedAt >= start) &
        (r.returnedAt < end),
    orderByList: (r) => [r.returnedAt, r.id],
  );
  final sales = {
    for (final ids in _chunks(returns.map((r) => r.saleId)))
      for (final s in await Sale.db.find(
        session,
        where: (s) => s.tenantId.equals(scope.tenantId) & s.id.inSet(ids),
      ))
        s.id: s.number,
  };
  final names = await _staffNames(
    session,
    scope.tenantId,
    returns.map((r) => r.staffId),
  );
  return ReturnsReport([
    for (final r in returns.reversed)
      ReturnReportLine(
        returnedAt: outletLocalTime(r.returnedAt, ctx.timezone),
        number: r.number,
        saleNumber: sales[r.saleId] ?? '',
        staffName: names[r.staffId] ?? '',
        reason: r.reason,
        restock: r.restock,
        refundMethod: r.refundMethod,
        amount: Money(r.amount),
        debtReduction: Money(r.debtReduction),
      ),
  ]);
}
