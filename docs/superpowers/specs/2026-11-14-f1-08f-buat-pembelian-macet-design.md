# F1-08f · Tombol *Buat pembelian* macet setelah keluar lewat menu samping

- **Fase:** 1
- **Status:** Rilis v0.90.0
- **Layar:** 1.18 *Stok* › tab *Stok minimum* › *Buat pembelian*.
- **Acuan:** perbaikan bug [F1-08c](2026-11-14-f1-08c-pembelian-dari-stok-minimum-design.md).
  Storeku membuka form pembelian di panel yang sama, jadi bug ini khusus
  Lakuna.

## Masalah

*Buat pembelian* di tab *Stok minimum* membuka form pembelian baru di atas
halaman Stok (`context.push`). Penjaga ketukan ganda (`_restocking`) baru
dilepas, dan daftar stok baru dimuat ulang, setelah form ditutup. Bila staf
meninggalkan form lewat menu samping (mis. mengetuk *Stok* lagi), router
mengganti tumpukan dengan `go`: form hilang tetapi `push` tidak pernah
selesai. Akibatnya:

1. *Buat pembelian* tidak bereaksi lagi sampai aplikasi dibuka ulang
   (penjaga tetap terpasang).
2. Daftar stok dan tab *Stok minimum* tetap menampilkan angka lama,
   walau pembelian sudah diterima di layar lain.

## Aturan

1. Saat halaman Stok kembali menjadi rute teratas lewat navigasi router
   (menu samping atau tautan) sementara form pembelian dari stok minimum
   masih tercatat terbuka, penjaga dilepas dan daftar stok dimuat ulang.
2. Saat form baru dibuka (push), halaman Stok juga dibangun ulang tetapi
   bukan rute teratas, jadi penjaga tetap dipegang: ketukan ganda tetap
   hanya membuka satu form.
3. Alur normal tidak berubah: menutup form (simpan, terima, atau batal)
   memuat ulang daftar dan, bila diterima, membuka detail pembelian.

## Rancangan teknis

- `StockScreen` (`stock_view.dart`): `didUpdateWidget` melepas
  `_restocking` dan memanggil `load` bila `_restocking` dan
  `ModalRoute.of(context)?.isCurrent == true`.
- Nomor generasi `_restockGen` naik tiap kali form dibuka atau penjaga
  dilepas paksa; `finally` dari form lama hanya melepas penjaga bila
  generasinya masih sama, sehingga form lama yang (mis. di versi router
  lain) selesai belakangan tidak membuka celah ketukan ganda pada form
  baru.

## Pengujian

- Widget (`stock_flow_test.dart`): buka *Buat pembelian*, stok berubah,
  ketuk `nav-stock`; form hilang, tab *Stok minimum* menampilkan data
  baru, dan *Buat pembelian* membuka form lagi.
- Widget: dua ketukan *Buat pembelian* dalam satu frame hanya membuka satu
  form (sekali *Kembali* langsung ke Stok). Tes ini gagal bila penjaga
  dibuang. Ketukan saat form sedang masuk tidak mungkin, karena rute Stok
  mengabaikan sentuhan selama tertutup rute baru.
- Uji manual Xvfb: Stok › *Stok minimum* › *Buat pembelian* → menu
  samping *Stok* → *Buat pembelian* lagi.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| *Buat pembelian* tidak macet setelah keluar lewat menu samping | 1.18 | Rilis v0.90.0 | Penjaga dilepas dan daftar dimuat ulang saat Stok kembali menjadi rute teratas. |
| Daftar Pembelian / Pelanggan / Supplier dimuat ulang setelah keluar dari detail lewat menu samping | — | Rilis v0.91.0 ([F1-12d](2026-11-14-f1-12d-muat-ulang-daftar-design.md)) | Daftar itu hanya dimuat ulang saat detail ditutup; keluar lewat menu samping ke daftar yang sama memperlihatkan data lama sampai daftar disegarkan. |
