import 'package:lakuna_domain/lakuna_domain.dart'
    show Hlc, newDeviceToken, newShortCode, normalizeShortCode, secretHash;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';
import 'activation.dart';
import 'apply_change.dart' show lockTenantChanges;
import 'device_auth.dart';

/// Batas mengulang aktivasi dengan kode yang sama setelah balasan pertama
/// hilang.
const activationRetryWindow = Duration(minutes: 15);

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
      final usedAt = code.usedAt;
      if (usedAt != null) {
        // Balasan aktivasi hilang (jaringan putus setelah server menyimpan):
        // pemilik yang sama boleh mengulang dengan kode yang sama dari
        // perangkat yang sama dalam [activationRetryWindow]; token lama
        // dicabut.
        if (code.tenantId != tenantId ||
            now.difference(usedAt) > activationRetryWindow ||
            !await _ownsTenant(session, tx, tenantId, user.authUserId)) {
          _fail(ActivationFailure.codeUsed);
        }
        await _reissue(session, tx, tenantId, deviceId, token, now);
        return;
      }
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

  Future<bool> _ownsTenant(
    Session session,
    Transaction tx,
    UuidValue tenantId,
    UuidValue authUserId,
  ) async =>
      await TenantOwner.db.findFirstRow(
        session,
        where: (o) =>
            o.tenantId.equals(tenantId) & o.authUserId.equals(authUserId),
        transaction: tx,
      ) !=
      null;

  Future<void> _reissue(
    Session session,
    Transaction tx,
    UuidValue tenantId,
    UuidValue deviceId,
    String token,
    DateTime now,
  ) async {
    final old = await DeviceCredential.db.find(
      session,
      where: (d) =>
          d.tenantId.equals(tenantId) &
          d.deviceId.equals(deviceId) &
          d.revokedAt.equals(null),
      transaction: tx,
    );
    await DeviceCredential.db.update(session, [
      for (final c in old) c.copyWith(revokedAt: now),
    ], transaction: tx);
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
        PairingOutlet(id: o.id, code: o.code, name: o.name),
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
    final requested = deviceCode.trim().toUpperCase();
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
      // Perangkat web berasal dari cabang tertua tenant (F2-02 aturan 2);
      // cabang lain dipilih di bilah atas web.
      final outlet = platform == DevicePlatform.web
          ? await oldestOutlet(session, tx, pairing.tenantId)
          : await Outlet.db.findById(session, outletId, transaction: tx);
      if (outlet == null || outlet.tenantId != pairing.tenantId) {
        _fail(ActivationFailure.outletUnknown);
      }
      await lockTenantChanges(session, tx, pairing.tenantId);
      final String code;
      if (platform == DevicePlatform.web) {
        // Kode web dibuat server, unik per tenant (F2-02 aturan 2).
        code = await nextWebDeviceCode(session, tx, pairing.tenantId);
      } else {
        if (isWebDeviceCode(requested)) {
          _fail(ActivationFailure.deviceCodeTaken);
        }
        code = requested;
      }
      final taken = await Device.db.count(
        session,
        where: (d) => d.outletId.equals(outlet.id) & d.code.equals(code),
        transaction: tx,
      );
      if (taken > 0) _fail(ActivationFailure.deviceCodeTaken);
      final device = await registerDevice(
        session,
        tx,
        tenantId: pairing.tenantId,
        outletId: outlet.id,
        code: code,
        name: deviceName,
        platform: platform,
        now: now,
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

/// Cabang aktif tertua tenant (dibuat paling awal, lalu ID): asal perangkat
/// web (F2-02 aturan 2).
Future<Outlet?> oldestOutlet(
  Session session,
  Transaction tx,
  UuidValue tenantId,
) => Outlet.db.findFirstRow(
  session,
  where: (o) => o.tenantId.equals(tenantId) & o.deletedAt.equals(null),
  orderByList: (o) => [o.createdAt.asc(), o.id.asc()],
  transaction: tx,
);

/// Baris `devices` baru dengan ID dari server beserta `sync_changes`-nya
/// agar ditarik perangkat lain. Pemanggil memegang [lockTenantChanges] dan
/// sudah memastikan [code] belum dipakai di cabang itu.
Future<Device> registerDevice(
  Session session,
  Transaction tx, {
  required UuidValue tenantId,
  required UuidValue outletId,
  required String code,
  required String name,
  required DevicePlatform platform,
  required DateTime now,
}) async {
  final hlc = Hlc(now.millisecondsSinceEpoch, 0, 'server').toString();
  final device = await Device.db.insertRow(
    session,
    Device(
      id: const Uuid().v7obj(),
      tenantId: tenantId,
      outletId: outletId,
      code: code,
      name: name.trim(),
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
      tenantId: tenantId,
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
  return device;
}

/// Kode `W` + angka dicadangkan untuk perangkat web (F2-02 aturan 2).
bool isWebDeviceCode(String code) => RegExp(r'^W\d+$').hasMatch(code);

/// Kode perangkat web berikutnya di [tenantId]: `W01`, `W02`, … Pemanggil
/// memegang kunci tenant ([lockTenantChanges]) sehingga dua login serentak
/// tidak mendapat kode yang sama.
Future<String> nextWebDeviceCode(
  Session session,
  Transaction tx,
  UuidValue tenantId,
) async {
  final devices = await Device.db.find(
    session,
    where: (d) => d.tenantId.equals(tenantId),
    transaction: tx,
  );
  var highest = 0;
  for (final d in devices) {
    if (!isWebDeviceCode(d.code)) continue;
    final n = int.parse(d.code.substring(1));
    if (n > highest) highest = n;
  }
  return 'W${(highest + 1).toString().padLeft(2, '0')}';
}
