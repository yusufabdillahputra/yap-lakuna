# Rencana F1-10o · Galat simpan di dialog area / meja / rentang

Spec: [F1-10o](../specs/2026-11-15-f1-10o-galat-di-dialog-meja-design.md).

- [x] 1. Tes widget gagal dulu (area/meja/rentang kembar, pesan di dialog,
  isian utuh, Esc setelah ditolak, simpan berjalan tidak bisa ditutup).
- [x] 2. Dialog: `onSave` async, `_saving`, `_saveError`, `FAlert`; tab:
  `onSave` per dialog + `clearError`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: pesan galat dari context dialog, galat tak terduga tidak mengunci; Minor: hasil null, kursor tidak menghapus galat, tes tambahan).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-10o/`.
- [x] 6. Dokumen: spec, gap F1-10n, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
