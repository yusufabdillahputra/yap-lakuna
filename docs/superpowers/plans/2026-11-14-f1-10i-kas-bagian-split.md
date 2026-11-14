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
- [x] Uji manual Xvfb: meja M4 (Rp 11.000) dibagi rata 4 tamu, bayar A
  tunai Rp 10.000: *Tunai seharusnya di laci* naik dari Rp 177.000 ke
  Rp 179.750 sebelum bill lunas (pembayaran lama tetap terhitung).
- [x] Review subagent: batal bill split lintas perangkat bisa macet (Fase 2)
  → batal bill tidak lagi ditolak, tiap bagian keluar dari laci
  penerimanya; filter tenant, komentar doc, catatan data lama dan QRIS
  bersamaan di spec.
- [x] Dokumen rilis: spec status, spec F1-10 gap, README spec, STATUS-JEDA,
  panduan split bill / sesi kasir, CHANGELOG 0.56.0, pubspec.
