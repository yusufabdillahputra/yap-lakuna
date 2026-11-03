import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

const _credentials = SetupCredentials(
  pinHash: r'$argon2id$pin',
  passwordHash: r'$argon2id$password',
);

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupStore(
      store,
      SetupInput(
        businessType: BusinessKind.retail,
        businessName: 'Warung Contoh',
        outletName: 'Cabang Pusat',
        outletCode: 'PST',
        deviceCode: 'K01',
        timezone: 'Asia/Jakarta',
        ownerName: 'Yusuf',
        email: 'yusuf@contoh.id',
        password: 'rahasia123',
        passwordConfirm: 'rahasia123',
        pin: '123456',
        pinConfirm: '123456',
      ),
      platform: DevicePlatform.linux,
      credentials: _credentials,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  /// Menambah staf (mewakili F1-17) di [outletId] dengan role [role].
  Future<StaffMember> addStaff(
    String name, {
    String role = 'cashier',
    UuidValue? outletId,
    bool active = true,
    bool deleted = false,
    bool memberDeleted = false,
    String? pinHash = r'$argon2id$x',
  }) {
    final actor = ctx.owner.id;
    return store.write(actor: actor, (w) async {
      final s = await w.stamp();
      final staff = await w.insert(
        StaffMember(
          tenantId: ctx.tenant.id,
          name: name,
          pinHash: pinHash,
          isActive: active,
          deletedAt: deleted ? s.now : null,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      await w.insert(
        OutletMember(
          tenantId: ctx.tenant.id,
          outletId: outletId ?? ctx.outlet.id,
          staffMemberId: staff.id,
          roleName: role,
          deletedAt: memberDeleted ? s.now : null,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      return staff;
    });
  }

  Future<Outlet> addOutlet() {
    final actor = ctx.owner.id;
    return store.write(actor: actor, (w) async {
      final s = await w.stamp();
      return w.insert(
        Outlet(
          tenantId: ctx.tenant.id,
          code: 'CB2',
          name: 'Cabang Dua',
          timezone: 'Asia/Jakarta',
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    });
  }

  test('pemilik dulu, lalu staf aktif di cabang ini urut nama', () async {
    await addStaff('sari', role: 'cashier');
    await addStaff('Budi', role: 'waiter');
    await addStaff('Nonaktif', active: false);
    await addStaff('Terhapus', deleted: true);
    await addStaff('Keluar', memberDeleted: true);
    final other = await addOutlet();
    await addStaff('Cabang Lain', outletId: other.id);

    final staff = await listOutletStaff(
      store,
      tenantId: ctx.tenant.id,
      outletId: ctx.outlet.id,
    );

    expect(staff.map((s) => s.name), ['Yusuf', 'Budi', 'sari']);
    expect(staff.map((s) => s.roleKey), ['owner', 'waiter', 'cashier']);
    expect(staff.first.isOwner, isTrue);
    expect(staff.first.permissions, Permission.values.toSet());
    expect(staff[1].permissions, DefaultRole.waiter.permissions);
  });

  test('hasPin mengikuti pin_hash', () async {
    await addStaff('Tanpa PIN', pinHash: null);
    final staff = await listOutletStaff(
      store,
      tenantId: ctx.tenant.id,
      outletId: ctx.outlet.id,
    );
    expect(staff.firstWhere((s) => s.name == 'Tanpa PIN').hasPin, isFalse);
    expect(staff.first.hasPin, isTrue);
  });

  test('findStaffById hanya untuk staf aktif di cabang ini', () async {
    final sari = await addStaff('Sari');
    final off = await addStaff('Nonaktif', active: false);
    final other = await addOutlet();
    final elsewhere = await addStaff('Cabang Lain', outletId: other.id);

    Future<OutletStaff?> find(UuidValue id) => findStaffById(
      store,
      tenantId: ctx.tenant.id,
      outletId: ctx.outlet.id,
      staffId: id,
    );

    final found = await find(sari.id);
    expect(found!.name, 'Sari');
    expect(found.staff.pinHash, r'$argon2id$x');
    expect(await find(off.id), isNull);
    expect(await find(elsewhere.id), isNull);
  });

  test('findOwnerByEmail mengabaikan huruf besar/kecil dan spasi', () async {
    final owner = await findOwnerByEmail(
      store,
      tenantId: ctx.tenant.id,
      outletId: ctx.outlet.id,
      email: '  Yusuf@Contoh.ID ',
    );
    expect(owner!.id, ctx.owner.id);
    expect(owner.staff.passwordHash, _credentials.passwordHash);
    expect(owner.roleKey, 'owner');
  });

  test('findOwnerByEmail menolak email yang bukan milik pemilik', () async {
    expect(
      await findOwnerByEmail(
        store,
        tenantId: ctx.tenant.id,
        outletId: ctx.outlet.id,
        email: 'lain@contoh.id',
      ),
      isNull,
    );
  });
}
