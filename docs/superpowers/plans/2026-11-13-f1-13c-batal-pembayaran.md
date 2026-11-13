# Rencana F1-13c · Batal pembayaran piutang & hutang (v0.44.0)

Spec: [F1-13c](../specs/2026-11-13-f1-13c-batal-pembayaran-utang-piutang-design.md).

## Langkah

- [x] Model `debt_payment.spy.yaml`: `voidedAt`, `voidedBy`, `voidReason`,
      `voidCashMovementId` → `serverpod generate` + migrasi
      `batal-bayar-utang`.
- [x] Domain (TDD): `validateDebtPaymentVoidReason` +
      `debtPaymentVoidReasonMax` di `receivable.dart`.
- [x] Data (TDD, `debt_payment_void_test.dart`): `voidDebtPayment` —
      piutang tunai (alokasi hilang, kas keluar, kuitansi tetap lengkap),
      transfer tanpa kas, tanpa sesi ditolak, alasan/izin/cabang/dua kali,
      outbox, laporan kas, hutang laci (kas masuk) dan bank.
- [x] `CashSourceKind.debtPaymentVoid` / `supplierPaymentVoid`, label di
      Laporan dan daftar gerak kas sesi kasir.
- [x] Repositori: `voidPayment` di `CustomersRepository` dan
      `SuppliersRepository` (+ cek `cash_movements:create` untuk laci),
      `outletId` di setup; versi palsu untuk tes.
- [x] View model panel pelanggan/supplier: `voidPayment`, `canVoid`.
- [x] Dialog bersama `debt_payment_void_dialog.dart`; baris riwayat batal
      dicoret + label + alasan; kuitansi bercap BATAL.
- [x] Tes view model + widget 1280/360 px.
- [x] Panduan ID/EN, spec F1-13/F1-14/README/STATUS-JEDA, CHANGELOG,
      versi 0.44.0+47.
- [ ] Uji manual Xvfb, review subagent, PR, CI, merge.
