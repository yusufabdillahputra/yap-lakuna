import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_session_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_users_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/data/repositories/users_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

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

void main() {
  late Directory dir;
  late LakunaStore store;
  late LocalSessionRepository session;
  late LocalUsersRepository users;
  late StoreContext ctx;
  const hasher = CredentialHasher.forTesting();

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_users_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: hasher,
      platform: DevicePlatform.linux,
    );
    ctx = _ok(await stores.setup(_input()));
    session = LocalSessionRepository(store, stores: stores, hasher: hasher);
    users = LocalUsersRepository(
      store,
      stores: stores,
      session: session,
      hasher: hasher,
    );
    _ok(await session.loginWithPin(ctx.owner.id, '123456'));
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  StaffAccount byName(List<StaffAccount> list, String name) =>
      list.singleWhere((a) => a.name == name);

  test('tambah staf: hash PIN tersimpan dan staf bisa login', () async {
    _ok(
      await users.createStaff(
        name: 'Sari',
        roleKey: 'cashier',
        pin: '246810',
        active: true,
      ),
    );
    final sari = byName(_ok(await users.accounts()), 'Sari');
    expect(sari.staff.pinHash, startsWith(r'$argon2id$'));
    session.logout();
    final login = _ok(await session.loginWithPin(sari.id, '246810'));
    expect(login.permissions, DefaultRole.cashier.permissions);
    // Kasir tidak punya users:manage.
    expect(_err(await users.accounts()), isA<NotPermitted>());
  });

  test('ganti PIN sendiri: PIN saat ini salah memakai kunci login', () async {
    for (var left = 4; left >= 1; left--) {
      final e = _err(await users.changeMyPin(current: '000000', pin: '111111'));
      expect((e as WrongCurrentSecret).remainingAttempts, left);
    }
    expect(
      _err(await users.changeMyPin(current: '000000', pin: '111111')),
      isA<CredentialsLocked>(),
    );
    expect(session.pinRetryAfter(ctx.owner.id), isNotNull);
    // Saat dikunci, PIN benar pun ditolak.
    expect(
      _err(await users.changeMyPin(current: '123456', pin: '111111')),
      isA<CredentialsLocked>(),
    );
  });

  test('ganti PIN sendiri berhasil: PIN baru dipakai login', () async {
    _ok(await users.changeMyPin(current: '123456', pin: '135790'));
    session.logout();
    expect(
      _err(await session.loginWithPin(ctx.owner.id, '123456')),
      isA<WrongPin>(),
    );
    _ok(await session.loginWithPin(ctx.owner.id, '135790'));
  });

  test('ganti kata sandi sendiri', () async {
    expect(
      _err(
        await users.changeMyPassword(
          current: 'salah1234',
          password: 'rahasiabaru',
        ),
      ),
      isA<WrongCurrentSecret>(),
    );
    _ok(
      await users.changeMyPassword(
        current: 'rahasia123',
        password: 'rahasiabaru',
      ),
    );
    session.logout();
    _ok(await session.loginWithPassword('ani@contoh.id', 'rahasiabaru'));
    expect(_ok(await users.myAccount()).hasPassword, isTrue);
  });

  test('reset PIN membuka kunci staf; manajer tidak bisa membuka kunci '
      'pemilik', () async {
    _ok(
      await users.saveMatrix({
        'manager': {...DefaultRole.manager.permissions, Permission.usersManage},
      }),
    );
    _ok(
      await users.createStaff(
        name: 'Rina',
        roleKey: 'manager',
        pin: '222222',
        active: true,
      ),
    );
    _ok(
      await users.createStaff(
        name: 'Sari',
        roleKey: 'cashier',
        pin: '333333',
        active: true,
      ),
    );
    final list = _ok(await users.accounts());
    final rina = byName(list, 'Rina');
    final sari = byName(list, 'Sari');

    session.logout();
    for (var i = 0; i < PinGuard.maxAttempts; i++) {
      await session.loginWithPin(sari.id, '000000');
      await session.loginWithPin(ctx.owner.id, '000000');
    }
    expect(session.pinRetryAfter(sari.id), isNotNull);
    expect(session.pinRetryAfter(ctx.owner.id), isNotNull);

    _ok(await session.loginWithPin(rina.id, '222222'));
    expect(_err(await users.unlockPin(ctx.owner.id)), isA<StaffOwnerLocked>());
    expect(session.pinRetryAfter(ctx.owner.id), isNotNull);
    _ok(await users.resetPin(sari.id, '444444'));
    expect(session.pinRetryAfter(sari.id), isNull);
  });

  test(
    'menonaktifkan diri tidak mungkin; refreshCurrent memakai izin baru',
    () async {
      _ok(
        await users.createStaff(
          name: 'Sari',
          roleKey: 'cashier',
          pin: '333333',
          active: true,
        ),
      );
      final sari = byName(_ok(await users.accounts()), 'Sari');
      session.logout();
      _ok(await session.loginWithPin(sari.id, '333333'));
      expect(session.current!.can(Permission.reportsView), isFalse);

      // Pemilik mengubah izin kasir di database (mewakili perangkat ini
      // sebelum ganti kasir), lalu sesi kasir disegarkan.
      await saveRoleMatrix(
        store,
        CatalogScope.of(ctx),
        staffId: ctx.owner.id,
        changes: {
          'cashier': {
            ...DefaultRole.cashier.permissions,
            Permission.reportsView,
          },
        },
      );
      await session.refreshCurrent();
      expect(session.current!.can(Permission.reportsView), isTrue);

      // Staf yang dinonaktifkan dikeluarkan saat disegarkan.
      await updateStaff(
        store,
        CatalogScope.of(ctx),
        staffId: ctx.owner.id,
        targetId: sari.id,
        name: 'Sari',
        roleKey: 'cashier',
        active: false,
      );
      await session.refreshCurrent();
      expect(session.current, isNull);
    },
  );
}
