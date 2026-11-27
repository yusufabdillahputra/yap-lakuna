# F1-04j · Setujui ulang diskon rupiah bila pesanan berkurang

- **Fase:** 1
- **Status:** Rilis v0.163.0
- **Layar:** 1.7 Meja (panel bill), 1.5 Pembayaran, 1.7c Split bill,
  1.2b Persetujuan PIN manajer.
- **Acuan:** gap 26 di `GAP-FASE1.md` dan gap
  [F1-04e](2026-11-13-f1-04e-diskon-open-bill-design.md) *Persetujuan
  ulang bila dasar diskon rupiah mengecil*.

## Masalah

Diskon nota rupiah di open bill disetujui untuk isi bill saat itu (mis.
Rp 20.000 untuk pesanan Rp 200.000, setara 10%). Pesanan tetap bisa
dikurangi sesudahnya oleh siapa pun yang boleh mengubah bill. Potongannya
tetap Rp 20.000, jadi untuk pesanan Rp 40.000 diskonnya kini 50% padahal
manajer hanya menyetujui 10%. Diskon persen tidak bermasalah karena
potongannya ikut mengecil.

## Keputusan

- **Hanya open bill (Meja / take away).** Di Kasir retail, persetujuan PIN
  berlaku untuk seluruh keranjang sampai keranjang selesai (F1-04b); kasir
  sudah boleh mengubah nilai diskon sesudahnya, jadi menuntut persetujuan
  ulang di sana tidak menambah kendali.
- **Berlaku untuk semua staf.** Staf yang punya izin `sales:discount`
  cukup sekali ketuk *Setujui ulang* tanpa PIN; staf lain diminta PIN
  manajer seperti saat memberi diskon. Dengan begitu pesanan yang
  dikurangi pelayan selalu terlihat oleh orang yang berhak.
- Diskon tidak diubah otomatis (tidak dikonversi ke persen atau dipangkas
  proporsional) agar angka di bill tidak berubah diam-diam.

## Aturan

1. Saat diskon nota **rupiah** diterapkan (`setBillDiscount`), dasar saat
   itu (Σ total baris setelah diskon baris) disimpan di
   `sales.discount_base`. Diskon persen atau tanpa diskon menyimpan
   `null`.
2. Bill **perlu disetujui ulang** bila diskon nota rupiah > 0, dasar
   tersimpan ada, dan dasar sekarang **lebih kecil** dari dasar tersimpan.
   Bila pesanan ditambah lagi sampai dasar kembali ≥ dasar tersimpan,
   tanda itu hilang sendiri.
3. Selama perlu disetujui ulang, *Tutup & bayar* dan bayar bagian split
   ditolak di lapisan data dengan `DiscountNeedsReapproval`; tombol *Bayar*
   dan *Split* di panel nonaktif. Panel bill
   menampilkan pesan *Pesanan berkurang sejak diskon Rp 20.000 disetujui
   (dari Rp 200.000 menjadi Rp 40.000). Setujui ulang atau ubah diskon.*
   dan tombol **Setujui ulang** (`dining-discount-reapprove`). Staf
   tanpa izin diskon saat sakelar PIN manajer mati (tombol *Diskon* tidak
   tampil) melihat petunjuk *Minta manajer atau staf yang berizin diskon
   untuk menyetujui ulang.* (`dining-discount-reapprove-hint`) sebagai
   ganti tombol.
4. *Setujui ulang* menerapkan diskon yang sama lewat `setBillDiscount`
   (izin dan PIN sama dengan memberi diskon); dasar baru tersimpan dan
   penyetuju diperbarui. Mengubah atau menghapus diskon lewat dialog
   *Diskon* juga menyelesaikannya.
5. Bill lama tanpa `discount_base` (sebelum versi ini) tidak diperiksa.
6. Diskon yang menghabiskan total tetap ditolak `DiscountTooLarge`
   (F1-04e) dan diperiksa lebih dulu.
7. Gabung bill biasanya menambah dasar tujuan. Bila pelanggan sumber
   membawa grup harga yang menurunkan harga item tujuan, dasar bisa
   mengecil; gabung tetap tersimpan dan tanda setujui ulang muncul
   sesudahnya (diperiksa saat bayar).
8. Perubahan bill lain yang menurunkan dasar tidak ditolak: ganti
   pelanggan berharga grup lebih murah, kurangi qty, atau beri diskon
   baris. Bill tetap tersimpan (hanya `DiscountTooLarge` yang menolak),
   lalu tanda setujui ulang tampil. Akibatnya diskon baris yang baru
   disetujui PIN manajer membuat diskon nota rupiah perlu disetujui ulang
   sekali lagi; ini disengaja karena dasar diskon nota memang berubah.
9. Sinkronisasi (Fase 2): kolom `discount_base` nullable. Klien versi lama
   yang menulis baris penjualan tanpa kolom ini mengirim `null`, sehingga
   pemeriksaan mati untuk bill itu (gagal terbuka). Ini diterima; klien
   lama tidak punya tombol setujui ulang.

## Komponen

- Model: `Sale.discountBase` (`int?`, kolom `discount_base`), migrasi
  `dasar-diskon`.
- Domain: `discountReapprovalDue({amount, base, approvedBase})`.
- Data: `setBillDiscount` menulis `discountBase`; `_assertPayable`
  (bayar penuh dan bayar bagian) melempar `DiscountNeedsReapproval`
  setelah `_assertDiscountFits`; perubahan bill seperti ganti pelanggan
  hanya memakai `_assertDiscountFits`. `OpenBill.discountNeedsReapproval`
  dan `discountBase`.
- UI: `DiningViewModel.discountBlocksPay` dan `discountNeedsReapproval`;
  `_reapproveBillDiscount` di `dining_view.dart` (PIN bila perlu, lalu
  `setDiscount` dengan diskon yang sama); pesan, tombol, atau petunjuk di
  panel bill; pesan galat di Meja, Pembayaran, dan Split.

## Pengujian

- Domain: dasar sama/lebih besar/lebih kecil, persen, tanpa dasar.
- Data: rupiah menyimpan dasar, persen `null`; kurangi item → bayar dan
  bayar bagian ditolak; tambah item lagi → boleh; setujui ulang
  → boleh dan dasar baru; staf tanpa izin butuh penyetuju; ganti ke
  pelanggan grup reseller tetap tersimpan dan memunculkan tanda.
- Widget 1280/360: pesan dan tombol tampil, Bayar nonaktif, setujui ulang
  lalu Bayar aktif; staf tanpa izin diskon melihat petunjuk, bukan tombol.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Setujui ulang diskon nota rupiah bila pesanan berkurang | 1.7 | Rilis v0.163.0 | Open bill saja; Kasir retail memakai persetujuan per keranjang. |
| Diskon baris rupiah saat qty baris berkurang | — | Belum | Diskon baris (F1-04g) dibatasi total baris, tanpa persetujuan ulang. |
| Repositori palsu menolak bayar seperti repositori asli | — | Belum | `FakeCashierRepository.payBill` dan `FakeDiningRepository.payPart` belum melempar `DiscountTooLarge` / `DiscountNeedsReapproval`; penolakan diuji di `lakuna_data`. |
