# Rencana F1-03f · Cetak ulang rekap dari layar Sesi kasir

Spec: [F1-03f](../specs/2026-11-14-f1-03f-rekap-sesi-dari-layar-sesi-kasir-design.md).
Rilis: v0.87.0+90.

- [x] 1. Data (TDD): `listRecentClosedSessions`; izin
  `cash_session:close` untuk rekap sesi perangkat sendiri.
- [x] 2. Flutter repositori: `CashDrawerRepository.recentClosed` /
  `loadSessionRecap`, palsu untuk tes.
- [x] 3. Dialog Rekap sesi menerima `loadRecap`; Laporan ikut.
- [x] 4. VM Sesi kasir (TDD): `previous`, muat ulang setelah *Buka sesi
  baru*.
- [x] 5. Widget (TDD): kartu *Sesi sebelumnya* 1280 / 360 px, ketuk
  membuka dialog; l10n.
- [x] 6. Format, analyze, semua tes.
- [x] 7. Review subagent; perbaiki temuan Critical/Important.
- [x] 8. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-03f/`.
- [x] 9. Dokumen: spec, README spec, STATUS-JEDA, panduan ID/EN,
  CHANGELOG, versi.
- [x] 10. PR, CI hijau, squash-merge, rilis (#93).
