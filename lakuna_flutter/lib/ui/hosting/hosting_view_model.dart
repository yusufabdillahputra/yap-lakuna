import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;

import '../../data/repositories/hosting_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Langkah stepper aktivasi 2.1.
enum ActivationStep { server, owner, upload, done }

/// Pilihan server di langkah 1.
enum ServerChoice { lakuna, own }

/// Cara login pemilik di langkah 2.
enum OwnerMode { signIn, register }

/// Kata sandi akun pemilik minimal (sama dengan bawaan Serverpod auth).
const ownerPasswordMinLength = 8;

/// Kartu *Versi hosting* dan stepper aktivasi 2.1 (F2-01).
class HostingViewModel extends ChangeNotifier {
  HostingViewModel({
    required this._repository,
    this.progressInterval = const Duration(seconds: 1),
  }) {
    load = Command0(_load)..addListener(notifyListeners);
    check = Command0(_check)..addListener(notifyListeners);
    signIn = Command0(_signIn)..addListener(notifyListeners);
    sendCode = Command0(_sendCode)..addListener(notifyListeners);
    createAccount = Command0(_createAccount)..addListener(notifyListeners);
    activate = Command0(_activate)..addListener(notifyListeners);
    setPaused = Command1(_setPaused)..addListener(notifyListeners);
    createPairing = Command0(_createPairing)..addListener(notifyListeners);
    _repository.addListener(_onStatus);
    _serverChoice = _repository.lakunaServerUrl != null
        ? ServerChoice.lakuna
        : ServerChoice.own;
  }

  final HostingRepository _repository;
  final Duration progressInterval;

  late final Command0<HostingState> load;
  late final Command0<SyncServerStatus> check;
  late final Command0<void> signIn;
  late final Command0<UuidValue> sendCode;
  late final Command0<void> createAccount;
  late final Command0<void> activate;
  late final Command1<void, bool> setPaused;
  late final Command0<PairingCodeShare> createPairing;

  HostingState? _state;
  HostingState? get state => _state;
  SyncStatus get status => _repository.status;
  String? get lakunaServerUrl => _repository.lakunaServerUrl;

  /// Stepper sedang tampil (bukan kartu ringkasan).
  bool _activating = false;
  bool get activating => _activating;
  ActivationStep _step = ActivationStep.server;
  ActivationStep get step => _step;

  late ServerChoice _serverChoice;
  ServerChoice get serverChoice => _serverChoice;
  String _ownUrl = '';
  String _activationCode = '';
  String get activationCode => _activationCode;
  SyncServerStatus? _serverStatus;
  SyncServerStatus? get serverStatus => _serverStatus;

  OwnerMode _ownerMode = OwnerMode.signIn;
  OwnerMode get ownerMode => _ownerMode;
  String _email = '';
  String _password = '';
  String _passwordRepeat = '';
  String _verificationCode = '';
  UuidValue? _registrationId;
  bool get codeSent => _registrationId != null;
  String get email => _email.trim();
  String? _signedInAs;
  String? get signedInAs => _signedInAs;

  List<UploadGroupProgress> _progress = const [];
  List<UploadGroupProgress> get progress => _progress;
  Timer? _poll;
  var _disposed = false;

  /// Alamat server yang dipakai stepper.
  String get serverUrl => switch (_serverChoice) {
    ServerChoice.lakuna => _repository.lakunaServerUrl ?? '',
    ServerChoice.own => _ownUrl.trim(),
  };

  bool get busy =>
      check.running ||
      signIn.running ||
      sendCode.running ||
      createAccount.running ||
      activate.running;

  void _onStatus() {
    notifyListeners();
    // Hasil siklus baru: angka kartu ikut diperbarui.
    if (!load.running && !_activating) unawaited(load.execute());
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    _repository.removeListener(_onStatus);
    for (final c in [
      load,
      check,
      signIn,
      sendCode,
      createAccount,
      activate,
      setPaused,
      createPairing,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<Result<HostingState>> _load() async {
    final result = await _repository.load();
    if (result case Ok(:final value)) {
      _state = value;
      if (value.active && value.pending > 0 && !_activating) {
        await _refreshProgress();
      }
    }
    return result;
  }

  Future<void> _refreshProgress() async {
    if (await _repository.uploadProgress() case Ok(:final value)) {
      _progress = value;
    }
  }

  /// Unggah data awal belum selesai (ada kelompok yang belum semua
  /// *acked*).
  bool get uploading => _progress.any((g) => g.acked < g.total);

  // --- Stepper -----------------------------------------------------------

  void startActivation() {
    _activating = true;
    _step = ActivationStep.server;
    _serverStatus = null;
    check.clearResult();
    notifyListeners();
  }

  void cancelActivation() {
    _activating = false;
    _poll?.cancel();
    notifyListeners();
  }

  void chooseServer(ServerChoice choice) {
    if (choice == _serverChoice) return;
    _serverChoice = choice;
    _serverStatus = null;
    check.clearResult();
    notifyListeners();
  }

  void setOwnUrl(String value) {
    _ownUrl = value;
    _serverStatus = null;
    notifyListeners();
  }

  void setActivationCode(String value) {
    _activationCode = value;
    notifyListeners();
  }

  bool get canCheck =>
      serverUrl.isNotEmpty && _activationCode.trim().isNotEmpty && !busy;

  /// Server sudah diperiksa: langkah 2 boleh dibuka.
  bool get canLeaveServerStep =>
      _serverStatus != null && _activationCode.trim().isNotEmpty;

  Future<Result<SyncServerStatus>> _check() async {
    _serverStatus = null;
    final result = await _repository.checkServer(serverUrl);
    if (result case Ok(:final value)) _serverStatus = value;
    return result;
  }

  void goTo(ActivationStep step) {
    if (step == ActivationStep.owner && !canLeaveServerStep) return;
    if (step == ActivationStep.upload && _signedInAs == null) return;
    _step = step;
    notifyListeners();
  }

  void setOwnerMode(OwnerMode mode) {
    _ownerMode = mode;
    signIn.clearResult();
    sendCode.clearResult();
    createAccount.clearResult();
    notifyListeners();
  }

  void setEmail(String v) {
    _email = v;
    notifyListeners();
  }

  void setPassword(String v) {
    _password = v;
    notifyListeners();
  }

  void setPasswordRepeat(String v) {
    _passwordRepeat = v;
    notifyListeners();
  }

  void setVerificationCode(String v) {
    _verificationCode = v;
    notifyListeners();
  }

  bool get _emailValid => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  bool get canSignIn => _emailValid && _password.isNotEmpty && !busy;

  bool get canSendCode => _emailValid && !busy;

  /// Galat isian kata sandi baru (aturan ketik ulang kredensial Lakuna).
  PasswordIssue? get passwordIssue {
    if (_password.isEmpty && _passwordRepeat.isEmpty) return null;
    if (_password.length < ownerPasswordMinLength) return PasswordIssue.short;
    if (_passwordRepeat.isNotEmpty && _password != _passwordRepeat) {
      return PasswordIssue.mismatch;
    }
    return null;
  }

  bool get canCreateAccount =>
      codeSent &&
      _verificationCode.trim().isNotEmpty &&
      _password.length >= ownerPasswordMinLength &&
      _password == _passwordRepeat &&
      !busy;

  Future<Result<void>> _signIn() async {
    final result = await _repository.login(
      serverUrl,
      email: email,
      password: _password,
    );
    if (result is Ok) {
      _signedInAs = email;
      _password = '';
      _step = ActivationStep.upload;
    }
    return result;
  }

  Future<Result<UuidValue>> _sendCode() async {
    final result = await _repository.startRegistration(serverUrl, email);
    if (result case Ok(:final value)) _registrationId = value;
    return result;
  }

  Future<Result<void>> _createAccount() async {
    final id = _registrationId;
    if (id == null) return const Result.error(HostingFormIncomplete());
    final token = await _repository.verifyRegistration(
      serverUrl,
      requestId: id,
      code: _verificationCode,
    );
    switch (token) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        final done = await _repository.finishRegistration(
          serverUrl,
          registrationToken: value,
          password: _password,
        );
        if (done is Ok) {
          _signedInAs = email;
          _password = '';
          _passwordRepeat = '';
          _step = ActivationStep.upload;
        }
        return done;
    }
  }

  Future<Result<void>> _activate() async {
    final result = await _repository.activate(
      serverUrl,
      activationCode: _activationCode.trim(),
    );
    if (result is Ok) {
      await _load();
      await _refreshProgress();
      _startPolling();
    }
    return result;
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(progressInterval, (_) async {
      await _refreshProgress();
      if (_progress.isNotEmpty && !uploading) {
        _poll?.cancel();
        _step = ActivationStep.done;
      }
      notifyListeners();
    });
  }

  /// *Selesai* di langkah 4.
  void finishActivation() {
    _activating = false;
    _poll?.cancel();
    notifyListeners();
    unawaited(load.execute());
  }

  // --- Kartu -------------------------------------------------------------

  Future<Result<void>> _setPaused(bool paused) async {
    final result = await _repository.setPaused(paused);
    if (result is Ok) await _load();
    return result;
  }

  void syncNow() => _repository.syncNow();

  Future<Result<PairingCodeShare>> _createPairing() =>
      _repository.createPairingCode();
}

enum PasswordIssue { short, mismatch }

/// Isian langkah belum lengkap (tombol seharusnya nonaktif).
class HostingFormIncomplete implements Exception {
  const HostingFormIncomplete();

  @override
  String toString() => 'HostingFormIncomplete';
}
