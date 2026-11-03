import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;
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

  Future<Tenant> tenant() => store.write((w) async {
    final s = await w.stamp();
    return w.insert(
      Tenant(name: 'Toko', hlc: s.hlc.toString(), originDeviceId: s.deviceId),
      s,
    );
  });

  Future<Setting> setting(Tenant t, String scopeKey, {Outlet? outlet}) =>
      store.write((w) async {
        final s = await w.stamp();
        return w.insert(
          Setting(
            tenantId: t.id,
            outletId: outlet?.id,
            scopeKey: scopeKey,
            key: 'tax',
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      });

  test('pengaturan tingkat tenant tidak bisa ganda', () async {
    final t = await tenant();
    await setting(t, settingScopeTenant);
    await expectLater(
      setting(t, settingScopeTenant),
      throwsA(isA<DatabaseUniqueViolationException>()),
    );
    expect(await Setting.db.count(store.session), 1);
  });

  test('kunci yang sama boleh ada di tingkat tenant dan per outlet', () async {
    final t = await tenant();
    final outlet = await store.write((w) async {
      final s = await w.stamp();
      return w.insert(
        Outlet(
          tenantId: t.id,
          code: 'PST',
          name: 'Pusat',
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
    await setting(t, settingScopeTenant);
    await setting(t, settingScopeOutlet(outlet.id), outlet: outlet);
    expect(await Setting.db.count(store.session), 2);
  });
}
