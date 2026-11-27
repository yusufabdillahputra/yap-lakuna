# Rencana F1-19f · Backup dan PDF besar di isolate terpisah

Spec: `docs/superpowers/specs/2026-11-27-f1-19f-isolate-backup-pdf-design.md`

- [x] 1. Tes jeda isolate utama (PDF tabel, label, backup) gagal dulu.
- [x] 2. `pdf_fonts.dart`; `buildBarcodeLabelPdf` dan `reportPdf` lewat
  `Isolate.run`.
- [x] 3. `createBackup`: SHA-256 dan zip lewat `Isolate.run`.
- [x] 4. Dokumen: spec F1-07e/F1-08b/F1-19d, README, STATUS-JEDA,
  GAP-FASE1, CHANGELOG, pubspec.
- [x] 5. Format, analyze, semua tes, review subagent, uji Xvfb.
- [ ] 6. PR dan rilis.
