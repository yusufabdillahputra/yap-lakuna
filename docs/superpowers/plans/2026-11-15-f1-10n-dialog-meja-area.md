# Rencana F1-10n · Dialog area, meja, rentang meja tanya sebelum ditutup

Spec: [F1-10n](../specs/2026-11-15-f1-10n-dialog-meja-area-design.md).

- [x] 1. Kunci l10n (ID + EN), `flutter gen-l10n`.
- [x] 2. Tes widget gagal dulu untuk ketiga dialog.
- [x] 3. `_showDialog`: navigator akar, `TapOutsideToPop`; dialog:
  tanda tangan awal, `DiscardChangesScope`, Batal `maybePop`, `setState`.
- [x] 4. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 5. Review subagent; temuan Minor diperbaiki (kunci Batal eksplisit, tes per isian rentang, tombol kembali, konfirmasi hapus, kata-kata spec).
- [x] 6. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-10n/`.
- [x] 7. Dokumen: spec, gap F1-09b, README spec, STATUS-JEDA, panduan
  (ID + EN), CHANGELOG, versi.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
