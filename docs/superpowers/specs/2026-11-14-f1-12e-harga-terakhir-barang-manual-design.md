# F1-12e · Harga beli terakhir untuk barang yang ditambah manual

- **Fase:** 1
- **Status:** Rilis v0.92.0
- **Layar:** 1.19 form pembelian (*+ Scan / cari produk*, pilihan satuan
  baris).
- **Acuan:** gap [F1-08e](2026-11-14-f1-08e-harga-beli-terakhir-design.md)
  *Harga beli terakhir saat menambah barang manual di form pembelian* dan
  *Harga terakhir setelah ganti satuan*. Storeku belum membangunnya.

## Tujuan

Sejak v0.89.0 draf dari stok minimum memakai harga faktur terakhir, tetapi
barang yang discan atau dicari di form pembelian masih terisi harga modal
rata-rata, sehingga staf mengetik ulang harga faktur. Modul ini memakai
harga beli terakhir yang sama untuk baris yang ditambah manual dan saat
baris dikembalikan ke satuan dasar.

## Aturan

1. **Harga beli terakhir** sama dengan F1-08e aturan 1–2: harga satuan
   baris pada pembelian diterima terbaru di cabang ini, per satuan dasar,
   baris bonus Rp 0 dilewati.
2. Baris baru dalam **satuan dasar** (scan barcode/SKU varian, pilih saran,
   atau nama yang cocok satu varian) tampil dulu dengan harga modal, lalu
   diganti harga beli terakhir begitu riwayat terbaca. Barang tanpa riwayat
   tetap harga modal.
3. Baris dalam **satuan konversi** (mis. scan barcode dus) tetap memakai
   harga awal satuan itu (HPP satuan atau HPP dasar × isi). Mengganti
   satuan baris kembali ke satuan dasar memakai harga beli terakhir lagi.
4. Harga yang diubah staf selama riwayat dibaca tidak ditimpa (harga
   diganti hanya bila baris masih memakai harga awal satuannya).
5. Riwayat dibaca sekali per varian selama form terbuka (termasuk riwayat
   yang sudah dibaca untuk draf stok minimum); form baru membaca ulang.
   Galat baca diabaikan (harga modal tetap) dan dicoba lagi untuk baris
   berikutnya.
7. *Simpan draf* / *Terima* menunggu pengisian harga yang masih berjalan,
   sehingga yang tersimpan sama dengan yang tampil.
6. Draf yang dibuka lagi tidak berubah; hanya baris yang ditambah setelahnya
   yang memakai aturan ini.

## Rancangan teknis

- `PurchaseFormViewModel`:
  - `_lastPrices` (`Map<UuidValue, Money?>`) diisi oleh
    `_applyRestockPrices` dan `_fillLastPrice`;
  - `addProduct` dan `setUnit` ke satuan dasar memanggil
    `_fillLastPrice(key)` lewat `_startFill` (tanpa menunggu, dicatat di
    `_pendingFills`); harga diganti dengan `priceRev` naik agar isian harga
    yang sudah tampil ikut berganti;
  - `_submit` menunggu `_pendingFills`; `_blank` mengosongkan
    `_lastPrices`; `_applyRestockPrices` hanya menyimpan varian yang
    diminta.
- Tanpa perubahan data atau l10n: memakai
  `PurchasesRepository.lastPurchasePrices` (F1-08e).

## Pengujian

- VM: satuan dasar memakai harga terakhir, tanpa riwayat harga modal; harga
  yang diubah selama menunggu tidak ditimpa; satuan konversi memakai harga
  modal dan kembali ke satuan dasar memakai harga terakhir tanpa membaca
  ulang; galat baca lalu baris berikutnya mencoba lagi; baris diganti ke
  dus selama menunggu; simpan sebelum riwayat terbaca; form baru membaca
  ulang; riwayat dari draf stok minimum dipakai lagi; draf yang dibuka lagi
  tidak berubah.
- Widget 1440 / 360 px: scan barang yang pernah dibeli menampilkan dan
  menyimpan harga terakhir.
- Uji manual Xvfb: Pembelian › baru › scan barang yang pernah dibeli.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Harga beli terakhir untuk barang manual dan kembali ke satuan dasar | 1.19 | Rilis v0.92.0 | Per satuan dasar, dibaca sekali per varian. |
| Harga terakhir per satuan konversi | — | Belum | Satuan dus tetap HPP satuan; riwayat per satuan belum dibaca. |
| Harga terakhir per supplier terpilih | — | Belum | Sama dengan F1-08e. |
| Penanda asal harga di baris | — | Belum | Tidak ada label *harga terakhir* di baris; panduan menjelaskan asalnya. |
