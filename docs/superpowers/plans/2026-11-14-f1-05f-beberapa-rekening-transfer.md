# Rencana F1-05f · Beberapa rekening transfer

Spec: [F1-05f](../specs/2026-11-14-f1-05f-beberapa-rekening-transfer-design.md).
Rilis: v0.86.0+89.

- [x] 1. Domain (TDD): `normalizeTransferAccounts`,
  `transferAccountIssue`, `SalesRules.transferAccounts`, `fromJson`
  membatasi baris; `ProfileLimits.transferAccountLines`.
- [x] 2. Data (TDD): `saveSalesRules` merapikan dan menolak 4 rekening /
  baris 101 karakter; `ReceiptConfig.transferAccounts`.
- [x] 3. Flutter pengaturan (TDD): galat VM, isian multi-baris, *Simpan*
  nonaktif saat galat; l10n baru.
- [x] 4. Flutter bayar (TDD): `CashierViewModel.transferAccounts`,
  `TransferAccountBox(accounts:)` salin per baris, keterangan tombol,
  *Bagi beberapa metode*.
- [x] 5. Struk dan kuitansi (TDD): `receiptTransferLines`, kuitansi A5.
- [x] 6. Format, analyze, semua tes.
- [x] 7. Review subagent; perbaiki temuan Critical/Important.
- [x] 8. Uji manual Xvfb + tangkapan layar ke
  `/mnt/project-files/lakuna/f1-05f/`.
- [x] 9. Dokumen: spec, README spec, STATUS-JEDA, panduan ID/EN,
  CHANGELOG, versi.
- [ ] 10. PR, CI hijau, squash-merge, rilis.
