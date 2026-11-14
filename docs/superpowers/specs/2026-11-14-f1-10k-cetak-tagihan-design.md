# F1-10k — Cetak tagihan (pre-bill) open bill

- **Fase:** 1
- **Status:** Dalam pengerjaan (v0.80.0)
- **Layar:** 1.7 Meja & open bill (panel bill Meja dan Take away), struk
  tagihan 58/80 mm.
- **Acuan:** gap [F1-05e](2026-11-14-f1-05e-rekening-di-struk-design.md)
  *Rekening di struk tagihan open bill sebelum bayar*. Storeku dan kanvas
  desain belum punya cetak tagihan; layar ini perluasan desain 1.7.

## Tujuan

Di restoran, tamu biasanya meminta tagihan dulu di meja, memeriksanya,
lalu membayar. Lakuna baru bisa mencetak struk setelah pembayaran, jadi
pelayan harus membacakan total dari layar. Tagihan cetak (pre-bill)
memuat pesanan, rincian service/PB1, total, dan rekening transfer agar
tamu bisa memeriksa dan mentransfer sebelum kasir menutup bill.

## Aturan

1. Panel bill (Meja dan Take away) punya aksi **Cetak tagihan** di baris
   aksi tambahan, aktif bila bill punya item dan tidak ada aksi berjalan.
   Siapa pun yang bisa membuka bill boleh mencetak tagihan (tidak
   mengubah data).
2. Aksi membuka dialog **Tagihan {meja/antrean}** berisi pratinjau
   kertas, tombol **Tutup**, **Bagikan PDF**, dan **Cetak** (printer struk
   perangkat, sama dengan cetak ulang Riwayat). Galat printer, *Struk
   dicetak*, dan lokasi PDF tampil di dialog.
3. Isi tagihan (`billReceiptContent`):
   - Kepala sama dengan struk (nama usaha, cabang, header, logo).
   - Banner **TAGIHAN - BELUM DIBAYAR** / *BILL - NOT PAID*.
   - Meta: No (nomor bill), Tgl (waktu cetak, zona cabang), Kasir (staf
     bertugas), Pesanan (meja atau antrean take away, seperti struk),
     Pelanggan bila ada.
   - Barang sama dengan struk nota: porsi split digabung, modifier, diskon
     baris.
   - Rincian Subtotal, Diskon, Service, PB1, Pembulatan dari rincian bill
     (`OpenBill.charges`), lalu **TOTAL**.
   - Bila sebagian bagian split sudah dibayar: *Sudah dibayar* (minus) dan
     **Sisa tagihan** (tebal).
   - `Transfer ke: <rekening>` (F1-05e) bila rekening diisi.
   - Footer struk.
4. Mencetak tagihan tidak mengubah status *Minta bill*, tidak menyimpan
   apa pun, dan tidak memberi nomor nota baru.

## Rancangan teknis

- `DiningData` mendapat `businessName` dan `outletName` (dari tenant dan
  outlet, seperti Kasir/Riwayat).
- `receipt_content.dart`: `billReceiptContent(l10n, {bill, businessName,
  outletName, staffName, timezone, config, now})`; pembuat baris barang
  dipisah menjadi `_receiptItems` agar dipakai nota dan tagihan.
- `DiningViewModel`: `printBill` (`Command1<void, List<ReceiptLine>>`),
  `shareBill` (`Command1<String?, List<ReceiptLine>>`), `billPrintFailure`,
  `billPrinted`, `billPdfPath`, `receiptLogo`, `clearBillPrint()` saat
  dialog dibuka.
- l10n: `diningPrintBill`, `diningBillPreviewTitle`, `receiptBannerBill`,
  `receiptPaidSoFar`, `receiptBalanceDue`.

## Tes

- Unit `billReceiptContent`: banner, meta, item + modifier, rincian F&B,
  total; split sebagian dibayar → *Sudah dibayar* dan *Sisa tagihan*;
  rekening; Take away memakai label antrean; bahasa Inggris.
- VM: `printBill` ke printer struk, galat printer tercatat; `shareBill`
  menyimpan path.
- Widget Meja 1280/360: aksi *Cetak tagihan* nonaktif tanpa item, membuka
  dialog berisi TOTAL, *Cetak* memanggil printer; tanpa overflow.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Cetak tagihan open bill (pratinjau, cetak, PDF) | 1.7 | Dalam pengerjaan | — |
| Cetak tagihan otomatis menandai *Minta bill* | — | Belum | Sengaja terpisah; pelayan menekan *Minta bill* sendiri. |
| QRIS statis di tagihan cetak | — | Belum | Butuh cetak gambar QR ESC/POS; tamu memakai stiker QRIS di meja. |
| Tagihan per tamu split bill | — | Belum | Tagihan memuat seluruh bill; rincian per tamu ada di layar split. |
