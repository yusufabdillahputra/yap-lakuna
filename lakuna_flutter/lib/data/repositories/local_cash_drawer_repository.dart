import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'cash_drawer_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [CashDrawerRepository] di atas database perangkat.
class LocalCashDrawerRepository extends CashDrawerRepository {
  LocalCashDrawerRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<ActiveCashSession?>> loadCurrent() =>
      _guard(null, (scope, _) async {
        final session = await findOpenCashSession(_store, scope);
        if (session == null) return null;
        return _active(scope, session);
      });

  @override
  Future<Result<ActiveCashSession>> open({
    required Money openingCash,
    String note = '',
  }) => _guard(Permission.cashSessionOpen, (scope, staffId) async {
    final session = await openCashSession(
      _store,
      scope,
      staffId: staffId,
      openingCash: openingCash,
      note: note,
    );
    return _active(scope, session);
  });

  @override
  Future<Result<ActiveCashSession>> recordMovement(
    UuidValue sessionId, {
    required CashDirection direction,
    required Money amount,
    required String note,
  }) => _guard(Permission.cashMovementsCreate, (scope, staffId) async {
    await recordCashMovement(
      _store,
      scope,
      sessionId: sessionId,
      staffId: staffId,
      direction: direction,
      amount: amount,
      note: note,
    );
    final session = await findOpenCashSession(_store, scope);
    if (session == null) throw CashSessionNotOpen();
    return _active(scope, session);
  });

  @override
  Future<Result<CashSession>> close(
    UuidValue sessionId, {
    required CashCount count,
    String note = '',
  }) => _guard(
    Permission.cashSessionClose,
    (scope, staffId) => closeCashSession(
      _store,
      scope,
      sessionId: sessionId,
      staffId: staffId,
      count: count,
      note: note,
    ),
  );

  /// Memeriksa toko, staf, dan [permission] (`null` = cukup login), lalu
  /// menjalankan [body] dan membungkus galatnya.
  Future<Result<T>> _guard<T>(
    Permission? permission,
    Future<T> Function(CashScope scope, UuidValue staffId) body,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null) {
      return Result.error(
        NotPermitted(permission ?? Permission.cashSessionOpen),
      );
    }
    if (permission != null && !staff.can(permission)) {
      return Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(CashScope.of(ctx), staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<ActiveCashSession> _active(
    CashScope scope,
    CashSession session,
  ) async {
    final movements = await listCashMovements(_store, scope, session.id);
    final drawer = await cashDrawerFor(_store, scope, session);
    final opener = await StaffMember.db.findFirstRow(
      _store.session,
      where: (s) =>
          s.id.equals(session.openedBy) & s.tenantId.equals(scope.tenantId),
    );
    return ActiveCashSession(
      session: session,
      openedByName: opener?.name ?? '',
      movements: movements,
      drawer: drawer,
    );
  }
}
