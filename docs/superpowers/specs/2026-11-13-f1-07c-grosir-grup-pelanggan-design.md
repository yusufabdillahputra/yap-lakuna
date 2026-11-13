# F1-07c · Harga grosir per grup pelanggan

- **Fase:** 1
- **Status:** Rilis v0.34.0
- **Layar:** 1.16 Form produk tab *Harga grosir* (kolom *Berlaku untuk*),
  1.4 / 1.4b Kasir (harga ikut pelanggan terpilih), 1.5b kredit.
- **Acuan Storeku:** F1-07 gap "Grosir *Berlaku untuk* grup pelanggan":
  `price_tiers.customer_group_id` nullable (`null` = semua pelanggan).
- **Menutup gap:** F1-04d / F1-13 "Harga grosir per grup pelanggan".

## Tujuan

Toko bisa memberi harga khusus untuk grup pelanggan (mis. *Reseller*,
*Grosir*): harganya otomatis dipakai di Kasir saat pelanggan grup itu
dipilih, tanpa diskon manual.

## Aturan

1. **Model.** `price_tiers` mendapat `customer_group_id` (nullable,
   relasi ke `customer_groups`). `null` = tingkat untuk semua pelanggan
   (perilaku lama). Migrasi `grosir-grup`.
2. **Form produk 1.16.** Kolom *Berlaku untuk* di tiap baris grosir
   menjadi pilihan: *Semua pelanggan* atau salah satu grup pelanggan
   (urut nama). Validasi:
   - tingkat semua pelanggan: mulai jumlah > 1 (aturan lama);
   - tingkat grup: mulai jumlah > 0, sehingga harga grup bisa berlaku sejak
     1 satuan (harga reseller);
   - jumlah yang sama tidak boleh dobel **dalam grup yang sama** (semua
     pelanggan dihitung sebagai satu grup);
   - harga > 0 (aturan lama).
3. **Hitung harga baris** (satuan dasar saja; satuan konversi tetap tanpa
   grosir):
   - tingkat umum terbaik = `minQty` terbesar ≤ jumlah dari tingkat semua
     pelanggan;
   - tingkat grup terbaik = sama, dari tingkat grup pelanggan nota;
   - harga = yang **lebih murah** dari kedua tingkat itu (atau harga jual
     bila tidak ada). Tanpa pelanggan atau pelanggan tanpa grup, hanya
     tingkat umum yang berlaku (perilaku lama tidak berubah).
   - Potongan tampil sebagai *Diskon grosir* seperti sekarang.
4. **Kasir.** Harga keranjang dihitung ulang saat pelanggan dipilih,
   diganti, dihapus, dibuat baru (F1-04f), atau dipilih dari panel kredit.
   Nota tersimpan dan draf keranjang membawa grup pelanggan.
5. **Lapisan data** menghitung ulang harga dengan grup pelanggan nota
   (`customerId` atau pelanggan kredit) saat checkout dan saat menyimpan
   nota, sehingga total di Kasir sama dengan total yang disimpan.
6. **Daftar produk 1.15** kolom grosir tetap menampilkan tingkat pertama
   (umum lebih dulu).
7. **F&B open bill** tidak memakai harga grup (bill tidak berpelanggan
   sampai ditutup); dicatat sebagai gap.
8. **Hapus grup pelanggan** ditolak (`CustomerGroupHasPrices`) selama grup
   masih dipakai tingkat grosir produk, sama seperti grup yang masih punya
   pelanggan. Simpan produk dengan grup yang sudah dihapus ditolak
   (`PriceTierGroupNotFound`).

## Komponen

- Server: `price_tier.spy.yaml` + generate + migrasi.
- Domain: `PriceTier.groupId`, `tierFor(tiers, qty, groupId:)`,
  `priceSaleLine(..., customerGroupId:)`, validasi tingkat per grup.
- Data: `listProducts` / `_saveTiers` membawa grup; `priceRequests` dan
  `priceSaleLines` menerima grup pelanggan; checkout, parkir, dan muat nota
  tersimpan memakai grup pelanggan.
- Flutter: `ProductCatalog.customerGroups`, `EditableTier.groupId`, pilihan
  *Berlaku untuk*; `CashierViewModel` menyimpan grup pelanggan terpilih.

## Pengujian

- Domain: tier grup lebih murah dipakai, tier umum lebih murah tetap
  dipakai, grup lain diabaikan, tanpa grup = perilaku lama, validasi
  (grup ≥ 1, dobel per grup).
- Data: simpan/muat tingkat grup; checkout tunai dan kredit dengan
  pelanggan grup menyimpan harga grup; parkir + lanjutkan.
- Flutter: VM form produk (pilih grup), VM Kasir (harga berubah saat
  pelanggan dipilih/dihapus), widget form 1280/360 px, Kasir dengan
  pelanggan grup.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Harga grosir per grup pelanggan di Kasir retail | 1.16, 1.4 | Rilis v0.34.0 | Termasuk kredit dan nota tersimpan. |
| Harga grup di open bill F&B | — | Belum | Bill belum berpelanggan saat item ditambahkan. |
| Harga grup untuk satuan konversi | — | Belum | Grosir hanya untuk satuan dasar (aturan lama). |
