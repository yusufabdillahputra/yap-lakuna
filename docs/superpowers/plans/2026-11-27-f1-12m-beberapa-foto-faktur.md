# Rencana F1-12m · Beberapa foto per faktur pembelian

Spec: `docs/superpowers/specs/2026-11-27-f1-12m-beberapa-foto-faktur-design.md`

- [x] 1. Model `PurchaseInvoicePage` + migrasi `foto-faktur-lembar`,
  `serverpod generate`.
- [x] 2. Domain `PurchaseLimits.invoicePhotoMaxCount`.
- [x] 3. Data: tes gagal dulu (slot, lembar, batas, kembar, tambah/hapus,
  muat daftar), lalu `_writeInvoicePhotos`, `addPurchaseInvoicePhoto`,
  `removePurchaseInvoicePhoto`, `loadPurchaseInvoicePhotos`.
- [x] 4. Repositori Flutter + fake; VM form (daftar foto) dan VM detail +
  tes.
- [x] 5. Widget `InvoicePhotoStrip` di form dan detail, penampil dengan
  judul; l10n ID/EN; tes widget 1280/360.
- [x] 6. Dokumen: spec F1-12b gap, README specs, STATUS-JEDA, GAP-FASE1,
  panduan ID/EN Pembelian, CHANGELOG, pubspec.
- [ ] 7. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 8. PR dan rilis.
