import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'master_data_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [MasterDataRepository] di atas database lokal.
class LocalMasterDataRepository extends MasterDataRepository {
  LocalMasterDataRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<List<CategoryRow>>> categories() =>
      _guard((scope, _) => categoryRows(_store, scope));

  @override
  Future<Result<ProductCategory>> createCategory(CategoryDraft draft) => _guard(
    (scope, staffId) =>
        data.createCategory(_store, scope, staffId: staffId, draft: draft),
  );

  @override
  Future<Result<ProductCategory>> updateCategory(
    UuidValue id,
    CategoryDraft draft,
  ) => _guard(
    (scope, staffId) => data.updateCategory(
      _store,
      scope,
      staffId: staffId,
      id: id,
      draft: draft,
    ),
  );

  @override
  Future<Result<ProductCategory>> setCategoryActive(
    UuidValue id,
    bool active,
  ) => _guard(
    (scope, staffId) => data.setCategoryActive(
      _store,
      scope,
      staffId: staffId,
      id: id,
      active: active,
    ),
  );

  @override
  Future<Result<void>> moveCategory(UuidValue id, int delta) => _guard(
    (scope, staffId) => data.moveCategory(
      _store,
      scope,
      staffId: staffId,
      id: id,
      delta: delta,
    ),
  );

  @override
  Future<Result<void>> deleteCategory(UuidValue id) => _guard(
    (scope, staffId) =>
        data.deleteCategory(_store, scope, staffId: staffId, id: id),
  );

  @override
  Future<Result<List<UnitRow>>> units() =>
      _guard((scope, _) => unitRows(_store, scope));

  @override
  Future<Result<MeasureUnit>> createUnit(String name) => _guard(
    (scope, staffId) =>
        data.createUnit(_store, scope, staffId: staffId, name: name),
  );

  @override
  Future<Result<MeasureUnit>> renameUnit(UuidValue id, String name) => _guard(
    (scope, staffId) =>
        data.renameUnit(_store, scope, staffId: staffId, id: id, name: name),
  );

  @override
  Future<Result<void>> deleteUnit(UuidValue id) => _guard(
    (scope, staffId) =>
        data.deleteUnit(_store, scope, staffId: staffId, id: id),
  );

  @override
  Future<Result<List<StockLocation>>> locations() =>
      _guard((scope, _) => stockLocations(_store, scope));

  Future<Result<T>> _guard<T>(
    Future<T> Function(CatalogScope scope, UuidValue staffId) body,
  ) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(Permission.productsManage)) {
      return const Result.error(NotPermitted(Permission.productsManage));
    }
    try {
      return Result.ok(await body(CatalogScope.of(ctx), staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
