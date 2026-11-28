import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Menyimpan [bytes] (gambar yang sudah diperiksa, [header]) di folder media
/// [store] dengan nama `<sha256>.<ext>` lalu mencatat barisnya. Berkas yang
/// sama (hash, jenis, dan cabang sama) memakai baris yang sudah ada.
///
/// Metadata (lokasi GPS, model ponsel, XMP, komentar) dibuang lebih dulu
/// tanpa mengubah piksel (F1-07n); hash dan ukuran dihitung dari hasilnya.
Future<MediaFile> storeMediaFile(
  SyncTx w,
  LakunaStore store,
  CatalogScope scope, {
  required Uint8List bytes,
  required ImageHeader header,
  required String fileName,
  required MediaKind kind,
  required SyncStamp stamp,
  UuidValue? outletId,
}) async {
  bytes = stripImageMetadata(bytes);
  final hash = sha256.convert(bytes).toString();
  final existing = await MediaFile.db.findFirstRow(
    w.session,
    where: (m) =>
        m.tenantId.equals(scope.tenantId) &
        m.outletId.equals(outletId) &
        m.sha256.equals(hash) &
        m.kind.equals(kind) &
        m.deletedAt.equals(null),
    transaction: w.transaction,
  );
  final key = '$hash.${header.extension}';
  // Tersemat sampai terunggah (versi hosting di web, F2-02 aturan 8).
  await store.media.write(key, bytes, pinned: true);
  if (existing != null) return existing;
  return w.insert(
    MediaFile(
      tenantId: scope.tenantId,
      outletId: outletId,
      kind: kind,
      fileName: _baseName(fileName),
      mimeType: header.mimeType,
      sizeBytes: bytes.length,
      sha256: hash,
      width: header.width,
      height: header.height,
      storageKey: key,
      createdAt: stamp.now,
      updatedAt: stamp.now,
      createdBy: stamp.actor,
      updatedBy: stamp.actor,
      hlc: stamp.hlc.toString(),
      originDeviceId: stamp.deviceId,
    ),
    stamp,
  );
}

/// Isi berkas [media], `null` bila berkasnya belum ada di perangkat ini
/// (mis. baru tersinkron dari perangkat lain) dan tidak bisa diambil lewat
/// [LakunaStore.fetchMedia] dalam [wait]. Unduhan yang lebih lama tetap
/// berjalan di latar, jadi layar (mis. kasir dengan QRIS) tidak tertahan
/// jaringan lambat dan gambar tampil saat dibuka lagi.
Future<Uint8List?> readMediaFile(
  LakunaStore store,
  MediaFile media, {
  Duration wait = const Duration(seconds: 4),
}) async {
  final local = await store.media.read(media.storageKey);
  if (local != null) return local;
  final fetch = store.fetchMedia;
  if (fetch == null) return null;
  return fetch(media).timeout(wait, onTimeout: () => null);
}

String _baseName(String name) {
  final parts = name.split(RegExp(r'[\\/]'));
  final base = parts.last.trim();
  return base.length > 120 ? base.substring(base.length - 120) : base;
}
