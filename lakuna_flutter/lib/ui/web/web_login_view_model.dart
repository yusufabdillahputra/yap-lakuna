import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show normalizeBackupCode;

import '../../data/repositories/web_join_repository.dart';
import '../../data/services/web_session_store.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Langkah layar login web 2.2.
enum WebLoginStep {
  /// Email + kata sandi.
  credentials,

  /// Kode authenticator atau kode cadangan (dan pilihan toko).
  secondFactor,

  /// Perangkat web sudah dibuat; *Menyiapkan data toko* menarik data.
  preparing,
}

final _sixDigits = RegExp(r'^\d{6}$');
final _backupCode = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$');

/// Login web pemilik (F2-02 aturan 11–13a, layar 2.2): email + kata sandi
/// akun pemilik, lalu kode verifikasi 2 langkah membuat perangkat web.
/// Database sesi baru dicatat sebagai gabung tertunda, jadi pull pertama
/// (langkah [WebLoginStep.preparing]) memakai alur *Menyiapkan data toko*
/// dan dilanjutkan bila tab ditutup.
class WebLoginViewModel extends ChangeNotifier {
  WebLoginViewModel({
    required this._repository,
    required this._sessions,
    String initialServer = '',
  }) : _server = initialServer {
    submitCredentials = Command0(_submitCredentials)
      ..addListener(notifyListeners);
    submitCode = Command0(_submitCode)..addListener(notifyListeners);
    if (_sessions.pendingDatabase != null) _step = WebLoginStep.preparing;
  }

  final WebLoginRepository _repository;
  final WebSessionStore _sessions;

  /// Langkah 1: login akun dan muat toko miliknya.
  late final Command0<void> submitCredentials;

  /// Langkah 2: verifikasi kode dan buat perangkat web.
  late final Command0<void> submitCode;

  var _step = WebLoginStep.credentials;
  WebLoginStep get step => _step;

  String _server;
  String _email = '';
  String _password = '';
  String _code = '';
  var _remember = true;
  List<WebTenant> _tenants = const [];
  UuidValue? _tenantId;

  String get serverUrl => _server.trim();
  String get email => _email;
  String get password => _password;
  String get code => _code;

  /// *Ingat perangkat ini 30 hari* (bawaan dicentang); tanpa centang token
  /// berlaku 12 jam.
  bool get remember => _remember;

  /// Toko milik akun; lebih dari satu → pilihan di langkah 2.
  List<WebTenant> get tenants => _tenants;
  UuidValue? get tenantId => _tenantId;

  bool get busy => submitCredentials.running || submitCode.running;

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

  void setServer(String value) {
    _server = value;
    submitCredentials.clearResult();
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    submitCredentials.clearResult();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    submitCredentials.clearResult();
    notifyListeners();
  }

  void setRemember(bool value) {
    _remember = value;
    notifyListeners();
  }

  void setCode(String value) {
    _code = value;
    submitCode.clearResult();
    notifyListeners();
  }

  void selectTenant(UuidValue id) {
    _tenantId = id;
    submitCode.clearResult();
    notifyListeners();
  }

  /// Kode yang dikirim: 6 angka tanpa spasi, atau kode cadangan
  /// `XXXX-XXXX`; `null` bila belum berbentuk salah satunya.
  String? get _normalizedCode {
    final digits = _code.replaceAll(RegExp(r'\s'), '');
    if (_sixDigits.hasMatch(digits)) return digits;
    final backup = normalizeBackupCode(_code);
    return _backupCode.hasMatch(backup) ? backup : null;
  }

  bool get canSubmitCredentials =>
      serverUrl.isNotEmpty &&
      _email.trim().contains('@') &&
      _password.isNotEmpty &&
      !busy;

  bool get canSubmitCode =>
      _normalizedCode != null && _tenantId != null && !busy;

  /// Kembali ke langkah 1 (mis. salah akun).
  void back() {
    _step = WebLoginStep.credentials;
    _code = '';
    submitCode.clearResult();
    notifyListeners();
  }

  Future<Result<void>> _submitCredentials() async {
    final result = await _repository.signIn(
      serverUrl,
      email: _email.trim(),
      password: _password,
    );
    switch (result) {
      case Ok(:final value):
        if (value.isEmpty) {
          return Result.error(
            WebAccessException(failure: WebAccessFailure.noTenant),
          );
        }
        _tenants = value;
        if (!value.any((t) => t.tenantId == _tenantId)) {
          _tenantId = value.first.tenantId;
        }
        _code = '';
        _step = WebLoginStep.secondFactor;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _submitCode() async {
    final code = _normalizedCode;
    final tenant = _tenantId;
    if (code == null || tenant == null) return const Result.ok(null);
    final result = await _repository.open(
      serverUrl,
      code: code,
      tenantId: tenant,
      remember: _remember,
    );
    switch (result) {
      case Ok(:final value):
        await _sessions.setPendingDatabase(value);
        _password = '';
        _code = '';
        _step = WebLoginStep.preparing;
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
