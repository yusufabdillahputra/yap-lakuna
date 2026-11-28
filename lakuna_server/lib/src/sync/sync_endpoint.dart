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
      // Satu push per tenant pada satu waktu: `seq` (bigserial) dibagikan
      // saat sisip tetapi terlihat saat commit, jadi tanpa kunci ini pull
      // bisa melompati seq kecil yang belum di-commit.
      await session.db.unsafeExecute(
        'SELECT pg_advisory_xact_lock(hashtext(@tenant))',
        parameters: QueryParameters.named({'tenant': auth.tenantId.uuid}),
        transaction: tx,
      );
      final out = <SyncPushResult>[];
      for (final entry in entries) {
        out.add(await applyPushEntry(session, tx, auth, entry, serverNow: now));
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
      nextSeq: page.isEmpty ? afterSeq : page.last.id!,
      hasMore: rows.length > pullPageSize,
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
      tenantKnown: credential != null,
    );
  }
}
