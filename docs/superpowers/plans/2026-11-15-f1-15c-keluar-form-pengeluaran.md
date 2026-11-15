# Rencana F1-15c · Peringatan keluar dari Pengeluaran tanpa menyimpan

Spec: [F1-15c](../specs/2026-11-15-f1-15c-keluar-form-pengeluaran-design.md).
Rilis: v0.99.0+102.

- [x] 1. Tes VM gagal dulu (`hasUnsavedChanges`, `busy`).
- [x] 2. Implementasi di `ExpenseFormViewModel`.
- [x] 3. Tes widget gagal dulu (1440 px menu samping, 360 px menu bawah).
- [x] 4. `LeaveGuard` + `onExit` di `/pengeluaran`; kunci l10n ID + EN.
- [x] 5. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 6. Review subagent; Critical/Important diperbaiki.
- [x] 7. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-15c/`.
- [x] 8. Dokumen: spec, gap F1-12f / F1-15, README spec, STATUS-JEDA,
  panduan pengeluaran ID/EN, CHANGELOG, versi.
- [ ] 9. PR, CI hijau, squash-merge, rilis.
