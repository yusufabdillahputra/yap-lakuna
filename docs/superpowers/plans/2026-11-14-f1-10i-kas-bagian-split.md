# Rencana F1-10i · Kas per sesi untuk bagian split bill

Spec: `docs/superpowers/specs/2026-11-14-f1-10i-kas-bagian-split-design.md`

## Langkah

- [x] Model: `Payment.cashSessionId`, `serverpod generate`, migrasi
  `kas-per-pembayaran`.
- [x] Data: tes `split_cash_session_test` (gagal dulu).
- [x] Data: `insertPayments` + QRIS menunggu + konfirmasi mengisi sesi;
  `sessionSalesSummary` per pembayaran; `closeCashSession` per sesi;
  batal nota memeriksa sesi pembayaran.
- [x] Uji penuh (format, analyze, domain/data/flutter).
- [ ] Uji manual Xvfb: rekap laci memuat tunai bagian A sebelum bill lunas.
- [ ] Review subagent, perbaikan temuan.
- [ ] Dokumen rilis: spec status, spec F1-10 gap, README spec, STATUS-JEDA,
  panduan split bill / sesi kasir, CHANGELOG 0.56.0, pubspec.
