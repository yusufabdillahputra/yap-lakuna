# Rencana F1-19c — Enkripsi backup dengan kata sandi

Spec: [F1-19c](../specs/2026-11-14-f1-19c-enkripsi-backup-design.md).

**Tujuan:** backup `.zip` bisa dikunci kata sandi (AES-256 per entri,
kunci dari PBKDF2-HMAC-SHA256) dan dipulihkan dengan kata sandi yang sama
dari Pengaturan maupun onboarding.

## Langkah

- [x] **Domain** — tes `backup_password_test.dart` (8/128 karakter, emoji,
  ulangi) lalu `backup_password.dart`, ekspor.
- [x] **Data: kripto** — tes vektor RFC 7914 untuk `pbkdf2Sha256`, format
  dan baca komentar `lakuna-kunci:1:…`, batas iterasi; lalu
  `backup_crypto.dart`.
- [x] **Data: backup** — tes backup terkunci (komentar, manifest tidak
  terbaca tanpa kunci), inspect tanpa / salah / benar, stage terkunci,
  MAC rusak, backup biasa + kata sandi; lalu `createBackup`,
  `inspectBackup`, `stageRestore` dengan `password:`, `BackupLocked`,
  `BackupWrongPassword`.
- [x] **Repositori** — `BackupRepository` + lokal + palsu menerima
  `password`; `CreatedBackup.locked`; tes repositori lokal.
- [x] **View model** — tes `BackupViewModel` (sakelar, validasi, isian
  dikosongkan, buka kunci) dan `SetupRestoreViewModel` (buka kunci);
  implementasi.
- [x] **UI + l10n** — sakelar dan isian di `backup_section.dart`, panel
  buka kunci (Pengaturan dan onboarding), pesan galat; kunci ARB id/en;
  tes widget 1280/360 px.
- [x] **Review** subagent baru; perbaiki temuan Critical/Important.
- [x] **Uji manual Xvfb**: backup terkunci, pulihkan dengan kata sandi
  salah lalu benar; tangkapan layar.
- [x] **Dokumen**: spec F1-19 (gap), README spec, STATUS-JEDA, panduan
  backup id/en, CHANGELOG 0.60.0, pubspec `0.60.0+63`.
- [ ] **PR, merge, cek rilis.**
