import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tab kartu kanan form 1.16; *Modifier* (1.16b) sejak v0.12.0.
enum ProductTab { variants, units, tiers, modifiers }

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
  EditableTier(
    this.key, {
    this.id,
    this.minQty = Qty.zero,
    this.price,
    this.groupId,
  });

  final int key;
  final String? id;
  Qty minQty;

  /// Grup pelanggan (UUID); `null` = semua pelanggan (F1-07c).
  String? groupId;

  /// `null` selama field masih kosong (ditolak saat simpan).
  Money? price;

  PriceTier toDraft() => PriceTier(
    id: id,
    minQty: minQty,
    price: price ?? Money.zero,
    groupId: groupId,
  );
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

  /// Naik setiap kali barcode diisi dari luar field (*Buat barcode*,
  /// F1-07h) supaya field teks dibuat ulang dengan nilai baru.
  int barcodeRevision = 0;

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
  ProductFormViewModel({
    required this._repository,
    String? productId,
    this._picker = const FileSelectorImagePicker(),
    Random? random,
  }) : _routeId = productId == null ? null : UuidValue.fromString(productId),
       _random = random ?? Random.secure() {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
    archive = Command0(_archive)..addListener(notifyListeners);
    pickPhoto = Command0(
      () => _choosePhoto(_picker.pickImage),
    )..addListener(notifyListeners);
    takePhoto = Command0(
      () => _choosePhoto(
        ({required maxBytes}) => _picker.takePhoto(
          maxBytes: maxBytes,
          maxWidth: ProductLimits.cameraMaxWidth,
        ),
      ),
    )..addListener(notifyListeners);
  }

  final CatalogRepository _repository;
  final ImageFilePicker _picker;
  final UuidValue? _routeId;
  final Random _random;

  /// Produk yang diubah: ID rute, atau produk baru yang sudah tersimpan
  /// tetapi fotonya gagal disimpan.
  UuidValue? get productId => _savedId ?? _routeId;

  late final Command0<ProductCatalog> load;
  late final Command0<UuidValue> save;

  /// Arsipkan produk lama (F1-07d). Gagal dengan `NotPermitted` atau
  /// `ProductNotFound`.
  late final Command0<void> archive;

  /// Pilih foto dari berkas / kamera (F1-07f); baru tersimpan saat *Simpan*.
  late final Command0<void> pickPhoto;
  late final Command0<void> takePhoto;

  String? _photoPath;
  bool _hasStoredPhoto = false;
  Uint8List? _newPhoto;
  String _newPhotoName = '';
  bool _removePhoto = false;
  ProductPhotoError? _photoError;

  /// Produk baru yang sudah tersimpan tetapi fotonya gagal: simpan ulang
  /// mengubah produk ini, bukan membuat produk baru lagi.
  UuidValue? _savedId;

  /// Foto tersimpan (lokasi berkas); `null` bila tidak ada atau dihapus.
  String? get photoPath => _removePhoto ? null : _photoPath;

  /// Foto baru yang belum disimpan.
  Uint8List? get photoBytes => _newPhoto;

  /// Ada foto (baru, atau tersimpan walau berkasnya belum ada di perangkat).
  bool get hasPhoto => _newPhoto != null || (_hasStoredPhoto && !_removePhoto);

  /// Berkas terakhir yang dipilih ditolak.
  ProductPhotoError? get photoError => _photoError;

  bool get canTakePhoto => _picker.canTakePhoto;

  Future<Result<void>> _choosePhoto(
    Future<PickedImage?> Function({required int maxBytes}) pick,
  ) async {
    final PickedImage? picked;
    try {
      picked = await pick(maxBytes: ProductLimits.photoMaxBytes);
    } on Exception catch (e) {
      // Izin kamera ditolak, berkas tidak terbaca, dll.
      _photoError = ProductPhotoError.unreadable;
      return Result.error(e);
    }
    if (picked == null) return const Result.ok(null);
    final bytes = picked.bytes;
    if (bytes == null) {
      _photoError = ProductPhotoError.tooLarge;
    } else if (readImageHeader(bytes) == null) {
      _photoError = ProductPhotoError.unsupported;
    } else {
      _photoError = null;
      _newPhoto = bytes;
      _newPhotoName = picked.name;
      _removePhoto = false;
    }
    return const Result.ok(null);
  }

  /// Lepas foto (baru tersimpan saat *Simpan*).
  void removePhoto() {
    _newPhoto = null;
    _removePhoto = true;
    _photoError = null;
    notifyListeners();
  }

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
  bool _sendToKitchen = true;
  bool _allowNote = true;
  final variants = <EditableVariant>[];

  /// Grup modifier terpasang, urut tampil di sheet 1.8.
  final _modifierGroupIds = <UuidValue>[];

  ProductTab _tab = ProductTab.variants;
  // `key` varian terpilih (bukan indeks) agar tidak bergeser saat baris
  // lain dihapus.
  int? _selectedKey;
  final _problems = <_FieldKey, FieldProblem>{};

  bool get isNew => productId == null;
  bool get loaded => _loaded;

  /// Produk yang diubah tidak ditemukan.
  bool get notFound => _notFound;

  /// Nama produk saat dimuat (untuk judul `Edit produk · nama`).
  String get originalName => _originalName;

  /// Tombol *Arsipkan produk*: hanya produk lama yang termuat.
  bool get canArchive => !isNew && _loaded && !_notFound;

  /// Stok tersisa produk yang melacak stok dan ≠ 0 (peringatan konfirmasi
  /// arsip), dengan satuan dasarnya; `null` bila tidak perlu peringatan.
  (Qty, String)? get archiveStock {
    final p = _catalog?.products.where((p) => p.id == productId).firstOrNull;
    if (p == null || !p.tracksStock || p.totalStock == Qty.zero) return null;
    return (p.totalStock, p.baseUnit);
  }

  Future<Result<void>> _archive() async {
    final id = productId;
    if (id == null || save.running) return const Result.ok(null);
    return _repository.archive(id);
  }

  /// Galat yang bukan milik satu field.
  Exception? get error => _error;

  ProductKind get kind => _kind;
  bool get isActive => _isActive;
  bool get isTaxable => _isTaxable;

  /// Sakelar *Kirim ke tiket dapur* (1.16b, F1-10g).
  bool get sendToKitchen => _sendToKitchen;

  /// Sakelar *Bisa catatan bebas* (1.16b, F1-10g).
  bool get allowNote => _allowNote;
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
    for (final c in _catalog?.categories ?? const <ProductCategory>[])
      if (c.isActive) c.name,
  ];
  List<String> get unitSuggestions => [
    for (final u in _catalog?.units ?? const <MeasureUnit>[]) u.name,
  ];

  int _key() => _nextKey++;

  // --- Modifier (1.16b) ----------------------------------------------------

  List<ModifierGroupDetail> get _allGroups =>
      _catalog?.modifierGroups ?? const [];

  /// Grup terpasang sesuai urutan; grup yang tidak dikenal dilewati.
  List<ModifierGroupDetail> get attachedGroups => [
    for (final id in _modifierGroupIds)
      ?_allGroups.where((g) => g.id == id).firstOrNull,
  ];

  /// Grup master yang belum terpasang (urut master).
  List<ModifierGroupDetail> get availableGroups => [
    for (final g in _allGroups)
      if (!_modifierGroupIds.contains(g.id)) g,
  ];

  void attachGroup(UuidValue id) {
    if (save.running || _modifierGroupIds.contains(id)) return;
    _modifierGroupIds.add(id);
    _clear(ProductField.modifierGroups, notify: false);
    notifyListeners();
  }

  void detachGroup(UuidValue id) {
    if (save.running || !_modifierGroupIds.remove(id)) return;
    _clear(ProductField.modifierGroups, notify: false);
    notifyListeners();
  }

  /// Pindah [delta] posisi (−1 naik, +1 turun).
  void moveGroup(UuidValue id, int delta) {
    final i = _modifierGroupIds.indexOf(id);
    if (save.running || i < 0) return;
    final j = (i + delta).clamp(0, _modifierGroupIds.length - 1);
    if (i == j) return;
    _modifierGroupIds.insert(j, _modifierGroupIds.removeAt(i));
    notifyListeners();
  }

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

  /// Barcode varian yang masih kosong di form diisi dari data tersimpan,
  /// mis. setelah dibuat massal di Cetak label (F1-07j). Isian lain di form
  /// tidak disentuh.
  Future<void> refreshBarcodes() async {
    final id = productId;
    if (id == null) return;
    switch (await _repository.loadCatalog()) {
      case Ok(:final value):
        _catalog = value;
        final product = value.products.where((p) => p.id == id).firstOrNull;
        if (product == null) return;
        var changed = false;
        for (final v in variants) {
          if (v.id == null || v.barcode.trim().isNotEmpty) continue;
          final stored = product.variants
              .where((s) => s.id.uuid == v.id)
              .firstOrNull
              ?.barcode;
          if (stored == null || stored.trim().isEmpty) continue;
          v
            ..barcode = stored
            ..barcodeRevision += 1;
          changed = true;
        }
        if (changed) notifyListeners();
      case Error():
        break;
    }
  }

  void _fill(CatalogProduct p) {
    _photoPath = p.photoPath;
    _hasStoredPhoto = p.photoMediaId != null;
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
    _sendToKitchen = d.sendToKitchen;
    _allowNote = d.allowNote;
    _modifierGroupIds
      ..clear()
      ..addAll(p.modifierGroupIds);
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
                  groupId: t.groupId,
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

  void setSendToKitchen(bool v) {
    _sendToKitchen = v;
    notifyListeners();
  }

  void setAllowNote(bool v) {
    _allowNote = v;
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

  /// *Buat barcode* (F1-07h): isi barcode varian [index] dengan EAN-13 toko
  /// yang belum dipakai di form ini maupun di katalog yang dimuat (produk
  /// ini sendiri dilewati karena kodenya sudah ada di form).
  void generateBarcode(int index) {
    final taken = <String>{
      for (final p in _catalog?.products ?? const <CatalogProduct>[])
        if (p.id != productId)
          for (final v in p.variants) ...[
            // SKU ikut dihindari: Kasir juga mencocokkan scan dengan SKU.
            if (v.sku case final sku? when sku.trim().isNotEmpty)
              barcodeKey(sku),
            if (v.barcode case final code? when code.trim().isNotEmpty)
              barcodeKey(code),
            for (final u in v.units)
              if (u.barcode case final code? when code.trim().isNotEmpty)
                barcodeKey(code),
          ],
      for (final v in variants) ...[
        if (v.sku.trim().isNotEmpty) barcodeKey(v.sku),
        if (v.barcode.trim().isNotEmpty) barcodeKey(v.barcode),
        for (final u in v.units)
          if (u.barcode.trim().isNotEmpty) barcodeKey(u.barcode),
      ],
    };
    final variant = variants[index];
    variant
      ..barcode = generateStoreEan13(_random, isTaken: taken.contains)
      ..barcodeRevision += 1;
    _clear(ProductField.variantBarcode, variant: variant.key, notify: false);
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

  /// Grup pelanggan untuk *Berlaku untuk* (urut nama).
  List<CustomerGroup> get customerGroups =>
      _catalog?.customerGroups ?? const [];

  /// Ganti grup tingkat [index]; galat jumlah (mis. kembar) ikut hilang
  /// karena keunikan dihitung per grup.
  void setTierGroup(int variant, int index, String? groupId) {
    if (save.running) return;
    final t = variants[variant].tiers[index];
    if (t.groupId == groupId) return;
    t.groupId = groupId;
    // Kembar dihitung per grup: galat jumlah baris lain ikut kedaluwarsa.
    for (final other in variants[variant].tiers) {
      _clear(
        ProductField.tierMinQty,
        variant: variants[variant].key,
        tier: other.key,
        notify: false,
      );
    }
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
    ProductField.modifierGroups => ProductTab.modifiers,
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
    id: (_savedId ?? productId)?.uuid,
    name: name,
    category: category,
    kind: _kind,
    baseUnit: baseUnit,
    sku: sku,
    brand: brand,
    isActive: _isActive,
    isTaxable: _isTaxable,
    sendToKitchen: _sendToKitchen,
    allowNote: _allowNote,
    variants: [for (final v in variants) v.toDraft()],
    modifierGroupIds: [for (final id in _modifierGroupIds) id.uuid],
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
    if (result case Ok(value: final id)) return _savePhoto(id);
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

  Future<Result<UuidValue>> _savePhoto(UuidValue id) async {
    final photo = _newPhoto;
    final Result<void> result;
    if (photo != null) {
      result = await _repository.setPhoto(
        id,
        ProductPhotoUpload(bytes: photo, fileName: _newPhotoName),
      );
    } else if (_removePhoto && _hasStoredPhoto) {
      result = await _repository.clearPhoto(id);
    } else {
      return Result.ok(id);
    }
    if (result case Error(:final error)) {
      // Produk sudah tersimpan: isi ulang form dari data tersimpan (ID
      // varian, tanpa stok awal) agar *Simpan* lagi hanya mengubahnya.
      _savedId = id;
      await _reload(id);
      _error = ProductPhotoNotSaved(error);
      return Result.error(_error!);
    }
    return Result.ok(id);
  }

  Future<void> _reload(UuidValue id) async {
    if (await _repository.loadCatalog() case Ok(:final value)) {
      _catalog = value;
      final product = value.products.where((p) => p.id == id).firstOrNull;
      if (product != null) _fill(product);
    }
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

/// Produk tersimpan tetapi fotonya gagal disimpan (F1-07f).
class ProductPhotoNotSaved implements Exception {
  const ProductPhotoNotSaved(this.cause);

  final Exception cause;

  @override
  String toString() => 'ProductPhotoNotSaved($cause)';
}
