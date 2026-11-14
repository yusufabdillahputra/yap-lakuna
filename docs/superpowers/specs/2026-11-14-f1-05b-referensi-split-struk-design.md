# F1-05b — Referensi kartu/transfer di split payment dan struk

- **Status:** Rilis v0.64.0
- **Layar:** 1.5 *Pembayaran* panel *Split*, struk (cetak, pratinjau,
  cetak ulang dari Riwayat).
- **Acuan:** gap [F1-05](2026-11-03-f1-05-pembayaran-design.md)
  *Referensi kartu/transfer di bagian split*; spec Storeku F1-05
  ("Kartu: kasir boleh mengisi nomor approval di `payments.reference`").

## Tujuan

Bayar tunggal dengan kartu atau transfer sudah punya isian *No. approval* /
*Referensi transfer*, tapi bagian kartu/transfer di split payment belum,
dan nomor yang tersimpan tidak pernah tampil di struk. Akibatnya kasir dan
pelanggan tidak bisa mencocokkan struk dengan slip EDC atau mutasi
rekening.

## Aturan

1. **Split payment:** saat metode bagian baru *Kartu* atau *Transfer*,
   muncul isian opsional *No. approval kartu* / *Referensi transfer*
   (label dan contoh sama dengan bayar tunggal). Maks 40 karakter
   (`validatePaymentReference`); lebih dari itu *Tambah metode* nonaktif
   dengan pesan *Maksimal 40 karakter*.
2. Referensi dirapikan (trim) dan melekat pada bagian; tunai dan QRIS tidak
   membawa referensi walau isian sempat diketik lalu metodenya diganti.
3. Baris bagian di daftar split menampilkan referensinya di bawah nama
   metode. Isian dikosongkan setelah bagian ditambah dan saat masuk ke
   tahap bayar lagi.
4. **Struk:** di bawah baris pembayaran kartu/transfer yang punya
   referensi tercetak baris menjorok *No. approval* / *Ref. transfer*
   beserta nomornya. Berlaku untuk bayar tunggal, split payment, bagian
   split bill F&B, pratinjau, dan cetak ulang dari Riwayat (semua memakai
   `receiptContent`). Referensi panjang dibungkus ke baris berikutnya
   oleh tata letak struk.
5. Lapisan data tidak berubah: `payments.reference` sudah ada dan
   divalidasi 40 karakter.

## Komponen

- `CashierViewModel`: `SplitPart.reference`, `draftReference`,
  `setDraftReference`, `draftReferenceRevision`,
  `SplitDraftError.referenceTooLong`; `_payments()` meneruskan referensi
  bagian.
- `SplitPanel`: isian `split-reference`, teks referensi di baris
  `split-part-$i-reference`.
- `receiptContent`: `ReceiptPair` referensi di `totals`.
- l10n: `receiptApproval`, `receiptTransferRef` (id/en).

## Pengujian

- VM: referensi bagian kartu/transfer terkirim; tunai/QRIS tanpa
  referensi; terlalu panjang memblokir tambah; isian kosong setelah
  tambah.
- Widget: isian referensi tampil hanya untuk kartu/transfer, baris bagian
  menampilkan referensi.
- Struk: baris *No. approval* / *Ref. transfer* di bawah pembayarannya,
  tidak ada baris untuk referensi kosong; bahasa Inggris.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Referensi di bagian split payment | 1.5 | Rilis v0.64.0 | Selesai. |
| Referensi di struk | — | Rilis v0.64.0 | Selesai. |
| Ubah referensi setelah nota tersimpan | — | Belum | Void lalu ulang bila salah. |
| Cari nota berdasarkan referensi di Riwayat | 1.14 | Belum | Pencarian Riwayat memakai nomor nota. |
