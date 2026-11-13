# Spesifikasi Lakuna (Superpowers)

Folder ini berisi **spec** (dokumen desain) Lakuna untuk alur kerja
[Superpowers](https://github.com/obra/superpowers): *brainstorm → spec →
plan → TDD → review → verifikasi*. Setiap spec menjelaskan **apa** yang
dibangun dan **kenapa**. Rencana langkah demi langkah (**bagaimana**) ada di
[`../plans/`](../plans/), satu rencana per spec saat modul mulai dikerjakan.

## Acuan

- **Spec Storeku** (`yusufabdillahputra/storeku`,
  `docs/superpowers/specs/`) adalah acuan fitur dan aturan bisnis untuk
  setiap modul. Spec Lakuna untuk sebuah modul ditulis saat modul itu mulai
  dikerjakan, menyalin aturan dari spec Storeku dan mencatat perbedaan
  khusus Flutter/Serverpod.
- **Kanvas desain** [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525) adalah acuan visual
  setiap layar (Forui preset `conhcc`, 89 artboard). Nomor layar (mis. 1.4
  Kasir, 1.26b Pengaturan QRIS) dipakai di kode dan CHANGELOG. Mulai dari
  halaman fondasinya: *Gaya visual Lakuna*, *Peta komponen Forui*, *Pola
  keadaan & responsif*, dan *Peta fitur hasil audit* (daftar periksa fitur →
  layar → detail wajib → kunci izin). Spec desain dan audit:
  `2026-11-03-ui-desain-lakuna-forui-design.md`,
  `2026-11-03-ui-audit-fitur-lakuna.md`.

## Aturan yang berlaku untuk semua spec

- Konvensi umum (struktur repo, model Serverpod, sync, RBAC, i18n, tema,
  aset offline, CI) ada di
  [F0 · Fondasi & arsitektur](2026-11-03-f0-fondasi-arsitektur-design.md).
  Spec modul tidak mengulanginya.
- Kode yang sudah rilis adalah sumber kebenaran untuk hal yang sudah
  dibangun. Perbedaan dengan desain dicatat sebagai *gap* di tabel
  **Status & gap** setiap spec.
- Setiap modul: tes dulu (TDD) di `lakuna_domain` / `lakuna_data` /
  view model, layar diuji manual di aplikasi desktop, review kode sebelum
  merge, CHANGELOG berbahasa Indonesia, versi SemVer naik.

## Status per fase

Legenda: **Rilis** (sudah di `main` dan dirilis), **Sebagian**,
**Berjalan**, **Belum**.

### Fase 0 · Fondasi

| Spec | Layar desain | Status |
| --- | --- | --- |
| [F0 · Fondasi & arsitektur](2026-11-03-f0-fondasi-arsitektur-design.md) | Gaya visual, tema gelap | Rilis v0.1.0 (kontras v0.1.1), ada gap |
| Merek · logo, ikon aplikasi & placeholder DiceBear | Logo Etalase diwarnai Sky | Ikon aplikasi v0.28.0 |

### Fase 1 · Gratis, offline-first

Urutan pengerjaan sama dengan Storeku.

| # | Modul | Layar desain | Status |
| --- | --- | --- | --- |
| 1 | [Onboarding & setup toko](2026-11-03-f1-01-onboarding-design.md) | 1.1, 1.1b | Rilis v0.2.0, ulangi kata sandi v0.3.0 (produk pertama di F1-07) |
| 2 | [Login PIN & ganti kasir](2026-11-03-f1-02-login-pin-design.md) | 1.2 | Rilis v0.3.0 (persetujuan PIN manajer menyusul bersama void/diskon) |
| 3 | [Sesi kasir](2026-11-03-f1-03-sesi-kasir-design.md) | 1.3, 1.3b | Rilis v0.4.0, angka penjualan v0.6.0; v0.38.0: cetak rekap sesi ([F1-03b](2026-11-13-f1-03b-cetak-rekap-sesi-design.md)) (shift menyusul) |
| 4 | [Kasir retail](2026-11-03-f1-04-kasir-retail-design.md) | 1.4, 1.11 | Rilis v0.6.0; v0.24.0: diskon manual baris & nota + PIN manajer ([F1-04b](2026-11-04-f1-04b-diskon-manual-design.md)); v0.28.1: keranjang tetap saat pindah menu ([F1-04c](2026-11-04-f1-04c-keranjang-tetap-design.md)); v0.29.0: pelanggan & nota tersimpan ([F1-04d](2026-11-04-f1-04d-pelanggan-nota-tersimpan-design.md)); v0.32.0: diskon nota di open bill F&B ([F1-04e](2026-11-13-f1-04e-diskon-open-bill-design.md)); v0.33.0: pelanggan baru dari Kasir ([F1-04f](2026-11-13-f1-04f-pelanggan-baru-kasir-design.md)) |
| 5 | [Pembayaran: tunai, split, QRIS statis, kredit](2026-11-03-f1-05-pembayaran-design.md) | 1.5, 1.6 | Rilis v0.6.0: tunai, kartu, transfer; v0.7.0: QRIS statis, split (kredit retail v0.17.0) |
| 6 | [Struk & printer](2026-11-03-f1-06-struk-printer-design.md) | 1.12, 1.26 | Rilis v0.8.0: struk layar, ESC/POS Bluetooth/LAN, dialog cetak, PDF; logo v0.39.0 (BLE menyusul) |
| 7 | [Produk, varian, satuan, grosir](2026-11-03-f1-07-produk-design.md) | 1.15, 1.16 | Rilis v0.5.0, inti katalog dibangun sebelum kasir; v0.31.0: import Excel/CSV ([F1-07b](2026-11-04-f1-07b-import-produk-design.md)); v0.34.0: grosir per grup pelanggan ([F1-07c](2026-11-13-f1-07c-grosir-grup-pelanggan-design.md)); v0.35.0: arsip produk ([F1-07d](2026-11-13-f1-07d-arsip-produk-design.md)); v0.36.0: cetak label barcode ([F1-07e](2026-11-13-f1-07e-label-barcode-design.md)); v0.37.0: foto produk ([F1-07f](2026-11-13-f1-07f-foto-produk-design.md)) |
| 8 | [Stok: penyesuaian, kartu stok, stok minimum](2026-11-03-f1-08-stok-design.md) | 1.18 | Rilis v0.9.0 (transfer antarlokasi, opname terjadwal menyusul) |
| 9 | [Master data](2026-11-03-f1-09-master-data-design.md) | 1.17 | Rilis v0.10.0: kategori, satuan, lokasi (baca), metode bayar (tautan); alasan dan jenis pengeluaran menyusul modulnya; grup pelanggan v0.17.0 |
| 10 | Meja F&B (denah `vyuh_node_flow`), open bill, modifier, split bill | 1.7, 1.7b–d, 1.8, 1.9 | Rilis: grid, open bill, take away, pajak & service v0.11.0; modifier v0.12.0; split bill v0.13.0; denah v0.14.0; gabung meja v0.40.0; printer dapur v0.41.0; pelanggan & harga grup di bill v0.42.0; menu tanpa tiket dapur & catatan v0.43.0 |
| 11 | [Riwayat transaksi, void & retur](2026-11-03-f1-11-riwayat-void-retur-design.md) | 1.14 | Rilis v0.15.0: daftar + filter, retur sebagian/penuh, void dengan persetujuan PIN manajer, cetak ulang, ekspor Excel (retur ke piutang v0.17.0) |
| 12 | [Pembelian & retur beli](2026-11-03-f1-12-pembelian-design.md) | 1.19, 1.19b | Rilis v0.16.0: draf, terima, landed cost, HPP, hutang + jatuh tempo, kas laci, retur beli, saran harga jual (bayar hutang v0.18.0) |
| 13 | [Pelanggan & piutang](2026-11-03-f1-13-pelanggan-piutang-design.md) | 1.20, 1.20b, 1.5b | Rilis v0.17.0: pelanggan + grup, limit & tempo, kredit di Kasir (DP), piutang per nota, terima pembayaran (alokasi otomatis/manual), kuitansi A5/thermal, import CSV/XLSX, retur potong piutang; v0.30.0: kredit *Tutup & bayar* open bill F&B ([F1-13b](2026-11-04-f1-13b-kredit-open-bill-design.md); kredit bagian split menyusul); v0.44.0: batal pembayaran piutang & hutang ([F1-13c](2026-11-13-f1-13c-batal-pembayaran-utang-piutang-design.md)) |
| 14 | [Supplier & hutang](2026-11-04-f1-14-supplier-hutang-design.md) | 1.21 | Rilis v0.18.0: master supplier + tempo standar, hutang per pembelian, bayar hutang (alokasi jatuh tempo terdekat / manual, kas toko/laci/bank, no. & foto bukti), tombol Bayar hutang di detail pembelian ; batal bayar hutang v0.44.0; import supplier CSV/XLSX v0.45.0 (F1-14b) |
| 15 | [Pengeluaran](2026-11-04-f1-15-pengeluaran-design.md) | 1.22 | Rilis v0.19.0: jenis pengeluaran (master data), catat kas toko/laci/bank dengan foto nota, batal dengan alasan (laci dibalik di sesi terbuka), per jenis + periode, ekspor Excel, sakelar *Catat juga sebagai pengeluaran* di kas laci (berulang menyusul Fase 3) |
| 16 | [Laporan & laba rugi](2026-11-04-f1-16-laporan-design.md) | 1.23, 1.24 | Rilis v0.20.0 + v0.21.0: ringkasan (penjualan, laba kotor, rata-rata, piutang jatuh tempo, metode bayar, terlaris), penjualan per produk/kasir/kategori, produk terlaris, laba rugi + perbandingan periode, unduh PDF/Excel, izin `reports:view_profit`; v0.21.0: tab stok (pergerakan + nilai), kas & sesi, piutang & hutang, retur |
| 17 | [Pengguna & role (RBAC)](2026-11-04-f1-17-pengguna-role-design.md) | 1.25, 1.25b | Rilis v0.22.0: tambah/ubah staf PIN + ulangi, reset & buka kunci PIN, matriks izin per role, role custom, Akun saya (ganti PIN/kata sandi + ulangi) |
| 18 | [Pengaturan toko](2026-11-03-f1-18-pengaturan-design.md) | 1.26, 1.26b | Sebagian (v0.1.0: tema & bahasa; v0.7.0: QRIS statis; v0.8.0: struk & printer; v0.23.0: profil toko, cabang, penjualan & stok, PB1 termasuk, ukuran tampilan; v0.24.0: sakelar diskon butuh PIN; v0.25.0: Data & backup; v0.29.1: orientasi EXIF foto) |
| 19 | [Data & backup](2026-11-04-f1-19-data-backup-design.md) | 1.13, 1.10 | Rilis v0.25.0 (backup .zip, pulihkan + muat ulang, pengingat Beranda, layar gagal mulai); enkripsi & pulihkan dari onboarding menyusul |
| 20 | [Tata letak mobile & beranda](2026-11-04-f1-20-mobile-beranda-design.md) | 1.10, 1.11 | Rilis v0.26.0 (Beranda 1.10; navigasi bawah sejak v0.1.0, kasir mobile sejak v0.6.0); bagikan struk menyusul |
| 21 | [Panduan pengguna](2026-11-04-f1-21-panduan-design.md) | 1.27 | Rilis v0.27.0 (27 artikel ID + EN, cari, 38 gambar WebP); tautan kontekstual dari layar lain menyusul |
| 22 | [Rilis ke store & distribusi](2026-11-04-f1-22-rilis-store-design.md) | 1.26 | Rilis v0.28.0 (ikon aplikasi, Tentang Lakuna, SHA256SUMS, dokumen + aset store); unggah ke store menunggu akun pemilik |

### Fase 2 · Hosting & sync (Serverpod di VPS sendiri)

| # | Modul | Status |
| --- | --- | --- |
| 1 | Server sync & aktivasi hosting | Belum |
| 2 | Versi web: login & dashboard semua cabang | Belum |
| 3 | Status sync & tinjau konflik | Belum |
| 4 | Cabang & perangkat | Belum |
| 5 | Transfer stok antar cabang | Belum |

### Fase 3 · Fitur ala majoo

Stock opname, QRIS dinamis & e-wallet, struk via WhatsApp, promo, membership,
karyawan/kasbon/gaji, pengiriman. Semua **Belum**.

## Format spec modul

1. **Ringkasan**: fase, status, layar desain, acuan spec Storeku.
2. **Tujuan**.
3. **Lingkup**: termasuk / tidak termasuk.
4. **Desain UI (baseline)**.
5. **Aturan bisnis** di `lakuna_domain`.
6. **Data**: model `.spy.yaml` dan migrasi.
7. **Izin** `resource:action`.
8. **Kasus tepi**.
9. **Pengujian** (TDD).
10. **Status & gap**.
11. **Kriteria selesai**.

Nama berkas: `YYYY-MM-DD-<kode>-<topik>-design.md` (mis.
`2026-11-03-f1-01-onboarding-design.md`).
