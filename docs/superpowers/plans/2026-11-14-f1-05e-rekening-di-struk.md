# Rencana F1-05e — Rekening transfer di struk piutang dan kuitansi

Spec: [F1-05e](../specs/2026-11-14-f1-05e-rekening-di-struk-design.md)

- [x] **Tes data** `loadReceiptConfig` memuat `transferAccount` (gagal dulu).
- [x] **Implementasi data** `ReceiptConfig.transferAccount`.
- [x] **Tes unit** struk nota dan kuitansi thermal/A5 (gagal dulu).
- [x] **Implementasi** `receiptTransferLine`, l10n `receiptTransferTo`.
- [x] **Review** subagent baru; perbaiki Critical/Important.
- [x] **Uji manual Xvfb**: nota piutang di Kasir, cetak ulang Riwayat,
      kuitansi pembayaran sebagian. Hasil: struk 80 mm nota kredit Rp 16.500
      mencetak *Transfer to: BCA 123-456-7890 a.n. Warung Contoh Jaya*
      (dibungkus) setelah *Due*, sama di cetak ulang; kuitansi Rp 10.000
      (sisa Rp 20.000) thermal mencetak baris setelah *Balance*. Kuitansi
      A5 awalnya berlabel *Transfer to* tepat di bawah *Method: Cash*
      (terbaca seolah tunai itu ditransfer), diganti *Pay the balance to* /
      *Transfer sisa ke* di akhir isian.
- [x] **Dokumen**: spec F1-05c, README, STATUS-JEDA, panduan, CHANGELOG
      0.79.0, versi 0.79.0+82.
- [x] **PR, merge, cek rilis.** PR #85 di-merge (13 cek hijau).
