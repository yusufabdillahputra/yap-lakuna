import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'dining_admin_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [DiningAdminRepository] di atas database lokal.
class LocalDiningAdminRepository extends DiningAdminRepository {
  LocalDiningAdminRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<DiningSetup>> load() => _guard(
    (scope, _) async => DiningSetup(
      areas: await diningAreas(_store, scope),
      tables: await diningTables(_store, scope),
    ),
  );

  @override
  Future<Result<DiningArea>> createArea(String name) => _guard(
    (scope, staffId) =>
        createDiningArea(_store, scope, staffId: staffId, name: name),
  );

  @override
  Future<Result<DiningArea>> renameArea(UuidValue id, String name) => _guard(
    (scope, staffId) =>
        renameDiningArea(_store, scope, staffId: staffId, id: id, name: name),
  );

  @override
  Future<Result<void>> moveArea(UuidValue id, int delta) => _guard(
    (scope, staffId) =>
        moveDiningArea(_store, scope, staffId: staffId, id: id, delta: delta),
  );

  @override
  Future<Result<void>> deleteArea(UuidValue id) => _guard(
    (scope, staffId) =>
        deleteDiningArea(_store, scope, staffId: staffId, id: id),
  );

  @override
  Future<Result<List<DiningTable>>> createTables(
    List<DiningTableDraft> drafts,
  ) => _guard(
    (scope, staffId) =>
        createDiningTables(_store, scope, staffId: staffId, drafts: drafts),
  );

  @override
  Future<Result<DiningTable>> updateTable(
    UuidValue id,
    DiningTableDraft draft,
  ) => _guard(
    (scope, staffId) => updateDiningTable(
      _store,
      scope,
      staffId: staffId,
      id: id,
      draft: draft,
    ),
  );

  @override
  Future<Result<void>> moveTable(UuidValue id, int delta) => _guard(
    (scope, staffId) =>
        moveDiningTable(_store, scope, staffId: staffId, id: id, delta: delta),
  );

  @override
  Future<Result<void>> deleteTable(UuidValue id) => _guard(
    (scope, staffId) =>
        deleteDiningTable(_store, scope, staffId: staffId, id: id),
  );

  @override
  Future<Result<FnbRates>> rates() =>
      _guard((scope, _) => loadFnbRates(_store.session, scope));

  @override
  Future<Result<FnbRates>> saveRates(FnbRates rates) => _guard(
    (scope, staffId) =>
        data.saveFnbRates(_store, scope, staffId: staffId, rates: rates),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(CatalogScope scope, UuidValue staffId) body,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.settingsManage)) {
      return const Result.error(NotPermitted(Permission.settingsManage));
    }
    try {
      return Result.ok(await body(CatalogScope.of(ctx), staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
