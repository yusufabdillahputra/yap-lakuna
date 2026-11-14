# F1-18 · Pengaturan toko

- **Fase:** 1
- **Status:** Sebagian: tampilan & bahasa (v0.1.0), metode pembayaran ›
  QRIS statis (v0.7.0), struk (v0.8.0), profil, cabang, penjualan & stok,
  pajak inklusif, ukuran tampilan (v0.23.0)
- **Layar desain:** 1.26 *Pengaturan*, 1.26b *Pengaturan › Metode
  pembayaran › QRIS statis*. Kanvas
  [Desain UI Lakuna](https://claude.ai/artifact/SEm5SPjepvhVKviYxdz525)
- **Acuan Storeku:** `docs/superpowers/specs/2026-11-02-f1-18-pengaturan-design.md`

## Tujuan

Satu tempat untuk mengatur toko, cabang, dan perangkat: metode pembayaran,
struk & printer, pajak & service, penjualan & stok, tampilan & bahasa, data
& backup. Modul dibangun bertahap; setiap bagian rilis bersama modul yang
memakainya.

## Struktur layar

- Judul **Pengaturan**, subjudul "Berlaku untuk <cabang> · semua perangkat
  cabang ini" untuk bagian per cabang.
- Navigasi bagian: kolom kiri bila lebar konten ≥ 900 px (tablet mendatar
  ke atas; diubah dari 1280 px saat review v0.7.0 agar tablet 1024 px
  tidak memakai pil), deretan pil di atas pada layar sempit. Bagian yang belum dibangun tidak ditampilkan.
- Bagian yang butuh izin `settings:manage` disembunyikan dari staf tanpa
  izin itu. *Tampilan & bahasa* selalu terlihat (preferensi perangkat).

## Lingkup v0.7.0: Metode pembayaran › QRIS statis (1.26b)

- **Gambar QRIS statis:** pratinjau stiker utuh (rasio asli, tanpa
  dipotong), nama file · ukuran. Kotak *Ganti gambar QRIS* dengan tombol
  *Pilih file* (PNG, JPG, atau WebP, maks 5 MB).
- **Hasil pemeriksaan** setelah memilih file:
  - rasio: "Rasio vertikal terdeteksi (1 : 1,42)" (ok) atau peringatan
    "Gambar tidak vertikal" (boleh disimpan);
  - resolusi: "Resolusi L × T px" (ok bila lebar ≥ 1000 px), peringatan
    "Disarankan ≥ 1000 px lebar agar tajam di tablet" bila kurang;
  - galat (tidak bisa disimpan): format bukan PNG/JPG/WebP (dicek dari isi
    file, bukan nama), atau lebih dari 5 MB.
- Catatan biru "Unggah stiker utuh, bukan potongan QR".
- **Data merchant:** *Nama merchant di QRIS* (maks 60), *NMID* (opsional,
  huruf/angka maks 20, disimpan huruf besar), *Kode terminal* (maks 20),
  *Dana masuk ke* (teks bebas maks 80, petunjuk kasir saat cek mutasi).
- **Sakelar:** *QRIS statis aktif di kasir* (butuh gambar), *Wajib tekan
  "Sudah Terbayar"* (selalu aktif, tidak bisa dimatikan).
- Tombol **Simpan** (dan **Batal** mengembalikan isian ke nilai tersimpan).
  Berhasil → pesan "Pengaturan QRIS tersimpan".

## Lingkup v0.23.0: Profil toko, Cabang ini, Penjualan & stok, pajak inklusif, ukuran tampilan (1.26)

Keputusan brainstorming (jawaban dari desain 1.26 dan spec Storeku F1-18):

- **Profil toko** (`settings:manage`): *Nama usaha* (wajib, maks 60, sama
  dengan onboarding). *Jenis usaha* dan *Zona waktu* hanya dibaca: jenis
  usaha menentukan menu Retail/F&B, zona waktu menentukan tanggal nomor
  nota, jadi tidak diubah di Fase 1.
- **Cabang ini** (`settings:manage`): *Nama cabang* (wajib, maks 60),
  *Alamat* (opsional, maks 160), *Telepon* (opsional, maks 20, angka, spasi,
  `+`, `-`). *Kode cabang* dan *Kode perangkat* hanya dibaca karena dipakai
  di nomor dokumen. Simpan memperbarui kepala aplikasi dan login.
- **Penjualan & stok** (`settings:manage`, kunci `sales.rules` per cabang,
  JSON `{"allowNegativeStock": bool, "rounding": "none"|"nearest100"|"nearest500"}`):
  - *Izinkan stok minus* (bawaan hidup = perilaku sebelumnya: nota tetap
    tersimpan dan kasir diberi peringatan). Bila mati, nota retail dan
    penyelesaian bill F&B ditolak bila ada produk berstok yang menjadi
    minus di lokasi penjualan (`SaleStockShort` berisi nama produk), dan
    bill F&B menolak menambah item yang stoknya tidak cukup.
  - *Wajib buka sesi kasir*: sakelar terkunci hidup ("uang tunai dicatat
    per sesi"), sama dengan *Wajib tekan Sudah Terbayar*.
  - *Pembulatan total*: Tidak ada / Ke Rp 100 terdekat / Ke Rp 500
    terdekat. Dibulatkan ke kelipatan terdekat, tepat setengah ke atas
    (Rp 50 → Rp 100, Rp 250 → Rp 500). Berlaku untuk semua metode bayar,
    nota kredit, dan bill F&B (setelah service dan PB1). Selisih disimpan di
    `sales.rounding_amount` (boleh negatif), termasuk dalam `sales.total`,
    tampil sebagai baris *Pembulatan* di kasir, struk, dan laporan.
  - *Diskon manual butuh PIN manajer* (v0.24.0, spec F1-04b): bawaan
    hidup; bila mati, staf tanpa `sales:discount` tidak melihat menu diskon.
- **Pajak & service** (F&B): sakelar *Harga sudah termasuk pajak* (kunci
  `fnb.tax_inclusive`). Bila hidup, PB1 dipisahkan dari (subtotal +
  service): pajak = (subtotal + service) × tarif ÷ (1 + tarif), dibulatkan
  setengah ke atas, dan tidak ditambahkan ke total. Nota menyimpan
  `sales.tax_inclusive` agar struk menulis "PB1 10% (termasuk)" dan laporan
  memisahkan pajak dari penjualan bersih.
- **Tampilan & bahasa**: *Ukuran tampilan* Normal / Besar (preferensi
  perangkat, skala teks 1,0 / 1,15) untuk semua pengguna.

## Aturan bisnis

- Validasi gambar di `lakuna_domain` (`checkQrisImage`): baca ukuran dari
  header PNG / JPEG (SOF) / WebP (VP8, VP8L, VP8X) tanpa dekoder gambar,
  jadi jalan di Dart murni.
- Validasi isian di `lakuna_domain` (`validateQrisSettings`).
- QRIS aktif tanpa gambar ditolak.

## Data

- **`settings`** (sudah ada): satu baris per cabang, `scope_key` =
  `outlet:<id>`, `key` = `payments.qris_static`, `value_json` =
  `{"enabled", "mediaId", "merchantName", "nmid", "terminalCode",
  "settlementNote"}`. Disimpan lewat `SyncTx` (outbox).
- **`media_files`** (baru): `tenant_id`, `outlet_id?`, `kind`
  (`MediaKind.qrisSticker`), `file_name`, `mime_type`, `size_bytes`,
  `sha256`, `width`, `height`, `storage_key` (`<sha256>.<ext>`), kolom sync
  standar. File disimpan di `<folder data>/media/<storage_key>`; isinya
  ditentukan hash, jadi file yang sama tidak disalin dua kali dan tidak
  bentrok antar perangkat. Fase 2 mengunggah file ke object storage dengan
  kunci yang sama.

## Izin

`settings:manage` untuk bagian Metode pembayaran (UI dan repositori).

## Pengujian

- Domain: header PNG/JPEG/WebP, rasio, resolusi, batas 5 MB, isian.
- Data: simpan + muat QRIS, file media tersimpan sekali per hash, QRIS
  aktif tanpa gambar ditolak, outbox tercatat.
- Widget: pilih file (picker palsu), peringatan, simpan, staf tanpa izin
  tidak melihat bagian ini.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Tampilan & bahasa | 1.26 | Rilis v0.1.0 | - |
| QRIS statis | 1.26b | Rilis v0.7.0 | - |
| Pembacaan QR (NMID otomatis) | 1.26b "QR terbaca" | Belum, NMID diketik | Dekoder QR offline Dart murni |
| *Foto stiker* (kamera), seret file | 1.26b | Belum, *Pilih file* saja | Bersama foto produk (F1-07) |
| *Kasir boleh konfirmasi tanpa PIN manajer* | 1.26b | Belum | Bersama persetujuan PIN manajer |
| *Tampilkan juga di layar mobile kasir* | 1.26b | Belum, selalu tampil | Bila ada permintaan |
| Rekening transfer, kartu, kredit | 1.26 | Rekening transfer rilis v0.74.0 ([F1-05c](2026-11-14-f1-05c-rekening-transfer-design.md)); kartu & kredit belum | Rekening di *Penjualan & stok*, bukan di halaman *Metode pembayaran* (QRIS). |
| Struk & printer | 1.26 | Rilis v0.8.0 (lihat F1-06) | - |
| Profil toko, Cabang ini | 1.26 | Rilis v0.23.0 | Jenis usaha dan zona waktu hanya dibaca |
| Penjualan & stok: stok minus, wajib sesi, pembulatan | 1.26 | Rilis v0.23.0 | Wajib sesi selalu hidup |
| Diskon manual butuh PIN manajer | 1.26 | v0.24.0 | - |
| Harga sudah termasuk pajak | 1.26 | Rilis v0.23.0 | F&B saja (pajak hanya di F&B) |
| Ukuran tampilan Normal/Besar | 1.26 | Rilis v0.23.0 | Skala teks perangkat |
| Data & backup | 1.26 | Belum | F1-19 |
| Stok minus dimatikan: split bill / QRIS | - | Stok dicek saat bill ditutup; bila stok habis di antara pembayaran bagian split (mis. penjualan retail di perangkat yang sama), bagian terakhir ditolak setelah bagian lain dibayar | Pra-cek stok sebelum bayar bagian pertama; untuk sekarang sesuaikan stok lalu ulangi |
| Stok minus dimatikan: bill lain | - | Tambah / ubah jumlah item hanya menghitung bill ini, bukan open bill meja lain | Reservasi stok per bill bila diperlukan |
| Pembulatan bagian split bill | - | Tagihan per tamu dibagi dari total yang sudah dibulatkan, bisa tidak kelipatan Rp 100/500 | Bulatkan per bagian bila ada permintaan |
| PB1 termasuk di laporan per produk / kategori | - | Penjualan per produk memakai total baris (termasuk PB1 bila harga termasuk pajak), sama seperti service | Pisahkan pajak per baris di Fase 2 |
| Aturan pembulatan di layar Kasir | - | Dimuat saat Kasir dibuka; layar dibuat ulang setiap kali menu dibuka | Muat ulang bila aturan bisa berubah dari perangkat lain (sinkronisasi Fase 2) |
| Orientasi EXIF JPEG | - | Rilis v0.29.1 | `readImageHeader` membaca tag Orientation APP1 Exif (MM/II); 5–8 menukar lebar/tinggi |
| Berkas gambar lama | - | Saat stiker diganti, baris `media_files` lama dan berkasnya tetap ada; berkas ditulis sebelum transaksi selesai | Pembersihan media tanpa rujukan (Fase 2, bersama unggah object storage) |
| Baris gambar ada, berkas hilang di perangkat | - | Pengaturan meminta unggah ulang sebelum QRIS bisa diaktifkan | Sengaja: kasir tidak bisa menampilkan stiker tanpa berkas |
