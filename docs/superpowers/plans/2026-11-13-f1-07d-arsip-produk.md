# Rencana F1-07d — Arsip produk

Spec: `docs/superpowers/specs/2026-11-13-f1-07d-arsip-produk-design.md`

- [x] 1. Data: tes arsip/pulihkan/daftar arsip (termasuk kode kembar dan tenant lain), lalu implementasi di `catalog.dart`.
- [x] 2. Flutter repositori: `archive`, `restore`, `archived`, `ProductCatalog.archivedCount`; repositori palsu.
- [x] 3. Form 1.16: `ProductFormViewModel.archive`, tombol dan dialog konfirmasi (peringatan stok); tes VM dan widget.
- [x] 4. Daftar 1.15: tombol *Diarsipkan (n)*, `ArchivedProductsViewModel`, dialog pulihkan; tes VM dan widget 1280/360 px; l10n ID + EN.
- [ ] 5. Uji manual Xvfb; review subagent.
- [ ] 6. CHANGELOG 0.35.0, versi `0.35.0+38`, status spec, README, STATUS-JEDA; PR, CI, merge.
