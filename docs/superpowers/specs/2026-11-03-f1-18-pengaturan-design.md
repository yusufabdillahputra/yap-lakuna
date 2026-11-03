# F1-18 · Pengaturan toko

- **Fase:** 1
- **Status:** Sebagian: tampilan & bahasa (v0.1.0), metode pembayaran ›
  QRIS statis (v0.7.0)
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
| Rekening transfer, kartu, kredit | 1.26 | Belum | Bersama kredit (F1-13) |
| Profil toko, cabang, struk & printer, pajak, penjualan & stok, data & backup | 1.26 | Belum | Bersama modul terkait |
| Orientasi EXIF JPEG | - | Belum: lebar/tinggi dibaca dari SOF sebelum rotasi, foto ponsel bisa diberi peringatan "tidak vertikal" palsu | Baca APP1 orientation 5-8 lalu tukar lebar/tinggi |
| Berkas gambar lama | - | Saat stiker diganti, baris `media_files` lama dan berkasnya tetap ada; berkas ditulis sebelum transaksi selesai | Pembersihan media tanpa rujukan (Fase 2, bersama unggah object storage) |
| Baris gambar ada, berkas hilang di perangkat | - | Pengaturan meminta unggah ulang sebelum QRIS bisa diaktifkan | Sengaja: kasir tidak bisa menampilkan stiker tanpa berkas |
