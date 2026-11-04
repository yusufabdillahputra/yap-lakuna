# F1-20 · Tata letak mobile & Beranda

- **Fase:** 1
- **Status:** Rilis v0.26.0
- **Layar desain:** 1.10 *Beranda & menu · mobile*; kasir mobile 1.11 /
  1.11b (sudah ada sejak F1-04)
- **Acuan Storeku:** `2026-11-02-f1-20-mobile-beranda-design.md`

## Tujuan

Beranda langsung menunjukkan angka hari ini dan hal yang perlu perhatian,
dengan akses cepat ke modul, di HP maupun desktop.

## Yang sudah ada

- Breakpoint `LayoutSize` (< 600 mobile: navigasi bawah Beranda / Kasir /
  Riwayat / Produk / Lainnya; 600–1279 tablet: sidebar ringkas; ≥ 1280
  desktop: sidebar penuh). Lebih ketat dari Storeku (tablet sampai 1279).
- Kasir mobile (1.11) dengan keranjang sebagai lembar bawah (1.11b).

## Beranda (1.10)

Dari atas:

1. **Sapaan** "Selamat pagi/siang/sore/malam, <nama>" menurut jam cabang
   (04.00–10.59 pagi, 11.00–14.59 siang, 15.00–17.59 sore, lainnya malam),
   lalu "Toko · Cabang".
2. **Penjualan hari ini** (izin `reports:view`, memakai laporan F1-16
   periode *Hari ini*): penjualan bersih, jumlah transaksi, rata-rata per
   transaksi. Tanpa izin, kartu disembunyikan.
3. **Grid modul**: Kasir, Meja (usaha F&B / campuran), Riwayat, Produk, Stok, Pembelian,
   Pengeluaran, Pelanggan, Laporan; hanya yang diizinkan (aturan menu yang
   sama dengan sidebar). Mobile 4 kolom, lebih lebar 6 kolom; label boleh
   dua baris.
4. **Perlu perhatian** (baris dengan tautan *Lihat*), hanya baris yang
   relevan dan diizinkan:
   - "N produk di bawah stok minimum" (izin Stok) → Stok.
   - "N pembayaran QRIS menunggu konfirmasi" (izin `open_bills:manage`,
     usaha F&B / campuran, QRIS bagian split bill yang masih *menunggu*) →
     Meja.
   - Backup (izin `backup:manage`): "Backup terakhir hari ini / kemarin /
     N hari lalu" atau "Belum pernah backup"; ditandai merah bila lebih dari
     7 hari → Data & backup. Menggantikan kartu pengingat v0.25.0.
   - Bila tidak ada baris: "Semua beres".
5. **Info perangkat** (toko, staf bertugas, versi, ID perangkat, lokasi
   data) tetap ada di bawah, untuk bantuan teknis.

Galat salah satu sumber (termasuk galat tak terduga) hanya menyembunyikan
barisnya; setiap bagian tampil begitu datanya siap. Data dimuat ulang saat
Beranda dibuka dan saat aplikasi kembali aktif.

## Data

Hanya baca. Fungsi baru `pendingQrisCount(store, scope)` (pembayaran
`pending` pada bill terbuka cabang).

## Izin

Mengikuti modul yang ditautkan (lihat di atas).

## Pengujian

- Data: `pendingQrisCount` pada alur split bill QRIS menunggu.
- VM: sapaan per jam cabang; izin menyembunyikan kartu/baris; galat
  sumber tidak menggagalkan Beranda.
- Widget 1440 dan 360 px: kartu penjualan, grid modul sesuai izin, Perlu
  perhatian dan tautannya.
- Uji manual Xvfb.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Beranda 1.10 | Ringkasan + perlu perhatian | v0.26.0 | - |
| Navigasi bawah mobile | 1.10 | v0.1.0 | - |
| Kasir mobile | 1.11 / 1.11b | v0.6.0 | - |
| Struk mobile (bagikan) | - | Cetak / simpan | Bagikan struk sebagai gambar (lihat F1-06) |
