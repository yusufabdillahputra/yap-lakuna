import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// PIN manajer untuk *Sudah Terbayar* QRIS (F1-05h).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CatalogProduct kopi;
  late DiningTable m1;

  UuidValue owner() => ctx.owner.id;

  Future<StaffMember> addStaff(String name, String role) =>
      store.write(actor: owner(), (w) async {
        final s = await w.stamp();
        final staff = await w.insert(
          StaffMember(
            tenantId: ctx.tenant.id,
            name: name,
            pinHash: r'$argon2id$x',
            isActive: true,
            createdBy: owner(),
            updatedBy: owner(),
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        await w.insert(
          OutletMember(
            tenantId: ctx.tenant.id,
            outletId: ctx.outlet.id,
            staffMemberId: staff.id,
            roleName: role,
            createdBy: owner(),
            updatedBy: owner(),
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
        return staff;
      });

  Future<void> qris({bool withoutPin = true}) => saveQrisSettings(
    store,
    scope,
    staffId: owner(),
    settings: QrisStaticSettings(
      enabled: true,
      cashierConfirmWithoutPin: withoutPin,
    ),
    image: QrisImageUpload(bytes: pngBytes(1080, 1528), fileName: 'q.png'),
  );

  SaleLineRequest line([int qty = 1]) => SaleLineRequest(
    variantId: kopi.variants.single.id,
    quantity: Qty(qty * 1000),
  );

  const confirmed = [
    SalePaymentRequest(method: PaymentMethod.qrisStatic, confirmed: true),
  ];

  Future<CheckoutResult> sell(UuidValue staffId, {UuidValue? approverId}) =>
      checkoutSale(
        store,
        scope,
        staffId: staffId,
        lines: [line()],
        payments: confirmed,
        qrisApproverId: approverId,
      );

  setUp(() async {
    now = DateTime.utc(2026, 11, 27, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Kopi',
        baseUnit: 'gelas',
        variants: [
          VariantDraft(
            costPrice: Money(5000),
            sellPrice: Money(20000),
            openingStock: Qty(50000),
          ),
        ],
      ),
    );
    kopi = (await loadProduct(store, scope, id))!;
    [m1] = await createDiningTables(
      store,
      scope,
      staffId: owner(),
      drafts: const [DiningTableDraft(name: 'M1')],
    );
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: const Money(100000),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  test('sakelar tersimpan, bawaan hidup', () async {
    await qris();
    expect(
      (await readQrisSettings(store.session, scope)).cashierConfirmWithoutPin,
      isTrue,
    );
    await qris(withoutPin: false);
    expect(
      (await readQrisSettings(store.session, scope)).cashierConfirmWithoutPin,
      isFalse,
    );
    expect(
      QrisStaticSettings.fromJson(const {'enabled': true})
          .cashierConfirmWithoutPin,
      isTrue,
    );
  });

  test('sakelar hidup: kasir langsung, pelayan butuh penyetuju', () async {
    await qris();
    final sari = await addStaff('Sari', 'cashier');
    final budi = await addStaff('Budi', 'waiter');
    final direct = await sell(sari.id);
    expect(direct.payments.single.confirmedBy, sari.id);
    await expectLater(sell(budi.id), throwsA(isA<QrisConfirmNotPermitted>()));
    final approved = await sell(budi.id, approverId: sari.id);
    expect(approved.payments.single.confirmedBy, sari.id);
    expect(approved.sale.staffId, budi.id);
  });

  test('sakelar mati: kasir butuh PIN manajer', () async {
    await qris(withoutPin: false);
    final sari = await addStaff('Sari', 'cashier');
    final dimas = await addStaff('Dimas', 'cashier');
    final rina = await addStaff('Rina', 'manager');
    await expectLater(sell(sari.id), throwsA(isA<QrisConfirmNotPermitted>()));
    // Sesama kasir tidak boleh menyetujui.
    await expectLater(
      sell(sari.id, approverId: dimas.id),
      throwsA(isA<QrisConfirmNotPermitted>()),
    );
    expect(await Sale.db.count(store.session), 0);
    final ok = await sell(sari.id, approverId: rina.id);
    expect(ok.payments.single.confirmedBy, rina.id);
    // Manajer dan pemilik tetap langsung.
    expect((await sell(rina.id)).payments.single.confirmedBy, rina.id);
    expect((await sell(owner())).payments.single.confirmedBy, owner());
  });

  test('pemilik tanpa keanggotaan cabang tetap langsung', () async {
    await qris(withoutPin: false);
    final member = await OutletMember.db.findFirstRow(
      store.session,
      where: (m) => m.staffMemberId.equals(owner()),
    );
    await OutletMember.db.updateRow(
      store.session,
      member!.copyWith(deletedAt: now),
    );
    final r = await sell(owner());
    expect(r.payments.single.confirmedBy, owner());
  });

  test('tanpa QRIS terkonfirmasi tidak diperiksa', () async {
    await qris(withoutPin: false);
    final sari = await addStaff('Sari', 'cashier');
    final r = await checkoutSale(
      store,
      scope,
      staffId: sari.id,
      lines: [line()],
      payments: const [SalePaymentRequest.cash(Money(20000))],
    );
    expect(r.sale.status, SaleStatus.completed);
  });

  group('bill dan split', () {
    Future<OpenBill> bill(UuidValue staffId) async {
      final b = await openTableBill(
        store,
        scope,
        staffId: staffId,
        tableId: m1.id,
        guests: 2,
      );
      return addBillItem(
        store,
        scope,
        staffId: staffId,
        billId: b.id,
        line: line(2),
      );
    }

    test('bayar bill dengan QRIS', () async {
      await qris(withoutPin: false);
      final sari = await addStaff('Sari', 'cashier');
      final rina = await addStaff('Rina', 'manager');
      final b = await bill(sari.id);
      await expectLater(
        payOpenBill(
          store,
          scope,
          staffId: sari.id,
          billId: b.id,
          payments: confirmed,
        ),
        throwsA(isA<QrisConfirmNotPermitted>()),
      );
      final r = await payOpenBill(
        store,
        scope,
        staffId: sari.id,
        billId: b.id,
        payments: confirmed,
        qrisApproverId: rina.id,
      );
      expect(r.payments.single.confirmedBy, rina.id);
    });

    test('bagian split dan bagian menunggu', () async {
      await qris(withoutPin: false);
      final sari = await addStaff('Sari', 'cashier');
      final rina = await addStaff('Rina', 'manager');
      var b = await bill(sari.id);
      b = await setBillSplit(
        store,
        scope,
        staffId: sari.id,
        billId: b.id,
        mode: SplitMode.equal,
        guests: 2,
      );
      Future<SplitPayResult> part(
        String guest, {
        bool pending = false,
        UuidValue? approverId,
      }) => paySplitPart(
        store,
        scope,
        staffId: sari.id,
        billId: b.id,
        guest: guest,
        payments: pending
            ? const [SalePaymentRequest(method: PaymentMethod.qrisStatic)]
            : confirmed,
        pending: pending,
        qrisApproverId: approverId,
      );
      await expectLater(part('A'), throwsA(isA<QrisConfirmNotPermitted>()));
      // Menunggu konfirmasi tidak butuh PIN.
      b = (await part('A', pending: true)).bill!;
      b = (await part('B', approverId: rina.id)).bill!;
      final b2 = b.payments.firstWhere((p) => p.guestLabel == 'B');
      expect(b2.confirmedBy, rina.id);
      final waiting = b.payments.firstWhere((p) => p.guestLabel == 'A');
      await expectLater(
        confirmSplitPayment(
          store,
          scope,
          staffId: sari.id,
          paymentId: waiting.id,
        ),
        throwsA(isA<QrisConfirmNotPermitted>()),
      );
      final done = await confirmSplitPayment(
        store,
        scope,
        staffId: sari.id,
        paymentId: waiting.id,
        qrisApproverId: rina.id,
      );
      final a = done.receipt!.payments.firstWhere((p) => p.guestLabel == 'A');
      expect(a.confirmedBy, rina.id);
    });
  });
}
