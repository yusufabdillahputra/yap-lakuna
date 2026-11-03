import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show TableRow, Transaction;

import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Draf produk ditolak aturan `lakuna_domain`; tidak ada yang ditulis.
class ProductInputInvalid implements Exception {
  const ProductInputInvalid(this.issues);

  final List<ProductIssue> issues;

  @override
  String toString() => 'ProductInputInvalid($issues)';
}

/// Satu kode (SKU/barcode) di draf yang sudah dipakai produk [takenBy].
class ProductCodeConflict {
  const ProductCodeConflict(this.issue, this.takenBy);

  /// Masalah dengan galat [ProductError.taken] yang menunjuk field-nya.
  final ProductIssue issue;
  final String takenBy;
}

/// SKU/barcode draf sudah dipakai produk lain di tenant ini.
class ProductCodesTaken implements Exception {
  const ProductCodesTaken(this.conflicts);

  final List<ProductCodeConflict> conflicts;

  @override
  String toString() =>
      'ProductCodesTaken(${conflicts.map((c) => c.issue).toList()})';
}

/// Produk yang diubah tidak ada (atau sudah dihapus) di tenant ini.
class ProductNotFound implements Exception {
  @override
  String toString() => 'ProductNotFound';
}

/// Satuan konversi sebuah varian di katalog.
class CatalogUnit {
  const CatalogUnit({
    required this.id,
    required this.unitId,
    required this.name,
    required this.factor,
    this.barcode,
    this.costPrice,
    this.sellPrice,
  });

  final UuidValue id;
  final UuidValue unitId;
  final String name;
  final Qty factor;
  final String? barcode;
  final Money? costPrice;
  final Money? sellPrice;
}

/// Varian produk beserta satuan, grosir, dan saldo stok di lokasi bawaan.
class CatalogVariant {
  const CatalogVariant({
    required this.id,
    required this.name,
    required this.costPrice,
    required this.sellPrice,
    required this.minStock,
    required this.stock,
    this.sku,
    this.barcode,
    this.units = const [],
    this.tiers = const [],
  });

  final UuidValue id;
  final String name;
  final String? sku;
  final String? barcode;
  final Money costPrice;
  final Money sellPrice;
  final Qty minStock;
  final Qty stock;
  final List<CatalogUnit> units;

  /// Urut dari jumlah minimum terkecil.
  final List<PriceTier> tiers;

  /// Stok ≤ stok minimum (hanya bila stok minimum diisi).
  bool get isBelowMinimum =>
      minStock.milli > 0 && stock.milli <= minStock.milli;
}

/// Produk di katalog (daftar 1.15 dan form 1.16).
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.kind,
    required this.baseUnitId,
    required this.baseUnit,
    required this.isActive,
    required this.isTaxable,
    required this.variants,
    this.categoryId,
    this.categoryName,
    this.sku,
    this.brand,
  });

  final UuidValue id;
  final String name;
  final UuidValue? categoryId;
  final String? categoryName;
  final ProductKind kind;
  final UuidValue baseUnitId;
  final String baseUnit;
  final String? sku;
  final String? brand;
  final bool isActive;
  final bool isTaxable;
  final List<CatalogVariant> variants;

  bool get tracksStock => kind.tracksStock;

  /// Jumlah stok semua varian dalam satuan dasar.
  Qty get totalStock =>
      variants.fold(Qty.zero, (sum, variant) => sum + variant.stock);

  /// Ada varian di bawah atau sama dengan stok minimum.
  bool get isLowStock => tracksStock && variants.any((v) => v.isBelowMinimum);

  /// Isi form ubah produk. Stok awal selalu nol karena hanya berlaku untuk
  /// varian baru.
  ProductDraft toDraft() => ProductDraft(
    id: id.uuid,
    name: name,
    category: categoryName ?? '',
    kind: kind,
    baseUnit: baseUnit,
    sku: sku ?? '',
    brand: brand ?? '',
    isActive: isActive,
    isTaxable: isTaxable,
    variants: [
      for (final v in variants)
        VariantDraft(
          id: v.id.uuid,
          name: v.name,
          sku: v.sku ?? '',
          barcode: v.barcode ?? '',
          costPrice: v.costPrice,
          sellPrice: v.sellPrice,
          minStock: v.minStock,
          units: [
            for (final u in v.units)
              UnitDraft(
                id: u.id.uuid,
                name: u.name,
                factor: u.factor,
                barcode: u.barcode ?? '',
                costPrice: u.costPrice,
                sellPrice: u.sellPrice,
              ),
          ],
          tiers: v.tiers,
        ),
    ],
  );
}

ProductKind _kindOf(ProductType type) => ProductKind.values.byName(type.name);
ProductType _typeOf(ProductKind kind) => ProductType.values.byName(kind.name);

String? _orNull(String text) {
  final t = text.trim();
  return t.isEmpty ? null : t;
}

int _byName(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

/// Kategori tenant yang belum dihapus, urut `sort_order` lalu nama.
Future<List<ProductCategory>> listCategories(
  LakunaStore store,
  CatalogScope scope,
) async {
  final rows = await ProductCategory.db.find(
    store.session,
    where: (c) => c.tenantId.equals(scope.tenantId) & c.deletedAt.equals(null),
  );
  return rows..sort(
    (a, b) => a.sortOrder != b.sortOrder
        ? a.sortOrder.compareTo(b.sortOrder)
        : _byName(a.name, b.name),
  );
}

/// Satuan tenant yang belum dihapus, urut nama.
Future<List<MeasureUnit>> listUnits(
  LakunaStore store,
  CatalogScope scope,
) async {
  final rows = await MeasureUnit.db.find(
    store.session,
    where: (u) => u.tenantId.equals(scope.tenantId) & u.deletedAt.equals(null),
  );
  return rows..sort((a, b) => _byName(a.name, b.name));
}

/// Semua produk tenant yang belum dihapus beserta stok di lokasi bawaan
/// cabang, urut nama tanpa beda huruf.
Future<List<CatalogProduct>> listProducts(
  LakunaStore store,
  CatalogScope scope,
) => _loadProducts(store, scope);

/// Satu produk, atau `null` bila tidak ada di tenant ini.
Future<CatalogProduct?> loadProduct(
  LakunaStore store,
  CatalogScope scope,
  UuidValue productId,
) async =>
    (await _loadProducts(store, scope, productId: productId)).firstOrNull;

Future<List<CatalogProduct>> _loadProducts(
  LakunaStore store,
  CatalogScope scope, {
  UuidValue? productId,
}) async {
  final session = store.session;
  final tenant = scope.tenantId;
  final products = await Product.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(tenant) &
        p.deletedAt.equals(null) &
        (productId == null ? p.id.notEquals(null) : p.id.equals(productId)),
  );
  if (products.isEmpty) return const [];
  final productIds = {for (final p in products) p.id};

  final variants = await ProductVariant.db.find(
    session,
    where: (v) =>
        v.tenantId.equals(tenant) &
        v.deletedAt.equals(null) &
        v.productId.inSet(productIds),
    orderByList: (v) => [v.sortOrder, v.createdAt, v.id],
  );
  final variantIds = {for (final v in variants) v.id};
  final units = variantIds.isEmpty
      ? const <ProductUnit>[]
      : await ProductUnit.db.find(
          session,
          where: (u) =>
              u.tenantId.equals(tenant) &
              u.deletedAt.equals(null) &
              u.variantId.inSet(variantIds),
          orderByList: (u) => [u.factorMilli, u.id],
        );
  final tiers = variantIds.isEmpty
      ? const <ProductPriceTier>[]
      : await ProductPriceTier.db.find(
          session,
          where: (t) =>
              t.tenantId.equals(tenant) &
              t.deletedAt.equals(null) &
              t.variantId.inSet(variantIds),
          orderBy: (t) => t.minQtyMilli,
        );
  final unitNames = {
    for (final u in await MeasureUnit.db.find(
      session,
      where: (u) => u.tenantId.equals(tenant),
    ))
      u.id: u.name,
  };
  final categoryNames = {
    for (final c in await ProductCategory.db.find(
      session,
      where: (c) => c.tenantId.equals(tenant) & c.deletedAt.equals(null),
    ))
      c.id: c.name,
  };
  final location = await defaultStockLocation(store, scope);
  final stock = {
    for (final l
        in variantIds.isEmpty
            ? const <StockLevel>[]
            : await StockLevel.db.find(
                session,
                where: (l) =>
                    l.stockLocationId.equals(location.id) &
                    l.variantId.inSet(variantIds),
              ))
      l.variantId: Qty(l.quantityMilli),
  };

  final result = [
    for (final p in products)
      CatalogProduct(
        id: p.id,
        name: p.name,
        categoryId: categoryNames.containsKey(p.categoryId)
            ? p.categoryId
            : null,
        categoryName: categoryNames[p.categoryId],
        kind: _kindOf(p.type),
        baseUnitId: p.baseUnitId,
        baseUnit: unitNames[p.baseUnitId] ?? '',
        sku: p.sku,
        brand: p.brand,
        isActive: p.isActive,
        isTaxable: p.isTaxable,
        variants: [
          for (final v in variants.where((v) => v.productId == p.id))
            CatalogVariant(
              id: v.id,
              name: v.name,
              sku: v.sku,
              barcode: v.barcode,
              costPrice: Money(v.costPrice),
              sellPrice: Money(v.sellPrice),
              minStock: Qty(v.minStockMilli),
              stock: stock[v.id] ?? Qty.zero,
              units: [
                for (final u in units.where((u) => u.variantId == v.id))
                  CatalogUnit(
                    id: u.id,
                    unitId: u.unitId,
                    name: unitNames[u.unitId] ?? '',
                    factor: Qty(u.factorMilli),
                    barcode: u.barcode,
                    costPrice: u.costPrice == null ? null : Money(u.costPrice!),
                    sellPrice: u.sellPrice == null ? null : Money(u.sellPrice!),
                  ),
              ],
              tiers: [
                for (final t in tiers.where((t) => t.variantId == v.id))
                  PriceTier(
                    id: t.id.uuid,
                    minQty: Qty(t.minQtyMilli),
                    price: Money(t.price),
                  ),
              ],
            ),
        ],
      ),
  ];
  return result..sort(
    (a, b) => _byName(a.name, b.name) != 0
        ? _byName(a.name, b.name)
        : a.id.uuid.compareTo(b.id.uuid),
  );
}

/// Menyimpan [draft] (produk baru bila `draft.id` kosong) dalam satu
/// transaksi: cek kode unik, pastikan kategori/satuan, tulis produk,
/// varian, satuan konversi, dan grosir; baris yang hilang dari draf
/// di-soft-delete; stok awal varian baru dicatat di ledger. Mengembalikan ID
/// produk.
Future<UuidValue> saveProduct(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required ProductDraft draft,
}) async {
  final issues = validateProductDraft(draft);
  if (issues.isNotEmpty) throw ProductInputInvalid(issues);
  return store.write(
    actor: staffId,
    (w) => _ProductWriter(w, scope, staffId).save(draft),
  );
}

class _ProductWriter {
  _ProductWriter(this.w, this.scope, this.staffId);

  final SyncTx w;
  final CatalogScope scope;
  final UuidValue staffId;
  late final SyncStamp s;
  final _units = <String, UuidValue>{};

  Transaction get tx => w.transaction;
  UuidValue get tenant => scope.tenantId;

  Future<UuidValue> save(ProductDraft draft) async {
    final existing = await _existingProduct(draft.id);
    final oldVariants = existing == null
        ? const <ProductVariant>[]
        : await ProductVariant.db.find(
            w.session,
            where: (v) =>
                v.productId.equals(existing.id) & v.deletedAt.equals(null),
            transaction: tx,
          );
    await _checkCodes(draft, existing?.id);

    s = await w.stamp();
    final categoryId = _orNull(draft.category) == null
        ? null
        : await _ensureCategory(draft.category.trim());
    final baseUnitId = await _ensureUnit(draft.baseUnit.trim());

    final product = Product(
      id: existing?.id,
      tenantId: tenant,
      categoryId: categoryId,
      baseUnitId: baseUnitId,
      name: draft.name.trim(),
      type: _typeOf(draft.kind),
      sku: _orNull(draft.sku),
      brand: _orNull(draft.brand),
      isActive: draft.isActive,
      isTaxable: draft.isTaxable,
      createdAt: existing?.createdAt ?? s.now,
      updatedAt: existing?.updatedAt ?? s.now,
      createdBy: existing?.createdBy ?? staffId,
      updatedBy: existing?.updatedBy ?? staffId,
      version: existing?.version ?? 1,
      hlc: existing?.hlc ?? s.hlc.toString(),
      originDeviceId: existing?.originDeviceId ?? s.deviceId,
    );
    final productId = existing == null
        ? (await w.insert(product, s)).id
        : (await _updateIfChanged(
            existing,
            product,
            (r) => r.copyWith(
              updatedAt: s.now,
              updatedBy: staffId,
              version: r.version + 1,
              hlc: s.hlc.toString(),
              originDeviceId: s.deviceId,
            ),
          )).id;

    final kept = <UuidValue>{};
    StockLocation? location;
    for (var i = 0; i < draft.variants.length; i++) {
      final v = draft.variants[i];
      final old = oldVariants.where((o) => o.id.uuid == v.id).firstOrNull;
      final row = ProductVariant(
        id: old?.id,
        tenantId: tenant,
        productId: productId,
        name: v.name.trim(),
        sku: _orNull(v.sku),
        barcode: _orNull(v.barcode),
        costPrice: v.costPrice.value,
        sellPrice: v.sellPrice.value,
        minStockMilli: v.minStock.milli,
        sortOrder: i,
        createdAt: old?.createdAt ?? s.now,
        updatedAt: old?.updatedAt ?? s.now,
        createdBy: old?.createdBy ?? staffId,
        updatedBy: old?.updatedBy ?? staffId,
        version: old?.version ?? 1,
        hlc: old?.hlc ?? s.hlc.toString(),
        originDeviceId: old?.originDeviceId ?? s.deviceId,
      );
      final UuidValue variantId;
      if (old == null) {
        variantId = (await w.insert(row, s)).id;
        if (draft.kind.tracksStock && v.openingStock.isPositive) {
          location ??= await defaultStockLocationIn(w, scope);
          await recordStockMovement(
            w,
            scope,
            locationId: location.id,
            variantId: variantId,
            quantity: v.openingStock,
            unitCost: v.costPrice,
            sourceType: StockSourceType.opening,
            sourceId: variantId,
            stamp: s,
          );
        }
      } else {
        variantId = old.id;
        kept.add(variantId);
        await _updateIfChanged(old, row, _stampVariant);
      }
      await _saveUnits(variantId, v.units, isNew: old == null);
      await _saveTiers(variantId, v.tiers, isNew: old == null);
    }

    for (final old in oldVariants.where((o) => !kept.contains(o.id))) {
      await _saveUnits(old.id, const [], isNew: false);
      await _saveTiers(old.id, const [], isNew: false);
      await w.update(_stampVariant(old.copyWith(deletedAt: s.now)), s);
    }
    return productId;
  }

  ProductVariant _stampVariant(ProductVariant r) => r.copyWith(
    updatedAt: s.now,
    updatedBy: staffId,
    version: r.version + 1,
    hlc: s.hlc.toString(),
    originDeviceId: s.deviceId,
  );

  Future<Product?> _existingProduct(String? id) async {
    if (id == null) return null;
    final UuidValue productId;
    try {
      productId = UuidValue.fromString(id);
    } on FormatException {
      throw ProductNotFound();
    }
    final product = await Product.db.findFirstRow(
      w.session,
      where: (p) =>
          p.id.equals(productId) &
          p.tenantId.equals(tenant) &
          p.deletedAt.equals(null),
      transaction: tx,
    );
    if (product == null) throw ProductNotFound();
    return product;
  }

  /// Memperbarui [before] menjadi [after] (dengan kolom sync dari [stamped])
  /// hanya bila isinya berubah.
  Future<T> _updateIfChanged<T extends TableRow<UuidValue?>>(
    T before,
    T after,
    T Function(T row) stamped,
  ) async {
    if (jsonEncode(before.toJson()) == jsonEncode(after.toJson())) {
      return before;
    }
    return w.update(stamped(after), s);
  }

  Future<void> _saveUnits(
    UuidValue variantId,
    List<UnitDraft> drafts, {
    required bool isNew,
  }) async {
    final olds = isNew
        ? const <ProductUnit>[]
        : await ProductUnit.db.find(
            w.session,
            where: (u) =>
                u.variantId.equals(variantId) & u.deletedAt.equals(null),
            transaction: tx,
          );
    ProductUnit stamped(ProductUnit r) => r.copyWith(
      updatedAt: s.now,
      updatedBy: staffId,
      version: r.version + 1,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    );
    final kept = <UuidValue>{};
    for (final d in drafts) {
      final old = olds.where((o) => o.id.uuid == d.id).firstOrNull;
      final row = ProductUnit(
        id: old?.id,
        tenantId: tenant,
        variantId: variantId,
        unitId: await _ensureUnit(d.name.trim()),
        factorMilli: d.factor.milli,
        barcode: _orNull(d.barcode),
        costPrice: d.costPrice?.value,
        sellPrice: d.sellPrice?.value,
        createdAt: old?.createdAt ?? s.now,
        updatedAt: old?.updatedAt ?? s.now,
        createdBy: old?.createdBy ?? staffId,
        updatedBy: old?.updatedBy ?? staffId,
        version: old?.version ?? 1,
        hlc: old?.hlc ?? s.hlc.toString(),
        originDeviceId: old?.originDeviceId ?? s.deviceId,
      );
      if (old == null) {
        await w.insert(row, s);
      } else {
        kept.add(old.id);
        await _updateIfChanged(old, row, stamped);
      }
    }
    for (final old in olds.where((o) => !kept.contains(o.id))) {
      await w.update(stamped(old.copyWith(deletedAt: s.now)), s);
    }
  }

  Future<void> _saveTiers(
    UuidValue variantId,
    List<PriceTier> drafts, {
    required bool isNew,
  }) async {
    final olds = isNew
        ? const <ProductPriceTier>[]
        : await ProductPriceTier.db.find(
            w.session,
            where: (t) =>
                t.variantId.equals(variantId) & t.deletedAt.equals(null),
            transaction: tx,
          );
    ProductPriceTier stamped(ProductPriceTier r) => r.copyWith(
      updatedAt: s.now,
      updatedBy: staffId,
      version: r.version + 1,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    );
    final kept = <UuidValue>{};
    for (final d in drafts) {
      final old = olds.where((o) => o.id.uuid == d.id).firstOrNull;
      final row = ProductPriceTier(
        id: old?.id,
        tenantId: tenant,
        variantId: variantId,
        minQtyMilli: d.minQty.milli,
        price: d.price.value,
        createdAt: old?.createdAt ?? s.now,
        updatedAt: old?.updatedAt ?? s.now,
        createdBy: old?.createdBy ?? staffId,
        updatedBy: old?.updatedBy ?? staffId,
        version: old?.version ?? 1,
        hlc: old?.hlc ?? s.hlc.toString(),
        originDeviceId: old?.originDeviceId ?? s.deviceId,
      );
      if (old == null) {
        await w.insert(row, s);
      } else {
        kept.add(old.id);
        await _updateIfChanged(old, row, stamped);
      }
    }
    for (final old in olds.where((o) => !kept.contains(o.id))) {
      await w.update(stamped(old.copyWith(deletedAt: s.now)), s);
    }
  }

  Future<UuidValue> _ensureCategory(String name) async {
    final rows = await ProductCategory.db.find(
      w.session,
      where: (c) => c.tenantId.equals(tenant) & c.deletedAt.equals(null),
      transaction: tx,
    );
    final key = name.toLowerCase();
    final found = rows.where((c) => c.name.trim().toLowerCase() == key);
    if (found.isNotEmpty) return found.first.id;
    final row = await w.insert(
      ProductCategory(
        tenantId: tenant,
        name: name,
        sortOrder:
            rows.fold<int>(-1, (m, c) => c.sortOrder > m ? c.sortOrder : m) +
            1,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    return row.id;
  }

  Future<UuidValue> _ensureUnit(String name) async {
    final key = name.toLowerCase();
    final cached = _units[key];
    if (cached != null) return cached;
    final rows = await MeasureUnit.db.find(
      w.session,
      where: (u) => u.tenantId.equals(tenant) & u.deletedAt.equals(null),
      transaction: tx,
    );
    final found = rows.where((u) => u.name.trim().toLowerCase() == key);
    final id = found.isNotEmpty
        ? found.first.id
        : (await w.insert(
            MeasureUnit(
              tenantId: tenant,
              name: name,
              createdAt: s.now,
              updatedAt: s.now,
              createdBy: staffId,
              updatedBy: staffId,
              hlc: s.hlc.toString(),
              originDeviceId: s.deviceId,
            ),
            s,
          )).id;
    return _units[key] = id;
  }

  Future<void> _checkCodes(ProductDraft draft, UuidValue? productId) async {
    if (draft.skus.isEmpty && draft.barcodes.isEmpty) return;
    final names = {
      for (final p in await Product.db.find(
        w.session,
        where: (p) => p.tenantId.equals(tenant) & p.deletedAt.equals(null),
        transaction: tx,
      ))
        if (p.id != productId) p.id: p.name,
    };
    final variants = await ProductVariant.db.find(
      w.session,
      where: (v) => v.tenantId.equals(tenant) & v.deletedAt.equals(null),
      transaction: tx,
    );
    final ownerOfVariant = {
      for (final v in variants) v.id: ?names[v.productId],
    };
    final skus = <String, String>{};
    final barcodes = <String, String>{};
    for (final v in variants) {
      final owner = ownerOfVariant[v.id];
      if (owner == null) continue;
      if (v.sku case final sku?) skus[normalizeCode(sku)] = owner;
      if (v.barcode case final code?) barcodes[normalizeCode(code)] = owner;
    }
    for (final u in await ProductUnit.db.find(
      w.session,
      where: (u) => u.tenantId.equals(tenant) & u.deletedAt.equals(null),
      transaction: tx,
    )) {
      final owner = ownerOfVariant[u.variantId];
      if (owner != null && u.barcode != null) {
        barcodes[normalizeCode(u.barcode!)] = owner;
      }
    }

    final conflicts = <ProductCodeConflict>[];
    void check(
      Map<String, String> taken,
      String code,
      ProductField field,
      int variant, [
      int? unit,
    ]) {
      if (code.trim().isEmpty) return;
      final owner = taken[normalizeCode(code)];
      if (owner == null) return;
      conflicts.add(
        ProductCodeConflict(
          ProductIssue(field, ProductError.taken, variant: variant, unit: unit),
          owner,
        ),
      );
    }

    for (var i = 0; i < draft.variants.length; i++) {
      final v = draft.variants[i];
      check(skus, v.sku, ProductField.variantSku, i);
      check(barcodes, v.barcode, ProductField.variantBarcode, i);
      for (var j = 0; j < v.units.length; j++) {
        check(barcodes, v.units[j].barcode, ProductField.unitBarcode, i, j);
      }
    }
    if (conflicts.isNotEmpty) throw ProductCodesTaken(conflicts);
  }
}
