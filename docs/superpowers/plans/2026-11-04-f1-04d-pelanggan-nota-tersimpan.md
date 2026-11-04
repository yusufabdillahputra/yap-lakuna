# Rencana F1-04d · Pelanggan & nota tersimpan di Kasir

Spec: `docs/superpowers/specs/2026-11-04-f1-04d-pelanggan-nota-tersimpan-design.md`.

- [x] 1. Data: `checkoutSale` + `customerId` (tes dulu).
- [x] 2. Data: `parked_sales.dart` simpan/daftar/muat/hapus + checkout
      `parkedSaleId` (tes dulu).
- [x] 3. `CashierRepository` (lokal + palsu) meneruskan API baru.
- [x] 4. `CashierViewModel`: pelanggan, simpan, daftar, lanjutkan, hapus,
      draf (tes dulu).
- [x] 5. UI: pemilih pelanggan, tombol Simpan, daftar Nota tersimpan
      (tablet + mobile), kunci l10n ID/EN, struk nama pelanggan.
- [x] 6. Tes widget tablet + 360 px; uji manual Xvfb ID + EN.
- [x] 7. Review subagent; perbaiki temuan Critical/Important.
- [x] 8. CHANGELOG 0.29.0, versi `0.29.0+31`, Status & gap + README spec,
      panduan Kasir diperbarui.
