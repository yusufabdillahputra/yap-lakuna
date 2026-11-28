import 'dart:async';
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

  /// Unduhan dan unggahan tidak pernah selesai (koneksi macet).
  bool stall = false;

  /// Jumlah semua panggilan ke server.
  int calls = 0;

  /// Jumlah permintaan URL unduh.
  int downloadUrls = 0;

  String _path(UuidValue id) {
    final m = rows[id];
    if (m == null) throw SyncRequestException(reason: 'mediaUnknown');
    return '${tenantId.uuid}/${m.storageKey}';
  }

  void _net() {
    calls++;
    if (offline) throw const SocketException('tidak ada jaringan');
  }

  Future<void> _stall() async {
    if (stall) await Completer<void>().future;
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
    await _stall();
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
    downloadUrls++;
    final path = _path(mediaFileId);
    return files.containsKey(path)
        ? Uri.parse('https://s3.contoh/$path')
        : null;
  }

  @override
  Future<Uint8List> download(Uri url) async {
    _net();
    await _stall();
    return corrupt ?? files[url.path.substring(1)]!;
  }
}
