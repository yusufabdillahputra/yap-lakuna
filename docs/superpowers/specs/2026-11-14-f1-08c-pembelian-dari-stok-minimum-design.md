# F1-08c · Buat pembelian dari daftar stok minimum

- **Fase:** 1
- **Status:** Rilis v0.49.0
- **Layar:** 1.18 Stok (panel/tab *Stok minimum*: tombol *Buat
  pembelian*) → 1.19 form pembelian baru yang sudah terisi.
- **Acuan:** gap *Buat pesanan pembelian dari daftar ini* di F1-08 (kanvas
  1.18) dan Storeku F1-08. Storeku belum membangunnya; perbedaan dicatat di
  sini.

## Tujuan

Pemilik melihat barang yang menipis lalu, dengan satu ketukan, membuka
draf pembelian berisi barang-barang itu dengan jumlah saran, tanpa
mencari produk satu per satu di form pembelian.

## Aturan

1. **Tombol** *Buat pembelian* (`stock-restock`, ikon keranjang) di bawah
   daftar *Di bawah stok minimum* (tab *Stok minimum* dan panel di tab
   *Penyesuaian*). Tampil hanya bila staf punya izin
   `purchases:manage` dan daftar tidak kosong; mati selama data lokasi
   dimuat (sama dengan F1-08b, baris harus milik lokasi terpilih).
2. **Isi form**: form *Pembelian baru* (1.19) terbuka dengan:
   - **lokasi terima** = lokasi stok yang sedang dilihat (bila masih ada);
   - satu baris per varian di bawah minimum, satuan dasar, **harga**
     bawaan form (harga modal varian), dan **jumlah saran**
     `2 × minimum − stok` (stok minus dihitung 0), dibulatkan **ke atas
     ke satuan utuh**, minimal 1. Contoh: stok 2, minimum 20 → 38;
     stok 12,5 kg, minimum 15 → 18 kg.
   - Supplier, nomor faktur, dan pembayaran tetap kosong/bawaan; staf
     memeriksa lalu menyimpan draf atau menerima seperti biasa.
3. Varian yang tidak bisa dibeli lagi (produk diarsip/dihapus atau bukan
   barang) dilewati; form menampilkan catatan jumlah barang yang
   dilewati. Catatan `purchase-restock-note`: "Diisi dari stok minimum
   <lokasi>: N barang. Periksa jumlah dan harga sebelum menyimpan."
4. Isian saran hanya dipakai sekali: setelah pembelian diterima dan form
   dikosongkan untuk pembelian berikutnya, form kembali kosong.
5. Tidak ada data baru di database: draf baru tercipta hanya saat staf
   menekan *Simpan draf* / *Terima barang*.
6. **Kembali ke Stok**: setelah form ditutup, layar Stok memuat ulang data
   lokasi sehingga daftar minimum tidak basi (barang yang baru diterima
   hilang dari daftar). Bila pembelian diterima, detail pembelian dibuka
   dulu (sama dengan daftar Pembelian). Ketukan ganda tidak membuka dua
   form.
7. Catatan menyebut lokasi yang benar-benar dipakai form; bila lokasi asal
   sudah dihapus, form memakai lokasi bawaan dan catatan menyebutnya.
8. Daftar di bawah minimum hanya ada di **lokasi bawaan** (minimum F1-08
   berlaku di sana), jadi tombol tidak tampil di lokasi lain.

## Komponen

- Domain: `restockQuantity(stock, minimum)` (`stock.dart`).
- `PurchaseRestock` (lokasi, nama lokasi, baris varian + jumlah) di
  `purchases_repository.dart`.
- `StockViewModel.restock` (dari `below`, hanya bila selaras dengan
  lokasi), `StockScreen.onRestock`, tombol di `_MinimumPanel`.
- `PurchaseFormViewModel(restock:)`, `PurchaseFormPage(restock:)`, rute
  `Routes.purchaseNew` membaca `extra`.

## Pengujian

- Domain: jumlah saran (bulat, desimal, minus, minimal 1).
- VM stok: `restock` berisi baris & lokasi; null saat memuat lokasi lain.
- VM form: baris terisi (jumlah, harga, lokasi), varian hilang dilewati,
  `startNew` kosong.
- Widget 1280 / 360 px: tombol hanya dengan izin, ketuk → form terisi.
- Uji manual Xvfb: Stok › Stok minimum › Buat pembelian → terima.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Pembelian dari stok minimum | 1.18 | Selesai v0.49.0 | |
| Supplier terakhir per barang | — | Belum | Belum ada data supplier per produk; staf memilih supplier di form. |
| Jumlah saran bisa diatur (kelipatan dus, target stok) | — | Belum | Rumus tetap 2 × minimum. Mengganti satuan baris (mis. pcs → dus) mempertahankan angka jumlah, jadi 38 pcs menjadi 38 dus; staf perlu mengubah jumlahnya. |
| Catatan isian setelah *Simpan draf* | — | Belum | Catatan tetap tampil; mengetuk *Buat pembelian* lagi membuat draf kedua berisi barang yang sama. |
