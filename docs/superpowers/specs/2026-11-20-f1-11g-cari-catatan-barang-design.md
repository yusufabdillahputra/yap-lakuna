# F1-11g · Cari nota Riwayat lewat catatan barang

- **Fase:** 1
- **Status:** Rilis v0.117.0
- **Layar:** 1.14 Riwayat (kolom *Cari*).
- **Acuan:** gap *Cari catatan item (tanpa es)* di
  [F1-11f](2026-11-15-f1-11f-cari-nama-modifier-design.md). Storeku tidak
  punya pencarian barang di riwayat.

## Masalah

Di F&B, pesanan sering diingat lewat catatannya: "yang tanpa es", "yang
dibungkus terpisah". Catatan barang (`sale_items.note`, F1-10g) tersimpan
di nota, tetapi pencarian Riwayat hanya mencocokkan nomor, pelanggan,
referensi, nama produk/varian, dan nama modifier.

## Aturan

1. Setiap kata kunci (F1-11e) boleh cocok dengan nama produk, nama varian,
   nama modifier, **atau catatan** baris barang yang sama, urutan bebas dan
   tanpa beda huruf. `kopi sedikit` cocok dengan *Kopi Bubuk* bercatatan
   *Tanpa es, gula sedikit*.
2. Kata di catatan satu barang dan nama barang lain di nota yang sama
   (`roti gula`) tidak cocok.
3. Catatan dibaca dari baris nota, jadi barang yang dihapus dari bill
   sebelum dibayar tidak ikut dicari.
4. Aturan F1-11d/F1-11e/F1-11f lain tetap: `%` dan `_` literal, filter dan
   batas 100 nota tetap.
5. Catatan nota (bukan per barang) dan alasan retur/void tidak dicari.
   Catatan barang hanya ada di pesanan F&B (open bill, F1-10g); catatan
   nota retail yang diparkir tidak disimpan di nota yang dibayar.
6. Rincian nota di Riwayat menampilkan catatan barang di bawah jumlah ×
   harga (*Catatan: tanpa es*), agar hasil pencarian terlihat alasannya.

## Rancangan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): klausa tiap kata di
  subkueri `sale_items` ditambah `OR LOWER("note") LIKE LOWER(%kata%)`.
- Cek ulang Dart `itemMatches`: catatan baris (`SaleItem.note`) ikut
  dicocokkan sebelum modifier dimuat.
- `history_detail.dart`: baris barang menampilkan `l10n.historyItemNote`
  bila `SaleItem.note` ada (kunci baru ID + EN).
- Tanpa perubahan skema; panduan Retur & void diperbarui.
- Review subagent: tanpa Critical/Important. Minor diperbaiki: catatan
  tampil di rincian, gap F1-11f diarahkan ke spec ini, aturan 5
  diperjelas.

## Tes

- Data (`history_test.dart`): `tanpa es`, `GULA`, `sedikit kopi` cocok
  nota bercatatan; `kopi bubuk` cocok kedua nota; `roti gula` (barang
  berbeda), `tanpa%es`, `gul_` kosong; barang bercatatan yang dihapus dari
  bill sebelum dibayar tidak cocok; diverifikasi mutasi (SQL dan cek ulang
  Dart).
- Widget (`history_flow_test.dart`): cari `tanpa es` → hanya nota
  bercatatan; rinciannya menampilkan *Catatan: Tanpa es* di baris itu
  saja; diverifikasi mutasi.
- Uji manual Xvfb di Riwayat: cari `less ice` → nota itu; rincian
  menampilkan *Note: less ice*.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cari catatan barang di Riwayat | — | Rilis v0.117.0 | Diuji manual (Linux). |
| Modifier di rincian nota Riwayat | — | Belum | Rincian menampilkan catatan, belum nama modifier; nota cocok lewat modifier (F1-11f) tidak terlihat alasannya. |
| Tes kata modifier + kata catatan di barang yang sama | — | Belum | Klausa per kata berupa OR sehingga kombinasi tercakup; belum ada tes khusus. |
