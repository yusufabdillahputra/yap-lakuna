# Rencana F1-17 · Pengguna & role (v0.22.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-17-pengguna-role-design.md`

## 1. Model & migrasi

- [ ] `organization/staff_role.spy.yaml` (tabel `roles`), `serverpod
      generate`, `serverpod create-migration --tag staff-role`.

## 2. Domain (TDD)

- [ ] `staff.dart`: `staffNameIssue`, `validatePinPair`,
      `validatePasswordPair`, `roleKeyFor`, `encodePermissions` /
      `decodePermissions`, `effectivePermissions`, `grantIssue`.

## 3. Data (TDD)

- [ ] `staff_access.dart`: `OutletStaff.permissions` + `roleName` dari tabel
      `roles`.
- [ ] `users.dart`: daftar akun, tambah/ubah staf, reset PIN, ganti PIN /
      kata sandi sendiri, daftar role, simpan matriks, role custom
      (buat/ganti nama/hapus). Tes skenario + izin + batas wewenang.

## 4. Aplikasi

- [ ] `UsersRepository` + lokal + palsu; `SessionRepository.unlockPin`,
      `refreshCurrent`; `StaffProfile.roleName`, `roleLabel`.
- [ ] VM (TDD): daftar pengguna + kunci, form pengguna (PIN + ulangi,
      reset PIN), matriks role, Akun saya.
- [ ] Layar `/pengguna` (tab Pengguna, Role & izin), dialog pengguna,
      `/akun`; menu; ARB id/en.
- [ ] Tes widget 1440 / 800 / 360.

## 5. Selesai

- [ ] Format, analyze, semua tes.
- [ ] Review subagent; perbaiki Critical/Important.
- [ ] Uji manual Xvfb + tangkapan layar.
- [ ] Spec Status & gap, README spec, CHANGELOG 0.22.0, versi `0.22.0+23`.
- [ ] PR, CI hijau, squash merge, cek rilis.
