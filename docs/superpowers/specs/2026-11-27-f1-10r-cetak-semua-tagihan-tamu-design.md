# F1-10r — Cetak semua tagihan tamu sekaligus

Tanggal: 2026-11-27 · Modul: F1-10 Meja F&B (1.9 Split bill) ·
Gap 17 di `docs/superpowers/GAP-FASE1.md`, gap 96 di STATUS-JEDA ·
Rilis: v0.153.0

## Masalah

Tagihan per tamu (F1-10m) dicetak satu per kartu tamu. Meja enam tamu
berarti enam kali buka dialog dan enam kali tekan *Cetak tagihan*, padahal
pelayan biasanya membagikan semua tagihan sekaligus.

## Aturan

1. Di mode **Per item** dan **Rata**, di bawah kartu tamu (di atas
   ringkasan) ada tombol garis tepi **Cetak semua tagihan (n)**, n = jumlah
   tamu yang tagihannya bisa dicetak (syarat F1-10m: belum ada pembayaran,
   tagihan > 0, dan di mode Per item tidak ada porsi tanpa tamu).
   - Tombol mati bila n = 0 (mis. masih ada porsi tanpa tamu, atau semua
     tamu sudah membayar). Mode **Nominal bebas** tidak punya tombol ini.
   - Tamu yang sudah membayar atau menunggu konfirmasi QRIS dilewati.
2. Izin sama dengan F1-10m: siapa pun yang bisa membuka layar split.
3. Tombol membuka dialog **Tagihan semua tamu · Meja 5** dengan perilaku
   F1-10m: pratinjau, **Tutup**, **Bagikan PDF**, **Cetak tagihan**; galat,
   *Struk terkirim ke printer*, dan lokasi PDF tampil di dialog; waktu cetak
   diambil saat tombol ditekan; hasil dialog lama tidak tampil di dialog
   berikutnya; dialog menutup sendiri bila tidak ada lagi tagihan yang bisa
   dicetak.
   - Pratinjau memuat tagihan tiap tamu berurutan (A, B, …), dipisah
     jarak, isinya sama persis dengan tagihan per kartu.
4. Hasil cetak:
   - **Printer struk langsung** (Bluetooth, jaringan): satu job per tamu,
     berurutan, jadi tiap tamu mendapat potongan kertas sendiri (printer
     ber-cutter memotong di antaranya). Bila satu job gagal, pengiriman
     berhenti dan galat tampil; *Cetak tagihan* lagi mengulang semua. Bila
     dialog ditutup di tengah pengiriman, sisa tagihan tidak dikirim.
   - **Dialog cetak sistem**: satu PDF, satu halaman struk per tamu, satu
     kali dialog. Ukuran awal dialog = struk terpanjang; tiap halaman PDF
     tetap seukuran isinya.
   - **Bagikan PDF**: satu berkas `tagihan-<bill>-semua.pdf`, satu halaman
     per tamu (logo di tiap halaman).
5. Mencetak tidak menyimpan apa pun dan tidak memberi nomor baru.

## Rancangan teknis

- `receipt_pdf.dart`: `buildReceiptsPdf(bills, paper, logo:)` membuat satu
  halaman per tagihan; `buildReceiptPdf` memanggilnya dengan satu tagihan
  (perilaku lama tetap, termasuk ulang tanpa logo bila logo rusak).
- `BillPrintJob`: perintah `printBills` dan `shareBills`
  (`List<List<ReceiptLine>>`). Satu tagihan memakai jalur lama
  (`print`/`sharePdf`). Lebih dari satu: printer langsung → `print` per
  tagihan; sistem → `printDocument` PDF banyak halaman; bagikan →
  `shareDocument`. Pembuat PDF disuntikkan (bawaan `buildReceiptsPdf`)
  agar tes tidak memuat font.
- `showBillPrintDialog`: `BillPrintPreview.bills` (daftar
  `ReceiptContent`) menggantikan `content`; satu tagihan → `printBill` /
  `shareBill` seperti dulu, lebih dari satu → `printBills` / `shareBills`.
- `SplitBillViewModel`: `printableParts`, `openAllPrint()` (nama job
  `tagihan-<bill>-semua`).
- `split_bill_view.dart`: tombol `split-print-all` dan dialog berawalan
  kunci `split-bill-all`.
- l10n: `billSplitPrintAll` (`Cetak semua tagihan ({count})`),
  `billSplitAllBillsTitle` (`Tagihan semua tamu · {order}`).

## Pengujian

- PDF: `buildReceiptsPdf` dua tagihan = dua halaman.
- `BillPrintJob`: dua tagihan ke printer langsung = dua job berurutan;
  gagal di job kedua berhenti dan tercatat; sistem = satu
  `printDocument`; bagikan = satu `shareDocument` bernama `…-semua.pdf`;
  satu tagihan tetap lewat `print` / `sharePdf`.
- VM split: `printableParts` (mode, pembayaran, porsi tanpa tamu, nol).
- Widget split 1280 / 360 px: tombol (n) dan mati saat porsi belum
  dibagi, tidak ada di Nominal bebas, dialog memuat tagihan semua tamu yang
  belum bayar, *Cetak tagihan* mengirim satu job per tamu, tanpa overflow.
- Uji manual Xvfb: split 3 tamu rata › Cetak semua tagihan.

## Status & gap

| Topik | Kode | Catatan |
| --- | --- | --- |
| Cetak semua tagihan tamu sekaligus | Rilis v0.153.0 | Per item dan Rata. |
| Lanjut dari tamu yang gagal dicetak | Belum | Cetak ulang mengirim semua tagihan lagi. |
| Kertas gulung di dialog cetak sistem | Catatan | Driver tertentu bisa memakai panjang struk terpanjang untuk semua halaman. |

Temuan review (Minor, diperbaiki): sisa job berhenti saat dialog ditutup,
nama job dibaca sekali, galat bukan `Exception` (mis. font PDF) tercatat
dan tampil, penghitung job di printer palsu, daftar tamu dihitung sekali.
