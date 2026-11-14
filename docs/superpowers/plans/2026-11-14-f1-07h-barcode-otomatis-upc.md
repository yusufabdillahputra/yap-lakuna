# Rencana F1-07h · Barcode otomatis & pemindaian UPC-A 13 digit

Spec: `docs/superpowers/specs/2026-11-14-f1-07h-barcode-otomatis-upc-design.md`

## Langkah

- [x] Domain: tes lalu `barcodeKey`, `sameBarcode`, `generateStoreEan13`;
  duplikat barcode di `ProductDraft` dan import memakai kunci.
- [x] Data: tes lalu `_checkCodes` dan cek import memakai `barcodeKey`.
- [x] VM: tes lalu scan Kasir/Stok/Pembelian memakai `sameBarcode`;
  `ProductFormViewModel.generateBarcode`.
- [x] View: tombol `variant-<key>-barcode-generate` + l10n id/en, tes widget.
- [x] Uji penuh (format, analyze, domain/data/flutter).
- [x] Uji manual Xvfb: buat barcode di *Kue Lapis Legit* (2042063624845),
  simpan, label EAN-13 di 1.15b, scan di Kasir; ubah barcode Kopi ke UPC-A
  036000291452 lalu scan `0036000291452` di Kasir menambah Kopi.
- [x] Review subagent (tanpa Critical/Important), perbaikan minor: fake
  repositori, cari daftar produk dan Cetak label, SKU dihindari generator,
  batas percobaan, tes 360 px, catatan data lama di spec.
- [x] Dokumen rilis: spec status, spec F1-07e gap, README spec, STATUS-JEDA,
  panduan produk, CHANGELOG 0.55.0, pubspec.
