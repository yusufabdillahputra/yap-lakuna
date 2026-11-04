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
  Future<Result<ReportData>> load(ReportPeriod period) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.reportsView)) {
      return const Result.error(NotPermitted(Permission.reportsView));
    }
    try {
      return Result.ok(
        await loadReport(
          _store,
          CatalogScope.of(ctx),
          staffId: staff.id,
          period: period,
          now: _clock().toUtc(),
        ),
      );
    } on ReportActorNotPermitted {
      return const Result.error(NotPermitted(Permission.reportsView));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
