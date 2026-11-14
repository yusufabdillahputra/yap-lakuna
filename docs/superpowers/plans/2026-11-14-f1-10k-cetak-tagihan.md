# Rencana F1-10k — Cetak tagihan (pre-bill) open bill

Spec: [F1-10k](../specs/2026-11-14-f1-10k-cetak-tagihan-design.md)

- [x] **Tes unit** `billReceiptContent` (gagal dulu).
- [x] **Implementasi** `billReceiptContent`, `_receiptItems`, l10n.
- [x] **Data** `DiningData.businessName/outletName` (lokal + fake).
- [x] **Tes VM** `printBill`/`shareBill` (gagal dulu), lalu implementasi.
- [x] **Tes widget** Meja 1280/360 (gagal dulu), lalu dialog + aksi.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [ ] **Uji manual Xvfb**: Meja › bill › Cetak tagihan; Take away.
- [ ] **Dokumen**: spec F1-05e, README, STATUS-JEDA, panduan, CHANGELOG
      0.80.0, versi 0.80.0+83.
- [ ] **PR, merge, cek rilis.**
