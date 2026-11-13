# Rencana F1-07c — Harga grosir per grup pelanggan

Spec: `docs/superpowers/specs/2026-11-13-f1-07c-grosir-grup-pelanggan-design.md`

- [ ] 1. Server: `customerGroupId` di `price_tier.spy.yaml`, generate, migrasi `grosir-grup`.
- [ ] 2. Domain: tes `tierFor`/`priceSaleLine` dengan grup dan validasi, lalu implementasi.
- [ ] 3. Data: tes simpan/muat tingkat grup, checkout/kredit/parkir dengan grup, lalu implementasi.
- [ ] 4. Flutter: katalog membawa grup pelanggan; form produk *Berlaku untuk*; Kasir menghitung harga dengan grup pelanggan; tes VM dan widget 1280/360 px.
- [ ] 5. Uji manual Xvfb; review subagent.
- [ ] 6. CHANGELOG 0.34.0, versi `0.34.0+37`, status spec, README, STATUS-JEDA; PR, CI, merge.
