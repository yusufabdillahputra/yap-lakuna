# F1-21 · Panduan pengguna

- **Fase:** 1
- **Status:** Dikerjakan
- **Layar desain:** 1.27 *Panduan / dokumentasi · desktop*
- **Acuan Storeku:** `2026-11-02-f1-21-panduan-design.md`

## Tujuan

Pemilik dan staf UMKM bisa belajar memakai Lakuna tanpa bertanya: artikel
per fitur dengan langkah bernomor dan tangkapan layar, dalam Bahasa
Indonesia dan English, dibuka **offline** dari menu *Panduan*.

## Perbedaan dengan Storeku

- Storeku memakai dioxus-docs-kit. Lakuna merender sendiri subset Markdown
  dengan widget Forui (tanpa paket Markdown pihak ketiga, tanpa jaringan).
- Situs panduan online menyusul bersama versi web (Fase 2); konten
  Markdown yang sama bisa dipakai ulang.
- Lakuna menambah pencarian dan artikel untuk modul yang dirilis sesudah
  daftar isi kanvas dibuat (diskon, kredit, struk, denah, pelanggan,
  pengeluaran, laporan, pengguna, pengaturan).

## Layar 1.27

- **Kepala:** judul *Panduan*, lencana *Tersedia offline*, kolom cari
  ("Cari: cara retur, QRIS, backup…"), sakelar **ID / EN**. Bahasa awal
  mengikuti bahasa aplikasi; sakelar hanya mengganti bahasa panduan.
- **Daftar isi** (kolom kiri ≥ 900 px): kelompok dengan judul huruf besar,
  artikel aktif disorot. Saat mencari, daftar isi diganti hasil pencarian
  (judul + kelompok) atau "Tidak ada artikel yang cocok".
- **Artikel:** breadcrumb *Kelompok › Judul*, judul H1, paragraf, H2
  (*Sebelum mulai*, *Langkah*), daftar bernomor/berpoin, kotak *catatan*
  (biru) dan *peringatan* (kuning), tangkapan layar dengan keterangan, lalu
  tautan *← sebelumnya* / *berikutnya →* sesuai urutan daftar isi.
- **Layar sempit** (< 900 px): halaman daftar isi; memilih artikel membuka
  artikel dengan tombol *Daftar isi* untuk kembali.
- Rute `/panduan`, artikel lewat `?artikel=<slug>` (tautan kontekstual dari
  layar lain cukup `Routes.guideArticle(slug)`).

## Konten

- Satu sumber: `lakuna_flutter/assets/guide/`.
  - `toc.json`: urutan kelompok (`id`, judul ID + EN) dan slug artikel.
  - `{id,en}/<slug>.md`: artikel. Baris pertama `# Judul`.
  - `img/{id,en}/<nama>.webp`: tangkapan layar per bahasa (UI dalam bahasa
    yang sama), lebar 960 px, WebP kualitas ±75.
- Subset Markdown yang didukung:
  - `# H1` (judul), `## H2`, paragraf (baris berurutan digabung).
  - `1. item` (bernomor) dan `- item` (berpoin).
  - `> [!note] teks` dan `> [!warning] teks` (kotak; baris `>` lanjutan
    digabung).
  - `![keterangan](nama)` gambar satu baris → `img/<bahasa>/<nama>.webp`.
  - Inline: `**tebal**`, `*miring*`, `[teks](slug)` tautan ke artikel lain.
- Artikel yang belum diterjemahkan jatuh ke Bahasa Indonesia.
- Setiap modul yang dirilis sesudah ini **wajib** memperbarui artikelnya di
  PR yang sama (Definition of Done di rencana).

### Daftar isi

| Kelompok | Artikel (slug) |
| --- | --- |
| Mulai | Instalasi & akun pemilik (`install-owner`), Masuk dengan PIN & ganti kasir (`login-pin`), Menambah produk pertama (`first-product`), Sesi kasir & kas laci (`cash-session`) |
| Kasir | Transaksi & harga grosir (`sale`), Diskon manual (`discount`), Pembayaran tunai & kembalian (`pay-cash`), Menerima QRIS statis (`pay-qris`), Split payment (`split-payment`), Penjualan kredit (`credit-sale`), Struk & printer (`receipt-printer`), Retur & void (`return-void`) |
| F&B | Meja & open bill (`tables-open-bill`), Modifier menu (`modifiers`), Split bill (`split-bill`), Mengatur denah meja (`floor-plan`) |
| Stok & pembelian | Mencatat pembelian (`purchases`), Penyesuaian & stok minimum (`stock`), Supplier & hutang (`supplier-debt`) |
| Keuangan | Pelanggan & piutang (`customers-credit`), Pengeluaran (`expenses`), Laporan & laba rugi (`reports`) |
| Pengaturan | Pengguna & role (`users-roles`), Pengaturan toko (`store-settings`) |
| Data | Backup & pulihkan (`backup-restore`), Versi hosting (`hosting`), Tanya-jawab (`faq`) |

## Arsitektur

- `GuideRepository` (abstrak) → `AssetGuideRepository(AssetBundle)`:
  `toc()` dan `article(lang, slug)`; hasil `Result`. Teks diurai sekali dan
  disimpan di memori.
- `parseGuideMarkdown(String)` → `GuideDocument` (judul, blok, teks polos
  untuk pencarian). Murni Dart, diuji tanpa widget.
- `GuideViewModel`: bahasa, slug aktif, kueri cari, hasil cari,
  sebelumnya/berikutnya. Pencarian tanpa membedakan huruf besar di judul dan
  isi artikel bahasa aktif; memuat semua artikel bahasa itu saat pertama
  mencari.
- `GuideScreen` + `GuideArticleView` (render blok dengan Forui: `FAlert`
  untuk kotak, `Image.asset` untuk gambar dengan `errorBuilder`).

## Izin

Semua staf (menu *Panduan* tanpa izin khusus), termasuk sebelum ada izin
apa pun di sesi.

## Pengujian

- Parser: setiap jenis blok, inline, galat bentuk (tanpa judul).
- Konten (tes yang memuat aset sungguhan):
  - setiap slug di `toc.json` ada untuk ID **dan** EN, berjudul;
  - setiap tautan `[..](slug)` menunjuk slug yang ada;
  - setiap gambar ada di `img/<bahasa>/`, berformat WebP, ≤ 150 KB;
  - tidak ada slug ganda;
  - setiap berkas `.md` dan `.webp` terdaftar (tidak ada yang yatim).
- View model: bahasa awal, ganti bahasa, cari, sebelumnya/berikutnya,
  slug tidak dikenal jatuh ke artikel pertama.
- Widget 1440 / 360 px: daftar isi, buka artikel, ganti EN, cari, tautan
  berikutnya, kasir pun bisa membuka.
- Manual (Xvfb): tangkapan layar Panduan ID dan EN.

## Status & gap

| Topik | Desain | Kode | Catatan |
| --- | --- | --- | --- |
| Layar Panduan + daftar isi + cari + ID/EN | 1.27 | Dikerjakan | |
| Artikel semua modul Fase 1 yang dirilis | Daftar isi | Dikerjakan | 27 artikel × 2 bahasa |
| Tangkapan layar WebP per bahasa | - | Dikerjakan | |
| Tautan kontekstual dari layar lain | - | Menyusul | Rute `?artikel=` sudah siap |
| Situs panduan online | A1 §6 | Menyusul Fase 2 | Konten Markdown dipakai ulang |
