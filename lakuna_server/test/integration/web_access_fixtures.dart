import 'package:lakuna_domain/lakuna_domain.dart'
    show base32Decode, totpCode, totpStep;
import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:lakuna_server/src/web_access/totp_cipher.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart' show AuthUser;
import 'package:serverpod_auth_idp_server/providers/email.dart'
    show EmailAccount;

const ownerId = '01900000-0000-7000-8000-00000000ff01';
const strangerId = '01900000-0000-7000-8000-00000000ff02';
const ownerEmail = 'sari@contoh.id';
final tenantId = UuidValue.fromString('01900000-0000-7000-8000-000000000001');
final otherTenantId = UuidValue.fromString(
  '01900000-0000-7000-8000-000000000002',
);
final outletId = UuidValue.fromString('01900000-0000-7000-8000-000000000010');
final newerOutletId = UuidValue.fromString(
  '01900000-0000-7000-8000-000000000011',
);
const seedHlc = '0000000000000-0000-seed';

/// Kunci enkripsi TOTP untuk tes (kata sandi server diubah di memori).
void setTotpKey(Session session, String? value) {
  if (value == null) {
    session.passwords.remove(totpEncryptionKeyName);
  } else {
    session.passwords[totpEncryptionKeyName] = value;
  }
}

/// Akun pemilik [ownerId] dengan email, tenant hosted dengan dua cabang
/// (cabang [outletId] lebih tua), dan akun [strangerId] tanpa tenant.
Future<void> seedOwner(Session session) async {
  for (final (id, email) in [(ownerId, ownerEmail), (strangerId, 'x@y.id')]) {
    final userId = UuidValue.fromString(id);
    await AuthUser.db.insertRow(
      session,
      AuthUser(id: userId, scopeNames: {}),
    );
    await EmailAccount.db.insertRow(
      session,
      EmailAccount(authUserId: userId, email: email, passwordHash: 'x'),
    );
  }
  for (final (id, name) in [(tenantId, 'Toko Maju'), (otherTenantId, 'Lain')]) {
    await Tenant.db.insertRow(
      session,
      Tenant(id: id, name: name, plan: TenantPlan.hosted, hlc: seedHlc),
    );
  }
  final now = DateTime.now().toUtc();
  for (final (id, code, created) in [
    (outletId, 'PST', now.subtract(const Duration(days: 30))),
    (newerOutletId, 'AAA', now),
  ]) {
    await Outlet.db.insertRow(
      session,
      Outlet(
        id: id,
        tenantId: tenantId,
        code: code,
        name: code,
        hlc: seedHlc,
        createdAt: created,
      ),
    );
  }
  await TenantOwner.db.insertRow(
    session,
    TenantOwner(tenantId: tenantId, authUserId: UuidValue.fromString(ownerId)),
  );
}

/// Kode TOTP rahasia [secretBase32] untuk langkah sekarang + [offset].
String codeFor(String secretBase32, {int offset = 0}) => totpCode(
  base32Decode(secretBase32)!,
  totpStep(DateTime.now().toUtc()) + offset,
);

/// Kode 6 digit yang pasti salah untuk [secretBase32] (±1 langkah).
String wrongCode(String secretBase32) {
  final valid = {
    for (final o in [-1, 0, 1]) codeFor(secretBase32, offset: o),
  };
  for (var i = 0; ; i++) {
    final c = i.toString().padLeft(6, '0');
    if (!valid.contains(c)) return c;
  }
}
