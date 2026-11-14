# Rencana F1-12b · Foto faktur pembelian

Spec: `docs/superpowers/specs/2026-11-14-f1-12b-foto-faktur-design.md`.

- [x] 1. Server: `Purchase.invoiceMediaId`, `MediaKind.purchaseInvoice`,
      `serverpod generate`, `serverpod create-migration --tag foto-faktur`.
- [x] 2. Domain: `PurchaseLimits.invoicePhotoMaxBytes` (5 MB).
- [x] 3. Data (TDD, `packages/lakuna_data/test/purchase_invoice_photo_test.dart`):
      `PurchaseInvoicePhoto`, `PurchaseRequest.invoicePhoto/removeInvoicePhoto`,
      `_writePurchase` menyimpan media, `setPurchaseInvoicePhoto`,
      `clearPurchaseInvoicePhoto`, `loadPurchaseInvoicePhoto`,
      `PurchaseInvoicePhotoInvalid`.
- [x] 4. Repositori Flutter + palsu: `invoicePhoto`, `setInvoicePhoto`,
      `clearInvoicePhoto`.
- [x] 5. VM form (TDD): pilih/kamera/hapus, pratinjau draf, request.
- [x] 6. VM detail (TDD): muat foto, lampirkan, hapus.
- [x] 7. View form + detail, l10n id/en, router memberi picker.
- [x] 8. Tes widget 1280/360.
- [x] 9. Review subagent, perbaiki temuan.
- [x] 10. Uji manual Xvfb, panduan id/en, spec/README/STATUS-JEDA,
      CHANGELOG 0.50.0, versi.
