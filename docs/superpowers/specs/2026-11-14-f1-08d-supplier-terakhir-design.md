# F1-08d — Supplier terakhir saat membuat pembelian dari stok minimum

- **Fase:** 1
- **Status:** Rilis v0.83.0
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
3. Supplier hanya diisi bila ada di daftar supplier form dan staf belum
   memilih supplier sendiri; staf tetap bisa menggantinya. Mengganti
   supplier menghapus kalimat supplier di catatan. Galat baca riwayat
   diabaikan (supplier kosong seperti F1-08c).
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
- Data: draf tidak dihitung, pembelian lebih baru menang, supplier
  terhapus diabaikan (kembali ke pembelian sebelumnya). Saringan cabang
  sama dengan kueri pembelian lain (`outlet_id`).
- VM / widget: form dari stok minimum memilih supplier terbanyak dan
  menampilkan catatan; ganti supplier menghapus catatan; tanpa riwayat,
  supplier tidak ada lagi, atau galat baca: supplier kosong; 1280 /
  360 px.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Supplier terakhir di pembelian dari stok minimum | 1.18 / 1.19 | Rilis v0.83.0 | — |
| Pecah draf per supplier | — | Belum | Satu draf satu supplier; barang dari supplier lain diubah atau dihapus staf. |
| Harga beli terakhir sebagai harga baris | — | Rilis v0.89.0 | [F1-08e](2026-11-14-f1-08e-harga-beli-terakhir-design.md). |
| Abaikan pembelian yang seluruh barangnya diretur | — | Rilis v0.114.0 | [F1-08m](2026-11-15-f1-08m-supplier-terakhir-tanpa-retur-design.md): baris yang diretur penuh tidak dihitung; retur sebagian tetap. |
| Indeks `purchase_items(variant_id)` | — | Belum | Kueri membaca baris barang pembelian tenant lalu menyaring; cukup untuk skala UMKM, tambah indeks lewat migrasi bila lambat. |
