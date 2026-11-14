import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'history_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [HistoryRepository] di atas database perangkat.
class LocalHistoryRepository extends HistoryRepository {
  LocalHistoryRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._preferences,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final LocalPreferences _preferences;
  final DateTime Function() _clock;

  @override
  Future<Result<HistoryData>> load() => _guard((ctx, staff) async {
    final scope = CatalogScope.of(ctx);
    final staffList = await listOutletStaff(
      _store,
      tenantId: ctx.tenant.id,
      outletId: ctx.outlet.id,
    );
    final drawerCash = await openDrawerCash(_store, CashScope.of(ctx));
    return HistoryData(
      staff: [for (final s in staffList) (id: s.id, name: s.name)],
      businessName: ctx.tenant.name,
      outletName: ctx.outlet.name,
      timezone: ctx.outlet.timezone ?? ctx.tenant.timezone,
      receipt: await loadReceiptConfig(_store, scope),
      printer: await loadPrinterSelection(_preferences),
      canReturn: staff.can(Permission.salesReturn),
      canVoid: staff.can(Permission.salesVoid),
      hasOpenSession: drawerCash != null,
      drawerCash: drawerCash,
    );
  });

  @override
  Future<Result<HistoryPage>> list(HistoryFilter filter) => _guard(
    (ctx, _) => listSalesHistory(
      _store,
      CatalogScope.of(ctx),
      filter: filter,
      now: _clock().toUtc(),
    ),
  );

  @override
  Future<Result<SaleDetail>> detail(UuidValue saleId) => _guard(
    (ctx, _) => loadSaleDetail(
      _store,
      CatalogScope.of(ctx),
      saleId,
      now: _clock().toUtc(),
    ),
  );

  @override
  Future<Result<SaleReturn>> returnSale({
    required UuidValue saleId,
    required List<ReturnLine> lines,
    required SaleReturnReason reason,
    String? note,
    required RefundMethod refundMethod,
    required bool restock,
  }) => _guard((ctx, staff) {
    if (!staff.can(Permission.salesReturn)) {
      throw const NotPermitted(Permission.salesReturn);
    }
    return data.returnSale(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      saleId: saleId,
      lines: lines,
      reason: reason,
      note: note,
      refundMethod: refundMethod,
      restock: restock,
    );
  });

  @override
  Future<Result<Sale>> voidSale({
    required UuidValue saleId,
    required String reason,
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
    final result = await data.voidSale(
      _store,
      CatalogScope.of(ctx),
      staffId: staff.id,
      approverId: approverId ?? staff.id,
      saleId: saleId,
      reason: reason,
      now: _clock().toUtc(),
    );
    if (approverId != null) {
      _session.consumeApproval(approverId, Permission.salesVoid);
    }
    return result;
  });

  /// Melihat riwayat: `sales:create` atau `reports:view`.
  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, StaffProfile staff) body,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null) {
      return const Result.error(NotPermitted(Permission.salesCreate));
    }
    if (!staff.can(Permission.salesCreate) &&
        !staff.can(Permission.reportsView)) {
      return const Result.error(NotPermitted(Permission.salesCreate));
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
