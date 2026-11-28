import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Menghapus database [path] dari penyimpanan browser: folder OPFS
/// `drift_db/<nama>` (dipakai `sqlite3_web`) dan database IndexedDB bernama
/// sama (cadangan). Database harus sudah ditutup; yang tidak ada diabaikan.
Future<void> deleteWebDatabase(String path) async {
  try {
    final root = await web.window.navigator.storage.getDirectory().toDart;
    final dir = await root.getDirectoryHandle('drift_db').toDart;
    await dir
        .removeEntry(path, web.FileSystemRemoveOptions(recursive: true))
        .toDart;
  } on Object {
    // Tidak ada OPFS atau database belum pernah dibuat.
  }
  try {
    web.window.indexedDB.deleteDatabase(path);
  } on Object {
    // IndexedDB tidak tersedia.
  }
}
