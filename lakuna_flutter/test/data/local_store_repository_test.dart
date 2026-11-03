import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
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

void main() {
  late Directory dir;
  late LakunaStore store;
  late LocalStoreRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_app_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    repo = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.android,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('sebelum setup konteks kosong', () async {
    expect((await repo.load() as Ok).value, isNull);
    expect(repo.current, isNull);
  });

  test('setup menyimpan hash Argon2id, bukan PIN atau kata sandi', () async {
    var notified = 0;
    repo.addListener(() => notified++);
    final result = await repo.setup(_input());
    final ctx = (result as Ok<StoreContext>).value;
    expect(repo.current, same(ctx));
    expect(notified, 1);
    expect(ctx.device.platform, DevicePlatform.android);

    const hasher = CredentialHasher.forTesting();
    expect(ctx.owner.pinHash, startsWith(r'$argon2id$'));
    expect(hasher.verify('123456', ctx.owner.pinHash!), isTrue);
    expect(hasher.verify('rahasia123', ctx.owner.passwordHash!), isTrue);
    expect(ctx.owner.pinHash, isNot(contains('123456')));

    final reloaded = LocalStoreRepository(store);
    expect((await reloaded.load() as Ok).value, isNotNull);
  });

  test(
    'toko sudah ada tetapi konteks belum dimuat: setup memuat ulang',
    () async {
      await repo.setup(_input());
      final fresh = LocalStoreRepository(
        store,
        hasher: const CredentialHasher.forTesting(),
      );
      final result = await fresh.setup(_input());
      expect(result, isA<Ok<StoreContext>>());
      expect(fresh.current, isNotNull);
    },
  );

  test('setup kedua tidak membuat toko ganda', () async {
    final first = (await repo.setup(_input()) as Ok<StoreContext>).value;
    final second = (await repo.setup(_input()) as Ok<StoreContext>).value;
    expect(second.tenant.id, first.tenant.id);
    expect(await Tenant.db.count(store.session), 1);
  });

  test('toko ada tetapi tidak lengkap: tetap galat SetupAlreadyDone', () async {
    await repo.setup(_input());
    await store.session.db.unsafeExecute('DELETE FROM outlet_members');
    await store.session.db.unsafeExecute('DELETE FROM staff_members');
    final fresh = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
    );
    final result = await fresh.setup(_input());
    expect((result as Error).error, isA<SetupAlreadyDone>());
    expect(fresh.current, isNull);
  });
}
