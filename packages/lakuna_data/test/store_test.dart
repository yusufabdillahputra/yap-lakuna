import 'dart:convert';
import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;

  setUp(() async {
    (store, dir) = await openTempStore();
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('id perangkat dibuat sekali dan tetap sama setelah dibuka ulang', () async {
    final first = store.deviceId;
    await store.close();
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    expect(store.deviceId, first);
  });

  test('semua tabel dibuat STRICT', () async {
    final rows = await store.session.db.unsafeQuery(
      "SELECT name, sql FROM sqlite_master WHERE type = 'table' "
      "AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'serverpod_%'",
    );
    final tables = {for (final r in rows) r[0] as String: r[1] as String};
    expect(tables.keys, containsAll(<String>[
      'tenants', 'outlets', 'stock_locations', 'devices', 'settings',
      'staff_members', 'outlet_members', 'sync_outbox', 'sync_state',
      'local_preferences',
    ]));
    for (final entry in tables.entries) {
      expect(entry.value.trimRight(), endsWith('STRICT'), reason: entry.key);
    }
  });

  test('insert lewat SyncTx menulis baris dan satu entri outbox', () async {
    final tenant = await store.write((w) async {
      final s = await w.stamp();
      return w.insert(
        Tenant(name: 'Toko Maju', hlc: s.hlc.toString(), originDeviceId: s.deviceId),
        s,
      );
    });

    expect(tenant.hlc, isNotEmpty);
    expect(tenant.originDeviceId, store.deviceId);

    final outbox = await SyncOutboxEntry.db.find(store.session);
    expect(outbox, hasLength(1));
    final entry = outbox.single;
    expect(entry.entity, 'tenants');
    expect(entry.rowId, tenant.id);
    expect(entry.op, SyncOp.upsert);
    expect(entry.status, OutboxStatus.pending);
    expect(entry.hlc, tenant.hlc);
    final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;
    expect(payload['name'], 'Toko Maju');
  });

  test('kesalahan di tengah transaksi membatalkan baris dan outbox', () async {
    await expectLater(
      store.write((w) async {
        final s = await w.stamp();
        await w.insert(Tenant(name: 'Gagal', hlc: s.hlc.toString()), s);
        throw StateError('batal');
      }),
      throwsStateError,
    );
    expect(await Tenant.db.count(store.session), 0);
    expect(await SyncOutboxEntry.db.count(store.session), 0);
  });

  test('update menambah entri outbox dengan HLC yang lebih besar', () async {
    final tenant = await store.write((w) async {
      final s = await w.stamp();
      return w.insert(Tenant(name: 'A', hlc: s.hlc.toString()), s);
    });
    final updated = await store.write((w) async {
      final s = await w.stamp();
      return w.update(
        tenant.copyWith(
          name: 'B',
          version: tenant.version + 1,
          updatedAt: s.now,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
    expect(updated.name, 'B');
    expect(updated.version, 2);

    final outbox = await SyncOutboxEntry.db.find(
      store.session,
      orderBy: (t) => t.id,
    );
    expect(outbox, hasLength(2));
    expect(
      Hlc.parse(outbox[1].hlc).compareTo(Hlc.parse(outbox[0].hlc)),
      greaterThan(0),
    );
  });

  test('HLC terakhir disimpan dan tetap naik walau jam mundur', () async {
    var now = DateTime.utc(2026, 11, 3, 5);
    await store.close();
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite', clock: () => now);
    final a = await store.write((w) async => (await w.stamp()).hlc);
    now = now.subtract(const Duration(minutes: 1));
    final b = await store.write((w) async => (await w.stamp()).hlc);
    expect(b > a, isTrue);
    expect(await store.syncState(SyncStateKey.lastHlc), b.toString());
  });

  test('aktor dicatat sebagai created_by/updated_by', () async {
    final actor = UuidValue.fromString(newId());
    final s = await store.write((w) async => w.stamp(), actor: actor);
    expect(s.actor, actor);
  });
}
