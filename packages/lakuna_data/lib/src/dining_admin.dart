import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'settings_scope.dart';
import 'store_settings.dart' show loadSalesRules;
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Area, meja, dan tarif F&B per cabang (F1-10). Semua tulis lewat
/// [LakunaStore.write] (outbox sync).

class DiningNotFound implements Exception {
  @override
  String toString() => 'DiningNotFound';
}

/// Nama area/meja tidak sah.
class DiningNameInvalid implements Exception {
  const DiningNameInvalid(this.error, {this.index = 0});

  final DiningNameError error;

  /// Baris ke-[index] pada *Tambah beberapa*.
  final int index;

  @override
  String toString() => 'DiningNameInvalid(${error.name}, $index)';
}

/// Kursi di luar 1..99.
class DiningSeatsInvalid implements Exception {
  @override
  String toString() => 'DiningSeatsInvalid';
}

/// Rentang *Tambah beberapa* tidak sah (lihat [tableRange]).
class DiningRangeInvalid implements Exception {
  @override
  String toString() => 'DiningRangeInvalid';
}

/// Hapus ditolak: area masih punya [tables] meja, atau meja punya bill
/// terbuka ([openBill]).
class DiningInUse implements Exception {
  const DiningInUse({this.tables = 0, this.openBill = false});

  final int tables;
  final bool openBill;

  @override
  String toString() => 'DiningInUse(tables: $tables, openBill: $openBill)';
}

/// Tarif service/PB1 tidak sah.
class FnbRatesInvalid implements Exception {
  const FnbRatesInvalid({this.service = false, this.tax = false});

  final bool service;
  final bool tax;

  @override
  String toString() => 'FnbRatesInvalid(service: $service, tax: $tax)';
}

int _byOrder(int aOrder, String aName, int bOrder, String bName) =>
    aOrder != bOrder
    ? aOrder.compareTo(bOrder)
    : aName.toLowerCase().compareTo(bName.toLowerCase());

Future<List<DiningArea>> _areas(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async => (await DiningArea.db.find(
  session,
  where: (a) =>
      a.tenantId.equals(scope.tenantId) &
      a.outletId.equals(scope.outletId) &
      a.deletedAt.equals(null),
  transaction: transaction,
))..sort((a, b) => _byOrder(a.sortOrder, a.name, b.sortOrder, b.name));

Future<List<DiningTable>> _tables(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async => (await DiningTable.db.find(
  session,
  where: (t) =>
      t.tenantId.equals(scope.tenantId) &
      t.outletId.equals(scope.outletId) &
      t.deletedAt.equals(null),
  transaction: transaction,
))..sort((a, b) => _byOrder(a.sortOrder, a.name, b.sortOrder, b.name));

/// Area cabang urut `sort_order` lalu nama.
Future<List<DiningArea>> diningAreas(LakunaStore store, CatalogScope scope) =>
    _areas(store.session, scope);

/// Meja cabang urut `sort_order` lalu nama.
Future<List<DiningTable>> diningTables(
  LakunaStore store,
  CatalogScope scope, {
  Transaction? transaction,
}) => _tables(store.session, scope, transaction: transaction);

// --- Area -------------------------------------------------------------------

Future<DiningArea> createDiningArea(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String name,
}) => store.write(actor: staffId, (w) async {
  final areas = await _areas(w.session, scope, transaction: w.transaction);
  final error = validateDiningName(
    name,
    max: FnbLimits.areaName,
    existing: areas.map((a) => a.name),
  );
  if (error != null) throw DiningNameInvalid(error);
  final s = await w.stamp();
  return w.insert(
    DiningArea(
      tenantId: scope.tenantId,
      outletId: scope.outletId,
      name: name.trim(),
      sortOrder:
          areas.fold(-1, (m, a) => a.sortOrder > m ? a.sortOrder : m) + 1,
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

Future<DiningArea> renameDiningArea(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required String name,
}) => store.write(actor: staffId, (w) async {
  final areas = await _areas(w.session, scope, transaction: w.transaction);
  final current = areas.where((a) => a.id == id).firstOrNull;
  if (current == null) throw DiningNotFound();
  final error = validateDiningName(
    name,
    max: FnbLimits.areaName,
    existing: [
      for (final a in areas)
        if (a.id != id) a.name,
    ],
  );
  if (error != null) throw DiningNameInvalid(error);
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

/// Naik (−1) / turun (+1); semua area dinomori ulang 0..n, hanya yang
/// berubah ditulis.
Future<void> moveDiningArea(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required int delta,
}) => store.write(actor: staffId, (w) async {
  final areas = await _areas(w.session, scope, transaction: w.transaction);
  final index = areas.indexWhere((a) => a.id == id);
  if (index < 0) throw DiningNotFound();
  final moved = moveInOrder(areas, index, delta);
  final s = await w.stamp();
  for (var i = 0; i < moved.length; i++) {
    final a = moved[i];
    if (a.sortOrder == i) continue;
    await w.update(
      a.copyWith(
        sortOrder: i,
        version: a.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
});

/// Hapus (soft delete). Ditolak bila masih punya meja ([DiningInUse]).
Future<void> deleteDiningArea(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
}) => store.write(actor: staffId, (w) async {
  final areas = await _areas(w.session, scope, transaction: w.transaction);
  final current = areas.where((a) => a.id == id).firstOrNull;
  if (current == null) throw DiningNotFound();
  final tables = (await _tables(
    w.session,
    scope,
    transaction: w.transaction,
  )).where((t) => t.diningAreaId == id).length;
  if (tables > 0) throw DiningInUse(tables: tables);
  final s = await w.stamp();
  await w.update(
    current.copyWith(
      deletedAt: s.now,
      version: current.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

// --- Meja -------------------------------------------------------------------

/// Isian meja.
class DiningTableDraft {
  const DiningTableDraft({
    required this.name,
    this.areaId,
    this.seats = 4,
    this.canMerge,
  });

  final String name;
  final UuidValue? areaId;
  final int seats;

  /// *Boleh digabung* (F1-10d); `null` = tetap (ubah) / tidak (baru).
  final bool? canMerge;
}

Future<void> _checkArea(SyncTx w, CatalogScope scope, UuidValue? areaId) async {
  if (areaId == null) return;
  final areas = await _areas(w.session, scope, transaction: w.transaction);
  if (!areas.any((a) => a.id == areaId)) throw DiningNotFound();
}

void _checkSeats(int seats) {
  if (seats < 1 || seats > FnbLimits.seatsMax) throw DiningSeatsInvalid();
}

/// Menambah satu atau beberapa meja di akhir urutan, dalam satu
/// transaksi. Gagal dengan [DiningNameInvalid] (indeks baris),
/// [DiningSeatsInvalid], atau [DiningNotFound] (area).
Future<List<DiningTable>> createDiningTables(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required List<DiningTableDraft> drafts,
}) => store.write(actor: staffId, (w) async {
  final tables = await _tables(w.session, scope, transaction: w.transaction);
  final names = [for (final t in tables) t.name];
  for (final (i, d) in drafts.indexed) {
    final error = validateDiningName(
      d.name,
      max: FnbLimits.tableName,
      existing: names,
    );
    if (error != null) throw DiningNameInvalid(error, index: i);
    _checkSeats(d.seats);
    await _checkArea(w, scope, d.areaId);
    names.add(d.name.trim());
  }
  var order = tables.fold(-1, (m, t) => t.sortOrder > m ? t.sortOrder : m);
  final s = await w.stamp();
  return [
    for (final d in drafts)
      await w.insert(
        DiningTable(
          tenantId: scope.tenantId,
          outletId: scope.outletId,
          diningAreaId: d.areaId,
          name: d.name.trim(),
          seats: d.seats,
          canMerge: d.canMerge ?? false,
          sortOrder: ++order,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      ),
  ];
});

Future<DiningTable> updateDiningTable(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required DiningTableDraft draft,
}) => store.write(actor: staffId, (w) async {
  final tables = await _tables(w.session, scope, transaction: w.transaction);
  final current = tables.where((t) => t.id == id).firstOrNull;
  if (current == null) throw DiningNotFound();
  final error = validateDiningName(
    draft.name,
    max: FnbLimits.tableName,
    existing: [
      for (final t in tables)
        if (t.id != id) t.name,
    ],
  );
  if (error != null) throw DiningNameInvalid(error);
  _checkSeats(draft.seats);
  await _checkArea(w, scope, draft.areaId);
  final s = await w.stamp();
  return w.update(
    current.copyWith(
      name: draft.name.trim(),
      diningAreaId: draft.areaId,
      seats: draft.seats,
      canMerge: draft.canMerge ?? current.canMerge,
      // Pindah area melepas posisi denah (meja jadi *Belum ditempatkan*).
      posX: draft.areaId == current.diningAreaId ? current.posX : null,
      posY: draft.areaId == current.diningAreaId ? current.posY : null,
      version: current.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

Future<void> moveDiningTable(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required int delta,
}) => store.write(actor: staffId, (w) async {
  final tables = await _tables(w.session, scope, transaction: w.transaction);
  final index = tables.indexWhere((t) => t.id == id);
  if (index < 0) throw DiningNotFound();
  final moved = moveInOrder(tables, index, delta);
  final s = await w.stamp();
  for (var i = 0; i < moved.length; i++) {
    final t = moved[i];
    if (t.sortOrder == i) continue;
    await w.update(
      t.copyWith(
        sortOrder: i,
        version: t.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
});

/// Hapus meja (soft delete). Ditolak bila meja punya bill terbuka.
Future<void> deleteDiningTable(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
}) => store.write(actor: staffId, (w) async {
  final current = await DiningTable.db.findFirstRow(
    w.session,
    where: (t) =>
        t.id.equals(id) &
        t.tenantId.equals(scope.tenantId) &
        t.outletId.equals(scope.outletId) &
        t.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (current == null) throw DiningNotFound();
  final open = await Sale.db.count(
    w.session,
    where: (s) =>
        s.tenantId.equals(scope.tenantId) &
        s.diningTableId.equals(id) &
        s.status.equals(SaleStatus.open) &
        s.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (open > 0) throw const DiningInUse(openBill: true);
  final s = await w.stamp();
  await w.update(
    current.copyWith(
      deletedAt: s.now,
      version: current.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

// --- Tarif service & PB1 ----------------------------------------------------

/// Kunci `settings` tarif F&B (basis poin, per cabang).
const fnbServiceKey = 'fnb.service_bp';
const fnbTaxKey = 'fnb.tax_bp';

/// Kunci `settings` *Harga sudah termasuk pajak* (bool, per cabang).
const fnbTaxInclusiveKey = 'fnb.tax_inclusive';

/// Tarif service charge dan PB1 cabang.
class FnbRates {
  const FnbRates({
    this.service = BasisPoints.zero,
    this.tax = BasisPoints.zero,
    this.taxInclusive = false,
    this.rounding = TotalRounding.none,
  });

  final BasisPoints service;
  final BasisPoints tax;

  /// Harga menu sudah termasuk PB1.
  final bool taxInclusive;

  /// Pembulatan total dari aturan *Penjualan & stok* (hanya dibaca;
  /// [saveFnbRates] tidak menyimpannya).
  final TotalRounding rounding;
}

Future<Setting?> _rateRow(
  DatabaseSession session,
  Transaction? transaction,
  CatalogScope scope,
  String key,
) => Setting.db.findFirstRow(
  session,
  where: (t) =>
      t.tenantId.equals(scope.tenantId) &
      t.scopeKey.equals(settingScopeOutlet(scope.outletId)) &
      t.key.equals(key) &
      t.deletedAt.equals(null),
  transaction: transaction,
);

BasisPoints _decodeRate(Setting? row, BasisPoints max) {
  if (row == null) return BasisPoints.zero;
  try {
    final v = jsonDecode(row.valueJson);
    if (v is int && validateFnbRate(BasisPoints(v), max)) return BasisPoints(v);
  } on FormatException {
    // Nilai rusak dianggap 0.
  }
  return BasisPoints.zero;
}

/// Tarif cabang [scope] (bawaan 0).
Future<FnbRates> loadFnbRates(
  DatabaseSession session,
  CatalogScope scope, {
  Transaction? transaction,
}) async => FnbRates(
  service: _decodeRate(
    await _rateRow(session, transaction, scope, fnbServiceKey),
    FnbLimits.serviceBp,
  ),
  tax: _decodeRate(
    await _rateRow(session, transaction, scope, fnbTaxKey),
    FnbLimits.taxBp,
  ),
  taxInclusive: _decodeBool(
    await _rateRow(session, transaction, scope, fnbTaxInclusiveKey),
  ),
  rounding: (await loadSalesRules(
    session,
    scope,
    transaction: transaction,
  )).rounding,
);

bool _decodeBool(Setting? row) {
  if (row == null) return false;
  try {
    return jsonDecode(row.valueJson) == true;
  } on FormatException {
    return false;
  }
}

/// Menyimpan tarif cabang. Gagal dengan [FnbRatesInvalid] tanpa menulis.
Future<FnbRates> saveFnbRates(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required FnbRates rates,
}) async {
  final serviceOk = validateFnbRate(rates.service, FnbLimits.serviceBp);
  final taxOk = validateFnbRate(rates.tax, FnbLimits.taxBp);
  if (!serviceOk || !taxOk) {
    throw FnbRatesInvalid(service: !serviceOk, tax: !taxOk);
  }
  await store.write(actor: staffId, (w) async {
    final s = await w.stamp();
    for (final (key, json) in [
      (fnbServiceKey, rates.service.value),
      (fnbTaxKey, rates.tax.value),
      (fnbTaxInclusiveKey, rates.taxInclusive),
    ]) {
      final current = await _rateRow(w.session, w.transaction, scope, key);
      final value = jsonEncode(json);
      if (current == null) {
        await w.insert(
          Setting(
            tenantId: scope.tenantId,
            outletId: scope.outletId,
            scopeKey: settingScopeOutlet(scope.outletId),
            key: key,
            valueJson: value,
            createdAt: s.now,
            updatedAt: s.now,
            createdBy: staffId,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      } else if (current.valueJson != value) {
        await w.update(
          current.copyWith(
            valueJson: value,
            version: current.version + 1,
            updatedAt: s.now,
            updatedBy: staffId,
            hlc: s.hlc.toString(),
            originDeviceId: s.deviceId,
          ),
          s,
        );
      }
    }
  });
  return loadFnbRates(store.session, scope);
}
