# Rencana F1-08g · Peringatan draf pembelian ganda dari stok minimum

Spec: [F1-08g](../specs/2026-11-14-f1-08g-draf-pembelian-ganda-design.md).
Rilis: v0.93.0+96.

- [x] 1. Tes data gagal dulu: `restockDraftsOf` (urutan, draf dihapus,
  diterima, cabang lain, varian kosong).
- [x] 2. `RestockDraft` + `restockDraftsOf`; repositori lokal + palsu.
- [x] 3. Tes widget gagal dulu (1280 / 360 px, galat baca); dialog
  `_askDraft` di `StockScreen`; wiring router; l10n ID/EN.
- [x] 4. Format, analyze, semua tes.
- [x] 5. Review subagent: 2 Important diperbaiki (draf dibatasi lokasi
  terima; pencarian draf di luar `whileAway` dengan bendera
  `_checkingDraft` + tes balapan yang diverifikasi mutasi); Minor:
  `purchasedOn` dibuang, tes lokasi lain. Data 502, Flutter 1149 tes.
- [x] 6. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08g/`.
- [x] 7. Dokumen: spec, gap F1-08c, README spec, STATUS-JEDA, panduan
  stok ID/EN, CHANGELOG, versi.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
