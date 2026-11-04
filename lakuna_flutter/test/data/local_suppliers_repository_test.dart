import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_suppliers_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/data/repositories/suppliers_repository.dart';
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
  late FakeSessionRepository session;
  late LocalSuppliersRepository repo;
  late StaffProfile owner;

  StaffProfile staffWith(Set<Permission> permissions) => StaffProfile(
    id: owner.id,
    name: owner.name,
    roleKey: 'custom',
    isOwner: false,
    hasPin: true,
    permissions: permissions,
  );

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('lakuna_suppliers_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    final ctx = _ok(await stores.setup(_input()));
    owner = StaffProfile(
      id: ctx.owner.id,
      name: ctx.owner.name,
      roleKey: 'owner',
      isOwner: true,
      hasPin: true,
      permissions: Permission.values.toSet(),
    );
    session = FakeSessionRepository(staff: [owner])..current = owner;
    repo = LocalSuppliersRepository(
      store,
      stores: stores,
      session: session,
      clock: () => DateTime.utc(2026, 11, 4, 3),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  SupplierPaymentRequest request(UuidValue id, FundingSource funding) =>
      SupplierPaymentRequest(
        supplierId: id,
        amount: const Money(10000),
        funding: funding,
        paidOn: DateTime.utc(2026, 11, 4),
      );

  test('muat, simpan, daftar, dan izin per aksi', () async {
    final setup = _ok(await repo.load());
    expect(setup.today, DateTime.utc(2026, 11, 4));
    expect(setup.canManage, isTrue);
    expect(setup.canPay, isTrue);
    expect(setup.hasOpenSession, isFalse);

    final s = _ok(
      await repo.save(const SupplierInput(name: 'CV Sumber', termDays: 7)),
    );
    expect(_ok(await repo.list()).rows.single.supplier.id, s.id);

    // Tanpa izin supplier maupun hutang.
    session.current = staffWith({Permission.salesCreate});
    expect(_err(await repo.list()), isA<NotPermitted>());

    // Staf gudang: kelola supplier, tidak bisa bayar.
    session.current = staffWith({Permission.suppliersManage});
    expect(
      _err(await repo.pay(request(s.id, FundingSource.bank))),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.debtsManage,
      ),
    );

    // Bisa bayar hutang tapi tanpa izin kas laci.
    session.current = staffWith({Permission.debtsManage});
    expect(
      _err(await repo.pay(request(s.id, FundingSource.drawer))),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.cashMovementsCreate,
      ),
    );
    expect(
      _err(await repo.save(const SupplierInput(name: 'Lain', termDays: 7))),
      isA<NotPermitted>(),
    );
    // Lolos izin; ditolak karena tidak ada hutang.
    expect(
      _err(await repo.pay(request(s.id, FundingSource.bank))),
      isA<SupplierPaymentInvalid>(),
    );
  });
}
