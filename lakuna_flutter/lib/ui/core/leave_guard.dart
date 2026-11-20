import 'dart:async';

import 'package:flutter/widgets.dart';

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

  /// Halaman sedang menyimpan atas pilihan **Simpan** di dialog keluar
  /// (F1-07r): navigasi lain ditolak, bukan ikut menunggu jawaban navigasi
  /// yang sedang ditahan (yang akan diteruskan bila simpan berhasil).
  var saving = false;

  /// Pertanyaan yang sedang tampil dipakai ulang: navigasi kedua selama
  /// dialog terbuka tidak membuka dialog kedua.
  Future<bool> canLeave() {
    final check = this.check;
    if (check == null) return Future.value(true);
    if (saving) return Future.value(false);
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

  /// Semua halaman yang masih terpasang boleh ditinggalkan sekaligus
  /// (*Ganti kasir*, F1-02b). Halaman teratas (guard terakhir dibuat)
  /// ditanya lebih dulu; berhenti pada jawaban `false`.
  Future<bool> canLeaveAll() async {
    final attached = [
      for (final g in _guards.values)
        if (g.check != null) g,
    ];
    for (final guard in attached.reversed) {
      if (!await guard.canLeave()) return false;
    }
    return true;
  }
}

/// Rute halaman [context], atau rute yang memuatnya (mis. bingkai menu
/// `ShellRoute` setelah *Ganti kasir*), sedang ditutup: sudah dilepas dari
/// navigatornya (beranimasi keluar, atau halaman go_router yang dihapus
/// dari daftar halaman) tetapi widget-nya belum dibuang. Perubahannya sudah
/// dibuang atau disimpan, jadi penjaganya tidak bertanya lagi (F1-02e),
/// mis. *Ganti kasir* atau tutup jendela di sela itu setelah *Buang*.
bool isRouteClosing(BuildContext context) {
  for (var route = ModalRoute.of(context); route != null;) {
    if (!route.isActive) return true;
    final outer = route.navigator?.context;
    route = outer == null ? null : ModalRoute.of(outer);
  }
  return false;
}
