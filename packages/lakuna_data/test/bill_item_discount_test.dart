import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

// Diskon per baris di open bill F&B (F1-04g).
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

  setUp(() async {
    now = DateTime.utc(2026, 11, 13, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Kopi Susu Aren',
        baseUnit: 'gelas',
        variants: [
          VariantDraft(
            costPrice: Money(9000),
            sellPrice: Money(25000),
            openingStock: Qty(20000),
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
    await saveFnbRates(
      store,
      scope,
      staffId: owner(),
      rates: const FnbRates(service: BasisPoints(500), tax: BasisPoints(1000)),
    );
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: Money.zero,
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<OpenBill> bill([int qty = 4]) async {
    final b = await openTableBill(
      store,
      scope,
      staffId: owner(),
      tableId: m1.id,
      guests: 2,
    );
    return addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.units(qty),
      ),
    );
  }

  Future<OpenBill> itemDiscount(
    SaleItem item,
    ManualDiscount? d, {
    UuidValue? staffId,
    UuidValue? approverId,
  }) => setBillItemDiscount(
    store,
    scope,
    staffId: staffId ?? owner(),
    itemId: item.id,
    discount: d,
    approverId: approverId,
  );

  Future<OpenBill> billDiscount(OpenBill b, ManualDiscount? d) =>
      setBillDiscount(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        discount: d,
      );

  const tenPercent = ManualDiscount.percent(BasisPoints(1000));

  test('persen dan rupiah tersimpan di item; dibayar ke nota', () async {
    var b = await bill();
    b = await itemDiscount(b.items.single, tenPercent);
    var item = b.items.single;
    expect(billItemDiscountOf(item), tenPercent);
    expect(item.discountBp, 1000);
    expect(item.discountAmount, 10000);
    expect(item.lineTotal, 90000);
    // 90.000 + service 4.500 + PB1 9.450.
    expect(b.charges.subtotal, const Money(90000));
    expect(b.charges.total, const Money(103950));
    expect(b.sale.subtotal, 100000);
    expect(b.sale.tierDiscount, 0);
    expect(b.sale.lineDiscountAmount, 10000);

    b = await itemDiscount(item, const ManualDiscount.amount(Money(5000)));
    item = b.items.single;
    expect(billItemDiscountOf(item), const ManualDiscount.amount(Money(5000)));
    expect(item.discountBp, 0);
    expect(item.discountAmount, 5000);
    expect(item.lineTotal, 95000);

    // Diskon nota dihitung dari total baris bersih.
    b = await billDiscount(b, tenPercent);
    expect(b.charges.discount, const Money(9500));

    final paid = await payOpenBill(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      payments: [SalePaymentRequest.cash(b.charges.total)],
    );
    expect(paid.items.single.discountAmount, 5000);
    expect(paid.items.single.lineTotal, 95000);
    expect(paid.sale.subtotal, 100000);
    expect(paid.sale.tierDiscount, 0);
    expect(paid.sale.lineDiscountAmount, 5000);
    expect(paid.sale.discountAmount, 9500);
    expect(paid.sale.total, b.charges.total.value);
  });

  test('hapus diskon baris', () async {
    var b = await bill();
    b = await itemDiscount(b.items.single, tenPercent);
    b = await itemDiscount(b.items.single, null);
    final item = b.items.single;
    expect(billItemDiscountOf(item), isNull);
    expect(item.discountAmount, 0);
    expect(item.lineTotal, 100000);
    expect(b.sale.lineDiscountAmount, 0);
    expect(b.sale.discountApprovedBy, isNull);
  });

  test('terlalu besar atau tidak sah ditolak', () async {
    final b = await bill(1);
    final item = b.items.single;
    await expectLater(
      itemDiscount(item, const ManualDiscount.amount(Money(30000))),
      throwsA(isA<DiscountTooLarge>()),
    );
    // Satu-satunya item gratis: total bill habis.
    await expectLater(
      itemDiscount(item, const ManualDiscount.percent(BasisPoints.full)),
      throwsA(isA<DiscountTooLarge>()),
    );
    await expectLater(
      itemDiscount(item, const ManualDiscount.amount(Money.zero)),
      throwsA(isA<DiscountInvalid>()),
    );
    final again = await loadOpenBill(store, scope, b.id);
    expect(again.items.single.discountAmount, 0);
  });

  test('izin: kasir butuh penyetuju; penyetuju bertahan', () async {
    final sari = await addStaff('Sari', 'cashier');
    final dimas = await addStaff('Dimas', 'cashier');
    final rina = await addStaff('Rina', 'manager');
    var b = await bill();
    await expectLater(
      itemDiscount(b.items.single, tenPercent, staffId: sari.id),
      throwsA(isA<DiscountNotPermitted>()),
    );
    await expectLater(
      itemDiscount(
        b.items.single,
        tenPercent,
        staffId: sari.id,
        approverId: dimas.id,
      ),
      throwsA(isA<ApproverNotPermitted>()),
    );
    b = await itemDiscount(
      b.items.single,
      tenPercent,
      staffId: sari.id,
      approverId: rina.id,
    );
    expect(b.sale.discountApprovedBy, rina.id);
    expect(b.discountApprovedByName, 'Rina');

    // Diskon nota oleh pemilik: pemilik menjadi pemberi terakhir (F1-04i;
    // satu kolom per nota). Dihapus: pemberi tetap selama ada baris
    // berdiskon.
    b = await billDiscount(b, const ManualDiscount.amount(Money(1000)));
    expect(b.sale.discountApprovedBy, ctx.owner.id);
    b = await billDiscount(b, null);
    expect(b.sale.discountApprovedBy, ctx.owner.id);

    // Hapus diskon baris tidak butuh izin diskon; penyetuju ikut hilang.
    b = await itemDiscount(b.items.single, null, staffId: sari.id);
    expect(b.sale.discountApprovedBy, isNull);

    await saveSalesRules(
      store,
      scope,
      staffId: owner(),
      rules: const SalesRules(discountNeedsPin: false),
    );
    await expectLater(
      itemDiscount(
        b.items.single,
        tenPercent,
        staffId: sari.id,
        approverId: rina.id,
      ),
      throwsA(isA<DiscountNotPermitted>()),
    );
  });

  test('ubah jumlah: persen ikut, rupiah dipangkas', () async {
    var b = await bill();
    b = await itemDiscount(b.items.single, tenPercent);
    b = await setBillItemQuantity(
      store,
      scope,
      staffId: owner(),
      itemId: b.items.single.id,
      quantity: Qty.units(5),
    );
    expect(b.items.single.discountAmount, 12500);
    expect(b.items.single.lineTotal, 112500);

    b = await itemDiscount(
      b.items.single,
      const ManualDiscount.amount(Money(40000)),
    );
    b = await setBillItemQuantity(
      store,
      scope,
      staffId: owner(),
      itemId: b.items.single.id,
      quantity: Qty.units(1),
    );
    expect(b.items.single.discountAmount, 25000);
    expect(b.items.single.lineTotal, 0);
    expect(b.charges.total, Money.zero);
    await expectLater(
      payOpenBill(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        payments: const [SalePaymentRequest.cash(Money(1000))],
      ),
      throwsA(isA<DiscountTooLarge>()),
    );
  });

  test('menu sama tidak digabung ke baris berdiskon', () async {
    var b = await bill(1);
    b = await itemDiscount(b.items.single, tenPercent);
    b = await addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.units(1),
      ),
    );
    expect(b.items, hasLength(2));
    expect(b.items.first.discountAmount, 2500);
    expect(b.items.last.discountAmount, 0);
    expect(b.items.last.lineTotal, 25000);
  });

  test('split per item: persen dibagi, rupiah dibagi sebanding', () async {
    var b = await bill(2);
    b = await itemDiscount(b.items.single, tenPercent);
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.item,
      guests: 2,
    );
    b = await assignPortion(
      store,
      scope,
      staffId: owner(),
      itemId: b.items.single.id,
      guest: 'A',
    );
    expect(b.items, hasLength(2));
    for (final i in b.items) {
      expect(i.discountBp, 1000);
      expect(i.discountAmount, 2500);
      expect(i.lineTotal, 22500);
    }
    expect(b.charges.subtotal, const Money(45000));

    // Batal split: porsi digabung kembali dengan potongan dihitung ulang.
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: null,
    );
    expect(b.items.single.quantityMilli, 2000);
    expect(b.items.single.discountAmount, 5000);

    b = await itemDiscount(
      b.items.single,
      const ManualDiscount.amount(Money(5000)),
    );
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.item,
      guests: 2,
    );
    // F1-04h: rupiah dibagi sebanding jumlah porsi.
    b = await assignPortion(
      store,
      scope,
      staffId: owner(),
      itemId: b.items.single.id,
      guest: 'A',
    );
    expect(b.items, hasLength(2));
    for (final i in b.items) {
      expect(i.discountBp, 0);
      expect(i.discountAmount, 2500);
      expect(i.lineTotal, 22500);
    }
    expect(b.charges.subtotal, const Money(45000));
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: null,
    );
    expect(b.items.single.quantityMilli, 2000);
    expect(b.items.single.discountAmount, 5000);
    expect(b.items.single.lineTotal, 45000);
  });

  group('bagi diskon rupiah (F1-04h)', () {
    Future<OpenBill> splitItems(OpenBill b, [int guests = 3]) => setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.item,
      guests: guests,
    );

    Future<OpenBill> give(SaleItem item, String? guest) => assignPortion(
      store,
      scope,
      staffId: owner(),
      itemId: item.id,
      guest: guest,
    );

    SaleItem of(OpenBill b, String? guest) =>
        b.items.singleWhere((i) => i.guestLabel == guest);

    test(
      'ganjil: 1.000 untuk 3 porsi jadi 333/334/333, gabung, batal',
      () async {
        var b = await bill(3);
        b = await itemDiscount(
          b.items.single,
          const ManualDiscount.amount(Money(1000)),
        );
        final subtotal = b.charges.subtotal;
        b = await splitItems(b);
        b = await give(b.items.single, 'A');
        expect(of(b, 'A').discountAmount, 333);
        expect(of(b, null).discountAmount, 667);
        b = await give(of(b, null), 'B');
        expect(of(b, 'B').discountAmount, 334);
        expect(of(b, null).discountAmount, 333);
        expect(b.items.fold(0, (s, i) => s + i.discountAmount), 1000);
        expect(b.charges.subtotal, subtotal);
        for (final i in b.items) {
          expect(i.discountBp, 0);
          expect(i.lineTotal, 25000 - i.discountAmount);
        }

        // Porsi B pindah ke A: digabung, potongan dijumlah.
        b = await give(of(b, 'B'), 'A');
        expect(of(b, 'A').quantityMilli, 2000);
        expect(of(b, 'A').discountAmount, 667);
        expect(b.charges.subtotal, subtotal);

        // Batal split: kembali satu baris dengan potongan asal.
        b = await setBillSplit(
          store,
          scope,
          staffId: owner(),
          billId: b.id,
          mode: null,
        );
        expect(b.items.single.quantityMilli, 3000);
        expect(b.items.single.discountAmount, 1000);
        expect(b.items.single.lineTotal, 74000);
      },
    );

    test('diskon rupiah hampir penuh: tiap porsi ≤ total kotornya', () async {
      var b = await bill(3);
      b = await itemDiscount(
        b.items.single,
        const ManualDiscount.amount(Money(74998)),
      );
      b = await splitItems(b);
      b = await give(b.items.single, 'A');
      b = await give(of(b, null), 'B');
      expect(b.items.map((i) => i.discountAmount).toList()..sort(), [
        24999,
        24999,
        25000,
      ]);
      for (final i in b.items) {
        expect(i.lineTotal, greaterThanOrEqualTo(0));
        expect(i.lineTotal + i.discountAmount, 25000);
      }
    });

    test('potongan Rp 0 karena pembulatan tetap digabung kembali', () async {
      var b = await bill(3);
      b = await itemDiscount(
        b.items.single,
        const ManualDiscount.amount(Money(1)),
      );
      b = await splitItems(b);
      b = await give(b.items.single, 'A');
      expect(of(b, 'A').discountAmount, 0);
      expect(of(b, null).discountAmount, 1);
      b = await give(of(b, null), 'A');
      expect(of(b, 'A').quantityMilli, 2000);
      expect(of(b, 'A').discountAmount, 1);
      b = await setBillSplit(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        mode: null,
      );
      expect(b.items.single.quantityMilli, 3000);
      expect(b.items.single.discountAmount, 1);
    });

    test('porsi rupiah tidak digabung dengan porsi persen', () async {
      var b = await bill(2);
      b = await itemDiscount(
        b.items.single,
        const ManualDiscount.amount(Money(4000)),
      );
      b = await splitItems(b, 2);
      b = await give(b.items.single, 'A');
      // Porsi sisa diubah ke persen, lalu dipindah ke A.
      b = await itemDiscount(of(b, null), tenPercent);
      b = await give(of(b, null), 'A');
      final a = b.items.where((i) => i.guestLabel == 'A').toList();
      expect(a, hasLength(2));
      expect(a.map((i) => i.discountBp).toSet(), {0, 1000});
    });

    test(
      'bayar bagian memakai potongan porsi; nota akhir satu baris',
      () async {
        var b = await bill(2);
        b = await itemDiscount(
          b.items.single,
          const ManualDiscount.amount(Money(5000)),
        );
        b = await splitItems(b, 2);
        b = await give(b.items.single, 'A');
        b = await give(of(b, null), 'B');
        final first = await paySplitPart(
          store,
          scope,
          staffId: owner(),
          billId: b.id,
          guest: 'A',
          payments: const [SalePaymentRequest(method: PaymentMethod.card)],
        );
        expect(first.bill!.split!.part('A').items.single.discountAmount, 2500);
        final last = await paySplitPart(
          store,
          scope,
          staffId: owner(),
          billId: b.id,
          guest: 'B',
          payments: const [SalePaymentRequest(method: PaymentMethod.card)],
        );
        final receipt = last.receipt!;
        expect(
          receipt.payments.fold(0, (s, p) => s + p.amount),
          receipt.sale.total,
        );
        final lines = receipt.items;
        expect(lines.fold(0, (s, i) => s + i.discountAmount), 5000);
      },
    );
  });

  test('baris rupiah satu porsi pindah utuh', () async {
    var b = await bill(1);
    b = await itemDiscount(
      b.items.single,
      const ManualDiscount.amount(Money(5000)),
    );
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.item,
      guests: 2,
    );
    b = await assignPortion(
      store,
      scope,
      staffId: owner(),
      itemId: b.items.single.id,
      guest: 'A',
    );
    final item = b.items.single;
    expect(item.guestLabel, 'A');
    expect(item.discountAmount, 5000);
    expect(item.lineTotal, 20000);
  });

  test('terkunci setelah bayar bagian', () async {
    var b = await bill();
    b = await itemDiscount(b.items.single, tenPercent);
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.equal,
      guests: 2,
    );
    final first = await paySplitPart(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      guest: 'A',
      payments: const [SalePaymentRequest(method: PaymentMethod.card)],
    );
    await expectLater(
      itemDiscount(first.bill!.items.single, null),
      throwsA(isA<SplitLocked>()),
    );
    final done = await paySplitPart(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      guest: 'B',
      payments: const [SalePaymentRequest(method: PaymentMethod.card)],
    );
    expect(done.receipt!.sale.lineDiscountAmount, 10000);
    expect(done.receipt!.sale.total, 103950);
  });

  test('split persen: jumlah potongan tetap meski dibulatkan', () async {
    var b = await bill(3);
    // 75.000 × 3,33% = 2.497,5 → 2.498; per gelas 832,5 → 833.
    b = await itemDiscount(
      b.items.single,
      const ManualDiscount.percent(BasisPoints(333)),
    );
    expect(b.items.single.discountAmount, 2498);
    final total = b.charges.total;
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: SplitMode.item,
      guests: 3,
    );
    for (final guest in ['A', 'B']) {
      final rest = b.items.firstWhere((i) => i.guestLabel == null);
      b = await assignPortion(
        store,
        scope,
        staffId: owner(),
        itemId: rest.id,
        guest: guest,
      );
    }
    expect(b.items, hasLength(3));
    expect(b.items.fold(0, (a, i) => a + i.discountAmount), 2498);
    expect(b.charges.total, total);
    b = await setBillSplit(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      mode: null,
    );
    expect(b.items.single.discountAmount, 2498);
  });

  test('item berdiskon dihapus: penyetuju ikut hilang', () async {
    final sari = await addStaff('Sari', 'cashier');
    final rina = await addStaff('Rina', 'manager');
    var b = await bill(1);
    b = await addBillItem(
      store,
      scope,
      staffId: owner(),
      billId: b.id,
      line: SaleLineRequest(
        variantId: kopi.variants.single.id,
        quantity: Qty.units(1),
      ),
    );
    b = await itemDiscount(
      b.items.single,
      tenPercent,
      staffId: sari.id,
      approverId: rina.id,
    );
    expect(b.sale.discountApprovedBy, rina.id);
    b = await setBillItemQuantity(
      store,
      scope,
      staffId: owner(),
      itemId: b.items.single.id,
      quantity: Qty.zero,
    );
    expect(b.items, isEmpty);
    expect(b.sale.discountApprovedBy, isNull);
  });
}
