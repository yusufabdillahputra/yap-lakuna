import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late DateTime now;
  late StockLocation etalase;
  late CatalogVariant telur; // kg, stok 12,5, HPP 25.500
  late CatalogVariant kopi; // sachet, stok 2, min 20, modal 1.500
  late CatalogVariant sabun; // pcs, stok 15, modal 18.000
  late CatalogVariant pulsa; // jasa

  Future<CatalogVariant> product(ProductDraft draft) async {
    final id = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: draft,
    );
    return (await loadProduct(store, scope, id))!.variants.single;
  }

  setUp(() async {
    // 2026-11-03 09.00 UTC = 16.00 WIB.
    now = DateTime.utc(2026, 11, 3, 9);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    etalase = await defaultStockLocation(store, scope);
    telur = await product(
      const ProductDraft(
        name: 'Telur Ayam',
        baseUnit: 'kg',
        variants: [
          VariantDraft(
            costPrice: Money(25500),
            sellPrice: Money(28000),
            openingStock: Qty(12500),
            minStock: Qty(15000),
          ),
        ],
      ),
    );
    kopi = await product(
      const ProductDraft(
        name: 'Kopi Sachet',
        baseUnit: 'sachet',
        variants: [
          VariantDraft(
            barcode: '8990001',
            costPrice: Money(1500),
            sellPrice: Money(2000),
            openingStock: Qty(2000),
            minStock: Qty(20000),
          ),
        ],
      ),
    );
    sabun = await product(
      const ProductDraft(
        name: 'Sabun Cuci 800 g',
        baseUnit: 'pcs',
        variants: [
          VariantDraft(
            costPrice: Money(18000),
            sellPrice: Money(21000),
            openingStock: Qty(15000),
          ),
        ],
      ),
    );
    pulsa = await product(
      const ProductDraft(
        name: 'Isi Pulsa',
        kind: ProductKind.service,
        baseUnit: 'kali',
        variants: [VariantDraft(sellPrice: Money(2000))],
      ),
    );
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<StockAdjustmentResult> adjust(
    List<AdjustmentLine> lines, {
    StockAdjustmentReason reason = StockAdjustmentReason.routineCheck,
    UuidValue? locationId,
    String? note,
  }) => saveStockAdjustment(
    store,
    scope,
    staffId: ctx.owner.id,
    locationId: locationId ?? etalase.id,
    reason: reason,
    note: note,
    lines: lines,
  );

  Matcher invalid(StockAdjustmentError error) => throwsA(
    isA<StockAdjustmentInvalid>().having((e) => e.error, 'error', error),
  );

  group('daftar stok', () {
    test('hanya barang, urut nama, dengan minimum dan nilai HPP', () async {
      final rows = await stockList(store, scope);
      expect(rows.map((r) => r.productName), [
        'Kopi Sachet',
        'Sabun Cuci 800 g',
        'Telur Ayam',
      ]);
      final t = rows.last;
      expect(t.stock, const Qty(12500));
      expect(t.minStock, const Qty(15000));
      expect(t.baseUnit, 'kg');
      expect(t.unitCost, const Money(25500));
      expect(t.value, const Money(318750));
      expect(t.belowMinimum, isTrue);
      expect(rows[1].belowMinimum, isFalse); // minimum 0 = tidak dipantau
    });

    test(
      'di bawah minimum urut paling kritis (stok/minimum terkecil)',
      () async {
        final rows = await belowMinimumStock(store, scope);
        expect(rows.map((r) => r.productName), ['Kopi Sachet', 'Telur Ayam']);
      },
    );
  });

  group('penyesuaian', () {
    test(
      'multi-baris: dokumen, item, pergerakan, outbox, satu transaksi',
      () async {
        final outboxBefore = await SyncOutboxEntry.db.count(store.session);
        final result = await adjust([
          AdjustmentLine(
            variantId: telur.id,
            physical: const Qty(12200),
            note: 'Pecah',
          ),
          AdjustmentLine(variantId: kopi.id, physical: const Qty(2000)),
          AdjustmentLine(
            variantId: sabun.id,
            physical: Qty.units(14),
            note: 'Hilang',
          ),
        ], note: 'Cek rutin mingguan');

        final a = result.adjustment;
        expect(a.number, 'SA-PST-K01-261103-0001');
        expect(a.reason, StockAdjustmentReason.routineCheck);
        expect(a.note, 'Cek rutin mingguan');
        expect(a.staffId, ctx.owner.id);
        expect(a.totalValue, -25650); // −7.650 − 18.000
        expect(result.items, hasLength(3));
        final t = result.items.first;
        expect(t.systemMilli, 12500);
        expect(t.physicalMilli, 12200);
        expect(t.differenceMilli, -300);
        expect(t.unitCost, 25500);
        expect(t.value, -7650);
        expect(t.note, 'Pecah');
        expect(result.items[1].differenceMilli, 0);

        // Baris selisih 0 tidak membuat pergerakan.
        final moves = await StockMovement.db.find(
          store.session,
          where: (m) => m.sourceId.equals(a.id),
        );
        expect(moves, hasLength(2));
        expect(
          moves.every((m) => m.sourceType == StockSourceType.adjustment),
          isTrue,
        );
        expect(
          await stockOnHand(store, scope, variantId: telur.id),
          const Qty(12200),
        );
        expect(
          await stockOnHand(store, scope, variantId: sabun.id),
          Qty.units(14),
        );
        // dokumen + 3 item + 2 pergerakan
        expect(await SyncOutboxEntry.db.count(store.session) - outboxBefore, 6);
      },
    );

    test('selisih dihitung dari stok saat disimpan', () async {
      await store.write(
        actor: ctx.owner.id,
        (w) => recordStockMovement(
          w,
          scope,
          locationId: etalase.id,
          variantId: sabun.id,
          quantity: Qty.units(-3),
          unitCost: const Money(18000),
          sourceType: StockSourceType.sale,
        ),
      );
      final result = await adjust([
        AdjustmentLine(variantId: sabun.id, physical: Qty.units(11)),
      ]);
      expect(result.items.single.systemMilli, 12000);
      expect(result.items.single.differenceMilli, -1000);
    });

    test(
      'masuk (fisik lebih banyak) memakai HPP sehingga rata-rata tetap',
      () async {
        final result = await adjust([
          AdjustmentLine(variantId: kopi.id, physical: Qty.units(5)),
        ]);
        expect(result.items.single.value, 4500);
        final level = await StockLevel.db.findFirstRow(
          store.session,
          where: (l) => l.variantId.equals(kopi.id),
        );
        expect(level!.avgCost, 1500);
        expect(level.quantityMilli, 5000);
      },
    );

    test('nomor urut per hari per perangkat', () async {
      await adjust([AdjustmentLine(variantId: kopi.id, physical: Qty.one)]);
      expect(
        await nextStockAdjustmentNumber(store, scope),
        'SA-PST-K01-261103-0002',
      );
      await adjust([AdjustmentLine(variantId: kopi.id, physical: Qty.zero)]);
      now = DateTime.utc(2026, 11, 3, 18); // 01.00 WIB tanggal 4
      expect(
        await nextStockAdjustmentNumber(store, scope),
        'SA-PST-K01-261104-0001',
      );
    });

    test('validasi: tidak ada yang tersimpan', () async {
      await expectLater(adjust([]), invalid(StockAdjustmentError.empty));
      await expectLater(
        adjust([AdjustmentLine(variantId: kopi.id, physical: const Qty(-1))]),
        invalid(StockAdjustmentError.negative),
      );
      await expectLater(
        adjust([
          AdjustmentLine(variantId: kopi.id, physical: Qty.one),
          AdjustmentLine(variantId: kopi.id, physical: Qty.units(3)),
        ]),
        invalid(StockAdjustmentError.duplicate),
      );
      await expectLater(
        adjust([AdjustmentLine(variantId: pulsa.id, physical: Qty.one)]),
        invalid(StockAdjustmentError.notGoods),
      );
      await expectLater(
        adjust([
          AdjustmentLine(
            variantId: UuidValue.fromString(newId()),
            physical: Qty.one,
          ),
        ]),
        invalid(StockAdjustmentError.unknownVariant),
      );
      await expectLater(
        adjust([AdjustmentLine(variantId: kopi.id, physical: const Qty(2000))]),
        invalid(StockAdjustmentError.noChange),
      );
      await expectLater(
        adjust([
          AdjustmentLine(variantId: kopi.id, physical: Qty.one, note: 'x' * 61),
        ]),
        invalid(StockAdjustmentError.noteTooLong),
      );
      await expectLater(
        adjust([
          AdjustmentLine(variantId: kopi.id, physical: Qty.one),
        ], locationId: UuidValue.fromString(newId())),
        invalid(StockAdjustmentError.unknownLocation),
      );
      expect(await StockAdjustment.db.count(store.session), 0);
      expect(await StockAdjustmentItem.db.count(store.session), 0);
    });

    test('penyesuaian terakhir: ringkasan terbaru dulu', () async {
      await adjust([AdjustmentLine(variantId: kopi.id, physical: Qty.one)]);
      now = now.add(const Duration(minutes: 5));
      await adjust([
        AdjustmentLine(variantId: sabun.id, physical: Qty.units(14)),
        AdjustmentLine(variantId: telur.id, physical: const Qty(12000)),
      ], reason: StockAdjustmentReason.damaged);
      final list = await recentStockAdjustments(store, scope);
      expect(list.map((a) => a.number), [
        'SA-PST-K01-261103-0002',
        'SA-PST-K01-261103-0001',
      ]);
      expect(list.first.itemCount, 2);
      expect(list.first.reason, StockAdjustmentReason.damaged);
      expect(list.first.staffName, 'Yusuf');
      expect(list.first.locationName, etalase.name);
      expect(list.first.totalValue, const Money(-18000 - 12750));
    });
  });

  group('kartu stok', () {
    test('saldo berjalan dan keterangan per sumber', () async {
      await openCashSession(
        store,
        CashScope.of(ctx),
        staffId: ctx.owner.id,
        openingCash: Money.zero,
      );
      now = now.add(const Duration(hours: 1));
      final sale = await checkoutSale(
        store,
        scope,
        staffId: ctx.owner.id,
        lines: [SaleLineRequest(variantId: sabun.id, quantity: Qty.units(2))],
        payments: const [SalePaymentRequest.cash(Money(100000))],
      );
      now = now.add(const Duration(hours: 1));
      final adj = await adjust([
        AdjustmentLine(
          variantId: sabun.id,
          physical: Qty.units(12),
          note: 'Hilang',
        ),
      ], reason: StockAdjustmentReason.lost);

      final card = await stockCard(store, scope, variantId: sabun.id);
      expect(card.openingBalance, Qty.zero);
      expect(card.current, Qty.units(12));
      expect(card.entries.map((e) => e.sourceType), [
        StockSourceType.opening,
        StockSourceType.sale,
        StockSourceType.adjustment,
      ]);
      expect(card.entries.map((e) => e.quantity), [
        Qty.units(15),
        Qty.units(-2),
        Qty.units(-1),
      ]);
      expect(card.entries.map((e) => e.balance), [
        Qty.units(15),
        Qty.units(13),
        Qty.units(12),
      ]);
      expect(card.entries[1].documentNumber, sale.sale.number);
      expect(card.entries[2].documentNumber, adj.adjustment.number);
      expect(card.entries[2].reason, StockAdjustmentReason.lost);
      expect(card.entries[2].note, 'Hilang');
      expect(card.entries[2].staffName, 'Yusuf');
    });

    test(
      'batas baris: saldo awal dari pergerakan yang tidak ditampilkan',
      () async {
        for (var i = 0; i < 3; i++) {
          now = now.add(const Duration(minutes: 1));
          await adjust([
            AdjustmentLine(variantId: kopi.id, physical: Qty.units(3 + i)),
          ]);
        }
        final card = await stockCard(
          store,
          scope,
          variantId: kopi.id,
          limit: 2,
        );
        expect(card.entries, hasLength(2));
        expect(card.openingBalance, Qty.units(3));
        expect(card.entries.last.balance, Qty.units(5));
        expect(card.current, Qty.units(5));
      },
    );
  });

  group('lokasi stok', () {
    test('tambah, ganti nama, duplikat ditolak, dipakai penyesuaian', () async {
      final gudang = await createStockLocation(
        store,
        scope,
        staffId: ctx.owner.id,
        name: ' Gudang ',
      );
      expect(gudang.name, 'Gudang');
      expect(gudang.isDefault, isFalse);
      await expectLater(
        createStockLocation(
          store,
          scope,
          staffId: ctx.owner.id,
          name: 'gudang',
        ),
        throwsA(
          isA<StockLocationInvalid>().having(
            (e) => e.error,
            'error',
            StockLocationNameError.duplicate,
          ),
        ),
      );
      await renameStockLocation(
        store,
        scope,
        staffId: ctx.owner.id,
        locationId: gudang.id,
        name: 'Gudang Belakang',
      );
      // Ganti nama ke namanya sendiri (beda huruf) boleh.
      await renameStockLocation(
        store,
        scope,
        staffId: ctx.owner.id,
        locationId: gudang.id,
        name: 'gudang belakang',
      );
      final locations = await stockLocations(store, scope);
      expect(locations.map((l) => l.name), [etalase.name, 'gudang belakang']);

      await adjust([
        AdjustmentLine(variantId: kopi.id, physical: Qty.units(10)),
      ], locationId: gudang.id);
      expect(
        await stockOnHand(
          store,
          scope,
          variantId: kopi.id,
          locationId: gudang.id,
        ),
        Qty.units(10),
      );
      final rows = await stockList(store, scope, locationId: gudang.id);
      expect(
        rows.firstWhere((r) => r.variantId == kopi.id).stock,
        Qty.units(10),
      );
    });

    test('minimum hanya berlaku di lokasi bawaan, sama dengan daftar '
        'produk', () async {
      final gudang = await createStockLocation(
        store,
        scope,
        staffId: ctx.owner.id,
        name: 'Gudang',
      );
      final rows = await stockList(store, scope, locationId: gudang.id);
      expect(rows.every((r) => r.minStock == Qty.zero), isTrue);
      expect(rows.any((r) => r.belowMinimum), isFalse);
      expect(
        await belowMinimumStock(store, scope, locationId: gudang.id),
        isEmpty,
      );
      final card = await stockCard(
        store,
        scope,
        variantId: kopi.id,
        locationId: gudang.id,
      );
      expect(card.minStock, Qty.zero);
      // Di etalase minimum tetap terbaca.
      expect(
        (await stockCard(store, scope, variantId: kopi.id)).minStock,
        Qty.units(20),
      );
    });
  });
}
