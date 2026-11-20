# F1-12h · Harga beli terakhir untuk satuan konversi

- **Fase:** 1
- **Status:** Rilis v0.106.0
- **Layar:** 1.19 Pembelian (form *Pembelian baru* / draf), termasuk form
  yang dibuka dari Stok › *Stok minimum*.
- **Acuan:** gap "Harga terakhir per satuan konversi" di
  [F1-12e](2026-11-14-f1-12e-harga-terakhir-barang-manual-design.md) dan
  [F1-12g](2026-11-15-f1-12g-harga-terakhir-per-supplier-design.md).
  Storeku tidak punya aturan ini.

## Masalah

Toko biasanya membeli dari grosir per dus atau per pak. Saat staf
memindai barcode dus *Minyak Goreng 2 L* (isi 6), baris memakai harga
awal satuan dus: HPP dus yang diisi di produk, atau HPP botol × 6. Harga
yang benar-benar dibayar per dus di pembelian terakhir tidak dipakai,
padahal untuk satuan dasar aturan itu sudah berlaku (F1-12e, F1-12g).
Staf harus mengingat dan mengetik ulang harga dus setiap kali.

## Aturan

1. **Harga terakhir satuan konversi** sebuah barang = harga per satuan
   itu pada baris pembelian diterima terakhir **dalam satuan yang sama**
   (mis. dus), apa adanya, tanpa dihitung ulang dari satuan dasar.
   Aturan lain sama dengan F1-12e: hanya pembelian cabang ini, baris
   bonus Rp 0 dilewati. Baris yang isi satuannya berbeda dari isi satuan
   sekarang (mis. dus isi 6 diubah menjadi isi 12 setelah pembelian) atau
   satuannya sudah dihapus tidak dipakai, karena harganya untuk isi yang
   lain.
2. Urutan sumber harga baris satuan konversi: pembelian terakhir dalam
   satuan itu **dari supplier yang dipilih**, lalu dari supplier mana pun
   (F1-12g), lalu harga awal satuan itu (HPP satuan atau HPP dasar × isi).
   Harga satuan dasar **tidak** dikalikan isi, karena harga per dus
   biasanya berbeda dari harga per botol × isi.
3. Berlaku untuk baris yang harganya masih otomatis, sama dengan satuan
   dasar: baris dari scan barcode satuan, baris yang satuannya diganti
   staf, dan baris stok minimum yang satuannya diganti. Harga yang
   diketik staf tidak pernah ditimpa.
4. Mengganti supplier menyegarkan baris otomatis satuan dasar **dan**
   satuan konversi (F1-12g aturan 3).
5. Riwayat dibaca bersama harga satuan dasar, sekali per varian per
   supplier selama form terbuka; satuan lain varian yang sama tidak
   membaca ulang. Galat baca diabaikan (harga awal tetap).
6. Simpan / terima menunggu pengisian yang masih berjalan (F1-12e).

## Rancangan teknis

- Data: `lastPurchasePriceSetOf(store, scope, variantIds,
  {supplierId})` → `(perBase, perUnit)` dari satu bacaan riwayat;
  `perUnit` = varian → `product_unit_id` → harga per satuan itu, hanya
  baris yang `factor_milli`-nya sama dengan `product_units` sekarang.
  `lastPurchasePricesOf` / `lastPurchaseUnitPricesOf` memakai fungsi
  ini.
- Repositori: `lastPurchasePrices(ids, {supplierId})` mengembalikan
  `Map<UuidValue, LastPurchasePrice>` (`perBase`, `perUnit` tak bisa
  diubah).
- VM: tembolok menyimpan `LastPurchasePrice?` per varian;
  `_lastPriceFor(variant, unit, supplier)` memilih harga satuan dasar
  atau harga satuan itu. Syarat `unit.isBase` dihapus dari pengisian
  barang baru, ganti satuan, penyegaran supplier, dan stok minimum.

## Pengujian

- Data (`purchases_test.dart`): harga dus terakhir apa adanya; satuan
  dasar tidak muncul di `perUnit`; supplier tertentu; bonus Rp 0 dan
  draf (harga dus berbeda, tanggal lebih baru) dilewati; isi dus diubah
  → harga dus lama tidak dipakai.
- VM (`purchase_view_models_test.dart`): scan barcode dus memakai harga
  dus terakhir; tanpa riwayat dus tetap HPP satuan (bukan harga botol ×
  isi); ganti satuan ke dus dan kembali tanpa membaca ulang; ganti
  supplier menyegarkan baris dus; harga dus yang diketik tidak ditimpa;
  supplier dipilih sebelum scan dus; baris stok minimum diganti ke dus
  selama harga dibaca.
- Widget (`purchase_flow_test.dart`): scan barcode dus → harga dus
  terakhir tampil dan tersimpan.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Harga terakhir per satuan konversi | 1.19 | Rilis v0.106.0 | Dari pembelian terakhir dalam satuan yang sama. |
| Harga dasar × isi bila belum pernah dibeli dalam satuan itu | — | Tidak dipakai | Sengaja; harga awal satuan tetap (aturan 2). |
| Penanda asal harga di baris | — | Rilis v0.129.0 | [F1-12l](2026-11-20-f1-12l-asal-harga-baris-pembelian-design.md); asal harga satuan konversi dari pembelian dalam satuan yang sama. |
