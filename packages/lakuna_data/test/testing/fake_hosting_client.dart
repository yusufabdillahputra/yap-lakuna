import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

/// Server aktivasi palsu di memori untuk tes versi hosting.
class FakeHostingClient implements HostingClient {
  FakeHostingClient({required this.serverTime});

  DateTime serverTime;
  int protocolVersion = syncProtocolVersion;
  String? minAppVersion;

  /// Galat yang dilempar panggilan aktivasi/pasang berikutnya.
  Object? failWith;

  /// Urutan panggilan (`status`, `activate`, `pairing`, `outlets`, `join`).
  final calls = <String>[];

  ({
    String activationCode,
    UuidValue tenantId,
    UuidValue deviceId,
    String tenantName,
    String deviceCode,
  })?
  activated;

  ({String pairingCode, UuidValue outletId, String deviceCode})? joined;
  String? pairingToken;

  final joinedDeviceId = UuidValue.fromString(
    '01900000-0000-7000-8000-0000000000c1',
  );

  List<PairingOutlet> outlets = [];

  void _fail() {
    final e = failWith;
    if (e != null) throw e;
  }

  @override
  Future<SyncServerStatus> status(String? deviceToken) async {
    calls.add('status');
    return SyncServerStatus(
      serverVersion: '0.166.0',
      protocolVersion: protocolVersion,
      minAppVersion: minAppVersion,
      serverTime: serverTime,
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
    calls.add('activate');
    _fail();
    activated = (
      activationCode: activationCode,
      tenantId: tenantId,
      deviceId: deviceId,
      tenantName: tenantName,
      deviceCode: deviceCode,
    );
    return ActivationResult(
      deviceToken: 'token-aktivasi',
      tenantId: tenantId,
      deviceId: deviceId,
      deviceCode: deviceCode,
    );
  }

  @override
  Future<String> createPairingCode(String deviceToken) async {
    calls.add('pairing');
    _fail();
    pairingToken = deviceToken;
    return 'ABCD2345';
  }

  @override
  Future<List<PairingOutlet>> pairingOutlets(String pairingCode) async {
    calls.add('outlets');
    _fail();
    return outlets;
  }

  @override
  Future<ActivationResult> joinWithPairingCode({
    required String pairingCode,
    required UuidValue outletId,
    required String deviceCode,
    required String deviceName,
    required DevicePlatform platform,
  }) async {
    calls.add('join');
    _fail();
    joined = (
      pairingCode: pairingCode,
      outletId: outletId,
      deviceCode: deviceCode,
    );
    return ActivationResult(
      deviceToken: 'token-gabung',
      tenantId: UuidValue.fromString('01900000-0000-7000-8000-000000000001'),
      deviceId: joinedDeviceId,
      deviceCode: deviceCode,
    );
  }
}
