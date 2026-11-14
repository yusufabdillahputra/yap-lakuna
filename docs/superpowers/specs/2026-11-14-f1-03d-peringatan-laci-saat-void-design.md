# F1-03d — Peringatan uang laci saat void

- **Status:** Rilis v0.70.0
- **Layar:** 1.14 *Void nota* (dialog alasan), 1.20 *Batal pembayaran
  piutang* (dialog alasan, panel pelanggan).
- **Acuan:** gap [F1-03c](2026-11-14-f1-03c-peringatan-kas-laci-design.md)
  *Void pembayaran piutang tunai, void nota tunai sesi ini*.

## Tujuan

F1-03c memperingatkan form yang mengisi jumlah uang keluar. Dua aksi lain
juga mengurangi *Kas seharusnya* tanpa mengetik jumlah: void nota tunai yang
uangnya diterima di sesi yang sedang buka, dan batal pembayaran piutang
pelanggan yang diterima tunai (kas keluar dari laci). Modul ini memakai
peringatan yang sama di kedua dialog konfirmasi.

## Aturan

1. **Void nota:** uang laci yang hilang = jumlah pembayaran *Tunai* lunas
   nota itu yang diterima di sesi kasir yang sedang buka, dikurangi
   kembalian (sama dengan cara rekap laci menghitung penjualan tunai,
   F1-10i: pembayaran tanpa sesi ikut sesi notanya). Void sendiri hanya
   boleh untuk nota sesi yang sedang buka yang semua pembayarannya di sesi
   itu (`VoidBlock.session`), jadi saringan sesi hanya pengaman.
2. **Batal pembayaran piutang pelanggan** yang tercatat di laci
   (`debtPaymentTouchesDrawer`): uang laci yang keluar = jumlah pembayaran.
   Batal bayar hutang supplier mengembalikan uang ke laci, jadi tanpa
   peringatan.
3. Bila jumlah itu lebih besar dari perkiraan uang di laci, dialog
   menampilkan peringatan F1-03c (teks dan gaya sama) di atas tombol
   konfirmasi. Peringatan tidak memblokir.
4. Tanpa sesi terbuka: tidak ada peringatan (void nota tidak mengubah
   laci; batal piutang tunai sudah ditolak oleh aturan lama).

## Rancangan teknis

- Data (`sales.dart`): `Money saleCashInSession(Iterable<Payment>,
  UuidValue sessionId, {UuidValue? saleSessionId})`, fungsi murni dengan
  aturan yang sama dengan rekap laci (dites cocok dengan penurunan rekap
  saat void).
- `HistoryData.openSessionId`, `CustomersSetup.drawerCash`. Panel
  pelanggan kini memuat ulang setup setiap muat (setelah terima/batal
  pembayaran) agar perkiraan tidak basi; setup lama dipakai bila gagal.
- `HistoryViewModel.voidDrawerShortfall`; `SaleVoidDialog` menerima
  `drawerCash` + `drawerShortfall` (kunci `history-void-drawer-short`).
- `showDebtPaymentVoidDialog(..., drawerCash:)` menghitung sendiri untuk
  pembayaran pelanggan (kunci `debt-void-drawer-short`).

## Tes

- Data: `saleCashInSession` (tunai dikurangi kembalian, non-tunai,
  belum lunas, sesi lain, pembayaran lama tanpa sesi).
- VM Riwayat: nota tunai sesi ini melebihi laci → kelebihan; nota sesi
  lain / QRIS → `null`.
- Widget: dialog void nota dan dialog batal piutang menampilkan peringatan;
  void tetap berjalan.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Peringatan void nota tunai dan batal piutang tunai | — | Rilis v0.70.0 | — |
| Muat ulang setup panel pelanggan | — | Setup penuh (struk, printer, sesi) dimuat setiap muat | Panggilan ringan khusus sesi + laci bila terasa lambat. |
| Void bagian split bill tunai | — | Ikut aturan void nota (semua pembayaran nota) | — |
