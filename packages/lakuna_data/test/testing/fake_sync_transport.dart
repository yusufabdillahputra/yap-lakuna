import 'dart:convert';
import 'dart:io';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

/// Server sync palsu di memori untuk tes mesin sync.
class FakeSyncTransport implements SyncTransport {
  FakeSyncTransport({required this.serverTime});

  DateTime serverTime;

  /// Bila `true`, setiap panggilan melempar [SocketException].
  bool offline = false;

  /// Hasil per entri; bawaan `applied`.
  SyncPushResult Function(SyncPushEntry entry)? onPush;

  /// Semua batch yang pernah di-push, urut.
  final pushed = <List<SyncPushEntry>>[];

  /// Log perubahan server (urut `seq`).
  final changes = <SyncPullChange>[];

  int pageSize = 1000;
  int pulls = 0;

  void _check() {
    if (offline) throw const SocketException('tidak ada jaringan');
  }

  @override
  Future<SyncPushReply> push(List<SyncPushEntry> entries) async {
    _check();
    pushed.add(entries);
    return SyncPushReply(
      results: [
        for (final e in entries)
          onPush?.call(e) ??
              SyncPushResult(
                rowId: e.rowId,
                hlc: e.hlc,
                kind: SyncResultKind.applied,
              ),
      ],
      serverTime: serverTime,
    );
  }

  @override
  Future<SyncPullPage> pull(int afterSeq) async {
    _check();
    pulls++;
    final rest = changes.where((c) => c.seq > afterSeq).toList();
    final page = rest.take(pageSize).toList();
    return SyncPullPage(
      changes: page,
      nextSeq: page.isEmpty ? afterSeq : page.last.seq,
      hasMore: rest.length > pageSize,
      serverTime: serverTime,
    );
  }

  /// Balasan [tenantStatus].
  TenantStatus? tenant;

  @override
  Future<TenantStatus> tenantStatus() async {
    _check();
    return tenant ??
        TenantStatus(devices: [], openConflicts: 0, serverTime: serverTime);
  }

  @override
  Future<SyncServerStatus> status() async {
    _check();
    return SyncServerStatus(
      serverVersion: '0.165.0',
      protocolVersion: 1,
      serverTime: serverTime,
      tenantKnown: true,
    );
  }

  /// Menambah [payload] ke log server sebagai perubahan berikutnya.
  void addChange(String table, Map<String, dynamic> payload) {
    changes.add(
      SyncPullChange(
        seq: changes.isEmpty ? 1 : changes.last.seq + 1,
        tableName: table,
        rowId: UuidValue.fromString(payload['id'] as String),
        payloadJson: jsonEncodeRow(payload),
        hlc: payload['hlc'] as String,
      ),
    );
  }
}

String jsonEncodeRow(Map<String, dynamic> payload) =>
    const JsonEncoder().convert(payload);
