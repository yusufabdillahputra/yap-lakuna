# Rencana F1-16d — Target margin toko

Spec: [F1-16d](../specs/2026-11-20-f1-16d-target-margin-toko-design.md)

- [x] 1. Domain: tes `SalesRules.targetMarginBp` (JSON, rusak, copyWith kosong), `targetMarginIssue`, `marginGapBp`; lalu implementasi.
- [x] 2. Data: tes `loadReport` memuat target (dengan / tanpa izin laba); lalu `ReportData.targetMarginBp`.
- [x] 3. Pengaturan: tes VM + widget isian target; lalu isian di kartu *Penjualan & stok*.
- [x] 4. Laporan: tes widget kartu margin (tercapai, kurang, tanpa target, tanpa penjualan) dan baris ekspor; lalu tampilan + l10n.
- [x] 5. Uji mutasi, review subagen, perbaiki temuan.
- [x] 6. Uji manual Xvfb dan tangkapan layar.
- [x] 7. Dokumen (spec F1-16, README, STATUS-JEDA, panduan), CHANGELOG, versi 0.133.0+136.
- [x] 8. PR, CI hijau, squash-merge, rilis (#139).
