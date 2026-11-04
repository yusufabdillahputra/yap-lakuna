# Rilis Lakuna ke store dan distribusi

Panduan untuk pemilik proyek. Installer di GitHub Releases sudah dibuat
otomatis oleh `.github/workflows/release.yml` setiap kali versi baru masuk ke
`main`. Langkah di bawah dibutuhkan untuk Google Play, App Store, dan agar
pembaruan Android tidak menghapus data.

## 1. Versi dan nomor build

- `lakuna_flutter/pubspec.yaml` memuat `version: X.Y.Z+N`.
- `X.Y.Z` menjadi tag `vX.Y.Z`, `versionName` Android, dan
  `CFBundleShortVersionString` iOS/macOS.
- `N` menjadi `versionCode` Android dan `CFBundleVersion`. **N wajib naik
  setiap rilis.** Play Console dan App Store menolak nomor yang sama atau
  lebih kecil.
- `tools/release/check-version.sh` dijalankan di CI (setiap PR) dan sebelum
  rilis. Skrip itu gagal bila CHANGELOG belum punya bagian versi baru atau N
  tidak lebih besar dari N di tag terakhir.
- Setiap GitHub Release menyertakan `SHA256SUMS.txt`. Untuk memeriksa
  unduhan di Linux/macOS: `sha256sum -c SHA256SUMS.txt --ignore-missing`.

## 2. Kunci Android permanen (wajib sebelum dipakai toko sungguhan)

Tanpa kunci permanen, APK ditandatangani kunci debug (berkas berakhiran
`-uji`). Akibatnya setiap pembaruan harus uninstall dulu, dan **data toko di
HP ikut terhapus**.

1. Buat keystore sekali saja, di komputer pemilik (butuh JDK):

   ```bash
   keytool -genkeypair -v -keystore lakuna-upload.jks \
     -keyalg RSA -keysize 4096 -validity 10000 -alias lakuna-upload
   ```

   Masukkan kata sandi keystore, lalu ulangi kata sandi itu saat diminta.
   Gunakan kata sandi yang sama untuk kunci bila ditanya.
2. Simpan `lakuna-upload.jks` dan kata sandinya di dua tempat aman (mis.
   pengelola kata sandi + flashdisk). **Kunci yang hilang tidak bisa
   diganti**: aplikasi di HP pelanggan tidak bisa diperbarui lagi.
3. Ubah ke base64: `base64 -w0 lakuna-upload.jks > lakuna-upload.b64`
   (macOS: `base64 -i lakuna-upload.jks -o lakuna-upload.b64`).
4. Di GitHub: **Settings › Secrets and variables › Actions › New repository
   secret**, isi empat secret:

   | Secret | Isi |
   | --- | --- |
   | `ANDROID_KEYSTORE_BASE64` | isi berkas `lakuna-upload.b64` |
   | `ANDROID_KEYSTORE_PASSWORD` | kata sandi keystore |
   | `ANDROID_KEY_ALIAS` | `lakuna-upload` |
   | `ANDROID_KEY_PASSWORD` | kata sandi kunci (biasanya sama) |

5. Rilis berikutnya menghasilkan `Lakuna-X.Y.Z-android.apk` dan `.aab` tanpa
   akhiran `-uji`. HP yang memasang APK `-uji` perlu backup data, uninstall,
   pasang APK baru, lalu pulihkan backup (Pengaturan › Data & backup). Ini
   hanya sekali.

## 3. Google Play

1. Daftar [Google Play Console](https://play.google.com/console) (biaya
   pendaftaran sekali bayar). Akun pribadi baru wajib menjalankan *closed
   testing* dengan penguji sebelum boleh rilis produksi.
2. **Buat aplikasi**: nama *Lakuna*, bahasa bawaan Indonesia, aplikasi,
   gratis.
3. **Play App Signing**: biarkan Google menyimpan kunci aplikasi. Kunci dari
   langkah 2 menjadi *upload key*.
4. **Listing toko**: salin teks dari [listing-store.md](listing-store.md)
   (ID + EN). Aset grafis ada di [`aset/`](aset/):
   - ikon `aset/ikon-512.png` (512×512),
   - feature graphic `aset/feature-graphic.png` (1024×500),
   - tangkapan layar HP `aset/<bahasa>/hp-*.jpg` (864×1728) dan tablet
     `aset/<bahasa>/tab-*.jpg` (2560×1600), `<bahasa>` = `id` atau `en`.
   Semua aset dibuat ulang dengan `tools/brand/render.mjs` +
   `tools/brand/make_icons.py` (ikon) dan tangkapan layar aplikasi.
5. **Kebijakan privasi**: tautkan
   `https://github.com/yusufabdillahputra/yap-lakuna/blob/main/docs/rilis/kebijakan-privasi.md`.
6. **Keamanan data (Data safety)**: versi gratis tidak mengumpulkan dan tidak
   membagikan data. Semua data tersimpan di perangkat. Jawab *Tidak* untuk
   pengumpulan data. Bila versi hosted dirilis (Fase 2), perbarui formulir
   ini.
7. **Rating konten**: isi kuesioner (aplikasi bisnis, tanpa konten sensitif).
8. **Rilis**: unggah `Lakuna-X.Y.Z-android.aab` dari GitHub Release ke jalur
   *Internal testing*, lalu *Closed testing*, lalu *Production*.

## 4. App Store (iOS/iPadOS) dan macOS

1. Daftar [Apple Developer Program](https://developer.apple.com/programs/)
   (biaya tahunan).
2. Buat App ID `id.lakuna.app`, sertifikat *Apple Distribution*, dan profil
   *App Store*. Simpan sertifikat (.p12, base64) dan profil sebagai secret
   GitHub. Setelah secret ada, workflow iOS diubah dari `--no-codesign`
   menjadi build bertanda tangan yang diunggah ke TestFlight.
3. Di App Store Connect: buat aplikasi, salin teks dari
   [listing-store.md](listing-store.md), tangkapan layar iPhone/iPad, URL
   kebijakan privasi yang sama, *App Privacy*: *Data Not Collected*.
   Tangkapan layar App Store **belum ada** di `aset/`: Apple meminta ukuran
   sendiri (iPhone 6,9" 1320×2868, iPad 13" 2064×2752). Ambil dari
   simulator iOS saat akun Apple siap.
4. macOS: dengan sertifikat *Developer ID Application* yang sama, `.dmg` bisa
   ditandatangani dan dinotarisasi agar Gatekeeper tidak memperingatkan.

## 5. Desktop Windows dan Linux

- Windows: `.exe` (Inno Setup) dan `.msi` (WiX). Tanpa sertifikat
  Authenticode, SmartScreen menampilkan *Windows protected your PC*. Pengguna
  memilih **More info › Run anyway**. Sertifikat code signing (OV/EV) bisa
  ditambahkan ke workflow kapan saja.
- Linux: `.deb` untuk Ubuntu/Debian 22.04+ (`sudo apt install
  ./lakuna_X.Y.Z_amd64.deb`).

## 6. Pembaruan tanpa kehilangan data

- Data ada di folder data aplikasi per platform. Folder ini tidak tersentuh
  saat aplikasi diperbarui dengan installer versi baru.
- Android: pembaruan aman selama APK ditandatangani kunci yang sama
  (langkah 2).
- Sebelum pindah perangkat atau pasang ulang, buat backup di Pengaturan ›
  Data & backup.
