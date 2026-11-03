import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_purchases_repository.dart';
import 'package:lakuna_flutter/data/repositories/purchases_repository.dart';
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
      openingStock: Qty(20000),
    ),
  ],
);

void main() {
  late Directory dir;
  late LakunaStore store;
  late StoreContext ctx;
  late FakeSessionRepository session;
  late LocalPurchasesRepository repo;
  late StaffProfile owner;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_purchases_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    ctx = _ok(await stores.setup(_input()));
    owner = StaffProfile(
      id: ctx.owner.id,
      name: ctx.owner.name,
      roleKey: 'owner',
      isOwner: true,
      hasPin: true,
      permissions: Permission.values.toSet(),
    );
    session = FakeSessionRepository(staff: [owner])..current = owner;
    repo = LocalPurchasesRepository(
      store,
      stores: stores,
      session: session,
    );
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

  test('muat, terima, detail, retur, dan izin', () async {
    final setup = _ok(await repo.load());
    final local = outletLocalTime(DateTime.now().toUtc(), 'Asia/Jakarta');
    expect(setup.today, DateTime(local.year, local.month, local.day));
    expect(setup.timezone, 'Asia/Jakarta');
    expect(setup.nextNumber, startsWith('PB-PST-K01-'));
    expect(setup.products.single.name, 'Kopi Sachet');
    expect(setup.hasOpenSession, isFalse);
    final variant = setup.products.single.variants.single;

    final received = _ok(
      await repo.receive(
        PurchaseRequest(
          purchasedOn: DateTime.utc(2026, 11, 3),
          locationId: setup.locations.first.id,
          newSupplierName: 'UD Makmur',
          lines: [
            PurchaseLineRequest(
              variantId: variant.id,
              quantity: Qty.units(10),
              unitPrice: const Money(1600),
            ),
          ],
          paid: const Money(16000),
          funding: FundingSource.storeCash,
        ),
      ),
    );
    expect(received.number, setup.nextNumber);
    final detail = _ok(await repo.detail(received.id));
    expect(detail.supplier!.name, 'UD Makmur');
    expect(detail.items.single.sellPriceBefore, 2000);
    expect(_ok(await repo.list()).single.debt, Money.zero);

    final ret = _ok(
      await repo.returnPurchase(
        purchaseId: received.id,
        lines: [
          PurchaseReturnLine(
            purchaseItemId: detail.items.single.id,
            quantity: Qty.units(2),
          ),
        ],
        refundSource: FundingSource.bank,
      ),
    );
    expect(ret.refundAmount, 3200);
    expect(
      _ok(await repo.listReturns()).single.purchaseNumber,
      received.number,
    );

    session.current = StaffProfile(
      id: owner.id,
      name: owner.name,
      roleKey: 'cashier',
      isOwner: false,
      hasPin: true,
      permissions: const {Permission.salesCreate},
    );
    expect(_err(await repo.load()), isA<NotPermitted>());
    expect(_err(await repo.list()), isA<NotPermitted>());
  });
}
