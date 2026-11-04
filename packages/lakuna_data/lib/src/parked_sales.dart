import 'package:characters/characters.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'customers.dart' show saleCustomer;
import 'open_bill.dart' show nextBillNumber;
import 'sales.dart';
import 'stock.dart';
import 'store.dart';
import 'store_settings.dart' show loadSalesRules;
import 'sync_tx.dart';

// Nota tersimpan (parkir) Kasir retail (F1-04d): `sales` berstatus `open`,
// `order_type = retail`, tanpa meja dan tanpa pembayaran. Stok baru bergerak
// saat nota dibayar lewat [checkoutSale] dengan `parkedSaleId`.

/// Nota tersimpan tidak ada (sudah dibayar, dihapus, atau bukan nota retail).
class ParkedSaleNotFound implements Exception {
  @override
  String toString() => 'ParkedSaleNotFound';
}

/// Catatan nota tersimpan terlalu panjang.
class ParkedNoteTooLong implements Exception {
  const ParkedNoteTooLong();

  @override
  String toString() => 'ParkedNoteTooLong';
}

/// Panjang maksimal catatan nota tersimpan (sama dengan nama take away).
const parkedNoteMaxLength = FnbLimits.customerName;

/// Satu baris daftar *Nota tersimpan*.
class ParkedSaleRow {
  const ParkedSaleRow({
    required this.id,
    required this.number,
    required this.title,
    required this.staffName,
    required this.itemCount,
    required this.total,
    required this.savedAt,
  });

  final UuidValue id;
  final String number;

  /// Nama pelanggan atau catatan; `null` = tanpa nama.
  final String? title;
  final String staffName;
  final int itemCount;
  final Money total;
  final DateTime savedAt;
}

/// Isi nota tersimpan untuk dimuat ulang ke keranjang. Harga dihitung ulang
/// dari katalog saat dibayar.
class ParkedSale {
  const ParkedSale({
    required this.id,
    required this.lines,
    this.customerId,
    this.customerName,
    this.note,
    this.discount,
  });

  final UuidValue id;
  final List<SaleLineRequest> lines;
  final UuidValue? customerId;

  /// Nama pelanggan saat disimpan.
  final String? customerName;

  /// Catatan nota tanpa pelanggan.
  final String? note;
  final ManualDiscount? discount;
}

String? _note(String? note) {
  final t = note?.trim() ?? '';
  if (t.characters.length > parkedNoteMaxLength) {
    throw const ParkedNoteTooLong();
  }
  return t.isEmpty ? null : t;
}

ManualDiscount? _discount(int bp, int amount) => bp > 0
    ? ManualDiscount.percent(BasisPoints(bp))
    : amount > 0
    ? ManualDiscount.amount(Money(amount))
    : null;

/// *Simpan nota*: menyimpan keranjang sebagai nota tersimpan. [replaceId]
/// = nota tersimpan asal keranjang ini, dihapus dalam transaksi yang sama.
Future<Sale> parkSale(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required List<SaleLineRequest> lines,
  ManualDiscount? discount,
  UuidValue? customerId,
  String? note,
  UuidValue? replaceId,
}) async {
  if (lines.isEmpty) throw SaleEmpty();
  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].quantity.isPositive) throw SaleQuantityInvalid(i);
  }
  final cleanNote = _note(note);
  return store.write(actor: staffId, (w) async {
    final rules = await loadSalesRules(
      w.session,
      scope,
      transaction: w.transaction,
    );
    final p = await priceSaleLines(w, scope, lines, discount, rules);
    final s = await w.stamp();
    if (replaceId != null) {
      await removeParkedSale(w, scope, replaceId, staffId, s, mustExist: false);
    }
    final customer = customerId == null
        ? null
        : await saleCustomer(w, scope, customerId);
    final number = await nextBillNumber(w, scope, s.now);
    final sale = await w.insert(
      Sale(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        staffId: staffId,
        number: number,
        billNumber: number,
        status: SaleStatus.open,
        orderType: OrderType.retail,
        customerId: customer?.id,
        customerName: customer?.name ?? cleanNote,
        openedBy: staffId,
        openedAt: s.now,
        subtotal: p.totals.subtotal.value,
        tierDiscount: p.totals.tierDiscount.value,
        lineDiscountAmount: p.lineDiscount.value,
        discountAmount: p.billCut.value,
        discountBp: discount?.bp ?? 0,
        roundingAmount: (p.total - p.net).value,
        total: p.total.value,
        paidAmount: 0,
        changeAmount: 0,
        itemCount: p.priced.length,
        soldAt: s.now,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    for (var i = 0; i < p.priced.length; i++) {
      final item = p.priced[i];
      await w.insert(
        SaleItem(
          tenantId: scope.tenantId,
          saleId: sale.id,
          variantId: item.variant.id,
          productUnitId: item.unit?.id,
          productName: item.product.name,
          variantName: item.variant.name,
          unitName: item.unitName,
          factorMilli: item.line.factor.milli,
          quantityMilli: item.line.quantity.milli,
          listPrice: item.line.listPrice.value,
          unitPrice: item.line.unitPrice.value,
          lineTotal: (item.line.lineTotal - p.lineCuts[i]).value,
          discountAmount: p.lineCuts[i].value,
          discountBp: lines[i].discount?.bp ?? 0,
          unitCost: 0,
          tracksStock: item.tracksStock,
          sortOrder: i,
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
    return sale;
  });
}

Future<Sale?> _findParked(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue id, {
  Transaction? transaction,
}) => Sale.db.findFirstRow(
  session,
  where: (s) =>
      s.id.equals(id) &
      s.tenantId.equals(scope.tenantId) &
      s.outletId.equals(scope.outletId) &
      s.status.equals(SaleStatus.open) &
      s.orderType.equals(OrderType.retail) &
      s.deletedAt.equals(null),
  transaction: transaction,
);

/// Menghapus (soft delete) nota tersimpan [id] di dalam transaksi [w].
/// Dipakai saat dibayar, disimpan ulang, atau dihapus.
Future<void> removeParkedSale(
  SyncTx w,
  CatalogScope scope,
  UuidValue id,
  UuidValue staffId,
  SyncStamp s, {
  bool mustExist = true,
}) async {
  final sale = await _findParked(
    w.session,
    scope,
    id,
    transaction: w.transaction,
  );
  if (sale == null) {
    if (mustExist) throw ParkedSaleNotFound();
    return;
  }
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
}

/// *Hapus* nota tersimpan. Stok tidak tersentuh karena belum bergerak.
Future<void> deleteParkedSale(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
}) => store.write(actor: staffId, (w) async {
  final s = await w.stamp();
  await removeParkedSale(w, scope, id, staffId, s);
});

/// Nota tersimpan cabang [scope], terbaru dulu.
Future<List<ParkedSaleRow>> listParkedSales(
  DatabaseSession session,
  CatalogScope scope,
) async {
  final sales = await Sale.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.outletId.equals(scope.outletId) &
        s.status.equals(SaleStatus.open) &
        s.orderType.equals(OrderType.retail) &
        s.deletedAt.equals(null),
    orderByList: (s) => [s.createdAt, s.number],
  );
  final staffIds = {for (final s in sales) s.staffId};
  final names = staffIds.isEmpty
      ? const <UuidValue, String>{}
      : {
          for (final m in await StaffMember.db.find(
            session,
            where: (m) =>
                m.tenantId.equals(scope.tenantId) & m.id.inSet(staffIds),
          ))
            m.id: m.name,
        };
  return [
    for (final s in sales.reversed)
      ParkedSaleRow(
        id: s.id,
        number: s.number,
        title: s.customerName,
        staffName: names[s.staffId] ?? '',
        itemCount: s.itemCount,
        total: Money(s.total),
        savedAt: s.createdAt,
      ),
  ];
}

/// Isi nota tersimpan [id] untuk dilanjutkan di Kasir.
Future<ParkedSale> loadParkedSale(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue id,
) async {
  final sale = await _findParked(session, scope, id);
  if (sale == null) throw ParkedSaleNotFound();
  final items = await SaleItem.db.find(
    session,
    where: (i) =>
        i.tenantId.equals(scope.tenantId) &
        i.saleId.equals(sale.id) &
        i.deletedAt.equals(null),
    orderBy: (i) => i.sortOrder,
  );
  return ParkedSale(
    id: sale.id,
    customerId: sale.customerId,
    customerName: sale.customerId == null ? null : sale.customerName,
    note: sale.customerId == null ? sale.customerName : null,
    discount: _discount(sale.discountBp, sale.discountAmount),
    lines: [
      for (final i in items)
        SaleLineRequest(
          variantId: i.variantId,
          productUnitId: i.productUnitId,
          quantity: Qty(i.quantityMilli),
          discount: _discount(i.discountBp, i.discountAmount),
        ),
    ],
  );
}
