# Rencana F1-13i · Rekening tujuan pembayaran piutang transfer

Spec: `docs/superpowers/specs/2026-11-20-f1-13i-rekening-tujuan-piutang-design.md`

- [x] 1. Model `DebtPayment.transferAccount`, `serverpod generate`, migrasi `rekening-piutang`.
- [x] 2. Data (TDD): `DebtPaymentRequest.transferAccount`, validasi, simpan hanya transfer.
- [x] 3. VM panel pelanggan (TDD): pilihan rekening, `canSubmit`, permintaan.
- [x] 4. UI: `TransferAccountBox` di isian terima, baris riwayat; tes widget 1280 + 360 px.
- [x] 5. Kuitansi *Ke rekening* (TDD).
- [x] 6. Uji mutasi, review subagen, uji manual Xvfb.
- [x] 7. Dokumen (spec F1-05g, README, STATUS-JEDA, panduan), CHANGELOG, versi 0.136.0+139.
- [ ] 8. PR, CI hijau, squash-merge, rilis.
