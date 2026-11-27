# Rencana F1-12n · PDF retur pembelian (RB-) tersendiri

Spec: `docs/superpowers/specs/2026-11-27-f1-12n-pdf-retur-pembelian-design.md`

- [x] 1. Data: tes gagal dulu (baris retur per retur, nama staf), lalu
  `PurchaseDetail.returnItems` / `returnStaffNames` di `loadPurchaseDetail`.
- [x] 2. Flutter: tes tabel cetak dulu, lalu `purchaseReturnPrintTable`,
  `purchaseReturnPrintFileName`; l10n ID/EN.
- [x] 3. Tombol PDF per retur di `_ActionsCard`; fake repositori mencatat
  baris retur; tes widget desktop.
- [x] 4. Dokumen: spec F1-12c gap, README specs, STATUS-JEDA, GAP-FASE1,
  panduan ID/EN Pembelian, CHANGELOG, pubspec.
- [x] 5. Format, analyze, semua tes, review subagent (temuan: filter tenant
  nama staf, baris barang hilang, tombol Proses retur meluap di 360 px), uji
  Xvfb.
- [ ] 6. PR dan rilis.
