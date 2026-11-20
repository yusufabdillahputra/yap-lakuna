# Rencana F1-08n · Tombol Simpan di dialog Buang perubahan? penyesuaian stok

Spec: [F1-08n](../specs/2026-11-20-f1-08n-simpan-dari-dialog-penyesuaian-design.md).

- [x] 1. Tes gagal dulu: grup F1-08n di `stock_flow_test.dart`.
- [x] 2. `StockScreen._confirmLeave` dan `_LocationSelect._select` dengan
  `onSave`.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (tanpa bug kode; Important:
  tes ganti lokasi tidak membuktikan pindah lokasi; Minor: tujuan navigasi
  diperiksa lewat jalur router, tes menu lain selama simpan ganti lokasi).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08n/`.
- [x] 6. Dokumen: spec, gap F1-08k dan F1-07r, README spec, STATUS-JEDA,
  panduan, CHANGELOG, versi.
- [x] 7. PR, CI hijau, squash-merge, rilis (#129).
