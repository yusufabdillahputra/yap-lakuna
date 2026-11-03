import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/master_data_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tab layar Master data (1.17) di v0.10.0.
enum MasterTab { categories, units, locations, payments }

/// View model layar Master data (F1-09): kategori, satuan, lokasi (baca),
/// metode bayar (tautan).
class MasterDataViewModel extends ChangeNotifier {
  MasterDataViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    saveCategory = Command0(_saveCategory)..addListener(notifyListeners);
    deleteCategory = Command0(_deleteCategory)..addListener(notifyListeners);
    move = Command1(_move)..addListener(notifyListeners);
    toggleActive = Command1(_toggleActive)..addListener(notifyListeners);
  }

  final MasterDataRepository _repository;

  late final Command0<void> load;
  late final Command0<void> saveCategory;
  late final Command0<void> deleteCategory;

  /// (id kategori, −1 naik / +1 turun).
  late final Command1<void, (UuidValue, int)> move;

  /// (id kategori, aktif).
  late final Command1<void, (UuidValue, bool)> toggleActive;

  MasterTab _tab = MasterTab.categories;
  List<CategoryRow> _categories = const [];
  List<UnitRow> _units = const [];
  List<StockLocation> _locations = const [];

  MasterTab get tab => _tab;
  List<CategoryRow> get categories => _categories;
  List<UnitRow> get units => _units;
  List<StockLocation> get locations => _locations;

  void setTab(MasterTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  /// Ada aksi tulis yang sedang berjalan; tombol lain dinonaktifkan.
  bool get busy =>
      saveCategory.running ||
      deleteCategory.running ||
      move.running ||
      toggleActive.running ||
      _unitBusy;

  Future<Result<void>> _load() async {
    final cats = await _repository.categories();
    final units = await _repository.units();
    final locations = await _repository.locations();
    for (final r in [cats, units, locations]) {
      if (r case Error(:final error)) return Result.error(error);
    }
    _categories = (cats as Ok<List<CategoryRow>>).value;
    _units = (units as Ok<List<UnitRow>>).value;
    _locations = (locations as Ok<List<StockLocation>>).value;
    return const Result.ok(null);
  }

  Future<void> _reloadCategories() async {
    final r = await _repository.categories();
    if (r case Ok(:final value)) _categories = value;
  }

  Future<void> _reloadUnits() async {
    final r = await _repository.units();
    if (r case Ok(:final value)) _units = value;
  }

  // --- Form kategori -------------------------------------------------------

  UuidValue? _editingId;
  int _formRevision = 0;
  String _name = '';
  String? _parentId;
  String? _color;
  bool _showInCashier = true;
  bool _isActive = true;
  List<CategoryError> _formErrors = const [];
  Object? _categoryError;
  String? _savedName;

  /// Kategori yang sedang diubah; `null` = form *Kategori baru*.
  UuidValue? get editingId => _editingId;
  bool get editing => _editingId != null;

  /// Naik setiap form diisi ulang (field teks dibuat ulang dengan isi baru).
  int get formRevision => _formRevision;
  String get name => _name;
  String? get parentId => _parentId;
  String? get color => _color;
  bool get showInCashier => _showInCashier;
  bool get isActive => _isActive;
  List<CategoryError> get formErrors => _formErrors;

  /// Galat aksi baris atau hapus ([MasterInUse], dsb.).
  Object? get categoryError => _categoryError;

  /// Nama kategori yang baru tersimpan (pesan sukses).
  String? get savedName => _savedName;

  /// Pilihan induk: kategori utama selain yang diubah. Kosong bila kategori
  /// yang diubah punya subkategori.
  List<ProductCategory> get parentOptions {
    final id = _editingId;
    if (id != null && _categories.any((r) => r.category.parentId == id)) {
      return const [];
    }
    return [
      for (final r in _categories)
        if (r.category.parentId == null && r.category.id != id) r.category,
    ];
  }

  CategoryRow? get editingRow =>
      _categories.where((r) => r.category.id == _editingId).firstOrNull;

  void _fill({
    UuidValue? id,
    String name = '',
    String? parentId,
    String? color,
    bool showInCashier = true,
    bool isActive = true,
  }) {
    _editingId = id;
    _name = name;
    _parentId = parentId;
    _color = color;
    _showInCashier = showInCashier;
    _isActive = isActive;
    _formErrors = const [];
    _categoryError = null;
    _formRevision++;
  }

  void startNew() {
    _fill();
    _savedName = null;
    notifyListeners();
  }

  void edit(CategoryRow row) {
    final c = row.category;
    _fill(
      id: c.id,
      name: c.name,
      parentId: c.parentId?.uuid,
      color: c.color,
      showInCashier: c.showInCashier,
      isActive: c.isActive,
    );
    _savedName = null;
    notifyListeners();
  }

  void _changed() {
    if (_formErrors.isNotEmpty) _formErrors = const [];
    _savedName = null;
    notifyListeners();
  }

  void setName(String v) {
    _name = v;
    _changed();
  }

  void setParent(String? id) {
    _parentId = id;
    _changed();
  }

  void setColor(String? hex) {
    _color = hex;
    _changed();
  }

  void setShowInCashier(bool v) {
    _showInCashier = v;
    _changed();
  }

  void setActive(bool v) {
    _isActive = v;
    _changed();
  }

  CategoryDraft get _draft => CategoryDraft(
    name: _name,
    parentId: _parentId,
    color: _color,
    showInCashier: _showInCashier,
    isActive: _isActive,
  );

  Future<Result<void>> _saveCategory() async {
    _categoryError = null;
    final id = _editingId;
    final draft = _draft;
    final result = id == null
        ? await _repository.createCategory(draft)
        : await _repository.updateCategory(id, draft);
    switch (result) {
      case Ok(:final value):
        await _reloadCategories();
        _fill();
        _savedName = value.name;
        return const Result.ok(null);
      case Error(:final error):
        if (error case CategoryInvalid(:final errors)) {
          _formErrors = errors;
        } else {
          _categoryError = error;
        }
        return Result.error(error);
    }
  }

  Future<Result<void>> _deleteCategory() async {
    final id = _editingId;
    if (id == null) return const Result.ok(null);
    _categoryError = null;
    final result = await _repository.deleteCategory(id);
    switch (result) {
      case Ok():
        await _reloadCategories();
        _fill();
        _savedName = null;
      case Error(:final error):
        _categoryError = error;
    }
    return result;
  }

  Future<Result<void>> _move((UuidValue, int) arg) async {
    _categoryError = null;
    final result = await _repository.moveCategory(arg.$1, arg.$2);
    if (result case Error(:final error)) _categoryError = error;
    await _reloadCategories();
    return result;
  }

  Future<Result<void>> _toggleActive((UuidValue, bool) arg) async {
    _categoryError = null;
    final result = await _repository.setCategoryActive(arg.$1, arg.$2);
    if (result case Error(:final error)) _categoryError = error;
    await _reloadCategories();
    // Saklar di tabel juga memperbarui form bila kategori itu sedang diubah.
    if (_editingId == arg.$1 && result is Ok) {
      _isActive = arg.$2;
    }
    return result;
  }

  // --- Satuan --------------------------------------------------------------

  bool _unitBusy = false;
  UnitNameError? _unitError;
  UuidValue? _unitErrorId;
  MasterInUse? _unitInUse;
  UuidValue? _unitInUseId;

  /// Galat nama satuan; [unitErrorId] = satuan yang diganti namanya, `null`
  /// = field satuan baru.
  UnitNameError? get unitError => _unitError;
  UuidValue? get unitErrorId => _unitErrorId;

  /// Hapus satuan ditolak (dipakai produk) untuk [unitInUseId].
  MasterInUse? get unitInUse => _unitInUse;
  UuidValue? get unitInUseId => _unitInUseId;

  void clearUnitError() {
    if (_unitError == null && _unitInUse == null) return;
    _unitError = null;
    _unitErrorId = null;
    _unitInUse = null;
    _unitInUseId = null;
    notifyListeners();
  }

  Future<bool> addUnit(String name) =>
      _unitAction(null, () => _repository.createUnit(name));

  Future<bool> renameUnit(UuidValue id, String name) =>
      _unitAction(id, () => _repository.renameUnit(id, name));

  Future<bool> deleteUnit(UuidValue id) =>
      _unitAction(id, () => _repository.deleteUnit(id));

  Future<bool> _unitAction(
    UuidValue? id,
    Future<Result<Object?>> Function() action,
  ) async {
    if (_unitBusy) return false;
    _unitBusy = true;
    _unitError = null;
    _unitErrorId = null;
    _unitInUse = null;
    _unitInUseId = null;
    notifyListeners();
    try {
      final result = await action();
      switch (result) {
        case Ok():
          await _reloadUnits();
          return true;
        case Error(:final error):
          if (error case UnitInvalid(:final error)) {
            _unitError = error;
            _unitErrorId = id;
          } else if (error case MasterInUse()) {
            _unitInUse = error;
            _unitInUseId = id;
          }
          return false;
      }
    } finally {
      _unitBusy = false;
      notifyListeners();
    }
  }
}
