# F1-19 · Data & backup

- **Fase:** 1
- **Status:** Rilis v0.25.0
- **Layar desain:** 1.13 *Data & backup · mobile*; bagian *Data & backup*
  di Pengaturan (1.26); pengingat di Beranda (1.10)
- **Acuan Storeku:** `2026-11-02-f1-19-backup-design.md`
- **Menutup gap:** F0 "Layar gagal mulai", F1-01 "Data toko tidak lengkap"
  (pulihkan dari backup), F1-18 "Data & backup"

## Tujuan

Versi gratis menyimpan semua data hanya di perangkat. Pemilik harus bisa
membuat backup (database + gambar) dan memulihkannya ke perangkat ini atau
perangkat pengganti, agar data tidak hilang bila HP/PC rusak.

## Lingkup

Termasuk:

- Bagian **Data & backup** di Pengaturan (izin `backup:manage`):
  - "Mode saat ini · Gratis · offline" dan teks "Semua data dan gambar
    tersimpan di perangkat ini saja…".
  - Statistik: Transaksi (nota), Produk, Ukuran data (database + gambar).
  - *Backup terakhir* (relatif, mis. "9 hari lalu" / "Belum pernah").
  - *Backup sekarang*: membuat `.zip`. Desktop: disimpan langsung ke
    `Dokumen/Lakuna/Backup` (lokasinya ditampilkan; dua backup di menit yang
    sama diberi akhiran `-2`). Android/iOS: share sheet (ditutup tanpa
    memilih = backup tidak dicatat). Salinan sementara dihapus saat backup
    berikutnya dibuat.
  - *Pulihkan*: pilih `.zip`, ringkasan isi backup (toko, cabang,
    perangkat, tanggal, jumlah nota/produk), konfirmasi dengan mengetik nama
    toko pada backup, lalu aplikasi dimuat ulang.
  - "File backup berisi database dan semua gambar (.zip). Simpan di tempat
    aman."
  - Kartu **Aktifkan versi hosting** (alamat server, kode aktivasi) tampil
    nonaktif dengan keterangan "Tersedia di versi hosting (Fase 2)".
- **Pengingat** di Beranda bila backup terakhir lebih dari 7 hari lalu atau
  belum pernah (hanya untuk staf dengan `backup:manage`), dengan tombol ke
  Data & backup.
- **Layar gagal mulai**: bila database gagal dibuka, tampil pesan galat dan
  lokasi data (bisa disalin), bukan aplikasi yang berhenti diam-diam.

Tidak termasuk (gap):

- Backup otomatis / ke cloud pihak ketiga. Enkripsi berkas backup: selesai
  v0.60.0, [F1-19c](2026-11-14-f1-19c-enkripsi-backup-design.md).
- Aktifkan hosting (alur F2-01).
- Pulihkan dari layar onboarding (sebelum toko dibuat): selesai v0.46.0,
  [F1-19b](2026-11-14-f1-19b-pulihkan-dari-onboarding-design.md).

## Format berkas

`lakuna-backup-<KODECABANG>-<YYMMDD-HHMM>.zip` berisi:

- `manifest.json`: `app: "lakuna"`, `format: 1`, versi aplikasi, versi
  skema (migrasi `lakuna` terakhir), tenant (id, nama), cabang (id, kode,
  nama), perangkat (id, kode), waktu backup (UTC), jumlah nota dan produk,
  ukuran dan SHA-256 database, daftar gambar.
- `lakuna.sqlite`: salinan konsisten lewat `VACUUM INTO` (kasir tetap bisa
  jalan; sesi kasir terbuka ikut tersalin).
- `media/<storage_key>`: semua berkas gambar di folder data.

## Aturan pulihkan

1. Validasi: `manifest.json` ada, `app == "lakuna"`, format dikenal, versi
   skema terisi, `lakuna.sqlite` ada dengan ukuran sesuai manifest. SHA-256
   database dicocokkan saat diekstrak (langkah 4, ditulis langsung ke berkas
   tanpa ditampung di memori). Gagal → `BackupInvalid`, data tidak berubah.
   Hanya `lakuna.sqlite` dan `media/<nama>` (tanpa subfolder, `..`, `\`,
   atau `:`) yang diekstrak.
2. Versi skema backup tidak dikenal aplikasi (backup dari versi lebih baru)
   → `BackupTooNew`.
3. Konfirmasi: ketik nama toko pada backup (tidak peka huruf besar/kecil,
   spasi di tepi diabaikan).
4. Berkas diekstrak ke `<folder data>/restore/` lalu ditandai siap.
5. Aplikasi menutup database, memindahkan data lama ke
   `<folder data>/sebelum-pulihkan-<YYMMDD-HHMM>/` (database + gambar), lalu
   memasang data backup dan memuat ulang aplikasi. Migrasi berjalan otomatis
   bila backup lebih lama.
6. Bila aplikasi tertutup di tengah langkah 5, pemasangan dilanjutkan saat
   aplikasi dibuka lagi (penanda `restore/ready`). Folder tujuan dicatat di
   `restore/applying` sebelum ada yang dipindah, dan setelah database
   backup terpasang data aktif tidak dipindah lagi.
7. Bila database backup gagal dibuka setelah dipasang, data backup dipindah
   ke `pulihkan-gagal-<YYMMDD-HHMM>/`, data lama dikembalikan, dan Beranda
   menampilkan *Pulihkan gagal*.
8. Identitas perangkat (id dan kode kasir, mis. K01) ikut dari backup:
   perangkat pengganti melanjutkan nomor nota perangkat lama. Jangan
   memakai backup yang sama di dua perangkat sekaligus (dicatat di
   Panduan; pendaftaran perangkat baru dibahas di Fase 2).
9. *Backup terakhir* diisi waktu backup yang dipasang (penanda
   `pulihkan-selesai`, dicatat setelah database dibuka).
10. Setelah pulih, pengguna kembali ke layar login (sesi staf direset).

## Data

Tidak ada tabel baru. `backup.last_at` (ISO UTC) disimpan di
`local_preferences` (per perangkat). Preferensi perangkat lain (tema,
printer) ikut dari backup.

## Izin

`backup:manage` (pemilik; manajer tidak). Repositori menolak backup dan
pulihkan tanpa izin.

## Kasus tepi

- Ruang penyimpanan habis / galat tulis → pesan galat, berkas sementara
  dihapus.
- Zip rusak atau bukan backup Lakuna → ditolak tanpa mengubah data.
- Batal di dialog simpan / pilih berkas → tidak ada perubahan.

## Pengujian

- Data: backup → manifest benar, isi zip; pulihkan ke folder lain →
  jumlah baris dan gambar sama; zip rusak / checksum salah / bukan Lakuna
  ditolak; skema lebih baru / kosong ditolak; pemasangan memindahkan data
  lama; entri zip berbahaya tidak diekstrak; pemasangan dilanjutkan setelah
  crash di tengah; batalkan pemasangan mengembalikan data lama.
- Repositori: izin `backup:manage`, salinan sementara dibersihkan.
- VM: statistik, backup terakhir, alur pulihkan (konfirmasi nama).
- Widget: bagian Data & backup 1440 dan 360 px; pengingat Beranda; layar
  gagal mulai; backup gagal dibuka → data lama dikembalikan.
- Uji manual Xvfb: backup, pulihkan, aplikasi dimuat ulang.

## Status & gap

| Topik | Desain | Kode | Rekomendasi |
| --- | --- | --- | --- |
| Backup & pulihkan manual | 1.13 | v0.25.0 | - |
| Pengingat backup di Beranda | 1.10 | v0.25.0 | - |
| Layar gagal mulai | - | v0.25.0 | - |
| Aktifkan hosting | 1.13 | Kartu nonaktif | Alur di F2-01 |
| Enkripsi backup | 1.13 | Rilis v0.60.0 | [F1-19c](2026-11-14-f1-19c-enkripsi-backup-design.md): kunci kata sandi + ulangi, AES-256 per entri |
| Pulihkan dari onboarding | - | Selesai v0.46.0 | [F1-19b](2026-11-14-f1-19b-pulihkan-dari-onboarding-design.md) |
| Perangkat pengganti vs perangkat tambahan | - | Identitas perangkat ikut backup | Fase 2: daftarkan perangkat baru (kode K02) saat sync |
| Checksum per gambar | - | Hanya database | Tambah SHA-256 gambar di manifest bila perlu |
| Simpan ke lokasi pilihan (desktop) | 1.13 | Folder tetap Dokumen/Lakuna/Backup | Dialog simpan bila diminta |
