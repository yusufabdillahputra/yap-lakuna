# Rencana F1-14 · Supplier & hutang (v0.18.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-14-supplier-hutang-design.md`.
TDD: tes gagal dulu di setiap lapisan.

## 1 · Model & migrasi (`lakuna_server`)

- [x] `suppliers`: `contactName`, `category`, `address`, `termDays`
  (default 14).
- [x] `debt_payments`: `reference`, `proofMediaId`; `MediaKind.paymentProof`.
- [x] `serverpod generate`, `serverpod create-migration --tag supplier`.

## 2 · Domain (`lakuna_domain`)

- [x] `supplier.dart`: `SupplierLimits`, `validateSupplier`.
- [x] `purchaseDebt(allocated:)`; `payableOrder` (jatuh tempo terdekat
  dulu); `supplierPaymentNumber` (`BH-`).
- [x] Tes.

## 3 · Data (`lakuna_data`)

- [x] `suppliers.dart`: daftar + hutang, rincian, simpan, hapus, bayar
  hutang (alokasi, laci, foto bukti), riwayat pembelian supplier.
- [x] `purchases.dart`: hutang dikurangi alokasi (daftar, detail, retur).
- [x] Tes.

## 4 · Aplikasi (`lakuna_flutter`)

- [x] `SuppliersRepository` + lokal + palsu.
- [x] VM daftar, panel (bayar, alokasi manual, foto), form.
- [x] Layar `/supplier`, `/supplier/:id`; dialog riwayat pembelian; menu.
- [x] Pembelian: jatuh tempo dari tempo supplier; tombol *Bayar hutang*.
- [x] Rekap sesi: label *Bayar hutang supplier*.
- [x] i18n ID + EN; tes VM dan widget 1280/360.

## 5 · Selesai

- [x] Review subagent; perbaiki Critical/Important.
- [x] Uji manual Xvfb + tangkapan layar.
- [x] Spec Status & gap, README spec, CHANGELOG 0.18.0, versi `0.18.0+19`.
- [ ] PR, CI hijau, squash merge, cek rilis.
