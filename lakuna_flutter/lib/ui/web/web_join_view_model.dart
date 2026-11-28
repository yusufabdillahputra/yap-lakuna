import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart' show parsePairingInput;

import '../../data/repositories/web_join_repository.dart';
import '../../data/services/web_session_store.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Toko belum punya cabang aktif, jadi perangkat web tidak bisa dibuat.
class WebJoinNoOutlet implements Exception {
  const WebJoinNoOutlet();
}

/// Masuk ke toko versi hosting di browser (F2-02 tahap 1): tempel kode
/// pasang, perangkat web dibuat di cabang pertama, lalu *Menyiapkan data
/// toko* menarik semua data. Pull yang terputus (offline, tab ditutup)
/// dilanjutkan dari kursor tanpa kode pasang baru.
class WebJoinViewModel extends ChangeNotifier {
  WebJoinViewModel({
    required WebJoinRepository repository,
    required WebSessionStore sessions,
    required Future<void> Function() onJoined,
    String initialServer = '',
  }) : _repository = repository,
       _sessions = sessions,
       _onJoined = onJoined,
       _server = initialServer {
    start = Command0(_start)..addListener(notifyListeners);
    cancel = Command0(_cancel)..addListener(notifyListeners);
    _database = sessions.pendingDatabase;
    resumed = _database == null ? Future.value() : start.execute();
  }

  final WebJoinRepository _repository;
  final WebSessionStore _sessions;
  final Future<void> Function() _onJoined;

  /// Masuk: daftarkan perangkat (bila belum) lalu tarik data.
  late final Command0<void> start;

  /// Batalkan gabung: hapus database dan kembali ke formulir.
  late final Command0<void> cancel;

  /// Selesai saat pull lanjutan dari tab sebelumnya selesai (tes).
  late final Future<void> resumed;

  String _server;
  String _code = '';
  String get serverUrl => _server.trim();
  String get code => _code;

  /// Naik saat kode lengkap ditempel di isian kode dan mengisi alamat.
  int _serverRevision = 0;
  int get serverRevision => _serverRevision;

  /// Database sesi yang sedang disiapkan.
  String? _database;
  bool get preparing => _database != null;

  int _pulled = 0;
  int? _total;

  /// Perubahan yang sudah diterima.
  int get pulled => _pulled;

  /// Semua perubahan (diterima + sisa); `null` bila server tidak memberi
  /// sisa.
  int? get total => _total;

  var _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get busy => start.running || cancel.running;

  void setServer(String value) {
    _server = value;
    start.clearResult();
  }

  void setCode(String value) {
    final parsed = parsePairingInput(value);
    if (parsed.serverUrl != null && value.contains('#')) {
      _server = parsed.serverUrl!;
      _serverRevision++;
    }
    _code = parsed.code;
    start.clearResult();
  }

  bool get canSubmit => serverUrl.isNotEmpty && _code.length >= 8 && !busy;

  Future<Result<void>> _start() async {
    try {
      return await _run();
    } on _Failed catch (f) {
      return Result.error(f.error);
    }
  }

  Future<Result<void>> _run() async {
    var database = _database;
    if (database == null) {
      final outlets = switch (await _repository.pairingOutlets(
        serverUrl,
        _code,
      )) {
        Ok(:final value) => value,
        Error(:final error) => throw _Failed(error),
      };
      if (outlets.isEmpty) return const Result.error(WebJoinNoOutlet());
      // Outlet asal perangkat web = cabang pertama; cabang lain dipilih
      // di bilah atas (aturan 2a).
      final registered = await _repository.register(
        serverUrl,
        code: _code,
        outletId: outlets.first.id,
      );
      switch (registered) {
        case Ok(:final value):
          database = value;
        case Error(:final error):
          return Result.error(error);
      }
      await _sessions.setPendingDatabase(database);
      _database = database;
    }
    _pulled = 0;
    _total = null;
    notifyListeners();
    final pulled = await _repository.pull(
      database,
      onPull: (n, remaining) {
        _pulled = n;
        _total = remaining == null ? null : n + remaining;
        notifyListeners();
      },
    );
    if (pulled is Error<void>) return pulled;
    await _sessions.setActiveDatabase(database);
    await _onJoined();
    return const Result.ok(null);
  }

  Future<Result<void>> _cancel() async {
    final database = _database;
    if (database == null) return const Result.ok(null);
    final result = await _repository.discard(database);
    await _sessions.setPendingDatabase(null);
    _database = null;
    _pulled = 0;
    _total = null;
    start.clearResult();
    return result;
  }
}

class _Failed implements Exception {
  const _Failed(this.error);
  final Exception error;
}
