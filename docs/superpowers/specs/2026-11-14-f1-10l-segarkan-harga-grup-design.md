# F1-10l · Segarkan harga grup pelanggan di open bill

- **Fase:** 1
- **Status:** Rilis v0.88.0
- **Layar:** 1.7 / 1.8 *Meja* (panel bill, baris *Pelanggan*).
- **Acuan:** gap [F1-10f](2026-11-13-f1-10f-pelanggan-open-bill-design.md)
  *Segarkan harga saat grup pelanggan diubah di master*. Storeku tidak
  punya pelanggan di open bill; perbedaan dicatat di sini.

## Tujuan

Pelanggan bill bisa dipindah grup di menu Pelanggan (mis. dari tanpa grup
ke *Reseller*) saat bill-nya masih terbuka. Sekarang harga item lama tetap
memakai grup lama, item baru memakai grup baru, dan memilih ulang
pelanggan yang sama tidak berbuat apa-apa; kasir harus melepas lalu
memilih lagi tanpa tahu bahwa harganya sudah tidak cocok. Modul ini
mencatat grup yang dipakai untuk harga bill, memberi tahu bila grup
pelanggan sudah berubah, dan menyediakan tombol *Segarkan harga*.

## Aturan

1. **Grup harga bill.** Bill menyimpan grup yang dipakai saat harganya
   terakhir dihitung untuk pelanggan bill (`sales.price_group_id`,
   `null` = harga umum). Diisi saat memilih, mengganti, atau menghapus
   pelanggan, saat menyegarkan harga, saat gabung meja dengan pelanggan,
   dan saat item pertama masuk ke bill kosong yang punya pelanggan.
2. **Grup berubah.** Bila bill punya pelanggan (yang belum dihapus) dan
   punya item, sementara grup pelanggan sekarang berbeda dari grup harga
   bill (pelanggan pindah grup, dilepas dari grup, atau grupnya dihapus),
   panel bill menampilkan peringatan di bawah baris *Pelanggan*:
   *Grup pelanggan berubah. Harga bill masih memakai grup lama.* dengan
   tombol **Segarkan harga** (`dining-customer-refresh`). Peringatan tidak
   tampil saat bill di-split atau punya pembayaran bagian (pelanggan tidak
   bisa diubah, F1-10f aturan 4).
3. **Segarkan harga** = memilih ulang pelanggan yang sama. Harga **semua**
   item dihitung ulang dengan grup pelanggan sekarang (aturan hitung F1-07c
   seperti F1-10f aturan 3: harga menu terkini, modifier tetap ditambah,
   item yang produknya nonaktif/dihapus tetap memakai harga bekunya), lalu
   grup harga bill diperbarui. Bila grupnya sama, memilih ulang tidak
   mengubah apa pun (harga beku tetap).
4. **Ganti pelanggan** membandingkan grup pelanggan baru dengan **grup
   harga bill** (bukan grup pelanggan lama saat ini), sehingga bill yang
   harganya sudah tidak cocok ikut dihitung ulang walau grup pelanggan
   lama dan baru kebetulan sama. Bill tanpa pelanggan, atau yang
   pelanggannya sudah dihapus, dianggap berharga umum (harga beku tetap,
   F1-10f aturan 4).
5. **Gabung meja (F1-10d/F1-10f aturan 5).** Bila bill gabungan punya
   pelanggan, item tiap bill yang grup harganya berbeda dari grup
   pelanggan itu dihitung ulang (bill tanpa pelanggan atau pelanggannya
   dihapus dianggap berharga umum), lalu grup harga bill gabungan = grup
   pelanggan. Tanpa pelanggan, harga beku tidak berubah.
6. Item baru dan ubah jumlah tetap memakai grup pelanggan sekarang
   (F1-10f aturan 3); peringatan tetap tampil sampai harga disegarkan.
7. **Data lama.** Bill yang dibuka sebelum v0.88.0 belum punya grup harga
   (`null`). Bila pelanggannya bergrup, peringatan tampil; *Segarkan harga*
   menghitung ulang dengan grup yang sama dan harga menu terkini. Ganti
   pelanggan atau gabung meja pada bill lama seperti itu juga menghitung
   ulang itemnya dengan harga menu terkini.
9. Peringatan tetap tampil sampai *Segarkan harga* ditekan, walau semua
   item kebetulan sudah dihitung ulang dengan grup baru lewat ubah jumlah
   atau item baru.
8. Total, service, PB1, diskon nota, dan pembulatan dihitung ulang; diskon
   nota rupiah yang menghabiskan total baru ditolak (`DiscountTooLarge`),
   sama dengan F1-10f.

## Rancangan teknis

- Model `Sale.priceGroupId` (`price_group_id`, `UuidValue?`, tanpa relasi
  seperti `discount_approved_by`); migrasi `segarkan-harga-grup`.
- Data (`open_bill.dart`):
  - `setOpenBillCustomer`: pelanggan sama → keluar bila pelanggan sudah
    dihapus atau grupnya = `priceGroupId`; selain itu hitung ulang semua
    item. Pelanggan lain → hitung ulang bila `priceGroupId` ≠ grup baru.
    Simpan `priceGroupId` = grup pelanggan baru.
  - `mergeOpenBills`: bandingkan `priceGroupId` tiap bill dengan grup
    pelanggan gabungan (hanya bila ada pelanggan).
  - `addBillItem`: bill tanpa item yang punya pelanggan mencatat grupnya.
  - `OpenBill.priceGroupStale`.
- Flutter: `_BillCustomerRow` menampilkan peringatan + *Segarkan harga*
  (`vm.setCustomer.execute(customer.id)`); repositori palsu mencatat
  `priceGroupId`.
- l10n: `diningCustomerStale`, `diningCustomerRefresh`.

## Pengujian

- Data: grup pelanggan diubah → `priceGroupStale`, item baru memakai grup
  baru; pilih ulang pelanggan sama menghitung ulang semua item dan
  menghapus tanda; pilih ulang tanpa perubahan grup tidak mengubah harga
  beku walau harga menu naik; ganti ke pelanggan lain dengan grup yang
  sama dengan grup baru pelanggan lama tetap menghitung ulang; gabung meja
  memakai grup harga; bill kosong mencatat grup saat item pertama; data
  lama `null`; outbox.
- Flutter: widget panel 1280 / 360 px: peringatan tampil, *Segarkan
  harga* memanggil repositori dan peringatan hilang; tidak tampil saat
  split.
- Uji manual Xvfb: pilih pelanggan di bill, ubah grupnya di Pelanggan,
  kembali ke Meja, *Segarkan harga*.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Peringatan grup berubah + *Segarkan harga* | 1.7 | Rilis v0.88.0 | Grup harga bill di `sales.price_group_id`. |
| Segarkan harga di Kasir retail | — | Belum | Keranjang Kasir dihitung ulang tiap kali pelanggan dipilih. |
| Peringatan grup berubah saat split / bayar | — | Belum | Pelanggan tidak bisa diubah setelah split atau bayar bagian, jadi peringatan disembunyikan; bill dibayar dengan harga grup lama. |
