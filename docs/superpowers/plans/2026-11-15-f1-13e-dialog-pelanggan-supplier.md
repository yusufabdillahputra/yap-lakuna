# Rencana F1-13e · Dialog pelanggan & supplier tidak tertutup tanpa bertanya

Spec: [F1-13e](../specs/2026-11-15-f1-13e-dialog-pelanggan-supplier-design.md).
Rilis: v0.100.0+103.

- [x] 1. Tes VM gagal dulu (`hasUnsavedChanges`, `busy`) pelanggan + supplier.
- [x] 2. Implementasi di kedua view model.
- [x] 3. Tes widget gagal dulu (ketuk di luar, Batal, simpan, menu samping).
- [x] 4. `DiscardChangesScope`, `maybePop` di Batal, `useRootNavigator`;
  kunci l10n ID + EN.
- [x] 5. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 6. Review subagent; Critical/Important diperbaiki.
- [x] 7. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-13e/`.
- [x] 8. Dokumen: spec, gap F1-12f / F1-15c / F1-13 / F1-14, README spec,
  STATUS-JEDA, panduan pelanggan & supplier ID/EN, CHANGELOG, versi.
- [x] 9. PR, CI hijau, squash-merge, rilis (#106).
