# F1-07d · Arsip produk

- **Fase:** 1
- **Status:** Rilis v0.35.0
- **Layar:** 1.16 Form produk (aksi *Arsipkan produk*), 1.15 Daftar produk
  (tombol *Diarsipkan* + dialog pulihkan).
- **Acuan desain:** catatan 1.15 "Hapus = arsip".
- **Menutup gap:** F1-07 "Arsip produk".

## Tujuan

Produk yang tidak dijual lagi bisa disingkirkan dari Kasir, daftar produk,
stok, dan pembelian tanpa merusak riwayat penjualan, pembelian, dan ledger
stok. Produk yang terlanjur diarsipkan bisa dipulihkan.

Beda dengan saklar *Dijual di kasir* (`is_active`): produk nonaktif tetap
tampil di daftar produk dan stok (mis. stok musiman); produk diarsipkan
hilang dari semua daftar kerja.

## Aturan

1. **Arsip = hapus lunak produk.** `products.deleted_at` diisi; varian,
   satuan, dan tingkat grosir tidak diubah sehingga semua dokumen lama yang
   menunjuk varian tetap utuh. Semua kueri katalog, Kasir, stok, pembelian,
   dan laporan nilai stok yang sudah menyaring `deleted_at` otomatis tidak
   menampilkannya. Riwayat dan laporan penjualan memakai nama yang tersimpan
   di nota, jadi tetap tampil.
2. **Izin** `products:manage` (dicek di repositori, sama dengan simpan
   produk).
3. **Konfirmasi** di form: judul *Arsipkan {nama}?* dan penjelasan bahwa
   produk hilang dari Kasir, daftar produk, stok, dan pembelian, riwayat
   tetap, dan bisa dipulihkan. Bila stok total varian ≠ 0, dialog
   menambahkan peringatan *Stok tersisa {stok} {satuan} tidak ikut dihitung
   lagi di stok dan nilai stok*. Arsip tidak ditolak karena stok: pemilik
   yang memutuskan (mis. barang rusak sudah dibuang tetapi belum
   disesuaikan).
4. **Nota tersimpan / draf keranjang / bill F&B** yang memuat produk itu
   memakai perilaku yang sudah ada: baris dibuang saat dilanjutkan
   (pesan *n baris dibuang*), item bill yang sudah masuk tetap ikut saat
   bill ditutup, tetapi jumlahnya tidak bisa diubah lagi.
5. **Daftar arsip.** Daftar produk 1.15 memperlihatkan tombol *Diarsipkan
   (n)* bila ada produk diarsipkan. Tombol membuka dialog berisi produk
   diarsipkan (urut nama, dengan kategori dan stok terakhir) dan tombol
   *Pulihkan* per produk. Dialog konfirmasi dan daftar bisa digulir agar
   muat di ponsel.
6. **Pulihkan** mengosongkan `deleted_at`. SKU dan barcode (varian dan
   satuan) diperiksa lagi terhadap produk aktif; bila sudah dipakai produk
   lain, pemulihan ditolak (`ProductCodesTaken`) dengan pesan yang menyebut
   produk pemakainya. Produk yang dipulihkan kembali dengan status *Dijual di
   kasir* seperti sebelum diarsipkan.
7. Arsip dan pulihkan lewat `LakunaStore.write` + `SyncTx.update` (versi
   naik, tercatat di outbox).

## Komponen

- Data (`catalog.dart`): `archiveProduct`, `restoreProduct`,
  `listArchivedProducts` (memakai pemuat katalog yang sama dengan
  `archived: true`), `ProductCatalog.archivedCount` di Flutter dari
  `countArchivedProducts`.
- Flutter: `CatalogRepository.archive/restore/archived`,
  `ProductFormViewModel.archive` (Command0), tombol *Arsipkan produk* di
  bawah form (hanya produk lama), `ArchivedProductsViewModel` + dialog
  *Produk diarsipkan*.

## Pengujian

- Data: arsip menyembunyikan produk dari katalog dan Kasir, riwayat nota
  tetap; arsip produk yang sudah diarsipkan → `ProductNotFound`; pulihkan
  mengembalikan; pulihkan dengan barcode sudah dipakai → `ProductCodesTaken`;
  tenant lain tidak terlihat.
- Flutter: VM form (arsip lalu selesai), VM daftar arsip (muat, pulihkan,
  galat kode), widget 1280/360 px (konfirmasi dengan peringatan stok, dialog
  pulihkan).
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Arsipkan produk dari form 1.16 | "Hapus = arsip" | Rilis v0.35.0 | |
| Pulihkan produk diarsipkan | — | Rilis v0.35.0 | Dialog dari 1.15. |
| Tanggal arsip di dialog | — | Belum | Layar produk belum memegang zona waktu cabang. |
| Hapus permanen | — | Tidak direncanakan | Riwayat dan ledger menunjuk varian. |
