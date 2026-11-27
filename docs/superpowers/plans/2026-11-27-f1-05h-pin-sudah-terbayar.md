# Rencana F1-05h — PIN manajer untuk *Sudah Terbayar*

Spec: `docs/superpowers/specs/2026-11-27-f1-05h-pin-sudah-terbayar-design.md`.

- [x] 1. Domain `canConfirmQrisDirectly`: tes, lalu kode.
- [x] 2. Data `QrisStaticSettings.cashierConfirmWithoutPin` (JSON bawaan
      hidup), `requireQrisConfirmer`, `QrisConfirmNotPermitted`,
      `insertPayments(confirmerId:)`; `checkoutSale`, `payOpenBill`,
      `paySplitPart`, `confirmSplitPayment` menerima `qrisApproverId`.
      Tes dulu.
- [x] 3. Repositori kasir dan meja: `qrisApproverId` + `hasApproval` +
      `consumeApproval`; `CashierData` / `SplitBillData` membawa aturan
      langsung dan sakelar; palsu ikut.
- [x] 4. VM kasir dan split bill: penyetuju QRIS, QRIS tampil untuk staf
      tanpa izin, bersihkan penyetuju setelah bayar/galat; tes.
- [x] 5. View: dialog PIN di panel QRIS, dialog bagian split, Split bill
      meja; `ApprovalDialog.eligible`; tes widget.
- [x] 6. Pengaturan QRIS: sakelar + tes.
- [x] 7. ARB ID/EN, panduan, CHANGELOG, versi 0.138.0+141, spec F1-05 /
      F1-18 / README / STATUS-JEDA (butir 80) / GAP-FASE1.
- [x] 8. Format, analyze, semua tes, review subagent, uji Xvfb.
- [x] 9. PR dan rilis.
