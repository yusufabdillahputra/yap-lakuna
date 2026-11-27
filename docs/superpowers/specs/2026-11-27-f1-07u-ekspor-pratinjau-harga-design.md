# F1-07u · Ekspor pratinjau import harga ke Excel

- **Fase:** 1
- **Status:** Rilis v0.162.0
- **Layar:** 1.15 Produk, dialog *Import Excel*, kartu pratinjau perubahan.
- **Acuan:** gap 25 di `GAP-FASE1.md` dan gap
  [F1-07m](2026-11-14-f1-07m-pratinjau-harga-import-design.md) *Ekspor
  pratinjau ke Excel*.

## Masalah

Pratinjau F1-07m hanya menampilkan 30 perubahan pertama, lalu *dan X
perubahan lainnya*. Untuk daftar harga ratusan baris dari supplier,
pemilik tidak bisa memeriksa sisanya sebelum menekan *Simpan*, dan tidak
bisa membagikan daftar itu ke orang lain untuk dicek.

## Aturan

1. Kartu pratinjau punya tombol **Unduh Excel**
   (`product-import-preview-export`) bila ada perubahan atau baris yang
   dilewati. Pratinjau tanpa keduanya (hanya produk baru atau tidak ada
   yang berubah) tidak menampilkan tombol.
2. Isi Excel satu lembar *Pratinjau harga*, baris judul tebal dan
   dibekukan. Kolom: Baris, Produk, Varian, Harga jual lama, Harga jual
   baru, Harga beli lama, Harga beli baru, Stok minimum lama, Stok minimum
   baru, Satuan, Keterangan.
   - **Semua** perubahan (tanpa batas 30), Keterangan *Diperbarui*. Harga
     rupiah sebagai angka berformat ribuan. Harga beli dan stok minimum
     hanya terisi bila ikut berubah (sama dengan layar); stok minimum
     ditulis seperti di layar (mis. `1,5`) dengan satuan dasarnya.
   - Baris yang dilewati: hanya nomor baris dan Keterangan *Dilewati:
     cocoknya ragu*.
   - Urut nomor baris berkas.
   - Produk baru tidak dicantumkan (pratinjau hanya menghitungnya).
3. Nama berkas `pratinjau-harga-<nama berkas import>.xlsx` huruf kecil,
   tanpa ekstensi asal (mis. `Harga Baru 2026.csv` →
   `pratinjau-harga-harga-baru-2026.xlsx`), paling panjang 60 karakter
   nama; nama tanpa huruf/angka ASCII menjadi `pratinjau-harga.xlsx`.
4. Desktop menyimpan di folder dokumen Lakuna dan menampilkan *Excel
   disimpan di …*; ponsel membuka lembar bagikan. Galat: *Ekspor gagal.
   Coba lagi.*
5. Pesan ekspor hilang saat pratinjau dihapus (ganti berkas, ubah sakelar,
   lihat pratinjau ulang). Hasil ekspor yang selesai setelah pratinjau
   berganti dibuang. Setelah *Simpan*, pratinjau dan tombol ekspor tidak
   tampil lagi.
6. Tidak ada tulisan data; izin sama dengan pratinjau.

## Komponen

- `ProductImportViewModel`: `exporter`, `export` (`Command1<String?,
  Uint8List>`), `canExport`, `exportPath`, `exportFileName`.
- `productImportPreviewWorkbook(l10n, summary)` di
  `product_import_dialog.dart` memakai `buildXlsx`.
- l10n: `productImportPreviewExport`, `productImportXlsxSheet`,
  `productImportCol*`, `productImportXlsxUpdated`,
  `productImportXlsxSkipped`; pesan simpan/gagal memakai kunci ekspor yang
  sudah ada (`historyExportSaved` / `historyExportFailed`).

## Pengujian

- VM: ekspor hanya setelah pratinjau, nama berkas, lokasi, galat,
  dihapus oleh sakelar/berkas/pratinjau ulang, nonaktif setelah simpan.
- Isi Excel dibaca kembali dengan `readTableFile`: kolom, semua perubahan,
  baris dilewati, urutan.
- Widget desktop dan 360 px: pratinjau → Unduh Excel → berkas tersimpan.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Ekspor pratinjau import harga ke Excel | — | Rilis v0.162.0 | Semua perubahan + baris dilewati. |
| Produk baru di Excel pratinjau | — | Belum | Dry run hanya menghitung produk baru. |
| Stok minimum sebagai angka di Excel | — | Belum | Ditulis seperti di layar (`1,5`) agar pecahan terbaca; belum bisa dijumlah di Excel. |
