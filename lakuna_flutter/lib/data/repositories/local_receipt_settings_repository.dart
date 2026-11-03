import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'receipt_settings_repository.dart';
import 'session_repository.dart';
import 'store_repository.dart';

/// [ReceiptSettingsRepository] di atas database dan preferensi perangkat.
class LocalReceiptSettingsRepository extends ReceiptSettingsRepository {
  LocalReceiptSettingsRepository(
    this._store, {
    required this._stores,
    required this._session,
    required this._preferences,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;
  final LocalPreferences _preferences;

  @override
  Future<Result<ReceiptConfig>> loadReceipt() =>
      _guard(manage: false, (scope, _) => loadReceiptConfig(_store, scope));

  @override
  Future<Result<ReceiptConfig>> saveReceipt(ReceiptSettings settings) => _guard(
    manage: true,
    (scope, staffId) => saveReceiptSettings(
      _store,
      scope,
      staffId: staffId,
      settings: settings,
    ),
  );

  @override
  Future<Result<PrinterSelection?>> loadPrinter() =>
      _guard(manage: false, (_, _) => loadPrinterSelection(_preferences));

  @override
  Future<Result<void>> savePrinter(PrinterSelection? printer) => _guard(
    manage: true,
    (_, _) => savePrinterSelection(_preferences, printer),
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(CatalogScope scope, UuidValue staffId) body, {
    required bool manage,
  }) async {
    const permission = Permission.settingsManage;
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null) return const Result.error(NotPermitted(permission));
    if (manage && !staff.can(permission)) {
      return const Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(CatalogScope.of(ctx), staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
