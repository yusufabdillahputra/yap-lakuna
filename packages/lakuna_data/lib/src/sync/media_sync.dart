/// Berkas media versi hosting (F2-01 aturan 19–20): unggah berkas yang
/// dibuat di perangkat ini setelah barisnya di-push, dan unduh berkas
/// perangkat lain saat pertama dibutuhkan.
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:lakuna_client/lakuna_client.dart';

import '../store.dart';
import '../sync_state.dart';

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

/// Mengunggah berkas media lokal urut ID mulai setelah kursor. Berhenti
/// (tanpa melempar) di berkas pertama yang belum bisa diunggah: barisnya
/// belum di-push, jaringan putus, atau server menolak; siklus berikutnya
/// mencoba lagi dari sana.
Future<void> uploadPendingMedia(
  LakunaStore store,
  MediaTransport transport,
) async {
  final cursor = await store.syncState(SyncStateKey.mediaUploadCursor) ?? '';
  final rows = await MediaFile.db.find(store.session);
  // UUID v7 urut waktu dalam bentuk teks.
  final pending = rows.where((m) => m.id.uuid.compareTo(cursor) > 0).toList()
    ..sort((a, b) => a.id.uuid.compareTo(b.id.uuid));
  for (final media in pending) {
    final file = _localFile(store, media);
    if (file.existsSync()) {
      try {
        final description = await transport.uploadDescription(media.id);
        if (description != null) {
          await transport.upload(description, await file.readAsBytes());
          if (!await transport.markUploaded(media.id)) return;
        }
      } on Exception {
        return;
      }
    }
    // Berkas dari perangkat lain yang belum diunduh tidak perlu diunggah.
    await writeSyncState(
      store.session,
      SyncStateKey.mediaUploadCursor,
      media.id.uuid,
    );
  }
}

/// Isi berkas [media]: dari folder media, atau diunduh dari server lalu
/// disimpan bila hash cocok. `null` (placeholder) bila belum diunggah,
/// offline, atau unduhan rusak.
Future<Uint8List?> ensureMediaLocal(
  LakunaStore store,
  MediaTransport transport,
  MediaFile media,
) async {
  final file = _localFile(store, media);
  if (file.existsSync()) return file.readAsBytes();
  try {
    final url = await transport.downloadUrl(media.id);
    if (url == null) return null;
    final bytes = await transport.download(url);
    if (sha256.convert(bytes).toString() != media.sha256) return null;
    await file.parent.create(recursive: true);
    // Nama sementara unik: gambar yang sama bisa diminta dua kali bersamaan.
    final tmp = File(
      '${file.path}.${DateTime.now().microsecondsSinceEpoch}.unduh',
    );
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(file.path);
    return bytes;
  } on Exception {
    return null;
  }
}

File _localFile(LakunaStore store, MediaFile media) =>
    File('${store.mediaDirectory}${Platform.pathSeparator}${media.storageKey}');
