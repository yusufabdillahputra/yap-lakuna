import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cashier_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import 'fake_catalog_repository.dart';
import 'fake_dining_repository.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Kasir di memori: produk dari [FakeCatalogRepository], harga dihitung
/// dengan aturan `lakuna_domain` yang sama dengan `checkoutSale`.
class FakeCashierRepository extends CashierRepository {
  FakeCashierRepository({
    List<ProductDraft> seed = const [],
    this.sessionOpen = true,
    this.permissions,
    this.qris,
    this.receipt = const ReceiptConfig(settings: ReceiptSettings()),
    this.printer,
    this.dining,
  }) : catalog = FakeCatalogRepository(seed: seed);

  /// Sumber open bill untuk mode bill (F1-10).
  FakeDiningRepository? dining;
  final paidBills = <(UuidValue, List<SalePaymentRequest>)>[];

  final FakeCatalogRepository catalog;
  bool sessionOpen;

  /// Izin staf; `null` = semua izin.
  Set<Permission>? permissions;

  /// QRIS statis aktif; `null` = nonaktif.
  CashierQris? qris;

  ReceiptConfig receipt;
  PrinterSelection? printer;

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;
  final checkouts = <(List<SaleLineRequest>, List<SalePaymentRequest>)>[];
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
        categories: cashierCategories(catalog.categories, used),
        categoryParents: {
          for (final c in catalog.categories)
            if (c.parentId != null) c.id: c.parentId!,
        },
        businessName: 'Warung Contoh',
        outletName: 'Cabang Pusat',
        staffName: 'Sari',
        timezone: 'Asia/Jakarta',
        qris: qris,
        receipt: receipt,
        printer: printer,
        canConfirmPayments:
            permissions?.contains(Permission.paymentsConfirm) ?? true,
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
    required List<SalePaymentRequest> payments,
  }) async {
    if (_check() case final e?) return Result.error(e);
    if (!sessionOpen) return Result.error(CashSessionNotOpen());
    final qrisUsed = payments.any((p) => p.method == PaymentMethod.qrisStatic);
    final p = permissions;
    if (qrisUsed && p != null && !p.contains(Permission.paymentsConfirm)) {
      return const Result.error(NotPermitted(Permission.paymentsConfirm));
    }
    if (qrisUsed && qris == null) {
      return const Result.error(
        SalePaymentUnsupported(PaymentMethod.qrisStatic),
      );
    }
    if (payments.any(
      (p) => p.method == PaymentMethod.qrisStatic && !p.confirmed,
    )) {
      return Result.error(SalePaymentUnconfirmed());
    }
    checkouts.add((lines, payments));
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
    final single = payments.length == 1;
    final amounts = [
      for (final p in payments)
        p.amount ?? (single && !p.isCash ? totals.total : Money.zero),
    ];
    final settlement = settleTender(totals.total, [
      for (final (i, p) in payments.indexed)
        TenderPart(amounts[i], isCash: p.isCash),
    ]);
    if (settlement.error == TenderError.short ||
        (single && payments.single.isCash && !settlement.isSettled)) {
      return Result.error(
        SalePaymentShort(total: totals.total, received: settlement.paid),
      );
    }
    if (settlement.error case final error?) {
      return Result.error(SalePaymentInvalid(error));
    }
    final change = settlement.change;
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
        payments: [
          for (final (i, payment) in payments.indexed)
            Payment(
              tenantId: _tenant,
              saleId: sale.id,
              method: payment.method,
              amount: amounts[i].value,
              changeAmount: payment.isCash ? change.value : 0,
              reference: payment.reference.trim().isEmpty
                  ? null
                  : payment.reference.trim(),
              status: PaymentStatus.paid,
              confirmedBy: payment.method == PaymentMethod.qrisStatic
                  ? _session
                  : null,
              confirmedAt: payment.method == PaymentMethod.qrisStatic
                  ? now
                  : null,
              paidAt: now,
              hlc: '',
            ),
        ],
        negativeStock: negative,
      ),
    );
  }

  @override
  Future<Result<OpenBill>> loadBill(UuidValue billId) async {
    if (_check() case final e?) return Result.error(e);
    final d = dining;
    if (d == null) return Result.error(BillNotFound());
    try {
      return Result.ok(d.bill(billId));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<CheckoutResult>> payBill(
    UuidValue billId,
    List<SalePaymentRequest> payments,
  ) async {
    if (_check() case final e?) return Result.error(e);
    if (!sessionOpen) return Result.error(CashSessionNotOpen());
    final d = dining;
    if (d == null) return Result.error(BillNotFound());
    final OpenBill bill;
    try {
      bill = d.bill(billId);
    } on Exception catch (e) {
      return Result.error(e);
    }
    if (bill.items.isEmpty) return Result.error(SaleEmpty());
    final total = bill.charges.total;
    final single = payments.length == 1;
    final amounts = [
      for (final p in payments)
        p.amount ?? (single && !p.isCash ? total : Money.zero),
    ];
    final settlement = settleTender(total, [
      for (final (i, p) in payments.indexed)
        TenderPart(amounts[i], isCash: p.isCash),
    ]);
    if (settlement.error == TenderError.short ||
        (single && payments.single.isCash && !settlement.isSettled)) {
      return Result.error(
        SalePaymentShort(total: total, received: settlement.paid),
      );
    }
    paidBills.add((billId, payments));
    d.markPaid(billId);
    _counter++;
    final now = DateTime.utc(2026, 11, 3, 6, 0);
    final sale = bill.sale.copyWith(
      number: 'PST-K01-261103-${_counter.toString().padLeft(4, '0')}',
      billNumber: bill.sale.number,
      status: SaleStatus.completed,
      cashSessionId: _session,
      subtotal: bill.charges.subtotal.value,
      serviceBp: bill.rates.service.value,
      taxBp: bill.rates.tax.value,
      serviceAmount: bill.charges.service.value,
      taxAmount: bill.charges.tax.value,
      total: total.value,
      paidAmount: total.value,
      changeAmount: settlement.change.value,
      soldAt: now,
    );
    return Result.ok(
      CheckoutResult(
        sale: sale,
        items: bill.items,
        payments: [
          for (final (i, payment) in payments.indexed)
            Payment(
              tenantId: _tenant,
              saleId: sale.id,
              method: payment.method,
              amount: amounts[i].value,
              changeAmount: payment.isCash ? settlement.change.value : 0,
              status: PaymentStatus.paid,
              paidAt: now,
              hlc: '',
            ),
        ],
        negativeStock: const [],
      ),
    );
  }
}
