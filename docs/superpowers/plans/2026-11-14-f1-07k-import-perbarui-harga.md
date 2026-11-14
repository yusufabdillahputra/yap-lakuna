# Rencana F1-07k · Perbarui harga produk lewat import

Spec: `docs/superpowers/specs/2026-11-14-f1-07k-import-perbarui-harga-design.md`

- [x] Tes data (gagal): cocok SKU/barcode/nama, sel kosong, stok awal,
      kecocokan ragu, tidak berubah tanpa outbox, outbox + versi, sakelar
      mati, jasa, varian dua baris.
- [x] Domain `ProductImportRow.hasCost` / `hasMinStock` + tes.
- [x] Data `importProducts(updateExisting:)`, `ProductImportSummary.updated`
      / `unchanged`, `_ProductWriter.updatePrices`.
- [x] Repositori lokal + palsu, view model, sakelar dan ringkasan di dialog,
      l10n id + en; tes VM, repositori lokal, widget 1280/360.
- [x] Spec, gap F1-07b, README, STATUS-JEDA, panduan, CHANGELOG 0.59.0,
      pubspec 0.59.0+62.
- [x] Review subagent: kode kembar/bertentangan dilewati, baris jasa tidak
      menimpa stok minimum, fake menyimpan data lengkap, jamak EN, alasan
      dilewati, tes arsip/banyak varian.
- [x] Uji manual Xvfb: CSV 4 baris → 1 baru, 2 diperbarui (UPC-A 13 digit
      dan nama), 1 tidak berubah.
- [x] PR, merge, cek rilis.
