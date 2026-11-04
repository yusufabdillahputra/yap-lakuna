import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

import '../../data/repositories/customers_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Isian dialog grup pelanggan.
typedef CustomerGroupDraft = ({UuidValue? id, String name, int termDays});

/// Tab Master data › Grup pelanggan (F1-13): nama grup dan tempo standar.
class CustomerGroupsViewModel extends ChangeNotifier {
  CustomerGroupsViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command1(_save)..addListener(notifyListeners);
    delete = Command1(_delete)..addListener(notifyListeners);
  }

  final CustomersRepository _repository;

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
  late final Command1<CustomerGroup, CustomerGroupDraft> save;
  late final Command1<void, UuidValue> delete;

  List<CustomerGroupRow> _groups = const [];
  UuidValue? _deleteFailedId;

  List<CustomerGroupRow> get groups => _groups;

  /// Grup yang gagal dihapus terakhir (pesan di barisnya).
  UuidValue? get deleteFailedId => _deleteFailedId;

  Future<Result<void>> _load() async {
    switch (await _repository.groups()) {
      case Ok(:final value):
        _groups = value;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<CustomerGroup>> _save(CustomerGroupDraft d) async {
    final result = await _repository.saveGroup(
      id: d.id,
      name: d.name,
      termDays: d.termDays,
    );
    if (result is Ok) await _load();
    return result;
  }

  Future<Result<void>> _delete(UuidValue id) async {
    _deleteFailedId = null;
    final result = await _repository.deleteGroup(id);
    if (result is Ok) {
      await _load();
    } else {
      _deleteFailedId = id;
    }
    return result;
  }
}
