# F1-08d — Supplier terakhir saat membuat pembelian dari stok minimum

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.83.0)
- **Layar:** 1.18 *Stok* › *Buat pembelian* → 1.19 form pembelian baru.
- **Acuan:** gap [F1-08c](2026-11-14-f1-08c-pembelian-dari-stok-minimum-design.md)
  *Supplier terakhir per barang*. Storeku belum membangunnya.

## Tujuan

Draf dari stok minimum (F1-08c) masih meminta staf memilih supplier
sendiri, padahal toko biasanya membeli barang yang sama dari supplier yang
sama. Form langsung memilih supplier yang paling sering memasok barang-
barang itu terakhir kali, sehingga staf cukup memeriksa lalu menyimpan.

## Aturan

1. **Supplier terakhir per barang** = supplier pembelian **diterima**
   terbaru (cabang ini, belum dihapus, ada supplier) yang memuat varian
   itu. Terbaru menurut `received_at` (atau tanggal beli bila kosong),
   lalu nomor. Draf tidak dihitung. Supplier yang sudah dihapus diabaikan.
2. **Pilihan supplier form**: dari barang yang terisi di form, supplier
   yang menjadi supplier terakhir untuk **paling banyak** barang. Bila
   seri, supplier dengan pembelian terbaru. Barang tanpa riwayat tidak
   dihitung. Tidak ada riwayat sama sekali: supplier tetap kosong (sama
   dengan F1-08c).
3. Supplier hanya diisi bila ada di daftar supplier form; staf tetap bisa
   menggantinya.
4. Catatan isian (`purchase-restock-note`) mendapat kalimat kedua:
   *Supplier diisi dari pembelian terakhir: {supplier} ({n} dari {m}
   barang).* / *Supplier filled from the last purchase: {supplier} ({n} of
   {m} items).* — m = barang yang terisi di form.
5. Harga baris tetap harga modal varian (aturan F1-08c).

## Rancangan teknis

- `lakuna_domain` (`stock.dart`): `chooseRestockSupplier<K>(Iterable<({K
  supplier, DateTime at})>)` → `({K supplier, int count})?`, murni.
- `lakuna_data` (`purchases.dart`): `lastSuppliersOf(store, scope,
  variantIds)` → peta varian → `({UuidValue supplierId, DateTime at})`.
- `PurchasesRepository.lastSuppliers(variantIds)` (lokal + palsu).
- `PurchaseFormViewModel`: saat menerapkan isian stok minimum, memuat
  supplier terakhir untuk baris yang terisi lalu mengisi `supplierId`;
  getter `restockSupplierName`, `restockSupplierCount`.
- l10n `purchaseRestockSupplierNote` (ID + EN).

## Tes

- Domain: pilihan terbanyak, seri → terbaru, kosong → null.
- Data: draf tidak dihitung, pembelian lebih baru menang, cabang lain dan
  supplier terhapus diabaikan.
- VM / widget: form dari stok minimum memilih supplier dan menampilkan
  catatan; tanpa riwayat supplier kosong; 1280 / 360 px.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Supplier terakhir di pembelian dari stok minimum | 1.18 / 1.19 | Dalam pengerjaan | — |
| Pecah draf per supplier | — | Belum | Satu draf satu supplier; barang dari supplier lain diubah atau dihapus staf. |
| Harga beli terakhir sebagai harga baris | — | Belum | Harga modal varian (rata-rata) tetap dipakai. |
