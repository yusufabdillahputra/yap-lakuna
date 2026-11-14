# F1-19c — Enkripsi backup dengan kata sandi

- **Status:** Rilis v0.60.0
- **Layar:** 1.13 *Data & backup* (Pengaturan) dan dialog *Pulihkan dari
  backup* di onboarding (1.1, F1-19b)
- **Acuan:** [F1-19](2026-11-04-f1-19-data-backup-design.md) gap
  *Enkripsi backup* ("Kata sandi backup bila diminta"); spec Storeku F1-19
  tidak mengenkripsi backup. Aturan kata sandi + ulangi mengikuti
  permintaan pemilik untuk setiap isian kata sandi.

## Tujuan

Berkas backup berisi seluruh data toko (penjualan, pelanggan, harga
modal) dan sering disimpan di Google Drive, WhatsApp, atau flashdisk.
Pemilik bisa mengunci backup dengan kata sandi sehingga berkas yang bocor
tidak bisa dibaca atau dipulihkan orang lain.

## Aturan

1. **Pilihan, bukan wajib.** Di *Data & backup* ada sakelar *Kunci dengan
   kata sandi* (`backup-lock`, bawaan mati). Saat dinyalakan tampil
   *Kata sandi backup* dan *Ulangi kata sandi* (`backup-password`,
   `backup-password-retype`). *Backup sekarang* nonaktif sampai kata sandi
   sah.
2. **Kata sandi sah:** 8 sampai 128 karakter (dihitung per karakter
   Unicode), dan isian ulangi sama persis. Pesan di bawah isian: terlalu
   pendek / terlalu panjang / tidak sama.
3. **Kata sandi tidak disimpan** di mana pun (tidak di database, tidak di
   preferensi). Catatan di bawah isian: "Kata sandi tidak disimpan.
   Tanpa kata sandi ini backup tidak bisa dipulihkan." Isian dikosongkan
   setelah backup berhasil dibuat.
4. **Format berkas** tetap `.zip` dengan nama dan isi yang sama
   (`manifest.json`, `lakuna.sqlite`, `media/…`). Setiap entri dienkripsi
   AES-256 gaya WinZip (AE-1, dengan MAC per entri) oleh paket `archive`,
   ditulis dan dibaca bertahap (tidak ditampung utuh di memori). AE-1
   tetap mencatat CRC32 isi asli, jadi manifest backup terkunci memuat
   `nonce` acak agar CRC-nya tidak bisa dipakai menebak isi manifest.
5. **Penurunan kunci:** kata sandi zip bukan kata sandi pengguna, melainkan
   `base64(PBKDF2-HMAC-SHA256(kata sandi UTF-8, salt acak 16 byte,
   310.000 iterasi, 32 byte))`, dihitung di isolate terpisah agar UI tidak
   tersendat. Parameternya ditulis di komentar zip (tidak terenkripsi):
   `lakuna-kunci:1:pbkdf2-sha256:<iterasi>:<salt base64url>`. Iterasi
   dibaca dari berkas, jadi bisa dinaikkan di versi berikutnya tanpa
   memecah backup lama (dibatasi 10.000–2.000.000 agar berkas rusak tidak
   membuat aplikasi macet). Kunci turunan terakhir disimpan di memori
   selama aplikasi berjalan, jadi buka kunci lalu pulihkan berkas yang
   sama hanya menghitung PBKDF2 sekali.
6. **Pulihkan** (Pengaturan dan onboarding): setelah berkas dipilih,
   backup terkunci tidak langsung menampilkan ringkasan. Panel meminta
   *Kata sandi backup* (`backup-unlock-password`) dan tombol *Buka*
   (`backup-unlock`). Kata sandi salah → pesan *Kata sandi salah* dan
   bisa dicoba lagi; berkas tetap terpilih. Setelah terbuka, alur sama
   dengan backup biasa (ringkasan, ketik nama toko, pulihkan) dan kata
   sandi yang sama dipakai untuk mengekstrak.
7. **Backup tanpa kunci** tetap dipulihkan seperti sebelumnya; kata sandi
   yang terlanjur dikirim diabaikan.
8. **Data rusak / diubah** (MAC tidak cocok, zip terpotong) → `BackupInvalid`
   seperti backup biasa; data aktif tidak berubah. Hanya pemeriksa kata
   sandi yang gagal dilaporkan sebagai *kata sandi salah*; MAC yang tidak
   cocok setelah pemeriksa lolos dianggap berkas rusak.
9. **Entri tanpa enkripsi ditolak di backup terkunci.** Siapa pun bisa
   menambah entri biasa ke zip tanpa tahu kata sandi (mis. mengganti
   gambar stiker QRIS). Bila komentar menandai backup terkunci, manifest,
   database, dan setiap gambar yang diekstrak wajib terenkripsi; bila
   tidak → `BackupInvalid`. Komentar kunci palsu di zip biasa ikut
   tertolak. Untuk semua backup, hanya gambar yang tercantum di manifest
   yang diekstrak.
10. **Hasil backup** menyebut bahwa berkas terkunci: "Backup terkunci kata
   sandi disimpan di …" / "… dibagikan".
11. **Kompatibilitas:** versi lama yang membuka backup terkunci melihatnya
    sebagai *bukan backup Lakuna* (manifest tidak terbaca) dan tidak
    mengubah data. Berkas tidak bisa dibuka dengan 7-Zip memakai kata
    sandi pengguna (kata sandi zip adalah kunci turunan).

## Komponen

- `lakuna_domain/lib/src/backup_password.dart`:
  `backupPasswordProblem(password, retype)` →
  `BackupPasswordProblem? {tooShort, tooLong, mismatch}`,
  `backupPasswordMinLength = 8`, `backupPasswordMaxLength = 128`.
- `lakuna_data/lib/src/backup_crypto.dart`: `pbkdf2Sha256` (dengan
  `package:crypto`, tanpa dependensi baru), `BackupLock` (salt, iterasi,
  format komentar, baca komentar dari ekor berkas), `deriveZipPassword`
  lewat `Isolate.run`.
- `lakuna_data/lib/src/backup.dart`: `createBackup(..., password:)` menulis
  lewat `ZipEncoder(password:, streamed: true)` + komentar;
  `inspectBackup` / `stageRestore` menerima `password:`; galat baru
  `BackupLocked` (perlu kata sandi) dan `BackupWrongPassword`.
  `BackupManifest` tidak berubah (format 1).
- `BackupRepository`: `createBackup({password})`, `inspect(path,
  {password})`, `stageRestore(path, {password})`, dan versi `ForSetup`.
  `CreatedBackup` membawa `locked`.
- `BackupViewModel`: `lockEnabled`, `setLock`, `setPassword`,
  `setPasswordRetype`, `passwordProblem`, `canBackup`; pulihkan:
  `needsPassword`, `setUnlockPassword`, `unlock` (Command0).
  `SetupRestoreViewModel` mendapat `needsPassword` / `unlock` yang sama.
- UI: `backup_section.dart` (sakelar + isian, panel buka kunci),
  `setup_restore_dialog.dart` (panel buka kunci).

## Pengujian

- Domain: batas panjang 8/128 per karakter, emoji dihitung satu, ulangi
  tidak sama.
- Data: vektor uji PBKDF2-HMAC-SHA256 (RFC 7914 §11), backup terkunci →
  komentar zip benar dan `manifest.json` tidak terbaca tanpa kata sandi;
  inspect tanpa kata sandi → `BackupLocked`; salah → `BackupWrongPassword`;
  benar → manifest; stage → database dan gambar sama; MAC rusak →
  `BackupInvalid`; iterasi di luar batas → `BackupInvalid`; backup biasa +
  kata sandi → diabaikan.
- Flutter: view model (sakelar, validasi, isian dikosongkan, buka kunci,
  kata sandi salah lalu benar), widget 1280 dan 360 px di Pengaturan dan
  onboarding.
- Uji manual Xvfb: backup terkunci, pulihkan dengan kata sandi salah lalu
  benar.

## Status & gap

| Topik | Desain | Status | Catatan |
| --- | --- | --- | --- |
| Kunci backup dengan kata sandi | 1.13 | Rilis v0.60.0 | Selesai. |
| Ganti iterasi PBKDF2 / Argon2 | — | Belum | Iterasi dibaca dari berkas; naikkan bila perangkat lebih cepat. Argon2 butuh paket native. |
| Ingat kata sandi backup di perangkat | — | Tidak direncanakan | Sengaja tidak disimpan. |
| Backup otomatis terkunci | — | Belum | Backup otomatis harian ada sejak v0.75.0 ([F1-19d](2026-11-14-f1-19d-backup-otomatis-design.md)) tanpa kunci; kunci butuh penyimpanan kata sandi aman. |
| Normalisasi Unicode kata sandi | — | Belum | Kata sandi dipakai apa adanya (UTF-8). Huruf beraksen yang diketik berbeda antar sistem (NFC/NFD) bisa dianggap beda; Dart belum punya normalisasi bawaan. |
| AE-2 (tanpa CRC32) | — | Belum | Paket `archive` menulis AE-1; ditutup dengan `nonce` di manifest. |
