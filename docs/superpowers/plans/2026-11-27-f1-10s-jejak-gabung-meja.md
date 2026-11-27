# Rencana F1-10s — Jejak gabung meja

Spec: `docs/superpowers/specs/2026-11-27-f1-10s-jejak-gabung-meja-design.md`

- [x] 1. Model `Sale.mergedIntoId`, `serverpod generate`,
  `serverpod create-migration --tag jejak-gabung`.
- [x] 2. Data: tes jejak (gagal), lalu `mergeOpenBills` dan
  `SaleDetail.mergedBills`.
- [x] 3. Flutter: tes widget (gagal), lalu `mergedBillLabel`, l10n, palsu.
- [x] 4. Panduan ID/EN, spec F1-10d, README specs, STATUS-JEDA, GAP-FASE1,
  CHANGELOG 0.155.0, pubspec 0.155.0+158.
- [x] 5. Format, analyze, semua tes, review subagent, uji Xvfb.
- [x] 6. PR dan rilis.
