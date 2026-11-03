import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/master_data_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// View model tab Master data › Grup modifier (F1-10b, 1.17b).
class ModifierGroupsViewModel extends ChangeNotifier {
  ModifierGroupsViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command1(_save)..addListener(notifyListeners);
    move = Command1(_move)..addListener(notifyListeners);
    delete = Command1(_delete)..addListener(notifyListeners);
  }

  final MasterDataRepository _repository;

  late final Command0<List<ModifierGroupDetail>> load;

  /// (grup yang diubah atau `null` = baru, isian). Galatnya tidak masuk
  /// [error]; form menampilkannya sendiri dari hasil perintah.
  late final Command1<void, (UuidValue?, ModifierGroupDraft)> save;
  late final Command1<void, (UuidValue, int)> move;
  late final Command1<void, UuidValue> delete;

  List<ModifierGroupDetail>? _groups;
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

  bool get loaded => _groups != null;
  List<ModifierGroupDetail> get groups => _groups ?? const [];

  /// Galat urut/hapus terakhir (mis. grup masih dipasang di menu).
  Exception? get error => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  bool get busy => save.running || move.running || delete.running;

  Future<Result<List<ModifierGroupDetail>>> _load() async {
    final result = await _repository.modifierGroups();
    if (result case Ok(:final value)) _groups = value;
    return result;
  }

  Future<Result<void>> _save((UuidValue?, ModifierGroupDraft) a) async {
    _error = null;
    final result = await _repository.saveModifierGroup(a.$1, a.$2);
    switch (result) {
      case Ok():
        await _load();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _act(Future<Result<void>> Function() action) async {
    _error = null;
    final result = await action();
    switch (result) {
      case Ok():
        await _load();
      case Error(:final error):
        _error = error;
    }
    return result;
  }

  Future<Result<void>> _move((UuidValue, int) a) =>
      _act(() => _repository.moveModifierGroup(a.$1, a.$2));

  Future<Result<void>> _delete(UuidValue id) =>
      _act(() => _repository.deleteModifierGroup(id));
}
