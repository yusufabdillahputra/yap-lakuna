import 'package:lakuna_domain/lakuna_domain.dart'
    show newDeviceToken, secretHash;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart'
    show AuthenticationInfoAuthUserId;

import '../generated/protocol.dart';
import '../sync/activation_endpoint.dart'
    show nextWebDeviceCode, oldestOutlet, registerDevice;
import '../sync/apply_change.dart' show lockTenantChanges;
import '../sync/device_auth.dart' show authenticateDevice, findDeviceCredential;
import 'owner_totp_check.dart';

/// Umur token web bila *Ingat saya di browser ini* dicentang (aturan 11).
const webTokenRemembered = Duration(days: 30);

/// Umur token web tanpa *Ingat saya*.
const webTokenSession = Duration(hours: 12);

/// Login web pemilik (F2-02 aturan 11–13a): akun email + kata sandi (JWT
/// Serverpod), lalu kode TOTP atau kode cadangan membuat perangkat web
/// tenant dengan token berumur.
///
/// Tidak memakai `requireLogin` karena [logout] dipanggil dengan token
/// perangkat saja; [tenants] dan [open] memeriksa login sendiri.
class WebAccessEndpoint extends Endpoint {
  /// Toko milik akun yang sedang login. Melempar `noTenant` bila tidak ada
  /// dan `totpNotEnabled` bila verifikasi 2 langkah belum aktif.
  Future<List<WebTenant>> tenants(Session session) async {
    final user = _user(session);
    final owned = await _ownedTenants(session, user);
    if (owned.isEmpty) {
      throw WebAccessException(failure: WebAccessFailure.noTenant);
    }
    final totp = await OwnerTotp.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(user),
    );
    if (totp?.confirmedAt == null) {
      throw WebAccessException(failure: WebAccessFailure.totpNotEnabled);
    }
    return [for (final t in owned) WebTenant(tenantId: t.id, name: t.name)];
  }

  /// Memverifikasi [code] lalu mendaftarkan perangkat web baru tenant
  /// [tenantId] di cabang tertua, kode `W..`, token berlaku
  /// [webTokenRemembered] atau [webTokenSession].
  Future<WebAccessResult> open(
    Session session,
    String code,
    UuidValue tenantId,
    bool remember,
  ) async {
    final user = _user(session);
    final owned = await _ownedTenants(session, user);
    if (!owned.any((t) => t.id == tenantId)) {
      throw WebAccessException(failure: WebAccessFailure.noTenant);
    }
    final now = DateTime.now().toUtc();
    final token = newDeviceToken();
    final expiresAt = now.add(remember ? webTokenRemembered : webTokenSession);
    final device = await withOwnerSecondFactor(
      session,
      user,
      code,
      cipher: requireTotpCipher(session),
      now: now,
      onVerified: (tx) async {
        await lockTenantChanges(session, tx, tenantId);
        final outlet = await oldestOutlet(session, tx, tenantId);
        if (outlet == null) {
          throw WebAccessException(failure: WebAccessFailure.noTenant);
        }
        final device = await registerDevice(
          session,
          tx,
          tenantId: tenantId,
          outletId: outlet.id,
          code: await nextWebDeviceCode(session, tx, tenantId),
          name: 'Browser',
          platform: DevicePlatform.web,
          now: now,
        );
        await DeviceCredential.db.insertRow(
          session,
          DeviceCredential(
            tenantId: tenantId,
            deviceId: device.id,
            tokenHash: secretHash(token),
            createdAt: now,
            expiresAt: expiresAt,
          ),
          transaction: tx,
        );
        return device;
      },
    );
    return WebAccessResult(
      deviceToken: token,
      tenantId: tenantId,
      deviceId: device.id,
      deviceCode: device.code,
      outletId: device.outletId,
      expiresAt: expiresAt,
    );
  }

  /// Mencabut token web [deviceToken] (menu *Keluar*). Token perangkat
  /// biasa (tanpa batas berlaku) tidak bisa dicabut dari sini.
  Future<void> logout(Session session, String deviceToken) async {
    final credential = await findDeviceCredential(session, deviceToken);
    if (credential == null || credential.expiresAt == null) return;
    await DeviceCredential.db.updateRow(
      session,
      credential.copyWith(revokedAt: DateTime.now().toUtc()),
    );
  }

  /// `true` bila pemilik tenant perangkat [deviceToken] sudah mengaktifkan
  /// verifikasi 2 langkah (baris di kartu *Versi hosting*).
  Future<bool> twoFactorEnabled(Session session, String deviceToken) async {
    final auth = await authenticateDevice(session, deviceToken);
    final owners = await TenantOwner.db.find(
      session,
      where: (o) => o.tenantId.equals(auth.tenantId),
    );
    if (owners.isEmpty) return false;
    final enabled = await OwnerTotp.db.count(
      session,
      where: (t) =>
          t.authUserId.inSet({for (final o in owners) o.authUserId}) &
          t.confirmedAt.notEquals(null),
    );
    return enabled > 0;
  }

  UuidValue _user(Session session) =>
      session.authenticated?.authUserId ??
      (throw WebAccessException(failure: WebAccessFailure.sessionExpired));

  Future<List<Tenant>> _ownedTenants(Session session, UuidValue user) async {
    final owners = await TenantOwner.db.find(
      session,
      where: (o) => o.authUserId.equals(user),
    );
    if (owners.isEmpty) return const [];
    return Tenant.db.find(
      session,
      where: (t) =>
          t.id.inSet({for (final o in owners) o.tenantId}) &
          t.deletedAt.equals(null),
      orderBy: (t) => t.name,
    );
  }
}
