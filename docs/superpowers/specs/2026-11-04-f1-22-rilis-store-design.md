# F1-22 · Rilis ke store & distribusi

- **Fase:** 1
- **Status:** Dikerjakan
- **Layar desain:** 1.26 Pengaturan (bagian baru *Tentang Lakuna*); tidak
  ada layar lain.
- **Acuan:** spec Storeku `2026-11-02-f1-22-rilis-store-design.md`,
  workflow `.github/workflows/{ci,release}.yml`.

## Tujuan

Pengguna bisa memasang dan memperbarui Lakuna tanpa kehilangan data:
installer desktop (Windows, Linux, macOS), Android lewat APK dan Google
Play, iOS/iPadOS lewat App Store. Semua yang bisa disiapkan tanpa akun
pemilik selesai di modul ini; langkah yang butuh pemilik ditulis sebagai
panduan langkah demi langkah.

## Aturan dari Storeku (tetap berlaku)

- **Satu versi untuk semua platform.** `version: X.Y.Z+N` di
  `lakuna_flutter/pubspec.yaml` → tag `vX.Y.Z`, `versionName` /
  `CFBundleShortVersionString` X.Y.Z, `versionCode` / `CFBundleVersion` N.
- **Nomor build N wajib naik** setiap rilis: Play Console dan App Store
  menolak versionCode yang sama atau lebih kecil.
- **Keystore Android permanen** wajib sebelum rilis publik; tanpa itu APK
  ditandatangani kunci debug dan update mengharuskan uninstall (data
  hilang). Empat secret: `ANDROID_KEYSTORE_BASE64`,
  `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
  `release.yml` sudah membacanya dan memberi akhiran `-uji` bila kosong.
- Google Play: listing ID/EN, ikon 512, feature graphic 1024×500,
  tangkapan layar HP & tablet, kebijakan privasi, Data safety, rating
  konten; jalur internal → closed → produksi.
- App Store: Apple Developer Program, sertifikat & profil di secret CI,
  TestFlight dulu.
- Desktop: `.exe` + `.msi`, `.deb`, `.dmg` dari `release.yml`; tanda tangan
  kode (Authenticode, notarization) menyusul bila pemilik punya sertifikat.
- Runner hanya GitHub-hosted.

## Perbedaan Lakuna

- Nomor build diambil dari `+N` di pubspec (bukan rumus `X*10000+...`),
  jadi `release.yml` memeriksa N lebih besar dari N di tag rilis
  sebelumnya dan gagal bila tidak.
- Setiap GitHub Release menyertakan `SHA256SUMS.txt` agar pengguna bisa
  memeriksa unduhan (8 aset per rilis).

## Lingkup modul ini

1. **Pengaturan › Tentang Lakuna** (semua staf): nama aplikasi, versi,
   ringkasan kebijakan privasi (data di perangkat ini; versi hosted di
   server pemilik toko), tautan ke Panduan, dan daftar **lisensi open
   source** (paket dan font) yang bisa dibuka per paket.
2. **Lisensi aset bundel** (font Montserrat, DM Sans, DM Mono — SIL OFL;
   Bootstrap Icons — MIT, mark logo) didaftarkan ke `LicenseRegistry` saat
   aplikasi mulai dan dicatat di `NOTICE.md`.
3. **CI rilis**: cek nomor build naik, `SHA256SUMS.txt`.
4. **Dokumen pemilik** di `docs/rilis/`: `README.md` (keystore, secret,
   Play Console, App Store, tanda tangan desktop), `kebijakan-privasi.md`
   (ID + EN, untuk URL kebijakan di store), `listing-store.md` (teks
   listing ID + EN dalam batas karakter Play).
5. **Aset store** di `docs/rilis/aset/`: ikon 512×512, feature graphic
   1024×500, tangkapan layar HP (potret 864×1728) dan tablet (lanskap
   2560×1600) ID + EN, JPEG.
6. **Ikon aplikasi Lakuna** (sebelumnya ikon bawaan Flutter): mark Etalase
   (Bootstrap Icons `shop-window`) di kotak gradien Sky `#00A6F4 → #0069A8`,
   ikon `#F0F9FF`, sesuai spec desain. Android legacy + adaptive (vector,
   monochrome untuk ikon bertema), iOS (kotak penuh tanpa alfa), macOS
   (grid Apple), Windows `.ico`, web, dan ikon `.deb`. Dibuat oleh
   `tools/brand/render.mjs` (Chromium/Playwright) + `make_icons.py`.

Tidak termasuk: akun store, unggah ke store, tanda tangan iOS/desktop
(butuh pemilik), versi web (Fase 2).

## Arsitektur

- `lib/config/bundled_licenses.dart`: `registerBundledLicenses()` menambah
  `LicenseEntryWithLineBreaks` per aset dari berkas lisensi di `assets/`;
  dipanggil di `main()`.
- `lib/ui/settings/about_view_model.dart`: `AboutViewModel` dengan
  `Command0 load` yang mengumpulkan `Stream<LicenseEntry>` (bisa diganti di
  tes) menjadi daftar paket terurut beserta paragrafnya.
- `lib/ui/settings/about_section.dart`: kartu versi + privasi + tombol
  Panduan, lalu daftar lisensi (`FAccordion`, satu item per paket).
- `SettingsSection.about` selalu ada di akhir daftar bagian.

## Pengujian

- Unit: `AboutViewModel` mengelompokkan dan mengurutkan lisensi per paket;
  galat stream menjadi `load.error`.
- Unit: `registerBundledLicenses` menambah tiga font + Bootstrap Icons.
- Widget: bagian Tentang tampil untuk kasir (tanpa `settings:manage`),
  menampilkan versi, membuka lisensi satu paket, dan tombol Panduan
  membuka `/panduan`; 360 px tanpa overflow.
- Manual (Xvfb): Pengaturan › Tentang Lakuna ID + EN.

## Langkah yang butuh pemilik

1. Membuat keystore permanen dan mengisi 4 secret Android.
2. Mendaftar Google Play Console (biaya sekali) dan Apple Developer Program
   (tahunan).
3. Menyetujui teks kebijakan privasi dan listing, lalu mengunggahnya.

## Status & gap

| Topik | Desain | Kode/CI | Catatan |
| --- | --- | --- | --- |
| Installer desktop + APK/AAB + IPA tanpa tanda tangan | - | Rilis sejak v0.1.0 | |
| Nomor build naik, SHA256SUMS | - | Dikerjakan | |
| Tentang Lakuna + lisensi | 1.26 | Dikerjakan | |
| Dokumen pemilik + aset store | - | Dikerjakan | |
| Ikon aplikasi semua platform | Spec desain | Dikerjakan | Menggantikan ikon bawaan Flutter |
| Keystore Android permanen | - | Menunggu pemilik | Secret belum diisi |
| Google Play / App Store | - | Menunggu pemilik | Akun developer |
| Tanda tangan kode desktop | - | Menyusul | Butuh sertifikat |
