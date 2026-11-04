# Rencana F1-18 lanjutan: profil, cabang, penjualan & stok (v0.23.0)

Spec: `docs/superpowers/specs/2026-11-03-f1-18-pengaturan-design.md`
(bagian *Lingkup v0.23.0*).

## Langkah

- [x] 1. Domain (`lakuna_domain`), tes dulu:
  - `TotalRounding {none, nearest100, nearest500}` + `roundTotal(Money,
    TotalRounding)` (setengah ke atas, nilai negatif tidak dipakai).
  - `fnbCharges(..., taxInclusive, rounding)`: `FnbCharges.rounding`,
    `taxInclusive`; total = subtotal + service + (eksklusif ? pajak : 0) +
    pembulatan.
  - `SalesRules {allowNegativeStock, rounding}` encode/decode JSON.
  - `validateStoreProfile` / `validateOutletProfile` (nama, alamat, telepon).
  - Laporan: `ReportSale.rounding`, `taxInclusive`; `netContribution`
    memperhitungkan keduanya; `ProfitAndLoss.rounding`.
- [x] 2. Model + migrasi: `sales.rounding_amount int default 0`,
  `sales.tax_inclusive bool default false` (`--tag sale-rounding`).
- [x] 3. Data (`lakuna_data`), tes dulu:
  - `loadSalesRules` / `saveSalesRules`; `FnbRates.taxInclusive` (kunci
    `fnb.tax_inclusive`).
  - `checkoutSale`: total dibulatkan, `rounding_amount`; stok minus ditolak
    (`SaleStockShort`) bila aturan mati.
  - Open bill: `_charges` memakai pembulatan + pajak inklusif;
    penyelesaian bill menyimpan keduanya; stok minus ditolak di
    penyelesaian dan saat menambah item.
  - `saveStoreProfile` (tenant) dan `saveOutletProfile` (outlet), izin
    `settings:manage`.
  - Laporan membaca `rounding_amount` dan `tax_inclusive`.
- [x] 4. Aplikasi:
  - Repositori: `StoreRepository.saveProfile/saveOutlet`,
    `SalesRulesRepository` (atau perluasan repositori pengaturan),
    kasir memuat aturan untuk total.
  - Kasir retail: baris *Pembulatan* dan total dibulatkan; pesan stok tidak
    cukup.
  - Struk: *Subtotal*, *Pembulatan*, "PB1 10% (termasuk)".
  - Laporan laba rugi: baris *Pembulatan*.
  - Pengaturan: bagian *Profil toko*, *Cabang ini*, *Penjualan & stok*,
    sakelar pajak inklusif, *Ukuran tampilan*.
  - Tes VM + widget 1440 / 800 / 360.
- [x] 5. Format, analyze, semua tes, review subagent, uji manual Xvfb,
  spec/README, CHANGELOG 0.23.0, PR.
