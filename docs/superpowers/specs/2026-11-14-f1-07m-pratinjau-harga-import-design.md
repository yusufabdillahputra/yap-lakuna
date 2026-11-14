# F1-07m — Pratinjau perubahan harga sebelum import

- **Fase:** 1
- **Status:** Rilis v0.71.0
- **Layar:** 1.15 Produk, dialog *Import Excel*.
- **Acuan:** [F1-07k](2026-11-14-f1-07k-import-perbarui-harga-design.md)
  gap *Pratinjau perubahan harga sebelum simpan*.

## Tujuan

Dengan sakelar *Perbarui harga produk yang sudah ada* (F1-07k), satu berkas
bisa mengubah harga ratusan produk sekaligus. Saat ini pemilik baru tahu
apa yang berubah setelah tersimpan. Modul ini menampilkan daftar perubahan
harga dulu, lalu pemilik menekan *Simpan* bila sudah benar.

## Aturan

1. Bila sakelar perbarui **menyala**, tombol utama dialog menjadi
   *Lihat perubahan* (`product-import-preview`). Tombol ini menjalankan
   import **tanpa menulis** apa pun (aturan pencocokan sama persis dengan
   F1-07k) dan menampilkan pratinjau:
   - ringkasan: *N produk baru · M diperbarui · K tidak berubah · L
     dilewati*;
   - daftar perubahan (paling banyak 30 baris, lalu *dan X perubahan
     lainnya*): `Nama (varian) · Rp lama → Rp baru`, dengan baris kecil
     untuk harga beli dan stok minimum (dengan satuan dasar) yang ikut
     berubah. Bila harga jual tetap (hanya harga beli/stok minimum yang
     berubah), baris utama hanya berisi nama;
   - nomor baris yang dilewati (sama dengan ringkasan F1-07k).
2. Setelah pratinjau, tombol utama menjadi *Simpan* (`product-import-run`)
   yang menjalankan import sungguhan. Ringkasan akhir dihitung ulang saat
   simpan (data bisa berubah di antara keduanya).
3. Mengganti berkas atau mematikan/menyalakan sakelar menghapus pratinjau;
   pemilik harus melihat pratinjau lagi sebelum menyimpan dengan sakelar
   menyala.
4. Bila sakelar **mati**, alur tetap seperti F1-07b (langsung *Import*),
   karena produk yang ada tidak disentuh.
5. Pratinjau tanpa perubahan apa pun (semua sama/dilewati, tanpa produk
   baru) tetap tampil; tombol *Simpan* nonaktif karena tidak ada yang
   disimpan.

## Rancangan teknis

- Data: `importProducts(..., dryRun:)`; `ProductImportSummary.changes`
  (`List<ProductPriceChange>`: baris, nama produk, nama varian, harga jual
  lama/baru, harga beli dan stok minimum lama/baru bila berubah). Dry run
  memakai transaksi yang sama tanpa satu pun tulisan (tidak ada cap HLC,
  tidak masuk outbox); produk baru hanya dihitung.
- `CatalogRepository.importRows(..., dryRun:)` (lokal + palsu).
- `ProductImportViewModel.preview` (`Command0`), `previewed`, `canPreview`;
  pratinjau dihapus oleh `setUpdateExisting` dan `pick`.
- l10n: `productImportPreview`, `productImportPreviewSummary` (EN memakai
  plural), `productImportPreviewMore`, `productImportPreviewCost`,
  `productImportPreviewMinStock`, `productImportPreviewNone`,
  `productImportPreviewNote`, `productImportSave`.
- Selama memilih berkas, pratinjau, atau simpan, sakelar dan tombol lain
  terkunci; dialog tidak bisa ditutup selama pratinjau atau simpan.

## Tes

- Data: dry run tidak menulis (jumlah produk, outbox, harga tetap) dan
  hitungannya sama dengan import sungguhan; `changes` berisi harga lama/baru,
  harga beli/stok minimum hanya bila berubah.
- VM: sakelar menyala → harus pratinjau dulu; sakelar/berkas baru menghapus
  pratinjau; tanpa perubahan → simpan nonaktif.
- Widget 1280/360: pratinjau tampil, lalu simpan.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Pratinjau perubahan harga sebelum simpan | — | Rilis v0.71.0 | Dry run di transaksi yang sama, tanpa tulisan. |
| Ekspor pratinjau ke Excel | — | Belum | Bila daftar sering panjang. |
| Galat simpan produk baru terlihat di pratinjau | — | Belum | Dry run tidak menjalankan penulis produk baru (kategori, satuan, stok awal); validasi draf sudah dijalankan untuk keduanya, jadi galat lain baru muncul saat *Simpan*. Opsi: jalankan jalur penuh lalu batalkan transaksi. |
