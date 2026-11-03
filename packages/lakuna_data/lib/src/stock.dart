import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show ColumnOrderingOperations, DatabaseSession, Transaction;

import 'store.dart';
import 'store_setup.dart';
import 'sync_tx.dart';

/// Batas query katalog dan stok: tenant, cabang, dan perangkat (F1-07).
class CatalogScope {
  const CatalogScope({
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
  });

  factory CatalogScope.of(StoreContext ctx) => CatalogScope(
    tenantId: ctx.tenant.id,
    outletId: ctx.outlet.id,
    deviceId: ctx.device.id,
  );

  final UuidValue tenantId;
  final UuidValue outletId;
  final UuidValue deviceId;
}

/// Lokasi stok bawaan cabang ([defaultStockLocationName], dibuat saat setup).
Future<StockLocation> defaultStockLocation(
  LakunaStore store,
  CatalogScope scope, {
  Transaction? transaction,
}) => _defaultLocation(store.session, scope, transaction);

Future<StockLocation> _defaultLocation(
  DatabaseSession session,
  CatalogScope scope,
  Transaction? transaction,
) async {
  final location = await StockLocation.db.findFirstRow(
    session,
    where: (l) =>
        l.tenantId.equals(scope.tenantId) &
        l.outletId.equals(scope.outletId) &
        l.deletedAt.equals(null),
    orderByList: (l) => [l.isDefault.desc(), l.createdAt],
    transaction: transaction,
  );
  if (location == null) {
    throw StateError('Cabang ${scope.outletId} belum punya lokasi stok.');
  }
  return location;
}

/// Lokasi bawaan di dalam transaksi tulis [w].
Future<StockLocation> defaultStockLocationIn(SyncTx w, CatalogScope scope) =>
    _defaultLocation(w.session, scope, w.transaction);

/// Mencatat satu pergerakan stok (ledger, ikut outbox) dan memperbarui cache
/// `stock_levels` di transaksi yang sama. [quantity] dalam satuan dasar,
/// positif = masuk. [stamp] dipakai bila penulisan lain di transaksi ini
/// sudah membuat stempel.
Future<StockMovement> recordStockMovement(
  SyncTx w,
  CatalogScope scope, {
  required UuidValue locationId,
  required UuidValue variantId,
  required Qty quantity,
  required Money unitCost,
  required StockSourceType sourceType,
  UuidValue? sourceId,
  String? note,
  SyncStamp? stamp,
}) async {
  if (quantity.milli == 0) {
    throw ArgumentError.value(quantity.milli, 'quantity', 'tidak boleh nol');
  }
  final s = stamp ?? await w.stamp();
  final movement = await w.insert(
    StockMovement(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      stockLocationId: locationId,
      variantId: variantId,
      quantityMilli: quantity.milli,
      unitCost: unitCost.value,
      sourceType: sourceType,
      sourceId: sourceId,
      occurredAt: s.now,
      note: note,
      createdAt: s.now,
      updatedAt: s.now,
      createdBy: w.actor,
      updatedBy: w.actor,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
  await _applyToLevel(
    w.session,
    w.transaction,
    locationId: locationId,
    variantId: variantId,
    quantity: quantity,
    unitCost: unitCost,
    sourceType: sourceType,
  );
  return movement;
}

/// HPP rata-rata lokasi setelah satu pergerakan: masuk memakai rata-rata
/// tertimbang; retur beli keluar pada HPP mendarat barisnya
/// ([averageCostAfterReturn]); keluar lainnya tidak mengubah rata-rata.
Money levelAverageCost({
  required Qty onHand,
  required Money avgCost,
  required Qty quantity,
  required Money unitCost,
  required StockSourceType sourceType,
}) => sourceType == StockSourceType.purchaseReturn && quantity.milli < 0
    ? averageCostAfterReturn(
        onHand: onHand,
        avgCost: avgCost,
        returned: -quantity,
        unitCost: unitCost,
      )
    : movingAverageCost(
        onHand: onHand,
        avgCost: avgCost,
        incoming: quantity,
        unitCost: unitCost,
      );

Future<void> _applyToLevel(
  DatabaseSession session,
  Transaction transaction, {
  required UuidValue locationId,
  required UuidValue variantId,
  required Qty quantity,
  required Money unitCost,
  required StockSourceType sourceType,
}) async {
  final level = await StockLevel.db.findFirstRow(
    session,
    where: (l) =>
        l.stockLocationId.equals(locationId) & l.variantId.equals(variantId),
    transaction: transaction,
  );
  final onHand = Qty(level?.quantityMilli ?? 0);
  final avg = levelAverageCost(
    onHand: onHand,
    avgCost: Money(level?.avgCost ?? 0),
    quantity: quantity,
    unitCost: unitCost,
    sourceType: sourceType,
  );
  if (level == null) {
    await StockLevel.db.insertRow(
      session,
      StockLevel(
        stockLocationId: locationId,
        variantId: variantId,
        quantityMilli: quantity.milli,
        avgCost: avg.value,
      ),
      transaction: transaction,
    );
  } else {
    await StockLevel.db.updateRow(
      session,
      level.copyWith(
        quantityMilli: (onHand + quantity).milli,
        avgCost: avg.value,
      ),
      transaction: transaction,
    );
  }
}

/// Saldo stok [variantId] di [locationId] (bawaan: lokasi bawaan cabang).
Future<Qty> stockOnHand(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue variantId,
  UuidValue? locationId,
}) async {
  final location = locationId ?? (await defaultStockLocation(store, scope)).id;
  final level = await StockLevel.db.findFirstRow(
    store.session,
    where: (l) =>
        l.stockLocationId.equals(location) & l.variantId.equals(variantId),
  );
  return Qty(level?.quantityMilli ?? 0);
}

/// Membangun ulang cache `stock_levels` dari ledger `stock_movements` (mis.
/// setelah sync tarik di Fase 2).
Future<void> rebuildStockLevels(LakunaStore store) =>
    store.session.db.transaction((tx) async {
      final session = store.session;
      await StockLevel.db.deleteWhere(
        session,
        where: (l) => l.id.notEquals(null),
        transaction: tx,
      );
      final movements = await StockMovement.db.find(
        session,
        where: (m) => m.deletedAt.equals(null),
        orderByList: (m) => [m.occurredAt, m.id],
        transaction: tx,
      );
      final levels = <(UuidValue, UuidValue), (Qty, Money)>{};
      for (final m in movements) {
        final key = (m.stockLocationId, m.variantId);
        final (onHand, avg) = levels[key] ?? (Qty.zero, Money.zero);
        final quantity = Qty(m.quantityMilli);
        levels[key] = (
          onHand + quantity,
          levelAverageCost(
            onHand: onHand,
            avgCost: avg,
            quantity: quantity,
            unitCost: Money(m.unitCost),
            sourceType: m.sourceType,
          ),
        );
      }
      if (levels.isEmpty) return;
      await StockLevel.db.insert(session, [
        for (final MapEntry(key: (location, variant), value: (qty, avg))
            in levels.entries)
          StockLevel(
            stockLocationId: location,
            variantId: variant,
            quantityMilli: qty.milli,
            avgCost: avg.value,
          ),
      ], transaction: tx);
    });
