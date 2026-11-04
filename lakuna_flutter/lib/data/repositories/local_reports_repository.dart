import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'reports_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [ReportsRepository] di atas database perangkat.
class LocalReportsRepository extends ReportsRepository {
  LocalReportsRepository(
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
  Future<Result<ReportData>> load(ReportPeriod period) => _run(
    (scope, permissions, now) => buildReport(
      _store,
      scope,
      permissions: permissions,
      period: period,
      now: now,
    ),
  );

  @override
  Future<Result<StockReport>> loadStock(ReportPeriod period) => _run(
    (scope, permissions, now) => loadStockReport(
      _store,
      scope,
      permissions: permissions,
      period: period,
      now: now,
    ),
  );

  @override
  Future<Result<CashReport>> loadCash(ReportPeriod period) => _run(
    (scope, permissions, now) => loadCashReport(
      _store,
      scope,
      permissions: permissions,
      period: period,
      now: now,
    ),
  );

  @override
  Future<Result<DebtReport>> loadDebts() => _run(
    (scope, permissions, now) => loadDebtReport(
      _store,
      scope,
      permissions: permissions,
      now: now,
    ),
  );

  @override
  Future<Result<ReturnsReport>> loadReturns(ReportPeriod period) => _run(
    (scope, permissions, now) => loadReturnsReport(
      _store,
      scope,
      permissions: permissions,
      period: period,
      now: now,
    ),
  );

  Future<Result<T>> _run<T>(
    Future<T> Function(
      CatalogScope scope,
      Set<Permission> permissions,
      DateTime now,
    )
    load,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.reportsView)) {
      return const Result.error(NotPermitted(Permission.reportsView));
    }
    try {
      // Izin dibaca ulang dari role staf di database, bukan dari sesi.
      final member = await findStaffById(
        _store,
        tenantId: ctx.tenant.id,
        outletId: ctx.outlet.id,
        staffId: staff.id,
      );
      return Result.ok(
        await load(
          CatalogScope.of(ctx),
          member?.permissions ?? const {},
          _clock().toUtc(),
        ),
      );
    } on ReportActorNotPermitted {
      return const Result.error(NotPermitted(Permission.reportsView));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
