# F1-07h · Barcode otomatis & pemindaian UPC-A 13 digit

- **Fase:** 1
- **Status:** Rilis v0.55.0
- **Layar:** 1.16 Form produk (field *Barcode* varian), 1.4 Kasir (scan),
  1.18 Stok (cari / penyesuaian), 1.20 Pembelian (scan).
- **Acuan:** F1-07 (SKU/barcode unik per tenant), F1-07e (label barcode,
  gap *Buat barcode otomatis* dan *UPC-A dibaca 13 digit*).
- **Menutup gap:** F1-07e "Buat barcode otomatis untuk produk tanpa kode" dan
  "UPC-A dibaca pemindai sebagai 13 digit (awalan 0)".

## Tujuan

Barang buatan sendiri (kue, racikan, barang curah) sering tidak punya
barcode pabrik. Pemilik bisa membuat barcode toko dengan satu ketukan, lalu
mencetak labelnya (F1-07e) dan kasir cukup memindai. Selain itu, sebagian
pemindai membaca barcode UPC-A (12 digit, barang impor) sebagai EAN-13
dengan awalan `0`; kasir tetap harus menemukan produknya.

## Aturan

1. **Kunci barcode** (`barcodeKey`, `lakuna_domain`): kode dinormalkan
   (`normalizeCode`: trim + huruf besar); bila hasilnya 13 digit, diawali
   `0`, dan digit periksanya benar, awalan `0` dibuang sehingga sama dengan
   UPC-A 12 digit. Kode lain tetap.
2. **Pemindaian** memakai kunci barcode: Kasir (scan Enter), Stok (cari
   persis dan *Scan / tambah produk*), Pembelian (*Scan / cari produk*),
   serta pencarian daftar produk (1.15) dan Cetak label (1.15b) sebagai
   kecocokan persis di samping pencarian *mengandung*.
   `0012345678905` menemukan produk berbarcode `012345678905`, dan
   sebaliknya. SKU tetap dibandingkan dengan `normalizeCode` saja.
3. **Keunikan**: barcode dianggap sama bila kuncinya sama, baik di dalam
   form (validasi domain), saat simpan (cek tenant di `lakuna_data`), maupun
   saat import (lewati baris duplikat). Barcode yang tersimpan tidak diubah.
4. **Buat barcode**: tombol ikon di field *Barcode* varian (form 1.16),
   tampil hanya selama field kosong. Kode = EAN-13 toko: awalan `20`
   (rentang GS1 untuk pemakaian internal toko) + 10 digit acak + digit
   periksa. Kode tidak boleh sama (menurut kunci barcode) dengan barcode
   lain di form atau di katalog yang dimuat, dan tidak sama dengan SKU
   (Kasir juga mencocokkan scan dengan SKU); generator mengulang sampai
   unik (maks. 1.000 percobaan). Pengecekan akhir tetap di simpan
   (aturan 3).
5. Barcode satuan konversi tidak mendapat tombol: satuan konversi biasanya
   punya barcode dus dari pabrik; pemilik tetap bisa mengetik kode.
6. Barcode buatan langsung dicetak sebagai EAN-13 di label (F1-07e).

## Komponen

- Domain (`barcode.dart`): `barcodeKey`, `sameBarcode`,
  `generateStoreEan13(Random, {isTaken})`; `ProductDraft.barcodes` dan
  validasi duplikat memakai `barcodeKey`; import memakai `barcodeKey`.
- Data (`catalog.dart`): `_checkCodes` dan cek duplikat import memakai
  `barcodeKey` untuk barcode.
- Flutter: `ProductFormViewModel.generateBarcode(i)` (+ `random` yang bisa
  disuntik untuk tes), tombol `variant-<key>-barcode-generate`; Kasir, Stok,
  Pembelian memakai `sameBarcode`.
- l10n: `productGenerateBarcode` (tooltip/label tombol).

## Pengujian

- Domain: `barcodeKey` (UPC-A, EAN-13 awalan 0, digit periksa salah, kode
  huruf), `generateStoreEan13` (13 digit, awalan 20, digit periksa benar,
  mengulang bila terpakai), validasi duplikat UPC-A vs 0+UPC-A.
- Data: simpan produk dengan `0`+UPC-A ditolak bila UPC-A sudah dipakai.
- VM: Kasir/Stok/Pembelian menemukan produk lewat 13 digit; form
  `generateBarcode` mengisi kode unik.
- Widget: tombol muncul saat kosong, mengisi field, hilang setelah terisi.
- Uji manual Xvfb: buat barcode di produk baru, simpan, cetak label EAN-13,
  scan kode di Kasir.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Pemindaian UPC-A 13 digit (awalan 0) | — | Rilis v0.55.0 | Kasir, Stok, Pembelian, cari produk, Cetak label. |
| Buat barcode EAN-13 toko | — | Rilis v0.55.0 | Awalan 20, varian saja. |
| Data lama dengan UPC-A dan 0 + UPC-A di dua produk | — | Terbatas | Sejak v0.55.0 dianggap kembar: menyimpan salah satunya ditolak *Sudah dipakai* sampai salah satu kode diubah; scan Kasir memilih produk pertama. |
| Buat barcode massal untuk semua produk tanpa kode | — | Rilis v0.58.0 | [F1-07j](2026-11-14-f1-07j-barcode-massal-design.md): dari layar Cetak label. |
| Barcode timbangan berisi harga/berat (awalan 2x) | — | Tidak direncanakan Fase 1 | Awalan 20 dipakai untuk kode toko biasa. |
