# Rencana F1-12l · Asal harga di baris pembelian

Spec: `docs/superpowers/specs/2026-11-20-f1-12l-asal-harga-baris-pembelian-design.md`

- [x] 1. Data: tes asal harga di `lakuna_data`, lalu `lastPurchasePriceSetOf` mengembalikan asal.
- [x] 2. Repositori: `PurchasePriceSource`, `LastPurchasePrice.perBaseFrom/perUnitFrom`, repositori lokal dan palsu.
- [x] 3. VM: tes `priceOrigin`, lalu implementasi.
- [x] 4. View + l10n: tes alur, lalu penanda di `_ProductName`.
- [x] 5. Uji mutasi, review subagen, perbaiki temuan.
- [x] 6. Uji manual Xvfb dan tangkapan layar.
- [x] 7. Dokumen (spec F1-12g/h, README, STATUS-JEDA, panduan), CHANGELOG, versi 0.129.0+132.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
