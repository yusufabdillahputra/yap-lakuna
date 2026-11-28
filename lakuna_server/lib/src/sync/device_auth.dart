import 'package:lakuna_domain/lakuna_domain.dart' show secretHash;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'apply_change.dart';

/// Kredensial aktif untuk [deviceToken], atau `null`.
Future<DeviceCredential?> findDeviceCredential(
  Session session,
  String deviceToken,
) => DeviceCredential.db.findFirstRow(
  session,
  where: (c) =>
      c.tokenHash.equals(secretHash(deviceToken)) & c.revokedAt.equals(null),
);

/// Tenant dan perangkat pemilik [deviceToken]; memperbarui `last_seen_at`.
/// Token salah atau dicabut melempar [SyncAuthException].
Future<DeviceAuth> authenticateDevice(
  Session session,
  String deviceToken,
) async {
  final credential = await findDeviceCredential(session, deviceToken);
  if (credential == null) {
    throw SyncAuthException(reason: 'invalidToken');
  }
  await DeviceCredential.db.updateRow(
    session,
    credential.copyWith(lastSeenAt: DateTime.now().toUtc()),
  );
  return DeviceAuth(
    tenantId: credential.tenantId,
    deviceId: credential.deviceId,
  );
}
