# Rencana F1-10k — Cetak tagihan (pre-bill) open bill

Spec: [F1-10k](../specs/2026-11-14-f1-10k-cetak-tagihan-design.md)

- [x] **Tes unit** `billReceiptContent` (gagal dulu).
- [x] **Implementasi** `billReceiptContent`, `_receiptItems`, l10n.
- [x] **Data** `DiningData.businessName/outletName` (lokal + fake).
- [x] **Tes VM** `printBill`/`shareBill` (gagal dulu), lalu implementasi.
- [x] **Tes widget** Meja 1280/360 (gagal dulu), lalu dialog + aksi.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: Meja › bill › Cetak tagihan. Hasil: Meja M3
      (3 item, service 5%, PB1 10% termasuk, pembulatan) — pratinjau 80 mm
      sama dengan panel (Subtotal 13.500, Service 675, PB1 1.289, -175,
      TOTAL 14.000) plus *Transfer to*; *Print bill* tanpa printer aktif
      memunculkan galat printer; *Share PDF* menyimpan
      `tagihan-OB-PST-K01-261113-0003.pdf`; dibuka lagi tanpa sisa alert.
- [x] **Dokumen**: spec F1-05e, README, STATUS-JEDA, panduan, CHANGELOG
      0.80.0, versi 0.80.0+83.
- [x] **PR, merge, cek rilis.** PR #86 di-merge (13 cek hijau).
