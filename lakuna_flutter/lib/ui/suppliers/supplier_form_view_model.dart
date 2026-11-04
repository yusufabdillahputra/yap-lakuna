import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Form tambah/ubah supplier (1.21).
class SupplierFormViewModel extends ChangeNotifier {
  SupplierFormViewModel({required this._repository, Supplier? supplier})
    : _supplier = supplier,
      _name = supplier?.name ?? '',
      _phone = supplier?.phone ?? '',
      _contact = supplier?.contactName ?? '',
      _category = supplier?.category ?? '',
      _address = supplier?.address ?? '',
      _note = supplier?.note ?? '',
      _termDays = supplier?.termDays ?? SupplierLimits.defaultTermDays {
    save = Command0(_save)..addListener(notifyListeners);
  }

  final SuppliersRepository _repository;
  final Supplier? _supplier;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    save.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<Supplier> save;

  String _name;
  String _phone;
  String _contact;
  String _category;
  String _address;
  String _note;
  int _termDays;
  var _submitted = false;

  bool get isEdit => _supplier != null;
  String get name => _name;
  String get phone => _phone;
  String get contactName => _contact;
  String get category => _category;
  String get address => _address;
  String get note => _note;
  int get termDays => _termDays;

  /// Galat isian; tampil setelah tombol simpan ditekan.
  Set<SupplierIssue> get issues => _submitted ? _validate() : const {};

  Set<SupplierIssue> _validate() => validateSupplier(
    name: _name,
    termDays: _termDays,
    phone: _phone,
    contactName: _contact,
    category: _category,
    address: _address,
    note: _note,
  );

  void setName(String v) => _set(() => _name = v);
  void setPhone(String v) => _set(() => _phone = v);
  void setContactName(String v) => _set(() => _contact = v);
  void setCategory(String v) => _set(() => _category = v);
  void setAddress(String v) => _set(() => _address = v);
  void setNote(String v) => _set(() => _note = v);

  /// Teks kosong atau bukan angka = tidak sah (-1).
  void setTermDays(String v) => _set(() => _termDays = int.tryParse(v) ?? -1);

  void _set(VoidCallback change) {
    change();
    if (save.error) save.clearResult();
    notifyListeners();
  }

  Future<Result<Supplier>> _save() async {
    _submitted = true;
    final issues = _validate();
    if (issues.isNotEmpty) {
      notifyListeners();
      return Result.error(SupplierInvalid(issues));
    }
    return _repository.save(
      SupplierInput(
        id: _supplier?.id,
        name: _name,
        phone: _phone,
        contactName: _contact,
        category: _category,
        address: _address,
        note: _note,
        termDays: _termDays,
      ),
    );
  }
}
