# CLAUDE.md — aturan proyek Lakuna

Lakuna adalah aplikasi kasir (POS) offline-first untuk UMKM Indonesia, mode
Retail dan F&B, dibangun dengan Flutter + Serverpod. Ide dan rancangannya
sama dengan Storeku (versi Dioxus, pengembangannya ditunda). Produk acuan:
majoo.id. Pemilik proyek: Yusuf Abdillah Putra. **Balas pemilik dalam Bahasa
Indonesia.**

Baca file ini dan `AGENTS.md` (alat Serverpod/MCP) di awal setiap sesi.
Aturan di sini berlaku untuk semua pekerjaan di repo ini dan menang bila
berbeda dengan `AGENTS.md`.

## 1. Alur kerja: Superpowers (wajib)

1. **Brainstorming** — `superpowers:brainstorming`. Spec Storeku dan kanvas
   desain sudah menjawab sebagian besar pertanyaan; jangan menunggu pemilik
   bila jawabannya ada di sana.
2. **Spec** — `docs/superpowers/specs/` (indeks dan urutan modul di
   `README.md` folder itu). Konvensi umum di spec F0. Modul baru:
   `docs/superpowers/specs/YYYY-MM-DD-<kode>-<topik>-design.md`, menyalin
   aturan dari spec Storeku modul yang sama dan mencatat perbedaannya.
3. **Rencana** — `superpowers:writing-plans` →
   `docs/superpowers/plans/YYYY-MM-DD-<topik>.md`. Centang langkah saat selesai.
4. **TDD** — tes gagal dulu, baru kode. Aturan bisnis diuji di
   `packages/lakuna_domain/test`, data di `packages/lakuna_data/test`, view
   model dan widget di `lakuna_flutter/test`.
5. **Code review** — `superpowers:requesting-code-review` dengan reviewer
   baru (subagent) sebelum merge. Temuan Critical/Important diperbaiki dulu.
6. **Verifikasi** — jalankan perintah dan lihat hasilnya sebelum mengklaim
   selesai, termasuk uji manual di aplikasi (bagian 6).

Setelah modul dirilis, perbarui tabel **Status & gap** di spec-nya dan
barisnya di `docs/superpowers/specs/README.md`.

Pemilik meminta "kerjakan Fase 1 sampai selesai": lanjutkan dari spec ke
rencana ke implementasi tanpa menunggu persetujuan rencana, kecuali ada
keputusan yang mengubah tujuan produk.

## 2. Git, PR, rilis

- Kembangkan di cabang fitur, buka PR ke `main`.
- **Claude boleh me-merge PR-nya sendiri** (squash) setelah CI hijau dan
  review selesai.
- Setiap rilis: naikkan `version:` di `lakuna_flutter/pubspec.yaml`
  (SemVer + nomor build; selama `0.x` rilis ditandai pre-release) dan
  tambahkan bagian di `CHANGELOG.md` (Keep a Changelog, Bahasa Indonesia)
  dengan bagian **Ditambahkan / Diubah / Diperbaiki / Dihapus / Keamanan /
  Catatan teknis** yang rinci. Perbarui tautan perbandingan versi di akhir.
- Setelah merge, `release.yml` membuat installer, tag `vX.Y.Z`, dan GitHub
  Release otomatis. Jangan push tag manual.
- Setelah squash-merge, mulai ulang cabang dari `origin/main` lalu
  `git merge -s ours origin/<cabang>` sebelum push (force push tidak bisa).
- README dan dokumen publik **tidak menyebut proyek acuan lain** selain
  Storeku.

## 3. Desain UI

- Komponen **Forui** dengan preset `conhcc` penuh: Zinc + Sky (`#0069A8`
  terang, `#00598A` gelap), judul **Montserrat**, isi **DM Sans**, ikon
  **Tabler** (`tabler_icons_plus`), radius Medium. Tema di
  `lakuna_flutter/lib/ui/core/theme/`.
- Acuan visual: kanvas [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525)
  (70 artboard; nomor layar mis. 1.4 Kasir dipakai di kode dan CHANGELOG).
  Halaman fondasi *Peta fitur hasil audit* adalah daftar periksa per modul.
  Spec desain: `docs/superpowers/specs/2026-11-03-ui-desain-lakuna-forui-design.md`.
- QRIS statis = gambar stiker QRIS utuh vertikal yang diunggah pemilik,
  ditampilkan rasio asli tanpa dipotong (1.6 / 1.6m / 1.26b).
- Mode Terang / Gelap / Ikuti sistem. Layout jalan di desktop, tablet, dan
  mobile (breakpoint 600 / 1280 px).
- Denah meja F&B memakai paket `vyuh_node_flow` (gambar denah = node
  terkunci di latar, meja = node tanpa port, orientasi 0°/90°, snap grid
  20 px, minimap; kasir memakai `NodeFlowViewer`).
- **Semua aset offline**: font dibundel, tanpa `google_fonts`, tanpa gambar
  jaringan. Logo dan placeholder dari DiceBear dibuat sekali lalu
  di-commit.

## 4. Stack dan konvensi kode

- Flutter 3.47.9 / Dart 3.13, Serverpod 4.1, pub workspace.
- Arsitektur resmi Flutter: View + ViewModel (`ChangeNotifier`), repositori
  abstrak + versi palsu untuk tes, `Command0/Command1`, `Result`, model
  immutable, DI `provider`, navigasi `go_router`.
- i18n: ARB `app_id.arb` (bawaan) + `app_en.arb`; setiap kunci baru wajib
  ada di keduanya, lalu `flutter gen-l10n`.
- Data: model `.spy.yaml` di `lakuna_server/lib/src/<area>/`
  (`database: all` atau `client`), `serverpod generate`, migrasi
  `serverpod create-migration --tag <modul>`. Kode generate di-commit,
  jangan diedit tangan.
- Penamaan DB: English snake_case, tabel jamak, `id` / `x_id` /
  `created_at` / `updated_at` / `deleted_at` (soft delete). Field
  multi-kata wajib `column=snake_name`.
- Semua tulis data bisnis lewat `LakunaStore.write` + `SyncTx.insert/update`
  agar tercatat di outbox sync dalam transaksi yang sama.
- **Stok dan saldo berupa ledger**; aturan bisnis di `lakuna_domain`, bukan
  trigger DB.
- Uang `Money` (rupiah bulat), jumlah `Qty` (mili-satuan). Tanpa `double`.
- Nomor dokumen memuat kode outlet **dan perangkat** (mis. nota
  `PST-K01-261102-0001`).
- Multi-tenant & multi-cabang: semua query dibatasi `tenant_id` /
  `outlet_id`.
- Izin dicek dengan `Permission` di UI dan di repositori.

## 5. Platform dan CI

- Fase 1: desktop (Windows, Linux, macOS), tablet, mobile. Web di Fase 2.
- Installer: Windows `.exe` (Inno Setup) + `.msi` (WiX), Linux `.deb`,
  macOS `.dmg`, Android `.apk` + `.aab`, iOS `.ipa` (tanpa tanda tangan
  sampai akun Apple siap).
- CI memakai **runner GitHub-hosted** (repo publik) dan semua job CI
  berjalan **paralel** (tanpa `needs:`). Jangan memakai `runs-on:
  self-hosted`.
- Sebelum push: `dart format`, `dart analyze --fatal-infos` /
  `flutter analyze --fatal-infos`, semua tes.

## 6. Uji manual di aplikasi

```bash
cd lakuna_flutter
flutter build linux --debug
LAKUNA_DATA_DIR=<dir> ./build/linux/x64/debug/bundle/lakuna
```

Di lingkungan cloud jalankan di Xvfb (1280x800) dan ambil tangkapan layar
untuk setiap layar yang diubah.

## 7. Fase produk

1. **Fase 1 (gratis, offline-first)**: kasir Retail + F&B (meja grid dan
   denah, open bill, modifier, split bill), QRIS statis + tombol "Sudah
   Terbayar", produk, stok, pembelian, pelanggan, supplier, pengeluaran,
   riwayat (void/retur), laporan & laba rugi, pengguna & role, pengaturan,
   panduan.
2. **Fase 2 (hosted, Serverpod)**: sinkronisasi semua data ke Postgres +
   aset ke object storage, versi web, dashboard semua cabang, transfer stok.
   Server di **VPS sendiri** (Hostinger/IDCloudhost, Docker), bukan
   Serverpod Cloud.
3. **Fase 3**: fitur ala majoo (kasbon/gaji, QRIS/e-wallet terintegrasi,
   promo, membership, dll.).
