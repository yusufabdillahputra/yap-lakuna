# F1-07g · Templat berkas import (produk, pelanggan, supplier)

- **Fase:** 1
- **Status:** Rilis v0.47.0
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
   **dua baris contoh** yang isinya sah. Kolom HP/Telepon, SKU, dan Barcode
   berformat teks (`@`) agar nol di depan tidak hilang saat pengguna
   mengetik baris baru di Excel; angka contoh (harga, stok, limit, tempo)
   ditulis sebagai angka.
2. Judul templat dibuat di `lakuna_domain` bersama pembaca import, dan tes
   memastikan templat terbaca utuh oleh pembacanya sendiri (tidak ada
   kolom yang tidak dikenali; contoh dengan nama diganti lolos tanpa
   ditolak).
3. **Simpan:** lewat `SpreadsheetExporter` yang sama dengan ekspor
   laporan: desktop menyimpan ke folder dokumen Lakuna dan menampilkan
   lokasinya; Android/iOS membuka share sheet. Nama berkas
   `templat-import-produk.xlsx` / `-pelanggan` / `-supplier`.
4. Tidak butuh izin tambahan: tombol ada di dialog import, yang sudah
   dibatasi izin modulnya. Templat tidak memuat data toko.
5. Baris contoh memakai data fiktif yang jelas (mis. "Contoh Gula Pasir
   1 kg"). Pembaca import **melewati** baris yang namanya sama dengan nama
   contoh templat (tanpa beda huruf besar/kecil), dengan alasan *baris
   contoh dari templat, ganti atau hapus*, agar data fiktif (stok awal,
   grup "Grosir", limit kredit) tidak ikut tersimpan bila pengguna lupa
   menghapusnya. Ini perbedaan dari rencana awal (contoh ikut diimport).

## Komponen

- Domain: `productImportTemplate`, `customerImportTemplate`,
  `supplierImportTemplate` (`List<List<String>>`),
  `isImportTemplateSample(name, template)`, alasan tolak `sample` di
  ketiga enum alasan import.
- Flutter: `import_template.dart`: `ImportTemplateKind` (nama berkas,
  lembar, isi .xlsx) dan widget `ImportFileActions` (tombol *Pilih
  berkas* + `import-template-<jenis>`, pesan `import-template-saved-…` /
  `-failed-…`), dipakai tiga dialog; `buildXlsx(textColumns:)`;
  `exporter` diteruskan dari router ke layar Produk/Pelanggan/Supplier.

## Pengujian

- Domain: tiap templat dibaca pembacanya → 2 baris dilewati sebagai
  contoh; nama diganti → 2 baris sah, 0 ditolak; tiap judul dikenali.
- Flutter: tombol menyimpan `.xlsx` (nama berkas, isi bisa dibaca
  `readTableFile` → pembaca import), pesan lokasi / galat; widget 1280 /
  360 px.
- Uji manual Xvfb: unduh templat supplier, import berkas itu.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Templat import produk/pelanggan/supplier | — | Selesai v0.47.0 | |
| Templat berbahasa Inggris | — | Belum | Judul Indonesia dikenali di kedua bahasa; templat EN bila diminta. |
| Share sheet di iPad | — | Catatan | Bukan gap: `share_plus` 13.3 (dipakai sejak v0.28) sudah memakai titik asal di tengah layar bila `sharePositionOrigin` kosong, jadi share sheet iPad tidak melempar galat. Belum diuji di iPad sungguhan. |
