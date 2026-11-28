import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

HostingState hostingState({
  bool active = false,
  String? serverUrl,
  DateTime? lastSyncAt,
  int pending = 0,
  int conflicts = 0,
  String? lastError,
  bool paused = false,
}) => (
  active: active,
  serverUrl: serverUrl,
  lastSyncAt: lastSyncAt,
  pending: pending,
  conflicts: conflicts,
  lastError: lastError,
  paused: paused,
  compacting: false,
);

/// Versi hosting palsu di memori untuk tes widget.
class FakeHostingRepository extends HostingRepository {
  FakeHostingRepository({
    HostingState? state,
    this.lakunaServerUrl,
    SyncStatus status = SyncStatus.local,
  }) : state = state ?? hostingState(),
       _status = status; // ignore: prefer_initializing_formals

  HostingState state;

  @override
  final String? lakunaServerUrl;

  SyncStatus _status;

  @override
  SyncStatus get status => _status;

  set status(SyncStatus value) {
    _status = value;
    notifyListeners();
  }

  /// Galat untuk `checkServer` / `pairingOutlets` berikutnya.
  Exception? checkError;
  Exception? loginError;
  Exception? activateError;
  Exception? joinError;

  final calls = <String>[];
  String? checkedUrl;
  String? activatedWith;
  ({String server, String code, String deviceCode, String deviceName})? joined;

  List<UploadGroupProgress> progress = const [];
  List<PairingOutlet> outlets = const [];
  int sales = 0;
  PairingCodeShare? pairing;
  var syncNowCalls = 0;

  @override
  Future<Result<HostingState>> load() async {
    calls.add('load');
    return Result.ok(state);
  }

  @override
  Future<Result<SyncServerStatus>> checkServer(String serverUrl) async {
    calls.add('check');
    checkedUrl = serverUrl;
    final e = checkError;
    if (e != null) return Result.error(e);
    return Result.ok(
      SyncServerStatus(
        serverVersion: '0.166.0',
        protocolVersion: 1,
        serverTime: DateTime.utc(2026, 11, 28, 8),
        tenantKnown: false,
      ),
    );
  }

  @override
  Future<Result<void>> login(
    String serverUrl, {
    required String email,
    required String password,
  }) async {
    calls.add('login:$email');
    final e = loginError;
    return e == null ? const Result.ok(null) : Result.error(e);
  }

  @override
  Future<Result<UuidValue>> startRegistration(
    String serverUrl,
    String email,
  ) async {
    calls.add('register:$email');
    return Result.ok(
      UuidValue.fromString('01900000-0000-7000-8000-0000000000e1'),
    );
  }

  @override
  Future<Result<String>> verifyRegistration(
    String serverUrl, {
    required UuidValue requestId,
    required String code,
  }) async {
    calls.add('verify:$code');
    return const Result.ok('token-daftar');
  }

  @override
  Future<Result<void>> finishRegistration(
    String serverUrl, {
    required String registrationToken,
    required String password,
  }) async {
    calls.add('finish:$registrationToken');
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> activate(
    String serverUrl, {
    required String activationCode,
  }) async {
    calls.add('activate');
    final e = activateError;
    if (e != null) return Result.error(e);
    activatedWith = '$serverUrl|$activationCode';
    state = hostingState(active: true, serverUrl: serverUrl, pending: 10);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<UploadGroupProgress>>> uploadProgress() async =>
      Result.ok(progress);

  @override
  Future<Result<void>> setPaused(bool paused) async {
    calls.add('paused:$paused');
    state = hostingState(
      active: state.active,
      serverUrl: state.serverUrl,
      pending: state.pending,
      lastSyncAt: state.lastSyncAt,
      paused: paused,
    );
    return const Result.ok(null);
  }

  @override
  void syncNow() => syncNowCalls++;

  @override
  Future<Result<PairingCodeShare>> createPairingCode() async {
    calls.add('pairing');
    final p = pairing;
    if (p == null) return const Result.error(HostingNotActive());
    return Result.ok(p);
  }

  @override
  Future<Result<List<PairingOutlet>>> pairingOutlets(
    String serverUrl,
    String code,
  ) async {
    calls.add('outlets:$serverUrl|$code');
    final e = checkError;
    if (e != null) return Result.error(e);
    return Result.ok(outlets);
  }

  @override
  Future<Result<int>> localSales() async => Result.ok(sales);

  @override
  Future<Result<void>> join(
    String serverUrl, {
    required String code,
    required UuidValue outletId,
    required String deviceCode,
    required String deviceName,
  }) async {
    calls.add('join');
    final e = joinError;
    if (e != null) return Result.error(e);
    joined = (
      server: serverUrl,
      code: code,
      deviceCode: deviceCode,
      deviceName: deviceName,
    );
    return const Result.ok(null);
  }

  // --- Verifikasi 2 langkah: kode `123456` benar, kode cadangan
  // `AAAA-BBBB` benar, kata sandi `rahasia123` benar.

  var twoFactorOn = false;
  Exception? twoFactorStatusError;
  var twoFactorSession = false;

  @override
  Future<Result<bool>> twoFactorEnabled() async {
    calls.add('twoFactorEnabled');
    final e = twoFactorStatusError;
    if (e != null) return Result.error(e);
    return Result.ok(twoFactorOn);
  }

  @override
  Future<Result<bool>> twoFactorSignIn({
    required String email,
    required String password,
  }) async {
    calls.add('twoFactorSignIn:$email');
    if (password != 'rahasia123') {
      return Result.error(
        loginError ?? const HostingNotPermitted(),
      );
    }
    twoFactorSession = true;
    return Result.ok(twoFactorOn);
  }

  @override
  Future<Result<TotpEnrollment>> beginTwoFactor() async {
    calls.add('beginTwoFactor');
    if (twoFactorOn) {
      return Result.error(
        WebAccessException(failure: WebAccessFailure.totpAlreadyEnabled),
      );
    }
    return Result.ok(
      TotpEnrollment(
        secretBase32: 'JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP',
        otpauthUri:
            'otpauth://totp/Lakuna:sari%40contoh.id?secret='
            'JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP&issuer=Lakuna',
      ),
    );
  }

  @override
  Future<Result<List<String>>> confirmTwoFactor(String code) async {
    calls.add('confirmTwoFactor:$code');
    if (code != '123456') {
      return Result.error(
        WebAccessException(failure: WebAccessFailure.totpInvalid),
      );
    }
    twoFactorOn = true;
    return Result.ok([for (var i = 1; i <= 8; i++) 'KODE-000$i']);
  }

  @override
  Future<Result<void>> disableTwoFactor(String code) async {
    calls.add('disableTwoFactor:$code');
    if (code != '123456' && code != 'AAAA-BBBB') {
      return Result.error(
        WebAccessException(failure: WebAccessFailure.totpInvalid),
      );
    }
    twoFactorOn = false;
    return const Result.ok(null);
  }

  @override
  void endTwoFactor() {
    calls.add('endTwoFactor');
    twoFactorSession = false;
  }
}
