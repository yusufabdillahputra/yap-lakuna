# F1-09 · Master data

- **Fase:** 1
- **Status:** Rilis v0.10.0
- **Layar desain:** 1.17 *Master data* (desktop). Kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525),
  berkas `F1-Master-Data`; 1.17b *Grup modifier* (`F1-Master-Modifier`)
  dibangun bersama F1-10.
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-09-master-data-design.md`

## Tujuan

Satu tempat untuk data referensi yang dipakai produk, stok, kasir, dan
laporan, agar modul lain cukup memilih dari daftar dan pemilik bisa
merapikan kategori yang terbentuk otomatis dari form produk.

## Lingkup v0.10.0

Layar `/master` (*Master data*, subjudul "Data referensi yang dipakai
produk, stok, kasir & laporan"), menu di kelompok *Produk & stok* setelah
Stok. Tab vertikal di desktop/tablet lebar, pil di ponsel.

1. **Kategori** (lengkap seperti kanvas): tabel urutan (tombol naik/turun di
   samping pegangan ⋮⋮), nama + titik warna + induk, jumlah produk, saklar
   *Aktif*, *Ubah*. Panel *Kategori baru* / *Ubah kategori*: nama, kategori
   induk (satu tingkat), warna (8 pilihan), *Tampil di kasir*, lalu *Batal* /
   *Simpan kategori*; saat mengubah ada *Hapus kategori*. Catatan: "Urutan
   ini dipakai tab kategori di layar kasir."
2. **Satuan**: daftar satuan tenant (pcs, botol, dus, kg …) dengan jumlah
   produk yang memakai; tambah, ganti nama, hapus.
3. **Lokasi stok**: daftar lokasi cabang (baca saja) dan tombol *Kelola di
   Stok* yang membuka `/stok?tab=locations` (tambah/ganti nama sudah ada di
   F1-08). Tombol hanya tampil bila staf punya `stock:adjust`.
4. **Metode pembayaran**: ringkasan metode (Tunai, Kartu, Transfer, QRIS
   statis) dan tombol *Buka Pengaturan* (QRIS statis diatur di 1.26b).

Kasir mengikuti master: chip kategori hanya untuk kategori **aktif** dan
**Tampil di kasir**, urut `sort_order` lalu nama, dengan titik warna.
Form produk hanya menyarankan kategori aktif.

Tidak termasuk v0.10.0 (lihat Status & gap): Alasan penyesuaian sebagai
master (tetap enum bawaan F1-08), Jenis pengeluaran (F1-15), Grup pelanggan
(F1-13), Meja & area + Grup modifier (F1-10), Shift (F1-03 lanjutan),
seret-lepas urutan, jadikan default / hapus lokasi.

## Desain UI (baseline)

Mengikuti kanvas 1.17: kepala halaman, kartu tab vertikal di kiri
(Kategori, Satuan, Lokasi stok, Metode pembayaran; tab modul lain
ditambahkan oleh modulnya), konten di kanan: tabel kategori dan panel
*Kategori baru* di sisi kanan (≥ 1280 px) atau di bawah tabel (lebih
sempit). Ponsel (< 600 px): pil tab di atas, tabel menjadi daftar baris,
panel form menjadi lembar bawah (`showFSheet`). Warna kategori tampil
sebagai lingkaran 10 px.

## Aturan bisnis (`lakuna_domain`, `master_data.dart`)

- **Nama** kategori wajib, maks 60 karakter terlihat (sama dengan field
  kategori di form produk), unik per tenant tanpa membedakan huruf
  besar/kecil di antara kategori yang belum dihapus (aktif maupun
  nonaktif).
- **Induk** satu tingkat: induk harus kategori tenant yang belum dihapus,
  bukan dirinya sendiri, dan bukan subkategori. Kategori yang punya
  subkategori tidak boleh diberi induk.
- **Warna**: kosong atau salah satu dari 8 warna palet
  (`categoryColors`: sky `#0069A8`, emerald `#059669`, amber `#D97706`,
  rose `#E11D48`, violet `#7C3AED`, teal `#0D9488`, orange `#EA580C`,
  zinc `#52525B`).
- **Urutan**: naik/turun menukar posisi dengan tetangga di daftar terurut
  (`sort_order`, lalu nama); semua kategori dinomori ulang 0..n dalam satu
  transaksi supaya nilai kembar lama ikut rapi.
- **Aktif**: kategori nonaktif tidak tampil di kasir dan tidak disarankan di
  form produk; produknya tetap dijual (tampil di chip *Semua*).
- **Hapus = soft delete** (`deleted_at`) dan **ditolak** bila masih dipakai
  produk yang belum dihapus atau masih punya subkategori; pesan menyebut
  jumlahnya.
- **Satuan**: nama wajib, maks 30 karakter, unik per tenant tanpa membedakan
  huruf. Ganti nama langsung terlihat di produk. Hapus ditolak bila satuan
  dipakai sebagai satuan dasar produk atau satuan konversi varian yang
  belum dihapus (pesan menyebut jumlah produk).
- Semua tulis lewat `LakunaStore.write` + `SyncTx.insert/update` (outbox
  sync), satu transaksi per aksi, `version` naik dan `hlc` baru tiap ubah.

## Data

Migrasi `master` (`serverpod create-migration --tag master`):

- `categories`: tambah `parent_id` (UUID, nullable, relasi ke
  `categories`, Restrict), `color` (TEXT nullable), `show_in_cashier`
  (bool, bawaan `true`), `is_active` (bool, bawaan `true`).
- Tidak ada tabel baru.

## Izin

`products:manage`: menu *Master data*, rute `/master`, tab Kategori dan
Satuan (dicek juga di repositori). Tab Lokasi stok dan Metode pembayaran
hanya baca; tombol *Kelola di Stok* butuh `stock:adjust`, *Buka
Pengaturan* butuh `settings:manage`.

## Kasus tepi

- Dua perangkat membuat kategori bernama sama sebelum sync: diterima di
  lokal (dicek per perangkat); penggabungan menyusul di F2 (konflik sync).
- Kategori induk dinonaktifkan: subkategori tetap mengikuti saklarnya
  sendiri (tidak ikut nonaktif).
- Form produk mengetik nama kategori nonaktif yang sudah ada: produk
  memakai kategori itu (tidak membuat kembar); kategori tetap nonaktif.
- Urutan diubah saat ada kategori yang baru dibuat otomatis oleh form
  produk: penomoran ulang membereskan `sort_order` kembar.

## Pengujian (TDD)

- Domain: validasi nama/induk/warna, `moveInOrder`.
- Data: buat/ubah kategori dengan outbox, induk tidak valid ditolak,
  urutan naik/turun menomori ulang, saklar aktif, hapus ditolak bila dipakai
  produk/subkategori, satuan buat/ganti nama/hapus (ditolak bila dipakai),
  jumlah produk per kategori/satuan, kasir hanya memuat kategori aktif +
  tampil di kasir.
- View model + widget: alur tambah/ubah/hapus kategori, urutan, satuan,
  ponsel tanpa luapan di 360/820/1280 px, tanpa izin.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Kategori (induk, warna, urutan, tampil di kasir, aktif) | Tab lengkap | Rilis v0.10.0 | Urutan memakai tombol naik/turun; seret-lepas ⋮⋮ menyusul. Hapus minta konfirmasi. |
| Kasir mengikuti urutan, aktif & warna kategori | Ada | Rilis v0.10.0 | Chip memuat kategori yang dipakai produk langsung atau lewat subkategori; memilih induk ikut menampilkan produk subkategori. |
| Satuan | Ada | Rilis v0.10.0 | Selesai. |
| Lokasi stok | Ada | Baca + tautan ke Stok (v0.9.0) | *Jadikan default* dan hapus lokasi menyusul. |
| Metode pembayaran | Ada | Ringkasan + tautan ke Pengaturan (v0.10.0) | Selesai. |
| Alasan penyesuaian | Ada | Enum bawaan F1-08 | Master alasan sendiri menyusul (butuh tabel baru + migrasi data). |
| Jenis pengeluaran | Ada | Belum | Dibangun bersama F1-15. |
| Grup pelanggan | Ada | Belum | Dibangun bersama F1-13. |
| Meja & area, Grup modifier (1.17b) | Ada | Belum | Dibangun bersama F1-10. |
| Shift | Ada di 1.17b | Belum | Bersama shift sesi kasir (F1-03 lanjutan). |

### Penyesuaian tata letak (dicatat saat rilis)

- Tab vertikal muncul bila lebar konten ≥ 900 px; di bawahnya tab berupa
  pil yang bisa digeser.
- Tabel kategori dan panel form berdampingan bila lebar konten ≥ 860 px;
  di bawahnya form ditumpuk di bawah tabel.
- Di bawah 600 px (ponsel) baris kategori menjadi kartu dan form dibuka di
  lembar bawah; menutup lembar tanpa *Batal* (tombol kembali / ketuk luar)
  keluar dari mode ubah, pesan sukses tetap di daftar.

Rencana: [2026-11-03-f1-09-master-data.md](../plans/2026-11-03-f1-09-master-data.md).

## Kriteria selesai

Kategori dan satuan bisa ditambah, diubah, diurutkan (kategori),
dinonaktifkan (kategori), dan dihapus bila tidak dipakai; urutan, warna, dan
saklar kategori terlihat di Kasir; layar jalan di desktop, tablet, dan
ponsel tanpa luapan.
