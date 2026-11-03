import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show ColumnOrderingOperations, DatabaseSession, Transaction;

import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Layar Stok (F1-08, 1.18): daftar stok, penyesuaian, kartu stok, lokasi.

// --- Daftar stok ------------------------------------------------------------

/// Satu varian barang di daftar stok satu lokasi.
class StockRow {
  const StockRow({
    required this.variantId,
    required this.productId,
    required this.productName,
    required this.variantName,
    required this.baseUnit,
    required this.stock,
    required this.minStock,
    required this.unitCost,
    this.sku,
    this.barcode,
  });

  final UuidValue variantId;
  final UuidValue productId;
  final String productName;

  /// Kosong bila produk hanya punya satu varian.
  final String variantName;
  final String baseUnit;
  final String? sku;
  final String? barcode;
  final Qty stock;
  final Qty minStock;

  /// HPP per satuan dasar ([adjustmentUnitCost]).
  final Money unitCost;

  String get displayName =>
      variantName.isEmpty ? productName : '$productName $variantName';

  /// Nilai stok = stok × HPP (0 bila stok minus).
  Money get value =>
      stock.isPositive ? unitCost.timesMilli(stock.milli) : Money.zero;

  /// Stok ≤ minimum (hanya bila minimum diisi), sama dengan daftar produk.
  bool get belowMinimum => minStock.isPositive && stock.milli <= minStock.milli;
}

/// Lokasi [locationId] cabang ini, atau lokasi bawaan bila `null`.
/// `null` bila lokasi bukan milik cabang ini atau sudah dihapus.
Future<StockLocation?> _location(
  LakunaStore store,
  CatalogScope scope,
  UuidValue? locationId, {
  Transaction? transaction,
}) async {
  if (locationId == null) {
    return defaultStockLocation(store, scope, transaction: transaction);
  }
  final l = await StockLocation.db.findById(
    store.session,
    locationId,
    transaction: transaction,
  );
  if (l == null ||
      l.tenantId != scope.tenantId ||
      l.outletId != scope.outletId ||
      l.deletedAt != null) {
    return null;
  }
  return l;
}

/// Semua varian barang (bukan jasa/menu) yang belum dihapus beserta stok di
/// [locationId] (bawaan: lokasi bawaan cabang), urut nama.
Future<List<StockRow>> stockList(
  LakunaStore store,
  CatalogScope scope, {
  UuidValue? locationId,
}) async {
  final location = await _location(store, scope, locationId);
  if (location == null) throw StockLocationNotFound();
  final session = store.session;
  final products = await Product.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(scope.tenantId) &
        p.deletedAt.equals(null) &
        p.type.equals(ProductType.goods),
  );
  if (products.isEmpty) return const [];
  final byId = {for (final p in products) p.id: p};
  final variants = await ProductVariant.db.find(
    session,
    where: (v) =>
        v.tenantId.equals(scope.tenantId) &
        v.deletedAt.equals(null) &
        v.productId.inSet(byId.keys.toSet()),
    orderByList: (v) => [v.sortOrder, v.createdAt, v.id],
  );
  final levels = {
    for (final l in await StockLevel.db.find(
      session,
      where: (l) => l.stockLocationId.equals(location.id),
    ))
      l.variantId: l,
  };
  final units = {
    for (final u in await MeasureUnit.db.find(
      session,
      where: (u) => u.tenantId.equals(scope.tenantId),
    ))
      u.id: u.name,
  };
  final rows = [
    for (final v in variants)
      StockRow(
        variantId: v.id,
        productId: v.productId,
        productName: byId[v.productId]!.name,
        variantName: v.name,
        baseUnit: units[byId[v.productId]!.baseUnitId] ?? '',
        sku: v.sku ?? byId[v.productId]!.sku,
        barcode: v.barcode,
        stock: Qty(levels[v.id]?.quantityMilli ?? 0),
        minStock: Qty(v.minStockMilli),
        unitCost: adjustmentUnitCost(
          avgCost: Money(levels[v.id]?.avgCost ?? 0),
          costPrice: Money(v.costPrice),
        ),
      ),
  ];
  return rows..sort((a, b) {
    final c = a.displayName.toLowerCase().compareTo(
      b.displayName.toLowerCase(),
    );
    return c != 0 ? c : a.variantId.uuid.compareTo(b.variantId.uuid);
  });
}

/// Varian dengan stok ≤ minimum, paling kritis (stok/minimum terkecil)
/// dulu.
Future<List<StockRow>> belowMinimum(
  LakunaStore store,
  CatalogScope scope, {
  UuidValue? locationId,
}) async {
  final rows = (await stockList(
    store,
    scope,
    locationId: locationId,
  )).where((r) => r.belowMinimum).toList();
  // Bandingkan a.stock/a.min dengan b.stock/b.min tanpa pecahan.
  int ratio(StockRow a, StockRow b) =>
      (BigInt.from(a.stock.milli) * BigInt.from(b.minStock.milli)).compareTo(
        BigInt.from(b.stock.milli) * BigInt.from(a.minStock.milli),
      );
  return rows..sort((a, b) {
    final c = ratio(a, b);
    return c != 0
        ? c
        : a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  });
}

// --- Lokasi -----------------------------------------------------------------

class StockLocationNotFound implements Exception {
  @override
  String toString() => 'StockLocationNotFound';
}

class StockLocationInvalid implements Exception {
  const StockLocationInvalid(this.error);

  final StockLocationNameError error;

  @override
  String toString() => 'StockLocationInvalid(${error.name})';
}

/// Lokasi stok cabang: bawaan dulu, lalu nama.
Future<List<StockLocation>> stockLocations(
  LakunaStore store,
  CatalogScope scope,
) async {
  final rows = await StockLocation.db.find(
    store.session,
    where: (l) =>
        l.tenantId.equals(scope.tenantId) &
        l.outletId.equals(scope.outletId) &
        l.deletedAt.equals(null),
    orderByList: (l) => [l.isDefault.desc(), l.createdAt, l.id],
  );
  return rows;
}

Future<List<StockLocation>> _locationsIn(SyncTx w, CatalogScope scope) =>
    StockLocation.db.find(
      w.session,
      where: (l) =>
          l.tenantId.equals(scope.tenantId) &
          l.outletId.equals(scope.outletId) &
          l.deletedAt.equals(null),
      transaction: w.transaction,
    );

/// Lokasi baru di cabang ini. Gagal dengan [StockLocationInvalid].
Future<StockLocation> createStockLocation(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String name,
}) => store.write(actor: staffId, (w) async {
  final existing = await _locationsIn(w, scope);
  final error = validateLocationName(
    name,
    existing: existing.map((l) => l.name),
  );
  if (error != null) throw StockLocationInvalid(error);
  final s = await w.stamp();
  return w.insert(
    StockLocation(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      name: name.trim(),
      isDefault: false,
      createdAt: s.now,
      updatedAt: s.now,
      createdBy: staffId,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

/// Ganti nama lokasi cabang ini. Gagal dengan [StockLocationInvalid] atau
/// [StockLocationNotFound].
Future<StockLocation> renameStockLocation(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue locationId,
  required String name,
}) => store.write(actor: staffId, (w) async {
  final existing = await _locationsIn(w, scope);
  final current = existing.where((l) => l.id == locationId).firstOrNull;
  if (current == null) throw StockLocationNotFound();
  final error = validateLocationName(
    name,
    existing: existing.where((l) => l.id != locationId).map((l) => l.name),
  );
  if (error != null) throw StockLocationInvalid(error);
  final s = await w.stamp();
  return w.update(
    current.copyWith(
      name: name.trim(),
      version: current.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

// --- Penyesuaian ------------------------------------------------------------

/// Satu baris penyesuaian yang stok fisiknya sudah diisi.
class AdjustmentLine {
  const AdjustmentLine({
    required this.variantId,
    required this.physical,
    this.note,
  });

  final UuidValue variantId;

  /// Stok fisik dalam satuan dasar.
  final Qty physical;

  /// Alasan baris (opsional).
  final String? note;
}

enum StockAdjustmentError {
  /// Tidak ada baris yang diisi.
  empty,
  negative,
  duplicate,

  /// Jasa/menu tidak dilacak stoknya.
  notGoods,
  unknownVariant,
  unknownLocation,

  /// Semua baris selisih 0.
  noChange,
  noteTooLong,
}

class StockAdjustmentInvalid implements Exception {
  const StockAdjustmentInvalid(this.error, {this.variantId});

  final StockAdjustmentError error;

  /// Baris yang bermasalah, bila ada.
  final UuidValue? variantId;

  @override
  String toString() => 'StockAdjustmentInvalid(${error.name}, $variantId)';
}

class StockAdjustmentResult {
  const StockAdjustmentResult({required this.adjustment, required this.items});

  final StockAdjustment adjustment;
  final List<StockAdjustmentItem> items;
}

String? _clean(String? text) {
  final t = text?.trim();
  return t == null || t.isEmpty ? null : t;
}

/// Menyimpan dokumen penyesuaian dalam satu transaksi: stok sistem dibaca
/// saat simpan, setiap baris berselisih membuat pergerakan `adjustment`.
/// Gagal dengan [StockAdjustmentInvalid]; tidak ada yang tersimpan.
Future<StockAdjustmentResult> saveStockAdjustment(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue locationId,
  required StockAdjustmentReason reason,
  required List<AdjustmentLine> lines,
  String? note,
}) async {
  if (lines.isEmpty) {
    throw const StockAdjustmentInvalid(StockAdjustmentError.empty);
  }
  final seen = <UuidValue>{};
  for (final l in lines) {
    if (l.physical.milli < 0) {
      throw StockAdjustmentInvalid(
        StockAdjustmentError.negative,
        variantId: l.variantId,
      );
    }
    if (!seen.add(l.variantId)) {
      throw StockAdjustmentInvalid(
        StockAdjustmentError.duplicate,
        variantId: l.variantId,
      );
    }
    final n = _clean(l.note);
    if (n != null && n.length > StockLimits.lineNote) {
      throw StockAdjustmentInvalid(
        StockAdjustmentError.noteTooLong,
        variantId: l.variantId,
      );
    }
  }
  final docNote = _clean(note);
  if (docNote != null && docNote.length > StockLimits.note) {
    throw const StockAdjustmentInvalid(StockAdjustmentError.noteTooLong);
  }

  return store.write(actor: staffId, (w) async {
    final location = await _location(
      store,
      scope,
      locationId,
      transaction: w.transaction,
    );
    if (location == null) {
      throw const StockAdjustmentInvalid(StockAdjustmentError.unknownLocation);
    }
    final variants = {
      for (final v in await ProductVariant.db.find(
        w.session,
        where: (v) =>
            v.tenantId.equals(scope.tenantId) &
            v.deletedAt.equals(null) &
            v.id.inSet(seen),
        transaction: w.transaction,
      ))
        v.id: v,
    };
    final products = {
      for (final p in await Product.db.find(
        w.session,
        where: (p) =>
            p.tenantId.equals(scope.tenantId) &
            p.deletedAt.equals(null) &
            p.id.inSet({for (final v in variants.values) v.productId}),
        transaction: w.transaction,
      ))
        p.id: p,
    };
    final levels = {
      for (final l in await StockLevel.db.find(
        w.session,
        where: (l) =>
            l.stockLocationId.equals(location.id) & l.variantId.inSet(seen),
        transaction: w.transaction,
      ))
        l.variantId: l,
    };

    final planned = <(AdjustmentLine, Qty, Qty, Money, Money)>[];
    for (final l in lines) {
      final v = variants[l.variantId];
      final p = v == null ? null : products[v.productId];
      if (v == null || p == null) {
        throw StockAdjustmentInvalid(
          StockAdjustmentError.unknownVariant,
          variantId: l.variantId,
        );
      }
      if (p.type != ProductType.goods) {
        throw StockAdjustmentInvalid(
          StockAdjustmentError.notGoods,
          variantId: l.variantId,
        );
      }
      final level = levels[v.id];
      final system = Qty(level?.quantityMilli ?? 0);
      final diff = stockDifference(system: system, physical: l.physical);
      final cost = adjustmentUnitCost(
        avgCost: Money(level?.avgCost ?? 0),
        costPrice: Money(v.costPrice),
      );
      planned.add((l, system, diff, cost, adjustmentValue(diff, cost)));
    }
    if (planned.every((p) => p.$3 == Qty.zero)) {
      throw const StockAdjustmentInvalid(StockAdjustmentError.noChange);
    }

    final s = await w.stamp();
    final number = await _nextNumber(w, scope, s.now);
    final total = planned.fold(Money.zero, (sum, p) => sum + p.$5);
    final adjustment = await w.insert(
      StockAdjustment(
        tenantId: scope.tenantId,
        outletId: scope.outletId,
        stockLocationId: location.id,
        number: number,
        reason: reason,
        note: docNote,
        totalValue: total.value,
        staffId: staffId,
        adjustedAt: s.now,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    final items = <StockAdjustmentItem>[];
    for (var i = 0; i < planned.length; i++) {
      final (line, system, diff, cost, value) = planned[i];
      final lineNote = _clean(line.note);
      items.add(
        await w.insert(
          StockAdjustmentItem(
            tenantId: scope.tenantId,
            adjustmentId: adjustment.id,
            variantId: line.variantId,
            systemMilli: system.milli,
            physicalMilli: line.physical.milli,
            differenceMilli: diff.milli,
            unitCost: cost.value,
            value: value.value,
            note: lineNote,
            sortOrder: i,
            createdAt: s.now,
            updatedAt: s.now,
            createdBy: staffId,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        ),
      );
      if (diff != Qty.zero) {
        await recordStockMovement(
          w,
          scope,
          locationId: location.id,
          variantId: line.variantId,
          quantity: diff,
          unitCost: cost,
          sourceType: StockSourceType.adjustment,
          sourceId: adjustment.id,
          note: lineNote,
          stamp: s,
        );
      }
    }
    return StockAdjustmentResult(adjustment: adjustment, items: items);
  });
}

const _adjustmentPrefix = 'SA';

Future<String> _nextNumber(SyncTx w, CatalogScope scope, DateTime now) async {
  final (outlet, device, timezone) = await _codes(
    w.session,
    w.transaction,
    scope,
  );
  final local = outletLocalTime(now, timezone);
  final prefix = '$_adjustmentPrefix-${receiptPrefix(outlet, device, local)}';
  final existing = await StockAdjustment.db.find(
    w.session,
    where: (a) => a.tenantId.equals(scope.tenantId) & a.number.like('$prefix%'),
    transaction: w.transaction,
  );
  final counter = nextReceiptCounter(existing.map((a) => a.number), prefix);
  return documentNumber(_adjustmentPrefix, outlet, device, local, counter);
}

Future<(String, String, String?)> _codes(
  DatabaseSession session,
  Transaction? transaction,
  CatalogScope scope,
) async {
  final outlet = await Outlet.db.findById(
    session,
    scope.outletId,
    transaction: transaction,
  );
  final device = await Device.db.findById(
    session,
    scope.deviceId,
    transaction: transaction,
  );
  if (outlet == null || device == null) {
    throw StateError('Cabang/perangkat ${scope.outletId} tidak ditemukan.');
  }
  final tenant = await Tenant.db.findById(
    session,
    scope.tenantId,
    transaction: transaction,
  );
  return (outlet.code, device.code, outlet.timezone ?? tenant?.timezone);
}

/// Nomor penyesuaian berikutnya (pratinjau di kepala form; nomor final
/// dibuat saat simpan).
Future<String> nextAdjustmentNumber(LakunaStore store, CatalogScope scope) =>
    store.session.db.transaction((tx) async {
      final (outlet, device, timezone) = await _codes(store.session, tx, scope);
      final local = outletLocalTime(store.now(), timezone);
      final prefix =
          '$_adjustmentPrefix-${receiptPrefix(outlet, device, local)}';
      final existing = await StockAdjustment.db.find(
        store.session,
        where: (a) =>
            a.tenantId.equals(scope.tenantId) & a.number.like('$prefix%'),
        transaction: tx,
      );
      final counter = nextReceiptCounter(existing.map((a) => a.number), prefix);
      return documentNumber(_adjustmentPrefix, outlet, device, local, counter);
    });

/// Ringkasan dokumen penyesuaian untuk daftar.
class StockAdjustmentSummary {
  const StockAdjustmentSummary({
    required this.id,
    required this.number,
    required this.adjustedAt,
    required this.reason,
    required this.staffName,
    required this.locationName,
    required this.itemCount,
    required this.totalValue,
    this.note,
  });

  final UuidValue id;
  final String number;
  final DateTime adjustedAt;
  final StockAdjustmentReason reason;
  final String staffName;
  final String locationName;
  final int itemCount;
  final Money totalValue;
  final String? note;
}

/// Penyesuaian cabang ini, terbaru dulu.
Future<List<StockAdjustmentSummary>> recentAdjustments(
  LakunaStore store,
  CatalogScope scope, {
  int limit = 10,
}) async {
  final session = store.session;
  final docs = await StockAdjustment.db.find(
    session,
    where: (a) =>
        a.tenantId.equals(scope.tenantId) &
        a.outletId.equals(scope.outletId) &
        a.deletedAt.equals(null),
    orderByList: (a) => [a.adjustedAt.desc(), a.number.desc()],
    limit: limit,
  );
  if (docs.isEmpty) return const [];
  final ids = {for (final d in docs) d.id};
  final counts = <UuidValue, int>{};
  for (final i in await StockAdjustmentItem.db.find(
    session,
    where: (i) => i.adjustmentId.inSet(ids) & i.deletedAt.equals(null),
  )) {
    counts[i.adjustmentId] = (counts[i.adjustmentId] ?? 0) + 1;
  }
  final staff = await _staffNames(store, {for (final d in docs) d.staffId});
  final locations = {
    for (final l in await StockLocation.db.find(
      session,
      where: (l) => l.tenantId.equals(scope.tenantId),
    ))
      l.id: l.name,
  };
  return [
    for (final d in docs)
      StockAdjustmentSummary(
        id: d.id,
        number: d.number,
        adjustedAt: d.adjustedAt,
        reason: d.reason,
        staffName: staff[d.staffId] ?? '',
        locationName: locations[d.stockLocationId] ?? '',
        itemCount: counts[d.id] ?? 0,
        totalValue: Money(d.totalValue),
        note: d.note,
      ),
  ];
}

Future<Map<UuidValue, String>> _staffNames(
  LakunaStore store,
  Set<UuidValue> ids,
) async => ids.isEmpty
    ? const {}
    : {
        for (final s in await StaffMember.db.find(
          store.session,
          where: (s) => s.id.inSet(ids),
        ))
          s.id: s.name,
      };

// --- Kartu stok -------------------------------------------------------------

/// Satu pergerakan di kartu stok.
class StockCardEntry {
  const StockCardEntry({
    required this.occurredAt,
    required this.sourceType,
    required this.quantity,
    required this.balance,
    this.documentNumber,
    this.staffName,
    this.reason,
    this.note,
  });

  final DateTime occurredAt;
  final StockSourceType sourceType;

  /// Nota, nomor penyesuaian, dst. `null` bila modul sumbernya belum ada.
  final String? documentNumber;
  final String? staffName;

  /// Alasan umum dokumen penyesuaian.
  final StockAdjustmentReason? reason;
  final String? note;

  /// Positif = masuk.
  final Qty quantity;

  /// Saldo setelah pergerakan ini.
  final Qty balance;
}

class StockCard {
  const StockCard({
    required this.openingBalance,
    required this.entries,
    required this.minStock,
  });

  /// Saldo sebelum pergerakan pertama yang ditampilkan.
  final Qty openingBalance;

  /// Terlama → terbaru.
  final List<StockCardEntry> entries;
  final Qty minStock;

  Qty get current => entries.isEmpty ? openingBalance : entries.last.balance;
}

/// Kartu stok [variantId] di [locationId] (bawaan: lokasi bawaan):
/// [limit] pergerakan terakhir dengan saldo berjalan.
Future<StockCard> stockCard(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue variantId,
  UuidValue? locationId,
  int limit = 200,
}) async {
  final location = await _location(store, scope, locationId);
  if (location == null) throw StockLocationNotFound();
  final session = store.session;
  final variant = await ProductVariant.db.findFirstRow(
    session,
    where: (v) => v.id.equals(variantId) & v.tenantId.equals(scope.tenantId),
  );
  final movements = await StockMovement.db.find(
    session,
    where: (m) =>
        m.tenantId.equals(scope.tenantId) &
        m.stockLocationId.equals(location.id) &
        m.variantId.equals(variantId) &
        m.deletedAt.equals(null),
    orderByList: (m) => [m.occurredAt, m.id],
  );
  final shown = movements.length > limit
      ? movements.sublist(movements.length - limit)
      : movements;
  var balance = movements
      .take(movements.length - shown.length)
      .fold(Qty.zero, (sum, m) => sum + Qty(m.quantityMilli));
  final opening = balance;

  Set<UuidValue> idsOf(StockSourceType t) => {
    for (final m in shown)
      if (m.sourceType == t && m.sourceId != null) m.sourceId!,
  };
  final saleIds = idsOf(StockSourceType.sale);
  final sales = saleIds.isEmpty
      ? const <UuidValue, Sale>{}
      : {
          for (final s in await Sale.db.find(
            session,
            where: (s) => s.id.inSet(saleIds),
          ))
            s.id: s,
        };
  final adjustmentIds = idsOf(StockSourceType.adjustment);
  final adjustments = adjustmentIds.isEmpty
      ? const <UuidValue, StockAdjustment>{}
      : {
          for (final a in await StockAdjustment.db.find(
            session,
            where: (a) => a.id.inSet(adjustmentIds),
          ))
            a.id: a,
        };
  final staff = await _staffNames(store, {
    for (final s in sales.values) s.staffId,
    for (final a in adjustments.values) a.staffId,
  });

  final entries = <StockCardEntry>[];
  for (final m in shown) {
    balance += Qty(m.quantityMilli);
    final sale = sales[m.sourceId];
    final adj = adjustments[m.sourceId];
    entries.add(
      StockCardEntry(
        occurredAt: m.occurredAt,
        sourceType: m.sourceType,
        documentNumber: sale?.number ?? adj?.number,
        staffName: staff[sale?.staffId ?? adj?.staffId],
        reason: adj?.reason,
        note: m.note,
        quantity: Qty(m.quantityMilli),
        balance: balance,
      ),
    );
  }
  return StockCard(
    openingBalance: opening,
    entries: entries,
    minStock: Qty(variant?.minStockMilli ?? 0),
  );
}
