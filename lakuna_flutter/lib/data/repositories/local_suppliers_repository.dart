import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'session_repository.dart';
import 'store_repository.dart';
import 'suppliers_repository.dart';

/// [SuppliersRepository] di atas database perangkat.
class LocalSuppliersRepository extends SuppliersRepository {
  LocalSuppliersRepository(
    this._store, {
    required this._stores,
    required this._session,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final DateTime Function() _clock;

  DateTime get _now => _clock().toUtc();

  @override
  Future<Result<SuppliersSetup>> load() => _guard((ctx, scope, staff) async {
    final drawerCash = await openDrawerCash(_store, CashScope.of(ctx));
    return SuppliersSetup(
      today: await outletToday(_store.session, scope, _now),
      outletId: ctx.outlet.id,
      canManage: staff.can(Permission.suppliersManage),
      canPay: staff.can(Permission.debtsManage),
      canUseDrawer: staff.can(Permission.cashMovementsCreate),
      hasOpenSession: drawerCash != null,
      drawerCash: drawerCash,
    );
  });

  @override
  Future<Result<SuppliersOverview>> list() => _guard(
    (_, scope, _) => loadSuppliersOverview(_store, scope, now: _now),
  );

  @override
  Future<Result<SupplierDetail>> detail(UuidValue id) =>
      _guard((_, scope, _) => loadSupplierDetail(_store, scope, id, now: _now));

  @override
  Future<Result<Supplier>> save(SupplierInput input) => _guard(
    permission: Permission.suppliersManage,
    (_, scope, staff) =>
        saveSupplier(_store, scope, staffId: staff.id, input: input),
  );

  @override
  Future<Result<SupplierImportSummary>> importRows(
    List<SupplierImportRow> rows,
  ) => _guard(
    permission: Permission.suppliersManage,
    (_, scope, staff) =>
        importSuppliers(_store, scope, staffId: staff.id, rows: rows),
  );

  @override
  Future<Result<void>> delete(UuidValue id) => _guard(
    permission: Permission.suppliersManage,
    (_, scope, staff) =>
        deleteSupplier(_store, scope, staffId: staff.id, supplierId: id),
  );

  @override
  Future<Result<DebtPayment>> pay(SupplierPaymentRequest request) {
    final drawer = request.funding == FundingSource.drawer;
    final staff = _session.current;
    if (drawer &&
        staff != null &&
        staff.can(Permission.debtsManage) &&
        !staff.can(Permission.cashMovementsCreate)) {
      return Future.value(
        const Result.error(NotPermitted(Permission.cashMovementsCreate)),
      );
    }
    return _guard(
      permission: Permission.debtsManage,
      (_, scope, staff) =>
          paySupplierDebt(_store, scope, staffId: staff.id, request: request),
    );
  }

  @override
  Future<Result<DebtPayment>> voidPayment(UuidValue paymentId, String reason) =>
      _guard(
        permission: Permission.debtsManage,
        // `voidDebtPayment` juga memeriksa `cash_movements:create` untuk
        // pembayaran laci.
        (_, scope, staff) => voidDebtPayment(
          _store,
          scope,
          staffId: staff.id,
          paymentId: paymentId,
          reason: reason,
        ),
      );

  @override
  Future<Result<List<PurchaseRow>>> purchases(UuidValue supplierId) => _guard(
    (_, scope, _) => listSupplierPurchases(_store, scope, supplierId),
  );

  @override
  Future<Result<Uint8List?>> proof(UuidValue paymentId) => _guard(
    (_, scope, _) => loadSupplierPaymentProof(_store, scope, paymentId),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, CatalogScope scope, StaffProfile staff)
    body, {
    Permission? permission,
  }) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null ||
        !(staff.can(Permission.suppliersManage) ||
            staff.can(Permission.debtsManage))) {
      return const Result.error(NotPermitted(Permission.suppliersManage));
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
