# F1-10g · Kirim ke tiket dapur & catatan bebas per menu

- **Fase:** 1
- **Status:** Rilis v0.43.0
- **Layar:** 1.16b *Form menu* (tab *Modifier*: sakelar *Kirim ke tiket
  dapur* dan *Bisa catatan bebas*), 1.7 / 1.7e panel bill dan tiket dapur,
  1.8 lembar modifier.
- **Acuan:** spec F1-10 (bagian *Form produk › Modifier (1.16b)*, gap
  "Toggle *Kirim ke tiket dapur* / *Catatan bebas* per menu"), F1-10e
  (printer dapur). Storeku menunda sakelar yang sama; perbedaan dicatat di
  sini.
- **Menutup gap:** F1-10 "Toggle *Kirim ke tiket dapur* / *Catatan bebas*
  per menu".

## Tujuan

Menu yang tidak dimasak (air mineral botol, kerupuk, rokok) tidak perlu
mengisi tiket dapur, dan menu yang tidak bisa diubah tidak menerima catatan
bebas, sehingga tiket dapur hanya berisi pekerjaan dapur.

## Aturan

1. **Sakelar per produk.** Kolom baru `products.send_to_kitchen` dan
   `products.allow_note`, keduanya `bool` bawaan `true` (produk lama dan
   import tetap seperti sebelumnya). Diatur di tab *Modifier* form produk
   (1.16b) di bagian *Dapur*; berlaku untuk semua jenis produk. Izin sama
   dengan simpan produk (`products:manage`).
2. **Kirim ke dapur.** Saat *Kirim ke dapur*, item tertunda dari produk
   *Kirim ke tiket dapur* mati **tidak** masuk tiket; statusnya langsung
   *Disajikan* (diantar pelayan/kasir) tanpa nomor tiket, dan terkunci
   seperti item dapur. Bila semua item tertunda bukan menu dapur, tiket
   tidak dibuat (nomor tiket harian tidak terpakai) dan modal tiket tidak
   muncul; panel menampilkan pesan singkat *N item tanpa tiket dapur
   ditandai disajikan*. Cetak otomatis ke printer dapur (F1-10e) hanya
   bila ada tiket. Sakelar dibaca saat kirim (bukan saat item ditambahkan).
3. **Catatan bebas.** Produk *Bisa catatan bebas* mati: catatan yang
   dikirim bersama item diabaikan (`note` = `null`) di lapisan data. Di
   lembar menu, catatan yang sudah diketik tidak terpakai oleh menu itu
   dan tetap tersimpan untuk item berikutnya; lembar modifier 1.8 tidak
   menampilkan isian catatan.
4. Kasir Retail tidak berubah (tidak memakai tiket dapur).
5. Sinkronisasi: kedua kolom ikut baris `products` di outbox seperti
   kolom produk lain.

## Komponen

- Model `product.spy.yaml` + migrasi `f1-10g`; `ProductDraft` /
  `CatalogProduct` `sendToKitchen`, `allowNote`; `saveProduct` /
  `loadProduct` / daftar katalog.
- `sendToKitchen` membaca sakelar produk item tertunda;
  `KitchenSendResult.ticket` boleh `null` dan `served` berisi item
  non-dapur. `addBillItem` mengabaikan catatan untuk produk tanpa catatan
  bebas.
- Flutter: `ProductFormViewModel.sendToKitchen/allowNote`, dua `FSwitch`
  di tab *Modifier*; `DiningViewModel` menangani hasil tanpa tiket; lembar
  menu dan lembar modifier menghormati `allowNote`.

## Pengujian

- Domain/data: draft bawaan `true`; simpan/muat kedua sakelar; kirim ke
  dapur campuran (tiket hanya item dapur, item lain *Disajikan* tanpa
  tiket); hanya non-dapur (tanpa tiket, nomor tidak terpakai); catatan
  diabaikan; outbox.
- Flutter: VM form produk; VM meja (hasil tanpa tiket tidak membuka
  modal, tidak cetak otomatis); widget form 1.16b dan lembar menu
  1280 / 360 px.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Sakelar *Kirim ke tiket dapur* / *Bisa catatan bebas* | 1.16b | Rilis v0.43.0 | Di tab *Modifier* form produk, bagian *Dapur*. |
| Printer per stasiun (bar vs dapur) | — | Belum | Satu printer dapur per perangkat (F1-10e). |
| Sakelar berubah di perangkat lain saat layar Meja terbuka | — | Belum | Lembar menu memakai katalog saat layar dimuat; lapisan data tetap benar (catatan diabaikan sesuai sakelar terbaru). |
