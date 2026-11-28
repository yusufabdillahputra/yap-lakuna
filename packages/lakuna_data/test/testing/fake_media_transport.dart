import 'dart:io';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';

/// Server media palsu: berkas per kunci `<tenant>/<storage_key>`.
class FakeMediaTransport implements MediaTransport {
  FakeMediaTransport(this.tenantId);

  final UuidValue tenantId;
  final rows = <UuidValue, MediaFile>{};
  final files = <String, Uint8List>{};
  final uploads = <String>[];
  Uint8List? corrupt;
  bool offline = false;

  String _path(UuidValue id) {
    final m = rows[id];
    if (m == null) throw SyncRequestException(reason: 'mediaUnknown');
    return '${tenantId.uuid}/${m.storageKey}';
  }

  void _net() {
    if (offline) throw const SocketException('tidak ada jaringan');
  }

  @override
  Future<String?> uploadDescription(UuidValue mediaFileId) async {
    _net();
    final path = _path(mediaFileId);
    return files.containsKey(path) ? null : path;
  }

  @override
  Future<void> upload(String description, Uint8List bytes) async {
    _net();
    uploads.add(description);
    files[description] = bytes;
  }

  @override
  Future<bool> markUploaded(UuidValue mediaFileId) async {
    _net();
    return files.containsKey(_path(mediaFileId));
  }

  @override
  Future<Uri?> downloadUrl(UuidValue mediaFileId) async {
    _net();
    final path = _path(mediaFileId);
    return files.containsKey(path)
        ? Uri.parse('https://s3.contoh/$path')
        : null;
  }

  @override
  Future<Uint8List> download(Uri url) async {
    _net();
    return corrupt ?? files[url.path.substring(1)]!;
  }
}
