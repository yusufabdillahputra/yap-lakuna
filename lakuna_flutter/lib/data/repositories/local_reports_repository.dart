import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/log_error.dart';
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
    required this._preferences,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final LocalPreferences _preferences;
  final DateTime Function() _clock;

  /// Kunci preferensi periode per cabang (F1-16f).
  String? _periodKey() {
    final ctx = _stores.current;
    if (ctx == null) return null;
    return 'reports.period.${ctx.tenant.id.uuid}.${ctx.outlet.id.uuid}';
  }

  @override
  Future<ReportPeriod?> savedPeriod() async {
    final key = _periodKey();
    if (key == null) return null;
    try {
      final text = await _preferences.get(key);
      return text == null ? null : ReportPeriod.fromJson(jsonDecode(text));
    } on Object catch (e, st) {
      if (e is! FormatException) {
        logError('Periode laporan gagal dibaca', e, st);
      }
      return null;
    }
  }

  @override
  Future<void> savePeriod(ReportPeriod period) async {
    final key = _periodKey();
    if (key == null) return;
    try {
      await _preferences.set(key, jsonEncode(period.toJson()));
    } on Object catch (e, st) {
      logError('Periode laporan gagal disimpan', e, st);
    }
  }

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

  @override
  Future<Result<ClosedSessionRecap>> loadSessionRecap(UuidValue sessionId) =>
      _run(
        (scope, permissions, now) => loadClosedSessionRecap(
          _store,
          scope,
          permissions: permissions,
          sessionId: sessionId,
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
      final member = await findActingStaff(
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
