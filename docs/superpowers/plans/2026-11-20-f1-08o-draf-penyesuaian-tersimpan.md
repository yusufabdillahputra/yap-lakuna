# Rencana F1-08o · Draf penyesuaian stok tersimpan di perangkat

Spec: `docs/superpowers/specs/2026-11-20-f1-08o-draf-penyesuaian-tersimpan-design.md`

- [x] 1. Repositori: `StockAdjustmentDraft` + JSON, `adjustmentDraft` / `saveAdjustmentDraft` (tes lokal dulu), repositori palsu, `bootstrap`.
- [x] 2. VM: tes simpan / pulihkan / hapus / gagal tulis, lalu implementasi.
- [x] 3. View + l10n: keterangan tersimpan / gagal; tes layar keluar dan ganti lokasi tanpa dialog.
- [x] 4. Sesuaikan tes F1-08k / F1-08n yang mengandalkan dialog (draf gagal tersimpan).
- [x] 5. Uji mutasi, review subagen, perbaiki temuan.
- [x] 6. Uji manual Xvfb dan tangkapan layar.
- [x] 7. Dokumen (spec F1-08k, README, STATUS-JEDA, panduan), CHANGELOG, versi 0.130.0+133.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
