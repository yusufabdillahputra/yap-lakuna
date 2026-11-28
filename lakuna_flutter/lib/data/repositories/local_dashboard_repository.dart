import 'package:lakuna_client/lakuna_client.dart' show TenantStatus, UuidValue;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Permission;

import '../../utils/log_error.dart';
import '../../utils/result.dart';
import 'dashboard_repository.dart';
import 'hosting_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [DashboardRepository]: angka dari database perangkat, status perangkat
/// dari server lewat [HostingRepository].
class LocalDashboardRepository implements DashboardRepository {
  LocalDashboardRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._hosting,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final HostingRepository _hosting;
  final DateTime Function() _clock;

  @override
  Future<Result<DashboardData>> load({UuidValue? outletId}) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.reportsView)) {
      return const Result.error(NotPermitted(Permission.reportsView));
    }
    try {
      return Result.ok(
        await loadDashboard(
          _store,
          tenantId: ctx.tenant.id,
          outletId: outletId,
          now: _clock().toUtc(),
        ),
      );
    } on Exception catch (e, st) {
      logError('Dashboard gagal dimuat', e, st);
      return Result.error(e);
    }
  }

  @override
  Future<Result<TenantStatus>> tenantStatus() {
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.reportsView)) {
      return Future.value(
        const Result.error(NotPermitted(Permission.reportsView)),
      );
    }
    return _hosting.tenantStatus();
  }
}
