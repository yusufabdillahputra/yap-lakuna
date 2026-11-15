# Rencana F1-12g · Harga beli terakhir dari supplier yang dipilih

Spec: [F1-12g](../specs/2026-11-15-f1-12g-harga-terakhir-per-supplier-design.md).
Rilis: v0.105.0+108.

- [x] 1. Tes data `lastPurchasePricesOf(..., supplierId)` gagal dulu; kode.
- [x] 2. Repositori (lokal + palsu) menerima `supplierId`.
- [x] 3. Tes VM gagal dulu; `autoPrice`, tembolok per supplier, penyegaran
  saat ganti supplier, urutan restock.
- [x] 4. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 5. Review subagent; temuan diperbaiki.
- [x] 6. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-12g/`.
- [x] 7. Dokumen: spec, gap F1-08e/F1-12e, README spec, STATUS-JEDA,
  panduan pembelian ID/EN, CHANGELOG, versi.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
