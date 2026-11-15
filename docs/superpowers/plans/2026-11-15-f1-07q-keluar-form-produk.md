# Rencana F1-07q · Peringatan keluar dari form produk tanpa menyimpan

Spec: [F1-07q](../specs/2026-11-15-f1-07q-keluar-form-produk-design.md).
Rilis: v0.98.0+101.

- [x] 1. Tes VM gagal dulu (`hasUnsavedChanges`).
- [x] 2. `_signature` / `_saved` di `ProductFormViewModel`.
- [x] 3. Tes widget gagal dulu (Batal, menu samping, setelah simpan).
- [x] 4. `LeaveGuard` + `onExit` di rute produk; kunci l10n ID + EN.
- [x] 5. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 6. Review subagent; Critical/Important diperbaiki.
- [x] 7. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-07q/`.
- [x] 8. Dokumen: spec, gap F1-12f, README spec, STATUS-JEDA, panduan
  produk ID/EN, CHANGELOG, versi.
- [ ] 9. PR, CI hijau, squash-merge, rilis.
