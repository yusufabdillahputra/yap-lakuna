/// Penyimpanan isi berkas media (stiker QRIS, foto) di perangkat (F2-02
/// aturan 8): folder `media` di samping database (native) atau cache memori
/// tab (web).
library;

import 'dart:io';
import 'dart:typed_data';

/// `true` saat aplikasi berjalan di browser.
const bool isWebPlatform = bool.fromEnvironment('dart.library.js_interop');

abstract interface class MediaBlobs {
  Future<bool> exists(String key);

  /// Isi berkas [key], `null` bila tidak ada.
  Future<Uint8List?> read(String key);

  /// Menyimpan [bytes]. [pinned] = unggahan dari perangkat ini yang belum
  /// terkirim; cache memori tidak membuangnya sampai [unpin].
  Future<void> write(String key, Uint8List bytes, {bool pinned = false});

  Future<void> unpin(String key);

  /// Jumlah berkas tersemat (belum terunggah) yang hanya ada di memori.
  int get pinnedCount;

  /// Lokasi berkas di disk untuk `Image.file`, `null` bila tidak ada atau
  /// penyimpanan bukan berkas.
  String? localPath(String key);
}

/// Media sebagai berkas di [directory].
class FileMediaBlobs implements MediaBlobs {
  FileMediaBlobs(this.directory);

  final String directory;

  File _file(String key) => File('$directory${Platform.pathSeparator}$key');

  @override
  Future<bool> exists(String key) async => _file(key).existsSync();

  @override
  Future<Uint8List?> read(String key) async {
    final file = _file(key);
    if (!file.existsSync()) return null;
    return file.readAsBytes();
  }

  @override
  Future<void> write(String key, Uint8List bytes, {bool pinned = false}) async {
    final file = _file(key);
    if (file.existsSync()) return;
    await file.parent.create(recursive: true);
    // Nama sementara unik agar berkas setengah jadi tidak pernah terbaca
    // sebagai gambar, juga bila gambar sama ditulis dua kali bersamaan.
    final tmp = File(
      '${file.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(file.path);
  }

  @override
  Future<void> unpin(String key) async {}

  @override
  int get pinnedCount => 0;

  @override
  String? localPath(String key) {
    final file = _file(key);
    return file.existsSync() ? file.path : null;
  }
}

/// Cache media di memori dengan batas [maxBytes] (LRU). Berkas tersemat
/// tidak dihitung untuk dibuang.
class MemoryMediaBlobs implements MediaBlobs {
  MemoryMediaBlobs({this.maxBytes = 64 * 1024 * 1024});

  final int maxBytes;
  final _entries = <String, Uint8List>{};
  final _pinned = <String>{};
  var _size = 0;

  @override
  Future<bool> exists(String key) async => _entries.containsKey(key);

  /// [exists] tanpa menunggu (untuk daftar produk yang dibangun sinkron).
  bool containsSync(String key) => _entries.containsKey(key);

  @override
  Future<Uint8List?> read(String key) async {
    final bytes = _entries.remove(key);
    if (bytes == null) return null;
    _entries[key] = bytes;
    return bytes;
  }

  @override
  Future<void> write(String key, Uint8List bytes, {bool pinned = false}) async {
    final old = _entries.remove(key);
    if (old != null) _size -= old.length;
    _entries[key] = bytes;
    _size += bytes.length;
    if (pinned) _pinned.add(key);
    _evict();
  }

  @override
  Future<void> unpin(String key) async {
    _pinned.remove(key);
  }

  @override
  int get pinnedCount => _pinned.length;

  @override
  String? localPath(String key) => null;

  void _evict() {
    if (_size <= maxBytes) return;
    for (final key in _entries.keys.toList()) {
      if (_size <= maxBytes) break;
      if (_pinned.contains(key)) continue;
      _size -= _entries.remove(key)!.length;
    }
  }
}

/// Penyimpanan media bawaan untuk database di [databasePath].
MediaBlobs defaultMediaBlobs(String databasePath) {
  if (isWebPlatform) return MemoryMediaBlobs();
  final sep = Platform.pathSeparator;
  final cut = databasePath.lastIndexOf(sep);
  final dir = cut < 0 ? '.' : databasePath.substring(0, cut);
  return FileMediaBlobs('$dir${sep}media');
}
