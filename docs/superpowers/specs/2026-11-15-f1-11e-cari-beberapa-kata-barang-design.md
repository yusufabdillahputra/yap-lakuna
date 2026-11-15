# F1-11e · Cari nota Riwayat dengan beberapa kata nama barang

- **Fase:** 1
- **Status:** Rilis v0.101.0
- **Layar:** 1.14 Riwayat (kolom *Cari*).
- **Acuan:** gap "Kata kunci melintasi nama produk + varian" di
  [F1-11d](2026-11-14-f1-11d-cari-nama-barang-design.md). Storeku tidak
  punya pencarian nama barang di riwayat.

## Masalah

Pencarian nama barang (F1-11d) mencocokkan kata kunci utuh ke nama produk
**atau** nama varian. Kasir yang mengetik `beras 5 kg` untuk produk *Beras
Premium* varian *5 kg* tidak menemukan apa pun, karena tidak ada satu
kolom yang memuat seluruh frasa itu. Begitu pula `teh melati` untuk
produk *Teh Celup* varian *Melati*.

## Aturan

1. Kata kunci dipecah per spasi putih (spasi, tab, spasi tak terputus;
   spasi ganda dan kata berulang diabaikan). Sebuah nota cocok
   lewat barang bila **satu baris barang** memuat **setiap kata** di nama
   produk atau nama varian saat transaksi, dengan urutan bebas dan tanpa
   beda huruf.
2. Kata yang tersebar di baris barang berbeda (mis. `bubuk pulsa` untuk
   nota berisi *Kopi Bubuk* dan *Isi Pulsa*) tidak cocok: pencarian
   mencari barang, bukan kombinasi barang.
3. Kata kunci satu kata berperilaku sama seperti F1-11d. Frasa yang
   memang ada utuh di satu nama (`kopi bubuk`) tetap ditemukan.
4. Nomor nota, nama/HP pelanggan, dan referensi pembayaran tetap
   dicocokkan dengan kata kunci utuh (F1-11b, F1-13d, F1-05b).
5. `%` dan `_` tetap literal; barang yang dihapus dari bill sebelum
   dibayar tetap tidak ikut; filter dan batas 100 nota tetap.

## Rancangan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): subkueri
  `sale_items` memakai `AND` per kata atas `(LOWER(product_name) LIKE
  LOWER(%kata%) OR LOWER(variant_name) LIKE LOWER(%kata%))`; cek ulang di
  Dart (`itemMatches`: `words.every`) agar wildcard tetap literal.
- Kata dikirim ke SQL **seperti diketik** (bukan huruf kecil Dart):
  `LOWER` SQLite hanya melipat A–Z, jadi `ÉSPRESSO` tetap cocok dengan
  nama `KOPI ÉSPRESSO` seperti F1-11d. Huruf kecil hanya untuk cek Dart.
- Paling banyak 8 kata (`_maxSqlWords`) masuk SQL; kata berikutnya hanya
  dicek di Dart. SQL hanya menyaring kandidat, jadi hasil tetap benar dan
  rantai `AND` tidak mencapai batas kedalaman ekspresi SQLite.
- Temuan review (Important): versi awal mengirim kata yang sudah
  dikecilkan Dart ke SQL sehingga nama ber-huruf besar non-ASCII hilang
  dari hasil; diperbaiki dan dites.
- Tidak ada perubahan skema, l10n, atau UI selain panduan.

## Tes

- Data (`history_test.dart`): pemesan tetap utuh (`rina kopi`,
  `lima meja`); huruf besar non-ASCII; lebih dari 8 kata dan kata
  berulang; grup F1-11d: `teh melati`, urutan terbalik
  dengan spasi ganda dan huruf besar, frasa utuh `kopi bubuk`, kata di
  barang berbeda satu nota (`bubuk pulsa`), kata di nota berbeda
  (`teh tawar`), wildcard (`teh %elati`); diverifikasi mutasi.
- Uji manual Xvfb di Riwayat.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Beberapa kata melintasi nama produk + varian | 1.14 | Rilis v0.101.0 | Per baris barang, urutan bebas. |
| Cari nama modifier | 1.14 | Rilis v0.103.0 | [F1-11f](2026-11-15-f1-11f-cari-nama-modifier-design.md). |
| Kata tanpa spasi (`5kg` vs `5 kg`) | — | Belum | Dicocokkan apa adanya. |
| Huruf kecil non-ASCII yang diketik (`éspresso` untuk `ÉSPRESSO`) di SQLite | — | Belum | Sama seperti F1-11b: `LOWER` SQLite hanya A–Z. Postgres (Fase 2) melipat Unicode. |
| Garis miring terbalik `\` di kata kunci pada Postgres | — | Belum (Fase 2) | `LIKE` Postgres memakai `\` sebagai escape; perlu `ESCAPE` eksplisit. SQLite tidak terpengaruh. |
