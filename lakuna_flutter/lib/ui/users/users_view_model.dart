import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/session_repository.dart';
import '../../data/repositories/users_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Tab layar Pengguna & role (1.25).
enum UsersTab { users, roles }

/// Layar Pengguna & role (1.25): daftar pengguna, kunci PIN, matriks izin,
/// dan role custom.
class UsersViewModel extends ChangeNotifier {
  UsersViewModel({required this._repository, this._actor}) {
    load = Command0(_load)..addListener(notifyListeners);
    unlock = Command1(_unlock)..addListener(notifyListeners);
    saveMatrix = Command0(_saveMatrix)..addListener(notifyListeners);
    createRole = Command1(_createRole)..addListener(notifyListeners);
    renameRole = Command1(_renameRole)..addListener(notifyListeners);
    deleteRole = Command1(_deleteRole)..addListener(notifyListeners);
  }

  final UsersRepository _repository;

  /// Staf yang bertugas; menentukan kolom dan izin yang bisa diubah.
  final StaffProfile? _actor;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    unlock.dispose();
    saveMatrix.dispose();
    createRole.dispose();
    renameRole.dispose();
    deleteRole.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;
  late final Command1<void, UuidValue> unlock;
  late final Command0<void> saveMatrix;

  /// Argumen = nama role; hasil = kunci role baru.
  late final Command1<String, String> createRole;

  /// Argumen = (kunci, nama baru).
  late final Command1<void, (String, String)> renameRole;
  late final Command1<void, String> deleteRole;

  List<StaffAccount> _accounts = const [];
  List<RoleSummary> _roles = const [];
  final _draft = <String, Set<Permission>>{};
  var _tab = UsersTab.users;
  String? _deleteFailedKey;

  List<StaffAccount> get accounts => _accounts;
  List<RoleSummary> get roles => _roles;
  UsersTab get tab => _tab;

  /// Role custom yang gagal dihapus terakhir (masih dipakai).
  String? get deleteFailedKey => _deleteFailedKey;

  /// Jumlah pengguna aktif.
  int get activeCount => _accounts.where((a) => a.isActive).length;

  void setTab(UsersTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  /// Sisa kunci PIN [account], `null` bila tidak dikunci.
  Duration? lockedFor(StaffAccount account) =>
      _repository.pinLockedFor(account.id);

  RoleSummary? role(String key) =>
      _roles.where((r) => r.key == key).firstOrNull;

  // --- Matriks ---------------------------------------------------------------

  /// Izin role [key] termasuk perubahan yang belum disimpan.
  Set<Permission> permissionsOf(String key) =>
      _draft[key] ?? role(key)?.permissions ?? const {};

  bool get _actorIsOwner => _actor?.isOwner ?? false;

  /// Kolom role yang bisa diubah aktor: bukan pemilik, bukan role aktor
  /// sendiri (kecuali pemilik), dan izinnya tidak melebihi milik aktor.
  bool canEdit(RoleSummary r) {
    if (r.isOwner) return false;
    final actor = _actor;
    if (actor == null) return false;
    if (actor.isOwner) return true;
    return r.key != actor.roleKey &&
        actor.permissions.containsAll(r.permissions);
  }

  /// Sel matriks yang bisa dicentang aktor.
  bool canToggle(RoleSummary r, Permission p) =>
      canEdit(r) && (_actorIsOwner || (_actor?.can(p) ?? false));

  void toggle(String key, Permission p) {
    final r = role(key);
    if (r == null || !canToggle(r, p)) return;
    final next = {...permissionsOf(key)};
    if (!next.remove(p)) next.add(p);
    if (setEquals(next, r.permissions)) {
      _draft.remove(key);
    } else {
      _draft[key] = next;
    }
    notifyListeners();
  }

  /// Ada perubahan matriks yang belum disimpan.
  bool get dirty => _draft.isNotEmpty;

  void discard() {
    _draft.clear();
    saveMatrix.clearResult();
    notifyListeners();
  }

  // --- Aksi -----------------------------------------------------------------

  Future<Result<void>> _load() async {
    final accounts = await _repository.accounts();
    final roles = await _repository.roles();
    switch ((accounts, roles)) {
      case (Ok(value: final a), Ok(value: final r)):
        _accounts = a;
        _roles = r;
        _draft.removeWhere((key, _) => role(key) == null);
        return const Result.ok(null);
      case (Error(:final error), _) || (_, Error(:final error)):
        return Result.error(error);
    }
  }

  Future<Result<void>> _unlock(UuidValue id) async {
    final result = await _repository.unlockPin(id);
    notifyListeners();
    return result;
  }

  Future<Result<void>> _saveMatrix() async {
    if (_draft.isEmpty) return const Result.ok(null);
    final result = await _repository.saveMatrix(Map.of(_draft));
    if (result is Ok) {
      _draft.clear();
      await _load();
    }
    return result;
  }

  Future<Result<String>> _createRole(String name) async {
    final result = await _repository.createRole(name);
    if (result is Ok) await _load();
    return result;
  }

  Future<Result<void>> _renameRole((String, String) args) async {
    final result = await _repository.renameRole(args.$1, args.$2);
    if (result is Ok) await _load();
    return result;
  }

  Future<Result<void>> _deleteRole(String key) async {
    _deleteFailedKey = null;
    final result = await _repository.deleteRole(key);
    if (result is Ok) {
      _draft.remove(key);
      await _load();
    } else {
      _deleteFailedKey = key;
    }
    return result;
  }
}

/// Kolom isian dialog pengguna.
enum StaffFormField { name, pin, pinRetype, resetPin, resetRetype }

/// Dialog *Tambah pengguna* / ubah pengguna + *Reset PIN* (1.25b).
class StaffFormViewModel extends ChangeNotifier {
  StaffFormViewModel({
    required this._repository,
    required List<RoleSummary> roles,
    this.account,
  }) : roles = [
         for (final r in roles)
           if (!r.isOwner) r,
       ],
       _name = account?.name ?? '',
       _roleKey = account?.roleKey ?? DefaultRole.cashier.key,
       _active = account?.isActive ?? true {
    save = Command0(_save)..addListener(notifyListeners);
    resetPin = Command0(_resetPin)..addListener(notifyListeners);
  }

  final UsersRepository _repository;

  /// Pengguna yang diubah, `null` untuk tambah.
  final StaffAccount? account;

  /// Role yang bisa dipilih (tanpa pemilik).
  final List<RoleSummary> roles;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    save.dispose();
    resetPin.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> save;
  late final Command0<void> resetPin;

  String _name;
  String _roleKey;
  bool _active;
  var _pin = '';
  var _pinRetype = '';
  var _reset = '';
  var _resetRetype = '';
  var _submitted = false;
  var _resetSubmitted = false;
  var _resetGeneration = 0;

  bool get isNew => account == null;
  String get name => _name;
  String get roleKey => _roleKey;
  bool get active => _active;

  /// Naik setelah reset PIN berhasil agar kolom PIN dikosongkan.
  int get resetGeneration => _resetGeneration;

  void setName(String v) {
    _name = v;
    notifyListeners();
  }

  void setRole(String key) {
    _roleKey = key;
    notifyListeners();
  }

  void setActive(bool v) {
    _active = v;
    notifyListeners();
  }

  void setPin(String v) {
    _pin = v;
    notifyListeners();
  }

  void setPinRetype(String v) {
    _pinRetype = v;
    notifyListeners();
  }

  void setResetPin(String v) {
    _reset = v;
    notifyListeners();
  }

  void setResetRetype(String v) {
    _resetRetype = v;
    notifyListeners();
  }

  Map<StaffFormField, StaffIssue> get _issues => {
    StaffFormField.name: ?staffNameIssue(_name),
    if (isNew)
      for (final MapEntry(:key, :value) in validatePinPair(
        _pin,
        _pinRetype,
      ).entries)
        key == CredentialField.secret
                ? StaffFormField.pin
                : StaffFormField.pinRetype:
            value,
  };

  Map<StaffFormField, StaffIssue> get _resetIssues => {
    for (final MapEntry(:key, :value) in validatePinPair(
      _reset,
      _resetRetype,
    ).entries)
      key == CredentialField.secret
              ? StaffFormField.resetPin
              : StaffFormField.resetRetype:
          value,
  };

  /// Galat isian; kosong sampai pengguna mencoba menyimpan.
  Map<StaffFormField, StaffIssue> get issues => {
    if (_submitted) ..._issues,
    if (_resetSubmitted) ..._resetIssues,
  };

  /// Nama sudah dipakai staf lain (dari repositori).
  bool get nameTaken => switch (save.result) {
    Error(error: StaffNameTaken()) => true,
    _ => false,
  };

  Future<Result<void>> _save() async {
    _submitted = true;
    if (_issues.isNotEmpty) {
      notifyListeners();
      return const Result.error(StaffFormInvalid());
    }
    final a = account;
    if (a == null) {
      return _repository.createStaff(
        name: _name,
        roleKey: _roleKey,
        pin: _pin,
        active: _active,
      );
    }
    return _repository.updateStaff(
      id: a.id,
      name: _name,
      roleKey: _roleKey,
      active: _active,
    );
  }

  Future<Result<void>> _resetPin() async {
    final a = account;
    if (a == null) return const Result.ok(null);
    _resetSubmitted = true;
    if (_resetIssues.isNotEmpty) {
      notifyListeners();
      return const Result.error(StaffFormInvalid());
    }
    final result = await _repository.resetPin(a.id, _reset);
    if (result is Ok) {
      _reset = '';
      _resetRetype = '';
      _resetSubmitted = false;
      _resetGeneration++;
    }
    return result;
  }
}

/// Isian dialog tidak lolos validasi (galat per kolom di [StaffFormViewModel.issues]).
class StaffFormInvalid implements Exception {
  const StaffFormInvalid();

  @override
  String toString() => 'StaffFormInvalid';
}

/// Kolom *Akun saya*.
enum MyAccountField {
  pinCurrent,
  pin,
  pinRetype,
  passwordCurrent,
  password,
  passwordRetype,
}

/// *Akun saya* (1.25b): ganti PIN dan kata sandi sendiri.
class MyAccountViewModel extends ChangeNotifier {
  MyAccountViewModel({required this._repository}) {
    load = Command0(_load)..addListener(notifyListeners);
    changePin = Command0(_changePin)..addListener(notifyListeners);
    changePassword = Command0(_changePassword)..addListener(notifyListeners);
  }

  final UsersRepository _repository;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    load.dispose();
    changePin.dispose();
    changePassword.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  late final Command0<void> load;
  late final Command0<void> changePin;
  late final Command0<void> changePassword;

  MyAccount? _account;
  final _values = <MyAccountField, String>{};
  var _pinSubmitted = false;
  var _passwordSubmitted = false;
  var _pinGeneration = 0;
  var _passwordGeneration = 0;

  MyAccount? get account => _account;

  /// Naik setelah berhasil agar kolom dikosongkan.
  int get pinGeneration => _pinGeneration;
  int get passwordGeneration => _passwordGeneration;

  String value(MyAccountField f) => _values[f] ?? '';

  void set(MyAccountField f, String v) {
    _values[f] = v;
    notifyListeners();
  }

  Map<MyAccountField, StaffIssue> _pair(
    MyAccountField current,
    MyAccountField secret,
    MyAccountField retype,
    Map<CredentialField, StaffIssue> Function(String, String) validate,
  ) => {
    if (value(current).isEmpty) current: StaffIssue.required,
    for (final MapEntry(:key, :value) in validate(
      this.value(secret),
      this.value(retype),
    ).entries)
      key == CredentialField.secret ? secret : retype: value,
  };

  Map<MyAccountField, StaffIssue> get _pinIssues => _pair(
    MyAccountField.pinCurrent,
    MyAccountField.pin,
    MyAccountField.pinRetype,
    validatePinPair,
  );

  Map<MyAccountField, StaffIssue> get _passwordIssues => _pair(
    MyAccountField.passwordCurrent,
    MyAccountField.password,
    MyAccountField.passwordRetype,
    validatePasswordPair,
  );

  /// Galat isian; kosong sampai pengguna mencoba menyimpan bagiannya.
  Map<MyAccountField, StaffIssue> get issues => {
    if (_pinSubmitted) ..._pinIssues,
    if (_passwordSubmitted) ..._passwordIssues,
  };

  Future<Result<void>> _load() async {
    final result = await _repository.myAccount();
    if (result case Ok(:final value)) _account = value;
    return result;
  }

  void _clear(List<MyAccountField> fields) {
    for (final f in fields) {
      _values.remove(f);
    }
  }

  Future<Result<void>> _changePin() async {
    _pinSubmitted = true;
    if (_pinIssues.isNotEmpty) {
      notifyListeners();
      return const Result.error(StaffFormInvalid());
    }
    final result = await _repository.changeMyPin(
      current: value(MyAccountField.pinCurrent),
      pin: value(MyAccountField.pin),
    );
    if (result is Ok) {
      _clear(const [
        MyAccountField.pinCurrent,
        MyAccountField.pin,
        MyAccountField.pinRetype,
      ]);
      _pinSubmitted = false;
      _pinGeneration++;
    }
    return result;
  }

  Future<Result<void>> _changePassword() async {
    _passwordSubmitted = true;
    if (_passwordIssues.isNotEmpty) {
      notifyListeners();
      return const Result.error(StaffFormInvalid());
    }
    final result = await _repository.changeMyPassword(
      current: value(MyAccountField.passwordCurrent),
      password: value(MyAccountField.password),
    );
    if (result is Ok) {
      _clear(const [
        MyAccountField.passwordCurrent,
        MyAccountField.password,
        MyAccountField.passwordRetype,
      ]);
      _passwordSubmitted = false;
      _passwordGeneration++;
    }
    return result;
  }
}
