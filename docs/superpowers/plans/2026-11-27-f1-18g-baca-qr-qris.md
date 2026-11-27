# Rencana F1-18g — Baca QR dari gambar stiker QRIS

Spec: `docs/superpowers/specs/2026-11-27-f1-18g-baca-qr-qris-design.md`.

- [x] 1. Domain `parseQrisPayload` + `QrisPayload`: tes dulu.
- [x] 2. Data `readQrisFromImage` (zxing2 + image), fixture PNG/JPEG: tes
      dulu.
- [x] 3. View model Pengaturan: pembaca QR (isolate, bisa diganti di
      tes), status baca, isi otomatis isian kosong, beda NMID.
- [x] 4. View: baris hasil pemeriksaan QR; tes widget.
- [x] 5. ARB ID/EN, panduan, NOTICE (zxing2), CHANGELOG, versi
      0.141.0+144, spec F1-18 / README / STATUS-JEDA / GAP-FASE1.
- [x] 6. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 7. PR dan rilis.
