# F1-10f · Pelanggan di open bill + harga grup

- **Fase:** 1
- **Status:** Rilis v0.42.0
- **Layar:** 1.7 / 1.8 *Meja* (panel bill: baris *Pelanggan*), 1.5 / 1.5b
  bayar bill (kredit memakai pelanggan bill).
- **Acuan:** spec Lakuna F1-07c (harga grosir per grup pelanggan, aturan
  hitung harga), F1-04d (pelanggan nota non-kredit), F1-13b (kredit open
  bill). Storeku tidak punya pelanggan di open bill; perbedaan dicatat di
  sini.
- **Menutup gap:** F1-07c "Harga grup di open bill F&B".

## Tujuan

Pelanggan langganan (mis. grup *Reseller* atau *Karyawan*) bisa dicatat
di bill meja atau take away sejak awal, sehingga harga grup otomatis
berlaku di bill, tiket, dan saat bayar, tanpa diskon manual.

## Aturan

1. **Pelanggan bill.** Panel bill punya baris *Pelanggan*: *Pilih
   pelanggan* membuka pemilih (cari nama/HP, sama dengan Kasir). Setelah
   dipilih tampil nama (dan grup bila ada) dengan *Ganti* dan *Hapus*.
   Disimpan di `sales.customer_id` bill. Butuh izin `open_bills:manage`
   (sama dengan aksi bill lain).
2. **Nama pemesan.** Bila bill belum punya nama pemesan, nama pelanggan
   dipakai (tampil di tiket dapur dan struk), dipotong ke 40 karakter
   (`FnbLimits.customerName`). Menghapus pelanggan juga menghapus nama
   pemesan bila nama itu sama dengan nama pelanggan.
3. **Harga.** Memilih, mengganti, atau menghapus pelanggan yang
   **mengubah grup harga** bill menghitung ulang harga **semua** item bill
   (termasuk yang sudah di dapur) dengan aturan F1-07c: tingkat umum vs
   tingkat grup pelanggan, ambil yang lebih murah; modifier tetap
   ditambahkan. Bila grupnya sama (mis. pelanggan tanpa grup, hanya untuk
   nama atau kredit), harga beku item tidak berubah walau harga menu sudah
   naik. Item yang produknya sudah nonaktif/dihapus tetap memakai harga
   bekunya. Item baru dan ubah jumlah memakai grup pelanggan bill. Total,
   service, PB1, diskon nota, dan pembulatan dihitung ulang; diskon nota
   rupiah yang menghabiskan total baru ditolak (`DiscountTooLarge`).
4. **Ditolak** (`BillCustomerBlocked`) bila bill sedang di-split atau sudah
   punya pembayaran bagian, karena porsi split sudah dibagi dengan harga
   lama. Memilih pelanggan yang dihapus → `CustomerNotFound`. Pelanggan
   bill yang dihapus kemudian dianggap tanpa pelanggan (panel *Pelanggan
   umum*, gabung dan kredit pelanggan mana pun boleh); harga beku item
   tetap.
5. **Gabung meja (F1-10d).** Dua bill dengan pelanggan berbeda tidak bisa
   digabung (`BillMergeReason.customer`). Bila hanya satu yang punya
   pelanggan, bill gabungan memakai pelanggan itu dan item bill yang grupnya
   berbeda dihitung ulang dengan grupnya.
6. **Bayar.** Kasir bill memakai pelanggan bill sebagai pelanggan nota;
   pilihan kredit awal = pelanggan bill. Kredit atas nama pelanggan lain
   ditolak (`BillCustomerMismatch`) agar total yang tampil sama dengan yang
   disimpan; ganti pelanggan di panel meja dulu. Bill tanpa pelanggan yang
   dibayar kredit tetap memakai harga bill (perilaku lama).
7. Split bill tidak berubah: harga per porsi mengikuti harga bill saat
   split dibuat.

## Komponen

- Data: `setOpenBillCustomer(store, scope, staffId:, billId:, customerId:)`,
  `BillCustomerBlocked`, `BillCustomerMismatch`, helper hitung ulang harga
  bill per grup; `addBillItem` / `setBillItemQuantity` /
  `mergeOpenBills` memakai grup pelanggan bill; `OpenBill.customer`
  (id, nama, grup) untuk UI.
- Flutter: `DiningRepository.setBillCustomer` + `customers()`;
  `DiningViewModel.setCustomer` dan daftar pemilih; baris *Pelanggan* di
  panel bill; `CashierViewModel` mengisi pelanggan nota dari bill.

## Pengujian

- Data: pilih pelanggan grup → harga grup untuk item dapur dan baru; hapus
  → harga umum; ditolak saat split/pembayaran bagian; gabung dengan
  pelanggan berbeda ditolak, satu pelanggan → harga grup; bayar kredit
  pelanggan lain ditolak; outbox.
- Flutter: VM meja (pilih/hapus pelanggan, galat), widget panel 1280 /
  360 px, Kasir bill memakai pelanggan bill untuk kredit.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Pelanggan di open bill + harga grup | — | Rilis v0.42.0 | Baris kosong menampilkan *Pelanggan umum* seperti Kasir. |
| Pelanggan per bagian split bill | — | Belum | Ikut gap kredit per bagian (F1-13b). |
| Segarkan harga saat grup pelanggan diubah di master | — | Belum | Memilih ulang pelanggan yang sama tidak menghitung ulang; lepas lalu pilih lagi. |
