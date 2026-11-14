import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'cash.dart';
import 'customers.dart';
import 'history.dart' show requireApprover, soldStatuses;
import 'parked_sales.dart' show removeParkedSale;
import 'sale_core.dart';
import 'staff_access.dart' show findStaffById;
import 'stock.dart';
import 'store.dart';
import 'store_settings.dart';
import 'sync_tx.dart';

/// Satu baris keranjang yang dikirim kasir (F1-04). Harga tidak ikut: harga
/// selalu dihitung ulang dari database.
class SaleLineRequest {
  const SaleLineRequest({
    required this.variantId,
    required this.quantity,
    this.productUnitId,
    this.discount,
  });

  /// Diskon manual baris (F1-04b), dari total baris setelah harga grosir.
  final ManualDiscount? discount;

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
/// Diskon manual melebihi dasarnya, atau membuat total nota nol.
class DiscountTooLarge implements Exception {
  const DiscountTooLarge();
  @override
  String toString() => 'DiscountTooLarge';
}

/// Nilai diskon manual tidak sah (nol, negatif, atau > 100%).
class DiscountInvalid implements Exception {
  const DiscountInvalid();
  @override
  String toString() => 'DiscountInvalid';
}

/// Staf tidak boleh memberi diskon manual: tanpa `sales:discount` dan
/// tanpa penyetuju (atau persetujuan PIN dimatikan di pengaturan).
class DiscountNotPermitted implements Exception {
  const DiscountNotPermitted();
  @override
  String toString() => 'DiscountNotPermitted';
}

/// Potongan [discount] dari [base]; galat bila tidak sah.
Money _discountCut(ManualDiscount discount, Money base) {
  switch (discount.issue(base)) {
    case DiscountIssue.invalid:
      throw const DiscountInvalid();
    case DiscountIssue.tooLarge:
      throw const DiscountTooLarge();
    case null:
      return discount.cut(base);
  }
}

/// Memeriksa izin diskon manual [staffId]. Mengembalikan penyetuju yang
/// dicatat (`null` bila staf sendiri berizin).
Future<UuidValue?> requireDiscountActor(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  UuidValue? approverId,
}) async {
  final staff = await findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: staffId,
  );
  if (staff?.permissions.contains(Permission.salesDiscount) ?? false) {
    return null;
  }
  final rules = await loadSalesRules(store.session, scope);
  if (!rules.discountNeedsPin || approverId == null) {
    throw const DiscountNotPermitted();
  }
  await requireApprover(store, scope, approverId, Permission.salesDiscount);
  return approverId;
}

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

/// Harga, diskon manual, dan total nota dari [lines] (dihitung dari
/// database). Dipakai checkout dan nota tersimpan (F1-04d).
typedef PricedSale = ({
  List<PricedRequest> priced,
  SaleTotals totals,
  List<Money> lineCuts,
  Money lineDiscount,
  Money billCut,
  Money net,
  Money total,
});

Future<PricedSale> priceSaleLines(
  SyncTx w,
  CatalogScope scope,
  List<SaleLineRequest> lines,
  ManualDiscount? discount,
  SalesRules rules, {
  UuidValue? customerGroupId,
}) async {
  final priced = await priceRequests(
    w.session,
    w.transaction,
    scope,
    lines,
    customerGroupId: customerGroupId,
  );
  final totals = SaleTotals.of(priced.map((p) => p.line));
  // Diskon manual baris lalu nota (F1-04b), sebelum pembulatan.
  final lineCuts = [
    for (var i = 0; i < priced.length; i++)
      switch (lines[i].discount) {
        final d? => _discountCut(d, priced[i].line.lineTotal),
        null => Money.zero,
      },
  ];
  final lineDiscount = Money.sum(lineCuts);
  final linesNet = totals.total - lineDiscount;
  final billCut = discount == null
      ? Money.zero
      : _discountCut(discount, linesNet);
  final net = linesNet - billCut;
  final total = roundTotal(net, rules.rounding);
  final discounted = discount != null || lines.any((l) => l.discount != null);
  // Nota berdiskon harus tetap bernilai, juga setelah pembulatan.
  if (discounted && (net <= Money.zero || total <= Money.zero)) {
    throw const DiscountTooLarge();
  }
  return (
    priced: priced,
    totals: totals,
    lineCuts: lineCuts,
    lineDiscount: lineDiscount,
    billCut: billCut,
    net: net,
    total: total,
  );
}

/// Menyimpan penjualan [lines] dengan [payments] (satu atau lebih, split)
/// dalam satu transaksi: nota, item, pembayaran, pergerakan stok, dan
/// outbox. Butuh sesi kasir terbuka di perangkat ini
/// ([CashSessionNotOpen]). Harga dihitung ulang dari database. QRIS statis
/// harus aktif di cabang dan sudah dikonfirmasi; `confirmed_by` = [staffId].
///
/// Nota kredit (F1-13): [credit] diisi dan [payments] kosong. DP tunai
/// dicatat sebagai pembayaran tunai; sisanya menjadi piutang pelanggan.
/// Butuh `debts:manage` ([CustomerActorNotPermitted]) dan lolos
/// [creditIssue] ([SaleCreditInvalid]).
Future<CheckoutResult> checkoutSale(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required List<SaleLineRequest> lines,
  required List<SalePaymentRequest> payments,
  SaleCredit? credit,
  ManualDiscount? discount,
  UuidValue? discountApproverId,
  UuidValue? customerId,
  UuidValue? parkedSaleId,
}) async {
  if (lines.isEmpty) throw SaleEmpty();
  for (var i = 0; i < lines.length; i++) {
    if (!lines[i].quantity.isPositive) throw SaleQuantityInvalid(i);
  }
  if (credit != null) {
    if (payments.isNotEmpty) {
      throw const SalePaymentInvalid(TenderError.nonCashOver);
    }
    await requireCustomerActor(store, scope, staffId, Permission.debtsManage);
    payments = [
      if (credit.downPayment > Money.zero)
        SalePaymentRequest.cash(credit.downPayment),
    ];
  }
  checkPaymentRequests(payments);
  final discounted = discount != null || lines.any((l) => l.discount != null);
  final approvedBy = discounted
      ? await requireDiscountActor(
          store,
          scope,
          staffId: staffId,
          approverId: discountApproverId,
        )
      : null;
  return store.write(actor: staffId, (w) async {
    final session = await requireOpenCashSession(store, w, scope);
    final rules = await loadSalesRules(
      w.session,
      scope,
      transaction: w.transaction,
    );
    // Harga grup pelanggan nota (F1-07c): pelanggan kredit atau terpilih.
    final buyerId = credit?.customerId ?? customerId;
    final buyer = buyerId == null
        ? null
        : await saleCustomer(w, scope, buyerId);
    final pricing = await priceSaleLines(
      w,
      scope,
      lines,
      discount,
      rules,
      customerGroupId: buyer?.customerGroupId,
    );
    final priced = pricing.priced;
    final totals = pricing.totals;
    final lineCuts = pricing.lineCuts;
    final lineDiscount = pricing.lineDiscount;
    final billCut = pricing.billCut;
    final net = pricing.net;
    final total = pricing.total;

    final s = await w.stamp();
    if (parkedSaleId != null) {
      await removeParkedSale(w, scope, parkedSaleId, staffId, s);
    }
    Customer? customer;
    late final List<Money> amounts;
    late final Money change;
    if (credit != null) {
      customer = await checkSaleCredit(w, scope, credit, total, s.now);
      amounts = [for (final p in payments) p.amount!];
      change = Money.zero;
    } else {
      customer = buyer;
      (amounts, change) = await settlePayments(w, scope, total, payments);
    }

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
        lineDiscountAmount: lineDiscount.value,
        discountAmount: billCut.value,
        discountBp: discount?.bp ?? 0,
        discountApprovedBy: approvedBy,
        roundingAmount: (total - net).value,
        total: total.value,
        paidAmount: credit?.downPayment.value ?? total.value,
        changeAmount: change.value,
        itemCount: priced.length,
        soldAt: s.now,
        customerId: customer?.id,
        customerName: customer?.name,
        dueOn: credit == null
            ? null
            : DateTime.utc(
                credit.dueOn.year,
                credit.dueOn.month,
                credit.dueOn.day,
              ),
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
            lineTotal: (p.line.lineTotal - lineCuts[i]).value,
            discountAmount: lineCuts[i].value,
            discountBp: lines[i].discount?.bp ?? 0,
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
      cashSessionId: session.id,
    );

    final negative = await negativeStockAfterSale(w, location.id, {
      for (final p in priced)
        if (p.tracksStock)
          p.variant.id: '${p.product.name} ${p.variant.name}'.trim(),
    });
    if (!rules.allowNegativeStock && negative.isNotEmpty) {
      throw SaleStockShort(negative);
    }
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
    this.credit = Money.zero,
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

  /// Bagian nota kredit yang menjadi piutang saat dijual (F1-13).
  final Money credit;
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

/// Uang tunai bersih (dikurangi kembalian) dari [payments] satu nota yang
/// masuk ke laci sesi [sessionId], dengan aturan yang sama dengan
/// [sessionSalesSummary]: hanya pembayaran lunas, dan pembayaran lama tanpa
/// sesi ikut sesi notanya ([saleSessionId]). Void nota mengurangi laci
/// sebesar ini (F1-03d).
Money saleCashInSession(
  Iterable<Payment> payments,
  UuidValue sessionId, {
  UuidValue? saleSessionId,
}) {
  var cash = Money.zero;
  for (final p in payments) {
    if (p.method != PaymentMethod.cash ||
        p.status != PaymentStatus.paid ||
        p.deletedAt != null) {
      continue;
    }
    if ((p.cashSessionId ?? saleSessionId) != sessionId) continue;
    cash += Money(p.amount - p.changeAmount);
  }
  return cash;
}

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
  // Uang dihitung di sesi yang menerimanya (F1-10i), termasuk bagian split
  // bill yang belum lunas atau notanya ditutup di sesi lain. Pembayaran lama
  // tanpa sesi ikut sesi notanya.
  final received = await Payment.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(tenantId) &
        p.cashSessionId.equals(sessionId) &
        p.status.equals(PaymentStatus.paid) &
        p.deletedAt.equals(null),
    transaction: transaction,
  );
  final legacy = sales.isEmpty
      ? const <Payment>[]
      : await Payment.db.find(
          session,
          where: (p) =>
              p.tenantId.equals(tenantId) &
              p.saleId.inSet({for (final s in sales) s.id}) &
              p.cashSessionId.equals(null) &
              p.status.equals(PaymentStatus.paid) &
              p.deletedAt.equals(null),
          transaction: transaction,
        );
  final counted = {for (final s in sales) s.id};
  final others = {
    for (final p in received)
      if (!counted.contains(p.saleId)) p.saleId,
  };
  if (others.isNotEmpty) {
    // Nota batal atau bill terhapus tidak dihitung.
    counted.addAll([
      for (final s in await Sale.db.find(
        session,
        where: (s) =>
            s.tenantId.equals(tenantId) &
            s.id.inSet(others) &
            s.status.inSet({...soldStatuses, SaleStatus.open}) &
            s.deletedAt.equals(null),
        transaction: transaction,
      ))
        s.id,
    ]);
  }
  final payments = [
    for (final p in received)
      if (counted.contains(p.saleId)) p,
    ...legacy,
  ];
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
    credit: Money.sum([
      for (final s in sales)
        if (s.customerId != null && s.paidAmount < s.total)
          Money(s.total - s.paidAmount),
    ]),
  );
}
