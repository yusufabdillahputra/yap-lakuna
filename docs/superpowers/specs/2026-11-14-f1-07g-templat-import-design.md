# F1-07g · Templat berkas import (produk, pelanggan, supplier)

- **Fase:** 1
- **Status:** Dikerjakan
- **Layar:** dialog import di 1.15 Produk, 1.20 Pelanggan, 1.21 Supplier:
  tombol *Unduh templat* di samping *Pilih berkas*.
- **Acuan:** gap "Templat berkas untuk diunduh" di F1-07b, F1-13 (import
  pelanggan) dan F1-14b. Storeku belum punya templat; perbedaan dicatat di
  sini.

## Tujuan

Pemilik yang belum pernah import tidak perlu menebak judul kolom: unduh
templat Excel, isi, lalu import.

## Aturan

1. **Isi templat** (.xlsx satu lembar, baris judul tebal dan dibekukan):
   - Produk: Nama, Kategori, Jenis, Satuan, SKU, Barcode, Harga beli, Harga
     jual, Stok awal, Stok minimum.
   - Pelanggan: Nama, HP, Alamat, Grup, Limit, Catatan.
   - Supplier: Nama, Kontak, Telepon, Kategori, Tempo (hari), Alamat,
     Catatan.
   Judul memakai Bahasa Indonesia (dikenali di kedua bahasa aplikasi), lalu
   **dua baris contoh** yang lolos import tanpa ditolak.
2. Judul templat dibuat di `lakuna_domain` bersama pembaca import, dan tes
   memastikan templat terbaca utuh oleh pembacanya sendiri (tidak ada
   kolom yang tidak dikenali, contoh tidak ditolak).
3. **Simpan:** lewat `SpreadsheetExporter` yang sama dengan ekspor
   laporan: desktop menyimpan ke folder dokumen Lakuna dan menampilkan
   lokasinya; Android/iOS membuka share sheet. Nama berkas
   `templat-import-produk.xlsx` / `-pelanggan` / `-supplier`.
4. Tidak butuh izin tambahan: tombol ada di dialog import, yang sudah
   dibatasi izin modulnya. Templat tidak memuat data toko.
5. Baris contoh memakai data fiktif yang jelas (mis. "Contoh Kopi Susu");
   pengguna menimpa atau menghapusnya sebelum import.

## Komponen

- Domain: `productImportTemplate`, `customerImportTemplate`,
  `supplierImportTemplate` (`List<List<String>>`).
- Flutter: `import_template.dart` (`saveImportTemplate(exporter, kind)`),
  tombol `*-import-template` di tiga dialog, `exporter` diteruskan dari
  router ke layar Produk/Pelanggan/Supplier.

## Pengujian

- Domain: tiap templat dibaca pembacanya → 2 baris sah, 0 ditolak, tiap
  judul dikenali.
- Flutter: tombol menyimpan `.xlsx` (nama berkas, isi bisa dibaca
  `readTableFile` → pembaca import), pesan lokasi / galat; widget 1280 /
  360 px.
- Uji manual Xvfb: unduh templat supplier, import berkas itu.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Templat import produk/pelanggan/supplier | — | Dikerjakan | |
| Templat berbahasa Inggris | — | Belum | Judul Indonesia dikenali di kedua bahasa; templat EN bila diminta. |
