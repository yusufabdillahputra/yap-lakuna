# Rencana F1-04d · Pelanggan & nota tersimpan di Kasir

Spec: `docs/superpowers/specs/2026-11-04-f1-04d-pelanggan-nota-tersimpan-design.md`.

- [ ] 1. Data: `checkoutSale` + `customerId` (tes dulu).
- [ ] 2. Data: `parked_sales.dart` simpan/daftar/muat/hapus + checkout
      `parkedSaleId` (tes dulu).
- [ ] 3. `CashierRepository` (lokal + palsu) meneruskan API baru.
- [ ] 4. `CashierViewModel`: pelanggan, simpan, daftar, lanjutkan, hapus,
      draf (tes dulu).
- [ ] 5. UI: pemilih pelanggan, tombol Simpan, daftar Nota tersimpan
      (tablet + mobile), kunci l10n ID/EN, struk nama pelanggan.
- [ ] 6. Tes widget tablet + 360 px; uji manual Xvfb ID + EN.
- [ ] 7. Review subagent; perbaiki temuan Critical/Important.
- [ ] 8. CHANGELOG 0.29.0, versi `0.29.0+31`, Status & gap + README spec,
      panduan Kasir diperbarui.
