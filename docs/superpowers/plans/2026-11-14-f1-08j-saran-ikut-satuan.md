# Rencana F1-08j · Jumlah saran stok minimum ikut satuan

Spec: [F1-08j](../specs/2026-11-14-f1-08j-saran-ikut-satuan-design.md).
Rilis: v0.96.0+99.

- [x] 1. Tes VM gagal dulu (38 → 7 dus → 38, 36 → 6, ketik jumlah, scan
  ulang, barang manual) dan tes widget 1280 / 360 px.
- [x] 2. `PurchaseFormLine.suggested` + `suggestedIn`; `_applyRestock`,
  `setUnit`, `setQuantity`, `addByCode`.
- [x] 3. Format, analyze, semua tes (Flutter 1165); tes widget
  diverifikasi mutasi.
- [x] 4. Review subagent; Critical/Important diperbaiki.
- [x] 5. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-08j/`.
- [x] 6. Dokumen: spec, gap F1-08c, README spec, STATUS-JEDA, panduan
  stok + pembelian ID/EN, CHANGELOG, versi.
- [ ] 7. PR, CI hijau, squash-merge, rilis.
