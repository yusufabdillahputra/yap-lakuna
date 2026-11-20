# Rencana F1-05g · Rekening tujuan per pembayaran transfer

Spec: `docs/superpowers/specs/2026-11-20-f1-05g-rekening-tujuan-per-pembayaran-design.md`

- [ ] 1. Model `Payment.transferAccount`, `serverpod generate`, migrasi `rekening-tujuan`.
- [ ] 2. Data (TDD): `SalePaymentRequest.transferAccount`, validasi, simpan hanya transfer; laporan membawa rekening.
- [ ] 3. Domain (TDD): `transferByAccount`.
- [ ] 4. VM Kasir (TDD): pilihan rekening panel transfer dan bagian split; `canPay` / tambah bagian.
- [ ] 5. UI: `TransferAccountBox` bisa dipilih, petunjuk, baris bagian split; tes widget 1280 + 360 px.
- [ ] 6. Struk *Ke:* dan laporan per rekening + ekspor (TDD).
- [ ] 7. Uji mutasi, review subagen, uji manual Xvfb.
- [ ] 8. Dokumen (spec F1-05d/F1-05f, README, STATUS-JEDA, panduan), CHANGELOG, versi 0.135.0+138.
- [ ] 9. PR, CI hijau, squash-merge, rilis.
