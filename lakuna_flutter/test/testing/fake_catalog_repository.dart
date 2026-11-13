import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/catalog_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Katalog di memori dengan validasi `lakuna_domain` dan cek kode unik yang
/// sama dengan `lakuna_data`.
class FakeCatalogRepository extends CatalogRepository {
  FakeCatalogRepository({this.permissions, List<ProductDraft>? seed}) {
    for (final d in seed ?? const <ProductDraft>[]) {
      _store(d, null);
    }
  }

  /// Izin staf; `null` = semua izin.
  Set<Permission>? permissions;
  final _tenant = _id();
  final products = <CatalogProduct>[];
  final categories = <ProductCategory>[];
  final units = <MeasureUnit>[];
  final saved = <ProductDraft>[];

  /// Grup modifier master untuk tab *Modifier*.
  List<ModifierGroupDetail> modifierGroups = const [];

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;
  var loadCalls = 0;

  Exception? _check() {
    final e = nextError;
    nextError = null;
    if (e != null) return e;
    final p = permissions;
    if (p != null && !p.contains(Permission.productsManage)) {
      return const NotPermitted(Permission.productsManage);
    }
    return null;
  }

  @override
  Future<Result<ProductCatalog>> loadCatalog() async {
    loadCalls++;
    if (_check() case final e?) return Result.error(e);
    final sorted = [...products]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return Result.ok(
      ProductCatalog(
        products: sorted,
        categories: List.of(categories),
        units: List.of(units),
        modifierGroups: List.of(modifierGroups),
      ),
    );
  }

  @override
  Future<Result<CatalogProduct?>> loadProduct(UuidValue id) async {
    if (_check() case final e?) return Result.error(e);
    return Result.ok(products.where((p) => p.id == id).firstOrNull);
  }

  /// Baris yang diterima `importRows`.
  final imported = <ProductImportRow>[];

  @override
  Future<Result<ProductImportSummary>> importRows(
    List<ProductImportRow> rows,
  ) async {
    if (_check() case final e?) return Result.error(e);
    var created = 0;
    final skipped = <int>[];
    for (final r in rows) {
      final name = productImportNameKey(r.draft.name);
      final exists = products.any((p) => productImportNameKey(p.name) == name);
      if (exists || _conflicts(r.draft, null).isNotEmpty) {
        skipped.add(r.line);
        continue;
      }
      imported.add(r);
      _store(r.draft, null);
      created++;
    }
    return Result.ok(
      ProductImportSummary(created: created, skippedLines: skipped),
    );
  }

  @override
  Future<Result<UuidValue>> save(ProductDraft draft) async {
    if (_check() case final e?) return Result.error(e);
    final issues = validateProductDraft(draft);
    if (issues.isNotEmpty) return Result.error(ProductInputInvalid(issues));
    final existing = draft.id == null
        ? null
        : products.where((p) => p.id.uuid == draft.id).firstOrNull;
    if (draft.id != null && existing == null) {
      return Result.error(ProductNotFound());
    }
    final conflicts = _conflicts(draft, existing?.id);
    if (conflicts.isNotEmpty) return Result.error(ProductCodesTaken(conflicts));
    saved.add(draft);
    return Result.ok(_store(draft, existing));
  }

  List<ProductCodeConflict> _conflicts(ProductDraft d, UuidValue? self) {
    final skus = <String, String>{};
    final barcodes = <String, String>{};
    for (final p in products.where((p) => p.id != self)) {
      for (final v in p.variants) {
        if (v.sku case final s?) skus[normalizeCode(s)] = p.name;
        if (v.barcode case final b?) barcodes[normalizeCode(b)] = p.name;
        for (final u in v.units) {
          if (u.barcode case final b?) barcodes[normalizeCode(b)] = p.name;
        }
      }
    }
    final out = <ProductCodeConflict>[];
    void check(
      Map<String, String> m,
      String code,
      ProductField f,
      int i, [
      int? j,
    ]) {
      final owner = code.trim().isEmpty ? null : m[normalizeCode(code)];
      if (owner != null) {
        out.add(
          ProductCodeConflict(
            ProductIssue(f, ProductError.taken, variant: i, unit: j),
            owner,
          ),
        );
      }
    }

    for (final (i, v) in d.variants.indexed) {
      check(skus, v.sku, ProductField.variantSku, i);
      check(barcodes, v.barcode, ProductField.variantBarcode, i);
      for (final (j, u) in v.units.indexed) {
        check(barcodes, u.barcode, ProductField.unitBarcode, i, j);
      }
    }
    return out;
  }

  UuidValue _ensureUnit(String name) {
    final found = units
        .where((u) => u.name.toLowerCase() == name.trim().toLowerCase())
        .firstOrNull;
    if (found != null) return found.id;
    final u = MeasureUnit(tenantId: _tenant, name: name.trim(), hlc: '');
    units.add(u);
    return u.id;
  }

  UuidValue _store(ProductDraft d, CatalogProduct? existing) {
    String? orNull(String s) => s.trim().isEmpty ? null : s.trim();
    UuidValue? categoryId;
    final category = d.category.trim();
    if (category.isNotEmpty) {
      final found = categories
          .where((c) => c.name.toLowerCase() == category.toLowerCase())
          .firstOrNull;
      final c =
          found ??
          ProductCategory(
            tenantId: _tenant,
            name: category,
            sortOrder: categories.length,
            hlc: '',
          );
      if (found == null) categories.add(c);
      categoryId = c.id;
    }
    final baseUnitId = _ensureUnit(d.baseUnit);
    final product = CatalogProduct(
      id: existing?.id ?? _id(),
      name: d.name.trim(),
      categoryId: categoryId,
      categoryName: categoryId == null
          ? null
          : categories.firstWhere((c) => c.id == categoryId).name,
      kind: d.kind,
      baseUnitId: baseUnitId,
      baseUnit: units.firstWhere((u) => u.id == baseUnitId).name,
      sku: orNull(d.sku),
      brand: orNull(d.brand),
      isActive: d.isActive,
      isTaxable: d.isTaxable,
      modifierGroupIds: [
        for (final id in d.modifierGroupIds) UuidValue.fromString(id),
      ],
      variants: [
        for (final v in d.variants)
          CatalogVariant(
            id: v.id == null ? _id() : UuidValue.fromString(v.id!),
            name: v.name.trim(),
            sku: orNull(v.sku),
            barcode: orNull(v.barcode),
            costPrice: v.costPrice,
            sellPrice: v.sellPrice,
            minStock: v.minStock,
            stock: v.id == null
                ? (d.kind.tracksStock ? v.openingStock : Qty.zero)
                : existing!.variants.firstWhere((x) => x.id.uuid == v.id).stock,
            units: [
              for (final u in v.units)
                CatalogUnit(
                  id: u.id == null ? _id() : UuidValue.fromString(u.id!),
                  unitId: _ensureUnit(u.name),
                  name: u.name.trim(),
                  factor: u.factor,
                  barcode: orNull(u.barcode),
                  costPrice: u.costPrice,
                  sellPrice: u.sellPrice,
                ),
            ],
            tiers: [
              for (final t in v.tiers)
                PriceTier(
                  id: t.id ?? newId(),
                  minQty: t.minQty,
                  price: t.price,
                ),
            ],
          ),
      ],
    );
    if (existing != null) {
      products[products.indexOf(existing)] = product;
    } else {
      products.add(product);
    }
    return product.id;
  }
}
