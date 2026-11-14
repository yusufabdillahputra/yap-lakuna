import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data show loadProduct;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'catalog_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [CatalogRepository] di atas database perangkat.
class LocalCatalogRepository extends CatalogRepository {
  LocalCatalogRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<ProductCatalog>> loadCatalog() => _guard((scope, _) async {
    final products = await listProducts(_store, scope);
    final categories = await listCategories(_store, scope);
    final units = await listUnits(_store, scope);
    return ProductCatalog(
      products: products,
      categories: categories,
      units: units,
      modifierGroups: await modifierGroupRows(_store, scope),
      customerGroups: [
        for (final r in await listCustomerGroups(_store, scope)) r.group,
      ],
      archivedCount: await countArchivedProducts(_store, scope),
    );
  });

  @override
  Future<Result<CatalogProduct?>> loadProduct(UuidValue id) =>
      _guard((scope, _) => data.loadProduct(_store, scope, id));

  @override
  Future<Result<UuidValue>> save(ProductDraft draft) => _guard(
    (scope, staffId) =>
        saveProduct(_store, scope, staffId: staffId, draft: draft),
  );

  @override
  Future<Result<ProductImportSummary>> importRows(
    List<ProductImportRow> rows, {
    bool updateExisting = false,
    bool dryRun = false,
  }) => _guard(
    (scope, staffId) => importProducts(
      _store,
      scope,
      staffId: staffId,
      rows: rows,
      updateExisting: updateExisting,
      dryRun: dryRun,
    ),
  );

  @override
  Future<Result<void>> archive(UuidValue id) => _guard(
    (scope, staffId) =>
        archiveProduct(_store, scope, staffId: staffId, productId: id),
  );

  @override
  Future<Result<List<CatalogProduct>>> archived() =>
      _guard((scope, _) => listArchivedProducts(_store, scope));

  @override
  Future<Result<void>> restore(UuidValue id) => _guard(
    (scope, staffId) =>
        restoreProduct(_store, scope, staffId: staffId, productId: id),
  );

  @override
  Future<Result<void>> setPhoto(UuidValue id, ProductPhotoUpload photo) =>
      _guard(
        (scope, staffId) => setProductPhoto(
          _store,
          scope,
          staffId: staffId,
          productId: id,
          photo: photo,
        ),
      );

  @override
  Future<Result<void>> clearPhoto(UuidValue id) => _guard(
    (scope, staffId) =>
        clearProductPhoto(_store, scope, staffId: staffId, productId: id),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(CatalogScope scope, UuidValue staffId) body,
  ) async {
    const permission = Permission.productsManage;
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(permission)) {
      return const Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(CatalogScope.of(ctx), staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
