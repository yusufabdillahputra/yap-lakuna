# F1-03c — Peringatan uang di laci tidak cukup

- **Status:** Rilis v0.69.0
- **Layar:** 1.3 *Sesi kasir* (uang keluar), 1.14 *Retur* (pengembalian
  tunai), 1.19 *Pengeluaran* (sumber
  dana laci), 1.21 *Bayar hutang supplier* (dari laci), 1.20 *Pembelian*
  (dibayar dari laci).
- **Acuan:** gap F1-11 *Retur tunai melebihi uang di laci*; spec Storeku
  F1-11 merekomendasikan "Tampilkan peringatan bila perkiraan kas laci jadi
  minus".

## Tujuan

Semua uang keluar dari laci (uang keluar manual, retur tunai, pengeluaran,
bayar hutang supplier, pembelian tunai) dicatat sebagai pengurang kas laci sesi yang
terbuka. Saat ini aplikasi tidak memeriksa apakah uangnya ada, sehingga
*Kas seharusnya* di tutup sesi bisa minus tanpa kasir sadar. Modul ini
menampilkan peringatan sebelum menyimpan.

## Aturan

Cakupan modul ini adalah form yang mengisi jumlah uang keluar. Dialog
konfirmasi void (pembayaran piutang tunai, nota tunai sesi berjalan) juga
mengurangi kas laci tetapi belum diberi peringatan (lihat gap).

1. Perkiraan uang di laci = *Kas seharusnya* sesi kasir yang terbuka
   (saldo awal + penjualan tunai − retur tunai + kas masuk − kas keluar),
   dihitung sama dengan rekap sesi (F1-03).
2. Bila jumlah yang akan keluar dari laci **lebih besar** dari perkiraan
   itu, form menampilkan peringatan (ikon segitiga, gaya sama dengan peringatan
   label F1-07i):
   *"Uang di laci diperkirakan Rp X. Jumlah ini lebih Rp Y dari perkiraan;
   pastikan uangnya ada sebelum melanjutkan."* (v0.70.0: *menyimpan* →
   *melanjutkan* agar cocok juga di dialog void, F1-03d). Sama dengan
   perkiraan = tidak ada peringatan.
3. Peringatan **tidak memblokir** simpan. Perkiraan bisa berbeda dengan
   isi laci nyata (mis. pemilik menambah uang tanpa mencatat kas masuk);
   keputusan tetap di kasir, dan selisihnya terlihat di tutup sesi.
4. Peringatan hanya muncul bila uang benar-benar keluar dari laci: tab
   *Uang keluar* di Sesi kasir, metode retur *Tunai*, sumber dana *Kas
   laci*, dan sesi terbuka. Bila belum
   ada sesi, pesan lama (*buka sesi dulu*) tetap yang tampil.
5. Perkiraan dimuat ulang setelah setiap simpan yang berhasil di layar itu,
   jadi retur kedua memakai saldo setelah retur pertama.

## Rancangan teknis

- Domain (`cash_session.dart`): `Money? drawerShortfallOf(Money amount,
  Money? drawerCash)` mengembalikan kelebihan (`amount − drawerCash`) bila
  positif, selain itu `null` (juga saat `drawerCash` null = tanpa sesi).
- Data (`cash.dart`): `Future<Money?> openDrawerCash(store, scope)` =
  `cashDrawerFor(...).expectedCash` sesi terbuka atau `null`.
- Repositori Flutter: `HistoryData`, `ExpensesSetup`, `SuppliersSetup`,
  `PurchaseSetup` mendapat `Money? drawerCash` (bersama `hasOpenSession`).
- VM: getter `drawerShortfall` per form (`movementShortfall` di Sesi
  kasir, memakai rekap laci yang sudah tampil); widget bersama
  `DrawerShortfallNote` (`ui/core/drawer_shortfall_note.dart`) dengan kunci
  `<prefix>-drawer-short`.
- l10n: `drawerShortfallWarning(cash, over)`.

## Tes

- Domain `drawerShortfallOf`: kurang, sama, lebih, tanpa sesi.
- Data: `openDrawerCash` tanpa sesi = null; sama dengan *Kas seharusnya*
  rekap setelah uang keluar manual (`cash_test`) dan setelah penjualan
  tunai + retur tunai (`history_test`).
- VM per layar: peringatan muncul hanya untuk tunai/laci dan jumlah di atas
  perkiraan; simpan tetap bisa.
- VM Riwayat: perkiraan dimuat ulang setelah retur, void, dan `refresh`.
- Widget: teks peringatan tampil di Sesi kasir (360 px), retur,
  pengeluaran, bayar supplier, dan pembelian; simpan tetap jalan.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Peringatan uang keluar manual, retur tunai, pengeluaran, bayar supplier, pembelian dari laci | — | Rilis v0.69.0 | — |
| Perkiraan berubah karena transaksi di layar lain saat form terbuka | — | Perkiraan dimuat saat layar dibuka dan setelah simpan | Cukup untuk satu perangkat. |
| Void pembayaran piutang tunai, void nota tunai sesi ini | — | Rilis v0.70.0 | [F1-03d](2026-11-14-f1-03d-peringatan-laci-saat-void-design.md) |
| Blokir simpan bila laci kurang | — | Tidak (peringatan saja) | Jadikan pengaturan bila pemilik meminta. |
