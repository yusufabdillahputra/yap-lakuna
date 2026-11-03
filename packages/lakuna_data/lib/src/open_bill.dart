import 'package:characters/characters.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'dining_admin.dart';
import 'sale_core.dart';
import 'sales.dart';
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Open bill F&B (F1-10): bill per meja dan take away, item dengan status
/// dapur, tiket dapur, dan tutup & bayar. Bill = baris `sales` berstatus
/// `open`; stok baru bergerak saat lunas.

/// Bill tidak ada, bukan milik cabang ini, atau sudah tidak terbuka.
class BillNotFound implements Exception {
  @override
  String toString() => 'BillNotFound';
}

/// Meja tujuan *Pindah meja* sudah punya bill terbuka.
class TableOccupied implements Exception {
  @override
  String toString() => 'TableOccupied';
}

/// Item sudah dikirim ke dapur (atau belum dikirim, untuk *Disajikan*).
class BillItemLocked implements Exception {
  @override
  String toString() => 'BillItemLocked';
}

/// *Kirim ke dapur* tanpa item Baru.
class NothingToSend implements Exception {
  @override
  String toString() => 'NothingToSend';
}

/// *Hapus bill kosong* pada bill yang berisi item.
class BillNotEmpty implements Exception {
  @override
  String toString() => 'BillNotEmpty';
}

enum BillField { guests, customerName, note, voidReason }

/// Isian bill tidak sah: tamu 1..99, nama pemesan ≤ 40, catatan ≤ 120,
/// alasan batal wajib ≤ 120.
class BillInputInvalid implements Exception {
  const BillInputInvalid(this.field);

  final BillField field;

  @override
  String toString() => 'BillInputInvalid(${field.name})';
}

/// Open bill beserta itemnya dan tagihan dengan tarif terkini.
class OpenBill {
  const OpenBill({
    required this.sale,
    required this.items,
    required this.charges,
    required this.rates,
    this.table,
    this.openedByName = '',
  });

  final Sale sale;

  /// Item yang belum dihapus, urut `sort_order`.
  final List<SaleItem> items;
  final FnbCharges charges;
  final FnbRates rates;

  /// `null` untuk take away.
  final DiningTable? table;
  final String openedByName;

  UuidValue get id => sale.id;
  bool get isTakeAway => sale.orderType == OrderType.takeAway;
  bool get billRequested => sale.billRequestedAt != null;

  /// "M4" atau "TA-07".
  String get label => table?.name ?? takeAwayLabel(sale.queueNumber ?? 0);

  int _count(KitchenStatus status) =>
      items.where((i) => i.kitchenStatus == status).length;

  int get pendingCount => _count(KitchenStatus.pending);
  int get sentCount => _count(KitchenStatus.sent);
  int get servedCount => _count(KitchenStatus.served);

  TakeAwayState get takeAwayStatus => takeAwayState(
    pending: pendingCount,
    sent: sentCount,
    served: servedCount,
  );
}

/// Isi layar Meja: area, meja, dan semua bill terbuka cabang ini.
class DiningOverview {
  const DiningOverview({
    required this.areas,
    required this.tables,
    required this.bills,
    required this.rates,
  });

  final List<DiningArea> areas;
  final List<DiningTable> tables;
  final List<OpenBill> bills;
  final FnbRates rates;

  OpenBill? billForTable(UuidValue tableId) =>
      bills.where((b) => b.sale.diningTableId == tableId).firstOrNull;

  /// Take away terbuka, urut nomor.
  List<OpenBill> get takeAways =>
      [
        for (final b in bills)
          if (b.isTakeAway) b,
      ]..sort(
        (a, b) => (a.sale.queueNumber ?? 0).compareTo(b.sale.queueNumber ?? 0),
      );

  /// Meja yang punya bill terbuka.
  int get occupiedTables =>
      tables.where((t) => billForTable(t.id) != null).length;
}

/// Hasil *Kirim ke dapur*: tiket, item yang baru dikirim, dan bill terkini.
class KitchenSendResult {
  const KitchenSendResult({
    required this.ticket,
    required this.items,
    required this.bill,
    this.staffName = '',
  });

  final KitchenTicket ticket;
  final List<SaleItem> items;
  final OpenBill bill;
  final String staffName;
}

// --- Baca -------------------------------------------------------------------

FnbCharges _charges(Sale sale, List<SaleItem> items, FnbRates rates) =>
    fnbCharges(
      Money.sum(items.map((i) => Money(i.lineTotal))),
      dineIn: sale.orderType == OrderType.dineIn,
      serviceBp: rates.service,
      taxBp: rates.tax,
    );

Future<List<SaleItem>> _items(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<UuidValue> saleIds, {
  Transaction? transaction,
}) async {
  final ids = saleIds.toSet();
  if (ids.isEmpty) return const [];
  return (await SaleItem.db.find(
    session,
    where: (i) =>
        i.tenantId.equals(tenantId) &
        i.saleId.inSet(ids) &
        i.deletedAt.equals(null),
    transaction: transaction,
  ))..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

Future<Map<UuidValue, String>> _staffNames(
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

Future<List<OpenBill>> _bills(
  DatabaseSession session,
  CatalogScope scope,
  List<Sale> sales,
  FnbRates rates, {
  Transaction? transaction,
}) async {
  final items = await _items(
    session,
    scope.tenantId,
    sales.map((s) => s.id),
    transaction: transaction,
  );
  final tableIds = {
    for (final s in sales)
      if (s.diningTableId != null) s.diningTableId!,
  };
  final tables = tableIds.isEmpty
      ? const <UuidValue, DiningTable>{}
      : {
          for (final t in await DiningTable.db.find(
            session,
            where: (t) =>
                t.tenantId.equals(scope.tenantId) & t.id.inSet(tableIds),
            transaction: transaction,
          ))
            t.id: t,
        };
  final names = await _staffNames(
    session,
    scope.tenantId,
    sales.map((s) => s.openedBy ?? s.staffId),
    transaction: transaction,
  );
  return [
    for (final s in sales)
      () {
        final own = [
          for (final i in items)
            if (i.saleId == s.id) i,
        ];
        return OpenBill(
          sale: s,
          items: own,
          charges: _charges(s, own, rates),
          rates: rates,
          table: tables[s.diningTableId],
          openedByName: names[s.openedBy ?? s.staffId] ?? '',
        );
      }(),
  ];
}

Future<List<Sale>> _openSales(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) => Sale.db.find(
  session,
  where: (s) =>
      s.tenantId.equals(scope.tenantId) &
      s.outletId.equals(scope.outletId) &
      s.status.equals(SaleStatus.open) &
      s.orderType.notEquals(OrderType.retail) &
      s.deletedAt.equals(null),
  orderBy: (s) => s.openedAt,
  transaction: transaction,
);

/// Area, meja, dan bill terbuka cabang [scope].
Future<DiningOverview> diningOverview(
  LakunaStore store,
  CatalogScope scope,
) async {
  final session = store.session;
  final rates = await loadFnbRates(session, scope);
  return DiningOverview(
    areas: await diningAreas(store, scope),
    tables: await diningTables(store, scope),
    bills: await _bills(
      session,
      scope,
      await _openSales(session, scope),
      rates,
    ),
    rates: rates,
  );
}

Future<Sale> _openSale(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue billId, {
  Transaction? transaction,
}) async {
  final sale = await Sale.db.findFirstRow(
    session,
    where: (s) =>
        s.id.equals(billId) &
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.status.equals(SaleStatus.open) &
        s.orderType.notEquals(OrderType.retail) &
        s.deletedAt.equals(null),
    transaction: transaction,
  );
  if (sale == null) throw BillNotFound();
  return sale;
}

/// Bill terbuka [billId] dengan tarif terkini, atau [BillNotFound].
Future<OpenBill> loadOpenBill(
  LakunaStore store,
  CatalogScope scope,
  UuidValue billId, {
  Transaction? transaction,
}) async {
  final session = store.session;
  final sale = await _openSale(
    session,
    scope,
    billId,
    transaction: transaction,
  );
  final rates = await loadFnbRates(session, scope, transaction: transaction);
  return (await _bills(
    session,
    scope,
    [sale],
    rates,
    transaction: transaction,
  )).single;
}

// --- Nomor harian -----------------------------------------------------------

/// Awal hari lokal cabang (UTC) untuk [now].
DateTime _localDayStart(DateTime now, String? timezone) {
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

Future<(Outlet, Device, String?)> _place(SyncTx w, CatalogScope scope) async {
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
  final tenant = await Tenant.db.findById(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  return (outlet, device, outlet.timezone ?? tenant?.timezone);
}

const _billPrefix = 'OB';

Future<String> _nextBillNumber(
  SyncTx w,
  CatalogScope scope,
  DateTime now,
) async {
  final (outlet, device, timezone) = await _place(w, scope);
  final local = outletLocalTime(now, timezone);
  final prefix =
      '$_billPrefix-${receiptPrefix(outlet.code, device.code, local)}';
  final existing = await Sale.db.find(
    w.session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) & s.billNumber.like('$prefix%'),
    transaction: w.transaction,
  );
  final counter = nextReceiptCounter(
    existing.map((s) => s.billNumber ?? ''),
    prefix,
  );
  return documentNumber(_billPrefix, outlet.code, device.code, local, counter);
}

Future<DateTime> _dayStart(SyncTx w, CatalogScope scope, DateTime now) async {
  final (_, _, timezone) = await _place(w, scope);
  return _localDayStart(now, timezone);
}

// --- Buka bill --------------------------------------------------------------

Sale _newBill(
  CatalogScope scope,
  SyncStamp s, {
  required UuidValue staffId,
  required String number,
  required OrderType type,
  UuidValue? tableId,
  int? queue,
  String? customerName,
  int? guests,
}) => Sale(
  tenantId: scope.tenantId,
  outletId: scope.outletId,
  deviceId: scope.deviceId,
  staffId: staffId,
  number: number,
  billNumber: number,
  status: SaleStatus.open,
  orderType: type,
  diningTableId: tableId,
  queueNumber: queue,
  customerName: customerName,
  guestCount: guests,
  openedBy: staffId,
  openedAt: s.now,
  subtotal: 0,
  tierDiscount: 0,
  total: 0,
  paidAmount: 0,
  changeAmount: 0,
  itemCount: 0,
  soldAt: s.now,
  createdAt: s.now,
  updatedAt: s.now,
  createdBy: staffId,
  updatedBy: staffId,
  hlc: s.hlc.toString(),
  originDeviceId: s.deviceId,
);

Future<Sale?> _tableBill(SyncTx w, CatalogScope scope, UuidValue tableId) =>
    Sale.db.findFirstRow(
      w.session,
      where: (s) =>
          s.tenantId.equals(scope.tenantId) &
          s.diningTableId.equals(tableId) &
          s.status.equals(SaleStatus.open) &
          s.deletedAt.equals(null),
      transaction: w.transaction,
    );

Future<DiningTable> _table(SyncTx w, CatalogScope scope, UuidValue id) async {
  final table = await DiningTable.db.findFirstRow(
    w.session,
    where: (t) =>
        t.id.equals(id) &
        t.tenantId.equals(scope.tenantId) &
        t.outletId.equals(scope.outletId) &
        t.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (table == null) throw DiningNotFound();
  return table;
}

/// Membuka bill meja [tableId] untuk [guests] tamu. Bila meja sudah punya
/// bill terbuka, bill itu yang dikembalikan (tanpa menulis).
Future<OpenBill> openTableBill(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue tableId,
  required int guests,
}) async {
  if (guests < 1 || guests > FnbLimits.guestsMax) {
    throw const BillInputInvalid(BillField.guests);
  }
  final id = await store.write(actor: staffId, (w) async {
    await _table(w, scope, tableId);
    final existing = await _tableBill(w, scope, tableId);
    if (existing != null) return existing.id;
    final s = await w.stamp();
    final number = await _nextBillNumber(w, scope, s.now);
    final sale = await w.insert(
      _newBill(
        scope,
        s,
        staffId: staffId,
        number: number,
        type: OrderType.dineIn,
        tableId: tableId,
        guests: guests,
      ),
      s,
    );
    return sale.id;
  });
  return loadOpenBill(store, scope, id);
}

String? _customer(String? name) {
  final t = name?.trim() ?? '';
  if (t.characters.length > FnbLimits.customerName) {
    throw const BillInputInvalid(BillField.customerName);
  }
  return t.isEmpty ? null : t;
}

/// *Take away baru*: memakai ulang take away kosong perangkat ini hari ini,
/// atau membuat bill baru bernomor `TA-nn` berikutnya.
Future<OpenBill> openTakeAway(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  String? customerName,
}) async {
  final name = _customer(customerName);
  final id = await store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    final start = await _dayStart(w, scope, s.now);
    final today = await Sale.db.find(
      w.session,
      where: (x) =>
          x.tenantId.equals(scope.tenantId) &
          x.deviceId.equals(scope.deviceId) &
          x.orderType.equals(OrderType.takeAway) &
          (x.openedAt >= start),
      transaction: w.transaction,
    );
    final empty = today
        .where(
          (x) =>
              x.status == SaleStatus.open &&
              x.deletedAt == null &&
              x.itemCount == 0,
        )
        .firstOrNull;
    if (empty != null) {
      // Pemesan baru menggantikan nama lama (juga bila kosong).
      if (name != empty.customerName) {
        await w.update(
          empty.copyWith(
            customerName: name,
            version: empty.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      }
      return empty.id;
    }
    final number = await _nextBillNumber(w, scope, s.now);
    final sale = await w.insert(
      _newBill(
        scope,
        s,
        staffId: staffId,
        number: number,
        type: OrderType.takeAway,
        queue: nextDailyNumber(today.map((x) => x.queueNumber ?? 0)),
        customerName: name,
      ),
      s,
    );
    return sale.id;
  });
  return loadOpenBill(store, scope, id);
}

// --- Item -------------------------------------------------------------------

Future<void> _refreshTotals(
  SyncTx w,
  CatalogScope scope,
  Sale sale,
  SyncStamp s,
  UuidValue staffId,
) async {
  final items = await _items(w.session, scope.tenantId, [
    sale.id,
  ], transaction: w.transaction);
  final rates = await loadFnbRates(
    w.session,
    scope,
    transaction: w.transaction,
  );
  final charges = _charges(sale, items, rates);
  final list = Money.sum(
    items.map((i) => Money(i.listPrice).timesMilli(i.quantityMilli)),
  );
  await w.update(
    sale.copyWith(
      subtotal: list.value,
      tierDiscount: (list - charges.subtotal).value,
      total: charges.total.value,
      itemCount: items.length,
      version: sale.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
}

String? _note(String? note) {
  final t = note?.trim() ?? '';
  if (t.characters.length > FnbLimits.itemNote) {
    throw const BillInputInvalid(BillField.note);
  }
  return t.isEmpty ? null : t;
}

/// Menambah [line] ke bill. Baris *Baru* dengan varian, satuan, dan
/// catatan yang sama digabung; selain itu baris baru. Harga dari database
/// (grosir sesuai jumlah baris) dan dibekukan di baris.
Future<OpenBill> addBillItem(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  required SaleLineRequest line,
  String? note,
}) async {
  if (!line.quantity.isPositive) throw const SaleQuantityInvalid(0);
  final cleanNote = _note(note);
  await store.write(actor: staffId, (w) async {
    final sale = await _openSale(
      w.session,
      scope,
      billId,
      transaction: w.transaction,
    );
    final items = await _items(w.session, scope.tenantId, [
      sale.id,
    ], transaction: w.transaction);
    final same = items
        .where(
          (i) =>
              i.kitchenStatus == KitchenStatus.pending &&
              i.variantId == line.variantId &&
              i.productUnitId == line.productUnitId &&
              i.note == cleanNote,
        )
        .firstOrNull;
    final quantity = Qty(same?.quantityMilli ?? 0) + line.quantity;
    final [priced] = await priceRequests(w.session, w.transaction, scope, [
      SaleLineRequest(
        variantId: line.variantId,
        productUnitId: line.productUnitId,
        quantity: quantity,
      ),
    ]);
    final s = await w.stamp();
    if (same != null) {
      await w.update(_repriced(same, priced, s, staffId), s);
    } else {
      await w.insert(
        SaleItem(
          tenantId: scope.tenantId,
          saleId: sale.id,
          variantId: priced.variant.id,
          productUnitId: priced.unit?.id,
          productName: priced.product.name,
          variantName: priced.variant.name,
          unitName: priced.unitName,
          factorMilli: priced.line.factor.milli,
          quantityMilli: priced.line.quantity.milli,
          listPrice: priced.line.listPrice.value,
          unitPrice: priced.line.unitPrice.value,
          lineTotal: priced.line.lineTotal.value,
          unitCost: 0,
          tracksStock: priced.tracksStock,
          sortOrder:
              items.fold(-1, (m, i) => i.sortOrder > m ? i.sortOrder : m) + 1,
          kitchenStatus: KitchenStatus.pending,
          note: cleanNote,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    await _refreshTotals(w, scope, sale, s, staffId);
  });
  return loadOpenBill(store, scope, billId);
}

SaleItem _repriced(
  SaleItem item,
  PricedRequest priced,
  SyncStamp s,
  UuidValue staffId,
) => item.copyWith(
  quantityMilli: priced.line.quantity.milli,
  listPrice: priced.line.listPrice.value,
  unitPrice: priced.line.unitPrice.value,
  lineTotal: priced.line.lineTotal.value,
  version: item.version + 1,
  updatedAt: s.now,
  updatedBy: staffId,
  hlc: s.hlc.toString(),
  originDeviceId: s.deviceId,
);

Future<(Sale, SaleItem)> _billItem(
  SyncTx w,
  CatalogScope scope,
  UuidValue itemId,
) async {
  final item = await SaleItem.db.findFirstRow(
    w.session,
    where: (i) =>
        i.id.equals(itemId) &
        i.tenantId.equals(scope.tenantId) &
        i.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (item == null) throw BillNotFound();
  final sale = await _openSale(
    w.session,
    scope,
    item.saleId,
    transaction: w.transaction,
  );
  return (sale, item);
}

/// Mengubah jumlah item *Baru*; nol atau kurang menghapusnya. Item yang
/// sudah dikirim ke dapur ditolak ([BillItemLocked]).
Future<OpenBill> setBillItemQuantity(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue itemId,
  required Qty quantity,
}) async {
  final billId = await store.write(actor: staffId, (w) async {
    final (sale, item) = await _billItem(w, scope, itemId);
    if (item.kitchenStatus != KitchenStatus.pending) throw BillItemLocked();
    final s = await w.stamp();
    if (quantity.isPositive) {
      final [priced] = await priceRequests(w.session, w.transaction, scope, [
        SaleLineRequest(
          variantId: item.variantId,
          productUnitId: item.productUnitId,
          quantity: quantity,
        ),
      ]);
      await w.update(_repriced(item, priced, s, staffId), s);
    } else {
      await w.update(
        item.copyWith(
          deletedAt: s.now,
          version: item.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    await _refreshTotals(w, scope, sale, s, staffId);
    return sale.id;
  });
  return loadOpenBill(store, scope, billId);
}

/// Menandai item *Di dapur* sebagai *Disajikan*.
Future<OpenBill> markItemServed(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue itemId,
}) async {
  final billId = await store.write(actor: staffId, (w) async {
    final (sale, item) = await _billItem(w, scope, itemId);
    if (item.kitchenStatus != KitchenStatus.sent) throw BillItemLocked();
    final s = await w.stamp();
    await w.update(
      item.copyWith(
        kitchenStatus: KitchenStatus.served,
        version: item.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    return sale.id;
  });
  return loadOpenBill(store, scope, billId);
}

// --- Dapur ------------------------------------------------------------------

/// Mengirim semua item *Baru* ke dapur: tiket `K-nnnn` baru dan status
/// item → *Di dapur*. Tanpa item baru → [NothingToSend].
Future<KitchenSendResult> sendToKitchen(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
}) async {
  final (ticket, sent) = await store.write(actor: staffId, (w) async {
    final sale = await _openSale(
      w.session,
      scope,
      billId,
      transaction: w.transaction,
    );
    final pending = [
      for (final i in await _items(w.session, scope.tenantId, [
        sale.id,
      ], transaction: w.transaction))
        if (i.kitchenStatus == KitchenStatus.pending) i,
    ];
    if (pending.isEmpty) throw NothingToSend();
    final s = await w.stamp();
    final start = await _dayStart(w, scope, s.now);
    final today = await KitchenTicket.db.find(
      w.session,
      where: (t) =>
          t.tenantId.equals(scope.tenantId) &
          t.deviceId.equals(scope.deviceId) &
          (t.sentAt >= start),
      transaction: w.transaction,
    );
    final ticket = await w.insert(
      KitchenTicket(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        saleId: sale.id,
        number: nextDailyNumber(today.map((t) => t.number)),
        staffId: staffId,
        sentAt: s.now,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    final sent = [
      for (final i in pending)
        await w.update(
          i.copyWith(
            kitchenStatus: KitchenStatus.sent,
            kitchenTicketId: ticket.id,
            version: i.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        ),
    ];
    return (ticket, sent);
  });
  final names = await _staffNames(store.session, scope.tenantId, [staffId]);
  return KitchenSendResult(
    ticket: ticket,
    items: sent,
    bill: await loadOpenBill(store, scope, billId),
    staffName: names[staffId] ?? '',
  );
}

// --- Aksi bill --------------------------------------------------------------

Future<OpenBill> _updateBill(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  required Future<Sale> Function(SyncTx w, Sale sale, SyncStamp s) change,
}) async {
  await store.write(actor: staffId, (w) async {
    final sale = await _openSale(
      w.session,
      scope,
      billId,
      transaction: w.transaction,
    );
    final s = await w.stamp();
    final next = await change(w, sale, s);
    await w.update(
      next.copyWith(
        version: sale.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
  return loadOpenBill(store, scope, billId);
}

/// *Minta bill* ([requested] `true`) atau membatalkannya.
Future<OpenBill> setBillRequested(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  required bool requested,
}) => _updateBill(
  store,
  scope,
  staffId: staffId,
  billId: billId,
  change: (w, sale, s) async =>
      sale.copyWith(billRequestedAt: requested ? s.now : null),
);

/// *Pindah meja* bill dine in ke meja kosong [tableId].
Future<OpenBill> moveBillToTable(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  required UuidValue tableId,
}) => _updateBill(
  store,
  scope,
  staffId: staffId,
  billId: billId,
  change: (w, sale, s) async {
    if (sale.orderType != OrderType.dineIn) throw BillNotFound();
    await _table(w, scope, tableId);
    final other = await _tableBill(w, scope, tableId);
    if (other != null && other.id != sale.id) throw TableOccupied();
    return sale.copyWith(diningTableId: tableId);
  },
);

/// *Batalkan bill* dengan [reason] (wajib, ≤ 120). Stok tidak bergerak.
/// Izin `sales:void` diperiksa pemanggil.
Future<void> voidOpenBill(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  required String reason,
}) async {
  final text = reason.trim();
  if (text.isEmpty || text.characters.length > FnbLimits.voidReason) {
    throw const BillInputInvalid(BillField.voidReason);
  }
  await store.write(actor: staffId, (w) async {
    final sale = await _openSale(
      w.session,
      scope,
      billId,
      transaction: w.transaction,
    );
    final s = await w.stamp();
    await w.update(
      sale.copyWith(
        status: SaleStatus.voided,
        voidReason: text,
        voidedBy: staffId,
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

/// *Hapus bill kosong* (soft delete). Bill berisi item → [BillNotEmpty].
Future<void> deleteEmptyBill(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
}) => store.write(actor: staffId, (w) async {
  final sale = await _openSale(
    w.session,
    scope,
    billId,
    transaction: w.transaction,
  );
  final items = await _items(w.session, scope.tenantId, [
    sale.id,
  ], transaction: w.transaction);
  if (items.isNotEmpty) throw BillNotEmpty();
  final s = await w.stamp();
  await w.update(
    sale.copyWith(
      deletedAt: s.now,
      version: sale.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

// --- Tutup & bayar ----------------------------------------------------------

/// *Tutup & bayar*: total = subtotal + service + PB1 dengan tarif terkini
/// (dibekukan di nota), nomor nota biasa, sesi kasir perangkat ini, stok
/// bergerak sekali, `staff_id` = [staffId] (penerima bayar). Gagal seperti
/// [checkoutSale]; bill tanpa item → [SaleEmpty].
Future<CheckoutResult> payOpenBill(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  required List<SalePaymentRequest> payments,
}) async {
  checkPaymentRequests(payments);
  return store.write(actor: staffId, (w) async {
    final cash = await requireOpenCashSession(store, w, scope);
    final sale = await _openSale(
      w.session,
      scope,
      billId,
      transaction: w.transaction,
    );
    final items = await _items(w.session, scope.tenantId, [
      sale.id,
    ], transaction: w.transaction);
    if (items.isEmpty) throw SaleEmpty();
    final rates = await loadFnbRates(
      w.session,
      scope,
      transaction: w.transaction,
    );
    final charges = _charges(sale, items, rates);
    final total = charges.total;
    final (amounts, change) = await settlePayments(w, scope, total, payments);

    final s = await w.stamp();
    final location = await defaultStockLocationIn(w, scope);
    final variants = {
      for (final v in await ProductVariant.db.find(
        w.session,
        where: (v) =>
            v.tenantId.equals(scope.tenantId) &
            v.id.inSet({for (final i in items) i.variantId}),
        transaction: w.transaction,
      ))
        v.id: v,
    };
    final paidItems = <SaleItem>[];
    for (final item in items) {
      final cost = await averageCost(
        w,
        location.id,
        item.variantId,
        Money(variants[item.variantId]?.costPrice ?? 0),
      );
      paidItems.add(
        await w.update(
          item.copyWith(
            unitCost: cost.value,
            version: item.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        ),
      );
      if (item.tracksStock) {
        await recordStockMovement(
          w,
          scope,
          locationId: location.id,
          variantId: item.variantId,
          quantity: -Qty(item.quantityMilli).toBaseUnit(item.factorMilli),
          unitCost: cost,
          sourceType: StockSourceType.sale,
          sourceId: sale.id,
          stamp: s,
        );
      }
    }
    final list = Money.sum(
      items.map((i) => Money(i.listPrice).timesMilli(i.quantityMilli)),
    );
    final paid = await w.update(
      sale.copyWith(
        number: await nextReceiptNumber(w, scope, s.now),
        status: SaleStatus.completed,
        cashSessionId: cash.id,
        staffId: staffId,
        subtotal: list.value,
        tierDiscount: (list - charges.subtotal).value,
        total: total.value,
        paidAmount: total.value,
        changeAmount: change.value,
        itemCount: items.length,
        soldAt: s.now,
        serviceBp: rates.service.value,
        taxBp: rates.tax.value,
        serviceAmount: charges.service.value,
        taxAmount: charges.tax.value,
        version: sale.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    final paymentRows = await insertPayments(
      w,
      scope,
      saleId: sale.id,
      staffId: staffId,
      payments: payments,
      amounts: amounts,
      change: change,
      stamp: s,
    );
    final negative = await negativeStockAfterSale(w, location.id, {
      for (final i in items)
        if (i.tracksStock)
          i.variantId: '${i.productName} ${i.variantName}'.trim(),
    });
    return CheckoutResult(
      sale: paid,
      items: paidItems,
      payments: paymentRows,
      negativeStock: negative,
    );
  });
}
