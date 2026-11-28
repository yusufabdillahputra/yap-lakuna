/// Versi hosting di perangkat: aktivasi dan gabung (F2-01 aturan 9–14).
library;

import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';

import 'store.dart';
import 'sync_state.dart';

/// Mengubah `tenants.plan` menjadi `hosted` lewat outbox (aturan 14),
/// sebelum unggah data awal agar LWW di server tidak mengembalikan `free`.
Future<Tenant> markTenantHosted(
  LakunaStore store, {
  required UuidValue staffId,
}) => store.write(actor: staffId, (w) async {
  final tenant = (await Tenant.db.findFirstRow(
    w.session,
    where: (t) => t.deletedAt.equals(null),
    orderBy: (t) => t.createdAt,
    transaction: w.transaction,
  ))!;
  if (tenant.plan == TenantPlan.hosted) return tenant;
  final s = await w.stamp();
  return w.update(
    tenant.copyWith(
      plan: TenantPlan.hosted,
      version: tenant.version + 1,
      updatedAt: s.now,
      updatedBy: staffId,
      hlc: s.hlc.toString(),
      originDeviceId: s.deviceId,
    ),
    s,
  );
});

/// Membuat database baru di [path] untuk perangkat yang bergabung lewat
/// kode pasang: ID perangkat dari server (aturan 10a) dan tanpa unggah
/// data awal, karena datanya ditarik dari server. Melempar [StateError]
/// bila berkas sudah ada.
Future<LakunaStore> openJoinedStore(
  String path, {
  required UuidValue deviceId,
  DateTime Function()? clock,
}) async {
  final file = File(path);
  if (file.existsSync()) {
    throw StateError('Database sudah ada: $path');
  }
  await file.parent.create(recursive: true);
  final first = await LakunaStore.open(path, clock: clock);
  await first.session.db.transaction((tx) async {
    await writeSyncState(
      first.session,
      SyncStateKey.deviceId,
      deviceId.uuid,
      transaction: tx,
    );
    await writeSyncState(
      first.session,
      SyncStateKey.initialUpload,
      'done',
      transaction: tx,
    );
  });
  await first.close();
  return LakunaStore.open(path, clock: clock);
}
