# F1-07k · Perbarui harga produk lama lewat import

- **Fase:** 1
- **Status:** Rilis v0.59.0
- **Layar:** 1.15 Produk, dialog *Import Excel*.
- **Acuan:** F1-07b (import produk), F1-07g (templat import).
- **Menutup gap:** F1-07b "Perbarui harga produk lama lewat import".

## Tujuan

Harga dari pemasok sering naik serentak. Pemilik UMKM biasanya mengubah
harga di Excel lalu ingin memasukkannya sekaligus. Sampai v0.58 import hanya
menambah produk baru; produk yang sudah ada dilewati. Modul ini menambah
pilihan untuk memperbarui harga produk yang cocok.

## Aturan

1. **Sakelar** *Perbarui harga produk yang sudah ada*
   (`product-import-update`) di dialog import, mati secara bawaan. Bila mati,
   perilaku sama dengan F1-07b (produk yang ada dilewati).
2. **Pencocokan** baris berkas ke varian yang ada (produk aktif, tidak
   dihapus, tenant yang sama), berurutan:
   - SKU baris = SKU varian (`normalizeCode`), dan/atau barcode baris =
     barcode varian (`barcodeKey`). Bila SKU dan barcode menunjuk varian
     berbeda, baris **dilewati**.
   - Kode baris yang lain bertentangan dengan kode varian yang sudah terisi
     (mis. SKU cocok tetapi barcode baris berbeda dari barcode varian):
     dilewati, karena bisa salah ketik.
   - Kode yang dimiliki lebih dari satu varian (data lama atau hasil
     sinkronisasi): dilewati, tidak memilih salah satu.
   - Barcode baris = barcode **satuan konversi** (mis. dus): dilewati,
     karena harga baris adalah harga satuan dasar.
   - Tanpa kecocokan kode, dan baris **tidak** punya SKU maupun barcode:
     nama produk (tanpa beda huruf/spasi). Dipakai hanya bila produk itu
     punya tepat satu varian; bila lebih, dilewati (ambigu).
   - Baris yang punya kode tetapi kodenya tidak cocok, sementara namanya
     sudah dipakai: dilewati (kemungkinan produk lain bernama sama).
   - Varian yang sudah diperbarui baris lain di berkas yang sama:
     dilewati (satu varian sekali per import).
   - Tidak cocok sama sekali: dibuat sebagai produk baru (F1-07b). Produk
     yang diarsipkan tidak dicocokkan (sama seperti F1-07b).
3. **Yang diperbarui** pada varian yang cocok:
   - harga jual (kolom wajib);
   - harga beli, hanya bila sel harga beli baris terisi;
   - stok minimum, hanya bila sel stok minimum terisi, jenis baris
     melacak stok (baris jasa/menu tidak membawa stok minimum), dan produk
     yang cocok melacak stok.
   Nama, kategori, jenis, satuan, SKU, barcode, harga satuan konversi, dan
   grosir **tidak** diubah (harga grosir bisa jadi lebih tinggi dari harga
   jual baru; panduan mengingatkan untuk memeriksanya). Hanya baris
   `product_variants` yang ditulis; `products.updated_at` tidak berubah. Kolom stok awal **diabaikan** untuk produk yang ada (stok hanya
   lewat ledger: pembelian / penyesuaian stok).
4. **Tanpa perubahan**: varian yang nilainya sudah sama dihitung *tidak
   berubah* dan tidak ditulis (tidak masuk outbox).
5. **Ringkasan**: produk baru, varian diperbarui, tidak berubah, dan nomor
   baris yang dilewati.
6. Semua dalam satu transaksi `LakunaStore.write` seperti F1-07b; varian
   diperbarui lewat `SyncTx.update` dengan cap versi/HLC (outbox).
7. **Izin** `products:manage` (sama dengan import).

## Komponen

- Domain: `ProductImportRow.hasCost`, `hasMinStock` (sel terisi).
- Data: `importProducts(..., updateExisting:)`,
  `ProductImportSummary.updated`, `unchanged`.
- `CatalogRepository.importRows(rows, {updateExisting})`; lokal + palsu.
- `ProductImportViewModel.updateExisting` + `setUpdateExisting`; dialog:
  sakelar + ringkasan.
- l10n: `productImportUpdate`, `productImportUpdateNote`,
  `productImportDoneUpdate` (jamak di EN), `productImportSkippedUnclear`.

## Pengujian

- Domain: `hasCost` / `hasMinStock` mengikuti sel terisi.
- Data: cocok SKU, barcode (termasuk UPC-A 13 digit), nama (satu varian);
  harga beli/stok min kosong tidak menimpa; stok awal diabaikan; SKU vs
  barcode beda varian dilewati; barcode satuan dilewati; nama dengan banyak
  varian dilewati; kode tak cocok + nama sama dilewati; kode bertentangan
  dilewati; kode kembar data lama dilewati; produk banyak varian hanya
  varian ber-SKU itu; baris jasa tidak menimpa stok minimum; tidak berubah
  tidak menulis outbox; sakelar mati = perilaku lama; produk diarsipkan
  tidak diperbarui; varian di dua baris diperbarui sekali.
- VM + widget 1280/360: sakelar, ringkasan.
- Uji manual Xvfb dengan CSV harga baru.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Perbarui harga jual/beli/stok min lewat import | — | Rilis v0.59.0 | Sakelar di dialog import. |
| Perbarui harga varian lain / satuan konversi / grosir | — | Belum | Satu baris satu varian; grosir lewat form. |
| Pratinjau perubahan harga sebelum simpan | — | Belum | Ringkasan setelah simpan saja. |
