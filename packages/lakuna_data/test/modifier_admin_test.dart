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

  ModifierGroupDraft size({List<ModifierOptionDraft>? options}) =>
      ModifierGroupDraft(
        name: 'Ukuran',
        minSelect: 1,
        maxSelect: 1,
        options:
            options ??
            const [
              ModifierOptionDraft(name: 'Reguler', isDefault: true),
              ModifierOptionDraft(name: 'Besar', priceDelta: Money(4000)),
            ],
      );

  Future<ModifierGroup> save(ModifierGroupDraft d, {UuidValue? id}) =>
      saveModifierGroup(store, scope, staffId: ctx.owner.id, id: id, draft: d);

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('buat grup + opsi lewat outbox, urutan di akhir', () async {
    final before = await SyncOutboxEntry.db.count(store.session);
    final g = await save(size());
    final topping = await save(
      const ModifierGroupDraft(
        name: ' Topping ',
        minSelect: 0,
        maxSelect: 2,
        options: [
          ModifierOptionDraft(name: 'Boba', priceDelta: Money(5000)),
          ModifierOptionDraft(name: 'Tanpa gula', priceDelta: Money(-1000)),
        ],
      ),
    );
    // 2 grup + 4 opsi.
    expect(await SyncOutboxEntry.db.count(store.session) - before, 6);
    expect(topping.name, 'Topping');
    final rows = await modifierGroupRows(store, scope);
    expect(rows.map((r) => r.name), ['Ukuran', 'Topping']);
    expect(rows.first.id, g.id);
    expect(rows.first.isRequired, isTrue);
    expect(rows.first.options.map((o) => o.name), ['Reguler', 'Besar']);
    expect(rows.first.options.first.isDefault, isTrue);
    expect(rows.last.options.last.priceDelta, -1000);
    expect(rows.last.productCount, 0);
  });

  test('galat validasi: nama kembar, opsi kembar ditandai indeksnya', () async {
    await save(size());
    await expectLater(
      save(size()),
      throwsA(
        isA<ModifierGroupInvalid>().having(
          (e) => e.errors,
          'errors',
          contains(ModifierGroupError.nameDuplicate),
        ),
      ),
    );
    await expectLater(
      save(
        const ModifierGroupDraft(
          name: 'Suhu',
          minSelect: 1,
          maxSelect: 1,
          options: [
            ModifierOptionDraft(name: 'Es'),
            ModifierOptionDraft(name: 'es'),
          ],
        ),
      ),
      throwsA(
        isA<ModifierGroupInvalid>().having(
          (e) => e.optionErrors,
          'optionErrors',
          {1: ModifierGroupError.optionNameDuplicate},
        ),
      ),
    );
  });

  test('ubah: opsi diubah, ditambah, dihapus lunak; habis', () async {
    final g = await save(size());
    final detail = (await modifierGroupRows(store, scope)).single;
    final reguler = detail.options.first;
    await save(
      size(
        options: [
          ModifierOptionDraft(
            id: detail.options.last.id.uuid,
            name: 'Besar',
            priceDelta: const Money(5000),
            isAvailable: false,
          ),
          const ModifierOptionDraft(name: 'Jumbo', priceDelta: Money(8000)),
        ],
      ),
      id: g.id,
    );
    final after = (await modifierGroupRows(store, scope)).single;
    expect(after.options.map((o) => o.name), ['Besar', 'Jumbo']);
    expect(after.options.first.priceDelta, 5000);
    expect(after.options.first.isAvailable, isFalse);
    expect(after.options.first.sortOrder, 0);
    final gone = await ModifierOption.db.findById(store.session, reguler.id);
    expect(gone!.deletedAt, isNotNull);
  });

  test('urutkan dan hapus; dipakai menu ditolak', () async {
    final a = await save(size());
    final b = await save(
      const ModifierGroupDraft(
        name: 'Suhu',
        minSelect: 1,
        maxSelect: 1,
        options: [ModifierOptionDraft(name: 'Es')],
      ),
    );
    await moveModifierGroup(
      store,
      scope,
      staffId: ctx.owner.id,
      id: b.id,
      delta: -1,
    );
    expect((await modifierGroupRows(store, scope)).map((r) => r.name), [
      'Suhu',
      'Ukuran',
    ]);

    await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: ProductDraft(
        name: 'Kopi Susu',
        category: '',
        baseUnit: 'gelas',
        variants: const [VariantDraft(sellPrice: Money(24000))],
        modifierGroupIds: [a.id.uuid],
      ),
    );
    expect(
      (await modifierGroupRows(
        store,
        scope,
      )).firstWhere((r) => r.id == a.id).productCount,
      1,
    );
    await expectLater(
      deleteModifierGroup(store, scope, staffId: ctx.owner.id, id: a.id),
      throwsA(isA<MasterInUse>().having((e) => e.products, 'products', 1)),
    );
    await deleteModifierGroup(store, scope, staffId: ctx.owner.id, id: b.id);
    expect((await modifierGroupRows(store, scope)).map((r) => r.name), [
      'Ukuran',
    ]);
  });

  test('produk: pasang grup berurutan, lepas, grup terhapus ditolak', () async {
    final a = await save(size());
    final b = await save(
      const ModifierGroupDraft(
        name: 'Suhu',
        minSelect: 1,
        maxSelect: 1,
        options: [ModifierOptionDraft(name: 'Es')],
      ),
    );
    ProductDraft draft(List<String> ids, {String? id}) => ProductDraft(
      id: id,
      name: 'Kopi Susu',
      baseUnit: 'gelas',
      variants: const [VariantDraft(sellPrice: Money(24000))],
      modifierGroupIds: ids,
    );
    final id = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: draft([b.id.uuid, a.id.uuid]),
    );
    var p = (await loadProduct(store, scope, id))!;
    expect(p.modifierGroupIds, [b.id, a.id]);
    expect(p.toDraft().modifierGroupIds, [b.id.uuid, a.id.uuid]);
    final menu = await menuModifierGroups(store, scope);
    expect(menu.keys, [id]);
    expect(menu[id]!.map((g) => g.id), [b.id, a.id]);
    expect(menu[id]!.first.options.single.name, 'Es');

    await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: draft([a.id.uuid], id: id.uuid),
    );
    p = (await loadProduct(store, scope, id))!;
    expect(p.modifierGroupIds, [a.id]);
    final links = await ProductModifierGroup.db.find(
      store.session,
      where: (l) => l.productId.equals(id),
    );
    expect(links, hasLength(2));
    final linkB = links.firstWhere((l) => l.modifierGroupId == b.id);
    final linkA = links.firstWhere((l) => l.modifierGroupId == a.id);
    expect(linkB.deletedAt, isNotNull);
    expect(linkA.deletedAt, isNull);
    expect(linkA.sortOrder, 0);

    await deleteModifierGroup(store, scope, staffId: ctx.owner.id, id: b.id);
    await expectLater(
      saveProduct(
        store,
        scope,
        staffId: ctx.owner.id,
        draft: draft([a.id.uuid, b.id.uuid], id: id.uuid),
      ),
      throwsA(isA<ProductInputInvalid>()),
    );
  });
}
