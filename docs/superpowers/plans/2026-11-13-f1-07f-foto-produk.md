# Rencana F1-07f — Foto produk

Spec: `docs/superpowers/specs/2026-11-13-f1-07f-foto-produk-design.md`

- [x] 1. Model: `Product.photoMediaId`, `MediaKind.productPhoto`; `serverpod generate`, migrasi `foto-produk`.
- [x] 2. Data: tes lalu `setProductPhoto`, `clearProductPhoto`, `photoPath` di katalog.
- [x] 3. Flutter repositori + palsu; VM form (pilih/ambil/hapus, simpan); tes VM.
- [x] 4. UI: kotak foto 1.16, thumbnail 1.15 dan kartu Kasir; l10n; tes widget 1280/360 px.
- [x] 5. Uji manual Xvfb; review subagent.
- [x] 6. CHANGELOG 0.37.0, versi `0.37.0+40`, status spec, README, STATUS-JEDA; PR, CI, merge.
