import 'dart:async';
import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

/// Galat jaringan dari klien Serverpod diubah menjadi
/// [SyncOfflineException] agar mesin sync menampilkan *Menunggu jaringan*.
/// `ClientException` paket http sudah dibungkus klien Serverpod menjadi
/// [ServerpodClientNetworkException].
Future<T> _guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on ServerpodClientNetworkException catch (e) {
    throw SyncOfflineException(e);
  } on SocketException catch (e) {
    throw SyncOfflineException(e);
  } on TimeoutException catch (e) {
    throw SyncOfflineException(e);
  } on HttpException catch (e) {
    throw SyncOfflineException(e);
  } on ServerpodClientHttpException catch (e) {
    // Proksi atau server sedang dimulai ulang.
    if (const {502, 503, 504}.contains(e.statusCode)) {
      throw SyncOfflineException(e);
    }
    rethrow;
  }
}

class _BearerAuth implements ClientAuthKeyProvider {
  String? token;

  @override
  Future<String?> get authHeaderValue async {
    final t = token;
    return t == null ? null : wrapAsBearerAuthHeaderValue(t);
  }
}

/// Koneksi ke satu server versi hosting: aktivasi, akun pemilik, dan
/// transport sync dengan token perangkat. Versi palsu dipakai di tes.
abstract interface class HostingConnection implements HostingClient {
  Future<void> login({required String email, required String password});
  Future<UuidValue> startRegistration(String email);
  Future<String> verifyRegistration(UuidValue requestId, String code);
  Future<void> finishRegistration(String token, String password);
  SyncTransport transport(String deviceToken);
  void close();
}

/// [HostingConnection] lewat klien Serverpod.
class ServerpodHosting implements HostingConnection {
  ServerpodHosting(Uri server)
    : _auth = _BearerAuth(),
      client = Client(
        server.toString(),
        connectionTimeout: const Duration(seconds: 30),
      ) {
    client.authKeyProvider = _auth;
  }

  final Client client;
  final _BearerAuth _auth;

  /// Sudah login sebagai akun pemilik (sesi hanya di memori).
  bool get signedIn => _auth.token != null;

  @override
  void close() => client.close();

  @override
  Future<void> login({required String email, required String password}) async {
    final auth = await _guard(
      () => client.emailIdp.login(email: email.trim(), password: password),
    );
    _auth.token = auth.token;
  }

  @override
  Future<UuidValue> startRegistration(String email) =>
      _guard(() => client.emailIdp.startRegistration(email: email.trim()));

  @override
  Future<String> verifyRegistration(UuidValue requestId, String code) => _guard(
    () => client.emailIdp.verifyRegistrationCode(
      accountRequestId: requestId,
      verificationCode: code.trim(),
    ),
  );

  @override
  Future<void> finishRegistration(String token, String password) async {
    final auth = await _guard(
      () => client.emailIdp.finishRegistration(
        registrationToken: token,
        password: password,
      ),
    );
    _auth.token = auth.token;
  }

  @override
  Future<SyncServerStatus> status(String? deviceToken) =>
      _guard(() => client.sync.status(deviceToken));

  @override
  Future<ActivationResult> activateFirstDevice({
    required String activationCode,
    required UuidValue tenantId,
    required UuidValue deviceId,
    required String tenantName,
    required String deviceCode,
  }) => _guard(
    () => client.activation.activateFirstDevice(
      activationCode,
      tenantId,
      deviceId,
      tenantName,
      deviceCode,
    ),
  );

  @override
  Future<String> createPairingCode(String deviceToken) =>
      _guard(() => client.activation.createPairingCode(deviceToken));

  @override
  Future<List<PairingOutlet>> pairingOutlets(String pairingCode) =>
      _guard(() => client.activation.pairingOutlets(pairingCode));

  @override
  Future<ActivationResult> joinWithPairingCode({
    required String pairingCode,
    required UuidValue outletId,
    required String deviceCode,
    required String deviceName,
    required DevicePlatform platform,
  }) => _guard(
    () => client.activation.joinWithPairingCode(
      pairingCode,
      outletId,
      deviceCode,
      deviceName,
      platform,
    ),
  );

  /// Transport sync dengan [deviceToken].
  @override
  SyncTransport transport(String deviceToken) =>
      _ServerpodSyncTransport(client, deviceToken);
}

class _ServerpodSyncTransport implements SyncTransport {
  _ServerpodSyncTransport(this._client, this._token);

  final Client _client;
  final String _token;

  @override
  Future<SyncPushReply> push(List<SyncPushEntry> entries) =>
      _guard(() => _client.sync.push(_token, entries));

  @override
  Future<SyncPullPage> pull(int afterSeq) =>
      _guard(() => _client.sync.pull(_token, afterSeq));

  @override
  Future<SyncServerStatus> status() =>
      _guard(() => _client.sync.status(_token));
}

/// Platform perangkat ini untuk baris `devices` saat gabung.
DevicePlatform currentDevicePlatform() {
  if (Platform.isAndroid) return DevicePlatform.android;
  if (Platform.isIOS) return DevicePlatform.ios;
  if (Platform.isWindows) return DevicePlatform.windows;
  if (Platform.isMacOS) return DevicePlatform.macos;
  return DevicePlatform.linux;
}
