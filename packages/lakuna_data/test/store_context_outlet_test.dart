import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Pemilih cabang di web (F2-02 aturan 2a): konteks toko bisa berganti
/// outlet, perangkat tetap perangkat web.
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext pst;
  late Outlet kmg;
  late UuidValue webId;

  setUp(() async {
    (store, dir) = await openTempStore();
    pst = await setupTestStore(store);
    webId = UuidValue.fromString(newId());
    kmg = await store.write((w) async {
      final s = await w.stamp();
      final outlet = await w.insert(
        Outlet(
          tenantId: pst.tenant.id,
          code: 'KMG',
          name: 'Cabang Kemang',
          timezone: 'Asia/Jakarta',
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      await w.insert(
        Device(
          id: webId,
          tenantId: pst.tenant.id,
          outletId: pst.outlet.id,
          code: 'W01',
          name: 'Browser',
          platform: DevicePlatform.web,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      return outlet;
    });
    // Database ini dipakai sebagai perangkat web W01.
    await writeSyncState(store.session, SyncStateKey.deviceId, webId.uuid);
    final path = store.path;
    await store.close();
    store = await LakunaStore.open(path);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('tanpa outletId: outlet asal perangkat', () async {
    final ctx = (await loadStoreContext(store))!;
    expect(ctx.outlet.code, 'PST');
    expect(ctx.device.code, 'W01');
  });

  test('outletId lain di tenant sama: outlet itu, perangkat sama', () async {
    final ctx = (await loadStoreContext(store, outletId: kmg.id))!;
    expect(ctx.outlet.code, 'KMG');
    expect(ctx.device.id, webId);
    expect(ctx.owner.id, pst.owner.id);
  });

  test('outlet tenant lain atau terhapus: null', () async {
    expect(
      await loadStoreContext(store, outletId: UuidValue.fromString(newId())),
      isNull,
    );
    await store.write((w) async {
      final s = await w.stamp();
      await w.update(
        kmg.copyWith(
          deletedAt: s.now,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
    expect(await loadStoreContext(store, outletId: kmg.id), isNull);
  });

  test(
    'nomor penyesuaian dari web setelah pindah cabang (Fokus review 5)',
    () async {
      final ctx = (await loadStoreContext(store, outletId: kmg.id))!;
      final number = await nextStockAdjustmentNumber(
        store,
        CatalogScope.of(ctx),
      );
      expect(number, startsWith('SA-KMG-W01-'));
    },
  );
}
