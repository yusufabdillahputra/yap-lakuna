import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/local_store_repository.dart';
import 'package:lakuna_flutter/data/repositories/expenses_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_cash_drawer_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_expenses_repository.dart';
import 'package:lakuna_flutter/data/repositories/session_repository.dart';
import 'package:lakuna_flutter/data/repositories/suppliers_repository.dart'
    show NotPermitted;
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
  late LocalExpensesRepository repo;
  late LocalCashDrawerRepository drawer;
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
    dir = await Directory.systemTemp.createTemp('lakuna_expenses_');
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
    repo = LocalExpensesRepository(store, stores: stores, session: session);
    drawer = LocalCashDrawerRepository(
      store,
      stores: stores,
      session: session,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('muat membuat jenis bawaan; catat bank, rincian, batal', () async {
    final setup = _ok(await repo.load());
    expect(
      setup.categories.map((c) => c.name),
      unorderedEquals(
        defaultExpenseCategories,
      ),
    );
    expect(setup.hasOpenSession, isFalse);
    final sewa = setup.categories.firstWhere((c) => c.name == 'Sewa tempat');
    final e = _ok(
      await repo.record(
        ExpenseRequest(
          description: 'Sewa November',
          categoryId: sewa.id,
          amount: const Money(2500000),
          funding: FundingSource.bank,
          spentOn: setup.today,
        ),
      ),
    );
    expect(e.number, startsWith('EX-PST-K01-'));
    final range = expensePeriodRange(ExpensePeriod.thisMonth, setup.today);
    expect(_ok(await repo.list(range)).single.categoryName, 'Sewa tempat');
    expect(_ok(await repo.detail(e.id)).staffName, 'Ani');
    _ok(await repo.cancel(e.id, 'Salah'));
    expect(_ok(await repo.detail(e.id)).voided, isTrue);
    // Jenis terpakai tidak bisa dihapus.
    expect(
      _err(await repo.deleteCategory(sewa.id)),
      isA<ExpenseCategoryInUse>(),
    );
  });

  test('tanpa expenses:manage semua aksi ditolak', () async {
    session.current = staffWith({Permission.cashMovementsCreate});
    expect(_err(await repo.load()), isA<NotPermitted>());
    expect(_err(await repo.categories()), isA<NotPermitted>());
    expect(
      _err(await repo.saveCategory(name: 'Iuran')),
      isA<NotPermitted>(),
    );
  });

  test('kas laci butuh cash_movements:create dan masuk rekap sesi', () async {
    _ok(await drawer.open(openingCash: const Money(100000)));
    final setup = _ok(await repo.load());
    expect(setup.hasOpenSession, isTrue);
    final bahan = setup.categories.firstWhere(
      (c) => c.name == 'Bahan habis pakai',
    );
    final request = ExpenseRequest(
      description: 'Es batu',
      categoryId: bahan.id,
      amount: const Money(8000),
      funding: FundingSource.drawer,
      spentOn: setup.today,
    );

    session.current = staffWith({Permission.expensesManage});
    final denied = _err(await repo.record(request));
    expect(denied, isA<NotPermitted>());
    expect(
      (denied as NotPermitted).permission,
      Permission.cashMovementsCreate,
    );
    expect(_ok(await repo.load()).canUseDrawer, isFalse);

    session.current = owner;
    final e = _ok(await repo.record(request));
    final active = _ok(await drawer.loadCurrent())!;
    expect(active.drawer.expectedCash, const Money(92000));
    final movement = active.movements.single;
    expect(movement.id, e.cashMovementId);
    expect(active.expenseLabels[movement.id], 'Bahan habis pakai');
  });
}
