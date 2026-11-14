# F1-08e · Harga beli terakhir di pembelian dari stok minimum

- **Fase:** 1
- **Status:** Rilis v0.89.0
- **Layar:** 1.18 *Stok* › *Buat pembelian* → 1.19 form pembelian baru.
- **Acuan:** gap [F1-08d](2026-11-14-f1-08d-supplier-terakhir-design.md)
  *Harga beli terakhir sebagai harga baris*. Storeku belum membangunnya.

## Tujuan

Draf dari stok minimum (F1-08c) mengisi harga baris dengan harga modal
rata-rata varian. Angka itu jarang sama dengan harga di faktur supplier:
rata-rata bercampur ongkos kirim, diskon, dan harga lama. Staf jadi harus
mengetik ulang harga tiap baris. Modul ini mengisi harga baris dengan
harga beli pada pembelian terakhir barang itu, karena harga supplier
biasanya belum berubah sejak pembelian terakhir.

## Aturan

1. **Harga beli terakhir per barang** = harga satuan baris (sebelum ongkos
   kirim dan diskon nota, persis yang diketik di faktur) pada pembelian
   **diterima** terbaru di cabang ini yang memuat varian itu. Terbaru
   menurut `received_at` (atau tanggal beli bila kosong), lalu nomor; bila
   satu pembelian memuat varian itu di beberapa baris (satuan berbeda,
   mis. dus dan botol), baris terakhir (urutan) yang dipakai. Draf dan
   pembelian terhapus tidak dihitung. Baris bonus seharga Rp 0 dilewati
   (bukan harga beli), jadi harga diambil dari baris atau pembelian
   sebelumnya. Supplier tidak harus ada (pembelian tanpa supplier ikut
   dihitung).
2. Harga dihitung **per satuan dasar**: harga satuan ÷ isi satuan baris
   (mis. Rp 185.000 per dus isi 6 = Rp 30.833 per botol), dibulatkan ke
   rupiah terdekat (setengah menjauhi nol). Baris dari stok minimum memakai
   satuan dasar, jadi harga ini langsung dipakai.
3. Baris tanpa riwayat tetap memakai harga modal varian (aturan F1-08c).
   Galat baca riwayat diabaikan (semua baris memakai harga modal).
4. Harga diisi hanya untuk baris yang harganya belum diubah staf selama
   riwayat dimuat.
5. Catatan isian (`purchase-restock-note`) mendapat kalimat
   *Harga diisi dari pembelian terakhir untuk {n} dari {m} barang.* /
   *Prices filled from the last purchase for {n} of {m} items.*
   (`purchase-restock-price`) bila n > 0.
6. Supplier terakhir (F1-08d) tidak berubah: dihitung terpisah dan tetap
   butuh supplier yang masih ada.

## Rancangan teknis

- `lakuna_domain` (`purchase.dart` atau `stock.dart`):
  `perBaseUnitPrice(Money unitPrice, Qty factor)` → `Money`, bulat
  setengah ke atas.
- `lakuna_data` (`purchases.dart`): `lastPurchasePricesOf(store, scope,
  variantIds)` → `Map<UuidValue, Money>` per satuan dasar.
- `PurchasesRepository.lastPurchasePrices(variantIds)` (lokal + palsu).
- `PurchaseFormViewModel`: setelah `_applyRestock`, memuat harga terakhir
  dan mengganti harga baris yang belum diubah; getter
  `restockPriceCount`.
- l10n `purchaseRestockPriceNote(count, total)` (ID + EN).

## Pengujian

- Domain: pembagian dan pembulatan, isi 1.
- Data: pembelian diterima terbaru menang, draf tidak dihitung, pembelian
  tanpa supplier dihitung, satuan konversi dibagi isi, cabang lain tidak
  terbaca, daftar kosong.
- VM / widget: harga baris dari pembelian terakhir, baris tanpa riwayat
  tetap harga modal, catatan *n dari m*, galat baca → harga modal; 1280 /
  360 px.
- Uji manual Xvfb: Stok › *Buat pembelian* untuk barang yang pernah dibeli.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Harga beli terakhir di pembelian dari stok minimum | 1.18 / 1.19 | Rilis v0.89.0 | Per satuan dasar, pembelian diterima terbaru di cabang. |
| Harga beli terakhir saat menambah barang manual di form pembelian | — | Belum | Barang yang ditambah manual tetap memakai harga modal. |
| Harga terakhir per supplier terpilih | — | Belum | Harga diambil dari pembelian terakhir mana pun, bukan dari supplier yang dipilih form. |
| Harga terakhir setelah ganti satuan | — | Belum | Mengganti satuan baris lalu kembali ke satuan dasar memakai harga modal lagi. |
