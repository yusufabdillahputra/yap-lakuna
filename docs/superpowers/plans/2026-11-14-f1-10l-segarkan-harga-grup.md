# Rencana F1-10l · Segarkan harga grup pelanggan di open bill

Spec: [F1-10l](../specs/2026-11-14-f1-10l-segarkan-harga-grup-design.md).
Rilis: v0.88.0+91.

- [x] 1. Model: `Sale.priceGroupId`, `serverpod generate`, migrasi
  `segarkan-harga-grup`.
- [x] 2. Data (TDD): `priceGroupStale`, pilih ulang pelanggan sama,
  ganti pelanggan, gabung meja, item pertama bill kosong.
- [x] 3. Flutter (TDD): palsu mencatat grup harga; peringatan + *Segarkan
  harga* di panel bill 1280 / 360 px; l10n.
- [x] 4. Format, analyze, semua tes.
- [x] 5. Review subagent: tanpa Critical/Important; catatan Minor
  (bill lama ikut dihitung ulang saat ganti/gabung, peringatan saat split)
  dicatat di spec.
- [x] 6. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-10l/`.
- [x] 7. Dokumen: spec, README spec, STATUS-JEDA, panduan ID/EN,
  CHANGELOG, versi.
- [x] 8. PR, CI hijau, squash-merge, rilis (#94).
