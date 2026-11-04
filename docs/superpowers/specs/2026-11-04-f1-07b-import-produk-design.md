# F1-07b — Import produk dari CSV / XLSX

- **Status:** Dikerjakan
- **Layar:** 1.15 Produk (tombol *Import Excel*)
- **Acuan:** spec Storeku F1-07 (Import Excel: kolom nama, kategori, SKU,
  barcode, satuan, harga beli, harga jual, stok awal) dan pola import
  pelanggan Lakuna F1-13 (`customer_import.dart`, `table_file.dart`).

## Tujuan

Pemilik UMKM biasanya sudah punya daftar barang di Excel. Import mengisi
katalog sekaligus tanpa mengetik satu per satu, dengan pratinjau baris yang
sah dan yang ditolak sebelum disimpan.

## Aturan

1. **Berkas:** CSV (koma / titik koma) atau XLSX, paling besar 2 MB, baris
   pertama judul. Pembaca berkas sama dengan import pelanggan.
2. **Kolom** (judul tidak peka huruf, Indonesia atau Inggris):
   | Kolom | Judul yang dikenali | Wajib | Bawaan |
   | --- | --- | --- | --- |
   | Nama | `nama`, `nama produk`, `name`, `product` | Ya | — |
   | Kategori | `kategori`, `category` | | kosong |
   | Jenis | `jenis`, `type`, `kind` (`barang`/`goods`, `jasa`/`service`, `menu`) | | barang |
   | Satuan | `satuan`, `unit` | | `pcs` |
   | SKU | `sku`, `kode`, `code` | | kosong |
   | Barcode | `barcode` | | kosong |
   | Harga beli | `harga beli`, `cost`, `cost price` | | 0 |
   | Harga jual | `harga jual`, `harga`, `price`, `sell price` | Ya | — |
   | Stok awal | `stok awal`, `stok`, `stock`, `opening stock` | | 0 |
   | Stok minimum | `stok minimum`, `min stok`, `min stock` | | 0 |
3. **Satu baris = satu produk satu varian.** Varian, satuan konversi, dan
   harga grosir tetap lewat form produk.
4. **Angka:** rupiah memakai `parseImportMoney` (bulat, `Rp 1.500.000`,
   `1,500,000`, desimal nol). Jumlah stok memakai format Indonesia
   (`1.500`, `1,5`); bila gagal, format ekspor Excel (`1.5`). Stok awal dan
   minimum diabaikan untuk jasa dan menu (tidak melacak stok).
5. **Baris ditolak di pratinjau** (alasan enum + terjemahan, nomor baris
   asli berkas): nama kosong / terlalu panjang, harga jual kosong atau tidak
   sah, harga beli tidak sah, stok tidak sah, jenis tidak dikenal, teks
   terlalu panjang (`validateProductDraft`), SKU/barcode atau nama kembar di
   dalam berkas.
6. **Produk yang sudah ada dilewati, bukan ditimpa.** Saat menyimpan, baris
   yang nama produknya (tanpa beda huruf/spasi) atau SKU/barcode-nya sudah
   dipakai produk aktif dilewati dan dilaporkan sebagai *sudah ada*.
   Import ulang berkas yang sama tidak menggandakan produk atau stok.
7. **Satu transaksi:** semua produk baru, kategori/satuan baru, dan stok
   awal (ledger `stock_movements` sumber `opening`) ditulis dalam satu
   `LakunaStore.write`; satu galat membatalkan semuanya.
8. **Izin:** `products:manage`, dicek di repositori.

## Komponen

- `lakuna_domain/lib/src/product_import.dart`: `productImportRows(table)`
  → `ProductImportResult` (`rows`, `rejected`, `missingColumns`),
  `ProductImportRejectReason`.
- `lakuna_data`: `importProducts(store, scope, staffId:, rows:)` →
  `ProductImportSummary(created, skippedLines)`; memakai `_ProductWriter`
  yang sama dengan `saveProduct`.
- `CatalogRepository.importRows(rows)`; lokal + palsu.
- `ProductImportViewModel` + `ProductImportDialog` (pola import pelanggan),
  tombol `products-import` di header 1.15.

## Pengujian

- Domain: judul ID/EN, kolom wajib hilang, bawaan, angka (rupiah, stok
  `1.500`/`1,5`/`1.5`), jenis, kembar di berkas, stok diabaikan untuk jasa.
- Data: produk + varian + stok awal tercatat di ledger, kategori dipakai
  ulang, nama/SKU/barcode yang sudah ada dilewati, import ulang idempoten.
- Flutter: view model (pilih berkas, masalah berkas, jalankan), widget
  dialog 1280 dan 360 px, tombol tersembunyi tanpa izin.
- Uji manual Xvfb dengan berkas CSV contoh.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Import produk baru CSV/XLSX | 1.15 | Dikerjakan | |
| Perbarui harga produk lama lewat import | — | Belum | Import hanya menambah; ubah harga lewat form. |
| Varian / satuan konversi / grosir lewat import | — | Belum | Satu baris satu varian. |
| Templat berkas untuk diunduh | — | Belum | Judul kolom dijelaskan di dialog. |
