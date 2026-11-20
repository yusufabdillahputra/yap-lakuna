# Rencana F1-10q · Kursor pindah ke isian yang salah di dialog meja

Spec: [F1-10q](../specs/2026-11-20-f1-10q-fokus-isian-salah-design.md).

- [x] 1. Tes gagal dulu: grup F1-10q di `dining_tables_tab_test.dart`.
- [x] 2. `dining_tables_tab.dart`: `FocusNode` per isian, `focusInvalid`
  di `_DialogSaving` dan ketiga dialog.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: pratinjau rentang
  dipindah ke bawah Dari–Sampai; Minor: galat penyimpanan didahulukan,
  kata Enter di spec, 5 tes tambahan).
- [x] 5. Uji manual Xvfb (Master data › Meja & area) + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-10q/`.
- [x] 6. Dokumen: spec, gap F1-10p, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
