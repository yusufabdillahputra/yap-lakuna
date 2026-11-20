# Rencana F1-12j · Gulir ke galat setelah simpan pembelian gagal

Spec: [F1-12j](../specs/2026-11-20-f1-12j-gulir-ke-galat-pembelian-design.md).

- [x] 1. Tes gagal dulu: `failedSubmits` di `purchase_view_models_test.dart`,
  grup F1-12j di `purchase_flow_test.dart` (360 px supplier, 1440 px kotak
  galat dari dialog, galat terlihat tidak menggeser).
- [x] 2. `failedSubmits` di view model; `PurchaseFormPanel` stateful dengan
  jangkar galat dan `Scrollable.ensureVisible`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki.
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-12j/`.
- [x] 6. Dokumen: spec, gap F1-12i, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#133).
