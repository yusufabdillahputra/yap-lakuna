import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show TableRow, Transaction;

import 'media.dart';
import 'modifier_admin.dart' show productModifierLinks;
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

/// Grup pelanggan tingkat grosir tidak ada atau sudah dihapus (F1-07c).
class PriceTierGroupNotFound implements Exception {
  @override
  String toString() => 'PriceTierGroupNotFound';
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
    this.modifierGroupIds = const [],
    this.archivedAt,
    this.photoMediaId,
    this.photoPath,
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

  /// Grup modifier terpasang, urut tampil di 1.8 (F1-10b).
  final List<UuidValue> modifierGroupIds;

  /// Waktu diarsipkan (F1-07d); `null` = produk aktif di katalog.
  final DateTime? archivedAt;

  /// Foto produk (F1-07f).
  final UuidValue? photoMediaId;

  /// Lokasi berkas foto di perangkat ini; `null` bila tanpa foto atau
  /// berkasnya belum ada (mis. belum tersinkron).
  final String? photoPath;

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
    modifierGroupIds: [for (final id in modifierGroupIds) id.uuid],
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

UuidValue? _uuidOrNull(String s) {
  try {
    return UuidValue.fromString(s);
  } on FormatException {
    return null;
  }
}

PriceTier _tier(ProductPriceTier t) => PriceTier(
  id: t.id.uuid,
  minQty: Qty(t.minQtyMilli),
  price: Money(t.price),
  groupId: t.customerGroupId?.uuid,
);

Future<List<CatalogProduct>> _loadProducts(
  LakunaStore store,
  CatalogScope scope, {
  UuidValue? productId,
  bool archived = false,
}) async {
  final session = store.session;
  final tenant = scope.tenantId;
  final products = await Product.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(tenant) &
        (archived ? p.deletedAt.notEquals(null) : p.deletedAt.equals(null)) &
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
  final modifierLinks = await productModifierLinks(
    session,
    tenant,
    productIds: productIds,
  );
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

  final photoIds = {for (final p in products) ?p.photoMediaId};
  final photoPaths = <UuidValue?, String>{
    if (photoIds.isNotEmpty)
      for (final m in await MediaFile.db.find(
        session,
        where: (m) => m.tenantId.equals(tenant) & m.id.inSet(photoIds),
      ))
        m.id: ?_mediaPath(store, m),
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
        archivedAt: p.deletedAt,
        photoMediaId: p.photoMediaId,
        photoPath: photoPaths[p.photoMediaId],
        modifierGroupIds: [
          for (final l in modifierLinks)
            if (l.productId == p.id) l.modifierGroupId,
        ],
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
              // Tingkat semua pelanggan dulu, lalu tingkat grup (F1-07c).
              tiers: [
                for (final t in tiers.where(
                  (t) => t.variantId == v.id && t.customerGroupId == null,
                ))
                  _tier(t),
                for (final t in tiers.where(
                  (t) => t.variantId == v.id && t.customerGroupId != null,
                ))
                  _tier(t),
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

// --- Arsip (F1-07d) ----------------------------------------------------------

/// Produk diarsipkan tenant ini (hapus lunak), urut nama, dengan stok
/// terakhir di lokasi bawaan cabang.
Future<List<CatalogProduct>> listArchivedProducts(
  LakunaStore store,
  CatalogScope scope,
) => _loadProducts(store, scope, archived: true);

/// Jumlah produk diarsipkan (tombol *Diarsipkan (n)* di 1.15).
Future<int> countArchivedProducts(LakunaStore store, CatalogScope scope) =>
    Product.db.count(
      store.session,
      where: (p) =>
          p.tenantId.equals(scope.tenantId) & p.deletedAt.notEquals(null),
    );

/// Mengarsipkan produk [productId]: `deleted_at` diisi, varian dan riwayat
/// tidak diubah. [ProductNotFound] bila tidak ada di katalog tenant ini.
/// Izin `products:manage` dicek di repositori.
Future<void> archiveProduct(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue productId,
}) => store.write(actor: staffId, (w) async {
  final p = await Product.db.findFirstRow(
    w.session,
    where: (p) =>
        p.id.equals(productId) &
        p.tenantId.equals(scope.tenantId) &
        p.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (p == null) throw ProductNotFound();
  final s = await w.stamp();
  await w.update(_stampProduct(p.copyWith(deletedAt: s.now), staffId, s), s);
});

/// Memulihkan produk diarsipkan [productId]. SKU dan barcode diperiksa lagi
/// terhadap produk aktif ([ProductCodesTaken]); [ProductNotFound] bila
/// produk tidak sedang diarsipkan di tenant ini.
Future<void> restoreProduct(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue productId,
}) async {
  final archived = (await _loadProducts(
    store,
    scope,
    productId: productId,
    archived: true,
  )).firstOrNull;
  if (archived == null) throw ProductNotFound();
  await store.write(actor: staffId, (w) async {
    final p = await Product.db.findFirstRow(
      w.session,
      where: (p) =>
          p.id.equals(productId) &
          p.tenantId.equals(scope.tenantId) &
          p.deletedAt.notEquals(null),
      transaction: w.transaction,
    );
    if (p == null) throw ProductNotFound();
    await _ProductWriter(
      w,
      scope,
      staffId,
    )._checkCodes(archived.toDraft(), productId);
    // Kategori yang terhapus selama produk diarsipkan dilepas, sehingga
    // produk kembali tanpa kategori (satuan dijaga oleh `deleteUnit`).
    final category = p.categoryId == null
        ? null
        : await ProductCategory.db.findById(
            w.session,
            p.categoryId!,
            transaction: w.transaction,
          );
    final keepCategory = category != null && category.deletedAt == null;
    final s = await w.stamp();
    await w.update(
      _stampProduct(
        p.copyWith(
          deletedAt: null,
          categoryId: keepCategory ? p.categoryId : null,
        ),
        staffId,
        s,
      ),
      s,
    );
  });
}

// --- Foto produk (F1-07f) ---------------------------------------------------

/// Berkas foto produk yang dipilih pengguna.
class ProductPhotoUpload {
  const ProductPhotoUpload({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

enum ProductPhotoError { unsupported, tooLarge }

/// Berkas foto bukan PNG/JPG/WebP atau lebih dari
/// [ProductLimits.photoMaxBytes].
class ProductPhotoInvalid implements Exception {
  const ProductPhotoInvalid(this.reason);

  final ProductPhotoError reason;

  @override
  String toString() => 'ProductPhotoInvalid(${reason.name})';
}

String? _mediaPath(LakunaStore store, MediaFile media) {
  final path =
      '${store.mediaDirectory}${Platform.pathSeparator}${media.storageKey}';
  return File(path).existsSync() ? path : null;
}

Future<Product> _activeProduct(
  SyncTx w,
  CatalogScope scope,
  UuidValue productId,
) async {
  final p = await Product.db.findFirstRow(
    w.session,
    where: (p) =>
        p.id.equals(productId) &
        p.tenantId.equals(scope.tenantId) &
        p.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (p == null) throw ProductNotFound();
  return p;
}

/// Memasang [photo] sebagai foto produk [productId] (menggantikan foto
/// lama). Gagal dengan [ProductPhotoInvalid] atau [ProductNotFound] tanpa
/// menulis apa pun. Izin `products:manage` dicek di repositori.
Future<void> setProductPhoto(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue productId,
  required ProductPhotoUpload photo,
}) async {
  final header = readImageHeader(photo.bytes);
  if (header == null) {
    throw const ProductPhotoInvalid(ProductPhotoError.unsupported);
  }
  if (photo.bytes.length > ProductLimits.photoMaxBytes) {
    throw const ProductPhotoInvalid(ProductPhotoError.tooLarge);
  }
  await store.write(actor: staffId, (w) async {
    final p = await _activeProduct(w, scope, productId);
    final s = await w.stamp();
    final media = await storeMediaFile(
      w,
      store,
      scope,
      bytes: photo.bytes,
      header: header,
      fileName: photo.fileName,
      kind: MediaKind.productPhoto,
      stamp: s,
    );
    if (p.photoMediaId == media.id) return;
    await w.update(
      _stampProduct(p.copyWith(photoMediaId: media.id), staffId, s),
      s,
    );
  });
}

/// Melepas foto produk [productId]; tidak menulis apa pun bila produk tidak
/// punya foto. Berkas media tetap disimpan (bisa dipakai riwayat sinkron).
Future<void> clearProductPhoto(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue productId,
}) => store.write(actor: staffId, (w) async {
  final p = await _activeProduct(w, scope, productId);
  if (p.photoMediaId == null) return;
  final s = await w.stamp();
  await w.update(_stampProduct(p.copyWith(photoMediaId: null), staffId, s), s);
});

Product _stampProduct(Product p, UuidValue staffId, SyncStamp s) => p.copyWith(
  version: p.version + 1,
  updatedAt: s.now,
  updatedBy: staffId,
  hlc: s.hlc.toString(),
  originDeviceId: s.deviceId,
);

// --- Import (F1-07b) --------------------------------------------------------

class ProductImportSummary {
  const ProductImportSummary({
    required this.created,
    required this.skippedLines,
  });

  final int created;

  /// Baris berkas yang dilewati karena nama, SKU, atau barcode-nya sudah
  /// dipakai produk yang ada.
  final List<int> skippedLines;
}

/// Menyimpan baris import sah sebagai produk baru dalam satu transaksi.
/// Produk yang sudah ada (nama tanpa beda huruf/spasi, SKU, atau barcode)
/// dilewati, bukan ditimpa, sehingga import ulang tidak menggandakan stok.
/// Izin `products:manage` dicek di repositori, sama dengan [saveProduct].
Future<ProductImportSummary> importProducts(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required List<ProductImportRow> rows,
}) async {
  // Baris dari luar aplikasi diperiksa ulang di sini; satu baris salah
  // membatalkan seluruh import.
  for (final r in rows) {
    if (r.draft.id != null) {
      throw ArgumentError.value(r.line, 'rows', 'import hanya produk baru');
    }
    final issues = validateProductDraft(r.draft);
    if (issues.isNotEmpty) throw ProductInputInvalid(issues);
  }
  return store.write(actor: staffId, (w) async {
    final tenant = scope.tenantId;
    final products = await Product.db.find(
      w.session,
      where: (p) => p.tenantId.equals(tenant) & p.deletedAt.equals(null),
      transaction: w.transaction,
    );
    final live = {for (final p in products) p.id};
    final names = {for (final p in products) productImportNameKey(p.name)};
    final variants = await ProductVariant.db.find(
      w.session,
      where: (v) => v.tenantId.equals(tenant) & v.deletedAt.equals(null),
      transaction: w.transaction,
    );
    final liveVariants = <UuidValue>{};
    final skus = <String>{};
    final barcodes = <String>{};
    for (final v in variants) {
      if (!live.contains(v.productId)) continue;
      liveVariants.add(v.id);
      if (v.sku case final sku?) skus.add(normalizeCode(sku));
      if (v.barcode case final code?) barcodes.add(normalizeCode(code));
    }
    for (final u in await ProductUnit.db.find(
      w.session,
      where: (u) => u.tenantId.equals(tenant) & u.deletedAt.equals(null),
      transaction: w.transaction,
    )) {
      if (liveVariants.contains(u.variantId) && u.barcode != null) {
        barcodes.add(normalizeCode(u.barcode!));
      }
    }

    final writer = _ProductWriter(w, scope, staffId);
    var created = 0;
    final skipped = <int>[];
    for (final r in rows) {
      final d = r.draft;
      final name = productImportNameKey(d.name);
      final rowSkus = {
        for (final v in d.variants)
          if (v.sku.trim().isNotEmpty) normalizeCode(v.sku),
      };
      final rowBarcodes = {
        for (final v in d.variants) ...[
          if (v.barcode.trim().isNotEmpty) normalizeCode(v.barcode),
          for (final u in v.units)
            if (u.barcode.trim().isNotEmpty) normalizeCode(u.barcode),
        ],
      };
      if (names.contains(name) ||
          rowSkus.any(skus.contains) ||
          rowBarcodes.any(barcodes.contains)) {
        skipped.add(r.line);
        continue;
      }
      await writer.save(d, checkCodes: false);
      names.add(name);
      skus.addAll(rowSkus);
      barcodes.addAll(rowBarcodes);
      created++;
    }
    return ProductImportSummary(created: created, skippedLines: skipped);
  });
}

class _ProductWriter {
  _ProductWriter(this.w, this.scope, this.staffId);

  final SyncTx w;
  final CatalogScope scope;
  final UuidValue staffId;
  late SyncStamp s;
  final _units = <String, UuidValue>{};
  final _categories = <String, UuidValue>{};
  StockLocation? _location;

  Transaction get tx => w.transaction;
  UuidValue get tenant => scope.tenantId;

  /// Pasang grup modifier [ids] berurutan (1.16b): baris lama yang tidak
  /// dipilih dihapus lunak, urutan yang berubah diperbarui.
  Future<void> _saveModifierLinks(UuidValue productId, List<String> ids) async {
    final wanted = <UuidValue>[];
    for (final id in ids) {
      final uuid = UuidValue.withValidation(id);
      if (!wanted.contains(uuid)) wanted.add(uuid);
    }
    if (wanted.isNotEmpty) {
      final groups = await ModifierGroup.db.find(
        w.session,
        where: (g) =>
            g.tenantId.equals(tenant) &
            g.deletedAt.equals(null) &
            g.id.inSet(wanted.toSet()),
        transaction: tx,
      );
      if (groups.length != wanted.length) {
        throw const ProductInputInvalid([
          ProductIssue(ProductField.modifierGroups, ProductError.missing),
        ]);
      }
    }
    final old = await ProductModifierGroup.db.find(
      w.session,
      where: (l) =>
          l.tenantId.equals(tenant) &
          l.productId.equals(productId) &
          l.deletedAt.equals(null),
      transaction: tx,
    );
    for (final l in old) {
      final i = wanted.indexOf(l.modifierGroupId);
      if (i == l.sortOrder) continue;
      await w.update(
        l.copyWith(
          sortOrder: i < 0 ? l.sortOrder : i,
          deletedAt: i < 0 ? s.now : null,
          version: l.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
    final linked = {for (final l in old) l.modifierGroupId};
    for (final (i, id) in wanted.indexed) {
      if (linked.contains(id)) continue;
      await w.insert(
        ProductModifierGroup(
          tenantId: tenant,
          productId: productId,
          modifierGroupId: id,
          sortOrder: i,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
  }

  /// [checkCodes] `false` hanya untuk import yang sudah memeriksa kode
  /// kembar sendiri untuk seluruh berkas (satu kueri, bukan per baris).
  Future<UuidValue> save(ProductDraft draft, {bool checkCodes = true}) async {
    final existing = await _existingProduct(draft.id);
    final oldVariants = existing == null
        ? const <ProductVariant>[]
        : await ProductVariant.db.find(
            w.session,
            where: (v) =>
                v.productId.equals(existing.id) & v.deletedAt.equals(null),
            transaction: tx,
          );
    if (checkCodes) await _checkCodes(draft, existing?.id);

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
      // Foto diubah lewat setProductPhoto / clearProductPhoto saja.
      photoMediaId: existing?.photoMediaId,
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
          final location = _location ??= await defaultStockLocationIn(w, scope);
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
    // Produk baru tanpa grup modifier tidak punya tautan untuk diperiksa.
    if (existing != null || draft.modifierGroupIds.isNotEmpty) {
      await _saveModifierLinks(productId, draft.modifierGroupIds);
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
    // Grup pelanggan tingkat harus aktif di tenant ini (F1-07c).
    final wanted = {for (final d in drafts) ?d.groupId};
    final groupIds = <String?, UuidValue>{};
    if (wanted.isNotEmpty) {
      final groups = await CustomerGroup.db.find(
        w.session,
        where: (g) =>
            g.tenantId.equals(tenant) &
            g.id.inSet({for (final g in wanted) ?_uuidOrNull(g)}) &
            g.deletedAt.equals(null),
        transaction: tx,
      );
      for (final g in groups) {
        groupIds[g.id.uuid] = g.id;
      }
      if (groupIds.length != wanted.length) throw PriceTierGroupNotFound();
    }
    final kept = <UuidValue>{};
    for (final d in drafts) {
      final old = olds.where((o) => o.id.uuid == d.id).firstOrNull;
      final row = ProductPriceTier(
        id: old?.id,
        tenantId: tenant,
        variantId: variantId,
        minQtyMilli: d.minQty.milli,
        price: d.price.value,
        customerGroupId: groupIds[d.groupId],
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
    final cached = _categories[name.toLowerCase()];
    if (cached != null) return cached;
    final rows = await ProductCategory.db.find(
      w.session,
      where: (c) => c.tenantId.equals(tenant) & c.deletedAt.equals(null),
      transaction: tx,
    );
    final key = name.toLowerCase();
    final found = rows.where((c) => c.name.trim().toLowerCase() == key);
    if (found.isNotEmpty) return _categories[key] = found.first.id;
    final row = await w.insert(
      ProductCategory(
        tenantId: tenant,
        name: name,
        sortOrder:
            rows.fold<int>(-1, (m, c) => c.sortOrder > m ? c.sortOrder : m) + 1,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    return _categories[key] = row.id;
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
