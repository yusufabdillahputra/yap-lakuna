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

  @override
  Future<void> login({required String email, required String password}) async =>
      calls.add('login:$email');

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
