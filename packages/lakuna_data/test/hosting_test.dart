import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('tandai tenant hosted lewat outbox (aturan 14)', () async {
    await markTenantHosted(store, staffId: ctx.owner.id);
    final tenant = (await Tenant.db.findById(store.session, ctx.tenant.id))!;
    expect(tenant.plan, TenantPlan.hosted);
    expect(tenant.version, ctx.tenant.version + 1);
    final entries = await SyncOutboxEntry.db.find(
      store.session,
      where: (e) => e.entity.equals('tenants'),
      orderBy: (e) => e.id,
    );
    expect(entries.last.hlc, tenant.hlc);
  });

  test('perangkat gabungan: ID dari server, tanpa unggah awal', () async {
    final id = UuidValue.fromString('01900000-0000-7000-8000-0000000000b9');
    final joined = await openJoinedStore(
      '${dir.path}/gabung/lakuna.sqlite',
      deviceId: id,
    );
    addTearDown(joined.close);
    expect(joined.deviceId, id);
    expect(await joined.syncState(SyncStateKey.initialUpload), 'done');
    expect(await SyncOutboxEntry.db.count(joined.session), 0);
    expect(await Tenant.db.count(joined.session), 0);
  });

  test('perangkat gabungan menolak berkas database yang sudah ada', () async {
    await expectLater(
      openJoinedStore(
        store.path,
        deviceId: UuidValue.fromString('01900000-0000-7000-8000-0000000000b9'),
      ),
      throwsStateError,
    );
  });
}
