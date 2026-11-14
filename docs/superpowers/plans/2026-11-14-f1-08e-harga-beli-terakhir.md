# Rencana F1-08e · Harga beli terakhir di pembelian dari stok minimum

Spec: [F1-08e](../specs/2026-11-14-f1-08e-harga-beli-terakhir-design.md).
Rilis: v0.89.0+92.

- [x] 1. Domain (TDD): `perBaseUnitPrice`.
- [x] 2. Data (TDD): `lastPurchasePricesOf`.
- [x] 3. Flutter (TDD): repositori + palsu, VM mengisi harga baris,
  catatan `purchase-restock-price` 1280 / 360 px; l10n.
- [x] 4. Format, analyze, semua tes.
- [x] 5. Review subagent; perbaiki temuan Important: baris bonus Rp 0
  dilewati, `priceRev` naik agar isian harga ikut berganti.
- [x] 6. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08e/`.
- [x] 7. Dokumen: spec, README spec, STATUS-JEDA, panduan ID/EN,
  CHANGELOG, versi.
- [x] 8. PR, CI hijau, squash-merge, rilis (#95).
