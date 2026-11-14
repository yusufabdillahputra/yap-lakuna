import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/catalog_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_catalog_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_session_repository.dart';

SetupInput _input() => SetupInput(
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
);

T _ok<T>(Result<T> result) => (result as Ok<T>).value;
Exception _err<T>(Result<T> result) => (result as Error<T>).error;

const _kopi = ProductDraft(
  name: 'Kopi Sachet',
  category: 'Minuman',
  baseUnit: 'sachet',
  variants: [
    VariantDraft(
      sku: 'KOP-SCH',
      costPrice: Money(1500),
      sellPrice: Money(2000),
      minStock: Qty(20000),
      openingStock: Qty(2000),
    ),
  ],
);

void main() {
  late Directory dir;
  late LakunaStore store;
  late StoreContext ctx;
  late FakeSessionRepository session;
  late LocalCatalogRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_catalog_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    ctx = _ok(await stores.setup(_input()));
    session = FakeSessionRepository()
      ..current = StaffProfile(
        id: ctx.owner.id,
        name: ctx.owner.name,
        roleKey: 'owner',
        isOwner: true,
        hasPin: true,
        permissions: Permission.values.toSet(),
      );
    repo = LocalCatalogRepository(store, stores: stores, session: session);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('simpan lalu muat katalog dan satu produk', () async {
    final id = _ok(await repo.save(_kopi));
    final catalog = _ok(await repo.loadCatalog());
    expect(catalog.products.single.name, 'Kopi Sachet');
    expect(catalog.products.single.isLowStock, isTrue);
    expect(catalog.categories.single.name, 'Minuman');
    expect(catalog.units.single.name, 'sachet');
    expect(
      _ok(await repo.loadProduct(id))!.variants.single.stock,
      Qty.units(2),
    );
  });

  test('galat data diteruskan sebagai Result.error', () async {
    _ok(await repo.save(_kopi));
    expect(
      _err(await repo.save(_kopi)),
      isA<ProductCodesTaken>().having(
        (e) => e.conflicts.single.takenBy,
        'takenBy',
        'Kopi Sachet',
      ),
    );
  });

  test('tanpa izin products:manage ditolak', () async {
    session.current = staffWithPermissions({Permission.salesCreate});
    expect(
      _err(await repo.loadCatalog()),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.productsManage,
      ),
    );
    expect(_err(await repo.save(_kopi)), isA<NotPermitted>());
    expect(_err(await repo.importRows(const [])), isA<NotPermitted>());
    session.current = null;
    expect(_err(await repo.loadCatalog()), isA<NotPermitted>());
  });

  test('import produk dengan perbarui harga (F1-07k)', () async {
    _ok(await repo.save(_kopi));
    final rows = productImportRows([
      ['nama', 'harga jual'],
      ['kopi sachet', '2500'],
    ]).rows;
    final summary = _ok(await repo.importRows(rows, updateExisting: true));
    expect(summary.updated, 1);
    final catalog = _ok(await repo.loadCatalog());
    expect(
      catalog.products.single.variants.single.sellPrice,
      const Money(2500),
    );
  });

  test('pratinjau import tidak menyimpan (F1-07m)', () async {
    _ok(await repo.save(_kopi));
    final rows = productImportRows([
      ['nama', 'harga jual'],
      ['kopi sachet', '2500'],
      ['Gula Aren', '18000'],
    ]).rows;
    final summary = _ok(
      await repo.importRows(rows, updateExisting: true, dryRun: true),
    );
    expect(summary.updated, 1);
    expect(summary.created, 1);
    expect(summary.changes.single.newSell, const Money(2500));
    final catalog = _ok(await repo.loadCatalog());
    expect(catalog.products, hasLength(1));
    expect(
      catalog.products.single.variants.single.sellPrice,
      isNot(const Money(2500)),
    );
  });

  test('import produk: baru disimpan, yang sudah ada dilewati', () async {
    _ok(await repo.save(_kopi));
    final rows = productImportRows([
      ['nama', 'harga jual', 'stok'],
      ['kopi sachet', '2000', '5'],
      ['Gula Aren', '18000', '3'],
    ]).rows;
    final summary = _ok(await repo.importRows(rows));
    expect(summary.created, 1);
    expect(summary.skippedLines, [2]);
    final catalog = _ok(await repo.loadCatalog());
    expect(
      catalog.products.map((p) => p.name),
      unorderedEquals(['Kopi Sachet', 'Gula Aren']),
    );
  });
}
