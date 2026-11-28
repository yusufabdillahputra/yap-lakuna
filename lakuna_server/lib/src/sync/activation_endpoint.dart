import 'package:lakuna_domain/lakuna_domain.dart'
    show Hlc, newDeviceToken, newShortCode, normalizeShortCode, secretHash;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'activation.dart';
import 'apply_change.dart' show lockTenantChanges;
import 'device_auth.dart';

/// Umur kode pasang perangkat (aturan 10).
const pairingCodeLifetime = Duration(minutes: 15);

/// Aktivasi versi hosting dan pasang perangkat berikutnya (F2-01 aturan
/// 9–11).
class ActivationEndpoint extends Endpoint {
  /// Perangkat pertama: memakai kode aktivasi dari admin server dan akun
  /// pemilik yang sedang login. Server membuat tenant dengan ID dari
  /// perangkat ([tenantId]) lalu menunggu unggahan data awal.
  Future<ActivationResult> activateFirstDevice(
    Session session,
    String activationCode,
    UuidValue tenantId,
    UuidValue deviceId,
    String tenantName,
    String deviceCode,
  ) async {
    final user = session.authenticated;
    if (user == null) _fail(ActivationFailure.notOwner);
    final now = DateTime.now().toUtc();
    final token = newDeviceToken();
    await session.db.transaction((tx) async {
      final code = await ActivationCode.db.findFirstRow(
        session,
        where: (c) =>
            c.codeHash.equals(secretHash(normalizeShortCode(activationCode))),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (code == null) _fail(ActivationFailure.codeInvalid);
      if (code.usedAt != null) _fail(ActivationFailure.codeUsed);
      if (!code.expiresAt.isAfter(now)) _fail(ActivationFailure.codeExpired);
      // Salinan backup membawa tenant yang sama, jadi cek salinan lebih dulu
      // agar pesannya tepat (aturan 10a).
      await _assertNotCopied(session, tx, deviceId);
      if (await Tenant.db.findById(session, tenantId, transaction: tx) !=
          null) {
        _fail(ActivationFailure.tenantActive);
      }
      await Tenant.db.insertRow(
        session,
        Tenant(
          id: tenantId,
          name: tenantName.trim(),
          plan: TenantPlan.hosted,
          hlc: serverSeedHlc,
        ),
        transaction: tx,
      );
      await ActivationCode.db.updateRow(
        session,
        code.copyWith(usedAt: now, tenantId: tenantId),
        transaction: tx,
      );
      await TenantOwner.db.insertRow(
        session,
        TenantOwner(tenantId: tenantId, authUserId: user.authUserId),
        transaction: tx,
      );
      await DeviceCredential.db.insertRow(
        session,
        DeviceCredential(
          tenantId: tenantId,
          deviceId: deviceId,
          tokenHash: secretHash(token),
          createdAt: now,
        ),
        transaction: tx,
      );
    });
    return ActivationResult(
      deviceToken: token,
      tenantId: tenantId,
      deviceId: deviceId,
      deviceCode: deviceCode,
    );
  }

  /// Kode pasang 8 huruf, berlaku [pairingCodeLifetime], dibuat dari
  /// perangkat yang sudah aktif.
  Future<String> createPairingCode(Session session, String deviceToken) async {
    final auth = await authenticateDevice(session, deviceToken);
    final now = DateTime.now().toUtc();
    final code = newShortCode(shortCodeLength);
    await PairingCode.db.insertRow(
      session,
      PairingCode(
        tenantId: auth.tenantId,
        codeHash: secretHash(code),
        createdByDeviceId: auth.deviceId,
        createdAt: now,
        expiresAt: now.add(pairingCodeLifetime),
      ),
    );
    return code;
  }

  /// Cabang aktif tenant kode pasang, urut kode, untuk dipilih perangkat
  /// baru sebelum [joinWithPairingCode]. Kode tidak dipakai di sini.
  Future<List<PairingOutlet>> pairingOutlets(
    Session session,
    String pairingCode,
  ) async {
    final now = DateTime.now().toUtc();
    final pairing = await PairingCode.db.findFirstRow(
      session,
      where: (c) =>
          c.codeHash.equals(secretHash(normalizeShortCode(pairingCode))),
    );
    if (pairing == null) _fail(ActivationFailure.codeInvalid);
    if (pairing.usedAt != null) _fail(ActivationFailure.codeUsed);
    if (!pairing.expiresAt.isAfter(now)) _fail(ActivationFailure.codeExpired);
    final outlets = await Outlet.db.find(
      session,
      where: (o) =>
          o.tenantId.equals(pairing.tenantId) & o.deletedAt.equals(null),
      orderBy: (o) => o.code,
    );
    return [
      for (final o in outlets)
        PairingOutlet(id: o.id!, code: o.code, name: o.name),
    ];
  }

  /// Perangkat baru bergabung ke tenant kode pasang. Server membuat ID
  /// perangkat baru (perangkat hasil salinan backup tidak pernah memakai ID
  /// lama) beserta baris `devices` yang ditarik perangkat lain.
  Future<ActivationResult> joinWithPairingCode(
    Session session,
    String pairingCode,
    UuidValue outletId,
    String deviceCode,
    String deviceName,
    DevicePlatform platform,
  ) async {
    final now = DateTime.now().toUtc();
    final token = newDeviceToken();
    final code = deviceCode.trim().toUpperCase();
    final device = await session.db.transaction((tx) async {
      final pairing = await PairingCode.db.findFirstRow(
        session,
        where: (c) =>
            c.codeHash.equals(secretHash(normalizeShortCode(pairingCode))),
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      if (pairing == null) _fail(ActivationFailure.codeInvalid);
      if (pairing.usedAt != null) _fail(ActivationFailure.codeUsed);
      if (!pairing.expiresAt.isAfter(now)) _fail(ActivationFailure.codeExpired);
      final outlet = await Outlet.db.findById(
        session,
        outletId,
        transaction: tx,
      );
      if (outlet == null || outlet.tenantId != pairing.tenantId) {
        _fail(ActivationFailure.outletUnknown);
      }
      await lockTenantChanges(session, tx, pairing.tenantId);
      final taken = await Device.db.count(
        session,
        where: (d) => d.outletId.equals(outletId) & d.code.equals(code),
        transaction: tx,
      );
      if (taken > 0) _fail(ActivationFailure.deviceCodeTaken);
      final hlc = Hlc(now.millisecondsSinceEpoch, 0, 'server').toString();
      final device = await Device.db.insertRow(
        session,
        Device(
          id: const Uuid().v7obj(),
          tenantId: pairing.tenantId,
          outletId: outletId,
          code: code,
          name: deviceName.trim(),
          platform: platform,
          createdAt: now,
          updatedAt: now,
          hlc: hlc,
        ),
        transaction: tx,
      );
      await SyncChange.db.insertRow(
        session,
        SyncChange(
          tenantId: device.tenantId,
          outletId: outletId,
          entity: 'devices',
          rowId: device.id,
          hlc: hlc,
          payloadJson: SerializationManager.encode(
            device.toJson()..remove('__className__'),
          ),
          receivedAt: now,
        ),
        transaction: tx,
      );
      await PairingCode.db.updateRow(
        session,
        pairing.copyWith(usedAt: now),
        transaction: tx,
      );
      await DeviceCredential.db.insertRow(
        session,
        DeviceCredential(
          tenantId: device.tenantId,
          deviceId: device.id,
          tokenHash: secretHash(token),
          createdAt: now,
        ),
        transaction: tx,
      );
      return device;
    });
    return ActivationResult(
      deviceToken: token,
      tenantId: device.tenantId,
      deviceId: device.id,
      deviceCode: device.code,
    );
  }

  Future<void> _assertNotCopied(
    Session session,
    Transaction tx,
    UuidValue deviceId,
  ) async {
    final active = await DeviceCredential.db.count(
      session,
      where: (c) => c.deviceId.equals(deviceId) & c.revokedAt.equals(null),
      transaction: tx,
    );
    if (active > 0) _fail(ActivationFailure.copiedDevice);
  }

  Never _fail(ActivationFailure reason) =>
      throw ActivationException(reason: reason);
}
