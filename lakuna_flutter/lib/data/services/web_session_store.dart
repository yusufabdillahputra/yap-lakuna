import 'package:lakuna_data/lakuna_data.dart' show deleteWebDatabase;

import 'web_session_store_io.dart'
    if (dart.library.js_interop) 'web_session_store_web.dart'
    as impl;

/// Alasan aplikasi web tidak bisa dimulai di tab ini (F2-02 *Kasus tepi*).
enum WebStartProblem {
  /// Browser menolak penyimpanan (mode privat atau kuota).
  storageUnavailable,

  /// Lakuna sudah terbuka di tab lain.
  otherTab,
}

/// Sesi toko di browser (F2-02 aturan 6): nama database sesi aktif dan
/// database lama yang harus dihapus, disimpan di `localStorage`.
abstract interface class WebSessionStore {
  /// Memastikan tab ini boleh membuka database: penyimpanan tersedia dan
  /// tidak ada tab lain yang memegang kunci. `null` = boleh.
  Future<WebStartProblem?> claim();

  /// Database gabung yang pull pertamanya belum selesai; dilanjutkan saat
  /// tab dibuka lagi (Fokus review 2) dan tidak dihapus [purgeStale].
  String? get pendingDatabase;

  /// Mengganti database gabung tertunda; yang lama masuk
  /// [staleDatabases].
  Future<void> setPendingDatabase(String? name);

  /// Database sesi yang dibuka saat aplikasi dimulai; `null` = belum
  /// masuk.
  String? get activeDatabase;

  /// Database sesi lama yang belum terhapus.
  List<String> get staleDatabases;

  /// Mengganti sesi aktif; database sesi sebelumnya masuk
  /// [staleDatabases]. Database tertunda yang sama menjadi sesi aktif.
  Future<void> setActiveDatabase(String? name);

  /// Menghapus semua [staleDatabases] (dipanggil sebelum database apa pun
  /// dibuka, sehingga penghapusan yang terputus diulang).
  Future<void> purgeStale();
}

/// [WebSessionStore] di memori (tes dan aplikasi perangkat).
class MemoryWebSessionStore implements WebSessionStore {
  MemoryWebSessionStore({
    Future<void> Function(String name)? delete,
    this.problem,
  }) : _delete = delete ?? deleteWebDatabase;

  final Future<void> Function(String name) _delete;

  /// Balasan [claim] (tes).
  WebStartProblem? problem;
  String? _active;
  String? _pending;
  final _stale = <String>[];

  @override
  Future<WebStartProblem?> claim() async => problem;

  @override
  String? get pendingDatabase => _pending;

  @override
  Future<void> setPendingDatabase(String? name) async {
    final old = _pending;
    if (old != null && old != name && !_stale.contains(old)) _stale.add(old);
    _pending = name;
  }

  @override
  String? get activeDatabase => _active;

  @override
  List<String> get staleDatabases => List.unmodifiable(_stale);

  @override
  Future<void> setActiveDatabase(String? name) async {
    final old = _active;
    if (old != null && old != name && !_stale.contains(old)) _stale.add(old);
    if (name != null && name == _pending) _pending = null;
    _active = name;
  }

  @override
  Future<void> purgeStale() async {
    for (final name in List.of(_stale)) {
      await _delete(name);
      _stale.remove(name);
    }
  }
}

/// Penyimpanan sesi web untuk platform ini (`localStorage` di browser).
WebSessionStore platformWebSessionStore() => impl.platformWebSessionStore();
