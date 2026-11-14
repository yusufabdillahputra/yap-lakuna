# Rencana F1-03c — Peringatan uang di laci tidak cukup

Spec: [F1-03c](../specs/2026-11-14-f1-03c-peringatan-kas-laci-design.md).

## Langkah

- [x] **Tes domain** `drawerShortfallOf`; lalu implementasi.
- [x] **Tes data** `openDrawerCash`; lalu implementasi.
- [x] **Repositori**: `drawerCash` di setup Riwayat, Pengeluaran, Supplier,
  Pembelian (+ versi palsu).
- [x] **Tes VM + widget**; lalu getter `drawerShortfall`, widget
  `DrawerShortfallNote`, l10n, muat ulang setelah simpan.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**.
- [x] **Dokumen**: spec F1-03 / F1-11, README, STATUS-JEDA, panduan,
  CHANGELOG 0.69.0, pubspec `0.69.0+72`.
- [ ] **PR, merge, cek rilis.**
