import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_data/lakuna_data.dart' as data show saveSalesRules;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'repository_errors.dart';
import 'session_repository.dart';
import 'store_repository.dart';
import 'store_settings_repository.dart';

/// [StoreSettingsRepository] di atas database perangkat.
class LocalStoreSettingsRepository implements StoreSettingsRepository {
  LocalStoreSettingsRepository(
    this._store, {
    required this._stores,
    required this._session,
  });

  final LakunaStore _store;
  final StoreRepository _stores;
  final SessionRepository _session;

  @override
  Future<Result<StoreProfile>> profile() =>
      _guard((ctx, _) async => _profileOf(ctx));

  @override
  Future<Result<StoreProfile>> saveBusinessName(String name) =>
      _guard((ctx, staffId) async {
        await saveStoreProfile(
          _store,
          CatalogScope.of(ctx),
          staffId: staffId,
          name: name,
        );
        return _reload(ctx);
      });

  @override
  Future<Result<StoreProfile>> saveOutlet({
    required String name,
    required String address,
    required String phone,
  }) => _guard((ctx, staffId) async {
    await saveOutletProfile(
      _store,
      CatalogScope.of(ctx),
      staffId: staffId,
      name: name,
      address: address,
      phone: phone,
    );
    return _reload(ctx);
  });

  @override
  Future<Result<SalesRules>> salesRules() =>
      _guard((ctx, _) => loadSalesRules(_store.session, CatalogScope.of(ctx)));

  @override
  Future<Result<SalesRules>> saveSalesRules(SalesRules rules) => _guard(
    (ctx, staffId) => data.saveSalesRules(
      _store,
      CatalogScope.of(ctx),
      staffId: staffId,
      rules: rules,
    ),
  );

  /// Memuat ulang konteks toko agar kepala aplikasi, login, dan kasir
  /// memakai nama baru.
  Future<StoreProfile> _reload(StoreContext previous) async {
    final result = await _stores.load();
    return _profileOf(switch (result) {
      Ok(value: final ctx?) => ctx,
      _ => previous,
    });
  }

  StoreProfile _profileOf(StoreContext ctx) => StoreProfile(
    businessName: ctx.tenant.name,
    businessType: ctx.tenant.businessType,
    timezone: ctx.outlet.timezone ?? ctx.tenant.timezone,
    outletName: ctx.outlet.name,
    address: ctx.outlet.address ?? '',
    phone: ctx.outlet.phone ?? '',
    outletCode: ctx.outlet.code,
    deviceCode: ctx.device.code,
  );

  Future<Result<T>> _guard<T>(
    Future<T> Function(StoreContext ctx, UuidValue staffId) body,
  ) async {
    const permission = Permission.settingsManage;
    final ctx = _stores.current;
    if (ctx == null) return const Result.error(StoreNotReady());
    final staff = _session.current;
    if (staff == null || !staff.can(permission)) {
      return const Result.error(NotPermitted(permission));
    }
    try {
      return Result.ok(await body(ctx, staff.id));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
