# F1-19d — Backup otomatis harian (desktop)

- **Fase:** 1
- **Status:** Rilis v0.75.0
- **Layar:** Pengaturan › *Data & backup* (1.13 / 1.26), pengingat Beranda
  (1.10).
- **Acuan:** gap [F1-19](2026-11-04-f1-19-data-backup-design.md)
  *Backup otomatis* dan gap [F1-19c](2026-11-14-f1-19c-enkripsi-backup-design.md)
  *Backup otomatis terkunci*. Storeku punya gap yang sama.

## Tujuan

Banyak pemilik UMKM tidak pernah menekan *Backup sekarang*. Bila database
rusak (listrik padam saat menulis, disk bermasalah, salah hapus), semua
penjualan hilang. Di komputer kasir (desktop), Lakuna membuat backup
sendiri sekali sehari ke folder lokal dan menyimpan tujuh backup terakhir,
jadi selalu ada titik pulih tanpa langkah dari pemilik.

## Aturan

1. **Hanya desktop** (Windows, Linux, macOS). Di Android/iOS sakelar tidak
   tampil dan backup otomatis tidak berjalan: aplikasi ponsel tidak bisa
   menulis ke folder bersama tanpa pengguna memilih tujuan (gap).
2. **Sakelar *Backup otomatis harian*** (`backup-auto`) di *Data & backup*,
   per perangkat (preferensi lokal `backup.auto`). **Bawaan menyala** di
   desktop: tujuannya melindungi pemilik yang lupa. Mengubahnya butuh izin
   `backup:manage` (sama dengan bagian ini).
3. **Kapan:** saat aplikasi berjalan dengan toko siap, pemeriksaan dilakukan
   dua menit setelah aplikasi dibuka lalu setiap jam. Backup dibuat bila
   backup otomatis terakhir lebih dari 24 jam lalu atau belum pernah. Tidak
   butuh staf masuk (berjalan di layar PIN juga), karena ini tindakan
   sistem, bukan aksi staf.
4. **Ke mana:** `Dokumen/Lakuna/Backup/Otomatis/` dengan nama yang sama
   dengan backup manual (`lakuna-backup-<KODE>-<YYMMDD-HHMM>.zip`). Hanya
   **7 berkas terbaru** di folder itu yang disimpan; yang lebih lama
   dihapus. Backup manual di `Dokumen/Lakuna/Backup/` tidak pernah dihapus.
5. **Tidak dikunci kata sandi** (kata sandi tidak disimpan di perangkat).
   Berkasnya ada di komputer yang sama dengan database yang juga tidak
   terenkripsi. Bila folder *Dokumen* disinkronkan ke awan (OneDrive,
   iCloud Drive), salinan backup ikut tersimpan di akun awan pemilik
   sendiri; keterangan sakelar menyebut hal ini agar pemilik bisa
   mematikannya. Bawaan tetap menyala karena kehilangan data lebih sering
   terjadi daripada kebocoran dari akun awan milik sendiri. Backup terkunci
   tetap lewat *Backup sekarang*.
6. Backup otomatis yang berhasil juga mengisi *Backup terakhir*, sehingga
   pengingat Beranda (> 7 hari) tidak muncul selama backup otomatis jalan.
7. *Data & backup* menampilkan: sakelar, keterangan folder dan
   "7 backup terakhir disimpan", *Backup otomatis terakhir* (relatif), dan
   bila percobaan terakhir gagal, pesan *Backup otomatis terakhir gagal*.
   Kegagalan dicoba lagi pada pemeriksaan berikutnya (satu jam).
8. Pulihkan memakai alur yang sama (*Pulihkan* → pilih berkas di folder
   *Otomatis*).

## Rancangan teknis

- `BackupRepository`:
  - `autoBackup()` → `AutoBackupState{enabled, lastAt, failed}` (tanpa cek
    izin; dipakai layanan dan layar).
  - `setAutoBackup(bool)` (izin `backup:manage`).
  - `runAutoBackup(Directory folder)` (tanpa staf; butuh toko siap):
    membuat backup ke folder sementara khusus otomatis, menyalin ke
    `<tujuan>.part` lalu mengganti nama (berkas setengah jadi tidak pernah
    tampak sah), memangkas ke 7 berkas `lakuna-backup-*.zip` terbaru
    menurut cap waktu di akhir nama (bukan kode cabang) hanya setelah
    berhasil, mencatat `backup.autoLastAt` dan `backup.lastAt`. Galat apa
    pun → `backup.autoFailed`, `.part` dan folder sementara dibersihkan.
- Preferensi lokal: `backup.auto` (`'on'`/`'off'`, kosong = bawaan),
  `backup.autoLastAt`, `backup.autoFailed`.
- `AutoBackupScheduler` (`lib/data/services/auto_backup.dart`):
  `runIfDue()`, `start()` (Timer 2 menit lalu periodik 1 jam),
  `dispose()` (async: menunggu backup yang sedang berjalan agar database
  tidak ditutup di tengah penyalinan). `lastAt` di masa depan (jam
  dimundurkan) dianggap jatuh tempo. Dijalankan dari `bootstrap.dart`
  hanya di desktop; `close` menunggu `dispose`.
- `autoBackupDirectory()` = `backupDirectory()/Otomatis`.
- UI: `BackupViewModel.autoSupported`, `autoBackup`, `autoFolderPath`,
  `daysSinceAutoBackup` (≥ 0), `setAuto` (Command1).
- l10n: `backupAutoTitle`, `backupAutoSwitch`, `backupAutoHint(folder)`,
  `backupAutoLastNever`, `backupAutoLastToday`, `backupAutoLastDays(days)`,
  `backupAutoFailed`, `backupAutoSaveFailed`.

## Tes

- Repositori (Flutter, SQLite sungguhan): bawaan menyala; jalan tanpa staf;
  berkas di folder; pangkas ke 7 tanpa menyentuh berkas lain; pangkas
  menurut waktu walau kode cabang berbeda; `.part` dibuang dan tidak ada
  yang dipangkas bila gagal; mencatat
  waktu otomatis dan *Backup terakhir*; toko belum siap → galat dan
  `failed`; `setAutoBackup` butuh izin.
- Penjadwal: tidak jalan bila mati / belum 24 jam; jalan bila belum pernah
  atau ≥ 24 jam atau `lastAt` di masa depan; tidak menumpuk bila
  pemeriksaan tumpang tindih; galat selain `Exception` tidak lolos;
  `dispose` menunggu backup yang berjalan.
- VM + widget *Data & backup* 1280/360: sakelar tampil di desktop, tersimpan;
  tidak tampil bila tidak didukung; status terakhir dan gagal.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Backup otomatis harian desktop | 1.13 | Rilis v0.75.0 | — |
| Backup otomatis di ponsel | — | Belum | Butuh folder pilihan pengguna (SAF Android / Files iOS). |
| Backup otomatis terkunci | — | Belum | Butuh penyimpanan kata sandi aman (keychain/keystore). |
| Jam dan jumlah simpanan bisa diatur | — | Belum | Tetap 24 jam dan 7 berkas. |
| Backup di isolate terpisah | — | Belum | Zip dibuat di isolate UI (sama dengan *Backup sekarang*); database besar bisa membuat layar tersendat sesaat sekali sehari. |
| Preferensi ikut pulihkan | — | Belum | `backup.auto*` tersimpan di database, jadi status sakelar dan gagal ikut kembali ke keadaan berkas yang dipulihkan. |
| "Hari ini" menurut kalender | — | Belum | *Terakhir hari ini* berarti kurang dari 24 jam lalu. |
| Salin ke flashdisk / folder awan (Google Drive desktop) | — | Belum | Pemilik bisa mengarahkan folder sinkron awan ke `Dokumen/Lakuna/Backup`. |
