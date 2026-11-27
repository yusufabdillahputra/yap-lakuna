import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'purchases_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [PurchasesRepository] di atas database perangkat.
class LocalPurchasesRepository extends PurchasesRepository {
  LocalPurchasesRepository(
    this._store, {
    required this._stores,
    required this._session,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final DateTime Function() _clock;

  @override
  Future<Result<PurchaseSetup>> load() => _guard((ctx, scope, staff) async {
    final now = _clock().toUtc();
    final timezone = ctx.outlet.timezone ?? ctx.tenant.timezone;
    final local = outletLocalTime(now, timezone);
    final products = await listProducts(_store, scope);
    final drawerCash = await openDrawerCash(_store, CashScope.of(ctx));
    return PurchaseSetup(
      locations: await stockLocations(_store, scope),
      suppliers: await listSuppliers(_store, scope),
      products: [
        for (final p in products)
          if (p.isActive && p.tracksStock) p,
      ],
      today: DateTime(local.year, local.month, local.day),
      nextNumber: await previewPurchaseNumber(_store, scope, now: now),
      timezone: timezone,
      hasOpenSession: drawerCash != null,
      drawerCash: drawerCash,
      canUseDrawer: staff.can(Permission.cashMovementsCreate),
      canEditPrices: staff.can(Permission.productsManage),
      staffName: staff.name,
    );
  });

  @override
  Future<Result<List<PurchaseRow>>> list({String query = ''}) =>
      _guard((_, scope, _) => listPurchases(_store, scope, query: query));

  @override
  Future<Result<List<PurchaseReturnRow>>> listReturns({String query = ''}) =>
      _guard((_, scope, _) => listPurchaseReturns(_store, scope, query: query));

  @override
  Future<Result<PurchaseDetail>> detail(UuidValue id) =>
      _guard((_, scope, _) => loadPurchaseDetail(_store, scope, id));

  @override
  Future<Result<Purchase>> saveDraft(PurchaseRequest request) => _guard(
    (_, scope, staff) => savePurchaseDraft(
      _store,
      scope,
      staffId: staff.id,
      request: request,
    ),
  );

  @override
  Future<Result<Purchase>> receive(PurchaseRequest request) => _guard(
    (_, scope, staff) => receivePurchase(
      _store,
      scope,
      staffId: staff.id,
      request: request,
    ),
  );

  @override
  Future<Result<void>> deleteDraft(UuidValue id) => _guard(
    (_, scope, staff) => deletePurchaseDraft(
      _store,
      scope,
      staffId: staff.id,
      purchaseId: id,
    ),
  );

  @override
  Future<Result<PurchaseReturn>> returnPurchase({
    required UuidValue purchaseId,
    required List<PurchaseReturnLine> lines,
    String? note,
    FundingSource? refundSource,
  }) => _guard(
    (_, scope, staff) => data.returnPurchase(
      _store,
      scope,
      staffId: staff.id,
      purchaseId: purchaseId,
      lines: lines,
      note: note,
      refundSource: refundSource,
    ),
  );

  @override
  Future<Result<void>> applySellPrices(Map<UuidValue, Money> prices) => _guard(
    permission: Permission.productsManage,
    (_, scope, staff) => data.applySellPrices(
      _store,
      scope,
      staffId: staff.id,
      prices: prices,
    ),
  );

  @override
  Future<Result<Map<UuidValue, ({UuidValue supplierId, DateTime at})>>>
  lastSuppliers(Iterable<UuidValue> variantIds) =>
      _guard((_, scope, _) => lastSuppliersOf(_store, scope, variantIds));

  @override
  Future<Result<Map<UuidValue, LastPurchasePrice>>> lastPurchasePrices(
    Iterable<UuidValue> variantIds, {
    UuidValue? supplierId,
  }) => _guard((_, scope, _) async {
    // Satu bacaan riwayat untuk kedua harga (F1-12h).
    final (
      :perBase,
      :perUnit,
      :baseFrom,
      :unitFrom,
    ) = await lastPurchasePriceSetOf(
      _store,
      scope,
      variantIds,
      supplierId: supplierId,
    );
    PurchasePriceSource source(LastPriceSource s) => PurchasePriceSource(
      purchasedOn: s.purchasedOn,
      supplierName: s.supplierName,
    );
    return {
      for (final id in {...perBase.keys, ...perUnit.keys})
        id: LastPurchasePrice(
          perBase: perBase[id],
          perUnit: Map.unmodifiable(perUnit[id] ?? const {}),
          perBaseFrom: switch (baseFrom[id]) {
            final s? => source(s),
            null => null,
          },
          perUnitFrom: Map.unmodifiable({
            for (final MapEntry(:key, :value)
                in (unitFrom[id] ?? const {}).entries)
              key: source(value),
          }),
        ),
    };
  });

  @override
  Future<Result<List<RestockDraft>>> restockDrafts(
    UuidValue locationId,
    Iterable<UuidValue> variantIds,
  ) => _guard(
    (_, scope, _) => restockDraftsOf(_store, scope, locationId, variantIds),
  );

  @override
  Future<Result<List<PurchaseInvoicePhotoFile>>> invoicePhotos(UuidValue id) =>
      _guard((_, scope, _) => loadPurchaseInvoicePhotos(_store, scope, id));

  @override
  Future<Result<Purchase>> addInvoicePhoto(
    UuidValue id,
    PurchaseInvoicePhoto photo,
  ) => _guard(
    (_, scope, staff) => addPurchaseInvoicePhoto(
      _store,
      scope,
      staffId: staff.id,
      purchaseId: id,
      photo: photo,
    ),
  );

  @override
  Future<Result<Purchase>> removeInvoicePhoto(
    UuidValue id,
    UuidValue mediaId,
  ) => _guard(
    (_, scope, staff) => removePurchaseInvoicePhoto(
      _store,
      scope,
      staffId: staff.id,
      purchaseId: id,
      mediaId: mediaId,
    ),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, CatalogScope scope, StaffProfile staff)
    body, {
    Permission? permission,
  }) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.purchasesManage)) {
      return const Result.error(NotPermitted(Permission.purchasesManage));
    }
    if (permission != null && !staff.can(permission)) {
      return Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(ctx, CatalogScope.of(ctx), staff));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
