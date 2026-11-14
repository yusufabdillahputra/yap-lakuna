import 'dart:async';

import 'package:flutter/widgets.dart';

/// Halaman yang membuka halaman lain dengan `context.push` lalu memuat ulang
/// datanya setelah halaman itu ditutup (F1-08f, F1-12d).
///
/// Bila staf meninggalkan halaman yang dibuka lewat menu samping
/// (`context.go`) ke halaman ini lagi, router membuang halaman itu tanpa
/// menyelesaikan future `push`-nya, sementara State halaman ini
/// dipertahankan. Mixin ini mengenali saat halaman ini kembali menjadi rute
/// teratas dan memanggil [onRouteReturn].
mixin RouteReturnMixin<T extends StatefulWidget> on State<T> {
  /// Naik saat staf kembali lewat router: halaman yang dibuka sebelumnya
  /// sudah dibuang, jadi selesainya (bila pernah) tidak dihitung lagi.
  var _awayEpoch = 0;

  /// Jumlah halaman yang dibuka lewat [whileAway] dan belum ditutup
  /// (ketukan ganda pada baris daftar bisa membuka dua).
  var _awayCount = 0;

  /// Halaman lain yang dibuka lewat [whileAway] masih terbuka.
  bool get isAway => _awayCount > 0;

  /// Menjalankan [open] (biasanya `push`) dan menandai halaman ini sedang
  /// ditinggalkan sampai [open] selesai atau staf kembali lewat router.
  Future<R> whileAway<R>(Future<R> Function() open) async {
    final epoch = _awayEpoch;
    _awayCount++;
    try {
      return await open();
    } finally {
      // Future lama yang selesai setelah staf kembali lewat router tidak
      // mengurangi hitungan halaman yang dibuka sesudahnya.
      if (epoch == _awayEpoch) _awayCount--;
    }
  }

  /// Dipanggil setelah staf kembali ke halaman ini lewat router sementara
  /// halaman yang dibuka [whileAway] belum ditutup.
  void onRouteReturn();

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Saat push sendiri halaman ini juga dibangun ulang, tetapi bukan rute
    // teratas, jadi tanda tetap dipegang.
    if (isAway && (ModalRoute.isCurrentOf(context) ?? false)) {
      _awayEpoch++;
      _awayCount = 0;
      // Setelah frame ini: memuat ulang memberi tahu pendengar.
      scheduleMicrotask(() {
        if (mounted) onRouteReturn();
      });
    }
  }
}
