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
  late DateTime now;

  Future<UuidValue> product(String name) => saveProduct(
    store,
    scope,
    staffId: ctx.owner.id,
    draft: ProductDraft(
      name: name,
      baseUnit: 'pcs',
      variants: const [
        VariantDraft(
          costPrice: Money(1000),
          sellPrice: Money(1500),
          openingStock: Qty(5000),
        ),
      ],
    ),
  );

  Future<List<SyncOutboxEntry>> outbox() =>
      SyncOutboxEntry.db.find(store.session, orderBy: (e) => e.id);

  /// Semua baris tabel sync di perangkat: (tabel, id).
  Future<Set<(String, String)>> allRows() async {
    final out = <(String, String)>{};
    for (final t in syncTables) {
      final rows = await store.session.db.unsafeQuery(
        'SELECT id FROM "${t.name}"',
      );
      for (final r in rows) {
        final id = r.first;
        out.add((
          t.name,
          id is List<int>
              ? UuidValue.fromByteList(Uint8List.fromList(id)).uuid
              : '$id',
        ));
      }
    }
    return out;
  }

  setUp(() async {
    now = DateTime.utc(2026, 11, 28, 5);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test(
    'outbox lama dipadatkan: satu entri per baris, urut dependensi',
    () async {
      final id = await product('Teh');
      now = now.add(const Duration(seconds: 1));
      await archiveProduct(store, scope, staffId: ctx.owner.id, productId: id);
      now = now.add(const Duration(seconds: 1));
      await restoreProduct(store, scope, staffId: ctx.owner.id, productId: id);
      final before = await outbox();
      expect(before.where((e) => e.rowId == id), hasLength(greaterThan(1)));

      await prepareInitialUpload(store, serverNow: now);

      final entries = await outbox();
      final keys = [for (final e in entries) (e.entity, e.rowId.uuid)];
      expect(keys.toSet(), hasLength(keys.length), reason: 'tanpa entri ganda');
      expect(keys.toSet(), await allRows());
      int first(String table) => keys.indexWhere((k) => k.$1 == table);
      expect(first('tenants'), lessThan(first('outlets')));
      expect(first('outlets'), lessThan(first('products')));
      expect(first('products'), lessThan(first('product_variants')));
      expect(first('product_variants'), lessThan(first('stock_movements')));
      for (final e in entries) {
        final payload = jsonDecode(e.payloadJson) as Map<String, dynamic>;
        expect(payload['hlc'], e.hlc);
        expect(payload['id'], e.rowId.uuid);
        expect(e.status, OutboxStatus.pending);
      }
      final latest = await Product.db.findById(store.session, id);
      expect(entries.firstWhere((e) => e.rowId == id).hlc, latest!.hlc);
      expect(await store.syncState(SyncStateKey.initialUpload), 'done');
    },
  );

  test('kategori induk dikirim sebelum anaknya', () async {
    final anak = await createCategory(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const CategoryDraft(name: 'Teh'),
    );
    final induk = await createCategory(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const CategoryDraft(name: 'Minuman'),
    );
    await updateCategory(
      store,
      scope,
      staffId: ctx.owner.id,
      id: anak.id,
      draft: CategoryDraft(name: 'Teh', parentId: induk.id.uuid),
    );
    await prepareInitialUpload(store, serverNow: now);
    final ids = [
      for (final e in await outbox())
        if (e.entity == 'categories') e.rowId,
    ];
    expect(ids.indexOf(induk.id), lessThan(ids.indexOf(anak.id)));
  });

  test(
    'pemadatan terputus lalu dilanjutkan: tanpa baris terlewat atau ganda',
    () async {
      for (var i = 0; i < 7; i++) {
        await product('Produk $i');
      }
      var chunks = 0;
      await expectLater(
        prepareInitialUpload(
          store,
          serverNow: now,
          chunkSize: 3,
          afterChunk: () async {
            if (++chunks == 4) throw StateError('aplikasi ditutup');
          },
        ),
        throwsStateError,
      );
      expect(await store.syncState(SyncStateKey.initialUpload), 'pending');
      // Tulisan baru di sela pemadatan masuk outbox seperti biasa.
      final late = await product('Produk baru');
      await prepareInitialUpload(store, serverNow: now, chunkSize: 3);

      final keys = [for (final e in await outbox()) (e.entity, e.rowId.uuid)];
      final snapshot = keys.toSet();
      expect(snapshot, await allRows());
      final products = [
        for (final k in keys)
          if (k.$1 == 'products') k.$2,
      ];
      expect(products.where((p) => p == late.uuid), hasLength(2));
      expect(products.toSet(), hasLength(products.length - 1));
    },
  );

  test('sudah selesai: dipanggil lagi tidak mengubah outbox', () async {
    await prepareInitialUpload(store, serverNow: now);
    final before = await outbox();
    await prepareInitialUpload(store, serverNow: now);
    expect((await outbox()).length, before.length);
  });

  test(
    'HLC perangkat jauh di depan server: snapshot distempel ulang',
    () async {
      now = DateTime.utc(2026, 11, 29, 5);
      await product('Kopi');
      final serverNow = DateTime.utc(2026, 11, 28, 5);
      final limit = serverNow.add(const Duration(minutes: 5));
      await prepareInitialUpload(store, serverNow: serverNow);

      final entries = await outbox();
      expect(entries, isNotEmpty);
      final hlcs = <String>{};
      for (final e in entries) {
        final h = Hlc.parse(e.hlc);
        expect(h.millis, lessThanOrEqualTo(limit.millisecondsSinceEpoch));
        expect(h.node, store.deviceId.uuid);
        expect(jsonDecode(e.payloadJson)['hlc'], e.hlc);
        hlcs.add(e.hlc);
      }
      expect(hlcs, hasLength(entries.length));
      final row = await Product.db.findFirstRow(store.session);
      expect(entries.map((e) => e.hlc), contains(row!.hlc));
      final last = Hlc.parse((await store.syncState(SyncStateKey.lastHlc))!);
      expect(last.millis, lessThanOrEqualTo(limit.millisecondsSinceEpoch));
    },
  );

  test('progres per kelompok menghitung entri acked', () async {
    await product('Teh');
    await prepareInitialUpload(store, serverNow: now);
    var progress = await initialUploadProgress(store);
    final catalog = progress.firstWhere((g) => g.group == UploadGroup.catalog);
    expect(catalog.total, greaterThan(0));
    expect(catalog.acked, 0);
    final products = await SyncOutboxEntry.db.find(
      store.session,
      where: (e) => e.entity.equals('products'),
    );
    await SyncOutboxEntry.db.update(store.session, [
      for (final e in products) e.copyWith(status: OutboxStatus.acked),
    ]);
    progress = await initialUploadProgress(store);
    expect(
      progress.firstWhere((g) => g.group == UploadGroup.catalog).acked,
      products.length,
    );
    expect(
      progress.map((g) => g.group),
      containsAll([UploadGroup.store, UploadGroup.stock]),
    );
  });

  test('setiap tabel syncTables punya model perangkat bernama sama', () {
    for (final t in syncTables) {
      expect(syncRowType(t.name)?.tableName, t.name, reason: t.name);
    }
    expect(syncRowType('sync_outbox'), isNull);
    expect(syncRowType('stock_levels'), isNull);
  });
}
