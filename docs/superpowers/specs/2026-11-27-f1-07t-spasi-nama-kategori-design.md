# F1-07t · Spasi ganda di nama kategori dan satuan

- **Fase:** 1
- **Status:** Rilis v0.157.0
- **Layar:** import produk (1.15), form produk (1.16), Data master ›
  Kategori dan Satuan (1.17).
- **Acuan:** gap *Spasi ganda di nama kategori* di
  [F1-07b](2026-11-04-f1-07b-import-produk-design.md) (gap 20 di
  `GAP-FASE1.md`). Storeku punya gap yang sama.

## Masalah

Kategori dan satuan dicocokkan tanpa beda huruf, tetapi spasi di tengah
nama tidak dirapatkan. Baris import berisi `Minuman  Dingin` (dua spasi,
sering terjadi saat menyalin dari Excel atau WhatsApp) membuat kategori baru
di samping `Minuman Dingin`. Hal yang sama terjadi di form produk dan Data
master.

## Aturan

1. Nama kategori dan satuan dirapatkan sebelum disimpan atau dicocokkan:
   spasi di ujung dibuang, deretan spasi/tab di tengah menjadi satu spasi.
2. Import produk dan form produk memakai kategori/satuan yang ada bila
   namanya sama setelah dirapatkan dan tanpa beda huruf. Kategori atau
   satuan baru disimpan dengan nama yang sudah dirapatkan.
3. Data master › Kategori dan Satuan menolak nama kembar walau beda spasi,
   dan menyimpan nama yang sudah dirapatkan.
4. Kategori/satuan lama yang terlanjur berspasi ganda tidak diubah, tetapi
   ikut dicocokkan (nama baru `Minuman Dingin` memakai kategori lama
   `Minuman  Dingin`). Bila ada dua data lama yang kembar beda spasi, nama
   yang persis sama (tanpa beda huruf) didahulukan, jadi menyimpan ulang
   produk tidak memindahkan kategori/satuannya.
5. Data master: mengubah kategori/satuan tanpa mengubah namanya (mis. hanya
   warna) selalu boleh, walau ada data lama yang kembar beda spasi; nama
   lama tidak diubah diam-diam. Mengganti nama menjadi kembar persis dengan
   data lain tetap ditolak.
6. Satuan konversi di form produk dibandingkan dengan satuan dasar dan
   sesamanya setelah spasi dirapatkan (`gelas  besar` = satuan dasar
   `gelas besar` → *sama dengan satuan dasar*). Panjang nama kategori dan
   satuan dihitung setelah spasi dirapatkan.

## Rancangan teknis

- `squishName` di `lakuna_domain` (`catalog.dart`), dipakai
  `validateProductDraft` (satuan dasar, satuan konversi, panjang),
  `validateCategory` (nama tidak berubah tidak dicek kembar),
  `validateUnitName`, dan kunci nama import produk.
- `lakuna_data`: `saveProduct` / `importProducts` (`_ensureCategory`,
  `_ensureUnit`, satuan konversi) dan `createCategory` /
  `updateCategory` / `createUnit` / `renameUnit` memakai `squishName`.
  `_ensureCategory` / `_ensureUnit` mencocokkan nama persis lebih dulu
  (urut `created_at`), lalu nama yang dirapatkan. `updateCategory`
  mempertahankan nama lama bila tidak diubah; `renameUnit` langsung
  kembali bila nama tidak diubah.
- Temuan review (Important, diperbaiki): satuan konversi berspasi ganda
  bisa menjadi satuan dasar diam-diam; data lama kembar beda spasi membuat
  kategori tidak bisa diubah; produk bisa pindah kategori saat disimpan
  ulang. Minor: panjang setelah dirapatkan, satu definisi kunci nama.

## Tes

- Domain: `squishName`; kategori dan satuan kembar walau beda spasi (dua
  arah).
- Data: import dengan `minuman   dingin`, `Gelas  Besar`, dan tab memakai
  kategori/satuan yang ada atau membuat satu yang dirapatkan; Data master
  menyimpan nama dirapatkan dan menolak kembar.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Spasi ganda di nama kategori dan satuan | — | Rilis v0.157.0 | Import, form produk, Data master. |
| Merapikan nama lama yang berspasi ganda | — | Belum | Nama lama tetap; ubah manual di Data master (bila kembar persis dengan kategori lain, pindahkan produknya lalu hapus). |
| Karakter tak terlihat (U+200B) | — | Belum | Spasi lebar-nol dari WhatsApp belum dibuang. |
