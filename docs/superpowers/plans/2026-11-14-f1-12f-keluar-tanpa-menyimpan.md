# Rencana F1-12f · Peringatan keluar dari form pembelian tanpa menyimpan

Spec: [F1-12f](../specs/2026-11-14-f1-12f-keluar-tanpa-menyimpan-design.md).
Rilis: v0.97.0+100.

- [x] 1. Tes VM gagal dulu (`hasUnsavedChanges`).
- [x] 2. `_signature` / `_saved` di `PurchaseFormViewModel`.
- [x] 3. Tes widget gagal dulu (Kembali, menu samping, kembali sistem,
  ganti draf di layar lebar).
- [x] 4. `LeaveGuard`, `onExit` di rute pembelian, `confirmDiscard(body:)`,
  daftar Pembelian layar lebar; kunci l10n ID + EN.
- [x] 5. Format, analyze, semua tes; tes widget diverifikasi mutasi.
- [x] 6. Review subagent; Critical/Important diperbaiki.
- [x] 7. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-12f/`.
- [ ] 8. Dokumen: spec, gap F1-08i, README spec, STATUS-JEDA, panduan
  pembelian ID/EN, CHANGELOG, versi.
- [x] 9. PR, CI hijau, squash-merge, rilis (#103).
