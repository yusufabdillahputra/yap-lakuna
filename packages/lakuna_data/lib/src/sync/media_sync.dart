/// Berkas media versi hosting (F2-01 aturan 19–20): unggah berkas yang
/// dibuat di perangkat ini setelah barisnya di-push, dan unduh berkas
/// perangkat lain saat pertama dibutuhkan.
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:lakuna_client/lakuna_client.dart';

import '../store.dart';
import '../sync_state.dart';
import 'sync_engine.dart' show isOfflineError;

/// Endpoint media server untuk satu perangkat (token di dalamnya).
abstract interface class MediaTransport {
  /// Deskripsi unggah, atau `null` bila berkas dengan kunci yang sama sudah
  /// ada di server. Baris yang belum di-push melempar
  /// [SyncRequestException] `mediaUnknown`.
  Future<String?> uploadDescription(UuidValue mediaFileId);

  /// Mengunggah [bytes] sesuai [description]; gagal melempar.
  Future<void> upload(String description, Uint8List bytes);

  Future<bool> markUploaded(UuidValue mediaFileId);

  /// URL unduh sementara, `null` bila berkas belum diunggah.
  Future<Uri?> downloadUrl(UuidValue mediaFileId);

  Future<Uint8List> download(Uri url);
}

/// Batas waktu satu unggahan atau unduhan berkas (koneksi macet dianggap
/// offline).
const mediaTransferTimeout = Duration(minutes: 2);

/// Jumlah baris `media_files` yang diperiksa per kueri.
const _uploadBatch = 50;

enum _Upload { done, offline, failed }

/// Mengunggah berkas media lokal yang barisnya sudah di-push, urut
/// masuknya baris ke database perangkat ini (`rowid`), bukan urut ID:
/// ID baris dari perangkat lain bisa lebih besar karena jam perangkat
/// berbeda. Baris yang ditolak (belum di-push, server menolak) dicatat dan
/// dicoba lagi tiap siklus tanpa menahan berkas sesudahnya; jaringan putus
/// menghentikan unggahan sampai siklus berikutnya. Tidak pernah melempar.
Future<void> uploadPendingMedia(
  LakunaStore store,
  MediaTransport transport, {
  Duration transferTimeout = mediaTransferTimeout,
}) async {
  final session = store.session;
  final retry = (await store.syncState(SyncStateKey.mediaUploadRetry) ?? '')
      .split(',')
      .where((id) => id.isNotEmpty)
      .toList();
  final failed = <String>[];

  Future<void> saveRetry([Iterable<String> rest = const []]) => writeSyncState(
    session,
    SyncStateKey.mediaUploadRetry,
    {...failed, ...rest}.join(','),
  );

  for (var i = 0; i < retry.length; i++) {
    final id = UuidValue.withValidation(retry[i]);
    final media = await MediaFile.db.findById(session, id);
    if (media == null) continue;
    switch (await _uploadOne(store, transport, media, transferTimeout)) {
      case _Upload.done:
        break;
      case _Upload.failed:
        failed.add(retry[i]);
      case _Upload.offline:
        await saveRetry(retry.skip(i));
        return;
    }
  }

  var cursor =
      int.tryParse(
        await store.syncState(SyncStateKey.mediaUploadCursor) ?? '',
      ) ??
      0;
  while (true) {
    final rows = await session.db.unsafeQuery(
      'SELECT rowid, id FROM media_files WHERE rowid > $cursor '
      'ORDER BY rowid LIMIT $_uploadBatch',
    );
    if (rows.isEmpty) break;
    for (final r in rows) {
      final rowid = r[0]! as int;
      final id = UuidValue.fromByteList(r[1]! as Uint8List);
      final media = await MediaFile.db.findById(session, id);
      if (media != null) {
        switch (await _uploadOne(store, transport, media, transferTimeout)) {
          case _Upload.done:
            break;
          case _Upload.failed:
            failed.add(id.uuid);
          case _Upload.offline:
            await saveRetry();
            return;
        }
      }
      cursor = rowid;
      await writeSyncState(session, SyncStateKey.mediaUploadCursor, '$cursor');
    }
  }
  await saveRetry();
}

Future<_Upload> _uploadOne(
  LakunaStore store,
  MediaTransport transport,
  MediaFile media,
  Duration timeout,
) async {
  final bytes = await store.media.read(media.storageKey);
  // Berkas dari perangkat lain yang belum diunduh tidak perlu diunggah.
  if (bytes == null) return _Upload.done;
  try {
    final description = await transport
        .uploadDescription(media.id)
        .timeout(timeout);
    if (description == null) return _Upload.done;
    await transport.upload(description, bytes).timeout(timeout);
    if (!await transport.markUploaded(media.id).timeout(timeout)) {
      return _Upload.failed;
    }
    await store.media.unpin(media.storageKey);
    return _Upload.done;
  } on Object catch (e) {
    return isOfflineError(e) ? _Upload.offline : _Upload.failed;
  }
}

/// Isi berkas [media]: dari folder media, atau diunduh dari server lalu
/// disimpan bila hash cocok. `null` (placeholder) bila belum diunggah,
/// offline, macet lebih dari [transferTimeout], atau unduhan rusak.
Future<Uint8List?> ensureMediaLocal(
  LakunaStore store,
  MediaTransport transport,
  MediaFile media, {
  Duration transferTimeout = mediaTransferTimeout,
}) async {
  final local = await store.media.read(media.storageKey);
  if (local != null) return local;
  try {
    final url = await transport.downloadUrl(media.id).timeout(transferTimeout);
    if (url == null) return null;
    final bytes = await transport.download(url).timeout(transferTimeout);
    if (sha256.convert(bytes).toString() != media.sha256) return null;
    await store.media.write(media.storageKey, bytes);
    return bytes;
  } on Object {
    return null;
  }
}

/// Pengambil gambar untuk [LakunaStore.fetchMedia]: satu unduhan per
/// gambar walau diminta banyak layar sekaligus, paling banyak
/// [maxConcurrent] unduhan bersamaan, dan gambar yang gagal tidak diminta
/// lagi sebelum [retryAfter] lewat.
class MediaFetcher {
  MediaFetcher(
    this._store,
    this._transport, {
    this.maxConcurrent = 3,
    this.retryAfter = const Duration(minutes: 2),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final LakunaStore _store;
  final MediaTransport _transport;
  final int maxConcurrent;
  final Duration retryAfter;
  final DateTime Function() _clock;

  final _inFlight = <String, Future<Uint8List?>>{};
  final _failedAt = <String, DateTime>{};
  final _waiting = <Completer<void>>[];
  var _running = 0;

  Future<Uint8List?> fetch(MediaFile media) {
    final key = media.storageKey;
    final running = _inFlight[key];
    if (running != null) return running;
    final failed = _failedAt[key];
    if (failed != null && _clock().difference(failed) < retryAfter) {
      return Future.value();
    }
    // Kurung kurawal: `remove` mengembalikan future ini sendiri, dan
    // whenComplete akan menunggunya.
    final future = _run(media).whenComplete(() {
      _inFlight.remove(key);
    });
    return _inFlight[key] = future;
  }

  Future<Uint8List?> _run(MediaFile media) async {
    if (_running >= maxConcurrent) {
      final slot = Completer<void>();
      _waiting.add(slot);
      await slot.future;
    }
    _running++;
    try {
      final bytes = await ensureMediaLocal(_store, _transport, media);
      if (bytes == null) {
        _failedAt[media.storageKey] = _clock();
      } else {
        _failedAt.remove(media.storageKey);
      }
      return bytes;
    } finally {
      _running--;
      if (_waiting.isNotEmpty) _waiting.removeAt(0).complete();
    }
  }
}
