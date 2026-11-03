import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cash_drawer_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_cash_drawer_repository.dart';
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

void main() {
  late Directory dir;
  late LakunaStore store;
  late StoreContext ctx;
  late FakeSessionRepository session;
  late LocalCashDrawerRepository repo;

  StaffProfile owner({Set<Permission>? permissions}) => StaffProfile(
    id: ctx.owner.id,
    name: ctx.owner.name,
    roleKey: 'owner',
    isOwner: true,
    hasPin: true,
    permissions: permissions ?? Permission.values.toSet(),
  );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_cash_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    ctx = _ok(await stores.setup(_input()));
    session = FakeSessionRepository()..current = owner();
    repo = LocalCashDrawerRepository(store, stores: stores, session: session);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('alur buka, catat, tutup', () async {
    expect(_ok(await repo.loadCurrent()), isNull);

    final opened = _ok(
      await repo.open(openingCash: const Money(200000), note: 'Pagi'),
    );
    expect(opened.openedByName, 'Ani');
    expect(opened.drawer.expectedCash, const Money(200000));
    expect(opened.movements, isEmpty);

    final after = _ok(
      await repo.recordMovement(
        opened.session.id,
        direction: CashDirection.outflow,
        amount: const Money(15000),
        note: 'Beli es batu',
      ),
    );
    expect(after.movements, hasLength(1));
    expect(after.drawer.expectedCash, const Money(185000));

    final loaded = _ok(await repo.loadCurrent());
    expect(loaded?.session.id, opened.session.id);
    expect(loaded?.movements, hasLength(1));

    final closed = _ok(
      await repo.close(
        opened.session.id,
        count: const CashCount(sheets: {100000: 1, 50000: 1, 20000: 1}),
        note: 'Kurang 15 ribu',
      ),
    );
    expect(closed.status, CashSessionStatus.closed);
    expect(closed.difference, -15000);
    expect(_ok(await repo.loadCurrent()), isNull);
  });

  test('tanpa izin buka sesi ditolak', () async {
    session.current = owner(permissions: const {});
    final error = _err(await repo.open(openingCash: Money.zero));
    expect(
      error,
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.cashSessionOpen,
      ),
    );
    expect(await CashSession.db.count(store.session), 0);
  });

  test('tanpa izin uang laci atau tutup sesi ditolak', () async {
    final opened = _ok(await repo.open(openingCash: Money.zero));
    session.current = owner(permissions: {Permission.cashSessionOpen});
    expect(
      _err(
        await repo.recordMovement(
          opened.session.id,
          direction: CashDirection.inflow,
          amount: const Money(1000),
          note: 'x',
        ),
      ),
      isA<NotPermitted>(),
    );
    expect(
      _err(await repo.close(opened.session.id, count: const CashCount())),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.cashSessionClose,
      ),
    );
  });

  test('belum login ditolak', () async {
    session.current = null;
    expect(_err(await repo.open(openingCash: Money.zero)), isA<NotPermitted>());
  });

  test('galat data diteruskan sebagai Result.error', () async {
    _ok(await repo.open(openingCash: Money.zero));
    expect(
      _err(await repo.open(openingCash: Money.zero)),
      isA<CashSessionAlreadyOpen>(),
    );
  });
}
