import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'payment_settings_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [PaymentSettingsRepository] di atas database dan folder media perangkat.
class LocalPaymentSettingsRepository extends PaymentSettingsRepository {
  LocalPaymentSettingsRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<QrisConfig>> loadQris() =>
      _guard((scope, _) => loadQrisConfig(_store, scope));

  @override
  Future<Result<QrisConfig>> saveQris(
    QrisStaticSettings settings, {
    QrisImageUpload? image,
  }) => _guard(
    (scope, staffId) => saveQrisSettings(
      _store,
      scope,
      staffId: staffId,
      settings: settings,
      image: image,
    ),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(CatalogScope scope, UuidValue staffId) body,
  ) async {
    const permission = Permission.settingsManage;
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
