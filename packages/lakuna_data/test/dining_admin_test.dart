import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;

  setUp(() async {
    (store, dir) = await openTempStore(
      clock: () => DateTime.utc(2026, 11, 3, 9),
    );
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<DiningArea> area(String name) =>
      createDiningArea(store, scope, staffId: ctx.owner.id, name: name);

  Future<List<DiningTable>> tables(List<DiningTableDraft> drafts) =>
      createDiningTables(store, scope, staffId: ctx.owner.id, drafts: drafts);

  group('area', () {
    test('buat, ganti nama, urutkan, hapus ditolak bila punya meja', () async {
      final indoor = await area(' Indoor ');
      final teras = await area('Teras');
      expect(indoor.name, 'Indoor');
      expect([indoor.sortOrder, teras.sortOrder], [0, 1]);
      await expectLater(
        area('indoor'),
        throwsA(
          isA<DiningNameInvalid>().having(
            (e) => e.error,
            'error',
            DiningNameError.duplicate,
          ),
        ),
      );

      await renameDiningArea(
        store,
        scope,
        staffId: ctx.owner.id,
        id: teras.id,
        name: 'Teras depan',
      );
      await moveDiningArea(
        store,
        scope,
        staffId: ctx.owner.id,
        id: teras.id,
        delta: -1,
      );
      expect((await diningAreas(store, scope)).map((a) => a.name), [
        'Teras depan',
        'Indoor',
      ]);

      await tables([DiningTableDraft(name: 'M1', areaId: indoor.id)]);
      await expectLater(
        deleteDiningArea(store, scope, staffId: ctx.owner.id, id: indoor.id),
        throwsA(isA<DiningInUse>().having((e) => e.tables, 'tables', 1)),
      );
      await deleteDiningArea(store, scope, staffId: ctx.owner.id, id: teras.id);
      expect((await diningAreas(store, scope)).map((a) => a.name), ['Indoor']);
    });
  });

  group('meja', () {
    test('tambah beberapa sekaligus, nama unik, kursi 1..99', () async {
      final before = await SyncOutboxEntry.db.count(store.session);
      final created = await tables([
        for (final n in tableRange('M', 1, 3)!) DiningTableDraft(name: n),
      ]);
      expect(created.map((t) => t.sortOrder), [0, 1, 2]);
      expect(await SyncOutboxEntry.db.count(store.session) - before, 3);

      await expectLater(
        tables(const [
          DiningTableDraft(name: 'M4'),
          DiningTableDraft(name: 'm2'),
        ]),
        throwsA(
          isA<DiningNameInvalid>()
              .having((e) => e.index, 'index', 1)
              .having((e) => e.error, 'error', DiningNameError.duplicate),
        ),
      );
      // Satu transaksi: M4 tidak ikut tersimpan.
      expect(await diningTables(store, scope), hasLength(3));
      await expectLater(
        tables(const [DiningTableDraft(name: 'M4', seats: 0)]),
        throwsA(isA<DiningSeatsInvalid>()),
      );
      await expectLater(
        tables(const [DiningTableDraft(name: 'M4', seats: 100)]),
        throwsA(isA<DiningSeatsInvalid>()),
      );
      await expectLater(
        tables([DiningTableDraft(name: 'M4', areaId: fakeUuid())]),
        throwsA(isA<DiningNotFound>()),
      );
    });

    test('ubah, urutkan, hapus ditolak bila ada bill terbuka', () async {
      final indoor = await area('Indoor');
      final [m1, m2] = await tables(const [
        DiningTableDraft(name: 'M1'),
        DiningTableDraft(name: 'M2', seats: 2),
      ]);
      final updated = await updateDiningTable(
        store,
        scope,
        staffId: ctx.owner.id,
        id: m2.id,
        draft: DiningTableDraft(name: 'Bar 1', areaId: indoor.id, seats: 1),
      );
      expect(updated.diningAreaId, indoor.id);
      expect(updated.seats, 1);
      expect(updated.version, 2);
      await moveDiningTable(
        store,
        scope,
        staffId: ctx.owner.id,
        id: updated.id,
        delta: -1,
      );
      expect((await diningTables(store, scope)).map((t) => t.name), [
        'Bar 1',
        'M1',
      ]);

      await openTableBill(
        store,
        scope,
        staffId: ctx.owner.id,
        tableId: m1.id,
        guests: 2,
      );
      await expectLater(
        deleteDiningTable(store, scope, staffId: ctx.owner.id, id: m1.id),
        throwsA(isA<DiningInUse>().having((e) => e.openBill, 'open', true)),
      );
      await deleteDiningTable(
        store,
        scope,
        staffId: ctx.owner.id,
        id: updated.id,
      );
      expect((await diningTables(store, scope)).map((t) => t.name), ['M1']);
    });
  });

  group('tarif', () {
    test('bawaan 0; simpan per cabang; tidak sah ditolak', () async {
      var rates = await loadFnbRates(store.session, scope);
      expect(rates.service, BasisPoints.zero);
      expect(rates.tax, BasisPoints.zero);

      rates = await saveFnbRates(
        store,
        scope,
        staffId: ctx.owner.id,
        rates: const FnbRates(
          service: BasisPoints(500),
          tax: BasisPoints(1000),
        ),
      );
      expect(rates.service, const BasisPoints(500));
      expect(rates.tax, const BasisPoints(1000));

      final before = await SyncOutboxEntry.db.count(store.session);
      await saveFnbRates(
        store,
        scope,
        staffId: ctx.owner.id,
        rates: const FnbRates(
          service: BasisPoints(500),
          tax: BasisPoints(1100),
        ),
      );
      // Hanya tarif yang berubah ditulis.
      expect(await SyncOutboxEntry.db.count(store.session) - before, 1);

      await expectLater(
        saveFnbRates(
          store,
          scope,
          staffId: ctx.owner.id,
          rates: const FnbRates(service: BasisPoints(3100)),
        ),
        throwsA(
          isA<FnbRatesInvalid>()
              .having((e) => e.service, 'service', true)
              .having((e) => e.tax, 'tax', false),
        ),
      );
      expect(
        (await loadFnbRates(store.session, scope)).tax,
        const BasisPoints(1100),
      );
    });
  });
}

UuidValue fakeUuid() =>
    UuidValue.fromString('01900000-0000-7000-8000-000000000999');
