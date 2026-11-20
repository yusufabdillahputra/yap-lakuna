# F1-05g · Rekening tujuan per pembayaran transfer

- **Fase:** 1
- **Status:** Rilis v0.135.0
- **Layar:** 1.5 Pembayaran (panel *Transfer bank* dan *Bagi beberapa
  metode*, termasuk bill Meja dan bagian split bill), struk (cetak,
  pratinjau, cetak ulang dari Riwayat), 1.24 Laporan › Ringkasan
  (*Per metode bayar*) dan ekspornya.
- **Acuan:** gap [F1-05f](2026-11-14-f1-05f-beberapa-rekening-transfer-design.md)
  *Catat rekening tujuan per pembayaran* dan gap
  [F1-05d](2026-11-14-f1-05d-rekening-split-payment-design.md) *Rekening di
  baris bagian transfer yang sudah ditambah*. Storeku belum punya rekening
  transfer; perbedaan dicatat di sini.

## Tujuan

Toko dengan dua atau tiga rekening (mis. BCA dan Mandiri) mencocokkan
mutasi tiap bank dengan penjualan. Sekarang nota hanya mencatat *Transfer
bank*, jadi pemilik tidak tahu transfer mana masuk ke rekening mana. Modul
ini mencatat rekening tujuan pada setiap pembayaran transfer dan
menampilkannya di struk dan laporan.

## Aturan

1. **Data.** `payments.transfer_account` (teks, nullable, maks 100
   karakter) menyimpan salinan baris rekening yang dipilih saat bayar,
   bukan ID: rekening di Pengaturan berupa teks bebas dan boleh diubah
   kemudian tanpa mengubah nota lama. Hanya pembayaran **Transfer bank**
   yang membawanya; metode lain selalu `null`. Teks dirapikan (trim);
   kosong = `null`; lebih dari 100 karakter ditolak
   (`SaleTransferAccountInvalid`). Migrasi `rekening-tujuan`.
2. **Pilih rekening (layar Bayar, panel Transfer).** Kotak *Transfer ke*
   tetap satu baris per rekening dengan tombol *Salin*. Tiap baris kini
   bisa dipilih (tanda centang di baris terpilih, `Semantics` selected):
   - 1 rekening: otomatis terpilih;
   - 2–3 rekening: belum ada yang terpilih; kasir mengetuk baris atau
     menekan *Salin* (menyalin juga memilih baris itu). Selama belum
     memilih, tombol selesai nonaktif dan petunjuk *Pilih rekening tujuan
     transfer* tampil di bawah kotak;
   - tanpa rekening: kotak tidak tampil dan transfer tersimpan tanpa
     rekening (perilaku lama).
3. **Bagi beberapa metode.** Sama untuk bagian transfer baru: kotak *Transfer
   ke* memilih rekening bagian itu; *Tambah metode* nonaktif selama
   rekening belum dipilih (2–3 rekening). Baris bagian transfer yang sudah
   ditambah menampilkan rekeningnya (menutup gap F1-05d). Pilihan
   dikosongkan setelah bagian ditambah.
4. **Struk.** Di bawah baris pembayaran transfer tercetak baris menjorok
   *Ke: \<rekening\>*, sebelum baris *Ref. transfer* bila ada. Berlaku untuk
   semua yang memakai `receiptContent` (struk, pratinjau, cetak ulang,
   bagian split bill). Baris menjorok yang terlalu panjang dibungkus dan
   tiap baris bungkusnya tetap menjorok (`layoutPair`), termasuk *Ref.
   transfer* panjang (sebelumnya jorokan hilang saat dibungkus).
5. **Laporan › Ringkasan, *Per metode bayar*.** Di bawah baris *Transfer
   bank* tampil rincian per rekening (nominal bersih), urut terbesar, dan
   *Tanpa rekening* untuk transfer lama atau toko tanpa rekening. Rincian
   hanya tampil bila ada transfer dengan rekening. Ekspor Excel/PDF memuat
   baris rincian yang sama (menjorok).
6. Pembayaran piutang pelanggan, hutang supplier, dan pengeluaran tidak
   berubah (gap).

## Rancangan teknis

- Server: `payment.spy.yaml` + `transferAccount: String?,
  column=transfer_account`; `serverpod generate`; `serverpod
  create-migration --tag rekening-tujuan`.
- Domain: `ReportPayment.transferAccount`; `transferByAccount(sales)` →
  `List<TransferAccountRow(account?, amount)>`.
- Data: `SalePaymentRequest.transferAccount` (default `''`);
  `checkPaymentRequests` menolak > 100 karakter; `insertPayments` menyimpan
  hanya untuk transfer; laporan membawa rekening.
- Flutter:
  - VM Kasir: `transferAccount` (rekening terpilih panel transfer; satu
    rekening otomatis), `transferAccountMissing`, `selectTransferAccount`;
    pindah metode membuang pilihan, mengetuk *Transfer* lagi menyimpannya.
    `SplitPart.transferAccount`, `draftTransferAccount`,
    `selectDraftTransferAccount`, `SplitDraftError.transferAccountMissing`;
    `canPay` dan `draftError` memperhitungkan pilihan; `_payments()`
    meneruskan rekening (transfer dan bagian split).
  - `TransferAccountBox(accounts:, selected:, onSelect:, enabled:)`: baris
    `FTappable` (fokus keyboard), judul *Rekening tujuan* saat memilih.
  - `receiptContent`: `ReceiptPair` *Ke:* di bawah pembayaran transfer.
  - Laporan: sub-baris di `_Methods` dan ekspor ringkasan.
- l10n: `paymentTransferChoose`, `paymentTransferSelected`,
  `receiptPaidTo`, `reportsTransferNoAccount`.

## Pengujian

- Data: transfer menyimpan rekening (dirapikan), metode lain `null`, 101
  karakter ditolak; laporan per rekening.
- Domain: `transferByAccount` (urut, *tanpa rekening*, kembalian tunai
  tidak ikut).
- VM: satu rekening otomatis; dua rekening wajib pilih; salin memilih;
  bagian split membawa rekening dan pilihan kosong setelah tambah.
- Widget: layar bayar 1280 + 360 px (pilih, salin, tombol selesai);
  baris bagian split; struk; laporan.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Rekening tujuan per pembayaran transfer penjualan | 1.5 | Rilis v0.135.0 | Struk dan laporan per rekening. |
| Rekening tujuan untuk pembayaran piutang / hutang | 1.20, 1.21 | Belum | Metode bayar piutang/hutang tetap tanpa rekening. |
| Rekening sebagai master (ID) | 1.26 | Belum | Disimpan sebagai salinan teks; ganti nama rekening tidak mengubah nota lama. |
