# Rencana F1-07r · Tombol Simpan di dialog Buang perubahan? form produk

Spec: [F1-07r](../specs/2026-11-20-f1-07r-simpan-dari-dialog-produk-design.md).

- [x] 1. Tes gagal dulu: `confirm_discard_test.dart` dan grup F1-07r di
  `product_flow_test.dart`.
- [x] 2. `confirmDiscardChanges(onSave:)`, kunci l10n `discardSave`,
  `ProductFormScreen._confirmLeave`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (Important: produk ganda
  setelah simpan dari dialog bila form tetap tampil, navigasi kedua selama
  simpan ikut diteruskan; Minor: tombol di ponsel, tes tujuan, galat
  penyimpanan; form tertutup dicatat sebagai gap).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-07r/`.
- [x] 6. Dokumen: spec, gap F1-07q, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
