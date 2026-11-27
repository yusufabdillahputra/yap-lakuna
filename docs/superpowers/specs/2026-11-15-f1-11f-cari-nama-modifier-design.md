# F1-11f · Cari nota Riwayat lewat nama modifier

- **Fase:** 1
- **Status:** Rilis v0.103.0
- **Layar:** 1.14 Riwayat (kolom *Cari*).
- **Acuan:** gap *Cari nama modifier* di
  [F1-11d](2026-11-14-f1-11d-cari-nama-barang-design.md) dan
  [F1-11e](2026-11-15-f1-11e-cari-beberapa-kata-barang-design.md).
  Storeku tidak punya pencarian barang di riwayat.

## Masalah

Di F&B, tamu sering mengingat pesanannya lewat modifier: "kopi yang
extra shot", "yang pakai boba". Pencarian Riwayat hanya mencocokkan nama
produk dan varian, jadi `extra shot` tidak menemukan apa pun walau nama
modifier itu tersimpan di nota (`sale_item_modifiers.name`, disalin saat
transaksi).

## Aturan

1. Setiap kata kunci (F1-11e) boleh cocok dengan nama produk, nama varian,
   **atau nama modifier** baris barang yang sama, urutan bebas dan tanpa
   beda huruf. `kopi extra shot` cocok dengan *Es Kopi Susu* + *Extra
   Shot*.
2. Nama modifier dibaca dari salinan di nota, jadi mengubah nama opsi
   modifier di master tidak mengubah hasil pencarian nota lama.
3. Kata di modifier satu barang dan nama barang lain di nota yang sama
   (`roti shot` untuk nota berisi *Roti* dan *Es Kopi Susu + Extra Shot*)
   tidak cocok.
4. Nama grup modifier (*Topping*, *Level*) tidak dicari.
5. Aturan F1-11d/F1-11e lain tetap: `%` dan `_` literal, barang yang
   dihapus dari bill tidak ikut, filter dan batas 100 nota tetap.

## Rancangan teknis

- `_searchSales` (`lakuna_data/lib/src/history.dart`): klausa tiap kata
  di subkueri `sale_items` ditambah `OR "sale_items"."id" IN (SELECT
  "sale_item_id" FROM "sale_item_modifiers" WHERE "tenant_id" = … AND
  "deleted_at" IS NULL AND LOWER("name") LIKE LOWER(%kata%))`.
- Cek ulang Dart: modifier (`itemModifiers`, bersama open bill) hanya
  dimuat untuk baris barang di nota yang belum cocok lewat nama
  produk/varian, sekali per kelompok nota; `itemMatches` menerima nama
  modifier baris itu.
- Temuan review: tes barang bermodifier yang dihapus dari bill dan
  wildcard `_` ditambah (Important); helper `itemModifiers` dipakai ulang
  dan modifier hanya dimuat untuk baris yang belum cocok (Minor). Biaya
  subkueri per kata sama dengan subkueri `sale_items` F1-11d.
- Tanpa perubahan skema, l10n, atau UI selain panduan dan petunjuk.

## Tes

- Data (`history_test.dart`): `extra shot`, `SHOT`, `kopi extra`,
  `shot kopi susu` cocok nota bermodifier; `es kopi` cocok kedua nota;
  `boba` (opsi tidak dipilih) dan `topping` (nama grup) kosong; `roti
  shot` (barang berbeda) kosong; `extra %hot` dan `sh_t` kosong; barang
  bermodifier yang dihapus dari bill sebelum dibayar tidak cocok; nama
  opsi master diubah setelah transaksi tetap ditemukan dengan nama lama;
  diverifikasi mutasi (SQL dan cek ulang Dart).
- Uji manual Xvfb di Riwayat.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cari nama modifier | 1.14 | Rilis v0.103.0 | Per baris barang bersama nama produk/varian. |
| Cari nama grup modifier | — | Rilis v0.149.0 | [F1-11j](2026-11-27-f1-11j-cari-grup-tanpa-spasi-design.md): grup dari modifier yang dipilih di baris itu. |
| Cari catatan item (*tanpa es*) | — | Rilis v0.117.0 | [F1-11g](2026-11-20-f1-11g-cari-catatan-barang-design.md). |
| `\` di kata kunci pada Postgres | — | Belum (Fase 2) | Sama seperti F1-11e; perlu `ESCAPE` eksplisit. |
