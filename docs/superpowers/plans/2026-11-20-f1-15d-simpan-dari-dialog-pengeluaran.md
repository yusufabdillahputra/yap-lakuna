# Rencana F1-15d · Tombol Simpan di dialog Buang perubahan? pengeluaran

Spec: [F1-15d](../specs/2026-11-20-f1-15d-simpan-dari-dialog-pengeluaran-design.md).

- [x] 1. Tes gagal dulu: grup F1-15d di `expenses_flow_test.dart`.
- [x] 2. `ExpensesScreen._confirmLeave` dengan `onSave`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: galat penyimpanan
  di ponsel tanpa umpan balik, daftar basi bila layar tetap tampil; Minor:
  tes kasus tepi).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-15d/`.
- [x] 6. Dokumen: spec, gap F1-15c dan F1-07r, README spec, STATUS-JEDA,
  panduan, CHANGELOG, versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#128).
