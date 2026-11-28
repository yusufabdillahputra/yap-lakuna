import 'dart:io';

import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;

  setUp(() async => (store, dir) = await openTempStore());
  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test(
    'StateTokenVault menyimpan token di sync_state (F2-02 aturan 10)',
    () async {
      final vault = StateTokenVault(store);
      expect(await vault.readToken(), isNull);
      await vault.writeToken('token-web');
      expect(await vault.readToken(), 'token-web');
      expect(await store.syncState(SyncStateKey.webDeviceToken), 'token-web');
      await vault.deleteToken();
      expect(await vault.readToken(), isNull);
    },
  );

  test('tokenVaultOf di VM = berkas HostingVault', () async {
    final vault = tokenVaultOf(store);
    expect(vault, isA<HostingVault>());
    await vault.writeToken('t1');
    expect(File('${dir.path}/hosting/device-token').readAsStringSync(), 't1');
  });
}
