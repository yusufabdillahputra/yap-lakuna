# Rencana F1-01b · Produk pertama di onboarding

Spec: `docs/superpowers/specs/2026-11-14-f1-01b-produk-pertama-onboarding-design.md`

## Langkah

- [x] Data: tes `store_setup_test` grup *produk pertama* (produk + stok awal
  dalam transaksi setup, menu F&B tanpa stok, draf tidak valid → tidak ada
  tenant), lalu `setupStore(firstProduct:)` + `writeProductInTx`.
- [x] Repositori: `StoreRepository.setup(input, {firstProduct})` di versi
  lokal dan palsu (`setupProducts`).
- [x] VM: tes pilihan bawaan, validasi, draf barang vs menu, lewati/import,
  isian bertahan; lalu `FirstProductChoice`, isian, `productError`,
  `opensImport`, `onBeforeSetup`.
- [x] View langkah 4: pilihan (`first-product-*`), isian singkat, pesan
  *Periksa isian produk pertama*; label langkah *Produk pertama*.
- [x] Router: `importAfterSetup` → `Routes.productsImport`;
  `ProductListScreen(openImport:)` membuka dialog import sekali.
- [x] Tes widget onboarding: alur lengkap dengan produk (tablet + 400 px),
  produk kosong menahan, lewati, import membuka dialog.
- [x] Uji penuh (format, analyze, domain/data/flutter).
- [x] Uji manual Xvfb: setup baru dengan produk pertama (tampil di Produk,
  stok 24); setup baru dengan pilihan import (dialog import terbuka).
- [x] Review subagent, perbaikan temuan.
- [x] Dokumen rilis: spec status, README spec, STATUS-JEDA, spec F1-01 dan
  F1-07 gap, panduan, CHANGELOG 0.52.0, pubspec.
