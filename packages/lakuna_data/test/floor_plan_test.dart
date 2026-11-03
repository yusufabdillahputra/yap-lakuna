import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  late DiningArea indoor;

  setUp(() async {
    (store, dir) = await openTempStore(
      clock: () => DateTime.utc(2026, 11, 3, 9),
    );
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    indoor = await createDiningArea(
      store,
      scope,
      staffId: ctx.owner.id,
      name: 'Indoor',
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<List<DiningTable>> tables(List<DiningTableDraft> drafts) =>
      createDiningTables(store, scope, staffId: ctx.owner.id, drafts: drafts);

  Future<void> save(
    List<FloorTableDraft> drafts, {
    DiningLayoutMode mode = DiningLayoutMode.floor,
    List<UuidValue> deleted = const [],
    UuidValue? staffId,
  }) => saveFloorLayout(
    store,
    scope,
    staffId: staffId ?? ctx.owner.id,
    areaId: indoor.id,
    mode: mode,
    tables: drafts,
    deleted: deleted,
  );

  group('gambar denah', () {
    test('PNG disimpan, area jadi mode denah, ukuran dunia', () async {
      final area = await saveFloorImage(
        store,
        scope,
        staffId: ctx.owner.id,
        areaId: indoor.id,
        bytes: pngBytes(1600, 1200),
        fileName: 'denah.png',
      );
      expect(area.layoutMode, DiningLayoutMode.floor);
      expect(area.floorMediaId, isNotNull);
      final image = (await loadFloorImage(store, scope, area))!;
      expect(image.media.kind, MediaKind.floorPlan);
      expect(image.bytes, isNotNull);
      expect(image.world, (width: 800, height: 600));
      final all = await floorImages(store, scope, [area]);
      expect(all.keys, [area.id]);
    });

    test('SVG diterima, format lain dan > 5 MB ditolak', () async {
      final svg = Uint8List.fromList(
        utf8.encode('<svg viewBox="0 0 1200 900" xmlns="x"></svg>'),
      );
      final area = await saveFloorImage(
        store,
        scope,
        staffId: ctx.owner.id,
        areaId: indoor.id,
        bytes: svg,
        fileName: 'denah.svg',
      );
      final image = (await loadFloorImage(store, scope, area))!;
      expect(image.media.mimeType, 'image/svg+xml');
      expect(image.world, (width: 800, height: 600));

      await expectLater(
        saveFloorImage(
          store,
          scope,
          staffId: ctx.owner.id,
          areaId: indoor.id,
          bytes: Uint8List.fromList('GIF89a......'.codeUnits),
          fileName: 'a.gif',
        ),
        throwsA(
          isA<FloorImageInvalid>().having(
            (e) => e.error,
            'error',
            FloorImageError.format,
          ),
        ),
      );
      await expectLater(
        saveFloorImage(
          store,
          scope,
          staffId: ctx.owner.id,
          areaId: indoor.id,
          bytes: Uint8List(FloorLimits.imageBytes + 1),
          fileName: 'besar.png',
        ),
        throwsA(
          isA<FloorImageInvalid>().having(
            (e) => e.error,
            'error',
            FloorImageError.tooLarge,
          ),
        ),
      );
    });
  });

  group('simpan tata letak', () {
    test(
      'meja lama diperbarui, meja baru dibuat, tanpa area masuk area',
      () async {
        final [m1, loose] = await tables([
          DiningTableDraft(name: 'M1', areaId: indoor.id),
          const DiningTableDraft(name: 'Bar 1', seats: 1),
        ]);
        await save([
          FloorTableDraft(
            id: m1.id,
            name: 'M1',
            seats: 2,
            shape: TableShape.round,
            x: 100,
            y: 120,
            width: 60,
            height: 60,
          ),
          FloorTableDraft(
            id: loose.id,
            name: 'Bar 1',
            seats: 1,
            shape: TableShape.bar,
            x: 300,
            y: 40,
            width: 40,
            height: 40,
          ),
          const FloorTableDraft(
            name: 'M2',
            seats: 6,
            shape: TableShape.long,
            x: 200,
            y: 400,
            width: 80,
            height: 140,
            canMerge: true,
          ),
        ]);
        final area = (await diningAreas(
          store,
          scope,
        )).singleWhere((a) => a.id == indoor.id);
        expect(area.layoutMode, DiningLayoutMode.floor);
        final all = await diningTables(store, scope);
        expect(
          all.map(
            (t) => (
              t.name,
              t.diningAreaId == indoor.id,
              t.shape,
              t.seats,
              t.posX,
              t.posY,
              t.width,
              t.height,
              t.canMerge,
            ),
          ),
          [
            ('M1', true, TableShape.round, 2, 100, 120, 60, 60, false),
            ('Bar 1', true, TableShape.bar, 1, 300, 40, 40, 40, false),
            ('M2', true, TableShape.long, 6, 200, 400, 80, 140, true),
          ],
        );
      },
    );

    test(
      'nama unik termasuk antar draf; isian di luar batas ditolak',
      () async {
        await tables([const DiningTableDraft(name: 'Teras 1')]);
        await expectLater(
          save([
            const FloorTableDraft(name: 'M1', x: 0, y: 0),
            const FloorTableDraft(name: 'm1', x: 100, y: 0),
          ]),
          throwsA(
            isA<DiningNameInvalid>()
                .having((e) => e.error, 'error', DiningNameError.duplicate)
                .having((e) => e.index, 'index', 1),
          ),
        );
        await expectLater(
          save([const FloorTableDraft(name: 'teras 1', x: 0, y: 0)]),
          throwsA(isA<DiningNameInvalid>()),
        );
        await expectLater(
          save([const FloorTableDraft(name: 'M1', width: 601, x: 0, y: 0)]),
          throwsA(
            isA<FloorTableInvalid>().having(
              (e) => e.error,
              'error',
              FloorTableError.size,
            ),
          ),
        );
        await expectLater(
          save([const FloorTableDraft(name: 'M1', x: 5001, y: 0)]),
          throwsA(
            isA<FloorTableInvalid>().having(
              (e) => e.error,
              'error',
              FloorTableError.position,
            ),
          ),
        );
        // Tidak ada yang tersimpan.
        expect((await diningTables(store, scope)).map((t) => t.name), [
          'Teras 1',
        ]);
      },
    );

    test('ganti nama dua meja saling tukar dalam satu simpan', () async {
      final [a, b] = await tables([
        DiningTableDraft(name: 'M1', areaId: indoor.id),
        DiningTableDraft(name: 'M2', areaId: indoor.id),
      ]);
      await save([
        FloorTableDraft(id: a.id, name: 'M2', x: 0, y: 0),
        FloorTableDraft(id: b.id, name: 'M1', x: 100, y: 0),
      ]);
      final all = await diningTables(store, scope);
      expect(all.firstWhere((t) => t.id == a.id).name, 'M2');
    });

    test('hapus meja; ditolak bila punya bill terbuka', () async {
      final [m1, m2] = await tables([
        DiningTableDraft(name: 'M1', areaId: indoor.id),
        DiningTableDraft(name: 'M2', areaId: indoor.id),
      ]);
      await openTableBill(
        store,
        scope,
        staffId: ctx.owner.id,
        tableId: m2.id,
        guests: 2,
      );
      await expectLater(
        save(const [], deleted: [m2.id]),
        throwsA(isA<DiningInUse>().having((e) => e.openBill, 'open', true)),
      );
      await save(const [], deleted: [m1.id]);
      expect((await diningTables(store, scope)).map((t) => t.name), ['M2']);
    });

    test('mode grid tetap menyimpan posisi', () async {
      final [m1] = await tables([
        DiningTableDraft(name: 'M1', areaId: indoor.id),
      ]);
      await save([
        FloorTableDraft(id: m1.id, name: 'M1', x: 40, y: 60),
      ], mode: DiningLayoutMode.grid);
      final area = (await diningAreas(store, scope)).single;
      expect(area.layoutMode, DiningLayoutMode.grid);
      expect((await diningTables(store, scope)).single.posX, 40);
    });

    test('area lain atau tidak ada: DiningNotFound', () async {
      await expectLater(
        saveFloorLayout(
          store,
          scope,
          staffId: ctx.owner.id,
          areaId: UuidValue.fromString(newId()),
          mode: DiningLayoutMode.floor,
          tables: const [],
        ),
        throwsA(isA<DiningNotFound>()),
      );
    });
  });

  test('pindah area di Master melepas posisi denah', () async {
    final teras = await createDiningArea(
      store,
      scope,
      staffId: ctx.owner.id,
      name: 'Teras',
    );
    final [m1] = await tables([
      DiningTableDraft(name: 'M1', areaId: indoor.id),
    ]);
    await save([FloorTableDraft(id: m1.id, name: 'M1', x: 40, y: 60)]);
    await updateDiningTable(
      store,
      scope,
      staffId: ctx.owner.id,
      id: m1.id,
      draft: DiningTableDraft(name: 'M1', areaId: indoor.id, seats: 6),
    );
    expect((await diningTables(store, scope)).single.posX, 40);
    await updateDiningTable(
      store,
      scope,
      staffId: ctx.owner.id,
      id: m1.id,
      draft: DiningTableDraft(name: 'M1', areaId: teras.id),
    );
    final t = (await diningTables(store, scope)).single;
    expect((t.posX, t.posY), (null, null));
  });
}
