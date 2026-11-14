# Rencana F1-16b — Rentang tanggal bebas di Laporan

Spec: [F1-16b](../specs/2026-11-14-f1-16b-rentang-tanggal-laporan-design.md).

**Tujuan:** periode laporan bisa berupa rentang tanggal bebas.

## Langkah

- [x] **Tes domain** `ReportPeriod.custom`, pembanding, `fileKey`,
  validasi; lalu implementasi di `report.dart`.
- [x] **Tes Flutter** label, VM, dialog; lalu `ReportRangeDialog`, pilihan
  Periode, l10n id/en.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: pilih rentang, galat, ekspor.
- [x] **Dokumen**: spec F1-16, README, STATUS-JEDA, panduan laporan
  id/en, CHANGELOG 0.67.0, pubspec `0.67.0+70`.
- [ ] **PR, merge, cek rilis.**
