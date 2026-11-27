# Rencana F1-03h — Log masuk/keluar staf

Spec: `docs/superpowers/specs/2026-11-27-f1-03h-log-masuk-keluar-staf-design.md`.

- [x] 1. Model `StaffAccessLog` + enum `StaffAccessKind`, `serverpod
      generate`, migrasi `--tag log-masuk`.
- [x] 2. Tes `lakuna_data` (catat, daftar, kursor, filter, cakupan,
      outbox), lalu `staff_access_log.dart`.
- [x] 3. Tes `LocalSessionRepository` (masuk/keluar/otomatis/gagal), lalu
      `_record` + `pendingLog`.
- [x] 4. `UsersRepository.accessLog` (lokal + palsu), tes izin.
- [x] 5. Tes VM + widget, lalu tab *Log masuk*; ARB ID/EN.
- [x] 6. Spec F1-02/F1-03/README/STATUS-JEDA/GAP-FASE1, panduan
      users-roles ID/EN, CHANGELOG, versi 0.144.0+147.
- [x] 7. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 8. PR dan rilis.
