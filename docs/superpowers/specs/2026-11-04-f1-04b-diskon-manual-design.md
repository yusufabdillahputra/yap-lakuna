# F1-04b · Diskon manual & persetujuan PIN manajer

- **Fase:** 1
- **Status:** Rilis v0.24.0
- **Layar desain:** 1.4b *Kasir: pelanggan, diskon, nota tersimpan* (panel
  *Diskon nota*), 1.2b *Persetujuan PIN manajer*, 1.26 sakelar *Diskon
  manual butuh PIN manajer*
- **Acuan Storeku:** `2026-11-02-f1-04-kasir-retail-design.md` (aturan
  diskon manual), `2026-11-02-f1-02-login-pin-design.md` (override manajer)
- **Menutup gap:** F1-04 "diskon manual", F1-18 "Diskon manual butuh PIN
  manajer"

## Tujuan

Kasir bisa memberi diskon manual per baris atau per nota, dalam persen atau
rupiah. Staf tanpa izin `sales:discount` meminta persetujuan PIN manajer di
tempat. Diskon tercatat di nota, struk, riwayat, dan laporan, dan nilai
retur ikut berkurang sebanding.

## Lingkup

Termasuk:

- **Diskon baris**: tekan lama (atau klik kanan) baris keranjang →
  dialog *Diskon baris*. Persen (0,01–100%) atau rupiah (≤ total baris
  setelah harga grosir). Baris menampilkan sub-baris "Diskon 10%" dan nilai
  potongannya; total baris sudah bersih.
- **Diskon nota**: tombol *Diskon* di blok total → dialog *Diskon nota*
  dengan pilihan % / Rp. Dihitung dari jumlah total baris (setelah diskon
  baris), sebelum pembulatan total.
- Dialog: pilihan % / Rp, isian nilai, pratinjau potongan, *Hapus diskon*
  (bila sudah ada), *Batal*, *Terapkan*.
- Blok total Kasir: baris *Diskon manual 5% · disetujui Rina* (atau tanpa
  "disetujui" bila staf sendiri berizin) bernilai negatif, sebelum
  *Pembulatan*.
- **Izin**:
  - Staf dengan `sales:discount` langsung menerapkan.
  - Staf tanpa izin dan sakelar *Diskon manual butuh PIN manajer* hidup
    (bawaan): setelah *Terapkan*, dialog *Persetujuan manajer* (sama dengan
    void) meminta staf lain yang punya `sales:discount` + PIN-nya.
  - Staf tanpa izin dan sakelar mati: menu diskon tidak muncul.
  - Satu penyetuju berlaku untuk semua diskon di keranjang itu sampai nota
    tersimpan, keranjang dikosongkan, atau ganti kasir. Persetujuan
    disimpan di `SessionRepository` dengan masa berlaku 30 menit (void
    tetap 2 menit).
  - Lapisan data menolak diskon dari staf tanpa izin kecuali
    `discountApproverId` adalah staf aktif cabang dengan `sales:discount`
    dan sakelar hidup.
- Sakelar **Diskon manual butuh PIN manajer** di *Penjualan & stok*
  (`SalesRules.discountNeedsPin`, bawaan hidup).
- Struk: di bawah baris item "Diskon 10%  -1.000"; di blok total
  "Diskon 5%" / "Diskon" bernilai negatif. Subtotal di struk tampil bila ada
  diskon nota.
- Riwayat (detail nota) memakai struk yang sama.
- Laporan: *Diskon* di laba rugi = diskon grosir + diskon manual
  (baris + nota). Penjualan per produk memakai total baris bersih
  (diskon baris sudah dipotong; diskon nota tidak dibagi ke produk, sama
  seperti pembulatan).
- Retur: nilai retur per baris dibagi dari total nota (mekanisme `shares`
  yang sudah ada), jadi diskon nota ikut terbagi.

Tidak termasuk (gap):

- Diskon di open bill F&B dan split bill (bill dihitung ulang di
  `open_bill.dart`; ditunda).
- Batas diskon maksimal per role.
- Nota tersimpan (parkir) dan pilih pelanggan di kepala Kasir (1.4b),
  versi berikutnya.

## Aturan hitung

- `ManualDiscount { kind: percent | amount, value }`. Persen dalam basis
  poin (1–10000). Rupiah > 0.
- Potongan persen = dasar × bp ÷ 10000, dibulatkan setengah ke atas.
  Potongan rupiah tidak boleh melebihi dasar (`DiscountTooLarge`).
- Baris: dasar = total baris setelah harga grosir. `sale_items.line_total`
  = dasar − potongan; `discount_amount` menyimpan potongan, `discount_bp`
  menyimpan persen (0 bila rupiah).
- Nota: dasar = Σ `line_total`. `sales.discount_amount`, `discount_bp`.
- `sales.line_discount_amount` = Σ potongan baris (untuk laporan).
- Total = Σ `line_total` − diskon nota, lalu pembulatan total (F1-18).
  Total nota setelah semua diskon **dan setelah pembulatan** harus > 0
  (`DiscountTooLarge`); diskon baris 100% boleh selama baris lain masih
  bernilai. Dialog diskon baris dan nota memeriksa aturan yang sama.
- Bila jumlah baris berkurang setelah diskon rupiah diberikan, potongannya
  dipangkas ke dasar baru (terlihat di sub-baris). Bila akibatnya total
  nota habis, tombol *Bayar* dimatikan dan blok total menampilkan pesan
  sampai diskon diubah.
- Penyetuju hanya dikirim bila keranjang memang berdiskon. Bila checkout
  ditolak karena persetujuan kedaluwarsa, penyetuju dihapus dari keranjang
  sehingga *Terapkan* berikutnya meminta PIN lagi.
- `ReportSale.manualDiscount` = diskon baris + nota;
  `netContribution` = subtotal − diskon grosir − diskon manual + service −
  PB1 termasuk + pembulatan.

## Data

Kolom baru (migrasi `manual-discount`):

- `sale_items.discount_amount int default 0`, `sale_items.discount_bp int
  default 0`.
- `sales.discount_amount int default 0`, `sales.discount_bp int default 0`,
  `sales.line_discount_amount int default 0`, `sales.discount_approved_by
  uuid?`.

## Pengujian

- Domain: potongan persen/rupiah, pembulatan setengah, batas, total.
- Data: checkout dengan diskon baris + nota + pembulatan; izin (berizin,
  penyetuju sah, penyetuju tanpa izin, sakelar mati); retur dengan diskon
  nota; laporan laba rugi.
- VM: terapkan/hapus diskon, total, butuh persetujuan, penyetuju dihapus
  saat keranjang dikosongkan.
- Widget: dialog diskon baris & nota di 1440 dan 360 px, alur persetujuan.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Diskon baris & nota di Kasir retail | 1.4b | v0.24.0 | - |
| Persetujuan PIN untuk diskon | 1.2b | v0.24.0 | - |
| Sakelar *Diskon manual butuh PIN manajer* | 1.26 | v0.24.0 | - |
| Diskon di open bill F&B / split bill | - | Belum | Tambahkan di `open_bill.dart` bila diminta |
| Batas diskon per role | - | Belum | Fase 3 (promo) |
| Pilih pelanggan & nota tersimpan di Kasir | 1.4b | Rilis v0.29.0 | [F1-04d](2026-11-04-f1-04d-pelanggan-nota-tersimpan-design.md) |
