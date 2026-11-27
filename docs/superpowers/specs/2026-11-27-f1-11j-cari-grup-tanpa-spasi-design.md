# F1-11j — Cari Riwayat: nama grup modifier, kata tanpa spasi, garis miring Unicode

Tanggal: 2026-11-27 · Modul: F1-11 Riwayat (1.14, kolom *Cari*) dan
pencarian HP F1-13d · Gap 13 di `docs/superpowers/GAP-FASE1.md`, gap 92 di
STATUS-JEDA · Rilis: v0.149.0

## Masalah

Tiga celah kecil di pencarian yang tercatat di spec sebelumnya:

1. **Nama grup modifier** (F1-11f). `topping` atau `level` tidak menemukan
   nota, padahal kasir F&B sering mengingat "yang pakai topping" tanpa ingat
   nama opsinya. Nama grup sudah disalin ke nota
   (`sale_item_modifiers.group_name`).
2. **Kata tanpa spasi** (F1-11e). `5kg` tidak menemukan *Beras 5 kg*.
   Arah sebaliknya sudah cocok: `5 kg` dipecah menjadi `5` dan `kg`, dan
   keduanya ada di *Beras 5kg*.
3. **Garis miring Unicode lain** (F1-13f). U+2044 *fraction slash* dan
   U+29F8 *big solidus* tidak dianggap `/`, jadi `0813⁄2222` tidak
   dicocokkan ke HP.

## Aturan

1. Setiap kata kunci (F1-11e) boleh cocok dengan nama produk, nama varian,
   catatan barang, nama modifier, **atau nama grup modifier** dari baris
   barang yang sama.
   - Nama grup hanya dari modifier yang dipilih di baris itu (salinan
     nota). Grup yang tidak dipilih di baris itu tidak cocok.
   - `kopi topping` menemukan *Es Kopi Susu* dengan opsi apa pun dari grup
     *Topping*. `roti topping` tidak cocok bila topping ada di barang lain
     di nota yang sama.
   - Barang yang cocok lewat nama grup ikut ditulis di baris hasil
     (F1-11i).
   - Nama grup yang umum (*Gula*, *Es*) membuat hasil lebih luas: `gula`
     juga menemukan minuman dengan pilihan grup *Gula*. Tambah kata lain
     (`gula pasir`) untuk menyaring.
2. Kata kunci juga cocok bila ada di kolom yang sama **setelah spasinya
   dibuang**, tanpa beda huruf. `5kg` cocok dengan *Beras 5 kg*, `kopisusu`
   dengan *Kopi Susu*.
   - Berlaku untuk semua kolom barang di aturan 1.
   - Hanya spasi biasa (U+0020) yang dibuang. Nama hanya di-*trim* saat
     disimpan, jadi spasi tak putus di tengah nama (mis. tersalin dari
     Excel) tidak dibuang; nama seperti itu jarang dan tetap cocok lewat
     `5 kg`.
   - Kata dicocokkan per kolom: `pandan5kg` tidak cocok dengan produk
     *Beras Pandan* bervarian *5 kg*.
   - Karena spasi dibuang, kata pendek bisa cocok melintasi batas kata
     (`teh` menemukan *Sate Hati*). Ini diterima: pencarian sudah memakai
     "memuat", dan kata yang lebih panjang menyaringnya.
   - Nomor nota, nama pemesan, pelanggan, dan referensi bayar tidak
     berubah (tetap dicocokkan apa adanya).
3. Garis miring Unicode U+2044 dan U+29F8 dianggap `/` di kata kunci HP,
   sejajar dengan U+2215 dan U+FF0F (F1-13f). Aturan ini berlaku di semua
   layar yang memakai `phoneSearchKeys`, termasuk *Pelanggan baru* dari
   kata pencarian.
4. Aturan lain tetap: `%` dan `_` literal, barang yang dihapus dari bill
   tidak ikut, filter dan batas 100 nota tetap, kata ke-9 dst. dicek di
   Dart.

## Rancangan teknis

- `lakuna_data` `history.dart` `_searchSales`:
  - Klausa per kata membandingkan `REPLACE(LOWER(kolom), ' ', '')` dengan
    `LOWER(%kata%)`. Kata kunci tidak berisi spasi, jadi bentuk ini
    mencakup pencocokan apa adanya. `REPLACE` dan `LOWER` ada di SQLite
    dan Postgres.
  - Subkueri modifier memeriksa `name` atau `group_name`.
  - `itemMatches` menerima pasangan nama dan grup modifier. Cek ulang Dart
    membuang spasi dengan cara yang sama.
- `lakuna_domain` `customer.dart`: `_unicodeSlashes` mendapat U+2044 dan
  U+29F8.
- Tanpa perubahan skema, l10n, atau UI. Panduan Riwayat ID/EN diperbarui.

## Pengujian

- Data (`history_test.dart`):
  - `topping` dan `kopi topping` menemukan nota bermodifier; `roti
    topping` dan `boba topping` (opsi tidak dipilih) tidak; `matchedItems`
    menulis barangnya.
  - `5kg` menemukan varian *5 kg*, `5 kg` menemukan *Gula 5kg*,
    `kopisusu` menemukan *Es Kopi Susu*, `extrashot` dan `tanpaes`
    menemukan modifier dan catatan; `5k_` dan `gula%5kg` tetap literal.
  - Diverifikasi mutasi (SQL dan Dart).
- Domain: `0813⁄2222` dan `0813⧸2222` cocok; draf pelanggan dari
  `021⁄5551234` mengisi HP.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Cari nama grup modifier | Rilis v0.149.0 | Hanya grup dari modifier yang dipilih di baris itu. |
| Kata tanpa spasi (`5kg` = `5 kg`) | Rilis v0.149.0 | Hanya di Riwayat. Pencarian produk di Kasir dan Produk masih apa adanya. |
| Garis miring Unicode U+2044 dan U+29F8 di HP | Rilis v0.149.0 | — |
| Kata tanpa spasi di pencarian produk Kasir/Produk | Belum | Ajukan bila pemilik memintanya. |
| Sorot kata kunci (gap 14) | Belum | Barang yang cocok lewat grup modifier atau tanpa spasi tidak memuat kata kunci apa adanya; sorotan perlu menangani keduanya. |
