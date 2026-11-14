import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-12b: foto faktur pembelian.
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

  PurchaseInvoicePhoto photo(Uint8List bytes) =>
      PurchaseInvoicePhoto(bytes: bytes, fileName: 'faktur.png');

  PurchaseRequest request({
    UuidValue? id,
    PurchaseInvoicePhoto? invoicePhoto,
    bool removeInvoicePhoto = false,
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
    invoicePhoto: invoicePhoto,
    removeInvoicePhoto: removeInvoicePhoto,
  );

  Future<Purchase> draft(PurchaseRequest r) =>
      savePurchaseDraft(store, scope, staffId: owner(), request: r);

  Future<MediaFile?> mediaOf(Purchase p) async => p.invoiceMediaId == null
      ? null
      : MediaFile.db.findById(store.session, p.invoiceMediaId!);

  test('draf dengan foto: baris media, outbox, isi foto terbaca', () async {
    final before = await SyncOutboxEntry.db.count(store.session);
    final p = await draft(request(invoicePhoto: photo(pngBytes(400, 300))));
    final media = (await mediaOf(p))!;
    expect(media.kind, MediaKind.purchaseInvoice);
    expect(media.outletId, ctx.outlet.id);
    expect(media.width, 400);
    // Baris media + supplier baru + pembelian + barisnya.
    expect(await SyncOutboxEntry.db.count(store.session), before + 4);
    expect(
      await loadPurchaseInvoicePhoto(store, scope, p.id),
      pngBytes(400, 300),
    );
    final detail = await loadPurchaseDetail(store, scope, p.id);
    expect(detail.hasInvoicePhoto, isTrue);
  });

  test('ubah draf tanpa menyentuh foto: foto tetap; hapus foto', () async {
    final p = await draft(request(invoicePhoto: photo(pngBytes(400, 300))));
    final kept = await draft(request(id: p.id));
    expect(kept.invoiceMediaId, p.invoiceMediaId);

    final cleared = await draft(request(id: p.id, removeInvoicePhoto: true));
    expect(cleared.invoiceMediaId, isNull);
    expect(await loadPurchaseInvoicePhoto(store, scope, p.id), isNull);
    expect(
      (await loadPurchaseDetail(store, scope, p.id)).hasInvoicePhoto,
      isFalse,
    );
  });

  test('terima barang dengan foto baru menggantikan foto draf', () async {
    final p = await draft(request(invoicePhoto: photo(pngBytes(400, 300))));
    final received = await receivePurchase(
      store,
      scope,
      staffId: owner(),
      request: request(
        id: p.id,
        invoicePhoto: photo(pngBytes(200, 100, fill: 7)),
      ),
    );
    expect(received.status, PurchaseStatus.received);
    expect((await mediaOf(received))!.width, 200);
  });

  test('berkas bukan gambar atau terlalu besar ditolak', () async {
    await expectLater(
      draft(request(invoicePhoto: photo(Uint8List.fromList([1, 2, 3])))),
      throwsA(isA<PurchaseInvoicePhotoInvalid>()),
    );
    final big = Uint8List(PurchaseLimits.invoicePhotoMaxBytes + 1)
      ..setAll(0, pngBytes(10, 10));
    await expectLater(
      draft(request(invoicePhoto: photo(big))),
      throwsA(isA<PurchaseInvoicePhotoInvalid>()),
    );
    expect(await Purchase.db.count(store.session), 0);
  });

  test(
    'set dan hapus foto pembelian diterima: versi naik, stok tetap',
    () async {
      final p = await receivePurchase(
        store,
        scope,
        staffId: owner(),
        request: request(),
      );
      final movements = await StockMovement.db.count(store.session);
      final set = await setPurchaseInvoicePhoto(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
        photo: photo(pngBytes(300, 300)),
      );
      expect(set.version, p.version + 1);
      expect(set.status, PurchaseStatus.received);
      expect((await mediaOf(set))!.kind, MediaKind.purchaseInvoice);
      expect(await loadPurchaseInvoicePhoto(store, scope, p.id), isNotNull);

      final cleared = await clearPurchaseInvoicePhoto(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
      );
      expect(cleared.invoiceMediaId, isNull);
      expect(cleared.version, set.version + 1);
      expect(await StockMovement.db.count(store.session), movements);

      await expectLater(
        setPurchaseInvoicePhoto(
          store,
          scope,
          staffId: owner(),
          purchaseId: p.id,
          photo: photo(Uint8List.fromList([9, 9])),
        ),
        throwsA(isA<PurchaseInvoicePhotoInvalid>()),
      );
    },
  );

  test('cabang lain dan staf tanpa izin ditolak', () async {
    final p = await draft(request());
    final other = await store.session.db.insertRow(
      Tenant(name: 'Toko Lain', hlc: 'x'),
    );
    final otherScope = CatalogScope(
      tenantId: other.id,
      outletId: ctx.outlet.id,
      deviceId: store.deviceId,
    );
    await expectLater(
      setPurchaseInvoicePhoto(
        store,
        otherScope,
        staffId: owner(),
        purchaseId: p.id,
        photo: photo(pngBytes(10, 10)),
      ),
      throwsA(isA<PurchaseActorNotPermitted>()),
    );
    expect(await loadPurchaseInvoicePhoto(store, otherScope, p.id), isNull);

    final actor = owner();
    final kasir = await store.write(actor: actor, (w) async {
      final s = await w.stamp();
      final staff = await w.insert(
        StaffMember(
          tenantId: ctx.tenant.id,
          name: 'Sari',
          pinHash: r'$argon2id$x',
          isActive: true,
          createdBy: actor,
          updatedBy: actor,
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
          roleName: 'cashier',
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      return staff;
    });
    await expectLater(
      clearPurchaseInvoicePhoto(
        store,
        scope,
        staffId: kasir.id,
        purchaseId: p.id,
      ),
      throwsA(isA<PurchaseActorNotPermitted>()),
    );
  });

  test('tanpa perubahan tidak menulis ulang; draf terhapus ditolak', () async {
    final p = await draft(request());
    final outbox = await SyncOutboxEntry.db.count(store.session);
    final same = await clearPurchaseInvoicePhoto(
      store,
      scope,
      staffId: owner(),
      purchaseId: p.id,
    );
    expect(same.version, p.version);
    final set = await setPurchaseInvoicePhoto(
      store,
      scope,
      staffId: owner(),
      purchaseId: p.id,
      photo: photo(pngBytes(50, 50)),
    );
    final again = await setPurchaseInvoicePhoto(
      store,
      scope,
      staffId: owner(),
      purchaseId: p.id,
      photo: photo(pngBytes(50, 50)),
    );
    expect(again.version, set.version);
    // Hanya baris media + dokumen dari pemasangan pertama.
    expect(await SyncOutboxEntry.db.count(store.session), outbox + 2);

    await deletePurchaseDraft(store, scope, staffId: owner(), purchaseId: p.id);
    await expectLater(
      setPurchaseInvoicePhoto(
        store,
        scope,
        staffId: owner(),
        purchaseId: p.id,
        photo: photo(pngBytes(50, 50)),
      ),
      throwsA(isA<PurchaseNotFound>()),
    );
    expect(await loadPurchaseInvoicePhoto(store, scope, p.id), isNull);
  });
}
