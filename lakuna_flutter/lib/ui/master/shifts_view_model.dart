import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../data/repositories/shifts_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Isian dialog shift; jam dalam menit sejak tengah malam.
typedef ShiftDraft = ({
  UuidValue? id,
  String name,
  int startMinute,
  int endMinute,
});

/// Tab Master data › Shift (F1-03g): nama dan jam shift cabang.
class ShiftsViewModel extends ChangeNotifier {
  ShiftsViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command1(_save)..addListener(notifyListeners);
    delete = Command1(_delete)..addListener(notifyListeners);
  }

  final ShiftsRepository _repository;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    save.dispose();
    delete.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;
  late final Command1<Shift, ShiftDraft> save;
  late final Command1<void, UuidValue> delete;

  List<ShiftRow> _rows = const [];
  UuidValue? _deleteFailedId;

  List<ShiftRow> get rows => _rows;

  /// Shift yang gagal dihapus terakhir (pesan di barisnya).
  UuidValue? get deleteFailedId => _deleteFailedId;

  Future<Result<void>> _load() async {
    switch (await _repository.list()) {
      case Ok(:final value):
        _rows = value;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<Shift>> _save(ShiftDraft d) async {
    final result = await _repository.save(
      id: d.id,
      name: d.name,
      startMinute: d.startMinute,
      endMinute: d.endMinute,
    );
    if (result is Ok) await _load();
    return result;
  }

  Future<Result<void>> _delete(UuidValue id) async {
    _deleteFailedId = null;
    final result = await _repository.delete(id);
    if (result is Ok) {
      await _load();
    } else {
      _deleteFailedId = id;
    }
    return result;
  }
}
