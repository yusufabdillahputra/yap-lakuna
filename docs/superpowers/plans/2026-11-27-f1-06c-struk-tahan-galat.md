# Rencana F1-06c — Struk tahan galat

Spec: `docs/superpowers/specs/2026-11-27-f1-06c-struk-tahan-galat-design.md`.

- [x] 1. Data: tes `loadReceiptConfig` (JSON salah bentuk, logo tak
      terbaca, `onError`) dan `loadReceiptConfigOrDefault`; lalu kode.
- [x] 2. Flutter: `logReceiptError`; repositori Kasir, Meja, Riwayat,
      Pelanggan memakai `loadReceiptConfigOrDefault`; tes repositori kasir.
- [x] 3. `PlatformReceiptPrinter`: catat galat non-printer; tes Bluetooth.
- [x] 4. Spec F1-06 / README / STATUS-JEDA / GAP-FASE1, CHANGELOG, versi
      0.142.0+145.
- [x] 5. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 6. PR dan rilis.
