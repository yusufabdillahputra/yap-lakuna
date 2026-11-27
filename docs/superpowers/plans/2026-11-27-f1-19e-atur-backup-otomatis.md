# Rencana F1-19e · Atur backup otomatis

Spec: `docs/superpowers/specs/2026-11-27-f1-19e-atur-backup-otomatis-design.md`

- [x] 1. Domain: `calendarDaysAgo` + tes; `HomeViewModel.backupDaysAgo`
  memakainya.
- [x] 2. Data: preferensi perangkat lewat stage/apply/finish restore + tes
  (`packages/lakuna_data/test`).
- [x] 3. Repositori: `everyHours`/`keep`, setter dengan izin, pangkas ke
  pilihan; penjadwal memakai jarak pilihan; `_stage` mengirim preferensi;
  `BackupOverview.timezone` + tes.
- [x] 4. VM + widget: pilihan *Setiap* / *Simpan*, keterangan, hari
  kalender (+ kemarin); l10n ID/EN; tes 1280/360.
- [x] 5. Dokumen: spec F1-19d gap, README, STATUS-JEDA, GAP-FASE1,
  panduan ID/EN, CHANGELOG, pubspec.
- [x] 6. Format, analyze, semua tes, review subagent, uji Xvfb.
- [x] 7. PR dan rilis.
