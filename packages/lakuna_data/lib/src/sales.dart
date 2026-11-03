import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'cash.dart';
import 'history.dart' show soldStatuses;
import 'sale_core.dart';
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Satu baris keranjang yang dikirim kasir (F1-04). Harga tidak ikut: harga
/// selalu dihitung ulang dari database.
class SaleLineRequest {
  const SaleLineRequest({
    required this.variantId,
    required this.quantity,
    this.productUnitId,
  });

  final UuidValue variantId;

  /// Satuan konversi; `null` = satuan dasar.
  final UuidValue? productUnitId;

  /// Jumlah dalam satuan baris.
  final Qty quantity;
}

/// Satu pembayaran yang dipilih di layar bayar (F1-05). Satu nota bisa
/// punya beberapa (split).
class SalePaymentRequest {
  const SalePaymentRequest({
    required this.method,
    this.amount,
    this.reference = '',
    this.confirmed = false,
  });

  /// Tunai dengan uang diterima [amount].
  const SalePaymentRequest.cash(Money this.amount)
    : method = PaymentMethod.cash,
      reference = '',
      confirmed = false;

  final PaymentMethod method;

  /// Tunai: uang diterima. Non-tunai: jumlah dibayar; `null` pada
  /// pembayaran tunggal berarti sama dengan total.
  final Money? amount;

  /// No. approval kartu atau referensi transfer.
  final String reference;

  /// Kasir sudah menekan *Sudah Terbayar* (wajib untuk QRIS statis).
  final bool confirmed;

  bool get isCash => method == PaymentMethod.cash;
}

/// Keranjang kosong.
class SaleEmpty implements Exception {
  @override
  String toString() => 'SaleEmpty';
}

/// Jumlah baris ke-[index] tidak positif.
class SaleQuantityInvalid implements Exception {
  const SaleQuantityInvalid(this.index);

  final int index;

  @override
  String toString() => 'SaleQuantityInvalid($index)';
}

/// Varian (atau satuannya) tidak ada, terhapus, atau produknya nonaktif.
class SaleItemUnavailable implements Exception {
  const SaleItemUnavailable(this.variantId);

  final UuidValue variantId;

  @override
  String toString() => 'SaleItemUnavailable($variantId)';
}

/// Uang tunai diterima kurang dari total nota.
class SalePaymentShort implements Exception {
  const SalePaymentShort({required this.total, required this.received});

  final Money total;
  final Money received;

  @override
  String toString() => 'SalePaymentShort(total: $total, received: $received)';
}

/// No. approval / referensi terlalu panjang.
class SaleReferenceInvalid implements Exception {
  @override
  String toString() => 'SaleReferenceInvalid';
}

/// Pembagian pembayaran tidak sah (lihat [TenderError]); kurang bayar
/// memakai [SalePaymentShort].
class SalePaymentInvalid implements Exception {
  const SalePaymentInvalid(this.error);

  final TenderError error;

  @override
  String toString() => 'SalePaymentInvalid($error)';
}

/// QRIS statis belum dikonfirmasi *Sudah Terbayar*.
class SalePaymentUnconfirmed implements Exception {
  @override
  String toString() => 'SalePaymentUnconfirmed';
}

/// Metode bayar tidak tersedia, mis. QRIS statis nonaktif di cabang ini.
class SalePaymentUnsupported implements Exception {
  const SalePaymentUnsupported(this.method);

  final PaymentMethod method;

  @override
  String toString() => 'SalePaymentUnsupported($method)';
}

/// Varian yang stoknya jadi minus setelah nota tersimpan.
class NegativeStock {
  const NegativeStock({
    required this.variantId,
    required this.name,
    required this.onHand,
  });

  final UuidValue variantId;

  /// Nama produk + varian, mis. "Minyak Goreng 2 L".
  final String name;
  final Qty onHand;
}

/// Hasil [checkoutSale].
class CheckoutResult {
  const CheckoutResult({
    required this.sale,
    required this.items,
    required this.payments,
    this.negativeStock = const [],
    this.modifiers = const {},
  });

  final Sale sale;

  /// Urut sesuai keranjang.
  final List<SaleItem> items;

  /// Urut sesuai permintaan.
  final List<Payment> payments;
  final List<NegativeStock> negativeStock;

  /// Modifier per item (bill F&B), urut `sort_order`.
  final Map<UuidValue, List<SaleItemModifier>> modifiers;

  List<SaleItemModifier> modifiersOf(SaleItem item) =>
      modifiers[item.id] ?? const [];
}

/// Menyimpan penjualan [lines] dengan [payments] (satu atau lebih, split)
/// dalam satu transaksi: nota, item, pembayaran, pergerakan stok, dan
/// outbox. Butuh sesi kasir terbuka di perangkat ini
/// ([CashSessionNotOpen]). Harga dihitung ulang dari database. QRIS statis
/// harus aktif di cabang dan sudah dikonfirmasi; `confirmed_by` = [staffId].
Future<CheckoutResult> checkoutSale(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required List<SaleLineRequest> lines,
  required List<SalePaymentRequest> payments,
}) async {
  if (lines.isEmpty) throw SaleEmpty();
  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].quantity.isPositive) throw SaleQuantityInvalid(i);
  }
  checkPaymentRequests(payments);
  return store.write(actor: staffId, (w) async {
    final session = await requireOpenCashSession(store, w, scope);
    final priced = await priceRequests(w.session, w.transaction, scope, lines);
    final totals = SaleTotals.of(priced.map((p) => p.line));
    final total = totals.total;

    final (amounts, change) = await settlePayments(w, scope, total, payments);

    final s = await w.stamp();
    final number = await nextReceiptNumber(w, scope, s.now);
    final sale = await w.insert(
      Sale(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
        cashSessionId: session.id,
        staffId: staffId,
        number: number,
        status: SaleStatus.completed,
        subtotal: totals.subtotal.value,
        tierDiscount: totals.tierDiscount.value,
        total: total.value,
        paidAmount: total.value,
        changeAmount: change.value,
        itemCount: priced.length,
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

    final location = await defaultStockLocationIn(w, scope);
    final items = <SaleItem>[];
    for (var i = 0; i < priced.length; i++) {
      final p = priced[i];
      final unitCost = await averageCost(
        w,
        location.id,
        p.variant.id,
        Money(p.variant.costPrice),
      );
      items.add(
        await w.insert(
          SaleItem(
            tenantId: scope.tenantId,
            saleId: sale.id,
            variantId: p.variant.id,
            productUnitId: p.unit?.id,
            productName: p.product.name,
            variantName: p.variant.name,
            unitName: p.unitName,
            factorMilli: p.line.factor.milli,
            quantityMilli: p.line.quantity.milli,
            listPrice: p.line.listPrice.value,
            unitPrice: p.line.unitPrice.value,
            lineTotal: p.line.lineTotal.value,
            unitCost: unitCost.value,
            tracksStock: p.tracksStock,
            sortOrder: i,
            createdAt: s.now,
            updatedAt: s.now,
            createdBy: staffId,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        ),
      );
      if (p.tracksStock) {
        await recordStockMovement(
          w,
          scope,
          locationId: location.id,
          variantId: p.variant.id,
          quantity: -p.line.baseQuantity,
          unitCost: unitCost,
          sourceType: StockSourceType.sale,
          sourceId: sale.id,
          stamp: s,
        );
      }
    }

    final paid = await insertPayments(
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
      for (final p in priced)
        if (p.tracksStock)
          p.variant.id: '${p.product.name} ${p.variant.name}'.trim(),
    });
    return CheckoutResult(
      sale: sale,
      items: items,
      payments: paid,
      negativeStock: negative,
    );
  });
}

/// Nomor nota berikutnya perangkat ini (tanggal lokal cabang).
Future<String> nextReceiptNumber(
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
  final tenant = await Tenant.db.findById(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final local = outletLocalTime(now, outlet.timezone ?? tenant?.timezone);
  final prefix = receiptPrefix(outlet.code, device.code, local);
  final existing = await Sale.db.find(
    w.session,
    where: (s) => s.tenantId.equals(scope.tenantId) & s.number.like('$prefix%'),
    transaction: w.transaction,
  );
  final counter = nextReceiptCounter(existing.map((s) => s.number), prefix);
  return receiptNumber(outlet.code, device.code, local, counter);
}

/// Ringkasan penjualan satu sesi kasir (layar tutup sesi dan rekap laci).
class SessionSalesSummary {
  const SessionSalesSummary({
    this.count = 0,
    this.total = Money.zero,
    this.cash = Money.zero,
    this.nonCash = Money.zero,
    this.voidCount = 0,
    this.returnCount = 0,
  });

  /// Jumlah nota lunas.
  final int count;
  final Money total;

  /// Tunai bersih (diterima − kembalian), masuk laci.
  final Money cash;

  /// Kartu, transfer, QRIS: tidak masuk laci.
  final Money nonCash;

  /// Nota sesi ini yang di-void (F1-11).
  final int voidCount;

  /// Dokumen retur yang dicatat di sesi ini (F1-11).
  final int returnCount;
}

/// Ringkasan nota lunas di sesi [sessionId].
Future<SessionSalesSummary> salesSummaryForSession(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue sessionId,
  Transaction? transaction,
}) => sessionSalesSummary(
  store.session,
  tenantId: scope.tenantId,
  sessionId: sessionId,
  transaction: transaction,
);

/// Versi [salesSummaryForSession] untuk modul lain (rekap laci F1-03).
Future<SessionSalesSummary> sessionSalesSummary(
  DatabaseSession session, {
  required UuidValue tenantId,
  required UuidValue sessionId,
  Transaction? transaction,
}) async {
  final sales = await Sale.db.find(
    session,
    where: (s) =>
        s.tenantId.equals(tenantId) &
        s.cashSessionId.equals(sessionId) &
        // Nota yang kemudian diretur tetap terjual di sesi ini; retur tunai
        // dikurangkan terpisah (`cashRefunds`).
        s.status.inSet(soldStatuses) &
        s.deletedAt.equals(null),
    transaction: transaction,
  );
  final voidCount = await Sale.db.count(
    session,
    where: (s) =>
        s.tenantId.equals(tenantId) &
        s.cashSessionId.equals(sessionId) &
        s.status.equals(SaleStatus.voided) &
        s.deletedAt.equals(null),
    transaction: transaction,
  );
  final returnCount = await SaleReturn.db.count(
    session,
    where: (r) =>
        r.tenantId.equals(tenantId) &
        r.cashSessionId.equals(sessionId) &
        r.deletedAt.equals(null),
    transaction: transaction,
  );
  if (sales.isEmpty) {
    return SessionSalesSummary(voidCount: voidCount, returnCount: returnCount);
  }
  final payments = await Payment.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(tenantId) &
        p.saleId.inSet({for (final s in sales) s.id}) &
        p.status.equals(PaymentStatus.paid) &
        p.deletedAt.equals(null),
    transaction: transaction,
  );
  var cash = Money.zero;
  var nonCash = Money.zero;
  for (final p in payments) {
    if (p.method == PaymentMethod.cash) {
      cash += Money(p.amount - p.changeAmount);
    } else {
      nonCash += Money(p.amount);
    }
  }
  return SessionSalesSummary(
    count: sales.length,
    total: Money.sum(sales.map((s) => Money(s.total))),
    cash: cash,
    nonCash: nonCash,
    voidCount: voidCount,
    returnCount: returnCount,
  );
}
