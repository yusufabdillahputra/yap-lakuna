import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../data/repositories/expenses_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Isian dialog jenis pengeluaran.
typedef ExpenseCategoryDraft = ({UuidValue? id, String name});

/// Tab Master data › Jenis pengeluaran (F1-15).
class ExpenseCategoriesViewModel extends ChangeNotifier {
  ExpenseCategoriesViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command1(_save)..addListener(notifyListeners);
    delete = Command1(_delete)..addListener(notifyListeners);
  }

  final ExpensesRepository _repository;

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
  late final Command1<ExpenseCategory, ExpenseCategoryDraft> save;
  late final Command1<void, UuidValue> delete;

  List<ExpenseCategoryRow> _rows = const [];
  UuidValue? _deleteFailedId;

  List<ExpenseCategoryRow> get rows => _rows;

  /// Jenis yang gagal dihapus terakhir (pesan di barisnya).
  UuidValue? get deleteFailedId => _deleteFailedId;

  Future<Result<void>> _load() async {
    switch (await _repository.categories()) {
      case Ok(:final value):
        _rows = value;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<ExpenseCategory>> _save(ExpenseCategoryDraft d) async {
    final result = await _repository.saveCategory(id: d.id, name: d.name);
    if (result is Ok) await _load();
    return result;
  }

  Future<Result<void>> _delete(UuidValue id) async {
    _deleteFailedId = null;
    final result = await _repository.deleteCategory(id);
    if (result is Ok) {
      await _load();
    } else {
      _deleteFailedId = id;
    }
    return result;
  }
}
