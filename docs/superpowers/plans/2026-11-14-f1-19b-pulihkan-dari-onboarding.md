# Rencana F1-19b · Pulihkan backup dari onboarding (v0.46.0)

Spec: [F1-19b](../specs/2026-11-14-f1-19b-pulihkan-dari-onboarding-design.md).

## Langkah

- [x] Repositori (TDD): `inspectForSetup` / `stageRestoreForSetup`,
      `StoreAlreadySetUp` bila toko sudah ada (juga setelah dibaca ulang).
- [x] `SetupRestoreViewModel` (TDD): pilih, ringkasan, konfirmasi nama,
      galat, restart; tidak membuang perintah saat aplikasi dimuat ulang.
- [x] `setup_restore_dialog.dart`, kartu di langkah 1 wizard, router.
- [x] l10n ID/EN, tes widget 1280/360 px.
- [x] Uji manual Xvfb: perangkat kosong → pulihkan → login.
- [x] Panduan ID/EN, spec F1-19/F1-19b/README/STATUS-JEDA, CHANGELOG,
      versi 0.46.0+49.
- [x] Review subagent, perbaiki temuan (pesan pulihkan gagal di wizard,
      cek tenant, tanpa restart minta buka ulang, galat bersama, latar
      tidak menutup dialog, tes AppRestart di harness).
- [ ] PR #52: CI, merge, cek rilis.
