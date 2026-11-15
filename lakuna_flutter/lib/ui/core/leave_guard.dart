import 'dart:async';

/// Penjaga keluar satu halaman rute (F1-12f).
///
/// Halaman memasang [check] selama tampil; rute memanggil [canLeave] dari
/// `GoRoute.onExit`, sehingga Kembali, tombol kembali sistem, dan menu
/// samping melewati pertanyaan yang sama.
class LeaveGuard {
  /// `true` bila halaman boleh ditinggalkan; `null` = selalu boleh.
  Future<bool> Function()? check;

  Future<bool>? _running;

  /// Pertanyaan yang sedang tampil dipakai ulang: navigasi kedua selama
  /// dialog terbuka tidak membuka dialog kedua.
  Future<bool> canLeave() {
    final check = this.check;
    if (check == null) return Future.value(true);
    return _running ??= check().whenComplete(() => _running = null);
  }
}

/// Satu [LeaveGuard] per halaman rute, dikunci `GoRouterState.pageKey`.
class LeaveGuards {
  final _guards = <Object, LeaveGuard>{};

  /// Guard untuk halaman [pageKey]; dibuat saat pertama diminta.
  LeaveGuard of(Object pageKey) {
    // Halaman yang sudah ditutup melepas `check`-nya: buang guard-nya.
    _guards.removeWhere((key, g) => key != pageKey && g.check == null);
    return _guards.putIfAbsent(pageKey, LeaveGuard.new);
  }

  /// Dipanggil dari `onExit`.
  Future<bool> canLeave(Object pageKey) async =>
      await _guards[pageKey]?.canLeave() ?? true;
}
