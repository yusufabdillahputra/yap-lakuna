import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Data master F1-09: kategori dan satuan. Semua tulis satu transaksi per
/// aksi lewat [LakunaStore.write] (outbox sync).

class MasterNotFound implements Exception {
  @override
  String toString() => 'MasterNotFound';
}

class CategoryInvalid implements Exception {
  const CategoryInvalid(this.errors);

  final List<CategoryError> errors;

  @override
  String toString() => 'CategoryInvalid(${errors.map((e) => e.name)})';
}

class UnitInvalid implements Exception {
  const UnitInvalid(this.error);

  final UnitNameError error;

  @override
  String toString() => 'UnitInvalid(${error.name})';
}

/// Hapus ditolak karena masih dipakai [products] produk atau punya
/// [children] subkategori.
class MasterInUse implements Exception {
  const MasterInUse({this.products = 0, this.children = 0});

  final int products;
  final int children;

  @override
  String toString() => 'MasterInUse(products: $products, children: $children)';
}

int _byOrder(ProductCategory a, ProductCategory b) => a.sortOrder != b.sortOrder
    ? a.sortOrder.compareTo(b.sortOrder)
    : a.name.toLowerCase().compareTo(b.name.toLowerCase());

// --- Kategori ---------------------------------------------------------------

/// Baris tabel kategori 1.17.
class CategoryRow {
  const CategoryRow({
    required this.category,
    required this.productCount,
    this.parentName,
  });

  final ProductCategory category;

  /// Produk (belum dihapus) yang memakai kategori ini langsung.
  final int productCount;
  final String? parentName;
}

Future<List<ProductCategory>> _categories(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
}) async => (await ProductCategory.db.find(
  session,
  where: (c) => c.tenantId.equals(tenantId) & c.deletedAt.equals(null),
  transaction: transaction,
))..sort(_byOrder);

/// Produk aktif tenant; [includeArchived] ikut menghitung produk
/// diarsipkan (F1-07d) agar satuannya tidak terhapus selama produk masih
/// bisa dipulihkan.
Future<List<Product>> _products(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
  bool includeArchived = false,
}) => Product.db.find(
  session,
  where: (p) =>
      p.tenantId.equals(tenantId) &
      (includeArchived ? p.id.notEquals(null) : p.deletedAt.equals(null)),
  transaction: transaction,
);

/// Kategori tenant urut `sort_order` lalu nama, dengan jumlah produk.
Future<List<CategoryRow>> categoryRows(
  LakunaStore store,
  CatalogScope scope,
) async {
  final categories = await _categories(store.session, scope.tenantId);
  final counts = <UuidValue, int>{};
  for (final p in await _products(store.session, scope.tenantId)) {
    final id = p.categoryId;
    if (id != null) counts[id] = (counts[id] ?? 0) + 1;
  }
  final names = {for (final c in categories) c.id: c.name};
  return [
    for (final c in categories)
      CategoryRow(
        category: c,
        productCount: counts[c.id] ?? 0,
        parentName: c.parentId == null ? null : names[c.parentId],
      ),
  ];
}

List<CategoryRef> _refs(List<ProductCategory> rows) => [
  for (final c in rows)
    CategoryRef(id: c.id.uuid, name: c.name, parentId: c.parentId?.uuid),
];

String? _color(String? color) =>
    color == null || color.trim().isEmpty ? null : color.trim();

UuidValue? _parent(String? id) =>
    id == null || id.isEmpty ? null : UuidValue.withValidation(id);

/// Kategori baru di akhir urutan. Gagal dengan [CategoryInvalid].
Future<ProductCategory> createCategory(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required CategoryDraft draft,
}) => store.write(actor: staffId, (w) async {
  final existing = await _categories(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final d = CategoryDraft(
    name: draft.name,
    parentId: draft.parentId,
    color: _color(draft.color),
    showInCashier: draft.showInCashier,
    isActive: draft.isActive,
  );
  final errors = validateCategory(d, existing: _refs(existing));
  if (errors.isNotEmpty) throw CategoryInvalid(errors);
  final last = existing.fold<int>(
    -1,
    (m, c) => c.sortOrder > m ? c.sortOrder : m,
  );
  final s = await w.stamp();
  return w.insert(
    ProductCategory(
      tenantId: scope.tenantId,
      parentId: _parent(d.parentId),
      name: d.name.trim(),
      color: d.color,
      showInCashier: d.showInCashier,
      isActive: d.isActive,
      sortOrder: last + 1,
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

Future<ProductCategory> _touch(
  SyncTx w,
  ProductCategory row,
  UuidValue staffId,
  ProductCategory Function(ProductCategory row, SyncStamp s) change,
) async {
  final s = await w.stamp();
  return w.update(
    change(row, s).copyWith(
      version: row.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
}

/// Ubah kategori [id]. Gagal dengan [CategoryInvalid] atau
/// [MasterNotFound].
Future<ProductCategory> updateCategory(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required CategoryDraft draft,
}) => store.write(actor: staffId, (w) async {
  final existing = await _categories(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final current = existing.where((c) => c.id == id).firstOrNull;
  if (current == null) throw MasterNotFound();
  final d = CategoryDraft(
    name: draft.name,
    parentId: draft.parentId,
    color: _color(draft.color),
    showInCashier: draft.showInCashier,
    isActive: draft.isActive,
  );
  final errors = validateCategory(d, id: id.uuid, existing: _refs(existing));
  if (errors.isNotEmpty) throw CategoryInvalid(errors);
  return _touch(
    w,
    current,
    staffId,
    (row, _) => row.copyWith(
      name: d.name.trim(),
      parentId: _parent(d.parentId),
      color: d.color,
      showInCashier: d.showInCashier,
      isActive: d.isActive,
    ),
  );
});

/// Saklar *Aktif* di tabel kategori.
Future<ProductCategory> setCategoryActive(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required bool active,
}) => store.write(actor: staffId, (w) async {
  final current = (await _categories(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  )).where((c) => c.id == id).firstOrNull;
  if (current == null) throw MasterNotFound();
  if (current.isActive == active) return current;
  return _touch(w, current, staffId, (r, _) => r.copyWith(isActive: active));
});

/// Pindahkan kategori [id] [delta] posisi (−1 naik, +1 turun) lalu nomori
/// ulang semua kategori 0..n. Hanya baris yang nomornya berubah ditulis.
Future<void> moveCategory(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required int delta,
}) => store.write(actor: staffId, (w) async {
  final existing = await _categories(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final index = existing.indexWhere((c) => c.id == id);
  if (index < 0) throw MasterNotFound();
  final ordered = moveInOrder(existing, index, delta);
  for (var i = 0; i < ordered.length; i++) {
    final row = ordered[i];
    if (row.sortOrder == i) continue;
    await _touch(w, row, staffId, (r, _) => r.copyWith(sortOrder: i));
  }
});

/// Hapus (soft delete) kategori [id]. Ditolak dengan [MasterInUse] bila
/// dipakai produk atau punya subkategori.
Future<void> deleteCategory(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
}) => store.write(actor: staffId, (w) async {
  final existing = await _categories(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final current = existing.where((c) => c.id == id).firstOrNull;
  if (current == null) throw MasterNotFound();
  final products = (await _products(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  )).where((p) => p.categoryId == id).length;
  final children = existing.where((c) => c.parentId == id).length;
  if (products > 0 || children > 0) {
    throw MasterInUse(products: products, children: children);
  }
  await _touch(w, current, staffId, (r, s) => r.copyWith(deletedAt: s.now));
});

/// Kategori untuk chip kasir dari [all] (kategori belum dihapus): aktif,
/// *Tampil di kasir*, dan dipakai produk [usedIds] langsung atau lewat
/// subkategori. Urut `sort_order` lalu nama.
List<ProductCategory> cashierCategories(
  List<ProductCategory> all,
  Set<UuidValue?> usedIds,
) {
  final used = {...usedIds};
  for (final c in all) {
    if (usedIds.contains(c.id) && c.parentId != null) used.add(c.parentId);
  }
  return [
    for (final c in all)
      if (c.isActive && c.showInCashier && used.contains(c.id)) c,
  ]..sort(_byOrder);
}

// --- Satuan -----------------------------------------------------------------

/// Baris daftar satuan 1.17.
class UnitRow {
  const UnitRow({required this.unit, required this.productCount});

  final MeasureUnit unit;

  /// Produk (belum dihapus) yang memakai satuan ini sebagai satuan dasar
  /// atau satuan konversi varian.
  final int productCount;
}

Future<List<MeasureUnit>> _units(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
}) async => (await MeasureUnit.db.find(
  session,
  where: (u) => u.tenantId.equals(tenantId) & u.deletedAt.equals(null),
  transaction: transaction,
))..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

/// Produk per satuan: id satuan → set id produk.
Future<Map<UuidValue, Set<UuidValue>>> _unitUsage(
  DatabaseSession session,
  UuidValue tenantId, {
  Transaction? transaction,
  bool includeArchived = false,
}) async {
  final products = await _products(
    session,
    tenantId,
    transaction: transaction,
    includeArchived: includeArchived,
  );
  final usage = <UuidValue, Set<UuidValue>>{};
  for (final p in products) {
    (usage[p.baseUnitId] ??= {}).add(p.id);
  }
  final productIds = {for (final p in products) p.id};
  final variants = {
    for (final v in await ProductVariant.db.find(
      session,
      where: (v) => v.tenantId.equals(tenantId) & v.deletedAt.equals(null),
      transaction: transaction,
    ))
      if (productIds.contains(v.productId)) v.id: v.productId,
  };
  for (final u in await ProductUnit.db.find(
    session,
    where: (u) => u.tenantId.equals(tenantId) & u.deletedAt.equals(null),
    transaction: transaction,
  )) {
    final product = variants[u.variantId];
    if (product != null) (usage[u.unitId] ??= {}).add(product);
  }
  return usage;
}

/// Satuan tenant urut nama, dengan jumlah produk yang memakai.
Future<List<UnitRow>> unitRows(LakunaStore store, CatalogScope scope) async {
  final usage = await _unitUsage(store.session, scope.tenantId);
  return [
    for (final u in await _units(store.session, scope.tenantId))
      UnitRow(unit: u, productCount: usage[u.id]?.length ?? 0),
  ];
}

/// Satuan baru. Gagal dengan [UnitInvalid].
Future<MeasureUnit> createUnit(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required String name,
}) => store.write(actor: staffId, (w) async {
  final existing = await _units(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final error = validateUnitName(name, existing: existing.map((u) => u.name));
  if (error != null) throw UnitInvalid(error);
  final s = await w.stamp();
  return w.insert(
    MeasureUnit(
      tenantId: scope.tenantId,
      name: name.trim(),
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

Future<MeasureUnit> _touchUnit(
  SyncTx w,
  MeasureUnit row,
  UuidValue staffId,
  MeasureUnit Function(MeasureUnit row, SyncStamp s) change,
) async {
  final s = await w.stamp();
  return w.update(
    change(row, s).copyWith(
      version: row.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
}

/// Ganti nama satuan [id]. Gagal dengan [UnitInvalid] atau
/// [MasterNotFound].
Future<MeasureUnit> renameUnit(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
  required String name,
}) => store.write(actor: staffId, (w) async {
  final existing = await _units(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  );
  final current = existing.where((u) => u.id == id).firstOrNull;
  if (current == null) throw MasterNotFound();
  final error = validateUnitName(
    name,
    existing: existing.where((u) => u.id != id).map((u) => u.name),
  );
  if (error != null) throw UnitInvalid(error);
  if (current.name == name.trim()) return current;
  return _touchUnit(
    w,
    current,
    staffId,
    (r, _) => r.copyWith(name: name.trim()),
  );
});

/// Hapus (soft delete) satuan [id]. Ditolak dengan [MasterInUse] bila
/// masih dipakai produk.
Future<void> deleteUnit(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue id,
}) => store.write(actor: staffId, (w) async {
  final current = (await _units(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
  )).where((u) => u.id == id).firstOrNull;
  if (current == null) throw MasterNotFound();
  // Produk diarsipkan ikut dihitung: satuannya dibutuhkan saat dipulihkan.
  final usage = await _unitUsage(
    w.session,
    scope.tenantId,
    transaction: w.transaction,
    includeArchived: true,
  );
  final products = usage[id]?.length ?? 0;
  if (products > 0) throw MasterInUse(products: products);
  await _touchUnit(w, current, staffId, (r, s) => r.copyWith(deletedAt: s.now));
});
