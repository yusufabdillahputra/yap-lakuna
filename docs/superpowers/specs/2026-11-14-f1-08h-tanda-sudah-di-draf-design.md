# F1-08h · Tanda "sudah di draf" di tab *Stok minimum*

- **Fase:** 1
- **Status:** Rilis v0.94.0
- **Layar:** 1.18 *Stok* › tab *Stok minimum* (dan panel *Stok minimum* di
  tab *Penyesuaian* desktop).
- **Acuan:** gap "Tandai barang yang sudah ada di draf" di
  [F1-08g](2026-11-14-f1-08g-draf-pembelian-ganda-design.md). Storeku tidak
  punya tanda ini.

## Masalah

Draf pembelian tidak menambah stok, jadi barang yang sudah dipesan lewat
draf tetap tampil di bawah minimum tanpa keterangan apa pun. Staf baru tahu
saat mengetuk *Buat pembelian* (dialog F1-08g), dan tidak tahu barang mana
yang sudah ada di draf dan mana yang belum.

## Aturan

1. Tiap baris di daftar *Di bawah stok minimum* yang barangnya ada di draf
   pembelian cabang ke lokasi yang sedang dilihat (draf, belum dihapus)
   diberi keterangan **Sudah di draf {nomor}** di bawah SKU/satuan.
2. Bila barang ada di beberapa draf, nomor yang ditampilkan mengikuti urutan
   F1-08g (draf yang paling banyak memuat barang di bawah minimum, lalu yang
   terakhir diubah).
3. Keterangan hanya untuk staf yang boleh *Buat pembelian* (izin *Kelola
   pembelian*); staf lain tidak melihatnya dan tidak ada kueri pembelian.
4. Galat membaca draf diabaikan: daftar tampil tanpa keterangan.
5. Keterangan ikut segar setiap daftar stok dimuat ulang (ganti lokasi,
   kembali dari form pembelian, kembali lewat menu samping).

## Rancangan teknis

- `RestockDraft` menyimpan `variantIds` (set varian yang cocok);
  `matched` menjadi getter `variantIds.length`.
- `StockViewModel` menerima `restockDrafts` opsional (fungsi yang sama
  dengan F1-08g). `_loadOnce` memanggilnya untuk varian di bawah minimum
  pada lokasi target, lalu menyusun `variantId → nomor draf` (draf pertama
  menang). Kueri ini berjalan bersamaan dengan pembacaan penyesuaian
  terakhir dan nomor penyesuaian, agar daftar tidak tertunda dua kueri
  berturut-turut. `draftNumberOf(variantId)` untuk tampilan.
- `StockScreen` meneruskan `restockDrafts` hanya bila `onRestock` ada
  (izin). Nilainya ditangkap sekali saat layar dibuat; ganti kasir selalu
  lewat `/login` yang membuang layar, dan repositori tetap memeriksa izin.
- `_MinimumPanel`: teks `stockMinimumInDraft(number)` berkunci
  `stock-min-draft-<uuid>`, warna utama (biru muda `#74D4FF` di tema
  gelap untuk kontras 4.5:1), dibungkus tanpa elipsis agar nomor draf
  tetap utuh di ponsel 360 px.
- l10n: `stockMinimumInDraft` (ID + EN).

## Pengujian

- VM: barang di draf mendapat nomor draf, barang lain `null`; dua draf →
  nomor draf pertama; galat baca → kosong; tanpa fungsi → kosong; muat
  ulang setelah draf dihapus → kosong.
- Widget (`stock_flow_test.dart`, 1280 / 360 px): baris barang di draf
  menampilkan *Sudah di draf PB-…* utuh (tidak melewati batas baris),
  baris lain tidak.
- Widget: staf tanpa izin pembelian tidak melihat tanda dan tidak ada
  kueri draf (diverifikasi mutasi).
- Uji manual Xvfb: draf dari F1-08g tampil sebagai keterangan di tab
  *Stok minimum*.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tanda "sudah di draf" di tab *Stok minimum* | 1.18 | Rilis v0.94.0 | Nomor draf di bawah tiap barang; hanya untuk staf berizin pembelian. |
| Jumlah di draf dibandingkan jumlah saran | — | Rilis v0.112.0 | [F1-08l](2026-11-15-f1-08l-jumlah-di-draf-design.md): *Sudah di draf …: 5 dari saran 38 pcs*. |
