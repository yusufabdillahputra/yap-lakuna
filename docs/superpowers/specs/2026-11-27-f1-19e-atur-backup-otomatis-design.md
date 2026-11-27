# F1-19e · Atur backup otomatis

- **Fase:** 1
- **Status:** Rilis v0.156.0
- **Layar:** Pengaturan › *Data & backup* (1.13 / 1.26).
- **Acuan:** gap [F1-19d](2026-11-14-f1-19d-backup-otomatis-design.md)
  *Jam dan jumlah simpanan bisa diatur*, *"Hari ini" menurut kalender*, dan
  *Preferensi ikut pulihkan* (gap 19 di `GAP-FASE1.md`). Storeku punya gap
  yang sama; kanvas desain hanya punya sakelar.

## Masalah

1. Backup otomatis selalu sekali per 24 jam dan menyimpan 7 berkas. Toko
   yang ramai ingin titik pulih lebih rapat (mis. tiap 6 jam), sedangkan
   pemilik yang ingin riwayat lebih panjang ingin menyimpan 30 berkas.
2. *Backup otomatis terakhir hari ini* berarti "kurang dari 24 jam lalu".
   Backup pukul 22.00 kemarin masih tertulis *hari ini* keesokan paginya,
   berbeda dengan pengingat Beranda yang sudah memakai tanggal kalender.
3. Status backup otomatis disimpan di database. Setelah pulihkan, sakelar,
   jadwal, waktu terakhir, dan tanda gagal kembali ke keadaan saat berkas
   itu dibuat, padahal semuanya milik perangkat ini.

## Aturan

1. Di kartu *Backup otomatis*, saat sakelar menyala, ada dua pilihan
   (izin `backup:manage`, sama dengan sakelar):
   - **Setiap** (`backup-auto-every`): *6 jam*, *12 jam*, *24 jam* (bawaan).
   - **Simpan** (`backup-auto-keep`): *3*, *7* (bawaan), *14*, *30* backup
     terakhir.
   Pilihan tersimpan per perangkat. Nilai lain (data rusak) dibaca sebagai
   bawaan.
2. Penjadwal tetap memeriksa dua menit setelah aplikasi dibuka lalu setiap
   jam. Backup dibuat bila backup otomatis terakhir sudah lewat jarak yang
   dipilih (atau belum pernah, atau waktunya di masa depan).
3. Setelah backup berhasil, folder *Otomatis* dipangkas ke jumlah yang
   dipilih. Menurunkan jumlah tidak langsung menghapus berkas; pemangkasan
   terjadi pada backup otomatis berikutnya.
4. Sakelar berganti nama menjadi *Backup otomatis* (bukan *harian*), dan
   keterangannya menyebut jadwal dan jumlah yang dipilih: *Setiap 24 jam
   selama aplikasi terbuka, ke {folder}. Menyimpan 7 backup terakhir, yang
   lebih lama dihapus. …*
5. *Backup terakhir …* dan *Backup otomatis terakhir …* di Data & backup
   dihitung menurut **tanggal kalender cabang** (zona waktu cabang, sama
   dengan pengingat Beranda): *hari ini*, *kemarin*, lalu *n hari lalu*.
6. **Pulihkan tidak mengubah preferensi backup otomatis perangkat**:
   `backup.auto`, `backup.autoEvery`, `backup.autoKeep`,
   `backup.autoLastAt`, `backup.autoFailed` tetap seperti sebelum pulihkan.
   Kunci yang belum pernah diisi di perangkat dihapus dari database hasil
   pulihkan, jadi kembali ke bawaan. Ini berlaku untuk pulihkan dari
   Pengaturan dan dari onboarding. *Backup terakhir* tetap diisi waktu
   backup yang dipasang (F1-19).

## Rancangan teknis

- `AutoBackupState` ditambah `everyHours` dan `keep`. Konstanta
  `autoBackupEveryChoices = [6, 12, 24]` dan
  `autoBackupKeepChoices = [3, 7, 14, 30]`, bawaan
  `autoBackupDefaultEvery = 24` dan `autoBackupKeep = 7`.
- `BackupRepository.setAutoBackupEvery(int hours)` dan
  `setAutoBackupKeep(int count)` (izin `backup:manage` dicek lebih dulu;
  nilai di luar pilihan memberi `AutoBackupChoiceInvalid`). `runAutoBackup` memangkas ke
  `state.keep`. `AutoBackupScheduler` memakai `state.everyHours`.
- `BackupOverview.timezone` (zona cabang) untuk hitungan tanggal.
  `calendarDaysAgo(at, now, timezone)` di `lakuna_domain` dipakai
  `BackupViewModel.daysSinceBackup`, `daysSinceAutoBackup`, dan
  `HomeViewModel.backupDaysAgo`.
- Preferensi perangkat saat pulihkan (`lakuna_data` `backup.dart`):
  `deviceBackupPreferenceKeys`. `stageRestore(..., devicePreferences:)`
  menulis `restore/perangkat.json` (kunci → nilai atau `null`).
  `applyPendingRestore` memindahkannya ke `<dataDir>/pulihkan-perangkat.json`.
  `finishRestore` mengembalikan nilainya (atau menghapus kunci yang `null`)
  lalu menghapus berkas itu; berkas rusak atau tak terbaca diabaikan agar
  pulihkan tetap jalan. `undoRestore` membuang berkas itu.
  `LocalBackupRepository._stage` membaca kunci dari database aktif sebelum
  menyiapkan berkas. Kunci `backup.auto*` adalah konstanta bersama di
  `lakuna_data` (`autoBackupKey`, …) yang dipakai repositori.
- `ChoicePill` mendapat `onTap` nullable (nonaktif, redup) dan
  `semanticsLabel` (*Setiap: 6 jam*).
- l10n: `backupAutoSwitch` (diubah), `backupAutoHint(folder, hours, keep)`,
  `backupAutoEvery`, `backupAutoEveryHours(hours)`, `backupAutoKeep`,
  `backupAutoKeepCount(count)`, `backupLastYesterday`,
  `backupAutoLastYesterday`.

## Tes

- Domain: `calendarDaysAgo` (lewat tengah malam cabang, zona berbeda,
  masa depan → 0).
- Data: stage → apply → finish mengembalikan preferensi perangkat dan
  menghapus kunci yang tidak ada di perangkat; tanpa berkas preferensi
  (stage lama) tetap jalan.
- Repositori: bawaan 24/7, simpan dan baca pilihan, nilai rusak → bawaan,
  izin, nilai di luar pilihan ditolak, pangkas ke `keep` pilihan.
- Penjadwal: jarak 6 jam dipakai (5 jam belum, 6 jam jalan).
- VM dan widget 1280/360: pilihan tampil hanya saat sakelar menyala,
  tersimpan, keterangan mengikuti pilihan, *kemarin* menurut tanggal
  cabang.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Jarak dan jumlah simpanan backup otomatis | — | Rilis v0.156.0 | 6/12/24 jam, 3/7/14/30 berkas. |
| Jam tertentu (mis. selepas tutup toko) | — | Belum | Aplikasi sering sudah ditutup pada jam itu; jarak lebih andal. |
| *Hari ini* menurut kalender | — | Rilis v0.156.0 | Sama dengan pengingat Beranda. |
| Preferensi backup otomatis tidak ikut pulihkan | — | Rilis v0.156.0 | Preferensi lain (printer, periode laporan) tetap ikut berkas. |
| Preferensi dibaca saat pulihkan dimulai | — | Diterima | Backup otomatis yang selesai selama ekstraksi berkas besar bisa tertimpa nilai lama (waktu terakhir / tanda gagal); paling buruk backup berikutnya datang lebih cepat. |
| Peringatan *backup lama* menurut kalender | — | Belum | Label hari memakai tanggal kalender, peringatan Beranda/Data & backup tetap > 7 × 24 jam (sudah begitu di Beranda sebelumnya). |
| Temuan review (diperbaiki) | — | v0.156.0 | Berkas preferensi tak terbaca tidak lagi menggagalkan pulihkan; kunci bersama; izin dicek sebelum nilai; pil nonaktif + label pembaca layar; palsu memvalidasi pilihan. |
