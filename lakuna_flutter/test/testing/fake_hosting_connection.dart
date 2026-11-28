import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_flutter/data/services/serverpod_hosting.dart';

/// Server versi hosting palsu untuk tes [LocalHostingRepository]: aktivasi
/// dan kode pasang berhasil, transport sync selalu offline.
class FakeHostingConnection implements HostingConnection {
  FakeHostingConnection(this.server);

  final Uri server;
  final calls = <String>[];
  var closed = false;

  /// Galat yang dilempar `joinWithPairingCode`.
  Object? joinFailure;
  String? transportToken;
  String? mediaToken;

  @override
  Future<void> login({required String email, required String password}) async {
    calls.add('login:$email');
    final e = loginFailure;
    if (e != null) throw e;
    signedIn = true;
  }

  @override
  Future<UuidValue> startRegistration(String email) async =>
      UuidValue.fromString('01900000-0000-7000-8000-0000000000e1');

  @override
  Future<String> verifyRegistration(UuidValue requestId, String code) async =>
      'token-daftar';

  @override
  Future<void> finishRegistration(String token, String password) async {}

  @override
  Future<SyncServerStatus> status(String? deviceToken) async {
    calls.add('status');
    return SyncServerStatus(
      serverVersion: '0.166.0',
      protocolVersion: syncProtocolVersion,
      serverTime: DateTime.now().toUtc(),
      tenantKnown: deviceToken != null,
    );
  }

  @override
  Future<ActivationResult> activateFirstDevice({
    required String activationCode,
    required UuidValue tenantId,
    required UuidValue deviceId,
    required String tenantName,
    required String deviceCode,
  }) async {
    calls.add('activate:$activationCode');
    return ActivationResult(
      deviceToken: 'token-aktivasi',
      tenantId: tenantId,
      deviceId: deviceId,
      deviceCode: deviceCode,
    );
  }

  @override
  Future<String> createPairingCode(String deviceToken) async {
    calls.add('pairing:$deviceToken');
    return 'ABCD2345';
  }

  @override
  Future<List<PairingOutlet>> pairingOutlets(String pairingCode) async => [];

  @override
  Future<ActivationResult> joinWithPairingCode({
    required String pairingCode,
    required UuidValue outletId,
    required String deviceCode,
    required String deviceName,
    required DevicePlatform platform,
  }) async {
    calls.add('join');
    final e = joinFailure;
    if (e != null) throw e;
    throw const SyncOfflineException();
  }

  @override
  SyncTransport transport(String deviceToken) {
    transportToken = deviceToken;
    return const _OfflineTransport();
  }

  @override
  MediaTransport mediaTransport(String deviceToken) {
    mediaToken = deviceToken;
    return const _OfflineMedia();
  }

  /// Server verifikasi 2 langkah palsu: kode `123456` benar, kode cadangan
  /// `AAAA-BBBB` benar.
  var totpEnabled = false;
  var signedIn = false;
  Object? loginFailure;

  void _needLogin() {
    if (!signedIn) throw StateError('belum login');
  }

  @override
  Future<bool> totpStatus() async {
    _needLogin();
    return totpEnabled;
  }

  @override
  Future<TotpEnrollment> totpBegin(String deviceToken) async {
    _needLogin();
    calls.add('totpBegin:$deviceToken');
    return TotpEnrollment(
      secretBase32: 'JBSWY3DPEHPK3PXP',
      otpauthUri: 'otpauth://totp/Lakuna:a%40b.id?secret=JBSWY3DPEHPK3PXP',
    );
  }

  @override
  Future<List<String>> totpConfirm(String deviceToken, String code) async {
    _needLogin();
    calls.add('totpConfirm:$deviceToken:$code');
    if (code != '123456') {
      throw WebAccessException(failure: WebAccessFailure.totpInvalid);
    }
    totpEnabled = true;
    return [for (var i = 0; i < 8; i++) 'AAAA-BBB$i'];
  }

  @override
  Future<void> totpDisable(String deviceToken, String code) async {
    _needLogin();
    calls.add('totpDisable:$deviceToken:$code');
    if (code != '123456' && code != 'AAAA-BBBB') {
      throw WebAccessException(failure: WebAccessFailure.totpInvalid);
    }
    totpEnabled = false;
  }

  @override
  Future<bool> twoFactorEnabled(String deviceToken) async {
    calls.add('twoFactorEnabled:$deviceToken');
    return totpEnabled;
  }

  /// Token yang dicabut lewat [webLogout].
  final loggedOut = <String>[];

  /// Galat berikutnya dari [webLogout] (sekali pakai).
  Exception? webLogoutError;

  @override
  Future<List<WebTenant>> webTenants() async {
    _needLogin();
    calls.add('webTenants');
    return [
      WebTenant(
        tenantId: UuidValue.fromString('01900000-0000-7000-8000-000000000001'),
        name: 'Toko Bu Ani',
      ),
    ];
  }

  @override
  Future<WebAccessResult> webOpen({
    required String code,
    required UuidValue tenantId,
    required bool remember,
  }) async {
    _needLogin();
    calls.add('webOpen:$code:$remember');
    if (code != '123456') {
      throw WebAccessException(failure: WebAccessFailure.totpInvalid);
    }
    return WebAccessResult(
      deviceToken: 'token-web',
      tenantId: tenantId,
      deviceId: UuidValue.fromString('01900000-0000-7000-8000-0000000000e1'),
      deviceCode: 'W01',
      outletId: UuidValue.fromString('01900000-0000-7000-8000-000000000010'),
      expiresAt: DateTime.utc(2026, 12, 28),
    );
  }

  @override
  Future<void> webLogout(String deviceToken) async {
    calls.add('webLogout:$deviceToken');
    if (webLogoutError case final e?) {
      webLogoutError = null;
      throw e;
    }
    loggedOut.add(deviceToken);
  }

  @override
  Future<UuidValue> startPasswordReset(String email) async {
    calls.add('startPasswordReset:$email');
    return UuidValue.fromString('01900000-0000-7000-8000-0000000000f1');
  }

  @override
  Future<String> verifyPasswordReset(UuidValue requestId, String code) async {
    calls.add('verifyPasswordReset:$code');
    return 'token-reset';
  }

  @override
  Future<void> finishPasswordReset(String token, String password) async {
    calls.add('finishPasswordReset:$token');
  }

  @override
  void close() => closed = true;
}

class _OfflineTransport implements SyncTransport {
  const _OfflineTransport();

  @override
  Future<SyncPushReply> push(List<SyncPushEntry> entries) =>
      throw const SyncOfflineException();

  @override
  Future<SyncPullPage> pull(int afterSeq) => throw const SyncOfflineException();

  @override
  Future<SyncServerStatus> status() => throw const SyncOfflineException();
}

class _OfflineMedia implements MediaTransport {
  const _OfflineMedia();

  @override
  Future<String?> uploadDescription(UuidValue mediaFileId) =>
      throw const SyncOfflineException();

  @override
  Future<void> upload(String description, Uint8List bytes) =>
      throw const SyncOfflineException();

  @override
  Future<bool> markUploaded(UuidValue mediaFileId) =>
      throw const SyncOfflineException();

  @override
  Future<Uri?> downloadUrl(UuidValue mediaFileId) =>
      throw const SyncOfflineException();

  @override
  Future<Uint8List> download(Uri url) => throw const SyncOfflineException();
}
