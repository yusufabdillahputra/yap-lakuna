# Rencana F1-03d — Peringatan uang laci saat void

Spec: [F1-03d](../specs/2026-11-14-f1-03d-peringatan-laci-saat-void-design.md).

## Langkah

- [x] **Tes data** `saleCashInSession` (murni + cocok dengan rekap); lalu implementasi.
- [x] **Repositori**: `HistoryData.openSessionId`, `CustomersSetup.drawerCash`
  (+ versi palsu).
- [x] **Tes VM + widget**; lalu `voidDrawerShortfall`, dialog void nota,
  dialog batal piutang.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**.
- [x] **Dokumen**: spec F1-03c, README, STATUS-JEDA, panduan, CHANGELOG
  0.70.0, pubspec `0.70.0+73`.
- [ ] **PR, merge, cek rilis.**
