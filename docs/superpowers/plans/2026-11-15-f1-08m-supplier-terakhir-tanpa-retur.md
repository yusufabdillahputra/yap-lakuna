# Rencana F1-08m · Supplier terakhir mengabaikan barang yang seluruhnya diretur

Spec: [F1-08m](../specs/2026-11-15-f1-08m-supplier-terakhir-tanpa-retur-design.md).

- [x] 1. Tes data gagal dulu (`purchases_test.dart`): retur sebagian, retur
  penuh, satu-satunya pembelian diretur penuh, dua baris barang sama.
- [x] 2. `lastSuppliersOf` melewati baris yang diretur penuh.
- [x] 3. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 4. Review subagent; temuan diperbaiki (tanpa Critical/Important; Minor: pakai `purchaseReturnsOf` + `_returnedMilliOf` yang sudah ada dan berindeks, catatan harga cadangan di aturan 5).
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08m/`.
- [x] 6. Dokumen: spec, gap F1-08d, README spec, STATUS-JEDA, panduan,
  CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
