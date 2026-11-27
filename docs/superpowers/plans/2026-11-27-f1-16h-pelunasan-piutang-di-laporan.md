# Rencana F1-16h — Pelunasan piutang per metode dan rekening di Laporan

Spec: `docs/superpowers/specs/2026-11-27-f1-16h-pelunasan-piutang-di-laporan-design.md`.

- [x] 1. Tes domain `debtCollection`, lalu `ReportDebtPayment`,
      `DebtCollection`, dan `_byAccount` bersama.
- [x] 2. Tes data (metode, rekening, di luar periode, dibatalkan,
      penjualan tetap), lalu `ReportData.debtPayments` di `buildReport`.
- [x] 3. Tes label ekspor dan widget 1440/360 px, lalu `_Collections` dan
      `reportTable` summary; ARB ID/EN.
- [x] 4. Spec F1-13i/README/STATUS-JEDA/GAP-FASE1, panduan reports ID/EN,
      CHANGELOG, versi 0.148.0+151.
- [x] 5. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 6. PR dan rilis.
