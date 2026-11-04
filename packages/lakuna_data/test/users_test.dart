import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;

  UuidValue owner() => ctx.owner.id;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<StaffMember> add(
    String name, {
    String role = 'cashier',
    bool active = true,
    UuidValue? actor,
  }) => createStaff(
    store,
    scope,
    staffId: actor ?? owner(),
    name: name,
    roleKey: role,
    pinHash: r'$argon2id$pin-baru',
    active: active,
  );

  Future<OutletStaff?> find(UuidValue id) => findStaffById(
    store,
    tenantId: scope.tenantId,
    outletId: scope.outletId,
    staffId: id,
  );

  group('staf', () {
    test('tambah staf PIN saja: muncul di login dengan izin role', () async {
      final sari = await add('  Sari ');
      expect(sari.name, 'Sari');
      expect(sari.email, isNull);
      expect(sari.passwordHash, isNull);
      final login = await listOutletStaff(
        store,
        tenantId: scope.tenantId,
        outletId: scope.outletId,
      );
      expect(login.map((s) => s.name), ['Yusuf', 'Sari']);
      expect(login.last.permissions, DefaultRole.cashier.permissions);
      final outbox = await SyncOutboxEntry.db.find(store.session);
      expect(
        outbox.where((e) => e.rowId == sari.id && e.entity == 'staff_members'),
        hasLength(1),
      );
      expect(outbox.where((e) => e.entity == 'outlet_members'), hasLength(2));
    });

    test('nama unik tanpa membedakan huruf, nama wajib', () async {
      await add('Sari');
      await expectLater(() => add('sari'), throwsA(isA<StaffNameTaken>()));
      await expectLater(() => add('  '), throwsA(isA<StaffNameInvalid>()));
    });

    test('role tidak dikenal atau owner ditolak', () async {
      await expectLater(
        () => add('Budi', role: 'tamu'),
        throwsA(isA<RoleNotFound>()),
      );
      await expectLater(
        () => add('Budi', role: 'owner'),
        throwsA(isA<RoleNotFound>()),
      );
    });

    test(
      'staf nonaktif tidak muncul di login tetapi ada di daftar akun',
      () async {
        final dimas = await add('Dimas', active: false);
        final login = await listOutletStaff(
          store,
          tenantId: scope.tenantId,
          outletId: scope.outletId,
        );
        expect(login.map((s) => s.id), isNot(contains(dimas.id)));
        final accounts = await listStaffAccounts(store, scope);
        expect(accounts.map((a) => a.name), ['Yusuf', 'Dimas']);
        expect(accounts.last.isActive, isFalse);
        expect(accounts.first.isOwner, isTrue);
        expect(accounts.first.hasPassword, isTrue);
      },
    );

    test('ubah nama, role, dan status', () async {
      final sari = await add('Sari');
      await updateStaff(
        store,
        scope,
        staffId: owner(),
        targetId: sari.id,
        name: 'Sari Dewi',
        roleKey: 'manager',
        active: true,
      );
      final s = await find(sari.id);
      expect(s!.name, 'Sari Dewi');
      expect(s.roleKey, 'manager');
      expect(s.permissions, DefaultRole.manager.permissions);
      await updateStaff(
        store,
        scope,
        staffId: owner(),
        targetId: sari.id,
        name: 'Sari Dewi',
        roleKey: 'manager',
        active: false,
      );
      expect(await find(sari.id), isNull);
    });

    test('pemilik tidak bisa diubah lewat daftar pengguna', () async {
      await expectLater(
        () => updateStaff(
          store,
          scope,
          staffId: owner(),
          targetId: owner(),
          name: 'Yusuf',
          roleKey: 'cashier',
          active: false,
        ),
        throwsA(isA<StaffOwnerLocked>()),
      );
      await expectLater(
        () => resetStaffPin(
          store,
          scope,
          staffId: owner(),
          targetId: owner(),
          pinHash: r'$argon2id$x',
        ),
        throwsA(isA<StaffOwnerLocked>()),
      );
    });

    test('reset PIN staf', () async {
      final sari = await add('Sari');
      await resetStaffPin(
        store,
        scope,
        staffId: owner(),
        targetId: sari.id,
        pinHash: r'$argon2id$reset',
      );
      expect((await find(sari.id))!.staff.pinHash, r'$argon2id$reset');
    });

    test('tanpa users:manage ditolak', () async {
      final sari = await add('Sari');
      await expectLater(
        () => add('Budi', actor: sari.id),
        throwsA(isA<UsersActorNotPermitted>()),
      );
      await expectLater(
        () => resetStaffPin(
          store,
          scope,
          staffId: sari.id,
          targetId: sari.id,
          pinHash: r'$argon2id$x',
        ),
        throwsA(isA<UsersActorNotPermitted>()),
      );
    });
  });

  group('batas wewenang manajer dengan users:manage', () {
    late StaffMember rina;

    setUp(() async {
      await saveRoleMatrix(
        store,
        scope,
        staffId: owner(),
        changes: {
          'manager': {
            ...DefaultRole.manager.permissions,
            Permission.usersManage,
          },
        },
      );
      rina = await add('Rina', role: 'manager');
    });

    test('boleh menambah kasir', () async {
      await add('Sari', actor: rina.id);
    });

    test('tidak boleh memberi role dengan izin di luar miliknya', () async {
      final big = await createCustomRole(
        store,
        scope,
        staffId: owner(),
        name: 'Admin',
        permissions: Permission.values.toSet(),
      );
      await expectLater(
        () => add('Budi', role: big.roleKey, actor: rina.id),
        throwsA(isA<StaffBeyondPermissions>()),
      );
      await expectLater(
        () => saveRoleMatrix(
          store,
          scope,
          staffId: rina.id,
          changes: {
            'cashier': {Permission.salesCreate, Permission.backupManage},
          },
        ),
        throwsA(isA<StaffBeyondPermissions>()),
      );
    });

    test(
      'tidak boleh mengelola pemilik, dirinya, atau staf berizin lebih',
      () async {
        final admin = await createCustomRole(
          store,
          scope,
          staffId: owner(),
          name: 'Admin',
          permissions: Permission.values.toSet(),
        );
        final boss = await add('Bos', role: admin.roleKey);
        final sari = await add('Sari');
        Future<void> manage(UuidValue target) => requireStaffManageable(
          store,
          scope,
          staffId: rina.id,
          targetId: target,
        );
        await expectLater(
          () => manage(owner()),
          throwsA(isA<StaffOwnerLocked>()),
        );
        await expectLater(
          () => manage(rina.id),
          throwsA(isA<StaffSelfChange>()),
        );
        await expectLater(
          () => manage(boss.id),
          throwsA(isA<StaffBeyondPermissions>()),
        );
        await manage(sari.id);
        expect(
          () => resetStaffPin(
            store,
            scope,
            staffId: rina.id,
            targetId: boss.id,
            pinHash: r'$argon2id$x',
          ),
          throwsA(isA<StaffBeyondPermissions>()),
        );
        expect(
          () => renameCustomRole(
            store,
            scope,
            staffId: rina.id,
            roleKey: admin.roleKey,
            name: 'Super',
          ),
          throwsA(isA<StaffBeyondPermissions>()),
        );
        expect(
          () => deleteCustomRole(
            store,
            scope,
            staffId: rina.id,
            roleKey: admin.roleKey,
          ),
          throwsA(isA<StaffBeyondPermissions>()),
        );
      },
    );

    test(
      'tidak boleh mengubah dirinya sendiri atau role-nya sendiri',
      () async {
        expect(
          () => updateStaff(
            store,
            scope,
            staffId: rina.id,
            targetId: rina.id,
            name: 'Rina',
            roleKey: 'manager',
            active: false,
          ),
          throwsA(isA<StaffSelfChange>()),
        );
        expect(
          () => saveRoleMatrix(
            store,
            scope,
            staffId: rina.id,
            changes: {
              'manager': {Permission.usersManage},
            },
          ),
          throwsA(isA<StaffSelfChange>()),
        );
      },
    );
  });

  group('role', () {
    test('daftar role: pemilik, bawaan, lalu custom', () async {
      await createCustomRole(
        store,
        scope,
        staffId: owner(),
        name: 'Barista',
        permissions: {Permission.openBillsManage},
      );
      final roles = await listRoles(store, scope);
      expect(roles.map((r) => r.key), [
        'owner',
        'manager',
        'cashier',
        'waiter',
        'stock_keeper',
        'barista',
      ]);
      expect(roles.first.permissions, Permission.values.toSet());
      expect(roles.first.isOwner, isTrue);
      expect(roles.first.memberCount, 1);
      expect(roles[2].permissions, DefaultRole.cashier.permissions);
      expect(roles.last.isCustom, isTrue);
      expect(roles.last.name, 'Barista');
    });

    test('ubah matriks berlaku untuk staf role itu', () async {
      final sari = await add('Sari');
      await saveRoleMatrix(
        store,
        scope,
        staffId: owner(),
        changes: {
          'cashier': {Permission.salesCreate, Permission.reportsView},
        },
      );
      expect((await find(sari.id))!.permissions, {
        Permission.salesCreate,
        Permission.reportsView,
      });
      // Simpan kedua memperbarui baris yang sama.
      await saveRoleMatrix(
        store,
        scope,
        staffId: owner(),
        changes: {
          'cashier': {Permission.salesCreate},
        },
      );
      expect((await find(sari.id))!.permissions, {Permission.salesCreate});
      final rows = await StaffRole.db.find(store.session);
      expect(rows.where((r) => r.roleKey == 'cashier'), hasLength(1));
    });

    test('matriks pemilik dan role tak dikenal ditolak', () async {
      await expectLater(
        () => saveRoleMatrix(
          store,
          scope,
          staffId: owner(),
          changes: {'owner': const {}},
        ),
        throwsA(isA<StaffOwnerLocked>()),
      );
      await expectLater(
        () => saveRoleMatrix(
          store,
          scope,
          staffId: owner(),
          changes: {'tamu': const {}},
        ),
        throwsA(isA<RoleNotFound>()),
      );
    });

    test(
      'role custom: nama unik, ganti nama, hapus bila tidak dipakai',
      () async {
        final barista = await createCustomRole(
          store,
          scope,
          staffId: owner(),
          name: 'Barista',
          permissions: {Permission.openBillsManage},
        );
        expect(
          () => createCustomRole(
            store,
            scope,
            staffId: owner(),
            name: 'barista',
            permissions: const {},
          ),
          throwsA(isA<RoleNameTaken>()),
        );
        final dimas = await add('Dimas', role: barista.roleKey);
        expect((await find(dimas.id))!.roleName, 'Barista');
        await renameCustomRole(
          store,
          scope,
          staffId: owner(),
          roleKey: barista.roleKey,
          name: 'Barista Pagi',
        );
        expect((await find(dimas.id))!.roleName, 'Barista Pagi');
        expect(
          () => deleteCustomRole(
            store,
            scope,
            staffId: owner(),
            roleKey: barista.roleKey,
          ),
          throwsA(isA<RoleInUse>()),
        );
        await updateStaff(
          store,
          scope,
          staffId: owner(),
          targetId: dimas.id,
          name: 'Dimas',
          roleKey: 'waiter',
          active: true,
        );
        await deleteCustomRole(
          store,
          scope,
          staffId: owner(),
          roleKey: barista.roleKey,
        );
        expect(
          (await listRoles(store, scope)).map((r) => r.key),
          isNot(contains('barista')),
        );
        // Nama yang sama boleh dipakai lagi dengan kunci baru.
        final again = await createCustomRole(
          store,
          scope,
          staffId: owner(),
          name: 'Barista',
          permissions: const {},
        );
        expect(again.roleKey, 'barista_2');
      },
    );

    test('baris role memakai ID tetap dan tercatat di outbox', () async {
      await saveRoleMatrix(
        store,
        scope,
        staffId: owner(),
        changes: {
          'cashier': {Permission.salesCreate},
        },
      );
      final barista = await createCustomRole(
        store,
        scope,
        staffId: owner(),
        name: 'Barista',
        permissions: const {},
      );
      final rows = await StaffRole.db.find(store.session);
      final cashier = rows.singleWhere((r) => r.roleKey == 'cashier');
      expect(cashier.id.uuid, stableId(scope.tenantId.uuid, 'cashier'));
      expect(barista.id.uuid, stableId(scope.tenantId.uuid, 'barista'));
      final outbox = await SyncOutboxEntry.db.find(store.session);
      expect(
        outbox.where((e) => e.entity == 'roles').map((e) => e.rowId),
        containsAll([cashier.id, barista.id]),
      );
    });

    test('nama role custom tidak boleh sama dengan role bawaan', () async {
      for (final name in ['Kasir', 'cashier', 'Staf Gudang']) {
        await expectLater(
          () => createCustomRole(
            store,
            scope,
            staffId: owner(),
            name: name,
            permissions: const {},
          ),
          throwsA(isA<RoleNameTaken>()),
          reason: name,
        );
      }
    });

    test(
      'staf dengan role yang sudah tidak ada tetap bisa diubah pemilik',
      () async {
        final barista = await createCustomRole(
          store,
          scope,
          staffId: owner(),
          name: 'Barista',
          permissions: {Permission.openBillsManage},
        );
        final dimas = await add('Dimas', role: barista.roleKey);
        // Mewakili role yang dihapus di perangkat lain lalu tersinkron.
        final row = (await StaffRole.db.find(store.session))
            .singleWhere((r) => r.roleKey == barista.roleKey);
        await StaffRole.db.updateRow(
          store.session,
          row.copyWith(deletedAt: DateTime.now().toUtc()),
        );
        await updateStaff(
          store,
          scope,
          staffId: owner(),
          targetId: dimas.id,
          name: 'Dimas P',
          roleKey: barista.roleKey,
          active: false,
        );
        final accounts = await listStaffAccounts(store, scope);
        expect(accounts.last.name, 'Dimas P');
        expect(accounts.last.permissions, isEmpty);
      },
    );

    test('role bawaan tidak bisa dihapus atau diganti nama', () async {
      await expectLater(
        () => deleteCustomRole(
          store,
          scope,
          staffId: owner(),
          roleKey: 'cashier',
        ),
        throwsA(isA<RoleNotFound>()),
      );
      await expectLater(
        () => renameCustomRole(
          store,
          scope,
          staffId: owner(),
          roleKey: 'cashier',
          name: 'Kasir',
        ),
        throwsA(isA<RoleNotFound>()),
      );
    });
  });

  group('akun saya', () {
    test('ganti PIN dan kata sandi sendiri', () async {
      await changeOwnPin(
        store,
        scope,
        staffId: owner(),
        pinHash: r'$argon2id$pin2',
      );
      await changeOwnPassword(
        store,
        scope,
        staffId: owner(),
        passwordHash: r'$argon2id$pw2',
      );
      final me = (await find(owner()))!.staff;
      expect(me.pinHash, r'$argon2id$pin2');
      expect(me.passwordHash, r'$argon2id$pw2');
    });

    test('staf tanpa kata sandi tidak bisa mengganti kata sandi', () async {
      final sari = await add('Sari');
      await changeOwnPin(
        store,
        scope,
        staffId: sari.id,
        pinHash: r'$argon2id$pin2',
      );
      await expectLater(
        () => changeOwnPassword(
          store,
          scope,
          staffId: sari.id,
          passwordHash: r'$argon2id$pw',
        ),
        throwsA(isA<StaffNoPassword>()),
      );
    });

    test('staf nonaktif ditolak', () async {
      final sari = await add('Sari', active: false);
      await expectLater(
        () => changeOwnPin(
          store,
          scope,
          staffId: sari.id,
          pinHash: r'$argon2id$pin2',
        ),
        throwsA(isA<StaffNotFound>()),
      );
    });
  });
}
