import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'cash.dart';
import 'payment_settings.dart';
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
  });

  final Sale sale;

  /// Urut sesuai keranjang.
  final List<SaleItem> items;

  /// Urut sesuai permintaan.
  final List<Payment> payments;
  final List<NegativeStock> negativeStock;
}

const _supportedMethods = {
  PaymentMethod.cash,
  PaymentMethod.card,
  PaymentMethod.transfer,
  PaymentMethod.qrisStatic,
};

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
  for (final payment in payments) {
    if (!_supportedMethods.contains(payment.method)) {
      throw SalePaymentUnsupported(payment.method);
    }
    if (validatePaymentReference(payment.reference) != null) {
      throw SaleReferenceInvalid();
    }
  }
  return store.write(actor: staffId, (w) async {
    final session = await findOpenCashSession(
      store,
      CashScope(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        deviceId: scope.deviceId,
      ),
      transaction: w.transaction,
    );
    if (session == null) throw CashSessionNotOpen();
    final priced = await _priceLines(w.session, w.transaction, scope, lines);
    final totals = SaleTotals.of(priced.map((p) => p.line));
    final total = totals.total;

    if (payments.any((p) => p.method == PaymentMethod.qrisStatic)) {
      final qris = await readQrisSettings(
        w.session,
        scope,
        transaction: w.transaction,
      );
      if (!qris.enabled || qris.mediaId == null) {
        throw const SalePaymentUnsupported(PaymentMethod.qrisStatic);
      }
      if (payments.any(
        (p) => p.method == PaymentMethod.qrisStatic && !p.confirmed,
      )) {
        throw SalePaymentUnconfirmed();
      }
    }
    final single = payments.length == 1;
    final amounts = [
      for (final p in payments)
        p.amount ?? (single && !p.isCash ? total : Money.zero),
    ];
    final settlement = settleTender(total, [
      for (var i = 0; i < payments.length; i++)
        TenderPart(amounts[i], isCash: payments[i].isCash),
    ]);
    switch (settlement.error) {
      case null:
        break;
      case TenderError.short:
        throw SalePaymentShort(total: total, received: settlement.paid);
      case final error:
        // Tunai tunggal nol = kurang bayar, bukan galat pembagian.
        if (single && payments.single.isCash) {
          throw SalePaymentShort(total: total, received: settlement.paid);
        }
        throw SalePaymentInvalid(error);
    }
    final change = settlement.change;

    final s = await w.stamp();
    final number = await _nextNumber(w, scope, s.now);
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
      final unitCost = await _averageCost(w, location.id, p);
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

    final paid = <Payment>[];
    for (var i = 0; i < payments.length; i++) {
      final payment = payments[i];
      final reference = payment.reference.trim();
      final confirms = payment.method == PaymentMethod.qrisStatic;
      paid.add(
        await w.insert(
          Payment(
            tenantId: scope.tenantId,
            saleId: sale.id,
            method: payment.method,
            amount: amounts[i].value,
            changeAmount: payment.isCash ? change.value : 0,
            reference: reference.isEmpty ? null : reference,
            status: PaymentStatus.paid,
            confirmedBy: confirms ? staffId : null,
            confirmedAt: confirms ? s.now : null,
            paidAt: s.now,
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
    }

    final negative = <NegativeStock>[];
    final seen = <UuidValue>{};
    for (final p in priced) {
      if (!p.tracksStock || !seen.add(p.variant.id)) continue;
      final level = await StockLevel.db.findFirstRow(
        w.session,
        where: (l) =>
            l.stockLocationId.equals(location.id) &
            l.variantId.equals(p.variant.id),
        transaction: w.transaction,
      );
      final onHand = Qty(level?.quantityMilli ?? 0);
      if (onHand.milli < 0) {
        negative.add(
          NegativeStock(
            variantId: p.variant.id,
            name: '${p.product.name} ${p.variant.name}'.trim(),
            onHand: onHand,
          ),
        );
      }
    }
    return CheckoutResult(
      sale: sale,
      items: items,
      payments: paid,
      negativeStock: negative,
    );
  });
}

class _PricedRequest {
  const _PricedRequest({
    required this.product,
    required this.variant,
    required this.unitName,
    required this.line,
    this.unit,
  });

  final Product product;
  final ProductVariant variant;
  final ProductUnit? unit;
  final String unitName;
  final PricedLine line;

  bool get tracksStock =>
      ProductKind.values.byName(product.type.name).tracksStock;
}

Future<List<_PricedRequest>> _priceLines(
  DatabaseSession session,
  Transaction transaction,
  CatalogScope scope,
  List<SaleLineRequest> lines,
) async {
  final variantIds = {for (final l in lines) l.variantId};
  final variants = {
    for (final v in await ProductVariant.db.find(
      session,
      where: (v) =>
          v.tenantId.equals(scope.tenantId) &
          v.id.inSet(variantIds) &
          v.deletedAt.equals(null),
      transaction: transaction,
    ))
      v.id: v,
  };
  final productIds = {for (final v in variants.values) v.productId};
  final products = productIds.isEmpty
      ? <UuidValue, Product>{}
      : {
          for (final p in await Product.db.find(
            session,
            where: (p) =>
                p.tenantId.equals(scope.tenantId) &
                p.id.inSet(productIds) &
                p.isActive.equals(true) &
                p.deletedAt.equals(null),
            transaction: transaction,
          ))
            p.id: p,
        };
  final unitIds = {
    for (final l in lines)
      if (l.productUnitId != null) l.productUnitId!,
  };
  final units = unitIds.isEmpty
      ? <UuidValue, ProductUnit>{}
      : {
          for (final u in await ProductUnit.db.find(
            session,
            where: (u) =>
                u.tenantId.equals(scope.tenantId) &
                u.id.inSet(unitIds) &
                u.deletedAt.equals(null),
            transaction: transaction,
          ))
            u.id: u,
        };
  final tiers = variantIds.isEmpty
      ? <ProductPriceTier>[]
      : await ProductPriceTier.db.find(
          session,
          where: (t) =>
              t.tenantId.equals(scope.tenantId) &
              t.variantId.inSet(variantIds) &
              t.deletedAt.equals(null),
          transaction: transaction,
        );
  final measureIds = {
    for (final p in products.values) p.baseUnitId,
    for (final u in units.values) u.unitId,
  };
  final measureNames = measureIds.isEmpty
      ? <UuidValue, String>{}
      : {
          for (final m in await MeasureUnit.db.find(
            session,
            where: (m) =>
                m.id.inSet(measureIds) & m.tenantId.equals(scope.tenantId),
            transaction: transaction,
          ))
            m.id: m.name,
        };

  return [
    for (final l in lines)
      _price(l, variants, products, units, tiers, measureNames),
  ];
}

_PricedRequest _price(
  SaleLineRequest l,
  Map<UuidValue, ProductVariant> variants,
  Map<UuidValue, Product> products,
  Map<UuidValue, ProductUnit> units,
  List<ProductPriceTier> tiers,
  Map<UuidValue, String> measureNames,
) {
  final variant = variants[l.variantId];
  final product = variant == null ? null : products[variant.productId];
  if (variant == null || product == null) {
    throw SaleItemUnavailable(l.variantId);
  }
  final unitId = l.productUnitId;
  final unit = unitId == null ? null : units[unitId];
  if (unitId != null && (unit == null || unit.variantId != variant.id)) {
    throw SaleItemUnavailable(l.variantId);
  }
  final line = priceSaleLine(
    sellPrice: Money(variant.sellPrice),
    quantity: l.quantity,
    tiers: [
      for (final t in tiers)
        if (t.variantId == variant.id)
          PriceTier(minQty: Qty(t.minQtyMilli), price: Money(t.price)),
    ],
    factor: unit == null ? null : Qty(unit.factorMilli),
    unitPrice: unit?.sellPrice == null ? null : Money(unit!.sellPrice!),
  );
  return _PricedRequest(
    product: product,
    variant: variant,
    unit: unit,
    unitName: measureNames[unit?.unitId ?? product.baseUnitId] ?? '',
    line: line,
  );
}

/// Biaya rata-rata per satuan dasar di cache stok; harga beli varian bila
/// belum ada stok.
Future<Money> _averageCost(
  SyncTx w,
  UuidValue locationId,
  _PricedRequest p,
) async {
  final level = await StockLevel.db.findFirstRow(
    w.session,
    where: (l) =>
        l.stockLocationId.equals(locationId) & l.variantId.equals(p.variant.id),
    transaction: w.transaction,
  );
  return level == null || level.avgCost == 0
      ? Money(p.variant.costPrice)
      : Money(level.avgCost);
}

Future<String> _nextNumber(SyncTx w, CatalogScope scope, DateTime now) async {
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
  });

  /// Jumlah nota lunas.
  final int count;
  final Money total;

  /// Tunai bersih (diterima − kembalian), masuk laci.
  final Money cash;

  /// Kartu, transfer, QRIS: tidak masuk laci.
  final Money nonCash;
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
        s.status.equals(SaleStatus.completed) &
        s.deletedAt.equals(null),
    transaction: transaction,
  );
  if (sales.isEmpty) return const SessionSalesSummary();
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
  );
}
