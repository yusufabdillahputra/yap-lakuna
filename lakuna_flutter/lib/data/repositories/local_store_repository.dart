import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';
import 'store_repository.dart';

/// [StoreRepository] di atas database SQLite perangkat.
class LocalStoreRepository extends StoreRepository {
  LocalStoreRepository(
    this._store, {
    this._hasher = const CredentialHasher(),
    DevicePlatform? platform,
    this._preferences,
  }) : _platform = platform ?? currentDevicePlatform();

  final LakunaStore _store;

  /// Bila ada, cabang pilihan (web) diingat di sini (F2-02 aturan 2a).
  final LocalPreferences? _preferences;
  final CredentialHasher _hasher;
  final DevicePlatform _platform;
  StoreContext? _current;

  @override
  StoreContext? get current => _current;

  @override
  Future<Result<StoreContext?>> load() async {
    try {
      var ctx = await loadStoreContext(_store);
      final preferences = _preferences;
      if (ctx != null && preferences != null) {
        final saved = tryUuid(
          await preferences.get(_outletKey(ctx.tenant.id)) ?? '',
        );
        if (saved != null && saved != ctx.outlet.id) {
          ctx = await loadStoreContext(_store, outletId: saved) ?? ctx;
        }
      }
      _current = ctx;
      notifyListeners();
      return Result.ok(_current);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<StoreContext>> setup(
    SetupInput input, {
    ProductDraft? firstProduct,
  }) async {
    try {
      final hasher = _hasher;
      final pin = input.pin;
      final password = input.password;
      // Argon2id sengaja lambat; jalankan di isolate agar UI tetap halus.
      final credentials = await Isolate.run(
        () => SetupCredentials(
          pinHash: hasher.hash(pin),
          passwordHash: hasher.hash(password),
        ),
      );
      final ctx = await setupStore(
        _store,
        input,
        platform: _platform,
        credentials: credentials,
        firstProduct: firstProduct,
      );
      _current = ctx;
      notifyListeners();
      return Result.ok(ctx);
    } on SetupAlreadyDone catch (e) {
      // Toko sudah ada (mis. konteks belum termuat): muat ulang agar router
      // keluar dari wizard bila konteksnya lengkap. Produk pertama yang
      // diketik tidak tersimpan, jadi pesan galat tetap ditampilkan.
      if (firstProduct != null) return Result.error(e);
      final reloaded = await load();
      if (reloaded case Ok(value: final ctx?)) return Result.ok(ctx);
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<Outlet>>> outlets() async {
    final ctx = _current;
    if (ctx == null) return const Result.ok([]);
    try {
      return Result.ok(
        await Outlet.db.find(
          _store.session,
          where: (o) =>
              o.tenantId.equals(ctx.tenant.id) & o.deletedAt.equals(null),
          orderBy: (o) => o.createdAt,
        ),
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<StoreContext>> switchOutlet(UuidValue outletId) async {
    final current = _current;
    if (current == null) return Result.error(const OutletUnavailable());
    try {
      final ctx = await loadStoreContext(_store, outletId: outletId);
      if (ctx == null) return Result.error(const OutletUnavailable());
      await _preferences?.set(_outletKey(ctx.tenant.id), outletId.uuid);
      _current = ctx;
      notifyListeners();
      return Result.ok(ctx);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}

String _outletKey(UuidValue tenantId) => 'web.outlet.${tenantId.uuid}';

/// Platform perangkat ini untuk kolom `devices.platform`.
DevicePlatform currentDevicePlatform() {
  if (kIsWeb) return DevicePlatform.web;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => DevicePlatform.android,
    TargetPlatform.iOS => DevicePlatform.ios,
    TargetPlatform.macOS => DevicePlatform.macos,
    TargetPlatform.windows => DevicePlatform.windows,
    TargetPlatform.linux || TargetPlatform.fuchsia => DevicePlatform.linux,
  };
}
