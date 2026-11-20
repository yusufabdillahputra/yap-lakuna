# Rencana F1-13g · Tombol Simpan di dialog Buang perubahan? pelanggan & supplier

Spec: [F1-13g](../specs/2026-11-20-f1-13g-simpan-dari-dialog-pelanggan-supplier-design.md).

- [x] 1. Tes gagal dulu: `confirm_discard_test.dart`, grup F1-13g di
  `customers_flow_test.dart` dan `suppliers_flow_test.dart`.
- [x] 2. `DiscardChangesScope(onSave:)`, `onSave` di dialog pelanggan dan
  supplier.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki.
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-13g/`.
- [x] 6. Dokumen: spec, gap F1-13e dan F1-07r, README spec, STATUS-JEDA,
  panduan, CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
