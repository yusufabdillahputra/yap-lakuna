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
  late DateTime now;

  Future<UuidValue> product(
    String name, {
    String category = '',
    String baseUnit = 'pcs',
    List<UnitDraft> units = const [],
  }) => saveProduct(
    store,
    scope,
    staffId: ctx.owner.id,
    draft: ProductDraft(
      name: name,
      category: category,
      baseUnit: baseUnit,
      variants: [VariantDraft(sellPrice: const Money(1000), units: units)],
    ),
  );

  Future<ProductCategory> create(CategoryDraft draft) =>
      createCategory(store, scope, staffId: ctx.owner.id, draft: draft);

  Future<List<String>> names() async => [
    for (final r in await categoryRows(store, scope)) r.category.name,
  ];

  setUp(() async {
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  group('kategori', () {
    test('buat: induk, warna, saklar, urutan di akhir, outbox', () async {
      await product('Beras 5 kg', category: 'Sembako');
      final before = await SyncOutboxEntry.db.count(store.session);
      final minuman = await create(
        CategoryDraft(name: ' Minuman ', color: categoryColors[1]),
      );
      final kopi = await create(
        CategoryDraft(
          name: 'Kopi',
          parentId: minuman.id.uuid,
          showInCashier: false,
        ),
      );
      expect(await SyncOutboxEntry.db.count(store.session) - before, 2);
      expect(minuman.name, 'Minuman');
      expect(minuman.color, categoryColors[1]);
      expect(minuman.isActive, isTrue);
      expect(minuman.showInCashier, isTrue);
      expect(kopi.parentId, minuman.id);
      expect(kopi.showInCashier, isFalse);
      expect(kopi.createdBy, ctx.owner.id);

      final rows = await categoryRows(store, scope);
      expect(rows.map((r) => r.category.name), ['Sembako', 'Minuman', 'Kopi']);
      expect(rows.map((r) => r.productCount), [1, 0, 0]);
      expect(rows[2].parentName, 'Minuman');
    });

    test('validasi ditolak dengan semua galat', () async {
      await create(const CategoryDraft(name: 'Sembako'));
      await expectLater(
        create(const CategoryDraft(name: 'sembako', color: '#000000')),
        throwsA(
          isA<CategoryInvalid>().having((e) => e.errors, 'errors', [
            CategoryError.nameDuplicate,
            CategoryError.colorInvalid,
          ]),
        ),
      );
      expect(await names(), ['Sembako']);
    });

    test('ubah: nama, induk, warna, saklar; versi naik', () async {
      final a = await create(const CategoryDraft(name: 'Minuman'));
      final b = await create(const CategoryDraft(name: 'Kopi'));
      now = now.add(const Duration(minutes: 5));
      final updated = await updateCategory(
        store,
        scope,
        staffId: ctx.owner.id,
        id: b.id,
        draft: CategoryDraft(
          name: 'Kopi susu',
          parentId: a.id.uuid,
          color: categoryColors[2],
          showInCashier: false,
          isActive: false,
        ),
      );
      expect(updated.name, 'Kopi susu');
      expect(updated.parentId, a.id);
      expect(updated.color, categoryColors[2]);
      expect(updated.isActive, isFalse);
      expect(updated.showInCashier, isFalse);
      expect(updated.version, b.version + 1);
      expect(updated.updatedAt, now);
      // Induk yang punya subkategori tidak boleh diberi induk.
      await expectLater(
        updateCategory(
          store,
          scope,
          staffId: ctx.owner.id,
          id: a.id,
          draft: CategoryDraft(name: 'Minuman', parentId: b.id.uuid),
        ),
        throwsA(isA<CategoryInvalid>()),
      );
    });

    test('ubah kategori tenant lain atau terhapus: tidak ditemukan', () async {
      await expectLater(
        updateCategory(
          store,
          scope,
          staffId: ctx.owner.id,
          id: UuidValue.fromString(newId()),
          draft: const CategoryDraft(name: 'X'),
        ),
        throwsA(isA<MasterNotFound>()),
      );
    });

    test('induk bisa dikosongkan lagi', () async {
      final a = await create(const CategoryDraft(name: 'Minuman'));
      final b = await create(CategoryDraft(name: 'Kopi', parentId: a.id.uuid));
      final cleared = await updateCategory(
        store,
        scope,
        staffId: ctx.owner.id,
        id: b.id,
        draft: const CategoryDraft(name: 'Kopi'),
      );
      expect(cleared.parentId, isNull);
      expect(
        (await ProductCategory.db.findById(store.session, b.id))!.parentId,
        isNull,
      );
    });

    test(
      'form produk memakai ulang kategori nonaktif, urutan max + 1',
      () async {
        final rokok = await create(
          const CategoryDraft(name: 'Rokok', isActive: false),
        );
        await create(const CategoryDraft(name: 'Snack'));
        // Hapus kategori di tengah membuat jumlah baris < sort_order terbesar.
        final tengah = await create(const CategoryDraft(name: 'Tengah'));
        await create(const CategoryDraft(name: 'Akhir'));
        await deleteCategory(
          store,
          scope,
          staffId: ctx.owner.id,
          id: tengah.id,
        );
        await product('Kretek', category: 'rokok');
        await product('Roti tawar', category: 'Roti');
        final rows = await categoryRows(store, scope);
        final reused = rows.firstWhere((r) => r.category.id == rokok.id);
        expect(reused.productCount, 1);
        expect(reused.category.isActive, isFalse);
        final roti = rows.firstWhere((r) => r.category.name == 'Roti');
        expect(roti.category.sortOrder, 4);
        expect(rows.last.category.name, 'Roti');
      },
    );

    test('saklar aktif saja', () async {
      final a = await create(const CategoryDraft(name: 'Rokok'));
      final off = await setCategoryActive(
        store,
        scope,
        staffId: ctx.owner.id,
        id: a.id,
        active: false,
      );
      expect(off.isActive, isFalse);
      expect(off.name, 'Rokok');
    });

    test('naik/turun menomori ulang semua kategori', () async {
      // Form produk membuat kategori dengan sort_order kembar bila
      // dihapus di tengah; penomoran ulang membereskannya.
      await create(const CategoryDraft(name: 'A'));
      final b = await create(const CategoryDraft(name: 'B'));
      final c = await create(const CategoryDraft(name: 'C'));
      await moveCategory(
        store,
        scope,
        staffId: ctx.owner.id,
        id: c.id,
        delta: -1,
      );
      expect(await names(), ['A', 'C', 'B']);
      await moveCategory(
        store,
        scope,
        staffId: ctx.owner.id,
        id: b.id,
        delta: 1,
      );
      expect(await names(), ['A', 'C', 'B']);
      await moveCategory(
        store,
        scope,
        staffId: ctx.owner.id,
        id: c.id,
        delta: -1,
      );
      expect(await names(), ['C', 'A', 'B']);
      final orders = [
        for (final r in await categoryRows(store, scope)) r.category.sortOrder,
      ];
      expect(orders, [0, 1, 2]);
      // Hanya baris yang nomornya berubah yang ditulis ke outbox.
      final before = await SyncOutboxEntry.db.count(store.session);
      await moveCategory(
        store,
        scope,
        staffId: ctx.owner.id,
        id: b.id,
        delta: -1,
      );
      expect(await names(), ['C', 'B', 'A']);
      expect(await SyncOutboxEntry.db.count(store.session) - before, 2);
    });

    test('hapus ditolak bila dipakai produk atau punya subkategori', () async {
      await product('Beras', category: 'Sembako');
      final sembako = (await categoryRows(store, scope)).single.category;
      await expectLater(
        deleteCategory(store, scope, staffId: ctx.owner.id, id: sembako.id),
        throwsA(
          isA<MasterInUse>()
              .having((e) => e.products, 'products', 1)
              .having((e) => e.children, 'children', 0),
        ),
      );
      final minuman = await create(const CategoryDraft(name: 'Minuman'));
      await create(CategoryDraft(name: 'Kopi', parentId: minuman.id.uuid));
      await expectLater(
        deleteCategory(store, scope, staffId: ctx.owner.id, id: minuman.id),
        throwsA(isA<MasterInUse>().having((e) => e.children, 'children', 1)),
      );
      final rokok = await create(const CategoryDraft(name: 'Rokok'));
      await deleteCategory(store, scope, staffId: ctx.owner.id, id: rokok.id);
      expect(await names(), ['Sembako', 'Minuman', 'Kopi']);
      final deleted = await ProductCategory.db.findById(
        store.session,
        rokok.id,
      );
      expect(deleted!.deletedAt, now);
      // Nama yang dihapus boleh dipakai lagi.
      await create(const CategoryDraft(name: 'Rokok'));
    });

    test('kasir: hanya aktif + tampil di kasir dan dipakai produk', () async {
      final minuman = await create(const CategoryDraft(name: 'Minuman'));
      final kopi = await create(
        CategoryDraft(name: 'Kopi', parentId: minuman.id.uuid),
      );
      final teh = await create(
        CategoryDraft(
          name: 'Teh',
          parentId: minuman.id.uuid,
          showInCashier: false,
        ),
      );
      final rokok = await create(
        const CategoryDraft(name: 'Rokok', isActive: false),
      );
      await create(const CategoryDraft(name: 'Kosong'));
      final all = await listCategories(store, scope);
      final shown = cashierCategories(all, {teh.id, kopi.id, rokok.id});
      // Minuman tampil karena subkategorinya dipakai; Teh disembunyikan,
      // Rokok nonaktif, Kosong tanpa produk.
      expect(shown.map((c) => c.name), ['Minuman', 'Kopi']);
    });
  });

  group('satuan', () {
    test('daftar dengan jumlah produk (dasar + konversi)', () async {
      await product(
        'Air 600 ml',
        baseUnit: 'botol',
        units: [UnitDraft(name: 'dus', factor: Qty.units(24))],
      );
      await product('Teh botol', baseUnit: 'Botol');
      await product('Beras', baseUnit: 'kg');
      final rows = await unitRows(store, scope);
      expect(
        {for (final r in rows) r.unit.name: r.productCount},
        {'botol': 2, 'dus': 1, 'kg': 1},
      );
    });

    test('buat, ganti nama, kembar ditolak', () async {
      final before = await SyncOutboxEntry.db.count(store.session);
      final pcs = await createUnit(
        store,
        scope,
        staffId: ctx.owner.id,
        name: ' pcs ',
      );
      expect(pcs.name, 'pcs');
      final dus = await createUnit(
        store,
        scope,
        staffId: ctx.owner.id,
        name: 'dus',
      );
      expect(await SyncOutboxEntry.db.count(store.session) - before, 2);
      await expectLater(
        createUnit(store, scope, staffId: ctx.owner.id, name: 'PCS'),
        throwsA(
          isA<UnitInvalid>().having(
            (e) => e.error,
            'error',
            UnitNameError.duplicate,
          ),
        ),
      );
      final renamed = await renameUnit(
        store,
        scope,
        staffId: ctx.owner.id,
        id: dus.id,
        name: 'Dus',
      );
      expect(renamed.name, 'Dus');
      expect(renamed.version, dus.version + 1);
      await expectLater(
        renameUnit(
          store,
          scope,
          staffId: ctx.owner.id,
          id: dus.id,
          name: 'pcs',
        ),
        throwsA(isA<UnitInvalid>()),
      );
    });

    test('hapus ditolak bila dipakai; yang tidak dipakai terhapus', () async {
      await product(
        'Air',
        baseUnit: 'botol',
        units: [UnitDraft(name: 'dus', factor: Qty.units(24))],
      );
      final rows = await unitRows(store, scope);
      final dus = rows.firstWhere((r) => r.unit.name == 'dus').unit;
      await expectLater(
        deleteUnit(store, scope, staffId: ctx.owner.id, id: dus.id),
        throwsA(isA<MasterInUse>().having((e) => e.products, 'products', 1)),
      );
      final kg = await createUnit(
        store,
        scope,
        staffId: ctx.owner.id,
        name: 'kg',
      );
      await deleteUnit(store, scope, staffId: ctx.owner.id, id: kg.id);
      expect((await unitRows(store, scope)).map((r) => r.unit.name), [
        'botol',
        'dus',
      ]);
      await expectLater(
        deleteUnit(store, scope, staffId: ctx.owner.id, id: kg.id),
        throwsA(isA<MasterNotFound>()),
      );
    });
  });
}
