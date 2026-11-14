# Rencana F1-16c — Umur piutang & hutang di Laporan

Spec: [F1-16c](../specs/2026-11-14-f1-16c-umur-piutang-hutang-design.md)

- [x] **Tes domain** `agingBucketOf` dan `Aging.of` (gagal dulu), lalu
      implementasi di `receivable.dart`.
- [x] **Tes data** `loadDebtReport` umur piutang/hutang (gagal dulu), lalu
      `openReceivables` / `openPayables` dan field `DebtReport`.
- [x] **UI**: tabel Umur piutang / Umur hutang di `_Debts`, l10n ID + EN,
      fake laporan; tes widget 1280 / 360 px.
- [x] **Ekspor**: bagian umur di `reportTable` debts; tes.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: Laporan › Piutang & hutang.
- [x] **Dokumen**: spec F1-14 dan F1-16, README, STATUS-JEDA, panduan,
      CHANGELOG 0.82.0, versi 0.82.0+85.
- [ ] **PR, merge, cek rilis.**
