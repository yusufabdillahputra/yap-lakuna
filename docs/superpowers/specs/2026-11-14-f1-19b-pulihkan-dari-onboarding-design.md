# F1-19b · Pulihkan dari backup di onboarding

- **Fase:** 1
- **Status:** Rilis v0.46.0
- **Layar:** 1.1 Onboarding, langkah 1 (*Bahasa & tampilan*): tautan
  *Pulihkan dari backup*. Dialog memakai isi panel pulihkan 1.13.
- **Acuan:** spec F1-19 (gap "Pulihkan dari onboarding"). Storeku
  menempatkan pulihkan di Pengaturan saja; perbedaan dicatat di sini.

## Tujuan

Pemilik yang HP/PC-nya rusak atau berganti perangkat bisa memasang backup
langsung di perangkat baru, tanpa membuat toko palsu dulu lalu pulihkan dari
Pengaturan.

## Aturan

1. **Tempat:** tombol *Pulihkan dari backup* di langkah pertama wizard
   (di bawah pilihan bahasa & tema), dengan teks singkat "Pindah perangkat?
   Pasang backup toko Anda". Langkah lain tidak menampilkannya.
2. **Izin:** belum ada staf, jadi tidak ada cek izin. Sebagai gantinya
   repositori **menolak** bila toko sudah dibuat di perangkat ini
   (`StoreAlreadySetUp`). Pulihkan untuk toko yang sudah ada tetap lewat
   Pengaturan (`backup:manage`).
3. **Alur:** pilih berkas `.zip` → pemeriksaan sama dengan F1-19 aturan 1–2
   (`BackupInvalid`, `BackupTooNew`) → ringkasan isi (toko, cabang,
   perangkat, tanggal, jumlah nota/produk) → ketik nama toko pada backup →
   *Pulihkan* → backup disiapkan (`restore/ready`) dan aplikasi dimuat
   ulang. Pemasangan, folder `sebelum-pulihkan-…`, dan pembatalan bila
   database gagal dibuka sama persis dengan F1-19 aturan 4–9.
4. Setelah pulih, aplikasi membuka layar **login** (toko sudah ada),
   bukan onboarding lagi. Pilihan bahasa/tema di wizard diganti preferensi
   dari backup.
5. Galat (berkas rusak, versi lebih baru, ruang habis) tampil di dialog;
   dialog hanya ditutup lewat *Batal* dan terkunci selama backup
   disiapkan.
6. Bila backup gagal dibuka setelah dipasang (F1-19 aturan 7), perangkat
   kembali kosong sehingga wizard tampil lagi dengan pesan *Pulihkan
   gagal* di langkah 1.
7. "Toko sudah ada" = konteks toko termuat **atau** ada tenant yang belum
   dihapus (sama dengan `setupStore`).

## Komponen

- `BackupRepository.inspectForSetup(path)` /
  `stageRestoreForSetup(path)`; `LocalBackupRepository` memeriksa
  `StoreRepository.current == null`.
- `SetupRestoreViewModel` (pick, confirm text, restore → restart).
- `setup_restore_dialog.dart` di `ui/onboarding`; `OnboardingScreen`
  menerima `BackupRepository` + `BackupFiles` (router, bootstrap).

## Pengujian

- Repositori: ditolak bila toko sudah ada; inspeksi & siapkan berhasil
  sebelum toko dibuat (data `restore/ready` tertulis).
- VM: pilih → ringkasan, konfirmasi nama tidak peka huruf, batal memilih,
  galat berkas, restart dipanggil setelah berhasil.
- Widget: tombol hanya di langkah 1; dialog 1280 / 360 px.
- Uji manual Xvfb: perangkat kosong → pulihkan backup → login dengan data
  backup.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Pulihkan dari onboarding | — | Selesai v0.46.0 | |
| Pilih toko dari server (Fase 2) | — | Belum | Versi hosting memulihkan dari server, bukan berkas. |
