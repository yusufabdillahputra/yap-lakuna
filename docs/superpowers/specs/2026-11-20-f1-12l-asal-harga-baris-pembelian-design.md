# F1-12l · Asal harga di baris pembelian

- **Fase:** 1
- **Status:** Rilis v0.129.0
- **Layar:** 1.19 Pembelian: daftar barang di form (tabel layar lebar dan
  kartu layar sempit). Penyempurnaan layar.
- **Acuan:** gap "Penanda asal harga di baris" di
  [F1-12g](2026-11-15-f1-12g-harga-terakhir-per-supplier-design.md) dan
  [F1-12h](2026-11-15-f1-12h-harga-terakhir-satuan-konversi-design.md).

## Masalah

Harga beli baris diisi otomatis dari pembelian terakhir dari supplier yang
dipilih, dari supplier mana pun bila supplier itu belum pernah memasok
barang tersebut, atau dari harga modal (F1-12e/g/h). Staf tidak bisa
melihat dari mana angka itu berasal, jadi tidak tahu apakah harga itu
harga supplier ini, harga supplier lain, atau sekadar harga modal yang
perlu dicek dengan faktur.

## Aturan

1. Baris yang harganya masih otomatis menampilkan satu baris kecil di
   bawah nama barang (di bawah SKU / barcode):
   - **Harga terakhir {tanggal} · {supplier}** bila harga diambil dari
     pembelian diterima. Supplier = supplier pembelian itu (juga bila
     supplier itu sudah dihapus), atau *tanpa supplier*. Tanggal = tanggal
     beli di pembelian itu (`dd/MM/yyyy`, seperti di faktur), walau
     urutan "terakhir" memakai waktu terima (F1-08e). Tanggal ditulis
     lebih dulu agar nama supplier yang panjang yang terpotong, bukan
     tanggalnya.
   - **Harga modal** bila barang belum pernah dibeli dalam satuan itu,
     sehingga harga diambil dari harga modal produk.
2. Bila supplier di form belum pernah memasok barang itu, harga diambil
   dari pembelian supplier lain (F1-12g) dan nama supplier lain itulah
   yang tampil.
3. Penanda hilang begitu staf mengetik harga sendiri. Baris yang dimuat
   dari draf tersimpan tidak punya penanda (harganya sudah ditetapkan).
4. Penanda ikut berganti saat supplier atau satuan diganti, bersamaan
   dengan harganya, juga bila harganya kebetulan tetap. Baris draf yang
   satuannya diganti kembali otomatis (F1-12h), sehingga penandanya
   muncul lagi. Selama harga terakhir masih dibaca, atau bila riwayat
   gagal dibaca, penanda tidak tampil (tidak menebak *Harga modal*).
5. Penanda hanya tampil bila harga baris sama dengan harga dari asal itu.

## Rancangan teknis

- `lakuna_data`: `lastPurchasePriceSetOf` juga mengembalikan asal tiap
  harga (`baseFrom`, `unitFrom`): pembelian, tanggal beli, dan nama
  supplier (supplier terhapus tetap dibaca namanya).
- `LastPurchasePrice` mendapat `perBaseFrom` dan `perUnitFrom`
  (`PurchasePriceSource`: nama supplier atau `null`, tanggal beli).
- `PurchaseFormViewModel.priceOrigin(line)` →
  `PurchasePriceOrigin?` (`lastPurchase(source)` atau `cost`), memakai
  tembolok harga dan urutan supplier yang sama dengan `_lastPriceFor`.
- `_fillLastPrice` dan `_refreshAutoPrices` memberi tahu pendengar setelah
  riwayat terbaca walau harga baris tidak berubah, karena asal harga baru
  diketahui.
- `_ProductName` menampilkan penanda (key `purchase-origin-<key>`).
- Kunci l10n baru: `purchasePriceOriginLast`, `purchasePriceOriginCost`,
  `purchasePriceOriginNoSupplier`.

## Pengujian

- `lakuna_data/test/purchases_test.dart`: asal harga satuan dasar dan
  satuan konversi (pembelian terbaru, supplier tertentu, tanpa supplier,
  supplier terhapus).
- `purchase_view_models_test.dart`: `priceOrigin` untuk harga terakhir,
  fallback supplier lain, supplier baru diketik, harga modal, harga
  diketik, belum dibaca, galat baca (juga setelah ganti supplier), baris
  draf, baris stok minimum, dan pemberitahuan saat harga tetap.
- `purchase_flow_test.dart` grup F1-12l: penanda tampil, berganti saat
  supplier diganti, dan hilang saat harga diketik (1440 dan 360 px);
  *Harga modal* muncul setelah riwayat terbaca belakangan.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Penanda asal harga di baris pembelian | 1.19 | Rilis v0.129.0 | Harga terakhir (supplier, tanggal) atau harga modal. |
