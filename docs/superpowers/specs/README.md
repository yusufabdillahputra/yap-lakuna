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
  setiap layar (Forui preset `conhcc`, 70 artboard). Nomor layar (mis. 1.4
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
| [F0 · Fondasi & arsitektur](2026-11-03-f0-fondasi-arsitektur-design.md) | Gaya visual, tema gelap | Rilis v0.1.0, ada gap |
| Merek · logo, ikon aplikasi & placeholder DiceBear | Logo Etalase diwarnai Sky | Belum |

### Fase 1 · Gratis, offline-first

Urutan pengerjaan sama dengan Storeku.

| # | Modul | Layar desain | Status |
| --- | --- | --- | --- |
| 1 | Onboarding & setup toko | 1.1 | Belum |
| 2 | Login PIN & ganti kasir | 1.2 | Belum |
| 3 | Sesi kasir | 1.3 | Belum |
| 4 | Kasir retail | 1.4, 1.11 | Belum |
| 5 | Pembayaran: tunai, split, QRIS statis, kredit | 1.5, 1.6 | Belum |
| 6 | Struk & printer | 1.12 | Belum |
| 7 | Produk, varian, satuan, grosir | 1.15, 1.16 | Belum |
| 8 | Stok: penyesuaian, kartu stok, stok minimum | 1.18 | Belum |
| 9 | Master data | 1.17 | Belum |
| 10 | Meja F&B (denah `vyuh_node_flow`), open bill, modifier, split bill | 1.7, 1.7b–d, 1.8, 1.9 | Belum |
| 11 | Riwayat transaksi, void & retur | 1.14 | Belum |
| 12 | Pembelian & retur beli | 1.19 | Belum |
| 13 | Pelanggan & piutang | 1.20 | Belum |
| 14 | Supplier & hutang | 1.21 | Belum |
| 15 | Pengeluaran | 1.22 | Belum |
| 16 | Laporan & laba rugi | 1.23, 1.24 | Belum |
| 17 | Pengguna & role (RBAC) | 1.25 | Belum |
| 18 | Pengaturan toko | 1.26 | Sebagian (v0.1.0: tema & bahasa) |
| 19 | Data & backup | 1.13 | Belum |
| 20 | Tata letak mobile & beranda | 1.10, 1.11 | Sebagian (v0.1.0: shell responsif) |
| 21 | Panduan pengguna (ID + EN, gambar WebP) | 1.27 | Belum |
| 22 | Rilis ke store & distribusi | - | Sebagian (v0.1.0: installer otomatis) |

### Fase 2 · Hosting & sync (Serverpod)

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
