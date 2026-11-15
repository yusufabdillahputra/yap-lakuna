# Rencana F1-09b · Dialog master data tidak tertutup tanpa bertanya

Spec: [F1-09b](../specs/2026-11-15-f1-09b-dialog-master-data-design.md).
Rilis: v0.107.0+110.

- [x] 1. Kunci l10n (ID + EN), `flutter gen-l10n`.
- [x] 2. Tes widget gagal dulu untuk ketiga dialog.
- [x] 3. Dialog: navigator akar, `TapOutsideToPop`, `DiscardChangesScope`,
  Batal `maybePop`, tanda tangan isian.
- [x] 4. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 5. Review subagent; temuan diperbaiki (Minor: angka min/maks, tes per isian, teks EN, spec). Uji manual menemukan Esc diam tanpa isian berfokus; diperbaiki di `TapOutsideToPop`.
- [x] 6. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-09b/`.
- [x] 7. Dokumen: spec, gap F1-13e, README spec, STATUS-JEDA, panduan
  master data ID/EN, CHANGELOG, versi.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
