import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

SetupInput _input({String outletCode = 'pst', String pin = '123456'}) =>
    SetupInput(
      businessType: BusinessKind.fnb,
      businessName: 'Warung Contoh',
      outletName: 'Cabang Pusat',
      outletCode: outletCode,
      deviceCode: 'k01',
      timezone: 'Asia/Makassar',
      ownerName: 'Yusuf',
      email: 'Yusuf@Contoh.id',
      password: 'rahasia123',
      passwordConfirm: 'rahasia123',
      pin: pin,
      pinConfirm: pin,
    );

const _credentials = SetupCredentials(
  pinHash: r'$argon2id$pin',
  passwordHash: r'$argon2id$password',
);

void main() {
  late LakunaStore store;
  late Directory dir;

  setUp(() async {
    (store, dir) = await openTempStore();
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<StoreContext> setup([SetupInput? input, ProductDraft? firstProduct]) =>
      setupStore(
        store,
        input ?? _input(),
        platform: DevicePlatform.linux,
        credentials: _credentials,
        firstProduct: firstProduct,
      );

  test('sebelum setup tidak ada konteks toko', () async {
    expect(await loadStoreContext(store), isNull);
  });

  test(
    'setup membuat tenant, cabang, perangkat, etalase, dan pemilik',
    () async {
      final ctx = await setup();

      expect(ctx.tenant.name, 'Warung Contoh');
      expect(ctx.tenant.businessType, BusinessType.fnb);
      expect(ctx.tenant.timezone, 'Asia/Makassar');
      expect(ctx.outlet.code, 'PST');
      expect(ctx.outlet.name, 'Cabang Pusat');
      expect(ctx.outlet.timezone, 'Asia/Makassar');
      expect(ctx.device.id, store.deviceId);
      expect(ctx.device.code, 'K01');
      expect(ctx.device.platform, DevicePlatform.linux);
      expect(ctx.owner.isOwner, isTrue);
      expect(ctx.owner.email, 'yusuf@contoh.id');
      expect(ctx.owner.pinHash, _credentials.pinHash);
      expect(ctx.owner.passwordHash, _credentials.passwordHash);

      final location = await StockLocation.db.findFirstRow(store.session);
      expect(location!.name, 'Etalase');
      expect(location.isDefault, isTrue);
      expect(location.outletId, ctx.outlet.id);

      final member = await OutletMember.db.findFirstRow(store.session);
      expect(member!.staffMemberId, ctx.owner.id);
      expect(member.outletId, ctx.outlet.id);
      expect(member.roleName, DefaultRole.owner.key);
    },
  );

  test('semua baris tercatat di outbox dengan aktor pemilik', () async {
    final ctx = await setup();
    final outbox = await SyncOutboxEntry.db.find(store.session);
    expect(outbox.map((e) => e.entity).toSet(), {
      'tenants',
      'outlets',
      'devices',
      'stock_locations',
      'staff_members',
      'outlet_members',
    });
    expect(outbox, hasLength(6));
    final hlc = ctx.tenant.hlc;
    expect(outbox.map((e) => e.hlc).toSet(), {hlc});
    expect(ctx.outlet.hlc, hlc);
    expect(ctx.device.hlc, hlc);
    expect(ctx.owner.originDeviceId, store.deviceId);
    expect(ctx.outlet.createdBy, ctx.owner.id);
    expect(ctx.tenant.createdBy, ctx.owner.id);
    expect(ctx.owner.createdBy, ctx.owner.id);
  });

  test('konteks toko bisa dimuat ulang setelah setup', () async {
    final ctx = await setup();
    final loaded = await loadStoreContext(store);
    expect(loaded!.tenant.id, ctx.tenant.id);
    expect(loaded.outlet.id, ctx.outlet.id);
    expect(loaded.device.code, 'K01');
    expect(loaded.owner.id, ctx.owner.id);
  });

  test('setup kedua ditolak dan tidak menulis apa pun', () async {
    await setup();
    final before = await SyncOutboxEntry.db.count(store.session);
    await expectLater(setup(), throwsA(isA<SetupAlreadyDone>()));
    expect(await Tenant.db.count(store.session), 1);
    expect(await SyncOutboxEntry.db.count(store.session), before);
  });

  test('input tidak valid ditolak sebelum menulis', () async {
    await expectLater(
      setup(_input(outletCode: 'P')),
      throwsA(isA<SetupInvalid>()),
    );
    expect(await Tenant.db.count(store.session), 0);
    expect(await SyncOutboxEntry.db.count(store.session), 0);
  });

  group('produk pertama (F1-01b)', () {
    const kopi = ProductDraft(
      name: 'Kopi Susu',
      baseUnit: 'pcs',
      variants: [
        VariantDraft(
          barcode: '899100',
          costPrice: Money(9000),
          sellPrice: Money(15000),
          openingStock: Qty(24000),
        ),
      ],
    );

    test('produk dan stok awal ditulis dalam transaksi setup', () async {
      final ctx = await setup(_input(), kopi);
      final scope = CatalogScope.of(ctx);
      final products = await listProducts(store, scope);
      expect(products.single.name, 'Kopi Susu');
      final variant = products.single.variants.single;
      expect(variant.sellPrice, const Money(15000));
      expect(variant.barcode, '899100');
      expect(variant.stock, Qty.units(24));
      final movement = await StockMovement.db.findFirstRow(store.session);
      expect(movement!.sourceType, StockSourceType.opening);
      // Produk tercatat di outbox dan dibuat oleh pemilik.
      final entries = await SyncOutboxEntry.db.find(store.session);
      expect(entries.where((e) => e.entity == 'products'), hasLength(1));
      final row = await Product.db.findFirstRow(store.session);
      expect(row!.createdBy, ctx.owner.id);
    });

    test('menu F&B tanpa stok awal', () async {
      final ctx = await setup(
        _input(),
        const ProductDraft(
          name: 'Nasi Goreng',
          baseUnit: 'porsi',
          kind: ProductKind.menu,
          variants: [VariantDraft(sellPrice: Money(18000))],
        ),
      );
      final p = (await listProducts(store, CatalogScope.of(ctx))).single;
      expect(p.kind, ProductKind.menu);
      expect(await StockMovement.db.count(store.session), 0);
    });

    test('produk tidak valid: toko juga tidak dibuat', () async {
      await expectLater(
        setup(
          _input(),
          const ProductDraft(
            name: ' ',
            baseUnit: 'pcs',
            variants: [VariantDraft(sellPrice: Money(1000))],
          ),
        ),
        throwsA(isA<ProductInputInvalid>()),
      );
      expect(await Tenant.db.count(store.session), 0);
      expect(await SyncOutboxEntry.db.count(store.session), 0);
    });
  });
}
