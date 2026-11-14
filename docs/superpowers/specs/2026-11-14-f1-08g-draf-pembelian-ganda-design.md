# F1-08g · Peringatan draf pembelian ganda dari stok minimum

- **Fase:** 1
- **Status:** Rilis v0.93.0
- **Layar:** 1.18 *Stok* › tab *Stok minimum* › *Buat pembelian*.
- **Acuan:** gap "Catatan isian setelah *Simpan draf*" di
  [F1-08c](2026-11-14-f1-08c-pembelian-dari-stok-minimum-design.md).
  Storeku tidak punya pemeriksaan ini; aturannya sama dengan Storeku untuk
  isi form (F1-08c/d/e), hanya dialog peringatannya yang baru.

## Masalah

*Buat pembelian* di tab *Stok minimum* selalu membuka form pembelian baru
berisi semua barang di bawah minimum. Draf tidak menambah stok, jadi barang
yang sudah masuk draf tetap tampil di bawah minimum. Staf yang menyimpan
draf lalu kembali ke Stok dan mengetuk *Buat pembelian* lagi membuat draf
kedua berisi barang yang sama, dan berisiko memesan dua kali ke supplier.

## Aturan

1. Sebelum membuka form baru, aplikasi mencari draf pembelian di cabang
   aktif (status draf, belum dihapus) **ke lokasi terima yang sama** dengan
   lokasi stok yang sedang dilihat, yang memuat **salah satu** barang di
   bawah minimum yang akan dibeli. Draf ke lokasi lain tidak dihitung,
   karena barang itu memang belum dipesan untuk lokasi ini.
2. Bila tidak ada draf seperti itu, alur F1-08c berjalan seperti biasa.
3. Bila ada, dialog *Sudah ada draf pembelian* tampil:
   - isi: nomor draf yang paling cocok dan "berisi X dari Y barang di bawah
     minimum";
   - bila ada draf lain yang juga cocok: "Ada N draf lain yang juga memuat
     barang ini (lihat menu Pembelian)";
   - tombol bertumpuk: **Buka draf** (utama) membuka form draf itu tanpa
     catatan isian stok minimum; **Buat draf baru** (garis) membuka form
     baru seperti F1-08c; **Batal** (ghost) menutup dialog tanpa membuka
     apa pun.
4. Draf "paling cocok" = paling banyak barang yang sama; bila seri, yang
   terakhir diubah; bila masih seri, nomor terbesar.
5. Galat saat membaca draf diabaikan: form baru langsung dibuka, agar
   *Buat pembelian* tetap bisa dipakai.
6. Ketukan ganda tidak membuka dua dialog atau dua form, termasuk bila
   router membangun ulang halaman Stok selagi draf dicari; setelah dialog
   atau form ditutup, daftar stok dimuat ulang.

## Rancangan teknis

- `lakuna_data` (`purchases.dart`): `RestockDraft{purchaseId, number,
  matched}` dan `restockDraftsOf(store, scope, locationId, variantIds)` —
  baca dulu `purchases` cabang ke lokasi itu yang berstatus draf dan belum
  dihapus (biasanya sedikit), lalu `purchase_items` draf itu untuk varian
  yang diminta; urutan sesuai aturan 4.
- `PurchasesRepository.restockDrafts(locationId, variantIds)` (lokal:
  `_guard`, izin *Kelola pembelian*; palsu: `restockDraftsError`,
  `restockDraftsGate`).
- `StockScreen`: parameter `restockDrafts` + `onOpenDraft`. `_restock`
  mencari draf di bawah bendera `_checkingDraft` (dilepas di `finally`,
  karena kueri lokal selalu selesai), baru kemudian masuk `whileAway`
  yang langsung mendorong dialog atau form. Bila pencarian dilakukan di
  dalam `whileAway`, halaman Stok masih rute teratas selama menunggu, dan
  pembangunan ulang router (`RouteReturnMixin.didUpdateWidget`) bisa
  melepas penjaga sebelum apa pun terbuka. `_askDraft`: FDialog lebar
  280–420 px, `SingleChildScrollView`, label tombol `Flexible` agar muat
  di 360 px.
- Router: `restockDrafts: purchases.restockDrafts`, `onOpenDraft` =
  `context.push(Routes.purchase(id))`.
- l10n: `stockRestockDraftTitle/Body/Others/Open/New/Cancel` (ID + EN).

## Pengujian

- Data (`purchases_test.dart`): draf cocok diurutkan paling banyak varian
  lalu terbaru; draf dihapus, pembelian diterima, dan draf ke lokasi lain
  tidak ikut; daftar varian kosong → kosong.
- Widget (`stock_flow_test.dart`, 1280 dan 360 px): dialog tampil dengan
  nomor draf dan "1 dari 2 barang"; *Batal* tidak membuka form; *Buka draf*
  membuka draf tanpa catatan stok minimum; *Buat draf baru* membuka form
  berisi catatan stok minimum; tanpa overflow.
- Widget: galat baca draf → form baru langsung terbuka.
- Widget: ketukan kedua setelah router membangun ulang Stok selagi draf
  dicari tetap diabaikan (satu dialog). Tes ini gagal bila bendera
  `_checkingDraft` dibuang.
- Uji manual Xvfb: simpan draf dari stok minimum, ketuk *Buat pembelian*
  lagi, dialog tampil; *Buka draf* membuka draf yang sama.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Peringatan draf berisi barang yang sama sebelum *Buat pembelian* | 1.18 | Rilis v0.93.0 | Dialog Buka draf / Buat draf baru / Batal; draf per lokasi terima. |
| Gabungkan barang yang belum ada ke draf yang dibuka | — | Belum | *Buka draf* membuka draf apa adanya; barang di bawah minimum yang belum ada di draf harus ditambah manual. |
| Tandai barang yang sudah ada di draf pada tab *Stok minimum* | — | Rilis v0.94.0 | *Sudah di draf {nomor}* di bawah tiap barang ([F1-08h](2026-11-14-f1-08h-tanda-sudah-di-draf-design.md)). |
