# Rencana F1-12h · Harga beli terakhir untuk satuan konversi

Spec: [F1-12h](../specs/2026-11-15-f1-12h-harga-terakhir-satuan-konversi-design.md).
Rilis: v0.106.0+109.

- [x] 1. Tes data `lastPurchaseUnitPricesOf` gagal dulu; kode (helper
  bersama dengan `lastPurchasePricesOf`).
- [x] 2. Repositori (lokal + palsu) mengembalikan `LastPurchasePrice`.
- [x] 3. Tes VM gagal dulu; tembolok `LastPurchasePrice`, `_lastPriceFor`
  per satuan, syarat `isBase` dihapus.
- [x] 4. Tes widget scan barcode dus.
- [x] 5. Format, analyze, semua tes; diverifikasi mutasi.
- [x] 6. Review subagent; temuan diperbaiki.
- [x] 7. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-12h/`.
- [x] 8. Dokumen: spec, gap F1-12e/F1-12g, README spec, STATUS-JEDA,
  panduan pembelian ID/EN, CHANGELOG, versi.
- [ ] 9. PR, CI hijau, squash-merge, rilis.
