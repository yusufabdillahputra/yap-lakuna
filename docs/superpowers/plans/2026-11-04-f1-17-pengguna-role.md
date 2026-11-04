# Rencana F1-17 · Pengguna & role (v0.22.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-17-pengguna-role-design.md`

## 1. Model & migrasi

- [x] `organization/staff_role.spy.yaml` (tabel `roles`), `serverpod
      generate`, `serverpod create-migration --tag staff-role`.

## 2. Domain (TDD)

- [x] `staff.dart`: `staffNameIssue`, `validatePinPair`,
      `validatePasswordPair`, `roleKeyFor`, `encodePermissions` /
      `decodePermissions`, `effectivePermissions`, `grantIssue`.

## 3. Data (TDD)

- [x] `staff_access.dart`: `OutletStaff.permissions` + `roleName` dari tabel
      `roles`.
- [x] `users.dart`: daftar akun, tambah/ubah staf, reset PIN, ganti PIN /
      kata sandi sendiri, daftar role, simpan matriks, role custom
      (buat/ganti nama/hapus). Tes skenario + izin + batas wewenang.

## 4. Aplikasi

- [x] `UsersRepository` + lokal + palsu; `SessionRepository.unlockPin`,
      `refreshCurrent`; `StaffProfile.roleName`, `roleLabel`.
- [x] VM (TDD): daftar pengguna + kunci, form pengguna (PIN + ulangi,
      reset PIN), matriks role, Akun saya.
- [x] Layar `/pengguna` (tab Pengguna, Role & izin), dialog pengguna,
      `/akun`; menu; ARB id/en.
- [x] Tes widget 1440 / 800 / 360.

## 5. Selesai

- [x] Format, analyze, semua tes.
- [x] Review subagent; perbaiki Critical/Important.
- [x] Uji manual Xvfb + tangkapan layar.
- [x] Spec Status & gap, README spec, CHANGELOG 0.22.0, versi `0.22.0+23`.
- [x] PR, CI hijau, squash merge, cek rilis.
