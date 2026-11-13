import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'dining_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [DiningRepository] di atas database perangkat.
class LocalDiningRepository extends DiningRepository {
  LocalDiningRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._preferences,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final LocalPreferences _preferences;

  @override
  Future<Result<int>> pendingQrisCount() => _guard(
    (ctx, _) => data.pendingQrisCount(_store, CatalogScope.of(ctx)),
  );

  @override
  Future<Result<DiningData>> load() => _guard((ctx, staff) async {
    final scope = CatalogScope.of(ctx);
    final products = [
      for (final p in await listProducts(_store, scope))
        if (p.isActive && p.variants.isNotEmpty) p,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final all = await listCategories(_store, scope);
    final overview = await diningOverview(_store, scope);
    return DiningData(
      overview: overview,
      products: products,
      categories: cashierCategories(all, {
        for (final p in products) p.categoryId,
      }),
      categoryParents: {
        for (final c in all)
          if (c.parentId != null) c.id: c.parentId!,
      },
      staffName: staff.name,
      timezone: ctx.outlet.timezone ?? ctx.tenant.timezone,
      canPay: staff.can(Permission.salesCreate),
      canVoid: staff.can(Permission.salesVoid),
      receipt: await loadReceiptConfig(_store, scope),
      printer: await loadPrinterSelection(_preferences),
      modifierGroups: await menuModifierGroups(_store, scope),
      floorImages: await floorImages(_store, scope, [
        for (final a in overview.areas)
          if (a.layoutMode == DiningLayoutMode.floor) a,
      ]),
      canArrange: staff.can(Permission.settingsManage),
      canDiscount: staff.can(Permission.salesDiscount),
      discountNeedsPin: (await loadSalesRules(
        _store.session,
        scope,
      )).discountNeedsPin,
    );
  });

  @override
  Future<Result<DiningOverview>> overview() =>
      _guard((ctx, _) => diningOverview(_store, CatalogScope.of(ctx)));

  @override
  Future<Result<OpenBill>> openTable(UuidValue tableId, int guests) => _guard(
    (ctx, staff) => openTableBill(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      tableId: tableId,
      guests: guests,
    ),
  );

  @override
  Future<Result<OpenBill>> openTakeAway(String? customerName) => _guard(
    (ctx, staff) => data.openTakeAway(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      customerName: customerName,
    ),
  );

  @override
  Future<Result<OpenBill>> addItem(
    UuidValue billId,
    SaleLineRequest line, {
    String? note,
    List<UuidValue> modifierIds = const [],
  }) => _guard(
    (ctx, staff) => addBillItem(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
      line: line,
      note: note,
      modifierIds: modifierIds,
    ),
  );

  @override
  Future<Result<OpenBill>> setItemQuantity(UuidValue itemId, Qty quantity) =>
      _guard(
        (ctx, staff) => setBillItemQuantity(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          itemId: itemId,
          quantity: quantity,
        ),
      );

  @override
  Future<Result<OpenBill>> markServed(UuidValue itemId) => _guard(
    (ctx, staff) => markItemServed(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      itemId: itemId,
    ),
  );

  @override
  Future<Result<KitchenSendResult>> sendToKitchen(UuidValue billId) => _guard(
    (ctx, staff) => data.sendToKitchen(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
    ),
  );

  @override
  Future<Result<OpenBill>> setBillRequested(UuidValue billId, bool requested) =>
      _guard(
        (ctx, staff) => data.setBillRequested(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          billId: billId,
          requested: requested,
        ),
      );

  @override
  Future<Result<OpenBill>> moveBill(UuidValue billId, UuidValue tableId) =>
      _guard(
        (ctx, staff) => moveBillToTable(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          billId: billId,
          tableId: tableId,
        ),
      );

  @override
  Future<Result<OpenBill>> mergeBill(
    UuidValue targetBillId,
    UuidValue sourceBillId,
  ) => _guard(
    (ctx, staff) => mergeOpenBills(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      targetBillId: targetBillId,
      sourceBillId: sourceBillId,
    ),
  );

  @override
  Future<Result<OpenBill>> setDiscount(
    UuidValue billId,
    ManualDiscount? discount, {
    UuidValue? approverId,
  }) => _guard((ctx, staff) async {
    if (discount != null &&
        approverId == null &&
        !staff.can(Permission.salesDiscount)) {
      throw const NotPermitted(Permission.salesDiscount);
    }
    // Id penyetuju saja tidak cukup: PIN-nya harus baru diperiksa di sini.
    if (approverId != null &&
        !_session.hasApproval(approverId, Permission.salesDiscount)) {
      throw const NotPermitted(Permission.salesDiscount);
    }
    final bill = await setBillDiscount(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
      discount: discount,
      approverId: discount == null ? null : approverId,
    );
    if (approverId != null) {
      _session.consumeApproval(approverId, Permission.salesDiscount);
    }
    return bill;
  });

  @override
  Future<Result<void>> voidBill(
    UuidValue billId,
    String reason, {
    UuidValue? approverId,
  }) => _guard((ctx, staff) async {
    if (approverId == null && !staff.can(Permission.salesVoid)) {
      throw const NotPermitted(Permission.salesVoid);
    }
    // Penyetuju harus baru saja memasukkan PIN-nya (sekali pakai).
    if (approverId != null &&
        !_session.hasApproval(approverId, Permission.salesVoid)) {
      throw const NotPermitted(Permission.salesVoid);
    }
    await voidOpenBill(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      approverId: approverId,
      billId: billId,
      reason: reason,
    );
    if (approverId != null) {
      _session.consumeApproval(approverId, Permission.salesVoid);
    }
  });

  @override
  Future<Result<void>> deleteEmptyBill(UuidValue billId) => _guard(
    (ctx, staff) => data.deleteEmptyBill(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
    ),
  );

  @override
  Future<Result<SplitBillData>> loadSplit(UuidValue billId) =>
      _guard((ctx, staff) async {
        return SplitBillData(
          bill: await loadOpenBill(_store, CatalogScope.of(ctx), billId),
          canPay: staff.can(Permission.salesCreate),
          canConfirm: staff.can(Permission.paymentsConfirm),
        );
      });

  @override
  Future<Result<OpenBill>> setSplit(
    UuidValue billId,
    SplitMode? mode,
    int guests,
  ) => _guard((ctx, staff) {
    _needSales(staff);
    return setBillSplit(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      billId: billId,
      mode: mode,
      guests: guests,
    );
  });

  /// Split bill bagian dari pembayaran: butuh `sales:create` juga.
  static void _needSales(StaffProfile staff) {
    if (!staff.can(Permission.salesCreate)) {
      throw const NotPermitted(Permission.salesCreate);
    }
  }

  @override
  Future<Result<OpenBill>> assignPortion(UuidValue itemId, String? guest) =>
      _guard((ctx, staff) {
        _needSales(staff);
        return data.assignPortion(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          itemId: itemId,
          guest: guest,
        );
      });

  @override
  Future<Result<SplitPayResult>> confirmSplitPayment(UuidValue paymentId) =>
      _guard((ctx, staff) {
        for (final p in [Permission.salesCreate, Permission.paymentsConfirm]) {
          if (!staff.can(p)) throw NotPermitted(p);
        }
        return data.confirmSplitPayment(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          paymentId: paymentId,
        );
      });

  @override
  Future<Result<OpenBill>> cancelSplitPayment(UuidValue paymentId) =>
      _guard((ctx, staff) {
        _needSales(staff);
        return data.cancelSplitPayment(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          paymentId: paymentId,
        );
      });

  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, StaffProfile staff) body,
  ) async {
    const permission = Permission.openBillsManage;
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(permission)) {
      return const Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(ctx, staff));
    } on Exception catch (e) {
      return Result.error(e);
    } on StateError catch (e) {
      return Result.error(Exception(e.message));
    }
  }
}
