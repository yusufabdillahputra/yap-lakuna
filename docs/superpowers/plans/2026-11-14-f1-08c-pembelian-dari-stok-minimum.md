# Rencana F1-08c · Buat pembelian dari stok minimum (v0.49.0)

Spec: [F1-08c](../specs/2026-11-14-f1-08c-pembelian-dari-stok-minimum-design.md).

## Langkah

- [x] Domain (TDD): `restockQuantity` (bulat, desimal, minus, minimal 1).
- [x] `PurchaseRestock`; `PurchaseFormViewModel(restock:)` mengisi baris,
      lokasi, catatan dilewati; `startNew` kosong (tes VM).
- [x] `StockViewModel.restock` selaras lokasi (tes VM dengan `stockGate`).
- [x] Tombol `stock-restock` di `_MinimumPanel`, `onRestock` dari router
      (izin `purchases:manage`), `extra` di rute pembelian baru, catatan
      `purchase-restock-note`; tes widget 1280/360 px + tanpa izin.
- [x] Uji manual Xvfb.
- [x] Review subagent, perbaiki temuan (muat ulang Stok setelah kembali +
      buka detail setelah diterima, ketukan ganda, catatan menyebut lokasi
      yang dipakai, jamak EN, anotasi `PurchaseSetup`, fake per lokasi,
      tes jumlah & kembali). Ganti satuan dan catatan setelah draf
      dicatat sebagai gap.
- [x] Panduan stok ID/EN, spec F1-08/F1-08c/README/STATUS-JEDA,
      CHANGELOG, versi 0.49.0+52.
- [ ] PR, CI, merge, cek rilis.
