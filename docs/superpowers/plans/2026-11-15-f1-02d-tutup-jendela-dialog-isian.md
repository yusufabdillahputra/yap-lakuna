# Rencana F1-02d · Menutup jendela saat dialog berisi isian terbuka

Spec: [F1-02d](../specs/2026-11-15-f1-02d-tutup-jendela-dialog-isian-design.md).

- [x] 1. Tes gagal dulu: `confirm_discard_test.dart` (`canDiscardAll`),
  alur dialog pelanggan + `handleRequestAppExit`.
- [x] 2. `DiscardChangesScope` stateful + daftar dialog terbuka +
  pertanyaan bersama; router memanggil `canDiscardAll` sebelum
  `canLeaveAll`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: simpan selesai saat pertanyaan terbuka menutup pertanyaan → dialog sibuk menolak tanpa bertanya; Minor: dialog yang sedang ditutup dilewati, aturan 4/5 diperjelas, celah uji dicatat di spec).
- [x] 5. Uji manual Xvfb (tutup jendela Linux saat dialog pelanggan
  berisi isian) + tangkapan layar ke `/mnt/project-files/lakuna/f1-02d/`.
- [x] 6. Dokumen: spec, gap F1-02c, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
