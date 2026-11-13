# Rencana F1-10f · Pelanggan dan harga grup di open bill F&B

Spec: `docs/superpowers/specs/2026-11-13-f1-10f-pelanggan-open-bill-design.md`.

- [x] 1. Data (TDD): `setOpenBillCustomer` (pasang/lepas pelanggan, isi
      nama bill yang kosong, harga ulang semua item sesuai grup, tolak bila
      split/bayar bagian), `OpenBill.customer`, harga grup di
      `addBillItem` / `setBillItemQuantity`.
- [x] 2. Gabung meja: tolak pelanggan berbeda (`BillMergeReason.customer`),
      pakai pelanggan sumber bila tujuan kosong lalu harga ulang.
- [x] 3. Bayar open bill: kredit untuk pelanggan lain ditolak
      (`BillCustomerMismatch`).
- [x] 4. Repositori meja: `customers()` dan `setBillCustomer`, versi lokal
      dan palsu (harga grup tiruan).
- [x] 5. `DiningViewModel` (TDD): daftar & cari pelanggan, `setCustomer`,
      `canSetCustomer`, sumber gabung disaring pelanggan. Kasir memakai
      pelanggan bill sebagai pilihan awal kredit.
- [x] 6. Baris pelanggan di panel bill + dialog pemilih, l10n ID/EN, tes
      widget 1280/360 px.
- [x] 7. Uji manual Xvfb.
- [x] 8. Review subagent, perbaiki temuan (harga beku, produk nonaktif,
      pelanggan terhapus, nama 40 karakter, diskon nota).
- [ ] 9. Dokumen (spec, F1-07c, README, STATUS-JEDA, panduan), CHANGELOG
      0.42.0, pubspec `0.42.0+45`, PR, CI, merge.
