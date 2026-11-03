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
| Merek · logo, ikon aplikasi & placeholder DiceBear | Logo Etalase diwarnai Sky | Belum |

### Fase 1 · Gratis, offline-first

Urutan pengerjaan sama dengan Storeku.

| # | Modul | Layar desain | Status |
| --- | --- | --- | --- |
| 1 | [Onboarding & setup toko](2026-11-03-f1-01-onboarding-design.md) | 1.1, 1.1b | Rilis v0.2.0, ulangi kata sandi v0.3.0 (produk pertama di F1-07) |
| 2 | [Login PIN & ganti kasir](2026-11-03-f1-02-login-pin-design.md) | 1.2 | Rilis v0.3.0 (persetujuan PIN manajer menyusul bersama void/diskon) |
| 3 | [Sesi kasir](2026-11-03-f1-03-sesi-kasir-design.md) | 1.3, 1.3b | Rilis v0.4.0, angka penjualan v0.6.0 (shift dan cetak rekap menyusul) |
| 4 | [Kasir retail](2026-11-03-f1-04-kasir-retail-design.md) | 1.4, 1.11 | Rilis v0.6.0 (pelanggan, diskon, nota tersimpan 1.4b menyusul) |
| 5 | [Pembayaran: tunai, split, QRIS statis, kredit](2026-11-03-f1-05-pembayaran-design.md) | 1.5, 1.6 | Rilis v0.6.0: tunai, kartu, transfer; v0.7.0: QRIS statis, split (kredit menyusul bersama F1-13) |
| 6 | [Struk & printer](2026-11-03-f1-06-struk-printer-design.md) | 1.12, 1.26 | Rilis v0.8.0: struk layar, ESC/POS Bluetooth/LAN, dialog cetak, PDF (logo, cetak ulang, BLE menyusul) |
| 7 | [Produk, varian, satuan, grosir](2026-11-03-f1-07-produk-design.md) | 1.15, 1.16 | Rilis v0.5.0, inti katalog dibangun sebelum kasir (foto, import, label barcode, arsip menyusul) |
| 8 | [Stok: penyesuaian, kartu stok, stok minimum](2026-11-03-f1-08-stok-design.md) | 1.18 | Rilis v0.9.0 (transfer antarlokasi, opname terjadwal menyusul) |
| 9 | [Master data](2026-11-03-f1-09-master-data-design.md) | 1.17 | Rilis v0.10.0: kategori, satuan, lokasi (baca), metode bayar (tautan); alasan, jenis pengeluaran, grup pelanggan, meja/modifier menyusul modulnya |
| 10 | Meja F&B (denah `vyuh_node_flow`), open bill, modifier, split bill | 1.7, 1.7b–d, 1.8, 1.9 | Sebagian: grid, open bill, take away, pajak & service v0.11.0 |
| 11 | Riwayat transaksi, void & retur | 1.14 | Belum |
| 12 | Pembelian & retur beli | 1.19 | Belum |
| 13 | Pelanggan & piutang | 1.20 | Belum |
| 14 | Supplier & hutang | 1.21 | Belum |
| 15 | Pengeluaran | 1.22 | Belum |
| 16 | Laporan & laba rugi | 1.23, 1.24 | Belum |
| 17 | Pengguna & role (RBAC) | 1.25 | Belum |
| 18 | [Pengaturan toko](2026-11-03-f1-18-pengaturan-design.md) | 1.26, 1.26b | Sebagian (v0.1.0: tema & bahasa; v0.7.0: QRIS statis; v0.8.0: struk & printer) |
| 19 | Data & backup | 1.13 | Belum |
| 20 | Tata letak mobile & beranda | 1.10, 1.11 | Sebagian (v0.1.0: shell responsif) |
| 21 | Panduan pengguna (ID + EN, gambar WebP) | 1.27 | Belum |
| 22 | Rilis ke store & distribusi | - | Sebagian (v0.1.0: installer otomatis) |

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
