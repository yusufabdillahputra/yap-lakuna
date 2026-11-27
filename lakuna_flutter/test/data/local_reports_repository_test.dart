import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_reports_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_session_repository.dart';

void main() {
  late Directory dir;
  late LakunaStore store;
  late LocalStoreRepository stores;
  late LocalPreferences preferences;
  late LocalReportsRepository repo;
  late StoreContext ctx;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_reports_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    final setup = await stores.setup(
      SetupInput(
        businessType: BusinessKind.retail,
        businessName: 'Toko Bu Ani',
        outletName: 'Cabang Pusat',
        outletCode: 'PST',
        deviceCode: 'K01',
        timezone: 'Asia/Jakarta',
        ownerName: 'Ani',
        email: 'ani@contoh.id',
        password: 'rahasia123',
        passwordConfirm: 'rahasia123',
        pin: '123456',
        pinConfirm: '123456',
      ),
    );
    ctx = (setup as Ok<StoreContext>).value;
    preferences = LocalPreferences(store.session);
    repo = LocalReportsRepository(
      store,
      stores: stores,
      session: FakeSessionRepository(),
      preferences: preferences,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('periode terakhir disimpan per cabang di perangkat (F1-16f)', () async {
    expect(await repo.savedPeriod(), isNull);
    final range = ReportPeriod.custom(
      DateTime.utc(2026, 11, 1),
      DateTime.utc(2026, 11, 15),
    );
    await repo.savePeriod(range);
    expect(await repo.savedPeriod(), range);
    await repo.savePeriod(ReportPeriod.thisMonth);
    expect(await repo.savedPeriod(), ReportPeriod.thisMonth);
    final key = 'reports.period.${ctx.tenant.id.uuid}.${ctx.outlet.id.uuid}';
    expect(await preferences.get(key), '{"kind":"thisMonth"}');

    // JSON rusak dibaca sebagai belum ada.
    await preferences.set(key, '{rusak');
    expect(await repo.savedPeriod(), isNull);
    await preferences.set(key, '{"kind":"month","year":2026}');
    expect(await repo.savedPeriod(), isNull);
  });

  test('tanpa toko: tidak membaca dan tidak menyimpan', () async {
    final empty = LocalReportsRepository(
      store,
      stores: LocalStoreRepository(
        store,
        hasher: const CredentialHasher.forTesting(),
        platform: DevicePlatform.linux,
      ),
      session: FakeSessionRepository(),
      preferences: preferences,
    );
    await empty.savePeriod(ReportPeriod.last7Days);
    expect(await empty.savedPeriod(), isNull);
    expect(await repo.savedPeriod(), isNull);
  });
}
