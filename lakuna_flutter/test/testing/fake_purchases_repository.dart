import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/purchases_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import 'cashier_seed.dart';
import 'fake_catalog_repository.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Pembelian palsu di memori (F1-12), meniru aturan `lakuna_data`: validasi
/// `validatePurchase`, nomor PB/RB, HPP sebelum → sesudah (rata-rata
/// tertimbang sederhana), hutang, retur mengurangi hutang dulu, dan laci
/// butuh sesi terbuka.
class FakePurchasesRepository extends PurchasesRepository {
  FakePurchasesRepository({
    List<ProductDraft>? products,
    this.canManage = true,
    this.hasOpenSession = true,
    this.canUseDrawer = true,
    this.canEditPrices = true,
    List<String> suppliers = const ['CV Sumber Pangan'],
  }) {
    final catalog = FakeCatalogRepository(seed: products ?? cashierProducts());
    this.products = [
      for (final p in catalog.products)
        if (p.isActive && p.tracksStock) p,
    ];
    for (final name in suppliers) {
      this.suppliers.add(Supplier(tenantId: _tenant, name: name, hlc: ''));
    }
    for (final p in this.products) {
      for (final v in p.variants) {
        costs[v.id] = v.costPrice;
        sellPrices[v.id] = v.sellPrice;
        stock[v.id] = v.stock;
      }
    }
  }

  bool canManage;
  bool hasOpenSession;
  bool canUseDrawer;
  bool canEditPrices;
  final _tenant = _id();
  final _outlet = _id();
  final _device = _id();
  final _staff = _id();
  late final locations = [
    StockLocation(
      tenantId: _tenant,
      outletId: _outlet,
      name: 'Toko',
      isDefault: true,
      hlc: '',
    ),
    StockLocation(
      tenantId: _tenant,
      outletId: _outlet,
      name: 'Gudang',
      hlc: '',
    ),
  ];
  late final List<CatalogProduct> products;
  final suppliers = <Supplier>[];
  final purchases = <Purchase>[];
  final items = <PurchaseItem>[];
  final returns = <PurchaseReturn>[];
  final returnedMilli = <UuidValue, int>{};
  final costs = <UuidValue, Money>{};
  final sellPrices = <UuidValue, Money>{};
  final stock = <UuidValue, Qty>{};
  final requests = <PurchaseRequest>[];

  /// Isi foto faktur per `invoice_media_id` (F1-12b).
  final photoFiles = <UuidValue, Uint8List>{};

  /// Foto tercatat tetapi berkasnya belum ada di perangkat.
  var photoFileMissing = false;
  final applied = <Map<UuidValue, Money>>[];

  /// Galat berikutnya untuk aksi tulis (sekali pakai).
  Exception? nextError;

  final today = DateTime(2026, 11, 3);
  var _counter = 0;
  var _returnCounter = 0;

  String _number() => purchaseNumber('PST', 'D01', today, _counter + 1);

  Result<T> _guard<T>(T Function() body) {
    if (!canManage) {
      return const Result.error(NotPermitted(Permission.purchasesManage));
    }
    if (nextError case final e?) {
      nextError = null;
      return Result.error(e);
    }
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<PurchaseSetup>> load() async => _guard(
    () => PurchaseSetup(
      locations: locations,
      suppliers: [...suppliers]..sort((a, b) => a.name.compareTo(b.name)),
      products: products,
      today: today,
      nextNumber: _number(),
      timezone: 'Asia/Jakarta',
      hasOpenSession: hasOpenSession,
      canUseDrawer: canUseDrawer,
      canEditPrices: canEditPrices,
    ),
  );

  String? _supplierName(UuidValue? id) =>
      suppliers.where((s) => s.id == id).firstOrNull?.name;

  Money _debt(Purchase p) => purchaseDebt(
    total: Money(p.total),
    paid: Money(p.paidAmount),
    debtReduction: Money.sum(
      returns
          .where((r) => r.purchaseId == p.id)
          .map((r) => Money(r.debtReduction)),
    ),
  );

  @override
  Future<Result<List<PurchaseRow>>> list({String query = ''}) async =>
      _guard(() {
        final q = query.trim().toLowerCase();
        return [
          for (final p in purchases.reversed)
            if (p.deletedAt == null &&
                (q.isEmpty ||
                    p.number.toLowerCase().contains(q) ||
                    (_supplierName(p.supplierId)?.toLowerCase().contains(q) ??
                        false)))
              PurchaseRow(
                purchase: p,
                supplierName: _supplierName(p.supplierId),
                returned: Money.sum(
                  returns
                      .where((r) => r.purchaseId == p.id)
                      .map((r) => Money(r.amount)),
                ),
                debt: p.status == PurchaseStatus.draft ? Money.zero : _debt(p),
              ),
        ];
      });

  @override
  Future<Result<List<PurchaseReturnRow>>> listReturns({
    String query = '',
  }) async => _guard(() {
    final q = query.trim().toLowerCase();
    return [
      for (final r in returns.reversed)
        if (q.isEmpty || r.number.toLowerCase().contains(q))
          PurchaseReturnRow(
            purchaseReturn: r,
            purchaseNumber: purchases
                .firstWhere((p) => p.id == r.purchaseId)
                .number,
            supplierName: _supplierName(
              purchases.firstWhere((p) => p.id == r.purchaseId).supplierId,
            ),
          ),
    ];
  });

  PurchaseDetail _detail(UuidValue id) {
    final p = purchases
        .where((p) => p.id == id && p.deletedAt == null)
        .firstOrNull;
    if (p == null) throw PurchaseNotFound();
    final lines = [
      for (final i in items)
        if (i.purchaseId == id) i,
    ];
    return PurchaseDetail(
      purchase: p,
      items: lines,
      supplier: suppliers.where((s) => s.id == p.supplierId).firstOrNull,
      staffName: 'Yusuf',
      deviceCode: 'D01',
      locationName: locations.firstWhere((l) => l.id == p.stockLocationId).name,
      returns: [
        for (final r in returns)
          if (r.purchaseId == id) r,
      ],
      returnedMilli: {
        for (final i in lines) i.id: returnedMilli[i.id] ?? 0,
      },
      sellPrices: {
        for (final i in lines) i.variantId: sellPrices[i.variantId]!,
      },
      skus: {
        for (final i in lines) i.variantId: _variant(i.variantId)?.sku,
      },
      baseUnits: {
        for (final i in lines)
          i.variantId: products
              .firstWhere((p) => p.variants.any((v) => v.id == i.variantId))
              .baseUnit,
      },
    );
  }

  CatalogVariant? _variant(UuidValue id) =>
      products.expand((p) => p.variants).where((v) => v.id == id).firstOrNull;

  @override
  Future<Result<PurchaseDetail>> detail(UuidValue id) async =>
      _guard(() => _detail(id));

  @override
  Future<Result<Purchase>> saveDraft(PurchaseRequest request) async =>
      _guard(() => _write(request, receiving: false));

  @override
  Future<Result<Purchase>> receive(PurchaseRequest request) async =>
      _guard(() => _write(request, receiving: true));

  Purchase _write(PurchaseRequest r, {required bool receiving}) {
    requests.add(r);
    final inputs = [
      for (final l in r.lines)
        PurchaseLineInput(
          quantity: l.quantity,
          unitPrice: l.unitPrice,
          factorMilli: _unit(l).factor.milli,
        ),
    ];
    final issues = validatePurchase(
      lines: inputs,
      discount: r.discount,
      shipping: r.shipping,
      paid: r.paid,
      funding: r.funding == null ? null : fundingKind(r.funding!),
      hasSupplier: r.hasSupplier,
      purchasedOn: r.purchasedOn,
      dueOn: r.dueOn,
      invoiceNo: r.invoiceNo,
      note: r.note,
      receiving: receiving,
    );
    if (issues.isNotEmpty) throw PurchaseInvalid(issues);
    if (r.invoicePhoto case final photo?) _checkPhoto(photo);
    if (receiving && r.funding == FundingSource.drawer && !hasOpenSession) {
      throw CashSessionNotOpen();
    }
    final old = r.id == null
        ? null
        : purchases.where((p) => p.id == r.id).firstOrNull;
    if (old != null && old.status != PurchaseStatus.draft) {
      throw PurchaseNotEditable();
    }
    var supplierId = r.supplierId;
    if (r.newSupplierName case final name? when name.trim().isNotEmpty) {
      final found = suppliers
          .where((s) => s.name.toLowerCase() == name.trim().toLowerCase())
          .firstOrNull;
      final s =
          found ?? Supplier(tenantId: _tenant, name: name.trim(), hlc: '');
      if (found == null) suppliers.add(s);
      supplierId = s.id;
    }
    final totals = purchaseTotals(
      inputs,
      discount: r.discount,
      shipping: r.shipping,
    );
    if (old == null) _counter++;
    final p = Purchase(
      id: old?.id,
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      stockLocationId: r.locationId,
      supplierId: supplierId,
      staffId: _staff,
      number: old?.number ?? purchaseNumber('PST', 'D01', today, _counter),
      invoiceNo: r.invoiceNo,
      status: receiving ? PurchaseStatus.received : PurchaseStatus.draft,
      purchasedOn: r.purchasedOn,
      subtotal: totals.subtotal.value,
      discount: r.discount.value,
      shipping: r.shipping.value,
      total: totals.total.value,
      paidAmount: r.paid.value,
      fundingSource: r.funding,
      dueOn: r.dueOn,
      note: r.note,
      invoiceMediaId: r.invoicePhoto != null
          ? _storePhoto(r.invoicePhoto!)
          : r.removeInvoicePhoto
          ? null
          : old?.invoiceMediaId,
      receivedAt: receiving ? DateTime.utc(2026, 11, 3, 4) : null,
      hlc: '',
    );
    if (old != null) {
      purchases[purchases.indexOf(old)] = p;
      items.removeWhere((i) => i.purchaseId == p.id);
    } else {
      purchases.add(p);
    }
    for (final (i, l) in r.lines.indexed) {
      final unit = _unit(l);
      final variant = _variant(l.variantId)!;
      final product = products.firstWhere((p) => p.variants.contains(variant));
      int? before;
      int? after;
      final base = totals.baseQuantities[i];
      if (receiving) {
        final cost = costs[l.variantId]!;
        final onHand = stock[l.variantId]!;
        before = cost.value;
        final value =
            cost.timesMilli(onHand.milli.clamp(0, 1 << 40)) +
            totals.landedTotals[i];
        final qty = (onHand.milli < 0 ? 0 : onHand.milli) + base.milli;
        after = qty == 0 ? cost.value : (value.value * 1000 / qty).round();
        costs[l.variantId] = Money(after);
        stock[l.variantId] = onHand + base;
      }
      items.add(
        PurchaseItem(
          tenantId: _tenant,
          purchaseId: p.id,
          variantId: l.variantId,
          productUnitId: l.productUnitId,
          productName: product.name,
          variantName: product.variants.length == 1 ? '' : variant.name,
          unitName: unit.name,
          factorMilli: unit.factor.milli,
          quantityMilli: l.quantity.milli,
          unitPrice: l.unitPrice.value,
          lineTotal: totals.lineTotals[i].value,
          landedUnitCost: totals.landedUnitCosts[i].value,
          avgCostBefore: before,
          avgCostAfter: after,
          sellPriceBefore: receiving ? sellPrices[l.variantId]!.value : null,
          sortOrder: i,
          hlc: '',
        ),
      );
    }
    return p;
  }

  ({String name, Qty factor}) _unit(PurchaseLineRequest l) {
    final product = products.firstWhere(
      (p) => p.variants.any((v) => v.id == l.variantId),
    );
    final variant = product.variants.firstWhere((v) => v.id == l.variantId);
    if (l.productUnitId == null) {
      return (name: product.baseUnit, factor: Qty.units(1));
    }
    final u = variant.units.firstWhere((u) => u.id == l.productUnitId);
    return (name: u.name, factor: u.factor);
  }

  @override
  Future<Result<void>> deleteDraft(UuidValue id) async => _guard(() {
    final p = purchases.firstWhere((p) => p.id == id);
    if (p.status != PurchaseStatus.draft) throw PurchaseNotEditable();
    purchases[purchases.indexOf(p)] = p.copyWith(
      deletedAt: DateTime.utc(2026, 11, 3),
    );
  });

  @override
  Future<Result<PurchaseReturn>> returnPurchase({
    required UuidValue purchaseId,
    required List<PurchaseReturnLine> lines,
    String? note,
    FundingSource? refundSource,
  }) async => _guard(() {
    final d = _detail(purchaseId);
    if (lines.every((l) => l.quantity.milli <= 0)) {
      throw const PurchaseReturnInvalid(PurchaseReturnError.empty);
    }
    var amount = Money.zero;
    for (final (i, l) in lines.indexed) {
      final item = d.items.firstWhere((x) => x.id == l.purchaseItemId);
      if (l.quantity.milli > d.remainingMilli(item)) {
        throw PurchaseReturnInvalid(PurchaseReturnError.quantity, index: i);
      }
      amount += returnAmount(
        share: d.landedTotal(item),
        soldMilli: item.quantityMilli,
        returnedMilli: d.returnedMilli[item.id] ?? 0,
        returningMilli: l.quantity.milli,
      );
    }
    final split = purchaseReturnSplit(amount: amount, debt: d.debt);
    if (split.refund.value > 0 && refundSource == null) {
      throw const PurchaseReturnInvalid(PurchaseReturnError.refundSource);
    }
    if (refundSource == FundingSource.drawer && !hasOpenSession) {
      throw CashSessionNotOpen();
    }
    for (final l in lines) {
      returnedMilli[l.purchaseItemId] =
          (returnedMilli[l.purchaseItemId] ?? 0) + l.quantity.milli;
    }
    _returnCounter++;
    final r = PurchaseReturn(
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      purchaseId: purchaseId,
      staffId: _staff,
      number: purchaseReturnNumber('PST', 'D01', today, _returnCounter),
      amount: amount.value,
      debtReduction: split.debtReduction.value,
      refundAmount: split.refund.value,
      refundSource: split.refund.value > 0 ? refundSource : null,
      note: note,
      returnedAt: DateTime.utc(2026, 11, 3, 5),
      hlc: '',
    );
    returns.add(r);
    return r;
  });

  @override
  Future<Result<void>> applySellPrices(Map<UuidValue, Money> prices) async =>
      _guard(() {
        applied.add(prices);
        sellPrices.addAll(prices);
      });

  void _checkPhoto(PurchaseInvoicePhoto photo) {
    if (readImageHeader(photo.bytes) == null ||
        photo.bytes.length > PurchaseLimits.invoicePhotoMaxBytes) {
      throw const PurchaseInvoicePhotoInvalid();
    }
  }

  UuidValue _storePhoto(PurchaseInvoicePhoto photo) {
    final id = _id();
    photoFiles[id] = photo.bytes;
    return id;
  }

  Purchase _setPhoto(UuidValue id, UuidValue? mediaId) {
    final p = purchases.where((p) => p.id == id).firstOrNull;
    if (p == null) throw PurchaseNotFound();
    final updated = p.copyWith(
      invoiceMediaId: mediaId,
      version: p.version + 1,
    );
    purchases[purchases.indexOf(p)] = updated;
    return updated;
  }

  @override
  Future<Result<Uint8List?>> invoicePhoto(UuidValue id) async => _guard(() {
    final media = purchases
        .where((p) => p.id == id)
        .firstOrNull
        ?.invoiceMediaId;
    return media == null || photoFileMissing ? null : photoFiles[media];
  });

  @override
  Future<Result<Purchase>> setInvoicePhoto(
    UuidValue id,
    PurchaseInvoicePhoto photo,
  ) async => _guard(() {
    _checkPhoto(photo);
    return _setPhoto(id, _storePhoto(photo));
  });

  @override
  Future<Result<Purchase>> clearInvoicePhoto(UuidValue id) async =>
      _guard(() => _setPhoto(id, null));
}
