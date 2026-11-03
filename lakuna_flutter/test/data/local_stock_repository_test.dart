import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_stock_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/stock_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../testing/fake_session_repository.dart';

T _ok<T>(Result<T> result) => (result as Ok<T>).value;
Exception _err<T>(Result<T> result) => (result as Error<T>).error;

void main() {
  late Directory dir;
  late LakunaStore store;
  late FakeSessionRepository session;
  late LocalStockRepository repo;
  late UuidValue kopi;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_stock_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    final ctx = _ok(
      await stores.setup(
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
      ),
    );
    session = FakeSessionRepository()
      ..current = StaffProfile(
        id: ctx.owner.id,
        name: ctx.owner.name,
        roleKey: 'owner',
        isOwner: true,
        hasPin: true,
        permissions: Permission.values.toSet(),
      );
    repo = LocalStockRepository(store, stores: stores, session: session);
    final scope = CatalogScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const ProductDraft(
        name: 'Kopi Sachet',
        baseUnit: 'sachet',
        variants: [
          VariantDraft(
            costPrice: Money(1500),
            sellPrice: Money(2000),
            openingStock: Qty(2000),
            minStock: Qty(20000),
          ),
        ],
      ),
    );
    kopi = (await loadProduct(store, scope, id))!.variants.single.id;
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  StaffProfile staff(Set<Permission> permissions) => StaffProfile(
    id: session.current!.id,
    name: 'Budi',
    roleKey: 'stock_keeper',
    isOwner: false,
    hasPin: true,
    permissions: permissions,
  );

  test('pemilik: daftar, simpan penyesuaian, kartu, lokasi', () async {
    final location = _ok(await repo.locations()).single;
    expect(_ok(await repo.stock()).single.stock, const Qty(2000));
    expect(_ok(await repo.belowMinimum()), hasLength(1));
    expect(_ok(await repo.nextAdjustmentNumber()), startsWith('SA-PST-K01-'));
    final saved = _ok(
      await repo.saveAdjustment(
        locationId: location.id,
        reason: StockAdjustmentReason.lost,
        lines: [AdjustmentLine(variantId: kopi, physical: Qty.one)],
      ),
    );
    expect(saved.items.single.differenceMilli, -1000);
    expect(
      _ok(await repo.recentAdjustments()).single.number,
      saved.adjustment.number,
    );
    expect(_ok(await repo.card(variantId: kopi)).current, Qty.one);
    final gudang = _ok(await repo.createLocation('Gudang'));
    expect(
      _ok(await repo.renameLocation(gudang.id, 'Gudang 2')).name,
      'Gudang 2',
    );
    expect(
      _err(await repo.createLocation('gudang 2')),
      isA<StockLocationInvalid>(),
    );
  });

  test('staf dengan products:manage saja bisa melihat tetapi tidak '
      'menyesuaikan', () async {
    session.current = staff({Permission.productsManage});
    expect(await repo.stock(), isA<Ok<List<StockRow>>>());
    final location = _ok(await repo.locations()).single;
    expect(
      _err(
        await repo.saveAdjustment(
          locationId: location.id,
          reason: StockAdjustmentReason.lost,
          lines: [AdjustmentLine(variantId: kopi, physical: Qty.one)],
        ),
      ),
      isA<NotPermitted>(),
    );
    expect(_err(await repo.createLocation('Gudang')), isA<NotPermitted>());
  });

  test('tanpa izin stok/produk: semua ditolak', () async {
    session.current = staff({Permission.salesCreate});
    expect(_err(await repo.stock()), isA<NotPermitted>());
    expect(_err(await repo.locations()), isA<NotPermitted>());
  });
}
