# F1-05 · Pembayaran: tunai, kartu, transfer, split, QRIS statis, kredit

- **Fase:** 1
- **Status:** Rilis v0.6.0 (tunai, kartu, transfer), ada gap
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
- Desktop/tablet: kolom *Uang diterima* langsung fokus, jadi nominal bisa
  diketik tanpa keypad.

## Aturan bisnis (`lakuna_domain`, `payment.dart`)

- Metode: `cash`, `card`, `transfer` (`qris_static` menyusul).
- Satu pembayaran per nota di v0.6.0. Tunai: `amount` = uang diterima,
  `change` = diterima − total ≥ 0. Non-tunai: `amount` = total, kembalian 0.
- `paid_amount` nota = total; `change_amount` = kembalian.
- Kembalian hanya dari tunai. Penjualan tunai bersih laci = diterima −
  kembalian.
- Nominal cepat: `quickCashAmounts(total)` = [total, ⌈total⌉ ke 10.000,
  ⌈total⌉ ke 50.000, ⌈total⌉ ke 100.000], unik, urut naik, maks 4.

## Data

- **`payments`**: `tenant_id`, `sale_id`, `method` (enum
  `PaymentMethod`), `amount`, `change_amount`, `reference?`, `status`
  (`paid`; `pending` untuk QRIS menyusul), `confirmed_by?`, `confirmed_at?`,
  `paid_at`.

## Izin

`sales:create`; `payments:confirm` untuk QRIS (menyusul).

## Kasus tepi

- Uang diterima kurang → tombol mati, petunjuk "Kurang Rp X".
- Keypad melebihi 15 digit diabaikan.
- Kembali dari layar bayar (← ) → keranjang utuh.
- Setelah berhasil, tombol kembali/← sama dengan *Transaksi baru*.

## Pengujian

- Domain: kembalian, uang kurang, nominal cepat (unik, batas), validasi
  referensi.
- Data: pembayaran tersimpan bersama nota (lihat F1-04).
- View model + widget: keypad, nominal cepat, kartu dengan approval.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| QRIS statis (stiker vertikal) | 1.6, 1.6m, 1.26b | Belum | v0.7.0: unggah stiker di Pengaturan, *Sudah Terbayar* / *Belum masuk* |
| Split payment | 1.5 panel kanan | Belum | Bersama QRIS |
| Kredit / piutang, DP, jatuh tempo | 1.5b | Belum | Setelah F1-13 Pelanggan |
| Opsi struk (cetak otomatis, PDF) | 1.5 panel Struk, 1.5c | Pratinjau teks saja | F1-06 |
| Pembulatan total | Pengaturan 1.26 | Belum | F1-18 |
| Rekening transfer di tombol | "BCA 123-456-7890" | Belum | Pengaturan metode bayar F1-18 |
