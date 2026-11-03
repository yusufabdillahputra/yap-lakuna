import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import 'store.dart';

/// Toko yang sedang dipakai perangkat ini: tenant, cabang, perangkat, dan
/// pemilik. Semua query modul dibatasi `tenant.id` / `outlet.id` dari sini.
class StoreContext {
  const StoreContext({
    required this.tenant,
    required this.outlet,
    required this.device,
    required this.owner,
  });

  final Tenant tenant;
  final Outlet outlet;
  final Device device;
  final StaffMember owner;
}

/// Hash Argon2id kata sandi dan PIN pemilik (dibuat pemanggil, sebaiknya di
/// isolate terpisah).
class SetupCredentials {
  const SetupCredentials({required this.pinHash, required this.passwordHash});

  final String pinHash;
  final String passwordHash;
}

/// Setup ditolak karena perangkat ini sudah punya tenant.
class SetupAlreadyDone implements Exception {
  @override
  String toString() => 'SetupAlreadyDone: perangkat ini sudah punya toko.';
}

/// Setup ditolak karena input tidak lolos [SetupInput.validate].
class SetupInvalid implements Exception {
  SetupInvalid(this.errors);

  final Map<SetupField, SetupError> errors;

  @override
  String toString() => 'SetupInvalid: $errors';
}

/// Nama lokasi stok bawaan yang dibuat saat setup.
const defaultStockLocationName = 'Etalase';

/// Memuat konteks toko, atau `null` bila setup belum dilakukan.
Future<StoreContext?> loadStoreContext(LakunaStore store) async {
  final session = store.session;
  final tenant = await Tenant.db.findFirstRow(
    session,
    where: (t) => t.deletedAt.equals(null),
    orderBy: (t) => t.createdAt,
  );
  if (tenant == null) return null;
  final device = await Device.db.findById(session, store.deviceId);
  if (device == null || device.tenantId != tenant.id) return null;
  final outlet = await Outlet.db.findById(session, device.outletId);
  final owner = await StaffMember.db.findFirstRow(
    session,
    where: (s) =>
        s.tenantId.equals(tenant.id) &
        s.isOwner.equals(true) &
        s.deletedAt.equals(null),
    orderBy: (s) => s.createdAt,
  );
  if (outlet == null || owner == null) return null;
  return StoreContext(
    tenant: tenant,
    outlet: outlet,
    device: device,
    owner: owner,
  );
}

/// Setup toko pertama (F1-01) dalam satu transaksi: tenant, cabang,
/// perangkat ini, lokasi stok "Etalase", pemilik, dan keanggotaan pemilik di
/// cabang dengan role `owner`. Semua baris tercatat di outbox dengan aktor
/// pemilik.
///
/// Melempar [SetupInvalid] bila input tidak valid dan [SetupAlreadyDone]
/// bila perangkat sudah punya tenant; keduanya sebelum menulis apa pun.
Future<StoreContext> setupStore(
  LakunaStore store,
  SetupInput input, {
  required DevicePlatform platform,
  required SetupCredentials credentials,
}) async {
  final errors = input.validate();
  if (errors.isNotEmpty) throw SetupInvalid(errors);

  final ownerId = UuidValue.fromString(newId());
  return store.write(actor: ownerId, (w) async {
    final existing = await Tenant.db.count(
      w.session,
      where: (t) => t.deletedAt.equals(null),
      transaction: w.transaction,
    );
    if (existing > 0) throw SetupAlreadyDone();

    final s = await w.stamp();
    final hlc = s.hlc.toString();
    final tenant = await w.insert(
      Tenant(
        name: input.businessName,
        businessType: BusinessType.values.byName(input.businessType.name),
        timezone: input.timezone,
        createdBy: ownerId,
        updatedBy: ownerId,
        hlc: hlc,
        originDeviceId: s.deviceId,
      ),
      s,
    );
    final outlet = await w.insert(
      Outlet(
        tenantId: tenant.id,
        code: input.outletCode,
        name: input.outletName,
        timezone: input.timezone,
        createdBy: ownerId,
        updatedBy: ownerId,
        hlc: hlc,
        originDeviceId: s.deviceId,
      ),
      s,
    );
    final device = await w.insert(
      Device(
        id: store.deviceId,
        tenantId: tenant.id,
        outletId: outlet.id,
        code: input.deviceCode,
        name: 'Perangkat ${input.deviceCode}',
        platform: platform,
        createdBy: ownerId,
        updatedBy: ownerId,
        hlc: hlc,
        originDeviceId: s.deviceId,
      ),
      s,
    );
    await w.insert(
      StockLocation(
        tenantId: tenant.id,
        outletId: outlet.id,
        name: defaultStockLocationName,
        isDefault: true,
        createdBy: ownerId,
        updatedBy: ownerId,
        hlc: hlc,
        originDeviceId: s.deviceId,
      ),
      s,
    );
    final owner = await w.insert(
      StaffMember(
        id: ownerId,
        tenantId: tenant.id,
        name: input.ownerName,
        email: input.email,
        pinHash: credentials.pinHash,
        passwordHash: credentials.passwordHash,
        isOwner: true,
        createdBy: ownerId,
        updatedBy: ownerId,
        hlc: hlc,
        originDeviceId: s.deviceId,
      ),
      s,
    );
    await w.insert(
      OutletMember(
        tenantId: tenant.id,
        outletId: outlet.id,
        staffMemberId: ownerId,
        roleName: DefaultRole.owner.key,
        createdBy: ownerId,
        updatedBy: ownerId,
        hlc: hlc,
        originDeviceId: s.deviceId,
      ),
      s,
    );
    return StoreContext(
      tenant: tenant,
      outlet: outlet,
      device: device,
      owner: owner,
    );
  });
}
