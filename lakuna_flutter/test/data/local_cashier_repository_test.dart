import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cashier_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_cashier_repository.dart';
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
  late LocalCashierRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_cashier_');
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
    repo = LocalCashierRepository(store, stores: stores, session: session);
    await saveProduct(
      store,
      CatalogScope.of(ctx),
      staffId: ctx.owner.id,
      draft: _kopi,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('muat katalog kasir tanpa sesi, lalu dengan sesi terbuka', () async {
    var data = _ok(await repo.load());
    expect(data.products.single.name, 'Kopi Sachet');
    expect(data.categories.single.name, 'Minuman');
    expect(data.businessName, 'Toko Bu Ani');
    expect(data.outletName, 'Cabang Pusat');
    expect(data.staffName, 'Ani');
    expect(data.timezone, 'Asia/Jakarta');
    expect(data.session, isNull);

    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: ctx.owner.id,
      openingCash: const Money(100000),
    );
    data = _ok(await repo.load());
    expect(data.session?.openedByName, 'Ani');
  });

  test('checkout menulis nota dengan nomor cabang dan perangkat', () async {
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: ctx.owner.id,
      openingCash: const Money(100000),
    );
    final kopi = _ok(await repo.load()).products.single.variants.single;
    final result = _ok(
      await repo.checkout(
        lines: [SaleLineRequest(variantId: kopi.id, quantity: Qty.units(3))],
        payment: const SalePaymentRequest.cash(Money(10000)),
      ),
    );
    expect(result.sale.number, startsWith('PST-K01-'));
    expect(result.sale.total, 6000);
    expect(result.payment.changeAmount, 4000);
    expect(result.negativeStock.single.onHand, Qty.units(-1));
  });

  test('galat checkout diteruskan sebagai Result.error', () async {
    final kopi = _ok(await repo.load()).products.single.variants.single;
    expect(
      _err(
        await repo.checkout(
          lines: [SaleLineRequest(variantId: kopi.id, quantity: Qty.one)],
          payment: const SalePaymentRequest.cash(Money(2000)),
        ),
      ),
      isA<CashSessionNotOpen>(),
    );
  });

  test('tanpa izin sales:create ditolak', () async {
    session.current = staffWithPermissions({Permission.productsManage});
    expect(
      _err(await repo.load()),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.salesCreate,
      ),
    );
    session.current = null;
    expect(_err(await repo.load()), isA<NotPermitted>());
  });
}
