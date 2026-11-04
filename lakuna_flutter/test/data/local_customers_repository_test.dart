import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/customers_repository.dart';
import 'package:lakuna_flutter/data/repositories/local_customers_repository.dart';
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
  late LocalCustomersRepository repo;
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
    dir = await Directory.systemTemp.createTemp('lakuna_customers_');
    store = await LakunaStore.open('${dir.path}/lakuna.sqlite');
    final stores = LocalStoreRepository(
      store,
      hasher: const CredentialHasher.forTesting(),
      platform: DevicePlatform.linux,
    );
    ctx = _ok(await stores.setup(_input()));
    owner = StaffProfile(
      id: ctx.owner.id,
      name: ctx.owner.name,
      roleKey: 'owner',
      isOwner: true,
      hasPin: true,
      permissions: Permission.values.toSet(),
    );
    session = FakeSessionRepository(staff: [owner])..current = owner;
    repo = LocalCustomersRepository(
      store,
      stores: stores,
      session: session,
      preferences: LocalPreferences(store.session),
      clock: () => DateTime.utc(2026, 11, 3, 3),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('muat, simpan, daftar, grup, import, dan hapus', () async {
    final setup = _ok(await repo.load());
    expect(setup.today, DateTime.utc(2026, 11, 3));
    expect(setup.canManage, isTrue);
    expect(setup.canReceive, isTrue);
    expect(setup.hasOpenSession, isFalse);
    expect(setup.businessName, 'Toko Bu Ani');

    final ani = _ok(
      await repo.save(
        const CustomerInput(
          name: 'Toko Bu Ani',
          phone: '0813-2222-1010',
          newGroupName: 'Grosir',
          creditLimit: Money(2000000),
        ),
      ),
    );
    expect(ani.phone, '081322221010');
    expect(
      _err(
        await repo.save(
          const CustomerInput(name: 'Lain', phone: '081322221010'),
        ),
      ),
      isA<CustomerPhoneTaken>(),
    );

    final groups = _ok(await repo.groups());
    expect(groups.single.group.name, 'Grosir');
    expect(groups.single.customerCount, 1);
    _ok(
      await repo.saveGroup(
        id: groups.single.group.id,
        name: 'Grosir',
        termDays: 30,
      ),
    );
    expect(
      _err(await repo.deleteGroup(groups.single.group.id)),
      isA<CustomerGroupInUse>(),
    );

    final summary = _ok(
      await repo.importRows([
        const CustomerImportRow(line: 2, name: 'Pak Darto'),
        const CustomerImportRow(
          line: 3,
          name: 'Toko Bu Ani',
          phone: '081322221010',
          note: 'langganan',
        ),
      ]),
    );
    expect((summary.created, summary.updated), (1, 1));

    final list = _ok(await repo.list());
    expect(list.rows.map((r) => r.customer.name), ['Pak Darto', 'Toko Bu Ani']);
    expect(list.rows.last.termDays, 30);
    final detail = _ok(await repo.detail(ani.id));
    expect(detail.customer.note, 'langganan');
    expect(detail.open, isEmpty);

    _ok(await repo.delete(list.rows.first.customer.id));
    expect(_ok(await repo.list()).rows, hasLength(1));
  });

  test('pembayaran piutang dan kuitansi', () async {
    final scope = CatalogScope.of(ctx);
    await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const ProductDraft(
        name: 'Beras',
        category: 'Sembako',
        baseUnit: 'karung',
        variants: [
          VariantDraft(
            sku: 'BRS',
            costPrice: Money(100000),
            sellPrice: Money(150000),
          ),
        ],
      ),
    );
    final variant = (await listProducts(store, scope)).single.variants.single;
    final ani = _ok(
      await repo.save(
        const CustomerInput(name: 'Toko Bu Ani', creditLimit: Money(1000000)),
      ),
    );
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: ctx.owner.id,
      openingCash: Money.zero,
    );
    await checkoutSale(
      store,
      scope,
      staffId: ctx.owner.id,
      lines: [SaleLineRequest(variantId: variant.id, quantity: Qty.units(2))],
      payments: const [],
      credit: SaleCredit(
        customerId: ani.id,
        downPayment: const Money(50000),
        dueOn: DateTime.utc(2026, 11, 17),
      ),
    );
    final before = _ok(await repo.detail(ani.id));
    expect(before.row.outstanding, const Money(250000));

    final payment = _ok(
      await repo.receivePayment(
        DebtPaymentRequest(
          customerId: ani.id,
          amount: const Money(100000),
          method: PaymentMethod.cash,
          paidOn: DateTime.utc(2026, 11, 3),
        ),
      ),
    );
    expect(payment.number, startsWith('BP-PST-K01-'));
    final receipt = _ok(await repo.receipt(payment.id));
    expect(receipt.amount, const Money(100000));
    expect(receipt.balanceAfter, const Money(150000));
    expect(receipt.lines.single.balanceBefore, const Money(250000));
    expect(_ok(await repo.load()).hasOpenSession, isTrue);
  });

  test('izin modul dan per aksi', () async {
    session.current = staffWith({Permission.salesCreate});
    expect(_err(await repo.list()), isA<NotPermitted>());

    session.current = staffWith({Permission.debtsManage});
    final setup = _ok(await repo.load());
    expect((setup.canManage, setup.canReceive), (false, true));
    expect(
      _err(await repo.save(const CustomerInput(name: 'A'))),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.customersManage,
      ),
    );

    session.current = staffWith({Permission.customersManage});
    expect(
      _err(
        await repo.receivePayment(
          DebtPaymentRequest(
            customerId: owner.id,
            amount: const Money(1),
            method: PaymentMethod.cash,
            paidOn: DateTime.utc(2026, 11, 3),
          ),
        ),
      ),
      isA<NotPermitted>().having(
        (e) => e.permission,
        'permission',
        Permission.debtsManage,
      ),
    );

    session.current = null;
    expect(_err(await repo.load()), isA<NotPermitted>());
  });
}
