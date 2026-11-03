import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tab kartu kanan form 1.16.
enum ProductTab { variants, units, tiers }

/// Satuan konversi yang sedang diedit. [key] stabil selama form terbuka
/// supaya field teks tidak tertukar saat baris dihapus.
class EditableUnit {
  EditableUnit(
    this.key, {
    this.id,
    this.name = '',
    this.factor = Qty.zero,
    this.barcode = '',
    this.costPrice,
    this.sellPrice,
  });

  final int key;
  final String? id;
  String name;
  Qty factor;
  String barcode;
  Money? costPrice;
  Money? sellPrice;

  UnitDraft toDraft() => UnitDraft(
    id: id,
    name: name,
    factor: factor,
    barcode: barcode,
    costPrice: costPrice,
    sellPrice: sellPrice,
  );
}

class EditableTier {
  EditableTier(this.key, {this.id, this.minQty = Qty.zero, this.price});

  final int key;
  final String? id;
  Qty minQty;

  /// `null` selama field masih kosong (ditolak saat simpan).
  Money? price;

  PriceTier toDraft() =>
      PriceTier(id: id, minQty: minQty, price: price ?? Money.zero);
}

class EditableVariant {
  EditableVariant(
    this.key, {
    this.id,
    this.name = '',
    this.sku = '',
    this.barcode = '',
    this.costPrice = Money.zero,
    this.sellPrice = Money.zero,
    this.minStock = Qty.zero,
    this.openingStock = Qty.zero,
    List<EditableUnit>? units,
    List<EditableTier>? tiers,
  }) : units = units ?? [],
       tiers = tiers ?? [];

  final int key;

  /// `null` = varian baru (stok awal boleh diisi).
  final String? id;
  String name;
  String sku;
  String barcode;
  Money costPrice;
  Money sellPrice;
  Qty minStock;
  Qty openingStock;
  final List<EditableUnit> units;
  final List<EditableTier> tiers;

  bool get isNew => id == null;

  VariantDraft toDraft() => VariantDraft(
    id: id,
    name: name,
    sku: sku,
    barcode: barcode,
    costPrice: costPrice,
    sellPrice: sellPrice,
    minStock: minStock,
    openingStock: isNew ? openingStock : Qty.zero,
    units: [for (final u in units) u.toDraft()],
    tiers: [for (final t in tiers) t.toDraft()],
  );
}

/// Galat sebuah field form, beserta nama produk pemilik kode bila
/// [ProductError.taken].
@immutable
class FieldProblem {
  const FieldProblem(this.error, {this.takenBy});

  final ProductError error;
  final String? takenBy;
}

typedef _FieldKey = (ProductField, int?, int?, int?);

/// View model form produk 1.16 (F1-07): tambah ([productId] `null`) atau
/// ubah produk. ID rute yang tidak ada di katalog → [notFound].
class ProductFormViewModel extends ChangeNotifier {
  ProductFormViewModel({required this._repository, String? productId})
    : _rawId = productId,
      productId = productId == null ? null : UuidValue.fromString(productId) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
  }

  final CatalogRepository _repository;
  final String? _rawId;
  final UuidValue? productId;

  late final Command0<ProductCatalog> load;
  late final Command0<UuidValue> save;

  var _nextKey = 0;
  bool _loaded = false;
  bool _notFound = false;
  Exception? _error;
  ProductCatalog? _catalog;
  String _originalName = '';

  String name = '';
  String category = '';
  ProductKind _kind = ProductKind.goods;
  String baseUnit = '';
  String sku = '';
  String brand = '';
  bool _isActive = true;
  bool _isTaxable = false;
  final variants = <EditableVariant>[];

  ProductTab _tab = ProductTab.variants;
  // `key` varian terpilih (bukan indeks) agar tidak bergeser saat baris
  // lain dihapus.
  int? _selectedKey;
  final _problems = <_FieldKey, FieldProblem>{};

  bool get isNew => _rawId == null;
  bool get loaded => _loaded;

  /// Produk yang diubah tidak ditemukan.
  bool get notFound => _notFound;

  /// Nama produk saat dimuat (untuk judul `Edit produk · nama`).
  String get originalName => _originalName;

  /// Galat yang bukan milik satu field.
  Exception? get error => _error;

  ProductKind get kind => _kind;
  bool get isActive => _isActive;
  bool get isTaxable => _isTaxable;
  ProductTab get tab => _tab;

  /// Indeks varian yang dipilih di tab Satuan dan Harga grosir.
  int get selectedVariant {
    final i = variants.indexWhere((v) => v.key == _selectedKey);
    return i < 0 ? 0 : i;
  }

  /// Ada galat di field mana pun (spanduk "Periksa isian").
  bool get hasProblems => _problems.isNotEmpty;

  /// Saran nama kategori dan satuan dari katalog.
  List<String> get categorySuggestions => [
    for (final c in _catalog?.categories ?? const <ProductCategory>[]) c.name,
  ];
  List<String> get unitSuggestions => [
    for (final u in _catalog?.units ?? const <MeasureUnit>[]) u.name,
  ];

  int _key() => _nextKey++;

  Future<Result<ProductCatalog>> _load() async {
    final result = await _repository.loadCatalog();
    switch (result) {
      case Ok(:final value):
        _catalog = value;
        final id = productId;
        if (isNew) {
          if (variants.isEmpty) variants.add(EditableVariant(_key()));
        } else {
          final product = value.products.where((p) => p.id == id).firstOrNull;
          if (product == null) {
            _notFound = true;
          } else {
            _fill(product);
          }
        }
        _loaded = true;
      case Error():
        break;
    }
    return result;
  }

  void _fill(CatalogProduct p) {
    final d = p.toDraft();
    _originalName = d.name;
    name = d.name;
    category = d.category;
    _kind = d.kind;
    baseUnit = d.baseUnit;
    sku = d.sku;
    brand = d.brand;
    _isActive = d.isActive;
    _isTaxable = d.isTaxable;
    variants
      ..clear()
      ..addAll([
        for (final v in d.variants)
          EditableVariant(
            _key(),
            id: v.id,
            name: v.name,
            sku: v.sku,
            barcode: v.barcode,
            costPrice: v.costPrice,
            sellPrice: v.sellPrice,
            minStock: v.minStock,
            units: [
              for (final u in v.units)
                EditableUnit(
                  _key(),
                  id: u.id,
                  name: u.name,
                  factor: u.factor,
                  barcode: u.barcode,
                  costPrice: u.costPrice,
                  sellPrice: u.sellPrice,
                ),
            ],
            tiers: [
              for (final t in v.tiers)
                EditableTier(
                  _key(),
                  id: t.id,
                  minQty: t.minQty,
                  price: t.price,
                ),
            ],
          ),
      ]);
  }

  // --- Info dasar ----------------------------------------------------------

  void setName(String v) {
    name = v;
    _clear(ProductField.name);
  }

  void setCategory(String v) {
    category = v;
    _clear(ProductField.category);
  }

  void setBaseUnit(String v) {
    final changed = v.trim() != baseUnit.trim();
    baseUnit = v;
    _clear(ProductField.baseUnit);
    // Label "Harga per <satuan>" dan teks bantu ikut berubah.
    if (changed) notifyListeners();
  }

  void setSku(String v) {
    sku = v;
    _clear(ProductField.sku);
  }

  void setBrand(String v) {
    brand = v;
    _clear(ProductField.brand);
  }

  void setKind(ProductKind v) {
    _kind = v;
    notifyListeners();
  }

  void setActive(bool v) {
    _isActive = v;
    notifyListeners();
  }

  void setTaxable(bool v) {
    _isTaxable = v;
    notifyListeners();
  }

  // --- Tab dan pilihan varian ---------------------------------------------

  void setTab(ProductTab v) {
    if (v == _tab) return;
    _tab = v;
    notifyListeners();
  }

  void selectVariant(int index) {
    _selectedKey = variants[index].key;
    notifyListeners();
  }

  // --- Varian --------------------------------------------------------------

  void addVariant() {
    variants.add(EditableVariant(_key()));
    notifyListeners();
  }

  void removeVariant(int index) {
    // Selama menyimpan, indeks baris dipakai untuk memetakan galat.
    if (variants.length <= 1 || save.running) return;
    variants.removeAt(index);
    _problems.clear();
    notifyListeners();
  }

  /// Mengubah varian [index] lewat [edit], lalu menghapus galat [field].
  void editVariant(
    int index,
    ProductField field,
    void Function(EditableVariant v) edit,
  ) {
    edit(variants[index]);
    _clear(field, variant: variants[index].key, notify: false);
    // Judul baris, petunjuk harga satuan, dan teks bantu ikut nilai ini.
    notifyListeners();
  }

  // --- Satuan konversi -----------------------------------------------------

  void addUnit(int variant) {
    variants[variant].units.add(EditableUnit(_key()));
    notifyListeners();
  }

  void removeUnit(int variant, int index) {
    if (save.running) return;
    variants[variant].units.removeAt(index);
    _problems.clear();
    notifyListeners();
  }

  void editUnit(
    int variant,
    int index,
    ProductField field,
    void Function(EditableUnit u) edit,
  ) {
    final u = variants[variant].units[index];
    edit(u);
    _clear(field, variant: variants[variant].key, unit: u.key, notify: false);
    notifyListeners();
  }

  // --- Harga grosir --------------------------------------------------------

  void addTier(int variant) {
    variants[variant].tiers.add(EditableTier(_key()));
    notifyListeners();
  }

  void removeTier(int variant, int index) {
    if (save.running) return;
    variants[variant].tiers.removeAt(index);
    _problems.clear();
    notifyListeners();
  }

  void editTier(
    int variant,
    int index,
    ProductField field,
    void Function(EditableTier t) edit,
  ) {
    final t = variants[variant].tiers[index];
    edit(t);
    _clear(field, variant: variants[variant].key, tier: t.key, notify: false);
    notifyListeners();
  }

  // --- Galat ---------------------------------------------------------------

  /// Galat [field]; [variant]/[unit]/[tier] adalah `key` baris.
  FieldProblem? problem(
    ProductField field, {
    int? variant,
    int? unit,
    int? tier,
  }) => _problems[(field, variant, unit, tier)];

  /// Ada galat di [tab] (titik merah di label tab).
  bool tabHasProblem(ProductTab tab) =>
      _problems.keys.any((k) => _tabOf(k.$1) == tab);

  /// Ada galat di [tab] untuk varian ber-`key` [variant].
  bool variantHasProblem(ProductTab tab, int variant) =>
      _problems.keys.any((k) => _tabOf(k.$1) == tab && k.$2 == variant);

  static ProductTab? _tabOf(ProductField f) => switch (f) {
    ProductField.variants ||
    ProductField.variantName ||
    ProductField.variantSku ||
    ProductField.variantBarcode ||
    ProductField.costPrice ||
    ProductField.sellPrice ||
    ProductField.minStock ||
    ProductField.openingStock => ProductTab.variants,
    ProductField.unitName ||
    ProductField.unitFactor ||
    ProductField.unitBarcode ||
    ProductField.unitCostPrice ||
    ProductField.unitSellPrice => ProductTab.units,
    ProductField.tierMinQty || ProductField.tierPrice => ProductTab.tiers,
    _ => null,
  };

  void _clear(
    ProductField field, {
    int? variant,
    int? unit,
    int? tier,
    bool notify = true,
  }) {
    final hadField = _problems.remove((field, variant, unit, tier)) != null;
    final hadError = _error != null;
    _error = null;
    if (notify && (hadField || hadError)) notifyListeners();
  }

  // --- Simpan --------------------------------------------------------------

  ProductDraft get draft => ProductDraft(
    id: productId?.uuid,
    name: name,
    category: category,
    kind: _kind,
    baseUnit: baseUnit,
    sku: sku,
    brand: brand,
    isActive: _isActive,
    isTaxable: _isTaxable,
    variants: [for (final v in variants) v.toDraft()],
  );

  Future<Result<UuidValue>> _save() async {
    _problems.clear();
    _error = null;
    final d = draft;
    final found = [
      ...validateProductDraft(d),
      // Harga grosir yang belum diisi ditolak sebagai "wajib", bukan "harus
      // lebih dari 0".
      for (var i = 0; i < variants.length; i++)
        for (var k = 0; k < variants[i].tiers.length; k++)
          if (variants[i].tiers[k].price == null)
            ProductIssue(
              ProductField.tierPrice,
              ProductError.required,
              variant: i,
              tier: k,
            ),
    ];
    // Galat "wajib" menang atas galat lain di field yang sama (urutan
    // lain dipertahankan).
    final issues = [
      ...found.where((i) => i.error == ProductError.required),
      ...found.where((i) => i.error != ProductError.required),
    ];
    if (issues.isNotEmpty) {
      _show([for (final i in issues) (i, null)]);
      return Result.error(ProductInputInvalid(issues));
    }
    final result = await _repository.save(d);
    if (result case Error(:final error)) {
      switch (error) {
        case ProductInputInvalid(:final issues):
          _show([for (final i in issues) (i, null)]);
        case ProductCodesTaken(:final conflicts):
          _show([for (final c in conflicts) (c.issue, c.takenBy)]);
        default:
          _error = error;
      }
    }
    return result;
  }

  void _show(List<(ProductIssue, String?)> issues) {
    ProductTab? firstTab;
    int? firstVariant;
    for (final (issue, takenBy) in issues) {
      final tab = _tabOf(issue.field);
      // Tab pertama menurut urutan form, bukan urutan galat.
      if (tab != null && (firstTab == null || tab.index < firstTab.index)) {
        firstTab = tab;
        firstVariant = issue.variant;
      }
      final v = issue.variant == null ? null : variants[issue.variant!];
      final key = (
        issue.field,
        v?.key,
        issue.unit == null ? null : v!.units[issue.unit!].key,
        issue.tier == null ? null : v!.tiers[issue.tier!].key,
      );
      // Galat pertama per field menang (mis. "wajib" sebelum "kembar").
      _problems.putIfAbsent(
        key,
        () => FieldProblem(issue.error, takenBy: takenBy),
      );
    }
    if (firstTab != null && !tabHasProblem(_tab)) {
      _tab = firstTab;
      if (firstVariant != null && firstTab != ProductTab.variants) {
        _selectedKey = variants[firstVariant].key;
      }
    }
  }
}
