import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'session_repository.dart';
import 'stock_repository.dart';
import 'store_repository.dart';

/// [StockRepository] di atas database lokal.
class LocalStockRepository extends StockRepository {
  LocalStockRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<List<StockLocation>>> locations() =>
      _guard((scope, _) => stockLocations(_store, scope));

  @override
  Future<Result<List<StockRow>>> stock({UuidValue? locationId}) =>
      _guard((scope, _) => stockList(_store, scope, locationId: locationId));

  @override
  Future<Result<List<StockRow>>> belowMinimum({UuidValue? locationId}) =>
      _guard(
        (scope, _) => belowMinimumStock(_store, scope, locationId: locationId),
      );

  @override
  Future<Result<StockCard>> card({
    required UuidValue variantId,
    UuidValue? locationId,
  }) => _guard(
    (scope, _) => stockCard(
      _store,
      scope,
      variantId: variantId,
      locationId: locationId,
    ),
  );

  @override
  Future<Result<String>> nextAdjustmentNumber() =>
      _guard((scope, _) => nextStockAdjustmentNumber(_store, scope));

  @override
  Future<Result<List<StockAdjustmentSummary>>> recentAdjustments() =>
      _guard((scope, _) => recentStockAdjustments(_store, scope));

  @override
  Future<Result<StockAdjustmentResult>> saveAdjustment({
    required UuidValue locationId,
    required StockAdjustmentReason reason,
    required List<AdjustmentLine> lines,
    String? note,
  }) => _guard(
    adjust: true,
    (scope, staffId) => saveStockAdjustment(
      _store,
      scope,
      staffId: staffId,
      locationId: locationId,
      reason: reason,
      note: note,
      lines: lines,
    ),
  );

  @override
  Future<Result<StockLocation>> createLocation(String name) => _guard(
    adjust: true,
    (scope, staffId) =>
        createStockLocation(_store, scope, staffId: staffId, name: name),
  );

  @override
  Future<Result<StockLocation>> renameLocation(UuidValue id, String name) =>
      _guard(
        adjust: true,
        (scope, staffId) => renameStockLocation(
          _store,
          scope,
          staffId: staffId,
          locationId: id,
          name: name,
        ),
      );

  Future<Result<T>> _guard<T>(
    Future<T> Function(CatalogScope scope, UuidValue staffId) body, {
    bool adjust = false,
  }) async {
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null) {
      return const Result.error(NotPermitted(Permission.stockAdjust));
    }
    final canAdjust = staff.can(Permission.stockAdjust);
    if (adjust
        ? !canAdjust
        : !(canAdjust || staff.can(Permission.productsManage))) {
      return const Result.error(NotPermitted(Permission.stockAdjust));
    }
    try {
      return Result.ok(await body(CatalogScope.of(ctx), staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
