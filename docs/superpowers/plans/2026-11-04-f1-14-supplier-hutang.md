# Rencana F1-14 · Supplier & hutang (v0.18.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-14-supplier-hutang-design.md`.
TDD: tes gagal dulu di setiap lapisan.

## 1 · Model & migrasi (`lakuna_server`)

- [ ] `suppliers`: `contactName`, `category`, `address`, `termDays`
  (default 14).
- [ ] `debt_payments`: `reference`, `proofMediaId`; `MediaKind.paymentProof`.
- [ ] `serverpod generate`, `serverpod create-migration --tag supplier`.

## 2 · Domain (`lakuna_domain`)

- [ ] `supplier.dart`: `SupplierLimits`, `validateSupplier`.
- [ ] `purchaseDebt(allocated:)`; `payableOrder` (jatuh tempo terdekat
  dulu); `supplierPaymentNumber` (`BH-`).
- [ ] Tes.

## 3 · Data (`lakuna_data`)

- [ ] `suppliers.dart`: daftar + hutang, rincian, simpan, hapus, bayar
  hutang (alokasi, laci, foto bukti), riwayat pembelian supplier.
- [ ] `purchases.dart`: hutang dikurangi alokasi (daftar, detail, retur).
- [ ] Tes.

## 4 · Aplikasi (`lakuna_flutter`)

- [ ] `SuppliersRepository` + lokal + palsu.
- [ ] VM daftar, panel (bayar, alokasi manual, foto), form.
- [ ] Layar `/supplier`, `/supplier/:id`; dialog riwayat pembelian; menu.
- [ ] Pembelian: jatuh tempo dari tempo supplier; tombol *Bayar hutang*.
- [ ] Rekap sesi: label *Bayar hutang supplier*.
- [ ] i18n ID + EN; tes VM dan widget 1280/360.

## 5 · Selesai

- [ ] Review subagent; perbaiki Critical/Important.
- [ ] Uji manual Xvfb + tangkapan layar.
- [ ] Spec Status & gap, README spec, CHANGELOG 0.18.0, versi `0.18.0+19`.
- [ ] PR, CI hijau, squash merge, cek rilis.
