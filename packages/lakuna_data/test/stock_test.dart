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
  late UuidValue variantId;
  late StockLocation location;

  setUp(() async {
    (store, dir) = await openTempStore(
      clock: () => DateTime.utc(2026, 11, 3, 9),
    );
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    final productId = await saveProduct(
      store,
      scope,
      staffId: ctx.owner.id,
      draft: const ProductDraft(
        name: 'Kopi Sachet',
        baseUnit: 'sachet',
        variants: [VariantDraft(costPrice: Money(1500))],
      ),
    );
    variantId = (await loadProduct(
      store,
      scope,
      productId,
    ))!.variants.single.id;
    location = await defaultStockLocation(store, scope);
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<void> move(int units, int cost) => store.write(
    actor: ctx.owner.id,
    (w) => recordStockMovement(
      w,
      scope,
      locationId: location.id,
      variantId: variantId,
      quantity: Qty.units(units),
      unitCost: Money(cost),
      sourceType: StockSourceType.adjustment,
    ),
  );

  Future<StockLevel?> level() => StockLevel.db.findFirstRow(
    store.session,
    where: (l) =>
        l.stockLocationId.equals(location.id) & l.variantId.equals(variantId),
  );

  test('lokasi bawaan adalah Etalase', () {
    expect(location.name, 'Etalase');
    expect(location.isDefault, isTrue);
  });

  test('pergerakan masuk ledger + outbox dan memperbarui cache', () async {
    await move(10, 1000);
    await move(5, 1600);
    await move(-3, 9999);

    final movements = await StockMovement.db.find(store.session);
    expect(movements.map((m) => m.quantityMilli), [10000, 5000, -3000]);
    expect(movements.first.createdBy, ctx.owner.id);
    final outbox = await SyncOutboxEntry.db.find(store.session);
    expect(outbox.where((e) => e.entity == 'stock_movements'), hasLength(3));

    final l = await level();
    expect(l!.quantityMilli, 12000);
    expect(l.avgCost, 1200);
    expect(
      await stockOnHand(store, scope, variantId: variantId),
      Qty.units(12),
    );
  });

  test('jumlah nol ditolak', () async {
    await expectLater(move(0, 1000), throwsA(isA<ArgumentError>()));
  });

  test('rebuildStockLevels membangun ulang cache dari ledger', () async {
    await move(10, 1000);
    await move(5, 1600);
    await StockLevel.db.deleteWhere(
      store.session,
      where: (l) => l.id.notEquals(null),
    );
    expect(await level(), isNull);

    await rebuildStockLevels(store);
    final l = await level();
    expect(l!.quantityMilli, 15000);
    expect(l.avgCost, 1200);
  });
}
