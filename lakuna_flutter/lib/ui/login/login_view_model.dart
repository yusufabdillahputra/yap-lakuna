import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/session_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Panjang PIN staf.
const pinLength = 6;

/// State layar 1.2 "Siapa yang bertugas?" (F1-02).
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required this._session,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    load = Command0(_load);
    submitPin = Command0(_submitPin);
    submitPassword = Command0(_submitPassword);
  }

  final SessionRepository _session;
  final DateTime Function() _clock;

  late final Command0<List<StaffProfile>> load;
  late final Command0<StaffProfile> submitPin;
  late final Command0<StaffProfile> submitPassword;

  List<StaffProfile> _staff = const [];
  StaffProfile? _selected;
  String _pin = '';
  bool _passwordMode = false;
  String _email = '';
  String _password = '';
  DateTime? _lockedUntil;
  Timer? _ticker;

  List<StaffProfile> get staff => _staff;
  StaffProfile? get selected => _selected;
  String get pin => _pin;
  bool get passwordMode => _passwordMode;
  String get email => _email;
  bool get canSubmitPassword =>
      _email.trim().isNotEmpty && _password.isNotEmpty && !locked;

  /// Sisa detik kunci, atau `null` bila tidak sedang dikunci.
  int? get lockSecondsLeft {
    final until = _lockedUntil;
    if (until == null) return null;
    final left = until.difference(_clock());
    if (left <= Duration.zero) return null;
    return (left.inMicroseconds + 999999) ~/ 1000000;
  }

  bool get locked => lockSecondsLeft != null;

  /// Pilihan tidak boleh berubah selama satu percobaan masih diperiksa, agar
  /// hasilnya tidak mendarat di staf atau formulir lain.
  bool get _busy => submitPin.running || submitPassword.running;

  /// Memilih staf untuk mengetik PIN. Staf tanpa PIN diabaikan. Bila PIN staf
  /// itu masih dikunci, hitung mundurnya langsung tampil.
  void select(StaffProfile staff) {
    if (!staff.hasPin || _busy) return;
    _selected = staff;
    _passwordMode = false;
    _resetAttempt();
    _rearm(_session.pinRetryAfter(staff.id));
    notifyListeners();
  }

  /// Kembali ke daftar staf (mobile).
  void clearSelection() {
    if (_busy) return;
    _selected = null;
    _resetAttempt();
    notifyListeners();
  }

  void addDigit(int digit) {
    if (_selected == null ||
        _passwordMode ||
        locked ||
        submitPin.running ||
        _pin.length >= pinLength) {
      return;
    }
    if (submitPin.result != null) submitPin.clearResult();
    _pin += '$digit';
    notifyListeners();
    if (_pin.length == pinLength) unawaited(submitPin.execute());
  }

  void backspace() {
    if (_pin.isEmpty || submitPin.running) return;
    _pin = _pin.substring(0, _pin.length - 1);
    notifyListeners();
  }

  /// Tombol *Batal*: mengosongkan PIN.
  void clearPin() {
    if (_pin.isEmpty || submitPin.running) return;
    _pin = '';
    notifyListeners();
  }

  void showPasswordForm() {
    if (_busy) return;
    _passwordMode = true;
    _resetAttempt();
    if (_email.trim().isNotEmpty) {
      _rearm(_session.passwordRetryAfter(_email));
    }
    notifyListeners();
  }

  void showPinForm() {
    if (_busy) return;
    _passwordMode = false;
    _resetAttempt();
    if (_selected case final staff?) {
      _rearm(_session.pinRetryAfter(staff.id));
    }
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    if (submitPassword.error) submitPassword.clearResult();
    // Kunci berlaku per email: tampilkan atau lepas sesuai email yang diketik.
    _resetLock();
    _rearm(_session.passwordRetryAfter(value));
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    if (submitPassword.error) submitPassword.clearResult();
    notifyListeners();
  }

  Future<Result<List<StaffProfile>>> _load() async {
    final result = await _session.listStaff();
    if (result case Ok(:final value)) {
      _staff = value;
      final selectedId = _selected?.id;
      _selected = value.where((s) => s.id == selectedId).firstOrNull;
      final withPin = value.where((s) => s.hasPin).toList();
      if (_selected == null && withPin.length == 1) {
        _selected = withPin.single;
        _rearm(_session.pinRetryAfter(withPin.single.id));
      }
      notifyListeners();
    }
    return result;
  }

  Future<Result<StaffProfile>> _submitPin() async {
    final staff = _selected;
    if (staff == null) return const Result.error(StaffUnavailable());
    final result = await _session.loginWithPin(staff.id, _pin);
    _pin = '';
    switch (result) {
      case Error(error: CredentialsLocked(:final retryAfter)):
        _lock(retryAfter);
      case Error(error: StaffUnavailable()):
        await _load();
      default:
    }
    notifyListeners();
    return result;
  }

  Future<Result<StaffProfile>> _submitPassword() async {
    final result = await _session.loginWithPassword(_email, _password);
    if (result case Error(error: CredentialsLocked(:final retryAfter))) {
      _lock(retryAfter);
    }
    return result;
  }

  void _lock(Duration retryAfter) {
    _lockedUntil = _clock().add(retryAfter);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!locked) {
        timer.cancel();
        _lockedUntil = null;
        if (submitPin.error) submitPin.clearResult();
        if (submitPassword.error) submitPassword.clearResult();
      }
      notifyListeners();
    });
  }

  void _rearm(Duration? retryAfter) {
    if (retryAfter != null) _lock(retryAfter);
  }

  void _resetLock() {
    _ticker?.cancel();
    _ticker = null;
    _lockedUntil = null;
  }

  void _resetAttempt() {
    _pin = '';
    _resetLock();
    if (submitPin.result != null) submitPin.clearResult();
    if (submitPassword.result != null) submitPassword.clearResult();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    load.dispose();
    submitPin.dispose();
    submitPassword.dispose();
    super.dispose();
  }
}
