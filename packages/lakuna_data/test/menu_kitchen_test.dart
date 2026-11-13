import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-10g: *Kirim ke tiket dapur* dan *Bisa catatan bebas* per menu.
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CatalogProduct nasi;
  late CatalogProduct air;
  late DiningTable m1;

  UuidValue owner() => ctx.owner.id;

  Future<CatalogProduct> product(ProductDraft draft) async {
    final id = await saveProduct(store, scope, staffId: owner(), draft: draft);
    return (await loadProduct(store, scope, id))!;
  }

  setUp(() async {
    final now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    nasi = await product(
      const ProductDraft(
        name: 'Nasi Goreng',
        kind: ProductKind.service,
        baseUnit: 'porsi',
        variants: [VariantDraft(sellPrice: Money(31000))],
      ),
    );
    air = await product(
      const ProductDraft(
        name: 'Air Mineral',
        kind: ProductKind.service,
        baseUnit: 'botol',
        sendToKitchen: false,
        allowNote: false,
        variants: [VariantDraft(sellPrice: Money(5000))],
      ),
    );
    [m1] = await createDiningTables(
      store,
      scope,
      staffId: owner(),
      drafts: const [DiningTableDraft(name: 'M1')],
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<OpenBill> open() =>
      openTableBill(store, scope, staffId: owner(), tableId: m1.id, guests: 2);

  Future<OpenBill> add(OpenBill b, CatalogProduct p, {String? note}) =>
      addBillItem(
        store,
        scope,
        staffId: owner(),
        billId: b.id,
        line: SaleLineRequest(
          variantId: p.variants.single.id,
          quantity: Qty.one,
        ),
        note: note,
        modifierIds: const [],
      );

  Future<KitchenSendResult> send(OpenBill b) =>
      sendToKitchen(store, scope, staffId: owner(), billId: b.id);

  test('sakelar bawaan aktif; tersimpan dan termuat', () async {
    expect(nasi.sendToKitchen, isTrue);
    expect(nasi.allowNote, isTrue);
    expect(air.sendToKitchen, isFalse);
    expect(air.allowNote, isFalse);
    expect(air.toDraft().sendToKitchen, isFalse);
    expect(air.toDraft().allowNote, isFalse);
    final listed = await listProducts(store, scope);
    final row = listed.firstWhere((p) => p.id == air.id);
    expect(row.sendToKitchen, isFalse);
    expect(row.allowNote, isFalse);
  });

  test('kirim campuran: tiket hanya item dapur; item lain disajikan tanpa '
      'tiket', () async {
    var b = await add(await open(), nasi);
    b = await add(b, air);
    final r = await send(b);
    expect(r.ticket, isNotNull);
    expect(r.items.map((i) => i.productName), ['Nasi Goreng']);
    expect(r.served.map((i) => i.productName), ['Air Mineral']);
    final items = r.bill.items;
    expect(items.map((i) => i.kitchenStatus), [
      KitchenStatus.sent,
      KitchenStatus.served,
    ]);
    expect(items[0].kitchenTicketId, r.ticket!.id);
    expect(items[1].kitchenTicketId, isNull);
    // Item non-dapur terkunci seperti item dapur.
    await expectLater(
      setBillItemQuantity(
        store,
        scope,
        staffId: owner(),
        itemId: items[1].id,
        quantity: const Qty(2000),
      ),
      throwsA(isA<BillItemLocked>()),
    );
  });

  test(
    'hanya item non-dapur: tanpa tiket, nomor harian tidak terpakai',
    () async {
      var b = await add(await open(), air);
      final r = await send(b);
      expect(r.ticket, isNull);
      expect(r.items, isEmpty);
      expect(r.served, hasLength(1));
      expect(r.bill.items.single.kitchenStatus, KitchenStatus.served);
      expect(await KitchenTicket.db.find(store.session), isEmpty);
      await expectLater(send(r.bill), throwsA(isA<NothingToSend>()));

      b = await add(r.bill, nasi);
      final next = await send(b);
      expect(next.ticket!.number, 1);
    },
  );

  test('sakelar dibaca saat kirim', () async {
    final b = await add(await open(), nasi);
    final draft = nasi.toDraft();
    await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: ProductDraft(
        id: draft.id,
        name: draft.name,
        kind: draft.kind,
        baseUnit: draft.baseUnit,
        variants: draft.variants,
        sendToKitchen: false,
      ),
    );
    final r = await send(b);
    expect(r.ticket, isNull);
    expect(r.served, hasLength(1));
  });

  test('catatan diabaikan untuk menu tanpa catatan bebas', () async {
    var b = await add(await open(), air, note: 'dingin');
    expect(b.items.single.note, isNull);
    b = await add(b, nasi, note: 'pedas');
    expect(b.items.last.note, 'pedas');
    // Tanpa catatan → digabung dengan baris yang sama.
    b = await add(b, air, note: 'es');
    expect(b.items.first.quantityMilli, 2000);
  });

  test('catatan terlalu panjang untuk menu tanpa catatan bebas tidak '
      'ditolak', () async {
    final b = await add(await open(), air, note: 'x' * 500);
    expect(b.items.single.note, isNull);
  });

  test('outbox: sakelar produk dan item yang langsung disajikan', () async {
    final before = (await SyncOutboxEntry.db.find(store.session)).length;
    final draft = nasi.toDraft();
    await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: ProductDraft(
        id: draft.id,
        name: draft.name,
        kind: draft.kind,
        baseUnit: draft.baseUnit,
        variants: draft.variants,
        allowNote: false,
      ),
    );
    var entries = (await SyncOutboxEntry.db.find(store.session)).skip(before);
    expect(entries.map((e) => e.entity), contains('products'));
    final b = await add(await open(), air);
    final mid = (await SyncOutboxEntry.db.find(store.session)).length;
    await send(b);
    entries = (await SyncOutboxEntry.db.find(store.session)).skip(mid);
    expect(
      entries.where((e) => e.entity == 'sale_items').map((e) => e.rowId),
      contains(b.items.single.id),
    );
    expect(entries.map((e) => e.entity), isNot(contains('kitchen_tickets')));
  });
}
