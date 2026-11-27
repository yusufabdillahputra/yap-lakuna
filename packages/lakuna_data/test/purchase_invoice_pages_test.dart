import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-12m: beberapa foto per faktur pembelian.
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CatalogProduct gula;
  late StockLocation gudang;

  UuidValue owner() => ctx.owner.id;

  setUp(() async {
    (store, dir) = await openTempStore();
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: const ProductDraft(
        name: 'Gula Pasir 1 kg',
        baseUnit: 'kg',
        variants: [
          VariantDraft(costPrice: Money(14800), sellPrice: Money(17500)),
        ],
      ),
    );
    gula = (await loadProduct(store, scope, id))!;
    gudang = await defaultStockLocation(store, scope);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  PurchaseInvoicePhoto photo(int fill) => PurchaseInvoicePhoto(
    bytes: pngBytes(40 + fill, 30, fill: fill),
    fileName: 'faktur-$fill.png',
  );

  AddInvoicePhoto add(int fill) => AddInvoicePhoto(photo(fill));

  PurchaseRequest request({
    UuidValue? id,
    List<PurchaseInvoicePhotoSlot>? invoicePhotos,
    PurchaseInvoicePhoto? invoicePhoto,
  }) => PurchaseRequest(
    id: id,
    newSupplierName: 'CV Sumber Pangan',
    purchasedOn: DateTime(2026, 11, 3),
    locationId: gudang.id,
    lines: [
      PurchaseLineRequest(
        variantId: gula.variants.single.id,
        quantity: Qty.units(10),
        unitPrice: const Money(14500),
      ),
    ],
    paid: const Money(145000),
    funding: FundingSource.storeCash,
    invoicePhotos: invoicePhotos,
    invoicePhoto: invoicePhoto,
  );

  Future<Purchase> draft(PurchaseRequest r) =>
      savePurchaseDraft(store, scope, staffId: owner(), request: r);

  Future<List<PurchaseInvoicePage>> pages(UuidValue purchaseId) =>
      PurchaseInvoicePage.db.find(
        store.session,
        where: (p) =>
            p.purchaseId.equals(purchaseId) & p.deletedAt.equals(null),
        orderBy: (p) => p.position,
      );

  Future<List<UuidValue>> ids(UuidValue purchaseId) async =>
      (await loadPurchaseDetail(store, scope, purchaseId)).invoiceMediaIds;

  Future<List<int>> widths(UuidValue purchaseId) async => [
    for (final f in await loadPurchaseInvoicePhotos(store, scope, purchaseId))
      (await MediaFile.db.findById(store.session, f.mediaId))!.width,
  ];

  test('draf dengan 3 foto: foto pertama di dokumen, 2 lembar', () async {
    final before = await SyncOutboxEntry.db.count(store.session);
    final p = await draft(request(invoicePhotos: [add(1), add(2), add(3)]));
    expect(p.invoiceMediaId, isNotNull);
    final rows = await pages(p.id);
    expect([for (final r in rows) r.position], [2, 3]);
    expect(rows.every((r) => r.outletId == ctx.outlet.id), isTrue);
    expect(await widths(p.id), [41, 42, 43]);
    final files = await loadPurchaseInvoicePhotos(store, scope, p.id);
    expect(files.first.bytes, photo(1).bytes);
    expect(files.first.mediaId, p.invoiceMediaId);
    expect(await ids(p.id), [for (final f in files) f.mediaId]);
    // 3 media + 2 lembar + supplier + pembelian + baris.
    expect(await SyncOutboxEntry.db.count(store.session), before + 8);
  });

  test('ubah draf tanpa menyentuh foto: lembar tidak ditulis ulang', () async {
    final p = await draft(request(invoicePhotos: [add(1), add(2)]));
    final page = (await pages(p.id)).single;
    final kept = await draft(request(id: p.id));
    expect(kept.invoiceMediaId, p.invoiceMediaId);
    expect((await pages(p.id)).single.version, page.version);

    // Daftar sama persis juga tidak menulis ulang lembar.
    final same = await draft(
      request(
        id: p.id,
        invoicePhotos: [for (final id in await ids(p.id)) KeepInvoicePhoto(id)],
      ),
    );
    expect(same.invoiceMediaId, p.invoiceMediaId);
    expect((await pages(p.id)).single.version, page.version);
  });

  test('hapus foto pertama: foto kedua naik, posisi rapat', () async {
    final p = await draft(request(invoicePhotos: [add(1), add(2), add(3)]));
    final [_, second, third] = await ids(p.id);
    final updated = await draft(
      request(
        id: p.id,
        invoicePhotos: [KeepInvoicePhoto(second), KeepInvoicePhoto(third)],
      ),
    );
    expect(updated.invoiceMediaId, second);
    final rows = await pages(p.id);
    expect([for (final r in rows) (r.position, r.mediaId)], [(2, third)]);
    expect(await widths(p.id), [42, 43]);
    // Lembar lama dihapus lunak, tidak hilang.
    expect(
      await PurchaseInvoicePage.db.count(
        store.session,
        where: (r) => r.purchaseId.equals(p.id),
      ),
      2,
    );
  });

  test('tambah di akhir dan hapus di tengah lewat draf', () async {
    final p = await draft(request(invoicePhotos: [add(1), add(2), add(3)]));
    final [first, _, third] = await ids(p.id);
    await draft(
      request(
        id: p.id,
        invoicePhotos: [
          KeepInvoicePhoto(first),
          KeepInvoicePhoto(third),
          add(4),
        ],
      ),
    );
    expect(await widths(p.id), [41, 43, 44]);
    expect([for (final r in await pages(p.id)) r.position], [2, 3]);
  });

  test('foto kembar diabaikan; foto ke-6 ditolak', () async {
    final p = await draft(request(invoicePhotos: [add(1), add(1), add(2)]));
    expect(await widths(p.id), [41, 42]);

    await expectLater(
      draft(request(invoicePhotos: [for (var i = 1; i <= 6; i++) add(i)])),
      throwsA(isA<PurchaseInvoicePhotoLimit>()),
    );
    expect(await Purchase.db.count(store.session), 1);
  });

  test('foto yang tidak milik pembelian ini ditolak', () async {
    final a = await draft(request(invoicePhotos: [add(1)]));
    final b = await draft(request(invoicePhotos: [add(2)]));
    await expectLater(
      draft(
        request(id: b.id, invoicePhotos: [KeepInvoicePhoto(a.invoiceMediaId!)]),
      ),
      throwsA(isA<PurchaseInvoicePhotoInvalid>()),
    );
    expect(await widths(b.id), [42]);
  });

  test('terima barang membawa daftar foto', () async {
    final p = await draft(request(invoicePhotos: [add(1)]));
    final [first] = await ids(p.id);
    final received = await receivePurchase(
      store,
      scope,
      staffId: owner(),
      request: request(
        id: p.id,
        invoicePhotos: [KeepInvoicePhoto(first), add(2)],
      ),
    );
    expect(received.status, PurchaseStatus.received);
    expect(await widths(p.id), [41, 42]);
  });

  test(
    'tambah dan hapus di pembelian diterima: versi naik, stok tetap',
    () async {
      final p = await receivePurchase(
        store,
        scope,
        staffId: owner(),
        request: request(),
      );
      final movements = await StockMovement.db.count(store.session);
      var doc = p;
      for (var i = 1; i <= 3; i++) {
        final next = await addPurchaseInvoicePhoto(
          store,
          scope,
          staffId: owner(),
          purchaseId: p.id,
          photo: photo(i),
        );
        expect(next.version, doc.version + 1);
        doc = next;
      }
      expect(await widths(p.id), [41, 42, 43]);

      // Foto sama tidak menulis ulang.
      final same = await addPurchaseInvoicePhoto(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
        photo: photo(2),
      );
      expect(same.version, doc.version);

      final [first, ..._] = await ids(p.id);
      final removed = await removePurchaseInvoicePhoto(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
        mediaId: first,
      );
      expect(removed.version, doc.version + 1);
      expect(await widths(p.id), [42, 43]);
      expect(await StockMovement.db.count(store.session), movements);

      // Menghapus foto yang sudah tidak ada tidak menulis ulang.
      final again = await removePurchaseInvoicePhoto(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
        mediaId: first,
      );
      expect(again.version, removed.version);
    },
  );

  test('tambah foto ke-6 ditolak', () async {
    final p = await draft(
      request(invoicePhotos: [for (var i = 1; i <= 5; i++) add(i)]),
    );
    await expectLater(
      addPurchaseInvoicePhoto(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
        photo: photo(6),
      ),
      throwsA(isA<PurchaseInvoicePhotoLimit>()),
    );
    expect((await ids(p.id)).length, 5);
  });

  test('API satu foto mengganti atau mengosongkan semua foto', () async {
    final p = await draft(request(invoicePhotos: [add(1), add(2), add(3)]));
    final replaced = await setPurchaseInvoicePhoto(
      store,
      scope,
      staffId: owner(),
      purchaseId: p.id,
      photo: photo(9),
    );
    expect(await widths(p.id), [49]);
    expect(await pages(p.id), isEmpty);
    expect(replaced.version, p.version + 1);

    await draft(request(id: p.id, invoicePhotos: [add(1), add(2)]));
    await draft(request(id: p.id, invoicePhoto: photo(5)));
    expect(await widths(p.id), [45]);

    await draft(request(id: p.id, invoicePhotos: [add(1), add(2)]));
    await clearPurchaseInvoicePhoto(
      store,
      scope,
      staffId: owner(),
      purchaseId: p.id,
    );
    expect(await ids(p.id), isEmpty);
    expect(await pages(p.id), isEmpty);
  });

  test(
    'berkas belum ada di perangkat: bytes kosong; cabang lain kosong',
    () async {
      final p = await draft(request(invoicePhotos: [add(1), add(2)]));
      final second = (await pages(p.id)).single;
      final media = (await MediaFile.db.findById(
        store.session,
        second.mediaId,
      ))!;
      await File(
        '${store.mediaDirectory}${Platform.pathSeparator}${media.storageKey}',
      ).delete();
      final files = await loadPurchaseInvoicePhotos(store, scope, p.id);
      expect([for (final f in files) f.bytes != null], [true, false]);

      final other = await store.session.db.insertRow(
        Tenant(name: 'Toko Lain', hlc: 'x'),
      );
      final otherScope = CatalogScope(
        tenantId: other.id,
        outletId: ctx.outlet.id,
        deviceId: store.deviceId,
      );
      expect(await loadPurchaseInvoicePhotos(store, otherScope, p.id), isEmpty);
    },
  );
}
