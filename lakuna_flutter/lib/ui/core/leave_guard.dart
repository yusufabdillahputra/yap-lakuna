import 'dart:async';

/// Penjaga keluar satu halaman rute (F1-12f).
///
/// Halaman memasang [check] selama tampil; rute memanggil [canLeave] dari
/// `GoRoute.onExit`, sehingga Kembali, tombol kembali sistem, dan menu
/// samping melewati pertanyaan yang sama.
class LeaveGuard {
  Future<bool> Function()? _check;

  /// Halaman pernah memasang [check]; setelah dilepas lagi, guard ini sudah
  /// selesai dan boleh dibuang [LeaveGuards].
  var _attached = false;

  /// `true` bila halaman boleh ditinggalkan; `null` = selalu boleh.
  Future<bool> Function()? get check => _check;
  set check(Future<bool> Function()? value) {
    _check = value;
    if (value != null) _attached = true;
  }

  /// Halaman pemiliknya sudah ditutup.
  bool get _released => _attached && _check == null;

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
    // Guard yang baru dibuat (halamannya belum sempat memasang `check`,
    // mis. dua halaman bertumpuk dibangun dalam satu frame, F1-08k) tetap
    // disimpan.
    // Guard yang belum pernah dipasang tidak dibuang di sini; semua halaman
    // yang meminta guard memasangnya di `initState`, jadi tidak menumpuk.
    _guards.removeWhere((key, g) => g._released);
    return _guards.putIfAbsent(pageKey, LeaveGuard.new);
  }

  /// Dipanggil dari `onExit`.
  Future<bool> canLeave(Object pageKey) async =>
      await _guards[pageKey]?.canLeave() ?? true;
}
