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

    test('0 + UPC-A sama dengan UPC-A yang sudah dipakai (F1-07h)', () async {
      await save(
        const ProductDraft(
          name: 'Sereal',
          baseUnit: 'pcs',
          variants: [VariantDraft(name: '', barcode: '036000291452')],
        ),
      );
      await expectLater(
        save(
          const ProductDraft(
            name: 'Sereal Impor',
            baseUnit: 'pcs',
            variants: [VariantDraft(name: '', barcode: '0036000291452')],
          ),
        ),
        throwsA(
          isA<ProductCodesTaken>().having(
            (e) => e.conflicts.map((c) => (c.issue.field, c.takenBy)),
            'conflicts',
            [(ProductField.variantBarcode, 'Sereal')],
          ),
        ),
      );
      final summary = await importProducts(
        store,
        scope,
        staffId: ctx.owner.id,
        rows: productImportRows([
          ['nama', 'barcode', 'harga jual'],
          ['Sereal Lain', '0036000291452', '30000'],
        ]).rows,
      );
      expect(summary.skippedLines, [2]);
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

    test(
      'toDraft(barcodes) hanya mengubah barcode varian itu (F1-07j)',
      () async {
        final id = await save(
          ProductDraft(
            name: 'Roti',
            baseUnit: 'pcs',
            isActive: false,
            variants: [
              ..._minyak().variants,
              VariantDraft(
                name: 'Kecil',
                sellPrice: const Money(5000),
                openingStock: Qty.units(3),
              ),
            ],
          ),
        );
        final loaded = (await loadProduct(store, scope, id))!;
        final kecil = loaded.variants.firstWhere((v) => v.name == 'Kecil');
        final movements = await StockMovement.db.count(store.session);
        final before = (await outboxTables()).length;
        now = now.add(const Duration(minutes: 1));
        await save(loaded.toDraft(barcodes: {kecil.id: '2000000000008'}));
        final after = (await loadProduct(store, scope, id))!;
        expect(
          after.variants.firstWhere((v) => v.name == 'Kecil').barcode,
          '2000000000008',
        );
        final besar = after.variants.firstWhere((v) => v.name == '2 L');
        final besarBefore = loaded.variants.firstWhere((v) => v.name == '2 L');
        expect(besar.barcode, besarBefore.barcode);
        expect(besar.units.single.barcode, '8991234500031');
        expect(besar.tiers, hasLength(besarBefore.tiers.length));
        expect(after.isActive, isFalse);
        expect(await StockMovement.db.count(store.session), movements);
        expect((await outboxTables()).skip(before), ['product_variants']);
      },
    );

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

  group('import produk (F1-07b)', () {
    List<ProductImportRow> rows(List<List<String>> body) => productImportRows([
      ['nama', 'kategori', 'satuan', 'sku', 'barcode', 'harga jual', 'stok'],
      ...body,
    ]).rows;

    Future<ProductImportSummary> run(List<ProductImportRow> r) =>
        importProducts(store, scope, staffId: ctx.owner.id, rows: r);

    test('produk baru, kategori dipakai ulang, stok awal di ledger', () async {
      await save(_minyak());
      final summary = await run(
        rows([
          ['Gula Pasir 1 kg', 'sembako', 'kg', 'GLA', '', '17500', '40'],
          ['Teh Botol', 'Minuman', '', '', '8990001', '5000', '1,5'],
        ]),
      );
      expect(summary.created, 2);
      expect(summary.skippedLines, isEmpty);
      final list = await listProducts(store, scope);
      final gula = list.firstWhere((p) => p.name == 'Gula Pasir 1 kg');
      final minyak = list.firstWhere((p) => p.name == 'Minyak Goreng');
      expect(gula.categoryId, minyak.categoryId);
      expect(gula.baseUnit, 'kg');
      expect(gula.variants.single.sku, 'GLA');
      expect(gula.variants.single.sellPrice, const Money(17500));
      expect(gula.variants.single.stock, Qty.units(40));
      final teh = list.firstWhere((p) => p.name == 'Teh Botol');
      expect(teh.baseUnit, 'pcs');
      expect(teh.variants.single.stock, const Qty(1500));
      final moves = await StockMovement.db.find(
        store.session,
        where: (m) => m.sourceType.equals(StockSourceType.opening),
      );
      expect(moves, hasLength(3));
    });

    test('nama, SKU, atau barcode yang sudah ada dilewati; import ulang '
        'idempoten', () async {
      await save(_minyak());
      final file = rows([
        ['minyak  goreng', '', '', '', '', '36000', ''],
        ['Minyak Curah', '', '', 'myk-2l', '', '15000', ''],
        ['Minyak Dus', '', '', '', '8991234500031', '210000', ''],
        ['Kecap Manis', '', 'botol', '', '', '9000', '12'],
      ]);
      final first = await run(file);
      expect(first.created, 1);
      expect(first.skippedLines, [2, 3, 4]);
      final again = await run(file);
      expect(again.created, 0);
      expect(again.skippedLines, [2, 3, 4, 5]);
      final list = await listProducts(store, scope);
      expect(
        list.map((p) => p.name),
        unorderedEquals(['Minyak Goreng', 'Kecap Manis']),
      );
      final kecap = list.firstWhere((p) => p.name == 'Kecap Manis');
      expect(kecap.variants.single.stock, Qty.units(12));
    });

    test('draf tidak sah membatalkan seluruh import', () async {
      final bad = ProductImportRow(
        line: 2,
        draft: const ProductDraft(
          name: '',
          baseUnit: 'pcs',
          variants: [VariantDraft()],
        ),
      );
      await expectLater(
        run([
          ...rows([
            ['Kopi', '', '', '', '', '2000', ''],
          ]),
          bad,
        ]),
        throwsA(isA<ProductInputInvalid>()),
      );
      expect(await listProducts(store, scope), isEmpty);
    });
  });

  group('perbarui harga lewat import (F1-07k)', () {
    List<ProductImportRow> rows(List<List<String>> body) => productImportRows([
      [
        'nama',
        'sku',
        'barcode',
        'harga beli',
        'harga jual',
        'stok',
        'stok minimum',
      ],
      ...body,
    ]).rows;

    Future<ProductImportSummary> run(
      List<ProductImportRow> r, {
      bool update = true,
    }) => importProducts(
      store,
      scope,
      staffId: ctx.owner.id,
      rows: r,
      updateExisting: update,
    );

    Future<CatalogVariant> variantOf(String name) async => (await listProducts(
      store,
      scope,
    )).firstWhere((p) => p.name == name).variants.single;

    test('cocok SKU: harga jual & beli diperbarui, isian kosong dan stok '
        'awal diabaikan', () async {
      await save(_minyak());
      now = now.add(const Duration(minutes: 1));
      final summary = await run(
        rows([
          ['Nama Lain', 'myk-2l', '', '33.000', '38000', '99', ''],
        ]),
      );
      expect(summary.created, 0);
      expect(summary.updated, 1);
      expect(summary.unchanged, 0);
      expect(summary.skippedLines, isEmpty);
      final v = await variantOf('Minyak Goreng');
      expect(v.sellPrice, const Money(38000));
      expect(v.costPrice, const Money(33000));
      expect(v.minStock, Qty.units(12));
      expect(v.stock, Qty.units(24));
      expect(v.units.single.sellPrice, const Money(210000));
    });

    test(
      'cocok barcode (UPC-A dibaca 13 digit) dan nama satu varian',
      () async {
        await save(
          const ProductDraft(
            name: 'Sereal Impor',
            baseUnit: 'pcs',
            variants: [
              VariantDraft(
                barcode: '036000291452',
                costPrice: Money(30000),
                sellPrice: Money(40000),
              ),
            ],
          ),
        );
        await save(_minyak());
        final summary = await run(
          rows([
            ['Sereal', '', '0036000291452', '', '41000', '', ''],
            ['minyak  goreng', '', '', '', '37000', '', '10'],
          ]),
        );
        expect(summary.updated, 2);
        final sereal = await variantOf('Sereal Impor');
        expect(sereal.sellPrice, const Money(41000));
        expect(sereal.costPrice, const Money(30000));
        final minyak = await variantOf('Minyak Goreng');
        expect(minyak.sellPrice, const Money(37000));
        expect(minyak.minStock, Qty.units(10));
        expect(minyak.costPrice, const Money(32500));
      },
    );

    test('kecocokan ragu dilewati, baris lain tetap', () async {
      await save(_minyak());
      await save(
        const ProductDraft(
          name: 'Sereal Impor',
          baseUnit: 'pcs',
          variants: [
            VariantDraft(barcode: '036000291452', sellPrice: Money(40000)),
          ],
        ),
      );
      await save(
        const ProductDraft(
          name: 'Kaos',
          baseUnit: 'pcs',
          variants: [
            VariantDraft(name: 'S', sellPrice: Money(50000)),
            VariantDraft(name: 'M', sellPrice: Money(50000)),
          ],
        ),
      );
      final summary = await run(
        rows([
          // SKU dan barcode menunjuk varian berbeda.
          ['X', 'MYK-2L', '036000291452', '', '1000', '', ''],
          // Barcode satuan dus.
          ['Dus', '', '8991234500031', '', '1000', '', ''],
          // Nama dengan dua varian.
          ['Kaos', '', '', '', '1000', '', ''],
          // Kode tidak cocok tetapi nama sudah dipakai.
          ['Minyak Goreng', 'LAIN', '', '', '1000', '', ''],
          ['Teh Baru', '', '', '', '4000', '', ''],
        ]),
      );
      expect(summary.skippedLines, [2, 3, 4, 5]);
      expect(summary.updated, 0);
      expect(summary.created, 1);
      expect((await variantOf('Minyak Goreng')).sellPrice, const Money(36000));
      expect((await variantOf('Sereal Impor')).sellPrice, const Money(40000));
    });

    test('nilai sama: tidak berubah dan tidak menulis outbox', () async {
      await save(_minyak());
      final before = await SyncOutboxEntry.db.count(store.session);
      final summary = await run(
        rows([
          ['Minyak Goreng', 'MYK-2L', '', '32500', '36000', '', '12'],
        ]),
      );
      expect(summary.updated, 0);
      expect(summary.unchanged, 1);
      expect(await SyncOutboxEntry.db.count(store.session), before);
    });

    test('perubahan tercatat di outbox dengan versi naik', () async {
      await save(_minyak());
      final before = (await SyncOutboxEntry.db.find(store.session)).length;
      await run(
        rows([
          ['Minyak Goreng', 'MYK-2L', '', '', '39000', '', ''],
        ]),
      );
      final entries = await SyncOutboxEntry.db.find(store.session);
      expect(entries.skip(before).map((e) => e.entity), ['product_variants']);
      final row = (await ProductVariant.db.find(store.session)).single;
      expect(row.version, 2);
      expect(row.sellPrice, 39000);
    });

    test('sakelar mati: perilaku lama (dilewati)', () async {
      await save(_minyak());
      final summary = await run(
        rows([
          ['Minyak Goreng', 'MYK-2L', '', '', '39000', '', ''],
        ]),
        update: false,
      );
      expect(summary.updated, 0);
      expect(summary.skippedLines, [2]);
      expect((await variantOf('Minyak Goreng')).sellPrice, const Money(36000));
    });

    test('varian yang sama di dua baris hanya diperbarui sekali', () async {
      await save(_minyak());
      final summary = await run(
        rows([
          ['Minyak Lain', 'MYK-2L', '', '', '39000', '', ''],
          ['Minyak Goreng', '', '', '', '40000', '', ''],
        ]),
      );
      expect(summary.updated, 1);
      expect(summary.skippedLines, [3]);
      expect((await variantOf('Minyak Goreng')).sellPrice, const Money(39000));
    });

    test('kode lain bertentangan: dilewati', () async {
      await save(_minyak());
      final summary = await run(
        rows([
          // SKU cocok, tetapi barcode berbeda dari barcode varian itu.
          ['Minyak Goreng', 'MYK-2L', '8990000000017', '', '1000', '', ''],
        ]),
      );
      expect(summary.skippedLines, [2]);
      expect(summary.updated, 0);
      expect((await variantOf('Minyak Goreng')).sellPrice, const Money(36000));
    });

    test('produk banyak varian: hanya varian ber-SKU itu', () async {
      await save(
        const ProductDraft(
          name: 'Kaos',
          baseUnit: 'pcs',
          variants: [
            VariantDraft(name: 'S', sku: 'KAOS-S', sellPrice: Money(50000)),
            VariantDraft(name: 'M', sku: 'KAOS-M', sellPrice: Money(50000)),
          ],
        ),
      );
      final summary = await run(
        rows([
          ['Kaos', 'kaos-m', '', '', '55000', '', ''],
        ]),
      );
      expect(summary.updated, 1);
      final kaos = (await listProducts(
        store,
        scope,
      )).firstWhere((p) => p.name == 'Kaos');
      expect(
        {for (final v in kaos.variants) v.name: v.sellPrice},
        {'S': const Money(50000), 'M': const Money(55000)},
      );
    });

    test(
      'kode kembar di data lama: dilewati, tidak memilih salah satu',
      () async {
        await save(_minyak());
        final teh = await save(
          const ProductDraft(
            name: 'Teh',
            baseUnit: 'pcs',
            variants: [VariantDraft(sku: 'TEH', sellPrice: Money(4000))],
          ),
        );
        // Data lama: dua varian ber-SKU sama (tanpa cek aplikasi).
        final row = (await ProductVariant.db.find(
          store.session,
          where: (v) => v.productId.equals(teh),
        )).single;
        await ProductVariant.db.updateRow(
          store.session,
          row.copyWith(sku: 'MYK-2L'),
        );
        final summary = await run(
          rows([
            ['Apa Saja', 'MYK-2L', '', '', '1000', '', ''],
          ]),
        );
        expect(summary.skippedLines, [2]);
        expect((await variantOf('Teh')).sellPrice, const Money(4000));
        expect(
          (await variantOf('Minyak Goreng')).sellPrice,
          const Money(36000),
        );
      },
    );

    test('produk diarsipkan tidak diperbarui', () async {
      final id = await save(_minyak());
      await archiveProduct(store, scope, staffId: ctx.owner.id, productId: id);
      await run(
        rows([
          ['Minyak Goreng', 'MYK-2L', '', '', '1000', '', ''],
        ]),
      );
      final archived = await ProductVariant.db.find(
        store.session,
        where: (v) => v.productId.equals(id),
      );
      expect(archived.single.sellPrice, 36000);
    });

    test('baris jenis jasa tidak menimpa stok minimum barang', () async {
      await save(_minyak());
      final table = productImportRows([
        ['nama', 'sku', 'jenis', 'harga jual', 'stok minimum'],
        ['Minyak Goreng', 'MYK-2L', 'jasa', '37000', '3'],
      ]).rows;
      final summary = await run(table);
      expect(summary.updated, 1);
      final v = await variantOf('Minyak Goreng');
      expect(v.sellPrice, const Money(37000));
      expect(v.minStock, Qty.units(12));
    });

    test('stok minimum tidak diisi untuk jasa', () async {
      await save(
        const ProductDraft(
          name: 'Jasa Antar',
          baseUnit: 'kali',
          kind: ProductKind.service,
          variants: [VariantDraft(sku: 'ANTAR', sellPrice: Money(5000))],
        ),
      );
      final summary = await run(
        rows([
          ['Jasa Antar', 'ANTAR', '', '', '6000', '', '5'],
        ]),
      );
      expect(summary.updated, 1);
      final v = await variantOf('Jasa Antar');
      expect(v.sellPrice, const Money(6000));
      expect(v.minStock, Qty.zero);
    });
  });

  group('pratinjau perubahan harga import (F1-07m)', () {
    List<ProductImportRow> rows(List<List<String>> body) => productImportRows([
      [
        'nama',
        'sku',
        'barcode',
        'harga beli',
        'harga jual',
        'stok',
        'stok minimum',
      ],
      ...body,
    ]).rows;

    Future<ProductImportSummary> run(
      List<ProductImportRow> r, {
      bool dryRun = false,
    }) => importProducts(
      store,
      scope,
      staffId: ctx.owner.id,
      rows: r,
      updateExisting: true,
      dryRun: dryRun,
    );

    Future<void> seed() async {
      await save(_minyak());
      await save(
        const ProductDraft(
          name: 'Kaos',
          baseUnit: 'pcs',
          variants: [
            VariantDraft(name: 'S', sku: 'KAOS-S', sellPrice: Money(50000)),
            VariantDraft(name: 'M', sku: 'KAOS-M', sellPrice: Money(50000)),
          ],
        ),
      );
    }

    List<ProductImportRow> file() => rows([
      // Harga jual dan beli berubah, stok minimum sama.
      ['Minyak Goreng', 'MYK-2L', '', '33000', '38000', '', '12'],
      // Varian M: harga jual sama, stok minimum berubah. Nama di berkas
      // berbeda karena nama kembar dalam satu berkas ditolak.
      ['Kaos M', 'KAOS-M', '', '', '50000', '', '5'],
      // Varian S: tidak berubah.
      ['Kaos S', 'KAOS-S', '', '', '50000', '', ''],
      // Produk baru dengan stok awal.
      ['Teh Baru', 'TEH-BARU', '', '', '4000', '10', ''],
      // Nama ragu (dua varian): dilewati.
      ['Kaos', '', '', '', '1000', '', ''],
    ]);

    test('dry run tidak menulis apa pun', () async {
      await seed();
      final products = await Product.db.count(store.session);
      final outbox = await SyncOutboxEntry.db.count(store.session);
      final moves = await StockMovement.db.count(store.session);
      final hlc = await store.syncState(SyncStateKey.lastHlc);
      final variants = await ProductVariant.db.find(store.session);
      now = now.add(const Duration(minutes: 1));
      await run(file(), dryRun: true);
      expect(await Product.db.count(store.session), products);
      expect(await SyncOutboxEntry.db.count(store.session), outbox);
      expect(await StockMovement.db.count(store.session), moves);
      expect(await store.syncState(SyncStateKey.lastHlc), hlc);
      final after = await ProductVariant.db.find(store.session);
      expect(
        {for (final v in after) v.id: (v.version, v.sellPrice, v.costPrice)},
        {for (final v in variants) v.id: (v.version, v.sellPrice, v.costPrice)},
      );
    });

    test('hitungan dry run sama dengan import sungguhan', () async {
      await seed();
      final preview = await run(file(), dryRun: true);
      final real = await run(file());
      for (final s in [preview, real]) {
        expect(s.created, 1);
        expect(s.updated, 2);
        expect(s.unchanged, 1);
        expect(s.skippedLines, [6]);
      }
      List<Object?> flat(ProductPriceChange c) => [
        c.line,
        c.productName,
        c.variantName,
        c.oldSell,
        c.newSell,
        c.oldCost,
        c.newCost,
        c.oldMinStock,
        c.newMinStock,
        c.unit,
      ];
      expect(preview.changes.map(flat), real.changes.map(flat));
      expect(real.changes, hasLength(2));
    });

    test('daftar perubahan: harga lama/baru, beli dan stok minimum hanya '
        'bila berubah', () async {
      await seed();
      final s = await run(file(), dryRun: true);
      expect(s.changes, hasLength(2));
      final minyak = s.changes.first;
      expect(minyak.line, 2);
      expect(minyak.productName, 'Minyak Goreng');
      expect(minyak.variantName, '2 L');
      expect(minyak.oldSell, const Money(36000));
      expect(minyak.newSell, const Money(38000));
      expect(minyak.oldCost, const Money(32500));
      expect(minyak.newCost, const Money(33000));
      expect(minyak.oldMinStock, isNull);
      expect(minyak.newMinStock, isNull);
      final kaos = s.changes.last;
      expect(kaos.line, 3);
      expect(kaos.productName, 'Kaos');
      expect(kaos.variantName, 'M');
      expect(kaos.oldSell, const Money(50000));
      expect(kaos.newSell, const Money(50000));
      expect(kaos.oldCost, isNull);
      expect(kaos.newCost, isNull);
      expect(kaos.oldMinStock, Qty.zero);
      expect(kaos.newMinStock, Qty.units(5));
      expect(kaos.unit, 'pcs');
    });

    test(
      'dry run tanpa sakelar perbarui hanya menghitung produk baru',
      () async {
        await seed();
        final s = await importProducts(
          store,
          scope,
          staffId: ctx.owner.id,
          rows: file(),
          dryRun: true,
        );
        expect(s.created, 1);
        expect(s.skippedLines, [2, 3, 4, 6]);
        expect(s.changes, isEmpty);
        expect(await Product.db.count(store.session), 2);
      },
    );
  });
}
