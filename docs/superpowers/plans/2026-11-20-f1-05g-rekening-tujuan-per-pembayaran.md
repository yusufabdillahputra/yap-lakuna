# Rencana F1-05g · Rekening tujuan per pembayaran transfer

Spec: `docs/superpowers/specs/2026-11-20-f1-05g-rekening-tujuan-per-pembayaran-design.md`

- [x] 1. Model `Payment.transferAccount`, `serverpod generate`, migrasi `rekening-tujuan`.
- [x] 2. Data (TDD): `SalePaymentRequest.transferAccount`, validasi, simpan hanya transfer; laporan membawa rekening.
- [x] 3. Domain (TDD): `transferByAccount`.
- [x] 4. VM Kasir (TDD): pilihan rekening panel transfer dan bagian split; `canPay` / tambah bagian.
- [x] 5. UI: `TransferAccountBox` bisa dipilih, petunjuk, baris bagian split; tes widget 1280 + 360 px.
- [x] 6. Struk *Ke:* dan laporan per rekening + ekspor (TDD).
- [x] 7. Uji mutasi, review subagen, uji manual Xvfb.
- [x] 8. Dokumen (spec F1-05d/F1-05f, README, STATUS-JEDA, panduan), CHANGELOG, versi 0.135.0+138.
- [x] 9. PR, CI hijau, squash-merge, rilis (#141).
