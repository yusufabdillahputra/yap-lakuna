import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_domain/lakuna_domain.dart' show passwordMinLength;

import '../../data/repositories/web_join_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

enum WebResetStep { email, code, done }

enum WebResetPasswordError { tooShort, mismatch }

/// *Lupa kata sandi?* di layar login web (F2-02 tugas 11): kode dikirim ke
/// email akun, lalu kata sandi baru diketik dua kali.
class WebPasswordResetViewModel extends ChangeNotifier {
  WebPasswordResetViewModel({
    required this._repository,
    required this._serverUrl,
    this._email = '',
  }) {
    send = Command0(_send)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
  }

  final WebLoginRepository _repository;
  final String _serverUrl;

  late final Command0<void> send;
  late final Command0<void> save;

  var _step = WebResetStep.email;
  WebResetStep get step => _step;

  String _email;
  String _code = '';
  String _password = '';
  String _passwordAgain = '';
  UuidValue? _requestId;

  /// Token dari kode yang sudah diverifikasi; dipakai ulang bila kata
  /// sandi baru ditolak server, agar kode tidak diminta lagi.
  String? _token;

  String get email => _email.trim();

  var _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get busy => send.running || save.running;

  void setEmail(String value) {
    _email = value;
    send.clearResult();
    notifyListeners();
  }

  void setCode(String value) {
    if (value.trim() != _code.trim()) _token = null;
    _code = value;
    save.clearResult();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    save.clearResult();
    notifyListeners();
  }

  void setPasswordAgain(String value) {
    _passwordAgain = value;
    save.clearResult();
    notifyListeners();
  }

  /// Galat kata sandi baru; `null` bila sah atau belum diisi.
  WebResetPasswordError? get passwordError {
    if (_password.isEmpty) return null;
    if (_password.length < passwordMinLength) {
      return WebResetPasswordError.tooShort;
    }
    if (_passwordAgain.isNotEmpty && _passwordAgain != _password) {
      return WebResetPasswordError.mismatch;
    }
    return null;
  }

  bool get canSend => email.contains('@') && !busy;

  bool get canSave =>
      _code.trim().isNotEmpty &&
      _password.length >= passwordMinLength &&
      _passwordAgain == _password &&
      !busy;

  Future<Result<void>> _send() async {
    final result = await _repository.startPasswordReset(_serverUrl, email);
    switch (result) {
      case Ok(:final value):
        _requestId = value;
        _step = WebResetStep.code;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _save() async {
    final requestId = _requestId;
    if (requestId == null) return const Result.ok(null);
    var token = _token;
    if (token == null) {
      final verified = await _repository.verifyPasswordReset(
        _serverUrl,
        requestId: requestId,
        code: _code.trim(),
      );
      switch (verified) {
        case Ok(:final value):
          token = _token = value;
        case Error(:final error):
          return Result.error(error);
      }
    }
    final finished = await _repository.finishPasswordReset(
      _serverUrl,
      token: token,
      password: _password,
    );
    if (finished is Error<void>) return finished;
    _password = '';
    _passwordAgain = '';
    _token = null;
    _step = WebResetStep.done;
    return const Result.ok(null);
  }
}
