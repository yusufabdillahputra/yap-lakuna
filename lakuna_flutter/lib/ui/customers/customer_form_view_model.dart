import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/customers_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Nilai pilihan *Grup baru* di daftar grup form.
const customerNewGroupKey = '__new__';

/// Nilai pilihan *Tanpa grup*.
const customerNoGroupKey = '__none__';

/// Form tambah/ubah pelanggan (1.20).
class CustomerFormViewModel extends ChangeNotifier {
  CustomerFormViewModel({
    required this._repository,
    Customer? customer,
    String initialName = '',
    String initialPhone = '',
  }) : _customer = customer,
       _name = customer?.name ?? initialName,
       _phone = customer?.phone ?? initialPhone,
       _address = customer?.address ?? '',
       _note = customer?.note ?? '',
       _groupKey = customer?.customerGroupId?.uuid ?? customerNoGroupKey,
       _limit = Money(customer?.creditLimit ?? 0) {
    load = Command0(_load)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
  }

  final CustomersRepository _repository;
  final Customer? _customer;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    save.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;
  late final Command0<Customer> save;

  List<CustomerGroupRow> _groups = const [];
  String _name;
  String _phone;
  String _address;
  String _note;
  String _groupKey;
  var _newGroup = '';
  Money _limit;
  var _submitted = false;

  bool get isEdit => _customer != null;
  List<CustomerGroupRow> get groups => _groups;
  String get name => _name;
  String get phone => _phone;
  String get address => _address;
  String get note => _note;
  String get groupKey => _groupKey;
  String get newGroup => _newGroup;
  Money get creditLimit => _limit;

  /// Galat isian; tampil setelah tombol simpan ditekan.
  Set<CustomerIssue> get issues => _submitted ? _validate() : const {};

  Set<CustomerIssue> _validate() => {
    ...validateCustomer(
      name: _name,
      phone: _phone,
      address: _address,
      note: _note,
      groupName: _groupKey == customerNewGroupKey ? _newGroup : null,
      creditLimit: _limit,
    ),
    if (_groupKey == customerNewGroupKey && _newGroup.trim().isEmpty)
      CustomerIssue.group,
  };

  Future<Result<void>> _load() async {
    switch (await _repository.groups()) {
      case Ok(:final value):
        _groups = value;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  void setName(String v) => _set(() => _name = v);
  void setPhone(String v) => _set(() => _phone = v);
  void setAddress(String v) => _set(() => _address = v);
  void setNote(String v) => _set(() => _note = v);
  void setGroup(String key) => _set(() => _groupKey = key);
  void setNewGroup(String v) => _set(() => _newGroup = v);
  void setCreditLimit(Money v) => _set(() => _limit = v);

  void _set(VoidCallback change) {
    change();
    if (save.error) save.clearResult();
    notifyListeners();
  }

  Future<Result<Customer>> _save() async {
    _submitted = true;
    final issues = _validate();
    if (issues.isNotEmpty) {
      notifyListeners();
      return Result.error(CustomerInvalid(issues));
    }
    final existing =
        _groupKey != customerNewGroupKey && _groupKey != customerNoGroupKey
        ? UuidValue.fromString(_groupKey)
        : null;
    return _repository.save(
      CustomerInput(
        id: _customer?.id,
        name: _name,
        phone: _phone,
        address: _address,
        note: _note,
        groupId: existing,
        newGroupName: _groupKey == customerNewGroupKey ? _newGroup : null,
        creditLimit: _limit,
      ),
    );
  }
}
