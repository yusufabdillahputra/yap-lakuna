import 'dart:io';
import 'dart:typed_data';

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
    repo = LocalCashierRepository(
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
        payments: const [SalePaymentRequest.cash(Money(10000))],
      ),
    );
    expect(result.sale.number, startsWith('PST-K01-'));
    expect(result.sale.total, 6000);
    expect(result.payments.single.changeAmount, 4000);
    expect(result.negativeStock.single.onHand, Qty.units(-1));
  });

  test('galat checkout diteruskan sebagai Result.error', () async {
    final kopi = _ok(await repo.load()).products.single.variants.single;
    expect(
      _err(
        await repo.checkout(
          lines: [SaleLineRequest(variantId: kopi.id, quantity: Qty.one)],
          payments: const [SalePaymentRequest.cash(Money(2000))],
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

  test(
    'QRIS statis aktif ikut termuat; konfirmasi butuh payments:confirm',
    () async {
      var data = _ok(await repo.load());
      expect(data.qris, isNull);
      expect(data.canConfirmPayments, isTrue);

      final image = _png(1080, 1528);
      await saveQrisSettings(
        store,
        CatalogScope.of(ctx),
        staffId: ctx.owner.id,
        settings: const QrisStaticSettings(
          enabled: true,
          merchantName: 'TOKO BU ANI',
          nmid: 'ID1023',
          settlementNote: 'BCA 123',
        ),
        image: QrisImageUpload(bytes: image, fileName: 'qris.png'),
      );
      data = _ok(await repo.load());
      expect(data.qris!.image, image);
      expect(data.qris!.merchantName, 'TOKO BU ANI');
      expect(data.qris!.nmid, 'ID1023');
      expect(data.qris!.settlementNote, 'BCA 123');

      await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: ctx.owner.id,
        openingCash: const Money(100000),
      );
      final kopi = data.products.single.variants.single;
      final lines = [SaleLineRequest(variantId: kopi.id, quantity: Qty.one)];
      const qris = SalePaymentRequest(
        method: PaymentMethod.qrisStatic,
        confirmed: true,
      );

      session.current = staffWithPermissions({Permission.salesCreate});
      expect(_ok(await repo.load()).canConfirmPayments, isFalse);
      expect(
        _err(await repo.checkout(lines: lines, payments: const [qris])),
        isA<NotPermitted>().having(
          (e) => e.permission,
          'permission',
          Permission.paymentsConfirm,
        ),
      );

      // Staf nyata (FK nota) dengan izin kasir bawaan.
      session.current = StaffProfile(
        id: ctx.owner.id,
        name: 'Ani',
        roleKey: 'cashier',
        isOwner: false,
        hasPin: true,
        permissions: DefaultRole.cashier.permissions,
      );
      final r = await repo.checkout(lines: lines, payments: const [qris]);
      if (r is Error<CheckoutResult>) fail('${r.error}');
      expect(_ok(r).payments.single.confirmedBy, session.current!.id);
    },
  );

  test(
    'diskon dengan penyetuju: PIN harus baru diperiksa, lalu habis',
    () async {
      await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: ctx.owner.id,
        openingCash: const Money(100000),
      );
      final kopi = _ok(await repo.load()).products.single.variants.single;
      final manager = StaffProfile(
        id: ctx.owner.id,
        name: 'Ani',
        roleKey: 'owner',
        isOwner: true,
        hasPin: true,
        permissions: Permission.values.toSet(),
      );
      session
        ..staff = [manager]
        ..current = StaffProfile(
          id: ctx.owner.id,
          name: 'Ani',
          roleKey: 'cashier',
          isOwner: false,
          hasPin: true,
          permissions: DefaultRole.cashier.permissions,
        );
      var now = DateTime.utc(2026, 11, 4, 9);
      session.approvalClock = () => now;
      const discount = ManualDiscount.percent(BasisPoints(1000));
      Future<Result<CheckoutResult>> pay(Money cash) => repo.checkout(
        lines: [SaleLineRequest(variantId: kopi.id, quantity: Qty.units(2))],
        payments: [SalePaymentRequest.cash(cash)],
        discount: discount,
        discountApproverId: manager.id,
      );

      // Id penyetuju tanpa PIN ditolak.
      expect(
        _err(await pay(const Money(10000))),
        isA<NotPermitted>().having(
          (e) => e.permission,
          'permission',
          Permission.salesDiscount,
        ),
      );

      // Persetujuan diskon berlaku 30 menit.
      _ok(
        await session.verifyApprover(
          manager.id,
          '123456',
          Permission.salesDiscount,
        ),
      );
      now = now.add(const Duration(minutes: 29));
      expect(session.hasApproval(manager.id, Permission.salesDiscount), isTrue);

      // Checkout gagal (uang kurang) tidak menghabiskan persetujuan.
      expect(await pay(const Money(1000)), isA<Error<CheckoutResult>>());
      expect(session.hasApproval(manager.id, Permission.salesDiscount), isTrue);

      final sale = _ok(await pay(const Money(10000))).sale;
      expect(sale.total, 3600);
      expect(
        session.hasApproval(manager.id, Permission.salesDiscount),
        isFalse,
      );

      // Kedaluwarsa setelah 30 menit.
      _ok(
        await session.verifyApprover(
          manager.id,
          '123456',
          Permission.salesDiscount,
        ),
      );
      now = now.add(const Duration(minutes: 31));
      expect(
        session.hasApproval(manager.id, Permission.salesDiscount),
        isFalse,
      );
    },
  );
}

Uint8List _png(int w, int h) {
  int b(int v, int s) => (v >> s) & 0xFF;
  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, //
    b(w, 24), b(w, 16), b(w, 8), b(w, 0), //
    b(h, 24), b(h, 16), b(h, 8), b(h, 0), //
    8, 6, 0, 0, 0, 0, 0, 0, 0, 0,
  ]);
}
