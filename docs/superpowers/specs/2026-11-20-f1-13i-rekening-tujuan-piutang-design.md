# F1-13i · Rekening tujuan pembayaran piutang transfer

- **Fase:** 1
- **Status:** Rilis v0.136.0
- **Layar:** 1.20 Pelanggan › panel pelanggan (*Terima pembayaran* dan
  riwayat bayar), 1.20b kuitansi A5 (pratinjau, PDF, cetak ulang).
- **Acuan:** gap [F1-05g](2026-11-20-f1-05g-rekening-tujuan-per-pembayaran-design.md)
  *Rekening tujuan untuk pembayaran piutang / hutang*. Storeku belum punya
  rekening transfer; perbedaan dicatat di sini.

## Tujuan

F1-05g mencatat rekening tujuan pada pembayaran transfer penjualan. Pelunasan
piutang lewat transfer juga masuk ke salah satu rekening toko, jadi pemilik
perlu tahu rekening mana untuk mencocokkan mutasi bank. Modul ini memakai
aturan yang sama untuk pembayaran piutang pelanggan.

## Aturan

1. **Data.** `debt_payments.transfer_account` (teks, nullable, maks 100
   karakter): salinan baris rekening yang dipilih, bukan ID (sama dengan
   F1-05g). Hanya pembayaran piutang pelanggan bermetode **Transfer bank**
   yang membawanya; metode lain dan bayar hutang supplier selalu `null`.
   Teks dirapikan (trim); kosong = `null`; lebih dari 100 karakter ditolak
   (`SaleTransferAccountInvalid`, sama dengan F1-05g). Migrasi
   `rekening-piutang`.
2. **Terima pembayaran (1.20).** Saat metode *Transfer bank* dipilih dan
   toko punya rekening, kotak *Transfer ke* (komponen yang sama dengan
   layar Bayar) tampil di bawah isian:
   - 1 rekening: otomatis terpilih;
   - 2–3 rekening: kasir mengetuk baris atau menekan *Salin*; selama
     belum memilih, tombol *Terima pembayaran* nonaktif dan petunjuk
     *Pilih rekening tujuan transfer.* tampil;
   - tanpa rekening: kotak tidak tampil, transfer tersimpan tanpa
     rekening.
   Pindah metode membuang pilihan. Setelah pembayaran tersimpan pilihan
   dikosongkan.
3. **Riwayat bayar di panel.** Baris pembayaran transfer menampilkan
   *Ke: \<rekening\>* di bawah metode.
4. **Kuitansi (1.20b).** A5: isian *Ke rekening* tepat di bawah *Metode*
   untuk pembayaran transfer yang punya rekening. Struk thermal: baris
   menjorok *Ke: \<rekening\>* di bawah baris metode. Isian/baris
   *Transfer sisa ke* (F1-05e) tetap di akhir.
5. Bayar hutang supplier (1.21) tidak berubah: uang keluar dari toko;
   rekening sumber dicatat lewat *Sumber dana* dan *No. bukti* (gap).

## Rancangan teknis

- Server: `debt_payment.spy.yaml` + `transferAccount: String?,
  column=transfer_account`; `serverpod generate`; `serverpod
  create-migration --tag rekening-piutang`.
- Data: `DebtPaymentRequest.transferAccount` (default `''`);
  `receiveDebtPayment` menolak > 100 karakter dan menyimpan hanya untuk
  transfer (`SaleTransferAccountInvalid`).
- Flutter:
  - `CustomerPanelViewModel`: `transferAccounts` (dari
    `setup.receipt.transferAccounts`), `transferAccount`,
    `transferAccountMissing`, `selectTransferAccount`; `canSubmit`
    memperhitungkan pilihan; `_receive` meneruskan rekening dan
    mengembalikan `DebtTransferAccountMissing` bila belum memilih.
  - `_PaymentFields` menampilkan `TransferAccountBox` saat transfer.
  - `debtTransferAccount(p)`: riwayat bayar, `kuitansiDocument`, dan
    `kuitansiReceiptContent` (thermal).
  - `customerErrorMessage`: `DebtTransferAccountMissing` →
    `paymentTransferChoose`, `SaleTransferAccountInvalid` →
    `debtErrTransferAccount`. Galat *pilih rekening* hanya bila isian lain
    sah, dan hilang saat rekening dipilih.
- l10n: `kuitansiPaidTo` (*Ke rekening* / *To account*),
  `debtErrTransferAccount`; memakai ulang
  `paymentTransferChoose` dan `receiptPaidTo`.

## Pengujian

- Data: transfer menyimpan rekening (dirapikan), tunai `null`, 101
  karakter ditolak.
- VM: satu rekening otomatis; dua rekening wajib pilih; pindah metode
  membuang pilihan; permintaan membawa rekening.
- Widget: panel 1280 + 360 px (pilih, tombol, riwayat); kuitansi.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Rekening tujuan pembayaran piutang transfer | 1.20 | Rilis v0.136.0 | Panel, riwayat, kuitansi A5 dan thermal. |
| Rekening sumber bayar hutang supplier | 1.21 | Belum | Pakai *Sumber dana* dan *No. bukti*. |
| Rincian piutang per rekening di laporan | 1.24 | Belum | Laporan per metode bayar hanya membaca penjualan. |
| Daftar rekening segar saat panel terbuka | — | Belum | Rekening dibaca saat panel dibuka / setelah simpan; ubahan di jendela lain terbaca setelah dimuat ulang (sama dengan Kasir). |
