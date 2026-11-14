# Rencana F1-12c · PDF pembelian dan tautan kartu stok

Spec: `docs/superpowers/specs/2026-11-14-f1-12c-pdf-pembelian-kartu-stok-design.md`.

- [ ] 1. Tes + `purchase_print.dart` (`purchasePrintTable`, `purchasePrintFileName`).
- [ ] 2. Tes + `PurchaseDetailViewModel(exporter:)` `printPdf`, `printPath`.
- [ ] 3. Tes + `StockViewModel.focusCard`, `StockScreen(initialVariantId, initialLocationId)`, `Routes.stockCard`.
- [ ] 4. View: tombol cetak + pesan di kartu *Tindakan*; tautan nama produk
      (izin `stock:adjust`); router.
- [ ] 5. l10n id/en, tes widget 1440/360.
- [ ] 6. Review subagent, perbaiki temuan.
- [ ] 7. Uji manual Xvfb (PDF via pdftoppm, tautan kartu stok), panduan,
      spec/README/STATUS-JEDA, CHANGELOG 0.51.0, versi.
