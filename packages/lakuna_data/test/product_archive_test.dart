import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// F1-07d: arsip produk.
void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late CatalogProduct kopi;

  UuidValue owner() => ctx.owner.id;

  Future<CatalogProduct> product(String name, String barcode) async {
    final id = await saveProduct(
      store,
      scope,
      staffId: owner(),
      draft: ProductDraft(
        name: name,
        baseUnit: 'sachet',
        variants: [
          VariantDraft(
            barcode: barcode,
            sellPrice: const Money(2000),
            openingStock: Qty.units(5),
          ),
        ],
      ),
    );
    return (await loadProduct(store, scope, id))!;
  }

  setUp(() async {
    now = DateTime.utc(2026, 11, 13, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    kopi = await product('Kopi Sachet', '8990001');
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<void> archive(UuidValue id) =>
      archiveProduct(store, scope, staffId: owner(), productId: id);

  test('arsip menyembunyikan produk, riwayat nota tetap', () async {
    await openCashSession(
      store,
      CashScope.of(ctx),
      staffId: owner(),
      openingCash: Money.zero,
    );
    final sale = await checkoutSale(
      store,
      scope,
      staffId: owner(),
      lines: [
        SaleLineRequest(variantId: kopi.variants.single.id, quantity: Qty.one),
      ],
      payments: const [SalePaymentRequest.cash(Money(2000))],
    );
    now = now.add(const Duration(hours: 1));
    await archive(kopi.id);

    expect(await listProducts(store, scope), isEmpty);
    expect(await loadProduct(store, scope, kopi.id), isNull);
    expect(await countArchivedProducts(store, scope), 1);
    final archived = await listArchivedProducts(store, scope);
    expect(archived.single.name, 'Kopi Sachet');
    expect(archived.single.archivedAt, now);
    expect(archived.single.variants.single.stock, Qty.units(4));

    // Varian tetap utuh; nota lama tetap terbaca.
    final variant = await ProductVariant.db.findById(
      store.session,
      kopi.variants.single.id,
    );
    expect(variant!.deletedAt, isNull);
    final item = await SaleItem.db.findFirstRow(
      store.session,
      where: (i) => i.saleId.equals(sale.sale.id),
    );
    expect(item!.productName, 'Kopi Sachet');

    // Produk diarsipkan tidak bisa dijual lagi.
    await expectLater(
      checkoutSale(
        store,
        scope,
        staffId: owner(),
        lines: [
          SaleLineRequest(
            variantId: kopi.variants.single.id,
            quantity: Qty.one,
          ),
        ],
        payments: const [SalePaymentRequest.cash(Money(2000))],
      ),
      throwsA(isA<SaleItemUnavailable>()),
    );

    // Arsip dua kali: produk sudah tidak ada di katalog.
    await expectLater(archive(kopi.id), throwsA(isA<ProductNotFound>()));
  });

  test('arsip tercatat di outbox sinkronisasi', () async {
    final before = await SyncOutboxEntry.db.count(store.session);
    await archive(kopi.id);
    expect(await SyncOutboxEntry.db.count(store.session), before + 1);
    final row = await Product.db.findById(store.session, kopi.id);
    expect(row!.deletedAt, now);
    expect(row.version, 2);
  });

  test('pulihkan mengembalikan produk ke katalog', () async {
    await archive(kopi.id);
    await restoreProduct(store, scope, staffId: owner(), productId: kopi.id);
    expect((await listProducts(store, scope)).single.name, 'Kopi Sachet');
    expect(await countArchivedProducts(store, scope), 0);
    await expectLater(
      restoreProduct(store, scope, staffId: owner(), productId: kopi.id),
      throwsA(isA<ProductNotFound>()),
    );
  });

  test('pulihkan ditolak bila barcode sudah dipakai produk lain', () async {
    await archive(kopi.id);
    await product('Kopi Baru', '8990001');
    await expectLater(
      restoreProduct(store, scope, staffId: owner(), productId: kopi.id),
      throwsA(
        isA<ProductCodesTaken>().having(
          (e) => e.conflicts.single.takenBy,
          'takenBy',
          'Kopi Baru',
        ),
      ),
    );
    expect(await countArchivedProducts(store, scope), 1);
  });

  test('barcode produk diarsipkan boleh dipakai produk baru', () async {
    await archive(kopi.id);
    final baru = await product('Kopi Baru', '8990001');
    expect(baru.variants.single.barcode, '8990001');
  });

  test('produk tenant lain tidak bisa diarsipkan atau dipulihkan', () async {
    final other = await store.session.db.insertRow(
      Tenant(name: 'Toko Lain', hlc: 'x'),
    );
    final otherScope = CatalogScope(
      tenantId: other.id,
      outletId: ctx.outlet.id,
      deviceId: store.deviceId,
    );
    await expectLater(
      archiveProduct(store, otherScope, staffId: owner(), productId: kopi.id),
      throwsA(isA<ProductNotFound>()),
    );
    await archive(kopi.id);
    expect(await listArchivedProducts(store, otherScope), isEmpty);
    await expectLater(
      restoreProduct(store, otherScope, staffId: owner(), productId: kopi.id),
      throwsA(isA<ProductNotFound>()),
    );
  });
}
