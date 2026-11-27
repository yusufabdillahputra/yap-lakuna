import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Gabung meja (F1-10d).
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CatalogProduct kopi;
  late CatalogProduct nasi;
  late DiningTable m1;
  late DiningTable m2;
  late DiningTable m3;
  late DateTime now;

  UuidValue staff() => ctx.owner.id;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: staff(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

  SaleLineRequest line(CatalogProduct p, [int qty = 1]) => SaleLineRequest(
    variantId: p.variants.single.id,
    quantity: Qty(qty * 1000),
  );

  setUp(() async {
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Susu Aren',
        baseUnit: 'gelas',
        variants: [
          VariantDraft(
            costPrice: Money(9000),
            sellPrice: Money(24000),
            openingStock: Qty(10000),
          ),
        ],
      ),
    );
    nasi = await product(
      const ProductDraft(
        name: 'Nasi Goreng',
        kind: ProductKind.service,
        baseUnit: 'porsi',
        variants: [VariantDraft(sellPrice: Money(31000))],
      ),
    );
    [m1, m2, m3] = await createDiningTables(
      store,
      scope,
      staffId: staff(),
      drafts: const [
        DiningTableDraft(name: 'M1'),
        DiningTableDraft(name: 'M2'),
        DiningTableDraft(name: 'M3'),
      ],
    );
    // *Boleh digabung* diatur dari panel denah; cukup ubah barisnya.
    for (final t in [m1, m2]) {
      await DiningTable.db.updateRow(store.session, t.copyWith(canMerge: true));
    }
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<OpenBill> open(DiningTable t, [int guests = 2]) => openTableBill(
    store,
    scope,
    staffId: staff(),
    tableId: t.id,
    guests: guests,
  );

  Future<OpenBill> add(OpenBill bill, SaleLineRequest l, {String? note}) =>
      addBillItem(
        store,
        scope,
        staffId: staff(),
        billId: bill.id,
        line: l,
        note: note,
        modifierIds: const [],
      );

  Future<OpenBill> merge(OpenBill target, OpenBill source) => mergeOpenBills(
    store,
    scope,
    staffId: staff(),
    targetBillId: target.id,
    sourceBillId: source.id,
  );

  Matcher blocked(BillMergeReason reason) => throwsA(
    isA<BillMergeBlocked>().having((e) => e.reason, 'reason', reason),
  );

  test('item, tiket, tamu pindah; total dihitung ulang dengan diskon '
      'tujuan; meja sumber kosong', () async {
    var a = await open(m1, 2);
    a = await add(a, line(kopi, 2));
    a = await setBillDiscount(
      store,
      scope,
      staffId: staff(),
      billId: a.id,
      discount: const ManualDiscount.percent(BasisPoints(1000)),
    );
    var b = await open(m2, 3);
    b = await add(b, line(nasi), note: 'pedas');
    final sent = await sendToKitchen(
      store,
      scope,
      staffId: staff(),
      billId: b.id,
    );
    b = await add(b, line(kopi));

    final merged = await merge(a, b);
    expect(merged.id, a.id);
    expect(merged.label, 'M1');
    expect(merged.sale.guestCount, 5);
    expect(merged.items.map((i) => i.productName), [
      'Kopi Susu Aren',
      'Nasi Goreng',
      'Kopi Susu Aren',
    ]);
    final nasiItem = merged.items[1];
    expect(nasiItem.note, 'pedas');
    expect(nasiItem.kitchenStatus, KitchenStatus.sent);
    expect(merged.items[2].kitchenStatus, KitchenStatus.pending);
    // Item tujuan tidak digabung dengan item sumber yang sama.
    expect(merged.items, hasLength(3));
    // (2 × 24.000 + 31.000 + 24.000) − 10 % = 92.700, tanpa service/PB1.
    expect(merged.sale.total, 92700);
    expect(merged.sale.itemCount, 3);

    final outbox = await SyncOutboxEntry.db.find(store.session);
    expect(
      outbox.map((e) => e.entity),
      containsAll(['sale_items', 'kitchen_tickets', 'sales']),
    );
    expect(
      outbox.where((e) => e.entity == 'sales').map((e) => e.rowId),
      containsAll([a.id, b.id]),
    );

    final ticket = await KitchenTicket.db.findById(
      store.session,
      sent.ticket!.id,
    );
    expect(ticket!.saleId, a.id);

    final gone = await Sale.db.findById(store.session, b.id);
    expect(gone!.deletedAt, isNotNull);
    final overview = await diningOverview(store, scope);
    expect(overview.billForTable(m2.id), isNull);
    expect(overview.billForTable(m1.id)!.id, a.id);
    // Meja M2 bisa dibuka lagi.
    final again = await open(m2);
    expect(again.id, isNot(b.id));
  });

  test('nama pelanggan sumber dipakai bila tujuan kosong', () async {
    final a = await open(m1);
    final b = await open(m2);
    await Sale.db.updateRow(
      store.session,
      b.sale.copyWith(customerName: 'Bu Ani'),
    );
    final merged = await merge(a, b);
    expect(merged.sale.customerName, 'Bu Ani');
  });

  test('ditolak: meja tidak boleh digabung, bill sama, take away', () async {
    final a = await open(m1);
    final c = await open(m3);
    await expectLater(merge(a, c), blocked(BillMergeReason.notAllowed));
    await expectLater(merge(c, a), blocked(BillMergeReason.notAllowed));
    await expectLater(merge(a, a), blocked(BillMergeReason.notAllowed));
    final ta = await openTakeAway(store, scope, staffId: staff());
    await expectLater(merge(a, ta), blocked(BillMergeReason.notAllowed));
  });

  test('ditolak: split, diskon sumber, tamu > 99; tanpa menulis', () async {
    var a = await open(m1, 60);
    a = await add(a, line(kopi));
    var b = await open(m2, 40);
    b = await add(b, line(nasi));
    await expectLater(merge(a, b), blocked(BillMergeReason.guests));

    b = await setBillDiscount(
      store,
      scope,
      staffId: staff(),
      billId: b.id,
      discount: const ManualDiscount.amount(Money(1000)),
    );
    await Sale.db.updateRow(store.session, a.sale.copyWith(guestCount: 2));
    await expectLater(merge(a, b), blocked(BillMergeReason.discount));

    b = await setBillDiscount(
      store,
      scope,
      staffId: staff(),
      billId: b.id,
      discount: null,
    );
    await setBillSplit(
      store,
      scope,
      staffId: staff(),
      billId: b.id,
      mode: SplitMode.equal,
    );
    await expectLater(merge(a, b), blocked(BillMergeReason.split));
    await expectLater(merge(b, a), blocked(BillMergeReason.split));

    final items = await SaleItem.db.find(
      store.session,
      where: (i) => i.saleId.equals(b.id),
    );
    expect(items, hasLength(1));
    expect((await Sale.db.findById(store.session, b.id))!.deletedAt, isNull);
  });

  group('jejak gabung (F1-10s)', () {
    Future<StaffMember> addStaff(String name) =>
        store.write(actor: staff(), (w) async {
          final s = await w.stamp();
          return w.insert(
            StaffMember(
              tenantId: ctx.tenant.id,
              name: name,
              pinHash: r'$argon2id$x',
              isActive: true,
              createdBy: staff(),
              updatedBy: staff(),
              hlc: s.hlc.toString(),
              originDeviceId: s.deviceId,
            ),
            s,
          );
        });

    test('bill sumber menunjuk tujuan; rincian nota memuat sumber berantai, '
        'urut waktu gabung', () async {
      await DiningTable.db.updateRow(
        store.session,
        m3.copyWith(canMerge: true),
      );
      final rina = await addStaff('Rina');
      var a = await add(await open(m1), line(kopi));
      var b = await add(await open(m2), line(nasi));
      final c = await add(await open(m3), line(kopi));
      final cNumber = c.sale.billNumber ?? c.sale.number;
      final bNumber = b.sale.billNumber ?? b.sale.number;

      // M3 ke M2 oleh Rina, lalu M2 ke M1 oleh pemilik.
      now = DateTime.utc(2026, 11, 3, 9, 10);
      b = await mergeOpenBills(
        store,
        scope,
        staffId: rina.id,
        targetBillId: b.id,
        sourceBillId: c.id,
      );
      now = DateTime.utc(2026, 11, 3, 9, 20);
      a = await merge(a, b);

      final rows = await Sale.db.find(
        store.session,
        where: (s) => s.id.inSet({b.id, c.id}),
      );
      final byId = {for (final r in rows) r.id: r};
      expect(byId[c.id]!.mergedIntoId, b.id);
      expect(byId[b.id]!.mergedIntoId, a.id);
      expect(byId[b.id]!.deletedAt, isNotNull);
      expect(
        (await Sale.db.findById(store.session, a.id))!.mergedIntoId,
        isNull,
      );

      await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: staff(),
        openingCash: Money.zero,
      );
      final paid = await payOpenBill(
        store,
        scope,
        staffId: staff(),
        billId: a.id,
        payments: [SalePaymentRequest.cash(Money(a.sale.total))],
      );
      final detail = await loadSaleDetail(store, scope, paid.sale.id);
      expect(
        [
          for (final m in detail.mergedBills)
            (m.billNumber, m.tableName, m.mergedAt, m.staffName),
        ],
        [
          (cNumber, 'M3', DateTime.utc(2026, 11, 3, 9, 10), 'Rina'),
          (bNumber, 'M2', DateTime.utc(2026, 11, 3, 9, 20), ctx.owner.name),
        ],
      );

      // Meja M3 dihapus (soft delete): sumbernya tampil tanpa nama meja.
      final m3Row = await DiningTable.db.findById(store.session, m3.id);
      await DiningTable.db.updateRow(
        store.session,
        m3Row!.copyWith(deletedAt: DateTime.utc(2026, 11, 3, 10)),
      );
      final after = await loadSaleDetail(store, scope, paid.sale.id);
      expect([for (final m in after.mergedBills) m.tableName], [null, 'M2']);
    });

    test('nota tanpa gabung: daftar kosong', () async {
      await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: staff(),
        openingCash: Money.zero,
      );
      final a = await add(await open(m1), line(kopi));
      final paid = await payOpenBill(
        store,
        scope,
        staffId: staff(),
        billId: a.id,
        payments: [SalePaymentRequest.cash(Money(a.sale.total))],
      );
      final detail = await loadSaleDetail(store, scope, paid.sale.id);
      expect(detail.mergedBills, isEmpty);
    });
  });
}
