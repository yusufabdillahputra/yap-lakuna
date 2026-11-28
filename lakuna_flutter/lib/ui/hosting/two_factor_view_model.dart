import 'package:flutter/foundation.dart';

import '../../data/repositories/hosting_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Yang dilakukan dialog verifikasi 2 langkah.
enum TwoFactorMode {
  /// *Aktifkan*: rahasia baru.
  enable,

  /// *Nonaktifkan*: butuh kode authenticator atau kode cadangan.
  disable,

  /// *Atur ulang*: nonaktifkan lalu rahasia baru (authenticator baru).
  reset,
}

enum TwoFactorStep {
  /// PIN pemilik di perangkat ini.
  pin,

  /// Email + kata sandi akun pemilik di server.
  account,

  /// QR + rahasia teks + kode 6 digit.
  enroll,

  /// 8 kode cadangan, tampil sekali.
  backupCodes,

  /// Kode untuk menonaktifkan (dan langkah pertama atur ulang).
  disable,
  done,
}

final _sixDigits = RegExp(r'^\d{6}$');
final _backupCode = RegExp(r'^[A-Z0-9]{8}$');

/// Kode yang diketik: spasi dan tanda hubung dibuang, huruf besar.
String _clean(String code) =>
    code.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

/// Kode cadangan dikirim berpola `XXXX-XXXX`, kode TOTP 6 angka.
String _normalized(String code) {
  final c = _clean(code);
  return _backupCode.hasMatch(c) && !_sixDigits.hasMatch(c)
      ? '${c.substring(0, 4)}-${c.substring(4)}'
      : c;
}

/// Mengatur verifikasi 2 langkah login web dari kartu *Versi hosting*
/// (F2-02 aturan 12–14): PIN pemilik → akun pemilik → QR + kode → kode
/// cadangan. Sesi akun hanya di memori dan ditutup saat dialog selesai.
class TwoFactorViewModel extends ChangeNotifier {
  TwoFactorViewModel({
    required this._hosting,
    required this._session,
    required this.mode,
  }) {
    submitPin = Command0(_submitPin)..addListener(notifyListeners);
    submitAccount = Command0(_submitAccount)..addListener(notifyListeners);
    submitCode = Command0(_submitCode)..addListener(notifyListeners);
    submitDisable = Command0(_submitDisable)..addListener(notifyListeners);
  }

  final HostingRepository _hosting;
  final SessionRepository _session;
  final TwoFactorMode mode;

  late final Command0<void> submitPin;
  late final Command0<void> submitAccount;
  late final Command0<void> submitCode;
  late final Command0<void> submitDisable;

  TwoFactorStep _step = TwoFactorStep.pin;
  TwoFactorStep get step => _step;

  String _pin = '';
  String _email = '';
  String _password = '';
  String _code = '';

  TotpEnrollment? _enrollment;
  TotpEnrollment? get enrollment => _enrollment;

  List<String> _backupCodes = const [];
  List<String> get backupCodes => _backupCodes;

  /// Server sudah mencatat TOTP aktif saat mode *Aktifkan* (kartu lama).
  var _alreadyEnabled = false;
  bool get alreadyEnabled => _alreadyEnabled;

  /// TOTP sudah dinonaktifkan di server pada dialog ini (langkah pertama
  /// *Atur ulang* tidak diulang bila QR baru gagal dimuat).
  var _disabled = false;

  /// Status di server berubah lewat dialog ini: kartu harus dimuat ulang
  /// walau dialog ditutup sebelum selesai (review I4).
  bool get serverChanged => _disabled || _backupCodes.isNotEmpty;

  /// Naik setiap langkah berganti agar isian kode dibuat baru (kosong).
  int _revision = 0;
  int get revision => _revision;

  var _disposed = false;

  /// Rahasia dalam kelompok 4 huruf untuk diketik manual.
  String get secretGroups {
    final s = _enrollment?.secretBase32 ?? '';
    return [
      for (var i = 0; i < s.length; i += 4)
        s.substring(i, i + 4 > s.length ? s.length : i + 4),
    ].join(' ');
  }

  bool get canSubmitPin => _sixDigits.hasMatch(_pin) && !submitPin.running;
  bool get canSubmitAccount =>
      _email.trim().contains('@') &&
      _password.isNotEmpty &&
      !submitAccount.running;
  bool get canSubmitCode =>
      _sixDigits.hasMatch(_clean(_code)) && !submitCode.running;
  bool get canSubmitDisable {
    final c = _clean(_code);
    return (_sixDigits.hasMatch(c) || _backupCode.hasMatch(c)) &&
        !submitDisable.running;
  }

  void setPin(String v) => _set(() => _pin = v);
  void setEmail(String v) => _set(() => _email = v);
  void setPassword(String v) => _set(() => _password = v);
  void setCode(String v) => _set(() => _code = v);

  void _set(void Function() change) {
    change();
    notifyListeners();
  }

  void _go(TwoFactorStep step) {
    _step = step;
    _code = '';
    _revision++;
    if (step == TwoFactorStep.done) _hosting.endTwoFactor();
  }

  Future<Result<void>> _submitPin() async {
    final result = await _session.verifyCurrentPin(_pin);
    if (result is Ok) _go(TwoFactorStep.account);
    return result;
  }

  Future<Result<void>> _submitAccount() async {
    final signIn = await _hosting.twoFactorSignIn(
      email: _email.trim(),
      password: _password,
    );
    switch (signIn) {
      case Error(:final error):
        return Result.error(error);
      case Ok(value: final enabled):
        _password = '';
        if (mode == TwoFactorMode.enable) {
          if (enabled) {
            _alreadyEnabled = true;
            _go(TwoFactorStep.done);
            return const Result.ok(null);
          }
          return _begin();
        }
        _go(TwoFactorStep.disable);
        return const Result.ok(null);
    }
  }

  Future<Result<void>> _begin() async {
    switch (await _hosting.beginTwoFactor()) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        _enrollment = value;
        _go(TwoFactorStep.enroll);
        return const Result.ok(null);
    }
  }

  Future<Result<void>> _submitCode() async {
    switch (await _hosting.confirmTwoFactor(_clean(_code))) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        _backupCodes = value;
        _go(TwoFactorStep.backupCodes);
        return const Result.ok(null);
    }
  }

  Future<Result<void>> _submitDisable() async {
    if (!_disabled) {
      final result = await _hosting.disableTwoFactor(_normalized(_code));
      if (result is Error) return result;
      _disabled = true;
    }
    if (mode == TwoFactorMode.reset) return _begin();
    _go(TwoFactorStep.done);
    return const Result.ok(null);
  }

  /// *Sudah saya simpan* di langkah kode cadangan.
  void finish() {
    _go(TwoFactorStep.done);
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _hosting.endTwoFactor();
    super.dispose();
  }
}

/// Baris *Verifikasi 2 langkah* di kartu *Versi hosting*: status dari
/// server dengan token perangkat.
class TwoFactorStatusViewModel extends ChangeNotifier {
  TwoFactorStatusViewModel({required this._hosting}) {
    load = Command0(_load)..addListener(notifyListeners);
  }

  final HostingRepository _hosting;
  late final Command0<bool> load;

  bool? _enabled;

  /// `null` bila belum dimuat atau server tidak terjangkau.
  bool? get enabled => _enabled;

  bool get offline => load.error;

  Future<Result<bool>> _load() async {
    final result = await _hosting.twoFactorEnabled();
    _enabled = switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };
    return result;
  }
}
