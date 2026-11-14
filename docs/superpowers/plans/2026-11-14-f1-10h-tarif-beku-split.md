# Rencana F1-10h · Tarif beku saat split bill dibayar

Spec: `docs/superpowers/specs/2026-11-14-f1-10h-tarif-beku-split-design.md`

## Langkah

- [x] Model: `Sale.roundingStep` (`rounding_step`), `serverpod generate`,
  migrasi `tarif-beku`.
- [x] Domain: tes lalu `TotalRounding.byStep`.
- [x] Data: tes `split_frozen_rates_test` (bill tanpa bayar ikut tarif
  terkini, bagian pertama membekukan sampai nota lunas, bill lain tarif
  baru, QRIS menunggu membekukan dan batal melepas, nota mencatat
  `rounding_step`).
- [x] Data: `billRates` + `_ratesOf` di semua perhitungan bill,
  `paySplitPart` membekukan, `cancelSplitPayment` melepas, `_completeBill`
  mengisi `rounding_step`.
- [ ] Uji penuh (format, analyze, domain/data/flutter).
- [ ] Uji manual Xvfb: split rata, bayar A, ubah service, total bill dan
  tagihan B tetap.
- [ ] Review subagent, perbaikan temuan.
- [ ] Dokumen rilis: spec status, spec F1-10 gap, README spec, STATUS-JEDA,
  panduan split bill, CHANGELOG 0.54.0, pubspec.
