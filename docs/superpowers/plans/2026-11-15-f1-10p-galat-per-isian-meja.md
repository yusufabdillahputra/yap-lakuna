# Rencana F1-10p · Galat simpan area / meja / rentang di isiannya

Spec: [F1-10p](../specs/2026-11-15-f1-10p-galat-per-isian-meja-design.md).

- [x] 1. Tes widget gagal dulu (nama area/meja di bawah Nama, kursi di bawah
  Kursi, rentang di pratinjau, galat lain tetap di kotak merah).
- [x] 2. `_DialogSaving.saveFailure` + `errorIf`; pemetaan per dialog.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: galat kosong area tertinggal menutupi galat kembar; Minor: tes kursi hilang saat diubah, kotak merah rentang).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-10p/`.
- [x] 6. Dokumen: spec, gap F1-10o, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
