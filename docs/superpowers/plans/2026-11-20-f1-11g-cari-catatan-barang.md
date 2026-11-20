# Rencana F1-11g · Cari nota Riwayat lewat catatan barang

Spec: [F1-11g](../specs/2026-11-20-f1-11g-cari-catatan-barang-design.md).

- [x] 1. Tes gagal dulu: `history_test.dart` (catatan barang).
- [x] 2. Subkueri `sale_items` + cek ulang Dart mencocokkan `note`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (tanpa Critical/Important; Minor: catatan tampil di rincian nota, gap F1-11f, aturan 5).
- [x] 5. Uji manual Xvfb (Riwayat, cari `less ice`, rincian) + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-11g/`.
- [x] 6. Dokumen: spec, gap F1-11f, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#123).
