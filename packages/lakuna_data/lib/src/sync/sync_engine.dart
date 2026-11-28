/// Siklus sync perangkat versi hosting: push outbox lalu pull perubahan
/// (F2-01 aturan 1–4).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

import '../stock.dart';
import '../store.dart';
import '../sync_state.dart';
import 'apply_incoming.dart';
import 'initial_upload.dart';
import 'sync_rows.dart';
import 'sync_transport.dart';

/// Batas entri per push (aturan 1).
const pushBatchSize = 500;

/// Batas ukuran payload per push (aturan 1).
const pushBatchBytes = 1024 * 1024;

/// Entri `acked` yang lebih tua dari ini dihapus dari outbox.
const ackedRetention = Duration(days: 7);

enum SyncCycleOutcome { synced, offline, attention }

class SyncCycleResult {
  const SyncCycleResult({
    required this.outcome,
    required this.pending,
    required this.conflicts,
    this.at,
    this.error,
  });

  final SyncCycleOutcome outcome;

  /// Entri outbox yang belum terkirim.
  final int pending;

  /// Entri outbox yang ditolak server ditambah perubahan pull yang diparkir.
  final int conflicts;

  /// Waktu sync terakhir yang berhasil.
  final DateTime? at;

  /// Kode galat terakhir (mis. `clock`, `invalidToken`, `network`).
  final String? error;
}

/// Mesin sync satu perangkat. Satu siklus pada satu waktu.
class SyncEngine {
  SyncEngine(
    this.store,
    this.transport, {
    DateTime Function()? clock,
    this.batchSize = pushBatchSize,
  }) : _clock = clock ?? store.now;

  final LakunaStore store;
  final SyncTransport transport;
  final int batchSize;
  final DateTime Function() _clock;
  Future<SyncCycleResult>? _running;

  /// Menjalankan satu siklus; bila siklus lain sedang jalan, menunggu
  /// siklus itu saja.
  Future<SyncCycleResult> runCycle() =>
      _running ??= _cycle().whenComplete(() => _running = null);

  Future<SyncCycleResult> _cycle() async {
    String? error;
    var outcome = SyncCycleOutcome.synced;
    try {
      if (await store.syncState(SyncStateKey.initialUpload) != 'done') {
        final status = await transport.status();
        await prepareInitialUpload(store, serverNow: status.serverTime);
      }
      error = await _push();
      await _pull();
      final now = _clock().toUtc();
      await _write(SyncStateKey.lastSyncAt, now.toIso8601String());
    } on SyncAuthException catch (e) {
      outcome = SyncCycleOutcome.attention;
      error = e.reason;
    } on SyncRequestException catch (e) {
      outcome = SyncCycleOutcome.attention;
      error = e.reason;
    } on Exception {
      outcome = SyncCycleOutcome.offline;
      error = 'network';
    }
    await _write(SyncStateKey.lastError, error ?? '');
    final pending = await SyncOutboxEntry.db.count(
      store.session,
      where: (e) => e.status.equals(OutboxStatus.pending),
    );
    final rejected = await SyncOutboxEntry.db.count(
      store.session,
      where: (e) => e.status.equals(OutboxStatus.conflict),
    );
    final conflicts = rejected + (await _parked()).length;
    if (outcome == SyncCycleOutcome.synced &&
        (conflicts > 0 || error != null)) {
      outcome = SyncCycleOutcome.attention;
    }
    final at = DateTime.tryParse(
      await store.syncState(SyncStateKey.lastSyncAt) ?? '',
    );
    return SyncCycleResult(
      outcome: outcome,
      pending: pending,
      conflicts: conflicts,
      at: at,
      error: error,
    );
  }

  Future<void> _write(SyncStateKey key, String value) =>
      writeSyncState(store.session, key, value);

  /// Push sampai semua entri `pending` (dan entri `dependency` yang dicoba
  /// ulang) terkirim sekali. Mengembalikan `clock` bila ada entri yang
  /// ditolak karena jam.
  Future<String?> _push() async {
    final session = store.session;
    var after = 0;
    String? error;
    while (true) {
      final candidates = await SyncOutboxEntry.db.find(
        session,
        where: (e) =>
            (e.id > after) &
            (e.status.equals(OutboxStatus.pending) |
                (e.status.equals(OutboxStatus.conflict) &
                    e.lastError.equals(SyncRejectReason.dependency.name))),
        orderBy: (e) => e.id,
        limit: batchSize,
      );
      if (candidates.isEmpty) break;
      final batch = <SyncOutboxEntry>[];
      var bytes = 0;
      for (final c in candidates) {
        bytes += c.payloadJson.length;
        if (batch.isNotEmpty && bytes > pushBatchBytes) break;
        batch.add(c);
      }
      final reply = await transport.push([
        for (final e in batch)
          SyncPushEntry(
            tableName: e.entity,
            rowId: e.rowId,
            op: e.op,
            payloadJson: e.payloadJson,
            hlc: e.hlc,
          ),
      ]);
      await session.db.transaction((tx) async {
        for (var i = 0; i < batch.length; i++) {
          final e = batch[i];
          final r = reply.results[i];
          if (r.kind == SyncResultKind.rejected) {
            if (r.reason == SyncRejectReason.clock) error = 'clock';
            await SyncOutboxEntry.db.updateRow(
              session,
              e.copyWith(
                status: OutboxStatus.conflict,
                attempts: e.attempts + 1,
                lastError: r.reason?.name,
              ),
              transaction: tx,
            );
            continue;
          }
          await SyncOutboxEntry.db.updateRow(
            session,
            e.copyWith(status: OutboxStatus.acked, lastError: null),
            transaction: tx,
          );
          final server = r.serverPayloadJson;
          if (server != null) await _takeServerRow(tx, e, server);
        }
        await _receive(tx, reply.serverTime);
      });
      after = batch.last.id!;
    }
    await SyncOutboxEntry.db.deleteWhere(
      session,
      where: (e) =>
          e.status.equals(OutboxStatus.acked) &
          (e.createdAt < _clock().toUtc().subtract(ackedRetention)),
    );
    return error;
  }

  /// Balasan `stale`/`merged`: baris server menimpa baris lokal tanpa
  /// outbox (bila tidak ada versi lokal yang lebih baru). Untuk `settings`
  /// yang digabung ke baris server ber-ID lain, baris lokal dihapus.
  Future<void> _takeServerRow(
    Transaction tx,
    SyncOutboxEntry entry,
    String payload,
  ) async {
    final type = syncRowType(entry.entity);
    if (type == null) return;
    final json = jsonDecode(payload) as Map<String, dynamic>;
    final savepoint = await tx.createSavepoint();
    try {
      if (json['id'] != entry.rowId.uuid) {
        final mine = await type.byId(store.session, tx, entry.rowId);
        if (mine != null) await type.delete(store.session, tx, mine);
      }
      final key = await applyServerRow(store, tx, type, json);
      if (key != null) {
        await rebuildStockLevelsFor(store, {key}, transaction: tx);
      }
      await savepoint.release();
    } on Object {
      await savepoint.rollback();
    }
  }

  Future<void> _receive(Transaction tx, DateTime serverTime) async {
    final session = store.session;
    final last =
        Hlc.tryParse(
          await readSyncState(session, SyncStateKey.lastHlc, transaction: tx) ??
              '',
        ) ??
        Hlc(0, 0, store.deviceId.uuid);
    final next = last.receive(
      Hlc(serverTime.millisecondsSinceEpoch, 0, 'server'),
      _clock().millisecondsSinceEpoch,
    );
    await writeSyncState(
      session,
      SyncStateKey.lastHlc,
      next.toString(),
      transaction: tx,
    );
  }

  Future<List<SyncPullChange>> _parked() async {
    final text = await store.syncState(SyncStateKey.pullParked);
    if (text == null || text.isEmpty) return [];
    return [
      for (final j in jsonDecode(text) as List<dynamic>)
        SyncPullChange.fromJson(j as Map<String, dynamic>),
    ];
  }

  /// Pull sampai habis. Perubahan yang diparkir dicoba lagi setelah halaman
  /// pertama; kursor dan daftar parkir disimpan di transaksi yang sama.
  Future<void> _pull() async {
    final session = store.session;
    var parked = await _parked();
    var first = true;
    while (true) {
      final cursor =
          int.tryParse(await store.syncState(SyncStateKey.pullCursor) ?? '') ??
          0;
      final page = await transport.pull(cursor);
      await session.db.transaction((tx) async {
        final fresh = await applyIncoming(store, tx, page.changes);
        var failed = fresh.failed;
        final touched = {...fresh.touchedStock};
        if (first && parked.isNotEmpty) {
          final retry = await applyIncoming(store, tx, parked);
          failed = [...failed, ...retry.failed];
          touched.addAll(retry.touchedStock);
        }
        // Induk bisa datang setelah anaknya di daftar yang sama.
        while (failed.isNotEmpty) {
          final again = await applyIncoming(store, tx, failed);
          touched.addAll(again.touchedStock);
          if (again.failed.length == failed.length) break;
          failed = again.failed;
        }
        await rebuildStockLevelsFor(store, touched, transaction: tx);
        await writeSyncState(
          session,
          SyncStateKey.pullParked,
          failed.isEmpty
              ? ''
              : jsonEncode([for (final c in failed) c.toJson()]),
          transaction: tx,
        );
        await writeSyncState(
          session,
          SyncStateKey.pullCursor,
          '${page.nextSeq}',
          transaction: tx,
        );
        await _receive(tx, page.serverTime);
        parked = failed;
      });
      first = false;
      if (!page.hasMore) break;
    }
  }
}

/// Penjadwal siklus: 2 detik setelah tulis terakhir, setiap 30 detik, dan
/// backoff eksponensial sampai 5 menit saat offline (aturan 4).
class SyncScheduler {
  SyncScheduler(
    this.run, {
    this.debounce = const Duration(seconds: 2),
    this.interval = const Duration(seconds: 30),
    this.maxBackoff = const Duration(minutes: 5),
    this.onResult,
  });

  final Future<SyncCycleResult> Function() run;
  final Duration debounce;
  final Duration interval;
  final Duration maxBackoff;
  final void Function(SyncCycleResult result)? onResult;

  Timer? _timer;
  bool _started = false;
  bool _running = false;
  bool _again = false;
  int _failures = 0;

  bool get isRunning => _running;

  void start() {
    _started = true;
    _schedule(Duration.zero);
  }

  void stop() {
    _started = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Dipanggil setelah setiap tulis data bisnis.
  void notifyWrite() {
    if (!_started) return;
    if (_running) {
      _again = true;
      return;
    }
    _schedule(debounce);
  }

  /// *Sync sekarang* dan saat aplikasi kembali ke depan.
  void syncNow() {
    if (!_started) return;
    if (_running) {
      _again = true;
      return;
    }
    _schedule(Duration.zero);
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _tick);
  }

  Future<void> _tick() async {
    if (!_started || _running) return;
    _running = true;
    _again = false;
    SyncCycleResult? result;
    try {
      result = await run();
    } finally {
      _running = false;
    }
    onResult?.call(result);
    if (!_started) return;
    if (result.outcome == SyncCycleOutcome.offline) {
      _failures++;
      final seconds = math.min(
        maxBackoff.inSeconds,
        5 * math.pow(2, _failures - 1).toInt(),
      );
      _schedule(Duration(seconds: seconds));
    } else {
      _failures = 0;
      _schedule(_again ? debounce : interval);
    }
  }
}
