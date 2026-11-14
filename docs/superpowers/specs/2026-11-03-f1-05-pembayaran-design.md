# F1-05 · Pembayaran: tunai, kartu, transfer, split, QRIS statis, kredit

- **Fase:** 1
- **Status:** Rilis v0.6.0 (tunai, kartu, transfer), v0.7.0 (QRIS statis,
  split payment), ada gap
- **Layar desain:** 1.5 *Bayar tunai & split payment*, 1.5b *Kredit /
  piutang & no. approval kartu*, 1.5c *Pembayaran berhasil, cetak &
  bagikan*, 1.6 / 1.6m *Bayar QRIS statis*, versi gelapnya. Kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525)
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-05-pembayaran-design.md`

## Tujuan

Menyelesaikan penjualan dari kasir (F1-04) dengan metode yang dipakai UMKM:
tunai dengan kembalian, kartu (EDC terpisah, no. approval opsional),
transfer bank; menyusul QRIS statis dengan konfirmasi manual, split, dan
kredit (piutang).

## Lingkup v0.6.0

- Tahap bayar di dalam rute `/kasir` (bukan rute terpisah) dari tombol
  *Bayar* (keranjang tidak kosong). Keranjang tetap di view model kasir,
  jadi tombol ← kembali ke pesanan tanpa kehilangan isi.
- Kolom kiri (1.5b): kartu **Total** besar + jumlah item, lalu pilihan
  metode *Tunai* (hitung kembalian), *Kartu debit / kredit* (EDC
  terpisah), *Transfer bank*.
- **Tunai** (1.5): *Uang diterima* besar berawalan Rp, nominal cepat (*Uang
  pas* lalu pecahan Rp 10.000 / 50.000 / 100.000 terdekat di atas total,
  tanpa duplikat), keypad 1–9, 000, 0, ⌫, kotak **Kembalian**. Selesaikan
  hanya bila diterima ≥ total.
- **Kartu**: isian *No. approval kartu (opsional)*, maks 40 karakter,
  jumlah = total.
- **Transfer**: isian *Referensi (opsional)*, jumlah = total.
- Tombol **Selesaikan pembayaran**.
- **Berhasil (1.5c)**: ikon centang, "Pembayaran berhasil", "<Metode> Rp X ·
  HH.mm · <kasir>", nomor nota di bilah atas, **Kembalian** besar (tunai),
  peringatan **Stok jadi minus** per varian, pratinjau struk teks (nama
  toko, cabang, no, tanggal, kasir, item "2 x 70.000", total, bayar,
  kembali), tombol **Transaksi baru**. Cetak/PDF menyusul F1-06.
- Ponsel: kolom metode di atas, panel bayar di bawah, satu kolom. Kotak
  **Kembalian** menempel di atas tombol selesai agar selalu terlihat.
- Desktop (lebar ≥ 600 px): kolom *Uang diterima* langsung fokus, jadi
  nominal bisa diketik tanpa keypad. Tablet/ponsel memakai keypad di layar
  (tanpa keyboard virtual yang menutupinya).

## Lingkup v0.7.0: QRIS statis dan split payment

- Pilihan metode bertambah: **QRIS statis** ("Konfirmasi manual") bila
  QRIS statis aktif dan gambarnya ada di Pengaturan cabang (F1-18, 1.26b),
  dan **Bagi beberapa metode** (split).
- **Panel QRIS (1.6 tablet/desktop, 1.6m ponsel):** gambar stiker QRIS
  utuh dengan rasio asli (`BoxFit.contain`, tanpa dipotong), lencana
  *Menunggu konfirmasi kasir*, "Scan QRIS, ketik nominal persis" dan
  nominal total besar, empat langkah (tunjukkan QR, pelanggan scan dan
  ketik nominal, cek notifikasi/mutasi masuk, tekan *Sudah Terbayar*),
  peringatan "Jangan konfirmasi dari tangkapan layar pelanggan saja", nama
  merchant + NMID + "Dana masuk ke" bila diisi, tombol *Perbesar gambar
  QRIS* (dialog layar penuh, bisa di-zoom). Ponsel: ketuk gambar untuk
  layar penuh.
- Tombol **Belum masuk** kembali ke pilihan *Tunai*, tidak menyimpan apa
  pun. Tombol **Sudah Terbayar** menyimpan nota dengan pembayaran QRIS
  `paid` + `confirmed_by` (staf bertugas) + `confirmed_at`. Ponsel: kedua
  tombol di bilah bawah.
- *Sudah Terbayar* butuh izin `payments:confirm` (role Kasir bawaan
  memilikinya). Tanpa izin tombol mati dengan petunjuk; repositori juga
  menolak (`NotPermitted`).
- **Split (panel 1.5 kanan):** daftar bagian (metode, nominal, lencana
  *Diterima* / *Menunggu*, hapus), form tambah: pilihan metode
  Tunai/Kartu/Transfer/QRIS + nominal (terisi otomatis dengan sisa) +
  *Tambah metode*. Baris **Sisa** dan **Kembalian** (bila tunai lebih).
  Bagian QRIS masuk sebagai *Menunggu*; ketuk *Konfirmasi* membuka dialog
  QRIS dengan nominal bagian itu, *Sudah Terbayar* mengubahnya jadi
  *Diterima*, *Belum masuk* menghapus bagian itu. *Selesaikan pembayaran*
  aktif bila sisa nol dan tidak ada bagian menunggu.
- Struk dan layar berhasil menampilkan setiap pembayaran ("Tunai Rp X",
  "QRIS statis Rp Y") dan kembalian. Judul ringkas: metode tunggal atau
  "Split · N metode".
- Tidak ada pembayaran `pending` yang disimpan di v0.7.0: nota hanya
  tersimpan setelah semua bagian lunas/terkonfirmasi.

## Aturan bisnis (`lakuna_domain`, `payment.dart`)

- Metode: `cash`, `card`, `transfer`, `qrisStatic` (kredit menyusul).
- Pelunasan `settleTender(total, parts)`: setiap bagian punya nominal dan
  tanda tunai. Galat berurutan: `empty` (tidak ada bagian), `nonPositive`
  (ada nominal ≤ 0; kecuali total 0 dengan satu bagian 0, yaitu barang
  gratis), `multipleCash` (lebih dari satu bagian tunai),
  `nonCashOver` (jumlah non-tunai > total, kembalian hanya dari tunai),
  `short` (jumlah < total). Hasil: `paid` (jumlah), `remaining`
  (sisa ≥ 0), `change` (kembalian ≥ 0, hanya dari bagian tunai).
- Pembayaran tunggal = split dengan satu bagian. Tunai: `amount` = uang
  diterima. Non-tunai tunggal tanpa nominal: `amount` = total.
- QRIS statis wajib dikonfirmasi (`confirmed`); tanpa itu
  `SalePaymentUnconfirmed`. QRIS ditolak (`SalePaymentUnsupported`) bila
  QRIS statis tidak aktif di cabang ini.
- `paid_amount` nota = total; `change_amount` = kembalian.
- Kembalian hanya dari tunai. Penjualan tunai bersih laci = diterima −
  kembalian.
- Nominal cepat: `quickCashAmounts(total)` = [total, ⌈total⌉ ke 10.000,
  ⌈total⌉ ke 50.000, ⌈total⌉ ke 100.000], unik, urut naik, maks 4.

## Data

- **`payments`**: `tenant_id`, `sale_id`, `method` (enum
  `PaymentMethod`), `amount`, `change_amount`, `reference?`, `status`
  (`paid`; `pending` disiapkan untuk kredit/QRIS tertunda), `confirmed_by?`,
  `confirmed_at?`, `paid_at`. Satu nota bisa punya beberapa baris (split),
  urut sesuai input; `change_amount` hanya di baris tunai.
- `checkoutSale(..., payments: [...])` menerima daftar pembayaran;
  `CheckoutResult.payments` urut sesuai input.

## Izin

`sales:create`; `payments:confirm` untuk *Sudah Terbayar* QRIS (dicek di UI
dan `LocalCashierRepository`).

## Kasus tepi

- Uang diterima kurang → tombol mati, petunjuk "Kurang Rp X".
- Keypad melebihi 15 digit diabaikan.
- Kembali dari layar bayar (← ) → keranjang utuh.
- Setelah berhasil, tombol kembali/← sama dengan *Transaksi baru*.

## Pengujian

- Domain: kembalian, uang kurang, nominal cepat (unik, batas), validasi
  referensi, `settleTender` (semua galat, kembalian dari tunai).
- Data: split tersimpan beberapa baris, QRIS tanpa konfirmasi ditolak, QRIS
  saat nonaktif ditolak, `confirmed_by/at` terisi.
- Data: pembayaran tersimpan bersama nota (lihat F1-04).
- View model + widget: keypad, nominal cepat, kartu dengan approval.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| QRIS statis (stiker vertikal) | 1.6, 1.6m, 1.26b | Rilis v0.7.0 | - |
| Split payment | 1.5 panel kanan | Rilis v0.7.0 | - |
| Referensi kartu/transfer di bagian split | 1.5 | Rilis v0.64.0 | [F1-05b](2026-11-14-f1-05b-referensi-split-struk-design.md); referensi juga tercetak di struk. |
| PIN manajer untuk *Sudah Terbayar* | 1.26b sakelar | Belum (izin `payments:confirm` saja) | Bersama persetujuan PIN manajer (void/diskon) |
| QRIS dinamis / cek mutasi otomatis | - | Belum | Fase 3 |
| Kredit / piutang, DP, jatuh tempo | 1.5b | Belum | Setelah F1-13 Pelanggan |
| Opsi struk (cetak otomatis, PDF) | 1.5 panel Struk, 1.5c | Pratinjau teks saja | F1-06 |
| Pembulatan total | Pengaturan 1.26 | Belum | F1-18 |
| Rekening transfer di tombol | "BCA 123-456-7890" | Rilis v0.74.0 ([F1-05c](2026-11-14-f1-05c-rekening-transfer-design.md)) | Teks bebas di *Penjualan & stok*; kotak *Transfer ke* + tombol Salin. |
| Scan barcode saat di layar bayar (desktop) | — | Masuk ke *Uang diterima* | Batasi nominal / abaikan input sangat cepat bersama F1-06 |
