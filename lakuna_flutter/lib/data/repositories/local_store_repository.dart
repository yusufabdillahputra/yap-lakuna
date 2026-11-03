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
  }) : _platform = platform ?? currentDevicePlatform();

  final LakunaStore _store;
  final CredentialHasher _hasher;
  final DevicePlatform _platform;
  StoreContext? _current;

  @override
  StoreContext? get current => _current;

  @override
  Future<Result<StoreContext?>> load() async {
    try {
      _current = await loadStoreContext(_store);
      notifyListeners();
      return Result.ok(_current);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<StoreContext>> setup(SetupInput input) async {
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
      );
      _current = ctx;
      notifyListeners();
      return Result.ok(ctx);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}

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
