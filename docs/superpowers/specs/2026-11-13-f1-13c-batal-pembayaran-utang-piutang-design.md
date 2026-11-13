# F1-13c · Batal pembayaran piutang & hutang

- **Fase:** 1
- **Status:** Rilis v0.44.0
- **Layar:** 1.20 / 1.20b detail pelanggan (riwayat pembayaran dan
  kuitansi), 1.21 detail supplier (riwayat bayar hutang).
- **Acuan:** spec F1-13 (gap "Batal pembayaran piutang"), F1-14 (gap "Batal
  pembayaran hutang"), F1-15 (pola batal pengeluaran: `voidedAt` +
  jurnal balik kas). Storeku F1-13 mencatat gap yang sama ("void pembayaran
  + jurnal balik kas"); perbedaan dicatat di sini.

## Tujuan

Pembayaran piutang atau hutang yang salah catat (nominal, pelanggan, atau
nota keliru) bisa dibatalkan tanpa menghapus jejaknya, lalu dicatat ulang
dengan benar. Saldo piutang/hutang dan kas kembali seperti sebelum
pembayaran.

## Aturan

1. **Batal, bukan hapus.** Kolom baru di `debt_payments`: `voided_at`,
   `voided_by`, `void_reason` (wajib, 1–200 karakter, sama dengan batal
   pengeluaran), `void_cash_movement_id`. Pembayaran batal tetap tampil di
   riwayat dengan label *Batal* dan alasannya; kuitansinya bisa dibuka dan
   bercap *BATAL*.
2. **Alokasi.** Semua alokasi pembayaran itu di-soft-delete
   (`deleted_at`) dalam transaksi yang sama, sehingga sisa piutang nota /
   hutang pembelian, status *Lunas*, dan laporan piutang/hutang kembali
   seperti sebelum pembayaran. `balance_after` pembayaran lain tidak
   diubah (cuplikan saat itu).
3. **Jurnal balik kas.**
   - Piutang tunai yang masuk laci (`cash_session_id` terisi): kas keluar
     sejumlah pembayaran di sesi kasir yang sedang terbuka di perangkat
     ini (`source` `debt_payment_void`). Wajib ada sesi terbuka
     (`CashSessionNotOpen`) dan izin `cash_movements:create`.
   - Hutang yang dibayar dari laci (`funding_source` `drawer`): kas masuk
     kembali di sesi terbuka (`source` `supplier_payment_void`), aturan
     sesi dan izin sama.
   - Metode lain (transfer, kartu, QRIS, kas toko, bank): tanpa gerakan
     kas.
4. **Izin.** `debts:manage` (sama dengan mencatat pembayaran), ditambah
   `cash_movements:create` bila ada jurnal balik laci.
5. **Ditolak:** pembayaran sudah batal (`DebtPaymentAlreadyVoided`), bukan
   milik tenant/cabang ini (`DebtPaymentNotFound`), alasan kosong/terlalu
   panjang (`DebtPaymentVoidReasonInvalid`).
6. **Laporan kas.** Sumber baru tampil sebagai *Batal bayar piutang* dan
   *Batal bayar hutang* di tab Kas.
7. Sinkronisasi: semua tulisan lewat outbox seperti biasa.

## Komponen

- Model `debt_payment.spy.yaml` + migrasi `batal-bayar-utang`.
- Data: `voidDebtPayment(store, scope, staffId:, paymentId:, reason:)`
  untuk piutang dan hutang; konstanta `debtPaymentVoidCashSource`,
  `supplierPaymentVoidCashSource`; `CashSourceKind`.
- Flutter: tombol ikon *Batalkan pembayaran* pada baris riwayat
  pembayaran (detail pelanggan dan supplier) membuka dialog alasan
  bersama (`debt_payment_void_dialog.dart`); baris batal dicoret + label
  *Batal* + alasan; kuitansi piutang bercap *BATAL* dan memuat alasan.
  Tombol hanya muncul untuk pembayaran yang dicatat di cabang aktif
  (jurnal balik kas memakai sesi kasir cabang ini).

## Perbedaan dengan Storeku

Storeku belum punya batal pembayaran piutang (gap). Lakuna memakai pola
batal pengeluaran F1-15: kolom `voided_*` di dokumen, bukan dokumen
pembalik terpisah, sehingga nomor `BP-`/`BH-` tidak bertambah.

## Pengujian

- Data: batal piutang tunai (alokasi hilang, sisa nota kembali, kas keluar
  di sesi terbuka); batal transfer tanpa kas; tanpa sesi ditolak untuk
  tunai laci; batal dua kali ditolak; alasan; izin; hutang dari laci (kas
  masuk) dan dari bank; outbox; laporan kas.
- Flutter: VM detail pelanggan/supplier (batal, galat); widget dialog
  1280 / 360 px.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Batal pembayaran piutang & hutang | — | Selesai v0.44.0 | Tombol ikon di baris riwayat; hanya pembayaran cabang ini. |
| Ubah pembayaran tanpa batal | — | Belum | Koreksi = batal lalu catat ulang. |
