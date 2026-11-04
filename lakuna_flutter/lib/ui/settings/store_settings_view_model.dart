import 'package:flutter/foundation.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/store_settings_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Isian ditolak sebelum dikirim ke repositori.
class StoreSettingsFormInvalid implements Exception {
  const StoreSettingsFormInvalid();
}

/// View model bagian *Profil toko*, *Cabang ini*, dan *Penjualan & stok*
/// (1.26, F1-18).
class StoreSettingsViewModel extends ChangeNotifier {
  StoreSettingsViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    saveBusiness = Command0(_saveBusiness)..addListener(notifyListeners);
    saveOutlet = Command0(_saveOutlet)..addListener(notifyListeners);
    saveRules = Command0(_saveRules)..addListener(notifyListeners);
  }

  final StoreSettingsRepository _repository;

  late final Command0<void> load;
  late final Command0<StoreProfile> saveBusiness;
  late final Command0<StoreProfile> saveOutlet;
  late final Command0<SalesRules> saveRules;

  StoreProfile? _profile;
  SalesRules _storedRules = const SalesRules();
  SalesRules _rules = const SalesRules();
  var _businessName = '';
  var _outletName = '';
  var _address = '';
  var _phone = '';
  var _businessSubmitted = false;
  var _outletSubmitted = false;
  var _rev = 0;
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

  StoreProfile? get profile => _profile;

  /// Naik setiap kali isian diisi ulang dari data (kunci field).
  int get revision => _rev;

  String get businessName => _businessName;
  String get outletName => _outletName;
  String get address => _address;
  String get phone => _phone;
  SalesRules get rules => _rules;

  ProfileIssue? get businessIssue =>
      _businessSubmitted ? storeNameIssue(_businessName) : null;

  Map<OutletProfileField, ProfileIssue> get outletIssues => _outletSubmitted
      ? outletProfileIssues(name: _outletName, address: _address, phone: _phone)
      : const {};

  bool get businessDirty =>
      _profile != null && _businessName.trim() != _profile!.businessName;

  bool get outletDirty =>
      _profile != null &&
      (_outletName.trim() != _profile!.outletName ||
          _address.trim() != _profile!.address ||
          _phone.trim() != _profile!.phone);

  bool get rulesDirty => _rules != _storedRules;

  void setBusinessName(String v) {
    _businessName = v;
    saveBusiness.clearResult();
    notifyListeners();
  }

  void setOutletName(String v) {
    _outletName = v;
    saveOutlet.clearResult();
    notifyListeners();
  }

  void setAddress(String v) {
    _address = v;
    saveOutlet.clearResult();
    notifyListeners();
  }

  void setPhone(String v) {
    _phone = v;
    saveOutlet.clearResult();
    notifyListeners();
  }

  void setAllowNegativeStock(bool v) {
    _rules = _rules.copyWith(allowNegativeStock: v);
    saveRules.clearResult();
    notifyListeners();
  }

  void setDiscountNeedsPin(bool v) {
    _rules = _rules.copyWith(discountNeedsPin: v);
    saveRules.clearResult();
    notifyListeners();
  }

  void setRounding(TotalRounding r) {
    _rules = _rules.copyWith(rounding: r);
    saveRules.clearResult();
    notifyListeners();
  }

  /// Mengisi ulang isian dari [p]. Menyimpan satu bagian tidak menimpa
  /// isian bagian lain yang belum disimpan.
  void _applyProfile(
    StoreProfile p, {
    bool business = true,
    bool outlet = true,
  }) {
    _profile = p;
    if (business) _businessName = p.businessName;
    if (outlet) {
      _outletName = p.outletName;
      _address = p.address;
      _phone = p.phone;
    }
    _rev++;
  }

  Future<Result<void>> _load() async {
    final profile = await _repository.profile();
    final rules = await _repository.salesRules();
    if (profile case Ok(:final value)) _applyProfile(value);
    if (rules case Ok(:final value)) {
      _storedRules = value;
      _rules = value;
    }
    return switch ((profile, rules)) {
      (Error(:final error), _) || (_, Error(:final error)) => Result.error(
        error,
      ),
      _ => const Result.ok(null),
    };
  }

  Future<Result<StoreProfile>> _saveBusiness() async {
    _businessSubmitted = true;
    if (storeNameIssue(_businessName) != null) {
      notifyListeners();
      return const Result.error(StoreSettingsFormInvalid());
    }
    final result = await _repository.saveBusinessName(_businessName);
    if (result case Ok(:final value)) {
      _businessSubmitted = false;
      _applyProfile(value, outlet: false);
    }
    return result;
  }

  Future<Result<StoreProfile>> _saveOutlet() async {
    _outletSubmitted = true;
    if (outletProfileIssues(
      name: _outletName,
      address: _address,
      phone: _phone,
    ).isNotEmpty) {
      notifyListeners();
      return const Result.error(StoreSettingsFormInvalid());
    }
    final result = await _repository.saveOutlet(
      name: _outletName,
      address: _address,
      phone: _phone,
    );
    if (result case Ok(:final value)) {
      _outletSubmitted = false;
      _applyProfile(value, business: false);
    }
    return result;
  }

  Future<Result<SalesRules>> _saveRules() async {
    final result = await _repository.saveSalesRules(_rules);
    if (result case Ok(:final value)) {
      _storedRules = value;
      _rules = value;
    }
    return result;
  }
}
