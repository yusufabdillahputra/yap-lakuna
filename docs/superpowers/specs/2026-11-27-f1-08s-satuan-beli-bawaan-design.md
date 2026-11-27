# F1-08s · Satuan beli bawaan per barang

- **Fase:** 1
- **Status:** Rilis v0.159.0
- **Layar:** form produk tab *Satuan & konversi* (1.16), form *Pembelian
  baru* / *Draf* (1.19), Stok › *Stok minimum* › *Buat pembelian* (1.18).
- **Acuan:** gap 22 di `GAP-FASE1.md` dan gap
  [F1-08j](2026-11-14-f1-08j-saran-ikut-satuan-design.md) *Satuan beli
  bawaan per barang (langsung dus)*. Storeku punya gap yang sama.

## Masalah

Banyak barang dibeli per dus tetapi dijual per botol. Setiap kali barang
itu ditambahkan ke pembelian (scan, cari, atau saran stok minimum), baris
mulai dalam satuan dasar dan staf harus mengganti satuan ke dus satu per
satu. Untuk saran stok minimum, F1-08j sudah mengonversi jumlahnya, tetapi
staf tetap harus mengganti satuannya sendiri.

## Aturan

1. Di form produk, tab *Satuan & konversi*, setiap varian punya
   **Satuan beli bawaan** (`unit-purchase`): satuan dasar (bawaan) atau
   salah satu satuan konversi yang sudah bernama. Pilihan hanya tampil
   untuk barang yang melacak stok (hanya barang itu yang bisa dibeli) dan
   bila varian punya satuan konversi bernama. Paling banyak satu satuan per
   varian.
2. Menambah barang ke pembelian lewat pencarian, nama, SKU, atau barcode
   varian (barcode satuan dasar) memakai satuan beli bawaan. Barcode satuan
   konversi tetap memilih satuan itu sendiri. Staf tetap bisa mengganti
   satuan baris.
3. *Buat pembelian* dari stok minimum (juga menambah ke draf, F1-08i)
   mengisi baris dalam satuan beli bawaan; jumlah saran dikonversi dan
   dibulatkan ke atas ke satuan utuh (38 botol → 7 dus isi 6). Saran tetap
   diingat dalam satuan dasar, jadi mengganti ke botol mengembalikan 38
   (F1-08j).
4. Harga awal baris mengikuti satuannya seperti biasa (harga beli terakhir
   dalam satuan itu, F1-12h, atau HPP satuan / HPP × isi).
5. Menghapus satuan konversi yang dipilih membuat satuan dasar kembali
   menjadi satuan beli bawaan.

## Rancangan teknis

- `product_units.purchase_default` (`bool`, bawaan `false`), migrasi
  `satuan-beli`. Disimpan per varian karena satuan konversi milik varian.
- `UnitDraft.purchaseDefault`, `CatalogUnit.purchaseDefault`.
  `_saveUnits` hanya menyimpan tanda pertama per varian (tanda berikutnya
  diabaikan), jadi data tetap konsisten walau pemanggil mengirim lebih dari
  satu. Bila sinkronisasi (Fase 2) menggabungkan tanda dari dua perangkat,
  pembacaan memakai yang pertama menurut urutan muat (isi, id) dan simpan
  berikutnya merapikannya.
- Form produk: `EditableUnit.purchaseDefault` (ikut tanda perubahan
  belum disimpan), `purchaseUnitKey(variant)`,
  `setPurchaseUnit(variant, unitKey)`; widget `_PurchaseUnitPicker` dengan
  `ChoicePill` `unit-purchase-base` / `unit-purchase-<key>`.
- Pembelian: `PurchaseUnitOption.purchaseDefault`,
  `PurchaseProductOption.purchaseUnit`. `addProduct(variantId)` tanpa
  satuan memakai `purchaseUnit`; `_applyRestock` mengisi baris dalam
  `purchaseUnit` dengan `suggestedIn(unit)` dan `suggested` dalam satuan
  dasar.
- l10n: `productPurchaseUnit`, `productPurchaseUnitHelp`.

## Tes

- Data: tanda tersimpan dan termuat (daftar dan `toDraft`), hanya satu per
  varian, kembali ke satuan dasar menghapus tanda.
- VM pembelian: saran 38 → 7 dus lalu kembali 38 botol; tambah dari
  pencarian, barcode botol, SKU, dan barcode dus memakai dus; tanpa satuan
  beli tetap satuan dasar.
- VM form produk: satu per varian, tersimpan, termuat tanpa tanda
  perubahan, kembali ke dasar, satuan yang dihapus membawa tandanya.
- Widget 1280 / 360: pilih dus di form produk lalu simpan; pilihan tidak
  tampil tanpa satuan konversi bernama; *Buat pembelian* langsung 7 dus.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Satuan beli bawaan per varian | — | Rilis v0.159.0 | Form produk, pembelian, saran stok minimum. |
| Satuan beli di import produk | — | Belum | Templat import belum punya kolomnya; atur lewat form produk. |
| Saran di daftar *Stok minimum* / PDF dalam satuan beli | — | Belum | Daftar dan PDF tetap dalam satuan dasar. |
| Scan barcode dasar menambah baris satuan yang sedang dipakai | — | Belum | Baris yang sudah diganti ke botol tidak bertambah saat barcode botol di-scan; scan menambah baris dus baru (cerminan perilaku lama). |
| Temuan review (diperbaiki) | — | v0.159.0 | Pilihan disembunyikan untuk jasa/menu tanpa stok; satuan tanpa nama tidak dianggap terpilih; panduan harga baris dalam satuan beli. |
