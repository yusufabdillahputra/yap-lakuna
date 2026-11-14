# Rencana F1-08f · Tombol *Buat pembelian* macet

Spec: [F1-08f](../specs/2026-11-14-f1-08f-buat-pembelian-macet-design.md).
Rilis: v0.90.0+93.

- [x] 1. Tes gagal dulu: `stock_flow_test.dart` keluar lewat `nav-stock`
  lalu *Buat pembelian* lagi.
- [x] 2. Perbaikan `didUpdateWidget` dengan `ModalRoute.isCurrent`.
- [x] 3. Format, analyze, semua tes.
- [x] 4. Review subagent: tanpa Critical; Important (tes ketukan ganda
  belum ada) diperbaiki; Minor nomor generasi penjaga diterapkan.
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08f/`.
- [x] 6. Dokumen: spec, gap F1-08c, README spec, STATUS-JEDA, CHANGELOG,
  versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
