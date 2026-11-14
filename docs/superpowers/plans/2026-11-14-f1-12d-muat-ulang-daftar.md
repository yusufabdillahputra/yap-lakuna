# Rencana F1-12d · Daftar dimuat ulang setelah keluar lewat menu samping

Spec: [F1-12d](../specs/2026-11-14-f1-12d-muat-ulang-daftar-design.md).
Rilis: v0.91.0+94.

- [x] 1. Tes gagal dulu: Pembelian (1440 px), Pelanggan, Supplier, Riwayat
  (800 px) keluar dari detail lewat menu samping.
- [x] 2. `RouteReturnMixin` (`whileAway`, `onRouteReturn`), dipakai Stok,
  Pembelian, Pelanggan, Supplier, Riwayat.
- [x] 3. Format, analyze, semua tes.
- [x] 4. Review subagent: tanpa Critical/Important; Minor diterapkan
  (hitungan halaman, `isCurrentOf`, `unawaited`, `HistoryViewModel`
  setelah dibuang, tes unit mixin).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-12d/`.
- [x] 6. Dokumen: spec, gap F1-08f, README spec, STATUS-JEDA, CHANGELOG,
  versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
