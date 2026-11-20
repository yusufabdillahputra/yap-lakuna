# Rencana F1-11h · Modifier pesanan di rincian nota Riwayat

Spec: [F1-11h](../specs/2026-11-20-f1-11h-modifier-di-rincian-nota-design.md).

- [x] 1. Tes gagal dulu: `history_flow_test.dart` (modifier di baris
  barang), repositori palsu menerima `modifiers`.
- [x] 2. `history_detail.dart` menampilkan `+ modifier` di bawah nama.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (tanpa Critical/Important; Minor: tes 360 px, aturan harga tambahan).
- [x] 5. Uji manual Xvfb (Riwayat, cari `boba`, rincian) + tangkapan layar
  ke `/mnt/project-files/lakuna/f1-11h/`.
- [x] 6. Dokumen: spec, gap F1-11g, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#124).
