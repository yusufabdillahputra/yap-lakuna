# Rencana F1-07j · Buat barcode massal dari Cetak label

Spec: `docs/superpowers/specs/2026-11-14-f1-07j-barcode-massal-design.md`

- [x] Tes VM dan `assignStoreBarcodes` (gagal kompilasi), lalu
      implementasi: `CatalogProduct.toDraft({barcodes})`, `LabelRow`
      (`hasBarcode`, `isUnit`, `variantId`), `missingCodeRows`,
      `denseWithoutBarcode`, `generateBarcodes`.
- [x] Kunci l10n (id + en), `flutter gen-l10n`.
- [x] View: tombol di daftar, tombol di peringatan F1-07i, dialog
      konfirmasi, pesan hasil; tes widget 1280/360.
- [x] Spec, gap F1-07h, README, STATUS-JEDA, panduan, CHANGELOG 0.58.0,
      pubspec 0.58.0+61.
- [x] Review subagent: form produk me-refresh barcode setelah kembali
      (Critical), muat ulang sebelum buat, lewati produk gagal, baris
      berbarcode tak tergambar tidak ditawarkan, teks jamak EN, tes data.
- [x] Uji manual Xvfb: Bolu Pandan tanpa kode dibuat barcode dan terpilih; SKU MYK-2L-PREMIUM di 38 × 25 diganti EAN-13 dari peringatan.
- [ ] PR, merge, cek rilis.
