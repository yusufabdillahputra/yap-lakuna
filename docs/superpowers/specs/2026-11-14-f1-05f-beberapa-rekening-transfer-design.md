# F1-05f · Beberapa rekening transfer

- **Fase:** 1
- **Status:** Rilis v0.86.0
- **Layar:** 1.26 Pengaturan (*Penjualan & stok*), 1.5 Pembayaran (panel
  transfer dan *Bagi beberapa metode*), 1.12 struk, 1.20b kuitansi.
- **Acuan:** gap [F1-05c](2026-11-14-f1-05c-rekening-transfer-design.md)
  *Beberapa rekening terpisah (pilih bank)*. Storeku belum punya rekening
  transfer sama sekali; perbedaan dicatat di sini.

## Tujuan

Banyak toko punya lebih dari satu rekening (mis. BCA dan Mandiri) agar
pembeli bisa transfer antarbank yang sama tanpa biaya. Sekarang semua
rekening harus ditulis di satu baris, sehingga sulit dibaca dan tombol
*Salin* menyalin semuanya sekaligus. Modul ini memisahkan rekening per
baris: kasir bisa menyalin rekening bank yang dipilih pembeli saja.

## Aturan

1. **Pengaturan (1.26), *Penjualan & stok*:** isian *Rekening transfer*
   menjadi beberapa baris: **satu rekening per baris, maksimal 3 rekening,
   tiap baris maksimal 100 karakter**. Baris kosong dan spasi di awal/akhir
   baris dibuang saat disimpan. Lebih dari 3 rekening atau baris terlalu
   panjang menampilkan galat di bawah isian dan tombol *Simpan* nonaktif.
   Data lama (satu baris) tetap terbaca sebagai satu rekening.
2. **Tombol metode *Transfer bank*** (layar lebar): keterangan kecil berisi
   semua rekening dipisah ` · ` (dipotong elipsis bila panjang; hanya
   petunjuk, rekening utuh ada di kotak *Transfer ke*).
3. **Kotak *Transfer ke*** (panel transfer dan baris transfer *Bagi
   beberapa metode*): satu baris per rekening, masing-masing dengan tombol
   *Salin* sendiri. Tombol yang ditekan berubah menjadi *Disalin*; tombol
   lain kembali ke *Salin*. Di layar sempit tombol turun ke bawah teks.
4. **Struk thermal** (nota piutang, tagihan pre-bill, kuitansi thermal):
   satu baris *Transfer ke: …* per rekening, dengan syarat tampil yang sama
   seperti F1-05e/F1-10k.
5. **Kuitansi A5:** isian *Transfer sisa ke* memuat semua rekening, satu
   per baris.
6. Tidak ada pilihan "rekening utama" atau pencatatan rekening tujuan per
   pembayaran (gap).

## Rancangan teknis

- Domain (`store_settings.dart`):
  - `ProfileLimits.transferAccountLines = 3` (per baris tetap
    `ProfileLimits.transferAccount = 100`).
  - `enum TransferAccountIssue { tooMany, tooLong }`;
    `transferAccountIssue(String text)` memeriksa baris yang sudah
    dirapikan.
  - `normalizeTransferAccounts(String text)`: pisah `\n`, pangkas tiap
    baris, buang baris kosong, gabung `\n`.
  - `SalesRules.transferAccounts` (`List<String>`): baris yang tidak
    kosong. `fromJson` merapikan dan membatasi data tersimpan (tiap baris
    100 karakter, maks 3 baris) agar data rusak tidak membuat simpan
    aturan lain gagal.
  - Kunci JSON tetap `transferAccount` (string, baris dipisah `\n`), jadi
    data lama dan cadangan lama tetap cocok.
- Data: `saveSalesRules` merapikan teks dan melempar `SalesRulesInvalid`
  bila `transferAccountIssue` tidak null.
- Flutter:
  - VM Pengaturan: `transferAccountIssue`; `rulesDirty` membandingkan
    teks yang dirapikan; `canSaveRules` = dirty dan tanpa galat.
  - Isian pengaturan: `minLines: 1`, `maxLines: 3`, tanpa penghitung
    `maxLength`, `error` sesuai galat.
  - VM Kasir: `transferAccounts` (`List<String>`) menggantikan
    `transferAccount`.
  - `TransferAccountBox(accounts:)`: kunci kotak tetap
    `payment-transfer-account`; tombol salin `payment-transfer-copy-$i`.
  - `receiptTransferLines(l10n, accounts)` menggantikan
    `receiptTransferLine` (list kosong bila tanpa rekening).
  - `ReceiptConfig.transferAccount` tetap string; konten struk memakai
    `transferAccounts` (getter baru di `ReceiptConfig`).
- l10n: `storeSettingsTransferAccountHint` diperbarui ("satu rekening per
  baris, maks 3"); `storeSettingsTransferTooMany`,
  `storeSettingsTransferLineTooLong` baru.

## Pengujian

- Domain: normalisasi baris; `transferAccounts`; `fromJson` membatasi 3
  baris dan 100 karakter per baris; data satu baris lama; galat
  `tooMany`/`tooLong`.
- Data: simpan dua rekening lalu muat ulang (baris kosong dibuang);
  4 rekening dan baris 101 karakter ditolak.
- Flutter: VM pengaturan (galat, *Simpan* nonaktif); widget layar bayar
  (dua baris, tombol salin kedua menyalin rekening kedua); *Bagi beberapa
  metode*; struk nota piutang, pre-bill, kuitansi thermal dan A5 dengan
  dua rekening.
- Uji manual Xvfb: isi dua rekening di Pengaturan, bayar transfer di
  Kasir, salin rekening kedua.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Beberapa rekening transfer, salin per rekening | 1.5, 1.26 | Rilis v0.86.0 | Maks 3 rekening, satu per baris. |
| Catat rekening tujuan per pembayaran | — | Rilis v0.135.0 | [F1-05g](2026-11-20-f1-05g-rekening-tujuan-per-pembayaran-design.md): struk dan laporan per rekening. |
