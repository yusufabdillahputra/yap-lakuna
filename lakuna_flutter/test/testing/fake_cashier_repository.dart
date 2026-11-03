import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cashier_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import 'fake_catalog_repository.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Kasir di memori: produk dari [FakeCatalogRepository], harga dihitung
/// dengan aturan `lakuna_domain` yang sama dengan `checkoutSale`.
class FakeCashierRepository extends CashierRepository {
  FakeCashierRepository({
    List<ProductDraft> seed = const [],
    this.sessionOpen = true,
    this.permissions,
  }) : catalog = FakeCatalogRepository(seed: seed);

  final FakeCatalogRepository catalog;
  bool sessionOpen;

  /// Izin staf; `null` = semua izin.
  Set<Permission>? permissions;

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;
  final checkouts = <(List<SaleLineRequest>, SalePaymentRequest)>[];
  var loadCalls = 0;
  var _counter = 0;
  final _tenant = _id();
  final _session = _id();

  Exception? _check() {
    final e = nextError;
    nextError = null;
    if (e != null) return e;
    final p = permissions;
    if (p != null && !p.contains(Permission.salesCreate)) {
      return const NotPermitted(Permission.salesCreate);
    }
    return null;
  }

  @override
  Future<Result<CashierData>> load() async {
    loadCalls++;
    if (_check() case final e?) return Result.error(e);
    final products =
        [
          for (final p in catalog.products)
            if (p.isActive && p.variants.isNotEmpty) p,
        ]..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    final used = {for (final p in products) p.categoryId};
    return Result.ok(
      CashierData(
        products: products,
        categories: [
          for (final c in catalog.categories)
            if (used.contains(c.id)) c,
        ],
        businessName: 'Warung Contoh',
        outletName: 'Cabang Pusat',
        staffName: 'Sari',
        timezone: 'Asia/Jakarta',
        session: sessionOpen
            ? CashierSession(
                id: _session,
                openedAt: DateTime.utc(2026, 11, 3, 0, 58),
                openedByName: 'Sari',
              )
            : null,
      ),
    );
  }

  @override
  Future<Result<CheckoutResult>> checkout({
    required List<SaleLineRequest> lines,
    required SalePaymentRequest payment,
  }) async {
    if (_check() case final e?) return Result.error(e);
    if (!sessionOpen) return Result.error(CashSessionNotOpen());
    checkouts.add((lines, payment));
    final priced =
        <(CatalogProduct, CatalogVariant, CatalogUnit?, PricedLine)>[];
    for (final l in lines) {
      final product = catalog.products
          .where((p) => p.variants.any((v) => v.id == l.variantId))
          .firstOrNull;
      if (product == null || !product.isActive) {
        return Result.error(SaleItemUnavailable(l.variantId));
      }
      final variant = product.variants.firstWhere((v) => v.id == l.variantId);
      final unit = l.productUnitId == null
          ? null
          : variant.units.firstWhere((u) => u.id == l.productUnitId);
      priced.add((
        product,
        variant,
        unit,
        priceSaleLine(
          sellPrice: variant.sellPrice,
          quantity: l.quantity,
          tiers: variant.tiers,
          factor: unit?.factor,
          unitPrice: unit?.sellPrice,
        ),
      ));
    }
    final totals = SaleTotals.of(priced.map((p) => p.$4));
    final cash = payment.method == PaymentMethod.cash;
    final received = cash ? payment.received ?? Money.zero : totals.total;
    final change = cashChange(total: totals.total, received: received);
    if (change == null) {
      return Result.error(
        SalePaymentShort(total: totals.total, received: received),
      );
    }
    final now = DateTime.utc(2026, 11, 3, 3, 44);
    _counter++;
    final sale = Sale(
      tenantId: _tenant,
      outletId: _id(),
      deviceId: _id(),
      cashSessionId: _session,
      staffId: _id(),
      number: 'PST-K01-261103-${_counter.toString().padLeft(4, '0')}',
      status: SaleStatus.completed,
      subtotal: totals.subtotal.value,
      tierDiscount: totals.tierDiscount.value,
      total: totals.total.value,
      paidAmount: totals.total.value,
      changeAmount: change.value,
      itemCount: priced.length,
      soldAt: now,
      hlc: '',
    );
    final negative = <NegativeStock>[];
    for (final (product, variant, _, line) in priced) {
      if (!product.tracksStock) continue;
      final after = variant.stock - line.baseQuantity;
      if (after.milli < 0) {
        negative.add(
          NegativeStock(
            variantId: variant.id,
            name: '${product.name} ${variant.name}'.trim(),
            onHand: after,
          ),
        );
      }
    }
    return Result.ok(
      CheckoutResult(
        sale: sale,
        items: [
          for (final (i, (product, variant, unit, line)) in priced.indexed)
            SaleItem(
              tenantId: _tenant,
              saleId: sale.id,
              variantId: variant.id,
              productUnitId: unit?.id,
              productName: product.name,
              variantName: variant.name,
              unitName: unit?.name ?? product.baseUnit,
              factorMilli: line.factor.milli,
              quantityMilli: line.quantity.milli,
              listPrice: line.listPrice.value,
              unitPrice: line.unitPrice.value,
              lineTotal: line.lineTotal.value,
              unitCost: variant.costPrice.value,
              tracksStock: product.tracksStock,
              sortOrder: i,
              hlc: '',
            ),
        ],
        payment: Payment(
          tenantId: _tenant,
          saleId: sale.id,
          method: payment.method,
          amount: received.value,
          changeAmount: change.value,
          reference: payment.reference.trim().isEmpty
              ? null
              : payment.reference.trim(),
          status: PaymentStatus.paid,
          paidAt: now,
          hlc: '',
        ),
        negativeStock: negative,
      ),
    );
  }
}
