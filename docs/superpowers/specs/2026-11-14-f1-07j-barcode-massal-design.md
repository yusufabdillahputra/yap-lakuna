# F1-07j · Buat barcode massal dari Cetak label

- **Fase:** 1
- **Status:** Rilis v0.58.0
- **Layar:** 1.15b Cetak label barcode.
- **Acuan:** F1-07h (barcode EAN-13 toko, `generateStoreEan13`), F1-07i
  (peringatan kode terlalu panjang), F1-07e (label barcode).
- **Menutup gap:** F1-07h "Buat barcode massal untuk semua produk tanpa
  kode".

## Tujuan

Toko yang baru mulai memakai label biasanya punya puluhan barang tanpa
barcode pabrik. Membuka form tiap produk untuk menekan *Buat barcode* terlalu
lama. Dari layar Cetak label, pemilik bisa membuat barcode EAN-13 toko untuk
banyak varian sekaligus, lalu langsung mencetak labelnya.

## Aturan

1. **Kandidat** hanya baris **varian** (bukan satuan konversi, F1-07h aturan
   5) yang barcode-nya kosong. Ada dua pintu:
   - **Produk tanpa kode** (tanpa SKU dan barcode, baris tidak bisa
     dipilih): tombol *Buat barcode untuk N produk tanpa kode*
     (`labels-generate-missing`) di atas daftar, tampil bila N > 0. N =
     jumlah produk; dialog menyebut jumlah barcode (varian). Varian yang
     barcodenya terisi tetapi tidak bisa digambar tidak termasuk.
   - **Kode terlalu panjang** (F1-07i): tombol *Ganti dengan barcode
     EAN-13* (`labels-generate-dense`) di dalam peringatan, untuk baris
     terpilih yang terlalu rapat dan masih memakai SKU (barcode kosong).
     Baris berbarcode yang terlalu rapat tidak diubah.
2. **Konfirmasi** dulu lewat dialog (`labels-generate-confirm`) yang
   menyebut jumlah varian dan bahwa barcode disimpan ke produk (bisa diubah
   lagi di form produk). SKU tidak diubah.
3. **Kode** = `generateStoreEan13` (awalan 20). Tidak boleh sama, menurut
   kunci barcode, dengan SKU atau barcode varian/satuan lain di katalog
   yang dimuat maupun kode lain yang dibuat di aksi yang sama.
4. **Simpan** per produk lewat `CatalogRepository.save(product.toDraft()
   dengan barcode baru)`: validasi, cek kode kembar per tenant, outbox
   sinkronisasi, dan izin sama dengan form produk. Katalog **dimuat ulang
   tepat sebelum** draft dibuat, agar perubahan produk dari tempat lain
   setelah layar dibuka tidak tertimpa. Baris yang tidak berubah tidak
   ditulis ulang (hanya `product_variants` yang barcodenya diisi masuk
   outbox). Produk diproses berurutan; bila satu gagal (mis. data lama tidak
   valid), produk itu dilewati, sisanya tetap disimpan, dan pesan menyebut
   nama produk yang gagal beserta alasannya. Bila semuanya gagal, galatnya
   ditampilkan.
4a. **Form produk di bawahnya.** Cetak label yang dibuka dari form produk
   (tombol *Cetak label*) bisa membuat barcode untuk produk itu. Saat
   kembali, form mengisi field barcode varian yang masih kosong dari data
   tersimpan (`ProductFormViewModel.refreshBarcodes`), sehingga *Simpan* di
   form tidak mengosongkan barcode baru. Isian lain di form tidak disentuh.
5. **Setelah berhasil** katalog dimuat ulang. Baris yang baru mendapat
   barcode langsung dipilih (jumlah 1) bila sebelumnya tidak terpilih;
   jumlah baris yang sudah terpilih dipertahankan. Pesan sukses
   (`labels-generated`) menyebut jumlah varian.

## Komponen

- `BarcodeLabelViewModel`: simpan `CatalogProduct` hasil muat;
  `missingCodeRows`, `denseWithoutBarcode`, `Command1<int, List<LabelRow>>
  generateBarcodes` (+ `Random` yang bisa disuntik untuk tes).
  `LabelRow.hasBarcode`, `isUnit`, `variantId`.
- Fungsi murni `assignStoreBarcodes(products, variantIds, random)` →
  `List<ProductDraft>` (di file view model, diuji langsung).
- View: tombol, dialog konfirmasi, pesan sukses/galat.
- `CatalogProduct.toDraft({barcodes})` (`lakuna_data`) mengganti barcode
  varian per ID.
- l10n: `labelsGenerateMissing`, `labelsGenerateDense`,
  `labelsGenerateTitle`, `labelsGenerateBody`, `labelsGenerateConfirm`,
  `labelsGenerateCancel`, `labelsGenerated`; galat memakai pesan form
  produk (`productErrorMessage`).

## Pengujian

- Unit: `assignStoreBarcodes` mengisi hanya varian yang diminta dan
  barcode-nya kosong, kode unik terhadap katalog (SKU, barcode varian dan
  satuan) dan satu sama lain, data lain draft tidak berubah.
- Data: `toDraft(barcodes)` lalu simpan hanya mengubah barcode varian itu
  (satuan, grosir, status nonaktif, stok tetap; outbox hanya
  `product_variants`).
- VM: produk tanpa kode → dibuat, tersimpan, baris kini bisa dipilih dan
  terpilih; baris padat ber-SKU → diganti, jumlah tetap; satu produk gagal
  → lainnya tersimpan dan yang gagal disebut; semua gagal → galat; harga
  yang diubah setelah layar dibuka tidak tertimpa; barcode tak tergambar
  tidak ditawarkan.
- Widget: barcode yang dibuat dari Cetak label (dibuka dari form) tetap ada
  setelah kembali dan *Simpan* di form.
- Widget 1280/360: tombol → dialog → konfirmasi → pesan sukses dan baris
  terpilih; tombol di peringatan padat.
- Uji manual Xvfb: produk tanpa kode, buat barcode massal, cetak.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Buat barcode untuk produk tanpa kode | — | Rilis v0.58.0 | Dari layar Cetak label. |
| Ganti SKU terlalu panjang dengan EAN-13 | — | Rilis v0.58.0 | Dari peringatan F1-07i. |
| Buat barcode untuk satuan konversi | — | Tidak direncanakan | Satuan biasanya punya barcode dus pabrik. |
| Batalkan barcode massal | — | Belum | Ubah per produk di form. |
| Kode produk diarsipkan | — | Terbatas | Produk diarsipkan tidak ikut dimuat, jadi kodenya tidak dihindari. Bentrok di rentang `20…` praktis tidak terjadi; bila terjadi, memulihkan produk itu ditolak *Sudah dipakai*. |
| Kategori yang sudah dihapus | — | Catatan | Sama seperti form: menyimpan ulang produk yang kategorinya terhapus mengosongkan kategorinya. |
| Simpan hanya kolom barcode | — | Belum | Saat ini seluruh produk disimpan ulang dari data terbaru (tanpa cek versi); kolom yang tidak berubah tidak ditulis. |
