import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'session_repository.dart';
import 'shifts_repository.dart';
import 'store_repository.dart';

/// [ShiftsRepository] di atas database perangkat.
class LocalShiftsRepository extends ShiftsRepository {
  LocalShiftsRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<List<ShiftRow>>> list() =>
      _guard(manage: false, (scope, _) => listShifts(_store, scope));

  @override
  Future<Result<Shift>> save({
    UuidValue? id,
    required String name,
    required int startMinute,
    required int endMinute,
  }) => _guard(
    (scope, staffId) => saveShift(
      _store,
      scope,
      staffId: staffId,
      id: id,
      name: name,
      startMinute: startMinute,
      endMinute: endMinute,
    ),
  );

  @override
  Future<Result<void>> delete(UuidValue id) => _guard(
    (scope, staffId) =>
        deleteShift(_store, scope, staffId: staffId, shiftId: id),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(CatalogScope scope, UuidValue staffId) body, {
    bool manage = true,
  }) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || (manage && !staff.can(Permission.settingsManage))) {
      return const Result.error(NotPermitted(Permission.settingsManage));
    }
    try {
      return Result.ok(await body(CatalogScope.of(ctx), staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
