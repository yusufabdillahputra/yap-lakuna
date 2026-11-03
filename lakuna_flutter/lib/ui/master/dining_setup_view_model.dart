import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/dining_admin_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Isian *Tambah beberapa* meja: "M1–M12" sekaligus.
class TableRange {
  const TableRange({
    required this.prefix,
    required this.from,
    required this.to,
    required this.seats,
    this.areaId,
  });

  final String prefix;
  final int from;
  final int to;
  final int seats;
  final UuidValue? areaId;
}

/// View model tab Master data › Meja & area (F1-10).
class DiningSetupViewModel extends ChangeNotifier {
  DiningSetupViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    addArea = Command1(_addArea)..addListener(notifyListeners);
    renameArea = Command1(_renameArea)..addListener(notifyListeners);
    moveArea = Command1(_moveArea)..addListener(notifyListeners);
    deleteArea = Command1(_deleteArea)..addListener(notifyListeners);
    saveTable = Command1(_saveTable)..addListener(notifyListeners);
    addRange = Command1(_addRange)..addListener(notifyListeners);
    moveTable = Command1(_moveTable)..addListener(notifyListeners);
    deleteTable = Command1(_deleteTable)..addListener(notifyListeners);
  }

  final DiningAdminRepository _repository;

  late final Command0<DiningSetup> load;
  late final Command1<void, String> addArea;
  late final Command1<void, (UuidValue, String)> renameArea;
  late final Command1<void, (UuidValue, int)> moveArea;
  late final Command1<void, UuidValue> deleteArea;

  /// (meja yang diubah atau `null` = baru, isian).
  late final Command1<void, (UuidValue?, DiningTableDraft)> saveTable;
  late final Command1<void, TableRange> addRange;
  late final Command1<void, (UuidValue, int)> moveTable;
  late final Command1<void, UuidValue> deleteTable;

  DiningSetup? _setup;
  Exception? _error;
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

  bool get loaded => _setup != null;
  List<DiningArea> get areas => _setup?.areas ?? const [];
  List<DiningTable> get tables => _setup?.tables ?? const [];

  Exception? get loadError => switch (load.result) {
    Error(:final error) => error,
    _ => null,
  };

  /// Galat aksi terakhir (nama kembar, area masih dipakai, dsb.).
  Exception? get error => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  String? areaName(UuidValue? id) =>
      id == null ? null : areas.where((a) => a.id == id).firstOrNull?.name;

  bool get busy =>
      addArea.running ||
      renameArea.running ||
      moveArea.running ||
      deleteArea.running ||
      saveTable.running ||
      addRange.running ||
      moveTable.running ||
      deleteTable.running;

  /// Nama meja dari *Tambah beberapa*; `null` bila rentang tidak sah.
  static List<String>? rangePreview(String prefix, int from, int to) =>
      tableRange(prefix, from, to);

  Future<Result<DiningSetup>> _load() async {
    final result = await _repository.load();
    if (result case Ok(:final value)) _setup = value;
    return result;
  }

  /// Menjalankan [action] lalu memuat ulang daftar bila berhasil.
  Future<Result<void>> _act<T>(Future<Result<T>> Function() action) async {
    _error = null;
    final result = await action();
    switch (result) {
      case Ok():
        await _load();
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  Future<Result<void>> _addArea(String name) =>
      _act(() => _repository.createArea(name));

  Future<Result<void>> _renameArea((UuidValue, String) a) =>
      _act(() => _repository.renameArea(a.$1, a.$2));

  Future<Result<void>> _moveArea((UuidValue, int) a) =>
      _act(() => _repository.moveArea(a.$1, a.$2));

  Future<Result<void>> _deleteArea(UuidValue id) =>
      _act(() => _repository.deleteArea(id));

  Future<Result<void>> _saveTable((UuidValue?, DiningTableDraft) a) {
    final (id, draft) = a;
    return _act(
      () => id == null
          ? _repository.createTables([draft])
          : _repository.updateTable(id, draft),
    );
  }

  Future<Result<void>> _addRange(TableRange r) async {
    final names = rangePreview(r.prefix, r.from, r.to);
    if (names == null) {
      _error = DiningRangeInvalid();
      return Result.error(_error!);
    }
    return _act(
      () => _repository.createTables([
        for (final n in names)
          DiningTableDraft(name: n, areaId: r.areaId, seats: r.seats),
      ]),
    );
  }

  Future<Result<void>> _moveTable((UuidValue, int) a) =>
      _act(() => _repository.moveTable(a.$1, a.$2));

  Future<Result<void>> _deleteTable(UuidValue id) =>
      _act(() => _repository.deleteTable(id));
}
