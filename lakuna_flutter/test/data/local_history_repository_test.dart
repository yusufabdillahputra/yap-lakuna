import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/history_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_history_repository.dart';
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
  late LocalHistoryRepository repo;
  late StaffProfile owner;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_history_');
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
    repo = LocalHistoryRepository(
      store,
      stores: stores,
      session: session,
      preferences: LocalPreferences(store.session),
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

  Future<CheckoutResult> sell() async {
    final scope = CatalogScope.of(ctx);
    final product = (await listProducts(store, scope)).single;
    return checkoutSale(
      store,
      scope,
      staffId: ctx.owner.id,
      lines: [
        SaleLineRequest(
          variantId: product.variants.single.id,
          quantity: Qty.units(2),
        ),
      ],
      payments: const [SalePaymentRequest.cash(Money(10000))],
    );
  }

  Future<void> openSession() => openCashSession(
    store,
    CashScope.of(ctx),
    staffId: ctx.owner.id,
    openingCash: const Money(100000),
  );

  test('muat: staf, struk, izin, sesi terbuka', () async {
    var data = _ok(await repo.load());
    expect(data.staff.map((s) => s.name), ['Ani']);
    expect(data.businessName, 'Toko Bu Ani');
    expect(data.timezone, 'Asia/Jakarta');
    expect(data.canReturn, isTrue);
    expect(data.canVoid, isTrue);
    expect(data.hasOpenSession, isFalse);
    await openSession();
    data = _ok(await repo.load());
    expect(data.hasOpenSession, isTrue);
  });

  test('daftar, rincian, retur tunai, lalu void ditolak', () async {
    await openSession();
    final sale = await sell();
    final page = _ok(await repo.list(const HistoryFilter()));
    expect(page.rows.single.sale.id, sale.sale.id);
    final detail = _ok(await repo.detail(sale.sale.id));
    expect(detail.voidBlock, isNull);
    final returned = _ok(
      await repo.returnSale(
        saleId: sale.sale.id,
        lines: [
          ReturnLine(saleItemId: sale.items.single.id, quantity: Qty.one),
        ],
        reason: SaleReturnReason.wrongItem,
        refundMethod: RefundMethod.cash,
        restock: true,
      ),
    );
    expect(returned.amount, 2000);
    expect(returned.number, startsWith('RT-PST-K01-'));
    expect(
      _err(await repo.voidSale(saleId: sale.sale.id, reason: 'Salah')),
      isA<SaleVoidInvalid>(),
    );
  });

  test('izin: lihat, retur, dan void tanpa penyetuju', () async {
    await openSession();
    final sale = await sell();
    session.current = staffWithPermissions({Permission.productsManage});
    expect(_err(await repo.load()), isA<NotPermitted>());

    session.current = staffWithPermissions({Permission.reportsView});
    expect(_ok(await repo.list(const HistoryFilter())).rows, hasLength(1));
    expect(
      _err(
        await repo.returnSale(
          saleId: sale.sale.id,
          lines: [
            ReturnLine(saleItemId: sale.items.single.id, quantity: Qty.one),
          ],
          reason: SaleReturnReason.damaged,
          refundMethod: RefundMethod.transfer,
          restock: false,
        ),
      ),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.salesReturn,
      ),
    );
    expect(
      _err(await repo.voidSale(saleId: sale.sale.id, reason: 'Salah')),
      isA<NotPermitted>(),
    );
  });

  test('void dengan penyetuju butuh persetujuan PIN sekali pakai', () async {
    await openSession();
    final sale = await sell();
    final other = await sell();
    session.current = staffWithPermissions({Permission.salesCreate});
    // Tanpa PIN penyetuju: approverId saja tidak cukup.
    expect(
      _err(
        await repo.voidSale(
          saleId: sale.sale.id,
          reason: 'Salah input',
          approverId: owner.id,
        ),
      ),
      isA<NotPermitted>(),
    );
    _ok(await session.verifyApprover(owner.id, '123456', Permission.salesVoid));
    // Alasan ditolak tidak menghabiskan persetujuan.
    expect(
      _err(
        await repo.voidSale(
          saleId: sale.sale.id,
          reason: ' ',
          approverId: owner.id,
        ),
      ),
      isA<SaleVoidInvalid>(),
    );
    final voided = _ok(
      await repo.voidSale(
        saleId: sale.sale.id,
        reason: 'Salah input',
        approverId: owner.id,
      ),
    );
    expect(voided.status, SaleStatus.voided);
    expect(voided.voidedBy, owner.id);
    // Persetujuan sudah terpakai.
    expect(
      _err(
        await repo.voidSale(
          saleId: other.sale.id,
          reason: 'Salah input',
          approverId: owner.id,
        ),
      ),
      isA<NotPermitted>(),
    );
  });
}
