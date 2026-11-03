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

  Future<StoreContext> setup([SetupInput? input]) => setupStore(
    store,
    input ?? _input(),
    platform: DevicePlatform.linux,
    credentials: _credentials,
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
}
