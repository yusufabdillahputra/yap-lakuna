import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../sync/device_auth.dart';

/// Penyimpanan berkas media versi hosting (F2-01 aturan 19–20).
const mediaStorageId = 'private';

/// Berkas media di object storage dengan kunci
/// `<tenant_id>/<storage_key>`. Baris `media_files` harus sudah di-push
/// lebih dulu; berkas dengan hash sama di tenant yang sama hanya diunggah
/// sekali.
class MediaSyncEndpoint extends Endpoint {
  /// Deskripsi unggah untuk `FileUploader`, atau `null` bila berkasnya
  /// sudah ada di storage.
  Future<String?> uploadDescription(
    Session session,
    String deviceToken,
    UuidValue mediaFileId,
  ) async {
    final media = await _media(session, deviceToken, mediaFileId);
    final path = mediaPath(media);
    if (await session.storage.fileExists(
      storageId: mediaStorageId,
      path: path,
    )) {
      return null;
    }
    return session.storage.createUploadDescription(
      storageId: mediaStorageId,
      path: path,
      options: UploadOptions(contentLength: media.sizeBytes),
    );
  }

  /// Dipanggil setelah unggah selesai; `true` bila berkas ada di storage.
  Future<bool> markUploaded(
    Session session,
    String deviceToken,
    UuidValue mediaFileId,
  ) async {
    final media = await _media(session, deviceToken, mediaFileId);
    final path = mediaPath(media);
    // Berkas yang sudah terverifikasi (unggahan sebelumnya atau hash sama)
    // juga dihitung terunggah.
    return await session.storage.verifyUpload(
          storageId: mediaStorageId,
          path: path,
        ) ||
        await session.storage.fileExists(storageId: mediaStorageId, path: path);
  }

  /// URL unduh sementara, atau `null` bila berkas belum diunggah perangkat
  /// asalnya.
  Future<Uri?> downloadUrl(
    Session session,
    String deviceToken,
    UuidValue mediaFileId,
  ) async {
    final media = await _media(session, deviceToken, mediaFileId);
    final path = mediaPath(media);
    if (!await session.storage.fileExists(
      storageId: mediaStorageId,
      path: path,
    )) {
      return null;
    }
    return session.storage.temporaryDownloadUrl(
      storageId: mediaStorageId,
      path: path,
    );
  }

  Future<MediaFile> _media(
    Session session,
    String deviceToken,
    UuidValue mediaFileId,
  ) async {
    final auth = await authenticateDevice(session, deviceToken);
    final media = await MediaFile.db.findFirstRow(
      session,
      where: (m) => m.id.equals(mediaFileId) & m.tenantId.equals(auth.tenantId),
    );
    if (media == null) throw SyncRequestException(reason: 'mediaUnknown');
    // Kunci datang dari perangkat: hanya `<hex>.<ext>`, tidak pernah keluar
    // dari folder tenant.
    if (!_storageKey.hasMatch(media.storageKey)) {
      throw SyncRequestException(reason: 'mediaInvalid');
    }
    return media;
  }
}

final _storageKey = RegExp(r'^[0-9a-f]{4,64}\.[a-z0-9]{1,5}$');

/// Kunci berkas di object storage.
String mediaPath(MediaFile media) =>
    '${media.tenantId.uuid}/${media.storageKey}';
