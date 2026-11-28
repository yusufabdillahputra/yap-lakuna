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

/// Token web (F2-02) dengan `expires_at` yang sudah lewat pada [now].
bool credentialExpired(DeviceCredential credential, DateTime now) {
  final expiresAt = credential.expiresAt;
  return expiresAt != null && !now.toUtc().isBefore(expiresAt);
}

/// Tenant dan perangkat pemilik [deviceToken]; memperbarui `last_seen_at`.
/// Token salah atau dicabut melempar [SyncAuthException] `invalidToken`;
/// token web lewat `expires_at` melempar `expired` (F2-02 aturan 11).
Future<DeviceAuth> authenticateDevice(
  Session session,
  String deviceToken,
) async {
  final credential = await findDeviceCredential(session, deviceToken);
  if (credential == null) {
    throw SyncAuthException(reason: 'invalidToken');
  }
  final now = DateTime.now().toUtc();
  if (credentialExpired(credential, now)) {
    throw SyncAuthException(reason: 'expired');
  }
  await DeviceCredential.db.updateRow(
    session,
    credential.copyWith(lastSeenAt: now),
  );
  return DeviceAuth(
    tenantId: credential.tenantId,
    deviceId: credential.deviceId,
  );
}
