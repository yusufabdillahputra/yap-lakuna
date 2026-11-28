import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http_pkg;
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

  /// Unggah dan unduh berkas media dengan [deviceToken] (aturan 19–20).
  MediaTransport mediaTransport(String deviceToken);

  // --- Verifikasi 2 langkah pemilik (F2-02 aturan 12–14) -----------------
  // Butuh [login] lebih dulu, kecuali [twoFactorEnabled].

  Future<bool> totpStatus();
  // Atur 2FA butuh token perangkat toko milik akun itu (review C1).
  Future<TotpEnrollment> totpBegin(String deviceToken);
  Future<List<String>> totpConfirm(String deviceToken, String code);
  Future<void> totpDisable(String deviceToken, String code);

  /// Status verifikasi 2 langkah pemilik tenant perangkat [deviceToken].
  Future<bool> twoFactorEnabled(String deviceToken);

  // --- Login web pemilik (F2-02 aturan 11–13a) ---------------------------

  /// Toko milik akun yang login (butuh [login]).
  Future<List<WebTenant>> webTenants();

  /// Kode verifikasi → perangkat web baru (butuh [login]).
  Future<WebAccessResult> webOpen({
    required String code,
    required UuidValue tenantId,
    required bool remember,
  });

  /// Mencabut token web [deviceToken] (*Keluar*).
  Future<void> webLogout(String deviceToken);

  Future<UuidValue> startPasswordReset(String email);
  Future<String> verifyPasswordReset(UuidValue requestId, String code);
  Future<void> finishPasswordReset(String token, String password);
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

  @override
  Future<bool> totpStatus() => _guard(() => client.totp.status());

  @override
  Future<TotpEnrollment> totpBegin(String deviceToken) =>
      _guard(() => client.totp.begin(deviceToken));

  @override
  Future<List<String>> totpConfirm(String deviceToken, String code) =>
      _guard(() => client.totp.confirm(deviceToken, code.trim()));

  @override
  Future<void> totpDisable(String deviceToken, String code) =>
      _guard(() => client.totp.disable(deviceToken, code.trim()));

  @override
  Future<List<WebTenant>> webTenants() =>
      _guard(() => client.webAccess.tenants());

  @override
  Future<WebAccessResult> webOpen({
    required String code,
    required UuidValue tenantId,
    required bool remember,
  }) => _guard(() => client.webAccess.open(code.trim(), tenantId, remember));

  @override
  Future<void> webLogout(String deviceToken) =>
      _guard(() => client.webAccess.logout(deviceToken));

  @override
  Future<UuidValue> startPasswordReset(String email) =>
      _guard(() => client.emailIdp.startPasswordReset(email: email.trim()));

  @override
  Future<String> verifyPasswordReset(UuidValue requestId, String code) =>
      _guard(
        () => client.emailIdp.verifyPasswordResetCode(
          passwordResetRequestId: requestId,
          verificationCode: code.trim(),
        ),
      );

  @override
  Future<void> finishPasswordReset(String token, String password) => _guard(
    () => client.emailIdp.finishPasswordReset(
      finishPasswordResetToken: token,
      newPassword: password,
    ),
  );

  @override
  Future<bool> twoFactorEnabled(String deviceToken) =>
      _guard(() => client.webAccess.twoFactorEnabled(deviceToken));

  /// Transport sync dengan [deviceToken].
  @override
  SyncTransport transport(String deviceToken) =>
      _ServerpodSyncTransport(client, deviceToken);

  @override
  MediaTransport mediaTransport(String deviceToken) =>
      _ServerpodMediaTransport(client, deviceToken);
}

class _ServerpodMediaTransport implements MediaTransport {
  _ServerpodMediaTransport(this._client, this._token);

  final Client _client;
  final String _token;

  @override
  Future<String?> uploadDescription(UuidValue mediaFileId) =>
      _guard(() => _client.mediaSync.uploadDescription(_token, mediaFileId));

  @override
  Future<void> upload(String description, Uint8List bytes) => _guard(() async {
    final ok = await FileUploader(
      description,
    ).uploadByteData(ByteData.sublistView(bytes));
    if (!ok) throw const HttpException('Unggah media ditolak');
  });

  @override
  Future<bool> markUploaded(UuidValue mediaFileId) =>
      _guard(() => _client.mediaSync.markUploaded(_token, mediaFileId));

  @override
  Future<Uri?> downloadUrl(UuidValue mediaFileId) =>
      _guard(() => _client.mediaSync.downloadUrl(_token, mediaFileId));

  @override
  Future<Uint8List> download(Uri url) => _guard(() async {
    if (kIsWeb) {
      // Browser: unduh lewat fetch (domain media butuh CORS, F2-02
      // aturan 25a).
      final response = await http_pkg
          .get(url)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        throw HttpException('Unduh media ${response.statusCode}', uri: url);
      }
      return response.bodyBytes;
    }
    final http = HttpClient()..connectionTimeout = const Duration(seconds: 30);
    try {
      final response = await (await http.getUrl(url)).close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Unduh media ${response.statusCode}', uri: url);
      }
      final builder = BytesBuilder(copy: false);
      await response.forEach(builder.add);
      return builder.takeBytes();
    } finally {
      http.close();
    }
  });
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
  if (kIsWeb) return DevicePlatform.web;
  if (Platform.isAndroid) return DevicePlatform.android;
  if (Platform.isIOS) return DevicePlatform.ios;
  if (Platform.isWindows) return DevicePlatform.windows;
  if (Platform.isMacOS) return DevicePlatform.macos;
  return DevicePlatform.linux;
}
