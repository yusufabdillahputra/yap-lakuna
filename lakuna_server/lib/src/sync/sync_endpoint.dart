import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'apply_change.dart';
import 'device_auth.dart';
import 'server_version.dart';

/// Batas entri per `push` (spec F2-01 aturan 1).
const maxPushEntries = 500;

/// Batas perubahan per halaman `pull` (aturan 2).
const pullPageSize = 1000;

/// Push/pull sync perangkat versi hosting (F2-01). Semua panggilan memakai
/// token perangkat, bukan sesi staf.
class SyncEndpoint extends Endpoint {
  /// Menerapkan [entries] (urutan outbox) dalam satu transaksi; setiap
  /// entri punya savepoint sendiri. Hasil per entri urut sama.
  Future<SyncPushReply> push(
    Session session,
    String deviceToken,
    List<SyncPushEntry> entries,
  ) async {
    final auth = await authenticateDevice(session, deviceToken);
    if (entries.length > maxPushEntries) {
      throw SyncRequestException(reason: 'batchTooLarge');
    }
    final now = DateTime.now().toUtc();
    final results = await session.db.transaction((tx) async {
      // Satu penulis log perubahan per tenant pada satu waktu.
      await lockTenantChanges(session, tx, auth.tenantId);
      final out = <SyncPushResult>[];
      final rejected = <UuidValue>{};
      for (final entry in entries) {
        out.add(
          await applyPushEntry(
            session,
            tx,
            auth,
            entry,
            serverNow: now,
            rejectedInBatch: rejected,
          ),
        );
      }
      return out;
    });
    return SyncPushReply(results: results, serverTime: now);
  }

  /// Perubahan tenant token dengan `seq > afterSeq`, maks [pullPageSize].
  /// Perubahan asal perangkat ini dilewati, tetapi kursor tetap maju.
  Future<SyncPullPage> pull(
    Session session,
    String deviceToken,
    int afterSeq,
  ) async {
    final auth = await authenticateDevice(session, deviceToken);
    final rows = await SyncChange.db.find(
      session,
      where: (c) => c.tenantId.equals(auth.tenantId) & (c.id > afterSeq),
      orderBy: (c) => c.id,
      limit: pullPageSize + 1,
    );
    final page = rows.take(pullPageSize).toList();
    final nextSeq = page.isEmpty ? afterSeq : page.last.id!;
    final remaining = rows.length > pullPageSize
        ? await SyncChange.db.count(
            session,
            where: (c) => c.tenantId.equals(auth.tenantId) & (c.id > nextSeq),
          )
        : 0;
    return SyncPullPage(
      changes: [
        for (final c in page)
          if (c.originDeviceId != auth.deviceId)
            SyncPullChange(
              seq: c.id!,
              tableName: c.entity,
              rowId: c.rowId,
              payloadJson: c.payloadJson,
              hlc: c.hlc,
            ),
      ],
      nextSeq: nextSeq,
      hasMore: rows.length > pullPageSize,
      remaining: remaining,
      serverTime: DateTime.now().toUtc(),
    );
  }

  /// Perangkat kasir tenant [deviceToken] (punya kredensial yang belum
  /// dicabut; perangkat web tidak ikut) dengan sync terakhirnya, dan jumlah
  /// konflik yang belum diselesaikan. Untuk dashboard 2.3 (F2-02 tahap 3).
  Future<TenantStatus> tenantStatus(Session session, String deviceToken) async {
    final auth = await authenticateDevice(session, deviceToken);
    final credentials = await DeviceCredential.db.find(
      session,
      where: (c) => c.tenantId.equals(auth.tenantId) & c.revokedAt.equals(null),
    );
    final lastSeen = <UuidValue, DateTime?>{};
    for (final c in credentials) {
      final prev = lastSeen[c.deviceId];
      final seen = c.lastSeenAt;
      lastSeen[c.deviceId] =
          prev == null || (seen != null && seen.isAfter(prev)) ? seen : prev;
    }
    final devices = lastSeen.isEmpty
        ? const <Device>[]
        : await Device.db.find(
            session,
            where: (d) =>
                d.tenantId.equals(auth.tenantId) &
                d.id.inSet(lastSeen.keys.toSet()) &
                d.deletedAt.equals(null) &
                d.platform.notEquals(DevicePlatform.web),
            orderBy: (d) => d.code,
          );
    final conflicts = await SyncConflict.db.count(
      session,
      where: (c) =>
          c.tenantId.equals(auth.tenantId) & c.resolvedAt.equals(null),
    );
    return TenantStatus(
      devices: [
        for (final d in devices)
          DeviceStatus(
            deviceId: d.id,
            outletId: d.outletId,
            code: d.code,
            name: d.name,
            platform: d.platform,
            lastSeenAt: lastSeen[d.id],
          ),
      ],
      openConflicts: conflicts,
      serverTime: DateTime.now().toUtc(),
    );
  }

  /// Versi server dan protokol; `tenantKnown` bila [deviceToken] aktif.
  Future<SyncServerStatus> status(Session session, String? deviceToken) async {
    final credential = deviceToken == null
        ? null
        : await findDeviceCredential(session, deviceToken);
    return SyncServerStatus(
      serverVersion: serverVersion,
      protocolVersion: syncProtocolVersion,
      serverTime: DateTime.now().toUtc(),
      tenantKnown:
          credential != null && !credentialExpired(credential, DateTime.now()),
    );
  }
}
