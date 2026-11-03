import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show ColumnOrderingOperations, DatabaseSession, Transaction;

import 'cash.dart';
import 'open_bill.dart';
import 'sale_core.dart';
import 'sales.dart';
import 'staff_access.dart';
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

// Riwayat transaksi, retur, dan void (F1-11, layar 1.14). Nota tidak pernah
// dihapus: retur = dokumen `sale_returns` baru, void = status `voided` +
// pembalikan stok lewat pergerakan baru.

/// Status nota yang tampil di riwayat (nota bernomor).
const historyStatuses = {
  SaleStatus.completed,
  SaleStatus.partiallyReturned,
  SaleStatus.returned,
  SaleStatus.voided,
};

/// Nota yang terhitung sebagai penjualan (rekap sesi, laporan).
const soldStatuses = {
  SaleStatus.completed,
  SaleStatus.partiallyReturned,
  SaleStatus.returned,
};

enum HistoryRange { today, yesterday, week }

enum HistoryStatus { all, completed, returned, voided }

/// Filter daftar riwayat. Rentang memakai tanggal lokal cabang.
class HistoryFilter {
  const HistoryFilter({
    this.range = HistoryRange.today,
    this.staffId,
    this.method,
    this.status = HistoryStatus.all,
  });

  final HistoryRange range;
  final UuidValue? staffId;
  final PaymentMethod? method;
  final HistoryStatus status;

  HistoryFilter copyWith({
    HistoryRange? range,
    UuidValue? Function()? staffId,
    PaymentMethod? Function()? method,
    HistoryStatus? status,
  }) => HistoryFilter(
    range: range ?? this.range,
    staffId: staffId == null ? this.staffId : staffId(),
    method: method == null ? this.method : method(),
    status: status ?? this.status,
  );
}

/// Satu baris daftar riwayat.
class HistoryRow {
  const HistoryRow({
    required this.sale,
    required this.staffName,
    required this.methods,
    required this.returned,
  });

  final Sale sale;
  final String staffName;

  /// Metode pembayaran lunas nota, urut kemunculan.
  final List<PaymentMethod> methods;

  /// Jumlah nilai retur.
  final Money returned;

  Money get total => Money(sale.total);

  /// Nilai bersih: total − retur; nota void bernilai 0.
  Money get net =>
      sale.status == SaleStatus.voided ? Money.zero : total - returned;
}

/// Hasil daftar riwayat beserta ringkasannya.
class HistoryPage {
  const HistoryPage({required this.rows, required this.from});

  final List<HistoryRow> rows;

  /// Awal rentang (UTC) untuk label tanggal.
  final DateTime from;

  /// Nota yang terhitung (bukan void).
  int get count => rows.where((r) => r.sale.status != SaleStatus.voided).length;

  /// Nilai bersih semua nota di daftar.
  Money get total => Money.sum(rows.map((r) => r.net));
}

/// Awal hari lokal cabang untuk [now] (UTC).
DateTime outletDayStart(DateTime now, String? timezone) {
  final local = outletLocalTime(now, timezone);
  final wall = DateTime.utc(
    local.year,
    local.month,
    local.day,
    local.hour,
    local.minute,
    local.second,
    local.millisecond,
    local.microsecond,
  );
  final offset = wall.difference(now.toUtc());
  return DateTime.utc(local.year, local.month, local.day).subtract(offset);
}

Future<String?> _timezone(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async {
  final outlet = await Outlet.db.findById(
    session,
    scope.outletId,
    transaction: transaction,
  );
  final tenant = await Tenant.db.findById(
    session,
    scope.tenantId,
    transaction: transaction,
  );
  return outlet?.timezone ?? tenant?.timezone;
}

/// Rentang `[from, to)` (UTC) untuk [range] pada [now].
(DateTime, DateTime) historyRangeBounds(
  HistoryRange range,
  DateTime now,
  String? timezone,
) {
  final today = outletDayStart(now, timezone);
  const day = Duration(days: 1);
  return switch (range) {
    HistoryRange.today => (today, today.add(day)),
    HistoryRange.yesterday => (today.subtract(day), today),
    HistoryRange.week => (
      today.subtract(const Duration(days: 6)),
      today.add(day),
    ),
  };
}

Future<Map<UuidValue, String>> _names(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<UuidValue?> ids, {
  Transaction? transaction,
}) async {
  final set = ids.whereType<UuidValue>().toSet();
  if (set.isEmpty) return const {};
  return {
    for (final s in await StaffMember.db.find(
      session,
      where: (s) => s.tenantId.equals(tenantId) & s.id.inSet(set),
      transaction: transaction,
    ))
      s.id: s.name,
  };
}

Future<List<Payment>> _paidPayments(
  DatabaseSession session,
  UuidValue tenantId,
  Set<UuidValue> saleIds, {
  Transaction? transaction,
}) async {
  if (saleIds.isEmpty) return const [];
  return Payment.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(tenantId) &
        p.saleId.inSet(saleIds) &
        p.status.equals(PaymentStatus.paid) &
        p.deletedAt.equals(null),
    orderBy: (p) => p.createdAt,
    transaction: transaction,
  );
}

Future<List<SaleReturn>> _returns(
  DatabaseSession session,
  UuidValue tenantId,
  Set<UuidValue> saleIds, {
  Transaction? transaction,
}) async {
  if (saleIds.isEmpty) return const [];
  return SaleReturn.db.find(
    session,
    where: (r) =>
        r.tenantId.equals(tenantId) &
        r.saleId.inSet(saleIds) &
        r.deletedAt.equals(null),
    orderBy: (r) => r.returnedAt,
    transaction: transaction,
  );
}

/// Daftar nota cabang ini sesuai [filter], terbaru dulu.
Future<HistoryPage> listSalesHistory(
  LakunaStore store,
  CatalogScope scope, {
  HistoryFilter filter = const HistoryFilter(),
  DateTime? now,
}) async {
  final session = store.session;
  final timezone = await _timezone(session, scope);
  final (from, to) = historyRangeBounds(
    filter.range,
    now ?? DateTime.now().toUtc(),
    timezone,
  );
  final statuses = switch (filter.status) {
    HistoryStatus.all => historyStatuses,
    HistoryStatus.completed => {SaleStatus.completed},
    HistoryStatus.returned => {
      SaleStatus.partiallyReturned,
      SaleStatus.returned,
    },
    HistoryStatus.voided => {SaleStatus.voided},
  };
  var sales = await Sale.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.status.inSet(statuses) &
        (s.soldAt >= from) &
        (s.soldAt < to) &
        s.deletedAt.equals(null),
    orderByList: (s) => [s.soldAt.desc(), s.id.desc()],
  );
  if (filter.staffId case final id?) {
    sales = [
      for (final s in sales)
        if (s.staffId == id) s,
    ];
  }
  final ids = {for (final s in sales) s.id};
  final payments = await _paidPayments(session, scope.tenantId, ids);
  final methods = <UuidValue, List<PaymentMethod>>{};
  for (final p in payments) {
    final list = methods.putIfAbsent(p.saleId, () => []);
    if (!list.contains(p.method)) list.add(p.method);
  }
  if (filter.method case final m?) {
    sales = [
      for (final s in sales)
        if (methods[s.id]?.contains(m) ?? false) s,
    ];
  }
  final returned = <UuidValue, Money>{};
  for (final r in await _returns(session, scope.tenantId, ids)) {
    returned[r.saleId] = (returned[r.saleId] ?? Money.zero) + Money(r.amount);
  }
  final names = await _names(
    session,
    scope.tenantId,
    sales.map((s) => s.staffId),
  );
  return HistoryPage(
    from: from,
    rows: [
      for (final s in sales)
        HistoryRow(
          sale: s,
          staffName: names[s.staffId] ?? '',
          methods: methods[s.id] ?? const [],
          returned: returned[s.id] ?? Money.zero,
        ),
    ],
  );
}

/// Alasan nota tidak bisa di-void.
enum VoidBlock {
  /// Nota bukan `completed` (sudah void atau diretur).
  status,

  /// Sudah ada retur.
  returned,

  /// Bukan nota hari ini.
  notToday,

  /// Sesi kasir nota sudah ditutup atau milik perangkat lain.
  session,
}

/// Rincian satu nota untuk panel riwayat, retur, dan cetak ulang.
class SaleDetail {
  const SaleDetail({
    required this.receipt,
    required this.staffName,
    required this.returns,
    required this.returnedMilli,
    required this.shares,
    this.voidedByName,
    this.voidBlock,
  });

  /// Nota, item, pembayaran lunas, modifier (bentuk yang sama dengan hasil
  /// bayar, untuk struk).
  final CheckoutResult receipt;
  final String staffName;
  final String? voidedByName;
  final List<SaleReturn> returns;

  /// Jumlah sudah diretur per baris (`sale_items.id`).
  final Map<UuidValue, int> returnedMilli;

  /// Bagian total nota per baris.
  final Map<UuidValue, Money> shares;

  /// `null` = boleh di-void.
  final VoidBlock? voidBlock;

  Sale get sale => receipt.sale;
  List<SaleItem> get items => receipt.items;

  Money get returnedTotal => Money.sum(returns.map((r) => Money(r.amount)));

  Money get net => sale.status == SaleStatus.voided
      ? Money.zero
      : Money(sale.total) - returnedTotal;

  /// Sisa yang masih bisa diretur di baris [item].
  int remainingMilli(SaleItem item) =>
      item.quantityMilli - (returnedMilli[item.id] ?? 0);

  bool get canReturn =>
      (sale.status == SaleStatus.completed ||
          sale.status == SaleStatus.partiallyReturned) &&
      items.any((i) => remainingMilli(i) > 0);

  /// Nilai retur [milli] dari baris [item].
  Money returnValue(SaleItem item, int milli) => returnAmount(
    share: shares[item.id] ?? Money.zero,
    soldMilli: item.quantityMilli,
    returnedMilli: returnedMilli[item.id] ?? 0,
    returningMilli: milli,
  );
}

class SaleNotFound implements Exception {
  @override
  String toString() => 'SaleNotFound';
}

Future<Sale> _historySale(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue saleId, {
  Transaction? transaction,
}) async {
  final sale = await Sale.db.findFirstRow(
    session,
    where: (s) =>
        s.id.equals(saleId) &
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.status.inSet(historyStatuses) &
        s.deletedAt.equals(null),
    transaction: transaction,
  );
  if (sale == null) throw SaleNotFound();
  return sale;
}

Future<List<SaleItem>> _saleItems(
  DatabaseSession session,
  UuidValue tenantId,
  UuidValue saleId, {
  Transaction? transaction,
}) => SaleItem.db.find(
  session,
  where: (i) =>
      i.tenantId.equals(tenantId) &
      i.saleId.equals(saleId) &
      i.deletedAt.equals(null),
  orderBy: (i) => i.sortOrder,
  transaction: transaction,
);

Future<Map<UuidValue, int>> _returnedMilli(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<SaleReturn> returns, {
  Transaction? transaction,
}) async {
  final ids = {for (final r in returns) r.id};
  if (ids.isEmpty) return const {};
  final result = <UuidValue, int>{};
  for (final i in await SaleReturnItem.db.find(
    session,
    where: (i) =>
        i.tenantId.equals(tenantId) &
        i.saleReturnId.inSet(ids) &
        i.deletedAt.equals(null),
    transaction: transaction,
  )) {
    result[i.saleItemId] = (result[i.saleItemId] ?? 0) + i.quantityMilli;
  }
  return result;
}

Map<UuidValue, Money> _shares(Sale sale, List<SaleItem> items) {
  final shares = lineShares(Money(sale.total), [
    for (final i in items) i.lineTotal,
  ]);
  return {for (var k = 0; k < items.length; k++) items[k].id: shares[k]};
}

Future<VoidBlock?> _voidBlock(
  LakunaStore store,
  CatalogScope scope,
  Sale sale,
  List<SaleReturn> returns,
  DateTime now, {
  Transaction? transaction,
}) async {
  if (returns.isNotEmpty) return VoidBlock.returned;
  if (sale.status != SaleStatus.completed) return VoidBlock.status;
  final timezone = await _timezone(
    store.session,
    scope,
    transaction: transaction,
  );
  if (sale.soldAt.isBefore(outletDayStart(now, timezone))) {
    return VoidBlock.notToday;
  }
  final open = await findOpenCashSession(
    store,
    CashScope(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      deviceId: scope.deviceId,
    ),
    transaction: transaction,
  );
  if (open == null || open.id != sale.cashSessionId) return VoidBlock.session;
  return null;
}

/// Rincian nota [saleId] di cabang ini.
Future<SaleDetail> loadSaleDetail(
  LakunaStore store,
  CatalogScope scope,
  UuidValue saleId, {
  DateTime? now,
}) async {
  final session = store.session;
  final sale = await _historySale(session, scope, saleId);
  final items = await _saleItems(session, scope.tenantId, sale.id);
  final payments = await _paidPayments(session, scope.tenantId, {sale.id});
  final returns = await _returns(session, scope.tenantId, {sale.id});
  final names = await _names(session, scope.tenantId, [
    sale.staffId,
    sale.voidedBy,
  ]);
  return SaleDetail(
    receipt: CheckoutResult(
      sale: sale,
      items: items,
      payments: payments,
      modifiers: await itemModifiers(
        session,
        scope.tenantId,
        items.map((i) => i.id),
      ),
    ),
    staffName: names[sale.staffId] ?? '',
    voidedByName: sale.voidedBy == null ? null : names[sale.voidedBy],
    returns: returns,
    returnedMilli: await _returnedMilli(session, scope.tenantId, returns),
    shares: _shares(sale, items),
    voidBlock: await _voidBlock(
      store,
      scope,
      sale,
      returns,
      now ?? DateTime.now().toUtc(),
    ),
  );
}

// --- Retur --------------------------------------------------------------------

/// Satu baris retur: [quantity] dari baris nota [saleItemId].
class ReturnLine {
  const ReturnLine({required this.saleItemId, required this.quantity});

  final UuidValue saleItemId;
  final Qty quantity;
}

enum ReturnError {
  /// Tidak ada baris dengan jumlah > 0.
  empty,

  /// Jumlah melebihi sisa atau baris bukan milik nota.
  quantity,

  /// Catatan kosong untuk *Lainnya* atau terlalu panjang.
  note,

  /// Nota void / sudah diretur penuh.
  status,

  /// Cara uang kembali belum didukung (potong piutang sampai F1-13).
  refundMethod,
}

class ReturnInvalid implements Exception {
  const ReturnInvalid(this.error, {this.index = 0});

  final ReturnError error;

  /// Baris [ReturnLine] yang ditolak.
  final int index;

  @override
  String toString() => 'ReturnInvalid($error, $index)';
}

ReturnReasonKind returnReasonKind(SaleReturnReason reason) => switch (reason) {
  SaleReturnReason.damaged => ReturnReasonKind.damaged,
  SaleReturnReason.wrongItem => ReturnReasonKind.wrongItem,
  SaleReturnReason.expired => ReturnReasonKind.expired,
  SaleReturnReason.other => ReturnReasonKind.other,
};

/// Nomor retur berikutnya perangkat ini (tanggal lokal cabang).
Future<String> _nextReturnNumber(
  SyncTx w,
  CatalogScope scope,
  DateTime now,
) async {
  final outlet = await Outlet.db.findById(
    w.session,
    scope.outletId,
    transaction: w.transaction,
  );
  final device = await Device.db.findById(
    w.session,
    scope.deviceId,
    transaction: w.transaction,
  );
  if (outlet == null || device == null) {
    throw StateError('Cabang/perangkat ${scope.outletId} tidak ditemukan.');
  }
  final timezone = await _timezone(
    w.session,
    scope,
    transaction: w.transaction,
  );
  final local = outletLocalTime(now, timezone);
  final prefix = 'RT-${receiptPrefix(outlet.code, device.code, local)}';
  final existing = await SaleReturn.db.find(
    w.session,
    where: (r) => r.tenantId.equals(scope.tenantId) & r.number.like('$prefix%'),
    transaction: w.transaction,
  );
  final counter = nextReceiptCounter(existing.map((r) => r.number), prefix);
  return saleReturnNumber(outlet.code, device.code, local, counter);
}

/// Retur [lines] dari nota [saleId] dalam satu transaksi: dokumen `RT-`,
/// baris, pergerakan stok `saleReturn` (bila [restock] dan baris dulu
/// mengurangi stok), dan status nota. Uang kembali tunai butuh sesi kasir
/// terbuka di perangkat ini ([CashSessionNotOpen]).
Future<SaleReturn> returnSale(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue saleId,
  required List<ReturnLine> lines,
  required SaleReturnReason reason,
  String? note,
  required RefundMethod refundMethod,
  required bool restock,
}) async {
  final text = note?.trim();
  if (validateReturnNote(other: reason == SaleReturnReason.other, note: text) !=
      null) {
    throw const ReturnInvalid(ReturnError.note);
  }
  if (refundMethod == RefundMethod.debt) {
    throw const ReturnInvalid(ReturnError.refundMethod);
  }
  if (!lines.any((l) => l.quantity.milli > 0)) {
    throw const ReturnInvalid(ReturnError.empty);
  }
  return store.write(actor: staffId, (w) async {
    final sale = await _historySale(
      w.session,
      scope,
      saleId,
      transaction: w.transaction,
    );
    if (sale.status != SaleStatus.completed &&
        sale.status != SaleStatus.partiallyReturned) {
      throw const ReturnInvalid(ReturnError.status);
    }
    final cashScope = CashScope(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      deviceId: scope.deviceId,
    );
    final cash = refundMethod == RefundMethod.cash
        ? await requireOpenCashSession(store, w, scope)
        : await findOpenCashSession(
            store,
            cashScope,
            transaction: w.transaction,
          );
    final items = await _saleItems(
      w.session,
      scope.tenantId,
      sale.id,
      transaction: w.transaction,
    );
    final byId = {for (final i in items) i.id: i};
    final previous = await _returns(w.session, scope.tenantId, {
      sale.id,
    }, transaction: w.transaction);
    final returned = Map.of(
      await _returnedMilli(
        w.session,
        scope.tenantId,
        previous,
        transaction: w.transaction,
      ),
    );
    final shares = _shares(sale, items);

    final amounts = <(SaleItem, int, Money)>[];
    for (var k = 0; k < lines.length; k++) {
      final line = lines[k];
      final milli = line.quantity.milli;
      if (milli == 0) continue;
      final item = byId[line.saleItemId];
      final before = item == null ? 0 : returned[item.id] ?? 0;
      if (item == null || milli < 0 || before + milli > item.quantityMilli) {
        throw ReturnInvalid(ReturnError.quantity, index: k);
      }
      amounts.add((
        item,
        milli,
        returnAmount(
          share: shares[item.id] ?? Money.zero,
          soldMilli: item.quantityMilli,
          returnedMilli: before,
          returningMilli: milli,
        ),
      ));
      returned[item.id] = before + milli;
    }

    final s = await w.stamp();
    final doc = await w.insert(
      SaleReturn(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        cashSessionId: cash?.id,
        saleId: sale.id,
        staffId: staffId,
        number: await _nextReturnNumber(w, scope, s.now),
        reason: reason,
        note: text == null || text.isEmpty ? null : text,
        refundMethod: refundMethod,
        amount: Money.sum(amounts.map((a) => a.$3)).value,
        restock: restock,
        returnedAt: s.now,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );

    final movements = restock
        ? await StockMovement.db.find(
            w.session,
            where: (m) =>
                m.tenantId.equals(scope.tenantId) &
                m.sourceType.equals(StockSourceType.sale) &
                m.sourceId.equals(sale.id) &
                m.deletedAt.equals(null),
            transaction: w.transaction,
          )
        : const <StockMovement>[];
    for (final (item, milli, amount) in amounts) {
      await w.insert(
        SaleReturnItem(
          tenantId: scope.tenantId,
          saleReturnId: doc.id,
          saleItemId: item.id,
          quantityMilli: milli,
          amount: amount.value,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      if (!restock || !item.tracksStock) continue;
      // Kembali ke lokasi tempat barang dulu keluar, dengan HPP saat itu.
      final out = movements
          .where((m) => m.variantId == item.variantId && m.quantityMilli < 0)
          .firstOrNull;
      if (out == null) continue;
      await recordStockMovement(
        w,
        scope,
        locationId: out.stockLocationId,
        variantId: item.variantId,
        quantity: Qty(milli).toBaseUnit(item.factorMilli),
        unitCost: Money(item.unitCost),
        sourceType: StockSourceType.saleReturn,
        sourceId: doc.id,
        stamp: s,
      );
    }

    final state = returnState(
      sold: [for (final i in items) i.quantityMilli],
      returned: [for (final i in items) returned[i.id] ?? 0],
    );
    await w.update(
      sale.copyWith(
        status: state == ReturnState.full
            ? SaleStatus.returned
            : SaleStatus.partiallyReturned,
        version: sale.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    return doc;
  });
}

// --- Void ---------------------------------------------------------------------

enum VoidError {
  /// Alasan kosong atau terlalu panjang.
  reason,

  /// Lihat [VoidBlock].
  blocked,
}

class SaleVoidInvalid implements Exception {
  const SaleVoidInvalid(this.error, {this.block});

  final VoidError error;
  final VoidBlock? block;

  @override
  String toString() => 'SaleVoidInvalid($error, $block)';
}

/// Penyetuju tidak aktif di cabang ini atau tidak punya izin yang diminta.
class ApproverNotPermitted implements Exception {
  @override
  String toString() => 'ApproverNotPermitted';
}

/// Penyetuju [approverId] aktif di cabang dan punya [permission].
Future<OutletStaff> requireApprover(
  LakunaStore store,
  CatalogScope scope,
  UuidValue approverId,
  Permission permission,
) async {
  final staff = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: approverId,
  );
  if (staff == null || !staff.permissions.contains(permission)) {
    throw ApproverNotPermitted();
  }
  return staff;
}

/// Void nota lunas [saleId]: hanya nota hari ini, tanpa retur, di sesi kasir
/// yang masih buka di perangkat ini. Stok dibalik lewat pergerakan baru;
/// pembayaran tetap ada (rekap sesi hanya menghitung nota terjual).
/// [approverId] = staf ber-`sales:void` yang menyetujui (boleh [staffId]).
Future<Sale> voidSale(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue approverId,
  required UuidValue saleId,
  required String reason,
  DateTime? now,
}) async {
  final text = reason.trim();
  if (text.isEmpty || text.length > FnbLimits.voidReason) {
    throw const SaleVoidInvalid(VoidError.reason);
  }
  await requireApprover(store, scope, approverId, Permission.salesVoid);
  return store.write(actor: staffId, (w) async {
    final sale = await _historySale(
      w.session,
      scope,
      saleId,
      transaction: w.transaction,
    );
    final returns = await _returns(w.session, scope.tenantId, {
      sale.id,
    }, transaction: w.transaction);
    final s = await w.stamp();
    final block = await _voidBlock(
      store,
      scope,
      sale,
      returns,
      now ?? s.now,
      transaction: w.transaction,
    );
    if (block != null) {
      throw SaleVoidInvalid(VoidError.blocked, block: block);
    }
    final movements = await StockMovement.db.find(
      w.session,
      where: (m) =>
          m.tenantId.equals(scope.tenantId) &
          m.sourceType.equals(StockSourceType.sale) &
          m.sourceId.equals(sale.id) &
          m.deletedAt.equals(null),
      transaction: w.transaction,
    );
    for (final m in movements) {
      await recordStockMovement(
        w,
        scope,
        locationId: m.stockLocationId,
        variantId: m.variantId,
        quantity: Qty(-m.quantityMilli),
        unitCost: Money(m.unitCost),
        sourceType: StockSourceType.sale,
        sourceId: sale.id,
        note: voidMovementNote,
        stamp: s,
      );
    }
    return w.update(
      sale.copyWith(
        status: SaleStatus.voided,
        voidReason: text,
        voidedBy: approverId,
        voidedAt: s.now,
        version: sale.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

/// Catatan pergerakan pembalik stok nota void (kartu stok menampilkannya
/// sebagai *Void*).
const voidMovementNote = 'void';

/// Total retur tunai di sesi kasir [sessionId] (rekap laci).
Future<Money> sessionCashRefunds(
  DatabaseSession session, {
  required UuidValue tenantId,
  required UuidValue sessionId,
  Transaction? transaction,
}) async {
  final returns = await SaleReturn.db.find(
    session,
    where: (r) =>
        r.tenantId.equals(tenantId) &
        r.cashSessionId.equals(sessionId) &
        r.refundMethod.equals(RefundMethod.cash) &
        r.deletedAt.equals(null),
    transaction: transaction,
  );
  return Money.sum(returns.map((r) => Money(r.amount)));
}
