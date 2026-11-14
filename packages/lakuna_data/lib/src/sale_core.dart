import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'cash.dart';
import 'payment_settings.dart';
import 'sales.dart';
import 'store.dart';
import 'stock.dart';
import 'sync_tx.dart';

/// Harga baris jual dari database, dipakai kasir (F1-04) dan open bill
/// (F1-10). Tidak diekspor dari paket.

class PricedRequest {
  const PricedRequest({
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

Future<List<PricedRequest>> priceRequests(
  DatabaseSession session,
  Transaction transaction,
  CatalogScope scope,
  List<SaleLineRequest> lines, {
  UuidValue? customerGroupId,
}) async {
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
      _price(
        l,
        variants,
        products,
        units,
        tiers,
        measureNames,
        customerGroupId?.uuid,
      ),
  ];
}

PricedRequest _price(
  SaleLineRequest l,
  Map<UuidValue, ProductVariant> variants,
  Map<UuidValue, Product> products,
  Map<UuidValue, ProductUnit> units,
  List<ProductPriceTier> tiers,
  Map<UuidValue, String> measureNames,
  String? customerGroupId,
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
          PriceTier(
            minQty: Qty(t.minQtyMilli),
            price: Money(t.price),
            groupId: t.customerGroupId?.uuid,
          ),
    ],
    customerGroupId: customerGroupId,
    factor: unit == null ? null : Qty(unit.factorMilli),
    unitPrice: unit?.sellPrice == null ? null : Money(unit!.sellPrice!),
  );
  return PricedRequest(
    product: product,
    variant: variant,
    unit: unit,
    unitName: measureNames[unit?.unitId ?? product.baseUnitId] ?? '',
    line: line,
  );
}

/// Biaya rata-rata per satuan dasar [variantId] di cache stok
/// [locationId]; [fallback] (harga beli varian) bila belum ada stok.
Future<Money> averageCost(
  SyncTx w,
  UuidValue locationId,
  UuidValue variantId,
  Money fallback,
) async {
  final level = await StockLevel.db.findFirstRow(
    w.session,
    where: (l) =>
        l.stockLocationId.equals(locationId) & l.variantId.equals(variantId),
    transaction: w.transaction,
  );
  return level == null || level.avgCost == 0 ? fallback : Money(level.avgCost);
}

// --- Pembayaran bersama kasir dan open bill ---------------------------------

const _supportedMethods = {
  PaymentMethod.cash,
  PaymentMethod.card,
  PaymentMethod.transfer,
  PaymentMethod.qrisStatic,
};

/// Pemeriksaan sebelum transaksi: metode didukung dan referensi sah.
void checkPaymentRequests(List<SalePaymentRequest> payments) {
  for (final payment in payments) {
    if (!_supportedMethods.contains(payment.method)) {
      throw SalePaymentUnsupported(payment.method);
    }
    if (validatePaymentReference(payment.reference) != null) {
      throw SaleReferenceInvalid();
    }
  }
}

/// Sesi kasir terbuka di perangkat ini, atau [CashSessionNotOpen].
Future<CashSession> requireOpenCashSession(
  LakunaStore store,
  SyncTx w,
  CatalogScope scope,
) async {
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
  return session;
}

/// Nominal tiap pembayaran dan kembalian untuk [total]. QRIS statis harus
/// aktif dan dikonfirmasi. Gagal dengan [SalePaymentShort],
/// [SalePaymentInvalid], [SalePaymentUnsupported], [SalePaymentUnconfirmed].
Future<(List<Money>, Money)> settlePayments(
  SyncTx w,
  CatalogScope scope,
  Money total,
  List<SalePaymentRequest> payments,
) async {
  if (payments.any((p) => p.method == PaymentMethod.qrisStatic)) {
    final ready = await qrisStaticReady(
      w.session,
      scope,
      transaction: w.transaction,
    );
    if (!ready) {
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
  return (amounts, settlement.change);
}

/// Menyimpan baris `payments` nota [saleId], urut permintaan, di sesi kasir
/// [cashSessionId] yang menerima uangnya (F1-10i).
Future<List<Payment>> insertPayments(
  SyncTx w,
  CatalogScope scope, {
  required UuidValue saleId,
  required UuidValue staffId,
  required List<SalePaymentRequest> payments,
  required List<Money> amounts,
  required Money change,
  required SyncStamp stamp,
  required UuidValue cashSessionId,
  String? guestLabel,
}) async {
  final s = stamp;
  final paid = <Payment>[];
  for (var i = 0; i < payments.length; i++) {
    final payment = payments[i];
    final reference = payment.reference.trim();
    final confirms = payment.method == PaymentMethod.qrisStatic;
    paid.add(
      await w.insert(
        Payment(
          tenantId: scope.tenantId,
          saleId: saleId,
          method: payment.method,
          amount: amounts[i].value,
          changeAmount: payment.isCash ? change.value : 0,
          reference: reference.isEmpty ? null : reference,
          status: PaymentStatus.paid,
          guestLabel: guestLabel,
          cashSessionId: cashSessionId,
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
  return paid;
}

/// Varian di [names] (id → nama) yang stoknya minus di [locationId].
Future<List<NegativeStock>> negativeStockAfterSale(
  SyncTx w,
  UuidValue locationId,
  Map<UuidValue, String> names,
) async {
  final negative = <NegativeStock>[];
  for (final MapEntry(key: variantId, value: name) in names.entries) {
    final level = await StockLevel.db.findFirstRow(
      w.session,
      where: (l) =>
          l.stockLocationId.equals(locationId) & l.variantId.equals(variantId),
      transaction: w.transaction,
    );
    final onHand = Qty(level?.quantityMilli ?? 0);
    if (onHand.milli < 0) {
      negative.add(
        NegativeStock(variantId: variantId, name: name, onHand: onHand),
      );
    }
  }
  return negative;
}
