import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/dining_admin_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Satu meja di draf *Atur denah*. [key] = id meja, atau `baru-n` untuk
/// meja yang belum tersimpan.
@immutable
class FloorItem {
  const FloorItem({
    required this.key,
    this.id,
    required this.name,
    this.seats = 4,
    this.shape = TableShape.square,
    this.x,
    this.y,
    this.width = 80,
    this.height = 80,
    this.canMerge = false,
    this.loose = false,
  });

  factory FloorItem.of(DiningTable t) => FloorItem(
    key: t.id.toString(),
    id: t.id,
    name: t.name,
    seats: t.seats,
    shape: t.shape,
    x: t.posX,
    y: t.posY,
    width: t.width,
    height: t.height,
    canMerge: t.canMerge,
    loose: t.diningAreaId == null,
  );

  final String key;
  final UuidValue? id;
  final String name;
  final int seats;
  final TableShape shape;
  final int? x;
  final int? y;
  final int width;
  final int height;
  final bool canMerge;

  /// Meja tanpa area (pindah ke area ini bila ditempatkan).
  final bool loose;

  bool get placed => x != null && y != null;

  /// Orientasi 90° (tegak).
  bool get vertical => height > width;

  FloorItem copyWith({
    String? name,
    int? seats,
    TableShape? shape,
    int? x,
    int? y,
    int? width,
    int? height,
    bool? canMerge,
  }) => FloorItem(
    key: key,
    id: id,
    name: name ?? this.name,
    seats: seats ?? this.seats,
    shape: shape ?? this.shape,
    x: x ?? this.x,
    y: y ?? this.y,
    width: width ?? this.width,
    height: height ?? this.height,
    canMerge: canMerge ?? this.canMerge,
    loose: loose,
  );

  FloorTableDraft toDraft() => FloorTableDraft(
    id: id,
    name: name,
    seats: seats,
    shape: shape,
    x: x,
    y: y,
    width: width,
    height: height,
    canMerge: canMerge,
  );

  @override
  bool operator ==(Object other) =>
      other is FloorItem &&
      other.key == key &&
      other.name == name &&
      other.seats == seats &&
      other.shape == shape &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      other.canMerge == canMerge;

  @override
  int get hashCode => Object.hash(
    key,
    name,
    seats,
    shape,
    x,
    y,
    width,
    height,
    canMerge,
  );
}

/// Bentuk meja dari palet domain.
TableShape tableShapeOf(FloorShape s) => TableShape.values.byName(s.name);

@immutable
class _Snapshot {
  const _Snapshot(this.items, this.mode, this.deleted);

  final List<FloorItem> items;
  final DiningLayoutMode mode;
  final List<UuidValue> deleted;

  @override
  bool operator ==(Object other) =>
      other is _Snapshot &&
      other.mode == mode &&
      listEquals(other.items, items) &&
      listEquals(other.deleted, deleted);

  @override
  int get hashCode =>
      Object.hash(mode, Object.hashAll(items), Object.hashAll(deleted));
}

/// View model *Atur denah* (1.7d) dan unggah denah (1.7c). Semua perubahan
/// meja dan mode adalah draf sampai [save].
class FloorPlanViewModel extends ChangeNotifier {
  FloorPlanViewModel({
    required this._repository,
    required this._picker,
    UuidValue? initialArea,
  }) : _areaId = initialArea {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
    upload = Command1(_upload)..addListener(notifyListeners);
    addArea = Command1(_addArea)..addListener(notifyListeners);
  }

  final DiningAdminRepository _repository;
  final ImageFilePicker _picker;

  late final Command0<void> load;
  late final Command0<void> save;

  /// Argumen: `true` = kamera, `false` = pilih berkas.
  late final Command1<void, bool> upload;
  late final Command1<void, String> addArea;

  FloorPlanSetup? _setup;
  UuidValue? _areaId;
  var _items = <FloorItem>[];
  var _mode = DiningLayoutMode.grid;
  var _deleted = <UuidValue>[];
  _Snapshot? _saved;
  final _undo = <_Snapshot>[];
  final _redo = <_Snapshot>[];
  String? _coalesce;
  String? _selected;
  var _newCount = 0;
  var _snap = true;
  var _opacity = 1.0;
  Exception? _error;
  int? _errorIndex;
  var _revision = 0;
  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  // --- Keadaan --------------------------------------------------------------

  bool get loaded => _setup != null;

  Exception? get loadError => switch (load.result) {
    Error(:final error) => error,
    _ => null,
  };

  List<DiningArea> get areas => _setup?.areas ?? const [];

  DiningArea? get area =>
      areas.where((a) => a.id == _areaId).firstOrNull ?? areas.firstOrNull;

  /// Gambar denah area terpilih.
  FloorImage? get image =>
      area == null ? null : _setup?.images[area!.id];

  ({int width, int height}) get world =>
      image?.world ?? floorWorldSize(null, null);

  DiningLayoutMode get mode => _mode;

  /// Kanvas tampil (mode denah dan gambar sudah ada).
  bool get showCanvas => _mode == DiningLayoutMode.floor && image != null;

  List<FloorItem> get items => List.unmodifiable(_items);
  List<FloorItem> get placed => [
    for (final i in _items)
      if (i.placed) i,
  ];

  /// Meja area ini tanpa posisi lalu meja tanpa area.
  List<FloorItem> get unplaced => [
    for (final i in _items)
      if (!i.placed && !i.loose) i,
    for (final i in _items)
      if (!i.placed && i.loose) i,
  ];

  FloorItem? get selected =>
      _items.where((i) => i.key == _selected).firstOrNull;

  bool get snap => _snap;
  double get opacity => _opacity;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// Ada perubahan yang belum disimpan.
  bool get dirty => _saved != null && _snapshot() != _saved;

  /// Naik setiap draf berubah (kanvas menyelaraskan node).
  int get revision => _revision;

  /// Galat aksi terakhir; [errorItem] = meja draf yang ditolak (bila ada).
  Exception? get error => _error;
  FloorItem? get errorItem {
    final i = _errorIndex;
    if (i == null) return null;
    final drafts = _drafts();
    return i < drafts.length ? drafts[i].$1 : null;
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    _errorIndex = null;
    notifyListeners();
  }

  // --- Muat & area ------------------------------------------------------------

  Future<Result<void>> _load() async {
    final result = await _repository.loadFloorPlan();
    if (result case Ok(:final value)) {
      _setup = value;
      _reset();
    }
    return result;
  }

  void _reset() {
    final a = area;
    _areaId = a?.id;
    _mode = a?.layoutMode ?? DiningLayoutMode.grid;
    _items = [
      for (final t in _setup?.tables ?? const <DiningTable>[])
        if (a != null && (t.diningAreaId == a.id || t.diningAreaId == null))
          FloorItem.of(t),
    ];
    _deleted = [];
    _undo.clear();
    _redo.clear();
    _coalesce = null;
    _selected = null;
    _error = null;
    _errorIndex = null;
    _saved = _snapshot();
    _revision++;
  }

  /// Pindah ke area [id]; draf yang belum disimpan dibuang (view bertanya
  /// lebih dulu bila [dirty]).
  void selectArea(UuidValue id) {
    if (id == _areaId) return;
    _areaId = id;
    _reset();
    notifyListeners();
  }

  /// Muat ulang dari database (membuang draf).
  void discard() {
    _reset();
    notifyListeners();
  }

  Future<Result<void>> _addArea(String name) async {
    final result = await _repository.createArea(name);
    switch (result) {
      case Ok(:final value):
        _areaId = value.id;
        _error = null;
        return _load();
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  // --- Draf -------------------------------------------------------------------

  _Snapshot _snapshot() =>
      _Snapshot(List.unmodifiable(_items), _mode, List.unmodifiable(_deleted));

  /// Catat keadaan sebelum perubahan; [tag] yang sama berturut-turut
  /// (mis. mengetik nama) digabung jadi satu langkah undo.
  void _commit([String? tag]) {
    if (tag == null || tag != _coalesce) {
      _undo.add(_snapshot());
      _redo.clear();
    }
    _coalesce = tag;
  }

  void _changed() {
    _error = null;
    _errorIndex = null;
    _revision++;
    notifyListeners();
  }

  void _restore(_Snapshot s) {
    _items = List.of(s.items);
    _mode = s.mode;
    _deleted = List.of(s.deleted);
    if (selected == null) _selected = null;
    _coalesce = null;
    _changed();
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(_snapshot());
    _restore(_undo.removeLast());
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(_snapshot());
    _restore(_redo.removeLast());
  }

  void setMode(DiningLayoutMode mode) {
    if (mode == _mode) return;
    _commit();
    _mode = mode;
    _changed();
  }

  void toggleSnap() {
    _snap = !_snap;
    notifyListeners();
  }

  void setOpacity(double value) {
    _opacity = value.clamp(0.2, 1.0);
    notifyListeners();
  }

  void select(String? key) {
    if (key == _selected) return;
    _selected = key;
    _coalesce = null;
    notifyListeners();
  }

  int _snapped(num v) => _snap ? snapTo(v, FloorLimits.grid) : snapTo(v, 0);

  int _clampPos(int v) => v.clamp(0, FloorLimits.maxPosition);

  /// Pojok kiri atas agar meja [w]×[h] berpusat di ([cx], [cy]).
  (int, int) _centered(num cx, num cy, int w, int h) => (
    _clampPos(_snapped(cx - w / 2)),
    _clampPos(_snapped(cy - h / 2)),
  );

  /// Ketuk palet: meja baru `M<n>` di tengah tampilan ([cx], [cy]).
  void addPreset(TablePreset preset, {required num cx, required num cy}) {
    _commit();
    final (x, y) = _centered(cx, cy, preset.width, preset.height);
    final item = FloorItem(
      key: 'baru-${++_newCount}',
      name: nextTableName(_allNames()),
      seats: preset.seats,
      shape: tableShapeOf(preset.shape),
      x: x,
      y: y,
      width: preset.width,
      height: preset.height,
    );
    _items = [..._items, item];
    _selected = item.key;
    _changed();
  }

  /// Nama semua meja cabang (draf + meja area lain) untuk nama otomatis.
  Iterable<String> _allNames() sync* {
    final keys = {for (final i in _items) i.key};
    for (final t in _setup?.tables ?? const <DiningTable>[]) {
      if (!keys.contains(t.id.toString())) yield t.name;
    }
    for (final i in _items) {
      yield i.name;
    }
  }

  void _replace(String key, FloorItem Function(FloorItem) change, [String? tag]) {
    final i = _items.indexWhere((e) => e.key == key);
    if (i < 0) return;
    final next = change(_items[i]);
    if (next == _items[i]) return;
    _commit(tag == null ? null : '$tag:$key');
    _items = [..._items]..[i] = next;
    _changed();
  }

  /// Ketuk *Belum ditempatkan*: taruh di tengah tampilan.
  void place(String key, {required num cx, required num cy}) {
    _replace(key, (e) {
      final (x, y) = _centered(cx, cy, e.width, e.height);
      return e.copyWith(x: x, y: y);
    });
    _selected = key;
    notifyListeners();
  }

  /// Akhir geser di kanvas.
  void moveTo(String key, num x, num y) => _replace(
    key,
    (e) => e.copyWith(x: _clampPos(_snapped(x)), y: _clampPos(_snapped(y))),
  );

  /// Akhir ubah ukuran di kanvas (pojok kiri atas bisa ikut bergeser).
  void resizeTo(String key, num x, num y, num width, num height) =>
      _replace(key, (e) {
        int size(num v) {
          final s = _snapped(v);
          return s.clamp(FloorLimits.minSize, FloorLimits.maxSize);
        }

        return e.copyWith(
          x: _clampPos(_snapped(x)),
          y: _clampPos(_snapped(y)),
          width: size(width),
          height: size(height),
        );
      });

  void _edit(FloorItem Function(FloorItem) change, String tag) {
    final key = _selected;
    if (key != null) _replace(key, change, tag);
  }

  void setName(String name) => _edit((e) => e.copyWith(name: name), 'name');

  /// Isian kosong/tidak sah diabaikan (kolom tetap menampilkan ketikan).
  void setSeats(int? seats) {
    if (seats == null) return;
    _edit((e) => e.copyWith(seats: seats), 'seats');
  }

  void setShape(TableShape shape) => _edit((e) {
    // Meja bulat dan kursi bar dibuat sama sisi.
    final square = shape == TableShape.round || shape == TableShape.bar;
    final side = e.width < e.height ? e.width : e.height;
    return e.copyWith(
      shape: shape,
      width: square ? side : null,
      height: square ? side : null,
    );
  }, 'shape');

  void setWidth(int? width) {
    if (width == null) return;
    _edit((e) => e.copyWith(width: width), 'width');
  }

  void setHeight(int? height) {
    if (height == null) return;
    _edit((e) => e.copyWith(height: height), 'height');
  }

  /// Orientasi 0° (mendatar) / 90° (tegak): tukar lebar dan tinggi.
  void setVertical(bool vertical) => _edit((e) {
    if (e.vertical == vertical || e.width == e.height) return e;
    return e.copyWith(width: e.height, height: e.width);
  }, 'orientation');

  void setCanMerge(bool value) =>
      _edit((e) => e.copyWith(canMerge: value), 'merge');

  /// Hapus meja terpilih dari draf (meja tersimpan dihapus saat [save]).
  void deleteSelected() {
    final item = selected;
    if (item == null) return;
    _commit();
    _items = [
      for (final i in _items)
        if (i.key != item.key) i,
    ];
    if (item.id case final id?) _deleted = [..._deleted, id];
    _selected = null;
    _changed();
  }

  // --- Simpan & unggah --------------------------------------------------------

  /// Draf yang dikirim saat simpan: meja area ini dan meja tanpa area yang
  /// sudah ditempatkan.
  List<(FloorItem, FloorTableDraft)> _drafts() => [
    for (final i in _items)
      if (!i.loose || i.placed) (i, i.toDraft()),
  ];

  Future<Result<void>> _save() async {
    final a = area;
    if (a == null) return const Result.ok(null);
    final result = await _repository.saveFloorLayout(
      a.id,
      mode: _mode,
      tables: [for (final d in _drafts()) d.$2],
      deleted: _deleted,
    );
    switch (result) {
      case Ok():
        final selectedName = selected?.name;
        await _load();
        _selected = _items
            .where((i) => i.name == selectedName)
            .firstOrNull
            ?.key;
        notifyListeners();
      case Error(:final error):
        _error = error;
        _errorIndex = switch (error) {
          DiningNameInvalid(:final index) => index,
          FloorTableInvalid(:final index) => index,
          _ => null,
        };
        if (errorItem case final item?) _selected = item.key;
        notifyListeners();
    }
    return result;
  }

  Future<Result<void>> _upload(bool camera) async {
    final a = area;
    if (a == null) return const Result.ok(null);
    _error = null;
    const max = FloorLimits.imageBytes;
    final picked = camera
        ? await _picker.takePhoto(maxBytes: max)
        : await _picker.pickImage(maxBytes: max, vector: true);
    if (picked == null) return const Result.ok(null);
    final bytes = picked.bytes;
    if (bytes == null) {
      _error = const FloorImageInvalid(FloorImageError.tooLarge);
      notifyListeners();
      return Result.error(_error!);
    }
    final result = await _repository.saveFloorImage(a.id, bytes, picked.name);
    switch (result) {
      case Ok():
        final reloaded = await _repository.loadFloorPlan();
        if (reloaded case Ok(:final value)) {
          _setup = value;
          // Gambar langsung tersimpan (area jadi mode denah); draf meja
          // tetap dan dibandingkan dengan keadaan database terbaru.
          _mode = DiningLayoutMode.floor;
          _saved = _savedFromSetup();
          _revision++;
        }
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        notifyListeners();
        return Result.error(error);
    }
  }

  /// Keadaan tersimpan menurut database (setelah unggah di tengah draf).
  _Snapshot _savedFromSetup() {
    final a = area;
    return _Snapshot(
      List.unmodifiable([
        for (final t in _setup?.tables ?? const <DiningTable>[])
          if (a != null && (t.diningAreaId == a.id || t.diningAreaId == null))
            FloorItem.of(t),
      ]),
      a?.layoutMode ?? DiningLayoutMode.grid,
      const [],
    );
  }
}
