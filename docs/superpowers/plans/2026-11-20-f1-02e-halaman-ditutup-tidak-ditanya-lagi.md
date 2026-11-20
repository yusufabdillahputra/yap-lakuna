# Rencana F1-02e · Halaman yang sedang ditutup tidak ditanya lagi

Spec: [F1-02e](../specs/2026-11-20-f1-02e-halaman-ditutup-tidak-ditanya-lagi-design.md).

- [x] 1. Tes gagal dulu: alur produk (Ganti kasir selagi form ditutup).
- [x] 2. `isRouteClosing` + lima `_confirmLeave` berpenjaga.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: bingkai menu yang sedang ditutup → telusuri rute leluhur, tes tutup jendela; Minor: komentar, tes halaman tertutup).
- [x] 5. Uji manual Xvfb (pengeluaran → Ganti kasir → Buang → tutup
  jendela) + tangkapan layar ke `/mnt/project-files/lakuna/f1-02e/`.
- [x] 6. Dokumen: spec, gap F1-02b, README spec, STATUS-JEDA, CHANGELOG,
  versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#125).
