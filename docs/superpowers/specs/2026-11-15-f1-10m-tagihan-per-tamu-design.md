# F1-10m · Tagihan per tamu split bill

- **Fase:** 1
- **Status:** Rilis v0.102.0
- **Layar:** 1.9 Split bill (kartu tamu), struk tagihan 58/80 mm.
- **Acuan:** gap *Tagihan per tamu split bill* di
  [F1-10k](2026-11-14-f1-10k-cetak-tagihan-design.md). Storeku dan kanvas
  desain belum punya tagihan per tamu; ini perluasan layar 1.9.

## Masalah

Setelah bill di-split, tiap tamu ingin melihat bagiannya sendiri sebelum
membayar. Tagihan cetak F1-10k memuat seluruh bill, jadi pelayan harus
membacakan nominal tiap tamu dari layar split, dan tamu tidak tahu porsi
mana yang ia bayar atau berapa bagian service/PB1-nya.

## Aturan

1. Kartu tamu yang belum punya pembayaran di mode **Per item** atau
   **Rata** punya tombol **Cetak tagihan** (garis tepi) di bawah *Bayar
   bagian*. Tombol aktif bila tagihan tamu lebih dari nol dan, di mode
   Per item, tidak ada porsi tanpa tamu (tagihan masih sementara). Mode **Nominal
   bebas** tidak punya tagihan per tamu (nominal diketik saat bayar);
   tagihan seluruh bill tetap dari panel Meja (F1-10k).
2. Siapa pun yang bisa membuka layar split boleh mencetak (tidak
   mengubah data, tanpa izin `sales:create`).
3. Tombol membuka dialog **Tagihan tamu A · Meja 5** dengan perilaku sama
   seperti F1-10k: pratinjau kertas, **Tutup**, **Bagikan PDF**, **Cetak
   tagihan** ke printer struk perangkat; galat printer/PDF, *Struk
   terkirim ke printer*, dan lokasi PDF tampil di dialog; waktu cetak
   diambil saat tombol ditekan; hasil dari dialog lama tidak tampil di
   dialog berikutnya. Bila tagihan tamu tidak lagi bisa dicetak (tamu
   sudah membayar, mode berubah, porsi berpindah sehingga ada porsi tanpa
   tamu), dialog menutup sendiri.
4. Isi tagihan tamu (`guestBillReceiptContent`):
   - Kepala sama dengan struk (nama usaha, cabang, header, logo).
   - Banner **TAGIHAN TAMU A - BELUM DIBAYAR** / *GUEST A BILL - NOT
     PAID*.
   - Meta sama dengan tagihan F1-10k ditambah **Tamu: A dari 3**.
   - **Per item:** porsi milik tamu (porsi dari baris yang sama digabung,
     modifier, diskon baris). Bila tagihan tamu berbeda dari jumlah
     porsinya (bagian diskon nota, service, PB1, pembulatan bill dibagi
     proporsional): *Subtotal* (jumlah porsi) dan *Bagian Diskon 10%,
     Service 5%, PB1 10%* (selisihnya; hanya komponen yang ada, PB1
     termasuk harga tidak disebut; *Penyesuaian bill* bila tidak ada
     komponen biaya, mis. tamu terakhir menanggung sisa setelah tamu lain
     membayar kurang/lebih). Lalu **TAGIHAN TAMU A** (tebal).
   - **Rata:** seluruh pesanan dan rincian F&B seperti F1-10k, *TOTAL*
     (tidak tebal), *Dibagi rata 3 tamu*, lalu **TAGIHAN TAMU A** (tebal).
   - Nominal tagihan = tagihan di kartu tamu (tamu terakhir yang belum
     bayar menanggung sisa).
   - `Transfer ke: <rekening>` (F1-05e/F1-05f) bila diisi, lalu footer.
5. Mencetak tidak menyimpan apa pun dan tidak memberi nomor baru.

## Rancangan teknis

- `SplitBillData` mendapat `businessName`, `outletName`, `staffName`,
  `timezone`, `receipt` (`ReceiptConfig`), dan `printer`
  (`PrinterSelection?`), dimuat seperti `DiningData`.
- `BillPrintJob` (`lib/ui/receipt/bill_print_job.dart`): `ChangeNotifier`
  berisi perintah `print` / `share`, status galat/terkirim/PDF, dan
  generasi dialog (`reset()` saat dialog dibuka). Dipakai
  `DiningViewModel` (API publik `printBill`, `shareBill`, `billPrint*`,
  `clearBillPrint` tetap) dan `SplitBillViewModel` (`partPrint`).
- `showBillPrintDialog` (`lib/ui/receipt/bill_print_dialog.dart`):
  dialog pratinjau bersama F1-10k dan F1-10m (awalan kunci `dining-bill`
  / `split-bill`); pembuat baris mengembalikan `null` bila tagihan tidak
  lagi berlaku sehingga dialog menutup sendiri.
- `receipt_content.dart`: `guestBillReceiptContent`; rincian F&B tagihan
  dipisah ke `_chargeLines` agar dipakai tagihan bill dan tagihan tamu.
- `SplitBillViewModel`: menerima `ReceiptPrinter`; `canPrintPart(part)`,
  `paper`, `receiptLogo`, `partPrint`.
- l10n: `receiptBannerGuestBill`, `receiptGuest`, `receiptGuestOf`,
  `receiptGuestShare`, `receiptBillAdjustment`, `receiptSplitEqually`,
  `receiptGuestDue`, `billSplitBillTitle`.
- Tutup otomatis dialog memakai `pop` sinkron bila dialog rute teratas,
  atau `removeRoute` bila ada rute lain di atasnya, agar tidak terjadi
  pop ganda yang menutup layar di bawahnya.
- Temuan review (Minor, diperbaiki): label cadangan *Bagian Pembulatan*
  diganti *Penyesuaian bill*; tutup otomatis tidak lagi bisa membuat pop
  ganda; tes tambahan untuk sisa tamu terakhir, porsi turunan bermodifier,
  nama job lengkap, dan tutup otomatis (rute dialog benar-benar tertutup).

## Tes

- Unit `guestBillReceiptContent`: per item (porsi tamu, Subtotal, Bagian
  …, TAGIHAN TAMU), per item tanpa biaya (tanpa Subtotal/Bagian), rata
  (pesanan penuh, TOTAL tidak tebal, Dibagi rata, TAGIHAN), tamu terakhir
  menanggung sisa (A membayar kurang dari bagiannya), *Penyesuaian bill*,
  porsi turunan bermodifier digabung, PB1 termasuk harga tidak disebut,
  bahasa Inggris; diverifikasi mutasi.
- VM split: `canPrintPart` (mode, pembayaran, porsi tanpa tamu, nol),
  `partPrint` mencetak ke printer struk dengan kertas dan logo, galat
  printer tercatat, hasil dialog lama diabaikan.
- Widget split 1280/360: tombol nonaktif selama porsi belum dibagi,
  dialog hanya memuat porsi tamu, *Cetak tagihan* memanggil printer,
  PDF bernama `…-A.pdf`, hasil dialog tamu A tidak tampil di dialog tamu
  B, tombol hilang setelah tamu membayar, mode Nominal bebas tanpa
  tombol, mode Rata di ponsel tanpa overflow, dialog tertutup sendiri
  (rutenya, bukan hanya isinya) saat mode diganti ke Nominal bebas. Tes tagihan Meja F1-10k
  (dialog bersama) tetap lulus.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Tagihan per tamu (Per item, Rata) | 1.9 | Rilis v0.102.0 | Dari kartu tamu layar split. |
| Tagihan per tamu mode Nominal bebas | — | Belum | Nominal baru diketahui saat bayar; pakai tagihan seluruh bill. |
| Cetak semua tagihan tamu sekaligus | — | Belum | Satu per kartu. |
| QRIS statis di tagihan cetak | — | Belum | Sama seperti F1-10k. |
