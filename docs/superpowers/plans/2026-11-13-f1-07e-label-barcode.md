# Rencana F1-07e — Cetak label barcode

Spec: `docs/superpowers/specs/2026-11-13-f1-07e-label-barcode-design.md`

- [x] 1. Domain: tes lalu `labelSymbology`, `eanCheckDigit`.
- [x] 2. PDF: tes lalu `buildBarcodeLabelPdf` (A4 3×8 + lewati, roll 50×30 / 38×25).
- [x] 3. VM: tes lalu `BarcodeLabelViewModel` (baris, pilih awal, stok, batas, cetak/simpan).
- [x] 4. Layar 1.15b + rute + tombol di 1.15 dan 1.16; l10n ID + EN; tes widget 1280/360 px.
- [ ] 5. Uji manual Xvfb; review subagent.
- [ ] 6. CHANGELOG 0.36.0, versi `0.36.0+39`, status spec, README, STATUS-JEDA; PR, CI, merge.
