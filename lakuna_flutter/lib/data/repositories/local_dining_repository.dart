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
  Future<Result<DiningData>> load() => _guard((ctx, staff) async {
    final scope = CatalogScope.of(ctx);
    final products = [
      for (final p in await listProducts(_store, scope))
        if (p.isActive && p.variants.isNotEmpty) p,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final all = await listCategories(_store, scope);
    return DiningData(
      overview: await diningOverview(_store, scope),
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
  Future<Result<void>> voidBill(UuidValue billId, String reason) =>
      _guard((ctx, staff) {
        if (!staff.can(Permission.salesVoid)) {
          throw const NotPermitted(Permission.salesVoid);
        }
        return voidOpenBill(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          billId: billId,
          reason: reason,
        );
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
