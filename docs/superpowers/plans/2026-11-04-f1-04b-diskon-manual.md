# Rencana F1-04b: diskon manual & persetujuan PIN (v0.24.0)

Spec: `docs/superpowers/specs/2026-11-04-f1-04b-diskon-manual-design.md`.

## Langkah

- [x] 1. Domain (`lakuna_domain`), tes dulu:
  - `DiscountKind {percent, amount}`, `ManualDiscount` (+ `cut(Money)`,
    `DiscountIssue`), `parseDiscountInput`.
  - `SalesRules.discountNeedsPin` (bawaan `true`, JSON toleran).
  - `ReportSale.manualDiscount`; `netContribution`, `ProfitAndLoss.discount`
    memasukkannya.
- [x] 2. Model + migrasi (`--tag manual-discount`): `sale_items.discount_amount`,
  `discount_bp`; `sales.discount_amount`, `discount_bp`,
  `line_discount_amount`, `discount_approved_by`.
- [x] 3. Data (`lakuna_data`), tes dulu:
  - `SaleLineRequest.discount`, `checkoutSale(discount:, discountApproverId:)`:
    potongan baris & nota, total > 0, kolom baru.
  - Izin: `sales:discount` aktor, atau penyetuju sah + sakelar hidup
    (`DiscountNotPermitted`, `ApproverNotPermitted`).
  - Laporan membaca diskon manual; retur memakai total nota.
- [x] 4. Aplikasi:
  - `CashierRepository.checkout` meneruskan diskon + penyetuju; cek
    `hasApproval` dan habiskan persetujuan setelah berhasil.
  - `SessionRepository.grantApproval(ttl:)`; persetujuan diskon 30 menit.
  - `CashierViewModel`: diskon baris/nota, `canDiscount`,
    `discountNeedsApproval`, penyetuju, total; reset saat keranjang kosong.
  - Dialog diskon (baris & nota), sub-baris diskon, baris total, tombol
    *Diskon*; tekan lama / klik kanan baris.
  - Struk & riwayat: baris diskon.
  - Pengaturan *Penjualan & stok*: sakelar *Diskon manual butuh PIN
    manajer* aktif.
  - Laba rugi: diskon manual ikut di *Diskon*.
- [x] 5. Format, analyze, semua tes, review subagent, uji manual Xvfb,
  CHANGELOG 0.24.0, versi `0.24.0+25`, spec & README, PR.
