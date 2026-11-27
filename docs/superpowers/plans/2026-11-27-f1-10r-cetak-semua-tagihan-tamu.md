# Rencana F1-10r — Cetak semua tagihan tamu sekaligus

Spec: `docs/superpowers/specs/2026-11-27-f1-10r-cetak-semua-tagihan-tamu-design.md`

- [x] 1. PDF: tes `buildReceiptsPdf` dua halaman (gagal), lalu refactor
  `receipt_pdf.dart`.
- [x] 2. `BillPrintJob`: tes `printBills` / `shareBills` (gagal), lalu
  implementasi dengan pembuat PDF tersuntik.
- [x] 3. VM split: tes `printableParts` dan nama job (gagal), lalu VM.
- [x] 4. Dialog + view: kunci l10n, `BillPrintPreview.bills`, tombol
  `split-print-all`; tes widget 1280 / 360 (gagal dulu).
- [x] 5. Panduan ID/EN, spec F1-10m, README specs, STATUS-JEDA, GAP-FASE1,
  CHANGELOG 0.153.0, pubspec 0.153.0+156.
- [x] 6. Format, analyze, semua tes, review subagent, uji Xvfb.
- [x] 7. PR dan rilis.
