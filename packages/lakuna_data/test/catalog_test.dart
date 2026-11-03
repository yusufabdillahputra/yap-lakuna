import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

ProductDraft _minyak({
  String? id,
  String category = 'Sembako',
  String baseUnit = 'botol',
  List<VariantDraft>? variants,
  ProductKind kind = ProductKind.goods,
}) => ProductDraft(
  id: id,
  name: 'Minyak Goreng',
  category: category,
  baseUnit: baseUnit,
  kind: kind,
  sku: 'MYK',
  brand: 'Contoh',
  variants:
      variants ??
      [
        VariantDraft(
          name: '2 L',
          sku: 'MYK-2L',
          barcode: '8991234500024',
          costPrice: const Money(32500),
          sellPrice: const Money(36000),
          minStock: Qty.units(12),
          openingStock: Qty.units(24),
          units: [
            UnitDraft(
              name: 'Dus',
              factor: Qty.units(6),
              barcode: '8991234500031',
              costPrice: const Money(195000),
              sellPrice: const Money(210000),
            ),
          ],
          tiers: [
            PriceTier(minQty: Qty.units(6), price: const Money(35000)),
            PriceTier(minQty: Qty.units(24), price: const Money(34000)),
          ],
        ),
      ],
);

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late DateTime now;
  late CatalogScope scope;

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

  Future<UuidValue> save(ProductDraft draft) =>
      saveProduct(store, scope, staffId: ctx.owner.id, draft: draft);

  Future<List<String>> outboxTables() async {
    final rows = await SyncOutboxEntry.db.find(store.session);
    return rows.map((r) => r.entity).toList();
  }

  group('produk baru', () {
    test(
      'menulis produk, varian, satuan, grosir, stok awal, dan outbox',
      () async {
        final id = await save(_minyak());

        final product = await Product.db.findById(store.session, id);
        expect(product!.name, 'Minyak Goreng');
        expect(product.type, ProductType.goods);
        expect(product.sku, 'MYK');
        expect(product.brand, 'Contoh');
        expect(product.isActive, isTrue);
        expect(product.createdBy, ctx.owner.id);
        expect(product.originDeviceId, store.deviceId);

        final categories = await ProductCategory.db.find(store.session);
        expect(categories.map((c) => c.name), ['Sembako']);
        final units = await MeasureUnit.db.find(store.session);
        expect(units.map((u) => u.name).toSet(), {'botol', 'Dus'});

        final variants = await ProductVariant.db.find(store.session);
        expect(variants.single.sellPrice, 36000);
        expect(variants.single.minStockMilli, 12000);
        final productUnits = await ProductUnit.db.find(store.session);
        expect(productUnits.single.factorMilli, 6000);
        expect(productUnits.single.sellPrice, 210000);
        final tiers = await ProductPriceTier.db.find(store.session);
        expect(tiers.map((t) => t.minQtyMilli).toSet(), {6000, 24000});

        final movements = await StockMovement.db.find(store.session);
        expect(movements.single.quantityMilli, 24000);
        expect(movements.single.unitCost, 32500);
        expect(movements.single.sourceType, StockSourceType.opening);
        expect(movements.single.sourceId, variants.single.id);

        final tables = await outboxTables();
        for (final table in [
          'categories',
          'units',
          'products',
          'product_variants',
          'product_units',
          'price_tiers',
          'stock_movements',
        ]) {
          expect(tables, contains(table));
        }
        expect(tables, isNot(contains('stock_levels')));
      },
    );

    test('listProducts membaca stok dan urut nama tanpa beda huruf', () async {
      await save(_minyak());
      await save(
        ProductDraft(
          name: 'beras Premium',
          baseUnit: 'karung',
          variants: [
            VariantDraft(
              sellPrice: const Money(72500),
              openingStock: Qty.units(3),
              minStock: Qty.units(5),
            ),
          ],
        ),
      );

      final list = await listProducts(store, scope);
      expect(list.map((p) => p.name), ['beras Premium', 'Minyak Goreng']);
      final beras = list.first;
      expect(beras.categoryName, isNull);
      expect(beras.baseUnit, 'karung');
      expect(beras.totalStock, Qty.units(3));
      expect(beras.isLowStock, isTrue);
      final minyak = list.last;
      expect(minyak.categoryName, 'Sembako');
      expect(minyak.isLowStock, isFalse);
      final v = minyak.variants.single;
      expect(v.stock, Qty.units(24));
      expect(v.units.single.name, 'Dus');
      expect(v.units.single.factor, Qty.units(6));
      expect(v.tiers.map((t) => t.minQty), [Qty.units(6), Qty.units(24)]);
    });

    test('kategori dan satuan dipakai ulang tanpa beda huruf', () async {
      await save(_minyak());
      await save(
        ProductDraft(
          name: 'Gula Pasir',
          category: ' sembako ',
          baseUnit: 'BOTOL',
          variants: const [VariantDraft(sellPrice: Money(17500))],
        ),
      );
      expect(await ProductCategory.db.count(store.session), 1);
      expect(await MeasureUnit.db.count(store.session), 2);
      final list = await listProducts(store, scope);
      expect(list.map((p) => p.categoryName), ['Sembako', 'Sembako']);
      expect(list.first.baseUnit, 'botol');
    });

    test('jasa tidak mencatat stok awal', () async {
      await save(
        ProductDraft(
          name: 'Jasa Antar',
          baseUnit: 'kali',
          kind: ProductKind.service,
          variants: [
            VariantDraft(
              sellPrice: const Money(5000),
              openingStock: Qty.units(10),
            ),
          ],
        ),
      );
      expect(await StockMovement.db.count(store.session), 0);
      final item = (await listProducts(store, scope)).single;
      expect(item.kind, ProductKind.service);
      expect(item.isLowStock, isFalse);
    });

    test('draf tidak sah ditolak tanpa menulis apa pun', () async {
      await expectLater(
        save(const ProductDraft(name: '', baseUnit: 'pcs', variants: [])),
        throwsA(
          isA<ProductInputInvalid>().having(
            (e) => e.issues.map((i) => i.field),
            'fields',
            [ProductField.name, ProductField.variants],
          ),
        ),
      );
      expect(await Product.db.count(store.session), 0);
      expect(await outboxTables(), isNot(contains('products')));
    });
  });

  group('kode unik per tenant', () {
    test('SKU dan barcode kembar dengan produk lain ditolak', () async {
      await save(_minyak());
      final before = (await outboxTables()).length;

      await expectLater(
        save(
          ProductDraft(
            name: 'Minyak Lain',
            baseUnit: 'pcs',
            variants: [
              const VariantDraft(name: 'a', sku: 'myk-2l', barcode: '111'),
              VariantDraft(
                name: 'b',
                barcode: '8991234500024',
                units: [
                  UnitDraft(
                    name: 'dus',
                    factor: Qty.units(6),
                    barcode: '8991234500031',
                  ),
                ],
              ),
            ],
          ),
        ),
        throwsA(
          isA<ProductCodesTaken>().having(
            (e) => e.conflicts.map(
              (c) => (c.issue.field, c.issue.variant, c.issue.unit, c.takenBy),
            ),
            'conflicts',
            [
              (ProductField.variantSku, 0, null, 'Minyak Goreng'),
              (ProductField.variantBarcode, 1, null, 'Minyak Goreng'),
              (ProductField.unitBarcode, 1, 0, 'Minyak Goreng'),
            ],
          ),
        ),
      );
      expect((await outboxTables()).length, before);
      expect(await Product.db.count(store.session), 1);
    });

    test('produk sendiri boleh menyimpan ulang kodenya', () async {
      final id = await save(_minyak());
      final draft = (await loadProduct(store, scope, id))!.toDraft();
      await save(draft);
      expect(await Product.db.count(store.session), 1);
    });

    test('kode produk yang sudah dihapus boleh dipakai lagi', () async {
      final id = await save(_minyak());
      final draft = (await loadProduct(store, scope, id))!.toDraft();
      // Varian lama dihapus dan diganti varian baru dengan kode yang sama.
      await save(
        ProductDraft(
          id: draft.id,
          name: draft.name,
          baseUnit: draft.baseUnit,
          variants: const [
            VariantDraft(sku: 'MYK-2L', barcode: '8991234500024'),
          ],
        ),
      );
      final product = (await loadProduct(store, scope, id))!;
      expect(product.variants.single.sku, 'MYK-2L');
    });
  });

  group('ubah produk', () {
    test('perubahan, varian/satuan/grosir baru dan dihapus', () async {
      final id = await save(_minyak());
      final loaded = (await loadProduct(store, scope, id))!;
      final draft = loaded.toDraft();
      final v = draft.variants.single;
      now = now.add(const Duration(minutes: 5));

      await save(
        ProductDraft(
          id: draft.id,
          name: 'Minyak Goreng Sawit',
          category: '',
          baseUnit: draft.baseUnit,
          sku: draft.sku,
          brand: '',
          isActive: false,
          isTaxable: true,
          variants: [
            VariantDraft(
              id: v.id,
              name: '2 L',
              sku: v.sku,
              barcode: v.barcode,
              costPrice: v.costPrice,
              sellPrice: const Money(37000),
              minStock: v.minStock,
              // Stok awal varian lama diabaikan.
              openingStock: Qty.units(99),
              units: const [],
              tiers: [v.tiers.first],
            ),
            VariantDraft(
              name: '1 L',
              sku: 'MYK-1L',
              costPrice: const Money(16800),
              sellPrice: const Money(18500),
              openingStock: Qty.units(10),
            ),
          ],
        ),
      );

      final product = (await loadProduct(store, scope, id))!;
      expect(product.name, 'Minyak Goreng Sawit');
      expect(product.categoryName, isNull);
      expect(product.brand, isNull);
      expect(product.isActive, isFalse);
      expect(product.isTaxable, isTrue);
      expect(product.variants.map((x) => x.name), ['2 L', '1 L']);
      expect(product.variants.first.sellPrice, const Money(37000));
      expect(product.variants.first.units, isEmpty);
      expect(product.variants.first.tiers.single.minQty, Qty.units(6));
      expect(product.variants.first.stock, Qty.units(24));
      expect(product.variants.last.stock, Qty.units(10));

      final row = await Product.db.findById(store.session, id);
      expect(row!.version, 2);
      expect(row.updatedAt, now);

      final deletedUnits = await ProductUnit.db.find(
        store.session,
        where: (u) => u.deletedAt.notEquals(null),
      );
      expect(deletedUnits, hasLength(1));
      final deletedTiers = await ProductPriceTier.db.find(
        store.session,
        where: (t) => t.deletedAt.notEquals(null),
      );
      expect(deletedTiers.single.minQtyMilli, 24000);
      expect(await StockMovement.db.count(store.session), 2);
    });

    test('varian dihapus di-soft-delete, stoknya tetap di ledger', () async {
      final id = await save(
        _minyak(
          variants: [
            VariantDraft(name: '1 L', openingStock: Qty.units(5)),
            VariantDraft(name: '2 L', openingStock: Qty.units(7)),
          ],
        ),
      );
      final draft = (await loadProduct(store, scope, id))!.toDraft();
      await save(
        ProductDraft(
          id: id.uuid,
          name: draft.name,
          baseUnit: draft.baseUnit,
          variants: [draft.variants.last],
        ),
      );
      final product = (await loadProduct(store, scope, id))!;
      expect(product.variants.single.name, '2 L');
      final deleted = await ProductVariant.db.find(
        store.session,
        where: (v) => v.deletedAt.notEquals(null),
      );
      expect(deleted.single.name, '1 L');
      expect(deleted.single.version, 2);
      expect(await StockMovement.db.count(store.session), 2);
    });

    test('menyimpan ulang tanpa perubahan tidak menulis outbox', () async {
      final id = await save(_minyak());
      final before = (await outboxTables()).length;
      await save((await loadProduct(store, scope, id))!.toDraft());
      expect((await outboxTables()).length, before);
    });

    test('produk tidak dikenal ditolak', () async {
      await expectLater(
        save(
          ProductDraft(
            id: newId(),
            name: 'X',
            baseUnit: 'pcs',
            variants: const [VariantDraft()],
          ),
        ),
        throwsA(isA<ProductNotFound>()),
      );
    });
  });

  test('toDraft membawa semua isi produk', () async {
    final id = await save(_minyak());
    final draft = (await loadProduct(store, scope, id))!.toDraft();
    expect(draft.id, id.uuid);
    expect(draft.category, 'Sembako');
    expect(draft.baseUnit, 'botol');
    expect(draft.sku, 'MYK');
    expect(draft.brand, 'Contoh');
    final v = draft.variants.single;
    expect(v.id, isNotNull);
    expect(v.barcode, '8991234500024');
    expect(v.minStock, Qty.units(12));
    expect(v.openingStock, Qty.zero);
    expect(v.units.single.id, isNotNull);
    expect(v.units.single.costPrice, const Money(195000));
    expect(v.tiers.map((t) => t.id), everyElement(isNotNull));
  });

  test('daftar kategori dan satuan urut nama', () async {
    await save(_minyak());
    expect((await listCategories(store, scope)).map((c) => c.name), [
      'Sembako',
    ]);
    expect((await listUnits(store, scope)).map((u) => u.name), [
      'botol',
      'Dus',
    ]);
  });

  test('produk tenant lain tidak terbaca dan kodenya tidak bentrok', () async {
    final other = await store.session.db.insertRow(
      Tenant(name: 'Toko Lain', hlc: 'x'),
    );
    final otherScope = CatalogScope(
      tenantId: other.id,
      outletId: ctx.outlet.id,
      deviceId: store.deviceId,
    );
    await saveProduct(
      store,
      otherScope,
      staffId: ctx.owner.id,
      // Tenant contoh ini tidak punya lokasi stok, jadi tanpa stok awal.
      draft: _minyak(
        variants: const [VariantDraft(sku: 'MYK-2L', barcode: '8991234500024')],
      ),
    );
    expect(await listProducts(store, scope), isEmpty);
    await save(_minyak());
    expect(await listProducts(store, scope), hasLength(1));
    expect(await listCategories(store, scope), hasLength(1));
  });
}
