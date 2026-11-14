# Rencana F1-05e — Rekening transfer di struk piutang dan kuitansi

Spec: [F1-05e](../specs/2026-11-14-f1-05e-rekening-di-struk-design.md)

- [x] **Tes data** `loadReceiptConfig` memuat `transferAccount` (gagal dulu).
- [x] **Implementasi data** `ReceiptConfig.transferAccount`.
- [x] **Tes unit** struk nota dan kuitansi thermal/A5 (gagal dulu).
- [x] **Implementasi** `receiptTransferLine`, l10n `receiptTransferTo`.
- [ ] **Review** subagent baru; perbaiki Critical/Important.
- [ ] **Uji manual Xvfb**: nota piutang di Kasir, cetak ulang Riwayat,
      kuitansi pembayaran sebagian.
- [ ] **Dokumen**: spec F1-05c, README, STATUS-JEDA, panduan, CHANGELOG
      0.79.0, versi 0.79.0+82.
- [ ] **PR, merge, cek rilis.**
